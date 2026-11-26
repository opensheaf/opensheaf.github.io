#!/usr/bin/env python3
"""Local deposit timing on throw-away copies of the test archive, with throw-away test keys.
No network: no Zenodo, no git push (the copy has no git remote).
Expects deposit/repo0 (copy of ~/.opensheaf-test/repo, remote removed), deposit/home (copy of
~/.opensheaf-test/home), deposit/input (1004.1407.tex and paper.pdf from the papers archive)."""
import json, os, shutil, statistics, subprocess, time
from pathlib import Path
E = Path(__file__).resolve().parent; D = E / "deposit"; O = str(E.parent / "venv" / "bin" / "osheaf")
OWNER = "3utmn6a66pihnegrlff6cqjfhkvua3ynuqzrvswz3yrbcww4hibq"
env = dict(os.environ, XDG_CONFIG_HOME=str(D / "home"), OPENSHEAF_KEY_STORE="file")
common = ["--pdf", str(D / "input/paper.pdf"), "--title", "Evaluation test", "--author", "Test, Manager|",
          "--rights", "CC-BY-4.0"]
steps = [("deposit_new", ["deposit", "eval-test", str(D / "input/1004.1407.tex"), "--new", "--message", "evaluation"] + common),
         ("collect", ["collect", "--owner", OWNER]),
         ("verify", ["verify"]),
         ("deposit_v2", ["deposit", "eval-test", str(D / "input/1004.1407.tex"), "--changes", "same text", "--message", "evaluation 2"] + common),
         ("collect_2", ["collect", "--owner", OWNER]),
         ("verify_2", ["verify"])]
rows = []
for i in range(6):
    try_ = D / "try"; shutil.rmtree(try_, ignore_errors=True); shutil.copytree(D / "repo0", try_, symlinks=True)
    row = {}
    for name, args in steps:
        t = time.perf_counter()
        p = subprocess.run([O, "--root", str(try_)] + args, env=env, cwd=try_, capture_output=True, text=True, stdin=subprocess.DEVNULL)
        row[name] = round(time.perf_counter() - t, 3)
        row[name + "_rc"] = p.returncode
        if p.returncode:
            row[name + "_err"] = (p.stdout + p.stderr)[-400:]
    rows.append(row)
    print(row)
timed = rows[1:]   # first run is a warm-up
summary = {k: statistics.median(r[k] for r in timed) for k in rows[0] if not k.endswith(("_rc", "_err"))}
(E / "deposit_times.json").write_text(json.dumps({"runs": rows, "median_of_runs_2_to_6": summary}, indent=1))
print(summary)
