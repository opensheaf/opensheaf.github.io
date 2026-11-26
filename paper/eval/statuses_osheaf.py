"""Per-version statuses of every line, from osheaf's own verifier (core.line_statuses)."""
import json, os, sys
from opensheaf import core as _c; _c.configure(_c.find_root(sys.argv[1]))
from opensheaf import core
out = {}
for obj_id, d, inv in core.objects():
    obj = core.read_json(d, inv, core.OBJ) or {}
    if obj.get("kind") == "owner":
        continue
    _, sts = core.line_statuses(d, inv)
    out[obj_id] = [str(s) for s in sts]
json.dump(out, open(sys.argv[2], "w"), indent=1, sort_keys=True)
