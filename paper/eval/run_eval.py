#!/usr/bin/env python3
"""Reproduce the evaluation numbers of the first OpenSheaf archive (mgubi/papers).

usage: run_eval.py [--public]

Expects, next to this script:
  papers/    a clone of the archive (git clone ~/Dropbox/Safe/papers papers)
  explorer/  a copy of opensheaf-explorer (no build needed; plain ES modules)
and VENV (default ../venv) with opensheaf-py installed (bin/osheaf).
Writes results.json, size.json, statuses_*.json, verify.prof here.
Nothing in papers/ is modified (osheaf verify and resolve only read).
--public: also one Explorer run against https://mgubi.org/papers/ (network-bound).
"""
import json, os, platform, statistics, subprocess, sys, time, pstats, cProfile, socket
from pathlib import Path

HERE = Path(__file__).resolve().parent
PAPERS, EXPLORER = HERE / "papers", HERE / "explorer"
VENV = Path(os.environ.get("VENV", HERE.parent / "venv"))
OSHEAF, PY = VENV / "bin" / "osheaf", VENV / "bin" / "python"
RUNS, PORT = 5, 8765
R = {}


def sh(cmd, **kw):
    return subprocess.run(cmd, shell=isinstance(cmd, str), capture_output=True, text=True, **kw)


def timed(cmd, runs=RUNS, warmup=1, cwd=None):
    for _ in range(warmup):
        subprocess.run(cmd, cwd=cwd, capture_output=True)
    ts = []
    for _ in range(runs):
        t = time.perf_counter()
        p = subprocess.run(cmd, cwd=cwd, capture_output=True, text=True)
        ts.append(time.perf_counter() - t)
    return {"runs_s": [round(x, 3) for x in ts], "median_s": round(statistics.median(ts), 3),
            "min_s": round(min(ts), 3), "max_s": round(max(ts), 3), "returncode": p.returncode,
            "stdout_tail": p.stdout.strip().splitlines()[-1:] , "stderr_tail": p.stderr.strip().splitlines()[-1:]}


# machine
R["machine"] = {
    "cpu": sh("sysctl -n machdep.cpu.brand_string").stdout.strip(),
    "ncpu": int(sh("sysctl -n hw.ncpu").stdout),
    "ram_GiB": int(sh("sysctl -n hw.memsize").stdout) / 2**30,
    "os": sh("sw_vers -productVersion").stdout.strip(),
    "python": sh([str(PY), "-V"]).stdout.strip(),
    "node": sh("node --version").stdout.strip(),
    "ocfl-py": sh([str(PY), "-c", "import importlib.metadata as m; print(m.version('ocfl-py'))"]).stdout.strip(),
}
R["archive_commit"] = sh(["git", "-C", str(PAPERS), "log", "-1", "--format=%H %cI"]).stdout.strip()
R["opensheaf_py_commit"] = sh(["git", "-C", os.path.expanduser("~/Dropbox/Safe/opensheaf-py"), "log", "-1",
                                "--format=%H %cI"]).stdout.strip()
R["explorer_commit"] = (HERE / "explorer.rev").read_text().strip() if (HERE / "explorer.rev").exists() else None

# 1. size
sh([sys.executable, str(HERE / "measure_size.py"), str(PAPERS), str(HERE / "size.json")])
R["size"] = json.loads((HERE / "size.json").read_text())

# 2. osheaf verify, whole archive, local disk
cmd = [str(OSHEAF), "--root", str(PAPERS), "verify", "--json"]
R["osheaf_verify_local"] = timed(cmd)
findings = json.loads(sh(cmd).stdout)
R["osheaf_verify_findings"] = {s: sum(f["severity"] == s for f in findings) for s in ("error", "warning", "result")}
n_obj = sum(R["size"]["objects_by_kind"].values())
n_ver = sum(R["size"]["object_versions_by_kind"].values())
m = R["osheaf_verify_local"]["median_s"]
R["osheaf_verify_local"]["per_object_ms"] = round(1000 * m / n_obj, 1)
R["osheaf_verify_local"]["per_object_version_ms"] = round(1000 * m / n_ver, 1)
R["osheaf_verify_local"]["MB_per_s"] = round(R["size"]["ocfl_total_bytes"] / 1e6 / m, 1)

# 3. profile
prof = HERE / "verify.prof"
sh([str(PY), "-m", "cProfile", "-o", str(prof), str(OSHEAF), "--root", str(PAPERS), "verify", "--json"])
st = pstats.Stats(str(prof))
total = st.total_tt
def tt(pred):
    return sum(v[2] for k, v in st.stats.items() if pred(k))
def cum(pred):
    return max([v[3] for k, v in st.stats.items() if pred(k)] or [0])
