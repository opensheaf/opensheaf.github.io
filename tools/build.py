#!/usr/bin/env python3
"""Build the OpenSheaf pages from their Markdown sources.

README.md becomes the home page (index.tm, index.html), the specification
opensheaf-specification-0.2.md (the current draft) its own page, FAQ.md the
page faq.html, USE-CASES.md the page use-cases.html, FORMAL-MODEL.md the
page formal-model.html (the formal model in Lean), TOOLS.md the page
tools.html (the osheaf command), and the companions
opensheaf-git-0.2.md (archives in git) and opensheaf-timestamps-0.2.md (the
timestamps extension) their own pages. Version 0.1, kept as published
(opensheaf-specification-0.1.md and opensheaf-git-0.1.md), is built too.
tools/md2tm.py converts each Markdown file to TeXmacs, with links between the
Markdown files turned into links between the pages, and TeXmacs exports each
document to HTML; the head of each page then gets what the export leaves
out (language, viewport, title, description). The .tm and .html files are
generated: edit the Markdown files only.

Runs TeXmacs headless with a private profile in texmacs_home/ (not
committed), whose plugins are those linked in ~/.TeXmacs/plugins: the
`notes` and `max-html` plugins of the author's website repository.

    tools/build.py            Markdown -> TeXmacs -> HTML, for every page
    tools/build.py --pdf F    also write a PDF of the specification (0.2) to F
"""

import argparse
import html
import os
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TM_HOME = ROOT / "texmacs_home"
USER_PLUGINS = Path(os.environ.get("TEXMACS_PLUGINS", Path.home() / ".TeXmacs/plugins"))
TM = os.environ.get("TEXMACS_BIN", "/Applications/TeXmacs.app/Contents/MacOS/TeXmacs")
# Markdown sources and the TeXmacs documents generated from them; TeXmacs
# exports each document to HTML next to it.
PAGES = {
    "README.md": "index.tm",                                        # home page
    "opensheaf-specification-0.2.md": "opensheaf-specification-0.2.tm",
    "FAQ.md": "faq.tm",
    "USE-CASES.md": "use-cases.tm",
    "FORMAL-MODEL.md": "formal-model.tm",
    "TOOLS.md": "tools.tm",
    "opensheaf-git-0.2.md": "opensheaf-git-0.2.tm",
    "opensheaf-timestamps-0.2.md": "opensheaf-timestamps-0.2.tm",
    # version 0.1, kept as published
    "opensheaf-specification-0.1.md": "opensheaf-specification-0.1.tm",
    "opensheaf-git-0.1.md": "opensheaf-git-0.1.tm",
}
SPEC = "opensheaf-specification-0.2.md"  # the current draft, for --pdf


def run_texmacs(calls):
    TM_HOME.mkdir(exist_ok=True)
    if not (TM_HOME / "plugins").exists():
        (TM_HOME / "plugins").symlink_to(USER_PLUGINS)
    for p in ("notes", "max-html"):
        if not (TM_HOME / "plugins" / p).exists():
            sys.exit(f"TeXmacs plugin {p} not found in {USER_PLUGINS}")
    env = dict(os.environ, LC_ALL="C.UTF-8", QT_QPA_PLATFORM="offscreen",
               TEXMACS_HOME_PATH=str(TM_HOME))
    if not (TM_HOME / "system" / "settings.scm").exists():
        # the first start sets the profile up and would discard preferences
        subprocess.run([TM, "-headless", "-x", "(quit-TeXmacs)"], env=env,
                       capture_output=True, timeout=600)
    (TM_HOME / "system" / "preferences.scm").write_text(
        '("texmacs->html:images" "off")\n'
        '("texmacs->html:mathjax" "on")\n'
        '("texmacs->html:mathml" "off")\n')
    # style-clear-cache: TeXmacs caches style environments in the profile,
    # so changes to the style packages would otherwise be ignored.
    cmd = (f"(begin (catch #t (lambda () (style-clear-cache) {calls}) (lambda args (display \"SCHEME-ERROR \")"
           f" (write args) (newline))) (quit-TeXmacs))")
    out = subprocess.run([TM, "-headless", "-x", cmd], env=env, capture_output=True,
                         text=True, errors="replace", timeout=1200)
    if "SCHEME-ERROR" in out.stdout + out.stderr:
        sys.exit(out.stdout + out.stderr)


