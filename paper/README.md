# The OpenSheaf paper

A technical paper introducing OpenSheaf: its principles, the format as of
version 0.2 of the specification, the reference implementation, and how it
relates to the systems surveyed in the working papers
([`../drafts/`](../drafts/)). Non-normative: where it and the
[specification](../opensheaf-specification-0.2.md) differ, the
specification holds.

- `opensheaf.md`: the source, in a restricted Markdown (see `build.py`);
  edit this file only.
- `build.py`: converts it to a two-column TeXmacs document, `opensheaf.tm`,
  reusing the inline rules of the site's converter (`../tools/md2tm.py`).
- `opensheaf-paper.ts`: the style package: Linux Libertine for the text,
  Linux Biolinum for the headings, Fira Mono for code, code listings
  (`os-code`) on a tinted ground; the table colours (`TABLE_HEAD`,
  `TABLE_STRIPE`) are set in `build.py`.
- `typeset.sh`, `typeset.scm`: build `opensheaf.tm` and typeset it twice
  with TeXmacs, headless, into `opensheaf.pdf`.

Build with `paper/typeset.sh` (TeXmacs 2.1.5; set `TEXMACS` to the path of
its binary if it is not in `/Applications`). Commit the regenerated
`opensheaf.tm` and `opensheaf.pdf` with the source. Keep the source in
ASCII, and lines in code blocks to 46 characters, the width of a column.