R["profile"] = {
    "total_s_under_profiler": round(total, 3),
    "sha512/md5 hashing (HASH.update), tottime": round(tt(lambda k: k[2] == "<method 'update' of '_hashlib.HASH' objects>"), 3),
    "Ed25519 verify (crypto_sign_open), tottime": round(tt(lambda k: "crypto_sign_open" in k[2]), 3),
    "Ed25519 verify calls": sum(v[1] for k, v in st.stats.items() if "crypto_sign_open" in k[2]),
    "file open+read+stat, tottime": round(tt(lambda k: k[2] in ("<built-in method _io.open>", "<method 'read' of '_io.BufferedReader' objects>", "<built-in method posix.stat>", "<built-in method posix.scandir>")), 3),
    "json decode, tottime": round(tt(lambda k: "json" in k[0] and k[2] in ("raw_decode", "json_value", "_jcs_string")), 3),
    "jsonschema, cumtime": round(cum(lambda k: "jsonschema" in k[0] and k[2] == "iter_errors"), 3),
    "ocfl-py Validator.validate_object (85 direct + 85 via StorageRoot.validate), cumtime": round(sum(v[3] for k, v in st.stats.items() if k[2] == "validate_object" and "/ocfl/" in k[0]), 3),
    "ocfl-py StorageRoot.validate, cumtime": round(sum(v[3] for k, v in st.stats.items() if k[2] == "validate" and k[0].endswith("ocfl/storage_root.py")), 3),
    "check_storage cumtime": round(cum(lambda k: k[2] == "check_storage"), 3),
    "check_key_logs cumtime": round(cum(lambda k: k[2] == "check_key_logs"), 3),
    "check_lines cumtime": round(cum(lambda k: k[2] == "check_lines"), 3),
    "check_indexes cumtime": round(cum(lambda k: k[2] == "check_indexes"), 3),
    "check_archive cumtime": round(cum(lambda k: k[2] == "check_archive"), 3),
    "check_presentation cumtime": round(cum(lambda k: k[2] == "check_presentation"), 3),
}

# local HTTP server on the clone
srv = subprocess.Popen([sys.executable, "-m", "http.server", str(PORT), "--bind", "127.0.0.1",
                        "--directory", str(PAPERS)], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
for _ in range(50):
    try:
        socket.create_connection(("127.0.0.1", PORT), 0.2).close(); break
    except OSError:
        time.sleep(0.1)
URL = f"http://127.0.0.1:{PORT}/"
try:
    # 4. Explorer, whole archive, over local HTTP
    base = ["node", "tests/verify-url.mjs", URL, "--no-remote", "--all"]
    R["explorer_verify_http_nodigests"] = timed(base, cwd=EXPLORER)
    R["explorer_verify_http_digests"] = timed(base + ["--digests"], cwd=EXPLORER)
    out_e = sh(base + ["--digests"], cwd=EXPLORER).stdout
    out_o = sh([str(OSHEAF), "--root", str(PAPERS), "verify"]).stdout
    (HERE / "explorer_findings.txt").write_text(out_e)
    (HERE / "osheaf_findings.txt").write_text(out_o)
    se = set(l for l in out_e.splitlines() if l and l != "OK")
    so = set(l for l in out_o.splitlines() if l and not l.startswith("OK,"))
    R["findings_only_osheaf"] = sorted(so - se)
    R["findings_only_explorer"] = sorted(se - so)
    R["findings_common"] = len(se & so)
    sh([str(PY), str(HERE / "statuses_osheaf.py"), str(PAPERS), str(HERE / "statuses_osheaf.json")])
    sh(["node", str(HERE / "statuses_explorer.mjs"), str(EXPLORER), URL, str(HERE / "statuses_explorer.json")])
    a = json.loads((HERE / "statuses_osheaf.json").read_text())
    b = json.loads((HERE / "statuses_explorer.json").read_text())
    R["per_version_statuses"] = {"lines": len(a), "versions": sum(map(len, a.values())),
                                 "identical": a == b,
                                 "differences": {k: [a.get(k), b.get(k)] for k in set(a) | set(b) if a.get(k) != b.get(k)}}
    # osheaf resolve: one line at a time (verifies a line and its latest signed version), each a new process
    ids = [o["id"] for o in json.loads((PAPERS / "opensheaf.json").read_text())["objects"] if o["kind"] != "owner"]
    for where, at in (("resolve_each_line_local_folder", str(PAPERS)), ("resolve_each_line_local_http", URL)):
        t = time.perf_counter(); bad = 0
        for i in ids:
            p = subprocess.run([str(OSHEAF), "resolve", i, "--at", at], capture_output=True, text=True, cwd=HERE)
            bad += p.returncode != 0 or "verified:" not in p.stdout
        dt = time.perf_counter() - t
        R[where] = {"lines": len(ids), "total_s": round(dt, 2), "per_line_ms": round(1000 * dt / len(ids), 1), "failures": bad}
finally:
    srv.terminate()

if "--public" in sys.argv:
    t = time.perf_counter()
    p = sh(["node", "tests/verify-url.mjs", "https://mgubi.org/papers/", "--no-remote", "--all"], cwd=EXPLORER)
    R["explorer_verify_public_nodigests_NETWORK_BOUND"] = {
        "wall_s": round(time.perf_counter() - t, 2), "returncode": p.returncode,
        "stdout_tail": p.stdout.strip().splitlines()[-1:], "stderr_tail": p.stderr.strip().splitlines()[-1:]}
    (HERE / "explorer_public_findings.txt").write_text(p.stdout)

(HERE / "results.json").write_text(json.dumps(R, indent=1))
print(json.dumps({k: v for k, v in R.items() if k != "size"}, indent=1))
