#!/usr/bin/env python3
"""Size measurements of an OpenSheaf archive (read only).

usage: measure_size.py ARCHIVE_DIR OUT_JSON

Every file under ARCHIVE_DIR/ocfl is put in one category, by its place in
the OCFL object and the logical path it has in the inventory.  Sizes are
apparent sizes (st_size), each stored file counted once (OCFL stores a file
unchanged between versions only once).
"""
import json, os, sys, statistics
from collections import Counter, defaultdict
from pathlib import Path

root = Path(sys.argv[1])
ocfl = root / "ocfl"
out = {}

IDENTITY = {"genesis.json", "object.json", "datacite.json"}


def size(p):
    return p.stat().st_size


cat_bytes, cat_files = Counter(), Counter()
kind_bytes, kind_files = Counter(), Counter()
objects = []               # (kind, dir)
per_version = []           # dicts for document versions
payload_names = Counter()


def add(cat, p, kind=None):
    s = size(p)
    cat_bytes[cat] += s
    cat_files[cat] += 1
    if kind:
        kind_bytes[kind] += s
        kind_files[kind] += 1
    return s


# storage-root level files
for p in sorted(ocfl.iterdir()):
    if p.is_file():
        add("storage root declarations (0=ocfl_1.1, layout description)", p)

object_dirs = [p.parent for p in ocfl.rglob("0=ocfl_object_1.1")]
versions_by_kind = Counter()
docversions = 0
for d in sorted(object_dirs):
    inv = json.loads((d / "inventory.json").read_text())
    head = inv["head"]
    # kind from the head object.json
    content_of = {}  # content path -> logical path(s)
    for ver, v in inv["versions"].items():
        for dig, lps in v["state"].items():
            for cp in inv["manifest"][dig]:
                content_of.setdefault(cp, set()).update(lps)
    objjson = None
    for dig, lps in inv["versions"][head]["state"].items():
        if "object.json" in lps:
            objjson = json.loads((d / inv["manifest"][dig][0]).read_text())
    kind = objjson["kind"]
    objects.append((kind, d))
    versions_by_kind[kind] += len(inv["versions"])
    seen_files = set()
    vstats = defaultdict(lambda: Counter())
    for p in sorted(d.rglob("*")):
        if not p.is_file():
            continue
        rel = p.relative_to(d).as_posix()
        seen_files.add(rel)
        parts = rel.split("/")
        if rel == "0=ocfl_object_1.1" or parts[-1] in ("inventory.json", "inventory.json.sha512"):
            cat = "inventories + sidecars (+ object declaration)"
            ver = parts[0] if len(parts) == 2 else None
        elif parts[0] == "extensions" and parts[1] == "opensheaf-witnesses":
            name = parts[-1]
            cat = "witnesses: signatures" if name.startswith("signature-") else "witnesses: timestamps/other"
            ver = parts[2]
        elif len(parts) >= 3 and parts[1] == "content":
            ver = parts[0]
            lps = content_of.get(rel, set())
            lp = sorted(lps)[0] if lps else "?"
            if lp in IDENTITY:
                cat = "identity files (genesis/object/datacite.json)"
            elif lp == "keys.json":
                cat = "key log (keys.json)"
            elif lp == "members.json":
                cat = "catalogue members (members.json)"
            elif kind == "document":
                renditions = {r["path"] for r in objjson.get("renditions", [])}
                if lp in renditions or lp.lower().endswith(".pdf") and "/" not in lp:
                    cat = "payload: renditions (PDF)"
                elif lp.startswith("source/"):
                    cat = "payload: sources"
                else:
                    cat = "payload: other sources (TeXmacs .tm, .bib outside source/)"
                    payload_names[lp] += 1
            else:
                cat = "other files of owner/collection"
        else:
            cat = "other files"
            ver = None
        s = add(cat, p, kind)
        if kind == "document" and ver and ver.startswith("v"):
            vstats[ver][cat] += s
            vstats[ver]["files"] += 1
    if kind == "document":
        dvs = set()
        for ver in inv["versions"]:
            for dig, lps in inv["versions"][ver]["state"].items():
                if "object.json" in lps:
                    o = json.loads((d / inv["manifest"][dig][0]).read_text())
                    dvs.add(o.get("documentVersion"))
            logical = sum(size(d / inv["manifest"][dig][0]) * len(lps)
                          for dig, lps in inv["versions"][ver]["state"].items())
            c = vstats[ver]
            payload = sum(v for k, v in c.items() if k.startswith("payload"))
            overhead = sum(v for k, v in c.items() if k != "files" and not k.startswith("payload"))
            per_version.append({"object": d.name, "version": ver,
                                "payload_stored": payload, "overhead_stored": overhead,
                                "signature": c["witnesses: signatures"],
                                "identity": c["identity files (genesis/object/datacite.json)"],
                                "inventory_copy": c["inventories + sidecars (+ object declaration)"],
                                "logical_state_bytes": logical,
                                "description_only": payload == 0})
        docversions += len(dvs)

