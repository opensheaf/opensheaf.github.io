/* Lean 4 for the site's highlight.js (10.3.2, resources/highlight.pack.js),
   which has no Lean of its own: code blocks marked ```lean in the Markdown
   sources (FORMAL-MODEL.md). As everywhere on the site, highlighting only
   sets keywords a little stronger and comments in grey (opensheaf.css). */
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
        hljs.COMMENT('--', '$'),
        hljs.COMMENT('/-', '-/', { contains: ['self'] }),
        hljs.QUOTE_STRING_MODE,
        hljs.C_NUMBER_MODE
      ]
    };
  });
}());
