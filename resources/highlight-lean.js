/* Lean 4 for the site's highlight.js (10.3.2, resources/highlight.pack.js),
   which has no Lean of its own: code blocks marked ```lean in the Markdown
   sources (FORMAL-MODEL.md). Lean code is the one place of the site shown in
   colour (opensheaf.css, section 9): keywords and logical symbols, the names
   being declared, type names, literals and comments. */
(function () {
  'use strict';
  if (typeof hljs === 'undefined') { return; }
  hljs.registerLanguage('lean', function (hljs) {
    return {
      name: 'Lean',
      keywords: {
        $pattern: /[A-Za-z_][\w'.]*/,
        keyword: 'theorem lemma def abbrev structure inductive instance class ' +
          'where deriving namespace end section variable open import omit in ' +
          'fun match with if then else let have show from by at do return ' +
          'mutual private protected noncomputable example calc universe',
        built_in: 'Type Prop Sort',
        literal: 'true false'
      },
      contains: [
        // the name a declaration introduces
        { className: 'title',
          begin: /(?<=\b(?:theorem|lemma|def|abbrev|structure|inductive|class|instance)\s+)[A-Za-z_][\w'.]*/ },
        // logical and other symbols written as Unicode
        { className: 'keyword', begin: /[\u2200\u2203\u03bb\u2192\u2194\u2227\u2228\u00ac]/ },
        // type and constructor names written with a capital
        { className: 'type', begin: /\b[A-Z][\w']*/ },
        hljs.COMMENT('--', '$'),
        hljs.COMMENT('/-', '-/', { contains: ['self'] }),
        hljs.QUOTE_STRING_MODE,
        hljs.C_NUMBER_MODE
      ]
    };
  });
}());