kinds = Counter(k for k, _ in objects)
out["objects_by_kind"] = dict(kinds)
out["object_versions_by_kind"] = dict(versions_by_kind)
out["document_versions_distinct"] = docversions
out["bytes_by_category"] = dict(cat_bytes)
out["files_by_category"] = dict(cat_files)
out["bytes_by_object_kind"] = dict(kind_bytes)
out["files_by_object_kind"] = dict(kind_files)
out["other_payload_names"] = dict(payload_names)
all_files = [p for p in ocfl.rglob("*") if p.is_file()]
out["ocfl_total_files"] = len(all_files)
out["ocfl_total_bytes"] = sum(size(p) for p in all_files)
payload = sum(v for k, v in cat_bytes.items() if k.startswith("payload"))
overhead_ocfl = out["ocfl_total_bytes"] - payload
out["payload_bytes"] = payload
out["overhead_in_ocfl_bytes"] = overhead_ocfl

# format files outside ocfl/: discovery document and indexes
outside = {"discovery document (opensheaf.json)": [root / "opensheaf.json"]}
for idx in ("names", "owners", "sha512"):
    outside[f"index {idx}/"] = sorted((root / idx).rglob("*.json"))
out["outside_ocfl_format"] = {k: {"files": len(v), "bytes": sum(size(p) for p in v)} for k, v in outside.items()}
fmt_outside = sum(x["bytes"] for x in out["outside_ocfl_format"].values())
out["overhead_total_bytes"] = overhead_ocfl + fmt_outside
out["overhead_pct_of_payload"] = 100 * out["overhead_total_bytes"] / payload

# website and tool files (not format overhead)
fmt_top = {"ocfl", "opensheaf.json", "names", "owners", "sha512", ".git"}
site = Counter()
for p in sorted(root.iterdir()):
    if p.name in fmt_top:
        continue
    files = [p] if p.is_file() else [q for q in p.rglob("*") if q.is_file()]
    site[p.name] = sum(size(q) for q in files)
    site[p.name + " #files"] = len(files)
out["outside_ocfl_not_format"] = dict(site)

def med(key, rows):
    xs = [r[key] for r in rows]
    return {"median": statistics.median(xs), "mean": statistics.mean(xs), "min": min(xs), "max": max(xs), "n": len(xs)}

out["per_document_version_all"] = {k: med(k, per_version) for k in
                                   ("payload_stored", "overhead_stored", "signature", "identity", "inventory_copy", "logical_state_bytes")}
withp = [r for r in per_version if not r["description_only"]]
out["per_document_version_with_new_payload"] = {k: med(k, withp) for k in ("payload_stored", "overhead_stored")}
out["per_document_version_overhead_pct_median"] = statistics.median(
    100 * r["overhead_stored"] / r["payload_stored"] for r in withp)
out["description_only_versions"] = sum(r["description_only"] for r in per_version)
# per document object (whole object, root inventory included)
per_obj = defaultdict(Counter)
for kind, d in objects:
    if kind != "document":
        continue
    for p in d.rglob("*"):
        if p.is_file():
            rel = p.relative_to(d).as_posix()
            isp = "/content/" in rel and not any(rel.endswith("/" + n) for n in IDENTITY)
            per_obj[d.name]["payload" if isp else "overhead"] += size(p)
out["per_document_object"] = {
    "payload_median": statistics.median(c["payload"] for c in per_obj.values()),
    "overhead_median": statistics.median(c["overhead"] for c in per_obj.values()),
    "overhead_pct_median": statistics.median(100 * c["overhead"] / c["payload"] for c in per_obj.values()),
}
json.dump(out, open(sys.argv[2], "w"), indent=1)
Path(sys.argv[2]).with_suffix(".versions.json").write_text(json.dumps(per_version, indent=1))
print(json.dumps(out, indent=1))
