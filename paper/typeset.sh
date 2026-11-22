#!/bin/sh
# typeset.sh [base]: build the paper. Converts base.md (default opensheaf)
# to base.tm, then
# typesets it twice with TeXmacs, headless, in separate processes (the PDF
# export is what typesets; the second run resolves references), and saves
# the references into the .tm.
#
# Needs TeXmacs 2.1.5 (TEXMACS: path of its binary).
set -e
cd "$(dirname "$0")"
W=$PWD
X=${TEXMACS:-/Applications/TeXmacs.app/Contents/MacOS/TeXmacs}
B=${1:-opensheaf}
python3 build.py "$B.md" "$B.tm"
for k in 1 2; do
  "$X" -headless -x "(begin (load \"$W/typeset.scm\") (catch #t (lambda () (paper-typeset \"$W/$B.tm\" \"$W/$B.pdf\")) (lambda args (display \"SCHEME-ERROR \") (write args) (newline))) (quit-TeXmacs))" > "$W/typeset.log" 2>&1 &
  P=$!; i=0
  while kill -0 $P 2>/dev/null; do
    sleep 1; i=$((i+1))
    if [ $i -gt 300 ]; then kill $P; echo TIMEOUT; exit 1; fi
  done
  if grep -a SCHEME-ERROR "$W/typeset.log"; then exit 1; fi
done
ls -l "$B.pdf"
