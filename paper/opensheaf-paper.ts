<TeXmacs|2.1.5>

<style|source>

<\body>
  <active*|<\src-title>
    <src-package|opensheaf-paper|1.0>

    <\src-purpose>
      The look of the OpenSheaf paper: Linux Libertine for the text, Linux
      Biolinum for the headings, Fira Mono for code, code listings on a
      tinted ground. Table colours are set by build.py (cell-background).
    </src-purpose>
  </src-title>>

  <\active*>
    <\src-comment>
      Fonts.
    </src-comment>
  </active*>

  <assign|font|Linux Libertine>

  <assign|os-sans-font|Linux Biolinum>

  <assign|os-mono-font|Fira Mono>

  <assign|os-old-section-title|<value|section-title>>

  <assign|section-title|<macro|name|<with|font|<value|os-sans-font>|<os-old-section-title|<arg|name>>>>>

  <assign|os-old-subsection-title|<value|subsection-title>>

  <assign|subsection-title|<macro|name|<with|font|<value|os-sans-font>|<os-old-subsection-title|<arg|name>>>>>

  <assign|os-old-paragraph-title|<value|paragraph-title>>

  <assign|paragraph-title|<macro|name|<with|font|<value|os-sans-font>|<os-old-paragraph-title|<arg|name>>>>>

  <assign|os-old-doc-title|<value|doc-title>>

  <assign|doc-title|<macro|x|<with|font|<value|os-sans-font>|<os-old-doc-title|<arg|x>>>>>

  <\active*>
    <\src-comment>
      Code: inline spans and blocks in Fira Mono, slightly smaller than the
      text; blocks (os-code) on a tinted ground with a thin rule.
    </src-comment>
  </active*>

  <assign|os-code-ground|#f2f4f7>

  <assign|os-code-rule|#c9d1dc>

  <assign|os-old-verbatim|<value|verbatim>>

  <assign|verbatim|<macro|body|<with|font|<value|os-mono-font>|font-size|<times|<value|font-size>|0.88>|<os-old-verbatim|<arg|body>>>>>

  <assign|os-code|<\macro|body>
    <\with|font|<value|os-mono-font>|font-size|0.92|par-first|0fn|ornament-shape|classic|ornament-color|<value|os-code-ground>|ornament-sunny-color|<value|os-code-rule>|ornament-shadow-color|<value|os-code-rule>|ornament-border|0.5ln|ornament-hpadding|0.6em|ornament-vpadding|0.5em>
      <\ornament>
        <\verbatim-code>
          <arg|body>
        </verbatim-code>
      </ornament>
    </with>
  </macro>>
</body>

<\initial>
  <\collection>
    <associate|preamble|true>
  </collection>
</initial>
