#!/usr/bin/env python3
"""Convert the paper from its restricted Markdown to a two-column TeXmacs
document.

    paper/build.py paper/opensheaf.md paper/opensheaf.tm

The Markdown is that of the site's converter (tools/md2tm.py), whose inline
rules are reused, with what a paper needs besides:

- front matter: `# Title`, then `author:`, `affiliation:`, `email:`,
  `date:` lines, the abstract as one paragraph in *italics*, and optionally
  `keywords: a, b, c`;
- numbered sections (`## Title {#sec:x}`), subsections (`###`) and run-in
  paragraph headings (`####`);
- tables with a caption, `Table: caption {#tab:x}` before a GitHub table
  (`Table*:` for one set across the page);
- listings with a caption, `Listing: caption {#lst:x}` before a fenced block;
- cross-references `@sec:x`, `@tab:x`, `@lst:x` (the number only), and
  citations `[@key]` or `[@a; @b]`;
- a references section, `## References`, one `- [key] text` per entry,
  numbered in order.

The title block and the abstract are set across the page, the body in two
columns. The file is written in Latin-1; the source is kept in ASCII.
"""

import os
import re
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'tools'))
from md2tm import inline as md_inline, esc, code_line  # noqa: E402

LABEL_RE = re.compile(r'\s*\{#([A-Za-z0-9:_-]+)\}\s*$')
CITE_RE = re.compile(r'\[(@[A-Za-z0-9-]+(?:\s*;\s*@[A-Za-z0-9-]+)*)\]')
REF_RE = re.compile(r'@((?:sec|tab|lst):[A-Za-z0-9_-]+)')


def inline(t):
    """Inline markup, with citations and cross-references set aside first,
    since the site's rules know nothing of them."""
    held = []

    def hold(markup):
        held.append(markup)
        return f'\x01{len(held) - 1}\x01'

    def cite(m):
        keys = [k.strip()[1:] for k in m.group(1).split(';')]
        return hold('<cite|' + '|'.join(keys) + '>')

    t = CITE_RE.sub(cite, t)
    t = REF_RE.sub(lambda m: hold(f'<reference|{m.group(1)}>'), t)
    out = with_breaks(md_inline(t))
    return re.sub('\x01(\\d+)\x01', lambda m: held[int(m.group(1))], out)


TOKEN_RE = re.compile(r'(\\<[^>]*\\>|<[^>|]*>|\\.)')


def breakable(t, every=14):
    """Allow line breaks in a long code span or URL, which a column cannot
    hold: after `/ : . ? & = -` and `,`, and every few characters of a run
    without them. Markup and escapes inside are kept whole."""
    out, run = [], 0
    for tok in TOKEN_RE.split(t):
        if not tok:
            continue
        if TOKEN_RE.fullmatch(tok):
            out.append(tok)
            run += 1
            continue
        for k, c in enumerate(tok):
            out.append(c)
            run += 1
            nxt = tok[k + 1:k + 2]
            if c in ':/' and nxt == '/':
                continue  # keep "https://" whole
            if c in '/:.?&=-,_' or run >= every:
                out.append('<line-break>')
                run = 0
    return ''.join(out)


def with_breaks(markup):
    markup = re.sub(r'<verbatim\|((?:[^<>]|<[^<>]*>)*)>',
                    lambda m: '<verbatim|' + (breakable(m.group(1))
                                              if len(m.group(1)) > (16 if re.search(r'[:/]', m.group(1)) else 30)
                                              else m.group(1)) + '>',
                    markup)
    return re.sub(r'(?<![|\w])(https?://[^\s<>|]+)', lambda m: breakable(m.group(1)), markup)


def heading(text):
    m = LABEL_RE.search(text)
    label = f'<label|{m.group(1)}>' if m else ''
    return inline(LABEL_RE.sub('', text).strip()), label


def table(rows):
    body = '|'.join('<row|' + '|'.join(f'<cell|<with|par-mode|left|{inline(c)}>>' for c in r) + '>'
                    for r in rows)
    n = len(rows[0])
    return ('<tformat|<twith|table-width|1par>|<twith|table-hmode|exact>|'
            '<cwith|1|-1|1|-1|cell-hyphen|t>|'
            '<cwith|1|-1|1|-1|cell-valign|top>|'
            '<cwith|1|-1|1|-1|cell-halign|l>|'
            '<cwith|1|-1|1|-1|cell-lsep|0.3em>|<cwith|1|-1|1|-1|cell-rsep|0.3em>|'
            '<cwith|1|1|1|-1|font-series|bold>|'
            '<cwith|1|1|1|-1|cell-tborder|1ln>|<cwith|1|1|1|-1|cell-bborder|0.5ln>|'
            '<cwith|-1|-1|1|-1|cell-bborder|1ln>|'
            + '|'.join(f'<cwith|1|-1|{k}|{k}|cell-hpart|1>' for k in range(1, n + 1))
            + f'|<table|{body}>>')


