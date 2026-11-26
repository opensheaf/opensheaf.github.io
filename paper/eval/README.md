# Measurements of the first archive

The numbers of the paper's section "Evaluation and limitations"
(Measurements), taken on 26 November 2026 from mgubi/papers at commit
1ac6db6, with opensheaf-py at 97ff867 (Python 3.13.7, ocfl-py 2.1.0) and the
Explorer at 1f2b9ed (Node 26.10.0), on an Apple M4 (10 cores, 24 GiB,
macOS 15.7.1).

- `run_eval.py`: sizes, verification times (median of 5 runs after one
  warm-up), the Explorer's verification and the comparison of statuses;
  `--public` adds one Explorer run against https://mgubi.org/papers/.
  It expects a clone of the archive in `papers/`, a copy of the Explorer in
  `explorer/` and a virtual environment with opensheaf-py (`VENV`).
- `measure_size.py`: the sizes alone; `statuses_osheaf.py`,
  `statuses_explorer.mjs`: the status of every version, by each tool.
- `run_deposit.py`: deposits on a throw-away copy of a test archive with
  test keys, without network.
- `results.json`, `size.json`, `deposit_times.json`,
  `statuses_osheaf.json`, `statuses_explorer.json`: the numbers measured.

Sizes are apparent bytes; OCFL stores each file once across versions.