def plain(md):
    """Markdown inline text as plain text: links by their text, no emphasis
    or code marks."""
    t = re.sub(r'\[([^\]]+)\]\([^)]*\)', r'\1', md)
    t = re.sub(r'</?dfn>', '', t)
    return re.sub(r'\s+', ' ', t.replace('`', '').replace('**', '').replace('*', '')).strip()


def head_of(md_file):
    """The title and description of a page, from its source: the first
    heading (the home page is "OpenSheaf"), with the version of a versioned
    document; and its abstract, the first paragraph in italics, cut at a
    word near 200 characters."""
    lines = (ROOT / md_file).read_text().split("\n")
    heading = next((l[2:] for l in lines if l.startswith("# ")), None)
    title = plain(heading) if heading else "OpenSheaf"
    version = re.search(r"-(\d+\.\d+)\.md$", md_file)
    if version:
        title += f", version {version.group(1)}"
    if not title.startswith("OpenSheaf"):
        title += " \u00b7 OpenSheaf"
    start = next((i for i, l in enumerate(lines) if l.startswith("*") and not l.startswith("**")), None)
    abstract = ""
    if start is not None:
        end = next((i for i in range(start, len(lines)) if not lines[i].strip()), len(lines))
        abstract = plain(" ".join(lines[start:end]))
        if len(abstract) > 200:
            abstract = abstract[:200].rsplit(" ", 1)[0].rstrip(",;:") + "..."
    return title, abstract


def finish(md_file, html_file):
    """What the HTML export of TeXmacs leaves out of the head of a page: the
    language, the viewport (without it phones lay the page out at desktop
    width), the page's own title and its description."""
    title, description = head_of(md_file)
    page = html_file.read_text(encoding="utf-8")
    page = page.replace('<html xmlns="http://www.w3.org/1999/xhtml"',
                        '<html lang="en" xml:lang="en" xmlns="http://www.w3.org/1999/xhtml"', 1)
    page = re.sub(r"<title>.*?</title>", lambda m: f"<title>{html.escape(title)}</title>"
                  '\n    <meta name="viewport" content="width=device-width, initial-scale=1"></meta>'
                  + (f'\n    <meta name="description" content="{html.escape(description)}"></meta>'
                     if description else ""), page, count=1, flags=re.S)
    html_file.write_text(page, encoding="utf-8")


def main():
    p = argparse.ArgumentParser(description=__doc__,
                                formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("--pdf")
    args = p.parse_args()
    maps = []
    for md, tm in PAGES.items():
        maps += ["--map", f"{md}={tm}"]
    for md, tm in PAGES.items():
        subprocess.run([sys.executable, str(ROOT / "tools" / "md2tm.py"), *maps,
                        str(ROOT / md), str(ROOT / tm)], check=True)
    scratch = Path(tempfile.mkdtemp())
    calls = []
    for name in PAGES.values():
        doc = ROOT / name
        pdf = (Path(args.pdf).resolve() if args.pdf and name == PAGES[SPEC]
               else scratch / (doc.stem + ".pdf"))
        # a PDF export typesets the document first (references, links)
        calls.append(f'(let ((u (string->url "{doc}"))) (load-buffer u) (switch-to-buffer u)'
                     f' (export-buffer-main u (string->url "{pdf}") "pdf" (list :overwrite))'
                     f' (export-buffer-main u (string->url "{doc.with_suffix(".html")}")'
                     f' "html" (list :overwrite)))')
    run_texmacs(" ".join(calls))
    shutil.rmtree(scratch, ignore_errors=True)
    for md, tm in PAGES.items():
        finish(md, (ROOT / tm).with_suffix(".html"))
    print("exported: " + ", ".join(t.replace(".tm", ".html") for t in PAGES.values()))


if __name__ == "__main__":
    main()