def convert(md):
    lines = md.split('\n')
    if not lines[0].startswith('# '):
        sys.exit('the paper must start with "# Title"')
    title = inline(lines[0][2:].strip())
    meta = {}
    i = 1
    while i < len(lines) and (not lines[i].strip() or re.match(r'^[a-z]+:', lines[i])):
        m = re.match(r'^([a-z]+):\s*(.*)$', lines[i])
        if m:
            meta[m.group(1)] = m.group(2).strip()
        i += 1
    abstract = []
    if i < len(lines) and lines[i].startswith('*'):
        while i < len(lines) and lines[i].strip():
            abstract.append(lines[i].strip())
            i += 1
    abstract = ' '.join(abstract)
    if abstract.startswith('*') and abstract.endswith('*'):
        abstract = abstract[1:-1]
    while i < len(lines) and (not lines[i].strip() or lines[i].startswith('keywords:')):
        if lines[i].startswith('keywords:'):
            meta['keywords'] = lines[i].split(':', 1)[1].strip()
        i += 1

    blocks = []        # (full_width, markup)
    caption = None     # (kind, star, text, label) waiting for its table or listing
    refs = []          # (key, text)
    in_refs = False
    while i < len(lines):
        l = lines[i]
        if not l.strip():
            i += 1
            continue
        if in_refs:
            m = re.match(r'^- \[([A-Za-z0-9-]+)\]\s*(.*)$', l)
            if m:
                text = [m.group(2)]
                i += 1
                while i < len(lines) and lines[i].startswith('  '):
                    text.append(lines[i].strip())
                    i += 1
                refs.append((m.group(1), ' '.join(text)))
                continue
            sys.exit(f'unexpected line in the references: {l!r}')
        m = re.match(r'^(Table\*?|Listing):\s*(.*)$', l)
        if m:
            text, label = heading(m.group(2))
            caption = (m.group(1).rstrip('*').lower(), m.group(1).endswith('*'), text, label)
            i += 1
            continue
        if l.startswith('```'):
            j = i + 1
            code = []
            while j < len(lines) and not lines[j].startswith('```'):
                code.append(lines[j])
                j += 1
            body = '\n\n'.join(code_line(c) for c in code)
            block = ('<\\with|font-size|0.84|par-first|0fn>\n  <\\verbatim-code>\n' + body
                     + '\n  </verbatim-code>\n</with>')
            if caption and caption[0] == 'listing':
                block = (f'<\\big-listing>\n{block}\n<|big-listing>\n'
                         f'  {caption[2]}{caption[3]}\n</big-listing>')
                caption = None
            blocks.append((False, block))
            i = j + 1
            continue
        if l.startswith('|') and i + 1 < len(lines) and re.match(r'^\|[\s:|-]+\|\s*$', lines[i + 1]):
            def cells(row):
                return [c.strip() for c in row.strip().strip('|').split('|')]
            rows = [cells(l)]
            i += 2
            while i < len(lines) and lines[i].startswith('|'):
                rows.append(cells(lines[i]))
                i += 1
            markup = table(rows)
            wide = False
            if caption and caption[0] == 'table':
                wide = caption[1]
                size = '0.84'
                markup = (f'<big-table|<with|font-size|{size}|{markup}>|'
                          f'{caption[2]}{caption[3]}>')
                caption = None
            blocks.append((wide, markup))
            continue
        if l.startswith('## '):
            text, label = heading(l[3:])
            if LABEL_RE.sub('', l[3:]).strip() == 'References':
                in_refs = True
                i += 1
                continue
            blocks.append((False, f'<section|{text}>{label}'))
            i += 1
            continue
        if l.startswith('### '):
            text, label = heading(l[4:])
            blocks.append((False, f'<subsection|{text}>{label}'))
            i += 1
            continue
        if l.startswith('#### '):
            text, label = heading(l[5:])
            para = []
            i += 1
            while i < len(lines) and lines[i].strip() and not re.match(r'(#{1,4} |- |\d+\. |```|\|)', lines[i]):
                para.append(lines[i].strip())
                i += 1
            blocks.append((False, f'<paragraph|{text}>{label}{inline(" ".join(para))}'))
            continue
        if l.startswith('- ') or re.match(r'\d+\. ', l):
            numbered = not l.startswith('- ')
            marker = r'\d+\. ' if numbered else r'- '
            items = []
            while i < len(lines) and (re.match(marker, lines[i]) or lines[i].startswith('  ')):
                ln = lines[i]
                m = re.match(marker, ln)
                if m:
                    items.append([ln[m.end():], [], ''])
                elif ln.startswith('  - '):
                    items[-1][1].append(ln[4:])
                elif items[-1][1] and ln.startswith('    '):
                    items[-1][1][-1] += ' ' + ln.strip()
                elif items[-1][1]:
                    items[-1][2] += ' ' + ln.strip()
                else:
                    items[-1][0] += ' ' + ln.strip()
                i += 1

            def render(text, subs, after):
                out = '  <item>' + inline(text)
                if subs:
                    out += ('\n\n  <\\itemize>\n'
                            + '\n\n'.join('    <item>' + inline(x) for x in subs)
                            + '\n  </itemize>')
                if after.strip():
                    out += '\n\n  ' + inline(after.strip())
                return out

            env = 'enumerate' if numbered else 'itemize'
            blocks.append((False, f'<\\{env}>\n' + '\n\n'.join(render(*it) for it in items)
                           + f'\n</{env}>'))
            continue
        para = []
        while (i < len(lines) and lines[i].strip()
               and not re.match(r'(#{1,4} |- |\d+\. |```|\||Table\*?:|Listing:)', lines[i])):
            para.append(lines[i].strip())
            i += 1
        blocks.append((False, inline(' '.join(para))))

    if refs:
        longest = str(len(refs))
        items = '\n\n'.join(f'  <bibitem*|{n}><label|bib-{k}>{inline(t)}'
                            for n, (k, t) in enumerate(refs, 1))
        blocks.append((False, '<section*|References>'))
        blocks.append((False, f'<\\bib-list|{longest}>\n{items}\n</bib-list>'))

    # the body in two columns, broken where a table is set across the page
    out = []
    run = []

    def flush():
        if run:
            inner = '\n\n'.join('  ' + b.replace('\n', '\n  ') for b in run)
            out.append(f'<\\with|par-columns|2>\n{inner}\n</with>')
            run.clear()

    for wide, b in blocks:
        if wide:
            flush()
            out.append(b)
        else:
            run.append(b)
    flush()

    author = f'<author-name|{inline(meta.get("author", ""))}>'
    if meta.get('affiliation'):
        author += f'|<author-affiliation|{inline(meta["affiliation"])}>'
    if meta.get('email'):
        author += f'|<author-email|{esc(meta["email"])}>'
    data = f'<doc-data|<doc-title|{title}>|<doc-author|<author-data|{author}>>'
    if meta.get('date'):
        data += f'|<doc-date|{inline(meta["date"])}>'
    data += '>'
    front = [data]
    if abstract:
        kw = ''
        if meta.get('keywords'):
            kw = '|<abstract-keywords|' + '|'.join(
                inline(k.strip()) for k in meta['keywords'].split(',')) + '>'
        front.append(f'<abstract-data|<\\abstract>\n  {inline(abstract)}\n</abstract>{kw}>')

    body = '\n\n'.join(front + out)
    body = '\n'.join('  ' + ln if ln else '' for ln in body.split('\n'))
    preamble = ('<\\hide-preamble>\n'
                '  <new-figure|listing|Listing>\n'
                '</hide-preamble>\n\n')
    return ('<TeXmacs|2.1.5>\n\n<style|<tuple|article|british>>\n\n<\\body>\n'
            + '  ' + preamble.replace('\n', '\n  ').rstrip() + '\n\n'
            + body + '\n</body>\n\n<\\initial>\n  <\\collection>\n'
            '    <associate|font-base-size|10>\n'
            '    <associate|page-medium|paper>\n'
            '    <associate|page-type|a4>\n'
            '    <associate|par-columns-sep|1.5fn>\n'
            '    <associate|page-odd|1.8cm>\n'
            '    <associate|page-even|1.8cm>\n'
            '    <associate|page-right|1.8cm>\n'
            '    <associate|page-top|2cm>\n'
            '    <associate|page-bot|2cm>\n'
            '  </collection>\n</initial>\n')


def main():
    src, dst = sys.argv[1:3]
    with open(src, encoding='utf-8') as f:
        md = f.read()
    tm = convert(md)
    with open(dst, 'w', encoding='latin-1', newline='') as f:
        f.write(tm)


if __name__ == '__main__':
    main()
