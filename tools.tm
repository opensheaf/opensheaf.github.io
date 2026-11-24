<TeXmacs|2.1.5>

<style|<tuple|notes|notes-meta>>

<\body>
  <notes-header>

  <chapter*|The command-line tools>

  <notes-abstract|<verbatim|osheaf> is the command that keeps an OpenSheaf archive on your computer: it deposits your papers and their new versions, signs them, keeps collections of papers from any archive, writes the website, verifies the whole, imports papers from arXiv and gets DOIs from Zenodo. This page shows how to use it, task by task. It is part of <hlink|opensheaf-py|https://github.com/opensheaf/opensheaf-py>, the reference implementation of the <hlink|specification|opensheaf-specification-0.2.tm>.>

  <os-alert|warning|Warning.|<strong|Under development.> The tools follow version 0.2 of the specification, a draft, and change with it. Archives made now may have to be rebuilt when the format changes. Do not rely on them yet for anything you cannot redo.>

  <section*|Running it><label|running-it>

  The tools need Python 3.9 or later. The simplest way to run them while they are developed is <hlink|uv|https://docs.astral.sh/uv/>, which fetches the latest version from GitHub and runs it without installing anything:

  <\html-div-class|language-bash>
  <\verbatim-code>
    uvx -<no-break>-python 3.13 -<no-break>-from "opensheaf[validate,keys] @ git+https://github.com/opensheaf/opensheaf-py" osheaf -<no-break>-help
  </verbatim-code>
  </html-div-class>

  Give it a short name once, in your shell's configuration (<verbatim|~/.zshrc> on a Mac):

  <\html-div-class|language-bash>
  <\verbatim-code>
    alias osheaf='uvx -<no-break>-python 3.13 -<no-break>-from "opensheaf[validate,keys] @ git+https://github.com/opensheaf/opensheaf-py" osheaf'
  </verbatim-code>
  </html-div-class>

  uv keeps what it fetched; to move to the latest version of the tools, run the same line once with <verbatim|-<no-break>-refresh> after <verbatim|uvx>. Naming the Python (<verbatim|-<no-break>-python 3.13>) matters on a Mac: see the keychain, below.

  To install the command instead, with uv or with pipx:

  <\html-div-class|language-bash>
  <\verbatim-code>
    uv tool install "opensheaf[validate,keys] @ git+https://github.com/opensheaf/opensheaf-py"

    pipx install "opensheaf[validate,keys] @ git+https://github.com/opensheaf/opensheaf-py"
  </verbatim-code>
  </html-div-class>

  The extras add what is optional: <verbatim|validate> lets <verbatim|osheaf verify> also check the files against the JSON Schemas and the storage root with an independent OCFL validator; <verbatim|keys> keeps your keys in the system's credential store. Nothing else is needed, unless you deposit TeXmacs documents, which the archive typesets itself: then <hlink|GNU TeXmacs|https://www.texmacs.org> (by default the macOS application, or wherever <verbatim|TEXMACS_BIN> says) and the TeXmacs plugins your archive names in its configuration.

  <strong|The keychain on a Mac.> When a Python other than the one that stored your key reads it, macOS asks: "python3.13 wants to use your confidential information stored in opensheaf-current-key". Answer <strong|Always Allow>, with your login password, and that Python is not asked again. A different Python is asked anew, which is why the line above names one. If you would rather keep no key on the computer at all, see <hlink|Where the keys are kept|#where-the-keys-are-kept>.

  <verbatim|osheaf -<no-break>-help> lists the commands, and <verbatim|osheaf COMMAND -<no-break>-help> (for instance <verbatim|osheaf collection add -<no-break>-help>) gives the options of each. <verbatim|osheaf help-config> describes the configuration file of an archive, <verbatim|osheaf.json>, and your own, <verbatim|~/.config/opensheaf/config.json>.

  <section*|Your first archive><label|your-first-archive>

  An archive is a folder. <verbatim|osheaf init> makes it, together with its <dfn|owner>: the keyed identity that signs every version of your papers (section 6 of the <hlink|specification|opensheaf-specification-0.2.tm#6-owners>).

  <\html-div-class|language-bash>
  <\verbatim-code>
    osheaf init my-papers -<no-break>-name "Papers of Jane Doe" -<no-break>-base-url https://janedoe.github.io/papers/ \\

    \ \ -<no-break>-curator "Doe, Jane" -<no-break>-affiliation "Example University" \\

    \ \ -<no-break>-new-owner -<no-break>-export /Volumes/USB/opensheaf-keys -<no-break>-print

    cd my-papers
  </verbatim-code>
  </html-div-class>

  <verbatim|-<no-break>-base-url> is the address where the archive will be served. Every later command is run inside the folder (or given it with <verbatim|-<no-break>-root>).

  <subsection*|Choosing where the keys live><label|choosing-where-the-keys-live>

  An owner has two kinds of keys. <strong|Current keys> sign your papers; each computer has its own. <strong|Rotation keys>, three by default, of which any two are needed, change the current keys: they add a new computer, retire an old one, or declare a stolen one. Whoever holds two rotation keys controls the owner, so where they live is the owner's <strong|security level>, chosen with <verbatim|-<no-break>-keys> when the owner is made:

  <\itemize>
    <item><verbatim|-<no-break>-keys offline> (the default, and the safest). The rotation keys are written once, encrypted under a passphrase you choose, to the folder of <verbatim|-<no-break>-export> (a USB stick), and, with <verbatim|-<no-break>-print>, printed on sheets. <verbatim|init> asks you to type back the check of each key once it is put away. They are never kept on the computer: store the stick and the sheets apart from it, and from each other.

    <item><verbatim|-<no-break>-keys github:OWNER/REPO>, a key wallet in a private GitHub repository of its own (create it by hand first, for instance with <verbatim|gh repo create me/opensheaf-keys -<no-break>-private>; the tools refuse a public one, or the archive's own). The rotation keys and the current keys are kept there, encrypted under the passphrase, and a new computer gets its key from the wallet. It needs the <hlink|GitHub CLI|https://cli.github.com>, signed in once with <verbatim|gh auth login>.

    <item><verbatim|-<no-break>-keys command>, a key wallet in your password manager (1Password's <verbatim|op>, Bitwarden's <verbatim|bw>, <verbatim|pass>): the same, through a <verbatim|read> and a <verbatim|write> command, given as a JSON object, <verbatim|{"wallet": "command", "read": READ, "write": WRITE}>, where READ prints a key and WRITE stores one (for 1Password, READ is <verbatim|op read 'op://Private/opensheaf-{owner}-{k}/notesPlain'>). Since these commands run on your computer, they are read only from your own configuration: the environment variable <verbatim|OPENSHEAF_WALLET>, or <verbatim|~/.config/opensheaf/config.json>; never from an archive's <verbatim|osheaf.json>, which anyone may have written, and which is refused if it names one. Chapter 9 of the <hlink|literate program|https://opensheaf.org/opensheaf-py/> gives the commands for the three managers.
  </itemize>

  A wallet trades security for convenience: whoever controls the wallet and knows the passphrase controls the owner, and the tools say so each time they put keys in one. Keep the passphrase elsewhere than the wallet. You can move up to <verbatim|offline> at any time with one rotation (see <hlink|Keys|#keys>).

  <\html-div-class|language-bash>
  <\verbatim-code>
    osheaf init my-papers -<no-break>-name "Papers of Jane Doe" -<no-break>-base-url https://janedoe.github.io/papers/ \\

    \ \ -<no-break>-curator "Doe, Jane" -<no-break>-new-owner -<no-break>-keys github:janedoe/opensheaf-keys
  </verbatim-code>
  </html-div-class>

  <verbatim|-<no-break>-keeper> names who answers for the owner, an ORCID iD or a domain of yours (<verbatim|-<no-break>-keeper https://orcid.org/0000-0002-1825-0097>, or <verbatim|-<no-break>-keeper https://example.org/>; section <hlink|6.6|opensheaf-specification-0.2.tm#66-keepers>). An owner can keep several archives: <verbatim|osheaf init> with <verbatim|-<no-break>-owner OWNER -<no-break>-key-log DIR> instead of <verbatim|-<no-break>-new-owner> starts an archive with an owner you already have, copying its key log from another archive.

  <subsection*|What appears in the folder><label|what-appears-in-the-folder>

  <\itemize>
    <item><verbatim|osheaf.json>: the settings of the archive (name, address, owner, curator, the GitHub wallet if any);

    <item><verbatim|.gitattributes>, unless the folder has one already: it tells git to keep every file of the archive byte for byte (section <hlink|4.1|opensheaf-git-0.2.tm#41-attributes> of <hlink|OpenSheaf archives in git|opensheaf-git-0.2.tm>);

    <item><verbatim|ocfl/>: the storage itself, one folder per work, with the key log of the owner at <verbatim|ocfl/\<less\>owner\<gtr\>/\<less\>owner\<gtr\>/>; - <verbatim|opensheaf.json>: the discovery document, which readers and tools start from, with the labels of your papers; beyond a thousand objects, the list of objects moves into pages under <verbatim|objects/>, so that a deposit rewrites one small file;

    <item><verbatim|names/>, <verbatim|owners/>, <verbatim|sha512/>: indexes for looking things up; - the website: <verbatim|index.html>, a page per paper at <verbatim|paper/\<less\>name\<gtr\>/> (the permanent address the descriptions record) and at <verbatim|paper/\<less\>label\<gtr\>/> (the readable one the pages link to), a page per owner at <verbatim|owner/\<less\>owner\<gtr\>/>, <verbatim|sitemap.xml>, and the templates they are made from in <verbatim|templates/>, which you can edit.
  </itemize>

  With <verbatim|-<no-break>-index texmacs>, the home page is instead a TeXmacs document made from a template (<verbatim|-<no-break>-index-template FILE>), with HTML versions of TeXmacs papers in <verbatim|site/>; the landing pages are the same. <verbatim|-<no-break>-curated> makes an owner catalogue that you choose by hand rather than one that lists every paper.

  <section*|Daily work><label|daily-work>

  <subsection*|Depositing a paper><label|depositing-a-paper>

  A new paper gets a <strong|label> of your choice, which names it in your archive and gives a readable address of its page, <verbatim|paper/\<less\>label\<gtr\>/>; the descriptions deposited record the permanent one, <verbatim|paper/\<less\>name\<gtr\>/>, built from its name. <verbatim|-<no-break>-new> makes the new work; the deposit prints its permanent name, a <verbatim|sheaf:> URI. A label may change later (<verbatim|osheaf label>, below); the permanent name does not.

  <\html-div-class|language-bash>
  <\verbatim-code>
    osheaf deposit kpz-uniqueness paper.tex -<no-break>-pdf paper.pdf -<no-break>-new \\

    \ \ -<no-break>-extra-source refs.bib -<no-break>-extra-source figures/fig1.pdf=figures/fig1.pdf \\

    \ \ -<no-break>-title "Energy solutions of KPZ are unique" \\

    \ \ -<no-break>-author "Doe, Jane\|Example University" -<no-break>-author "Roe, Richard\|Another University" \\

    \ \ -<no-break>-abstract-file abstract.txt -<no-break>-keyword "stochastic PDE" \\

    \ \ -<no-break>-rights cc-by-4.0 -<no-break>-available 2015-08-31
  </verbatim-code>
  </html-div-class>

  <verbatim|-<no-break>-rights> takes an SPDX key (<verbatim|cc-by-4.0>, <verbatim|cc-by-sa-4.0>, <verbatim|cc0-1.0>, <verbatim|gpl-3.0-only>, <verbatim|gpl-3.0-or-later>) or a statement in plain text; by default a new version keeps the licence of the previous one, and a new paper is "All rights reserved". Any source works (LaTeX, Markdown, ...) with its PDF; a TeXmacs source (<verbatim|.tm>) needs no PDF, since the archive typesets it. A paper whose sources are lost is deposited as a PDF alone, saying why: <verbatim|-<no-break>-no-source "the sources are lost">; <verbatim|osheaf complete LABEL -<no-break>-version N -<no-break>-source paper.tex> adds them later. Files are kept byte for byte.

  The options can also come from a YAML or JSON file, with the same names, which is handy for papers with many authors or for several deposits at once (a list in the file):

  <\html-div-class|language-bash>
  <\verbatim-code>
    osheaf deposit -<no-break>-from kpz.yaml
  </verbatim-code>
  </html-div-class>

  <\html-div-class|language-yaml>
  <\verbatim-code>
    id: kpz-uniqueness

    source: paper.tex

    pdf: paper.pdf

    extra-sources: [refs.bib]

    title: Energy solutions of KPZ are unique

    authors:

    \ \ - Doe, Jane\|Example University

    abstract: \|

    \ \ We prove that energy solutions of the KPZ equation are unique.

    rights: cc-by-4.0

    available: 2015-08-31
  </verbatim-code>
  </html-div-class>

  <subsection*|New versions><label|new-versions>

  The same command without <verbatim|-<no-break>-new> adds a version, signed, to the paper with that label. It keeps the abstract, keywords and licence of the previous version unless you give them again:

  <\html-div-class|language-bash>
  <\verbatim-code>
    osheaf deposit kpz-uniqueness paper.tex -<no-break>-pdf paper.pdf -<no-break>-changes "Typos corrected." \\

    \ \ -<no-break>-title "Energy solutions of KPZ are unique" -<no-break>-author "Doe, Jane\|Example University"
  </verbatim-code>
  </html-div-class>

  Dates follow the specification: <verbatim|-<no-break>-available> (when this version was first made available, public or not; by default today, the deposit), <verbatim|-<no-break>-created> for when a version deposited long after was written, <verbatim|-<no-break>-issued> for the first appearance of the work. A version found later, which belongs earlier in the history, is placed with <verbatim|-<no-break>-after N>. The publication stage is <verbatim|-<no-break>-stage> (<verbatim|AM> for an accepted manuscript, <verbatim|VoR> for the version of record, ...).

  <subsection*|Notices, corrections and withdrawals><label|notices-corrections-and-withdrawals>

  These change what is said about a paper without changing its files. Each makes a new version that holds only the description.

  <\html-div-class|language-bash>
  <\verbatim-code>
    osheaf notice kpz-uniqueness -<no-break>-about 1 -<no-break>-text "Lemma 2 is wrong as stated; see version 2."

    osheaf describe kpz-uniqueness -<no-break>-title "Energy solutions of the KPZ equation are unique"

    osheaf relicense kpz-uniqueness -<no-break>-rights cc-by-4.0 -<no-break>-method "confirmed by email"

    osheaf relate kpz-uniqueness -<no-break>-to arxiv:1508.07764 -<no-break>-relation IsIdenticalTo

    osheaf withdraw kpz-uniqueness -<no-break>-reason "Superseded by a joint paper."
  </verbatim-code>
  </html-div-class>

  A notice is about one version (<verbatim|-<no-break>-about>) and stays in every later one; its <verbatim|-<no-break>-text> is required, and <verbatim|-<no-break>-file> adds a full statement, such as an erratum. <verbatim|describe> corrects the title, the abstract, the keywords or the authors. <verbatim|relicense> records a new licence with the authors' agreement; its <verbatim|-<no-break>-rights> takes the same values as that of <verbatim|deposit>. <verbatim|relate> links the same work elsewhere (on arXiv, or by a DOI). <verbatim|withdraw> withdraws the versions of the paper deposited so far: the content stays, and every page that shows them shows the withdrawal; its <verbatim|-<no-break>-reason> is required. A later <verbatim|deposit> of a new version reinstates the paper, while the versions withdrawn stay withdrawn (section <hlink|13|opensheaf-specification-0.2.tm#13-withdrawal-takedown-and-tombstones>).

  <subsection*|Changing a label><label|changing-a-label>

  A label is your archive's choice, and may change (section <hlink|3.1|opensheaf-specification-0.2.tm#31-the-discovery-document>); the permanent name of a paper, its <verbatim|sheaf:> URI, does not.

  <\html-div-class|language-bash>
  <\verbatim-code>
    osheaf label kpz-uniqueness kpz-energy-solutions \ \ \ # a paper or a collection, by its label

    osheaf label "sheaf:\<less\>name\<gtr\>:\<less\>owner\<gtr\>" kpz-copy \ \ \ \ \ \ \ # a line without a label, by its identifier

    osheaf label -<no-break>-owner \<less\>owner\<gtr\> jane-doe \ \ \ \ \ \ \ \ \ \ \ \ \ \ # the owner object

    osheaf label kpz-copy -<no-break>-unset \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ # no label: the page is at paper/\<less\>name\<gtr\>/
  </verbatim-code>
  </html-div-class>

  The discovery document, the indexes and the website are written again; the featured collection is renamed in <verbatim|osheaf.json> too. The readable address moves to <verbatim|paper/\<less\>new\<gtr\>/>, and the HTML version of a TeXmacs paper to <verbatim|site/\<less\>new\<gtr\>/\<less\>new\<gtr\>.html>, with its images; the permanent address <verbatim|paper/\<less\>name\<gtr\>/>, which the descriptions record, does not change. As a courtesy to links shared with the old readable address, <verbatim|osheaf.json> records it in <verbatim|formerAddresses>, and the website keeps a small page there that sends the reader on, until another paper takes the label. A takedown removes them with the paper.

  <subsection*|Updating the archive and checking it><label|updating-the-archive-and-checking-it>

  <\html-div-class|language-bash>
  <\verbatim-code>
    osheaf collect \ \ # new versions of the owner catalogues, listing the latest versions

    osheaf index \ \ \ \ # rewrite opensheaf.json, the indexes and the website

    osheaf verify \ \ \ # check everything, as section 14 of the specification asks
  </verbatim-code>
  </html-div-class>

  Each owner the archive hosts has an owner catalogue of its own, made when the owner is set up (by <verbatim|osheaf init>, or by <verbatim|osheaf owner init> for another owner in the same archive), which lists its papers in the archive, branches included (section <hlink|8.1|opensheaf-specification-0.2.tm#81-catalogues-and-selections>). <verbatim|osheaf collect> gives a new version only to the catalogues whose papers changed, each signed by its own owner; <verbatim|-<no-break>-owner OWNER> takes one owner's catalogue alone. The catalogue of the archive's first owner is labelled <verbatim|main>; that of another owner <verbatim|\<less\>label\<gtr\>-catalogue>, when the owner has a label, which <verbatim|osheaf label -<no-break>-owner> gives or changes with the owner's.

  With several owners, the home page lists the papers of all the catalogues together, newest first, each with its owner; with <verbatim|"index": {"owners": "by-owner"}> in <verbatim|osheaf.json> (the default is <verbatim|"together">), it lists them under a heading for each owner, in the order of <verbatim|owners> in <verbatim|opensheaf.json>. With one owner both are the same.

  The website is written again after every command that changes the archive, so <verbatim|osheaf index> is only needed to rewrite everything. <verbatim|osheaf verify> reports errors, warnings and the status of every signature and member; <verbatim|-<no-break>-remote> also checks the members of your collections held in other archives, and <verbatim|-<no-break>-json> prints the findings for a program. The same checks can be run on a published archive from the browser, with the <hlink|Explorer|https://opensheaf.org/explorer/>.

  <subsection*|Publishing><label|publishing>

  An archive is plain files: serve the folder from any static web server, at the address given as <verbatim|-<no-break>-base-url>. With git and GitHub Pages, the easiest start is the <hlink|archive template|https://github.com/opensheaf/archive-template>, which has the workflows and Pages already set up. A folder made with <verbatim|osheaf init> is ready for git as it is: <verbatim|init> wrote its <verbatim|.gitattributes>, so that git keeps every file byte for byte. Then, after each change:

  <\html-div-class|language-bash>
  <\verbatim-code>
    osheaf verify

    git add -A && git commit -m "A new version of kpz-uniqueness" && git push
  </verbatim-code>
  </html-div-class>

  On GitHub, turn Pages on once (<strong|Settings>, <strong|Pages>, <strong|Deploy from a branch>, <verbatim|main>, <verbatim|/ (root)>). The archive is only ever added to: never rewrite the history of a published branch.

  <section*|Keys><label|keys>

  The owner's <dfn|key log> is kept in the archive, and travels with every copy of your papers, so that anyone can check that a version was signed by you (section <hlink|6|opensheaf-specification-0.2.tm#6-owners>). The private keys are never in the archive.

  <\html-div-class|language-bash>
  <\verbatim-code>
    osheaf owner show \ \ # the key log: current keys, rotation keys committed, keeper

    osheaf key list \ \ \ \ # what the key wallet holds (never a secret)
  </verbatim-code>
  </html-div-class>

  Wallets and owners are many to many: one wallet may hold the keys of several owners (an institution's), several people may share one owner's keys in a wallet, each with a passkey of their own, and the keys of one owner may be in several wallets. Two lists say where keys are looked for:

  <\itemize>
    <item>your own wallets, in <verbatim|~/.config/opensheaf/config.json>, <verbatim|{"wallets": ["github:me/opensheaf-keys", "github:institute/keys"]}>;

    <item>for each owner of an archive, the wallets that hold its keys, as hints in its <verbatim|osheaf.json>, <verbatim|"keys": {"\<less\>owner\<gtr\>": {"wallets": [.<no-break>.<no-break>.]}}> (GitHub wallets only), written by <verbatim|init>, <verbatim|owner init> and <verbatim|owner rotate> with <verbatim|-<no-break>-keys github:.<no-break>.<no-break>.>, and by <verbatim|key push -<no-break>-wallet github:.<no-break>.<no-break>.>.
  </itemize>

  The <verbatim|key> commands look for the keys of an owner in the wallets hinted for it, then in yours, in order, and use the first that holds them; <verbatim|OPENSHEAF_WALLET> wins over both, and <verbatim|-<no-break>-wallet github:OWNER/REPO> (or <verbatim|-<no-break>-wallet command>) names another. A wallet configured under <verbatim|keys> in your file (a command wallet) comes after your <verbatim|wallets>.

  <\html-div-class|language-bash>
  <\verbatim-code>
    osheaf key wallet \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ # where the keys of the owner are looked for, in order

    osheaf key wallet -<no-break>-owner OWNER -<no-break>-add github:me/opensheaf-keys \ \ \ \ # a hint in osheaf.json

    osheaf key wallet -<no-break>-remove github:me/old-keys

    osheaf key wallets \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ # your wallets, the owners each holds, their locks

    osheaf key wallets -<no-break>-add github:institute/keys \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ # in your configuration file
  </verbatim-code>
  </html-div-class>

  <subsection*|A new computer><label|a-new-computer>

  With a key wallet, a new computer takes the current key from it:

  <\html-div-class|language-bash>
  <\verbatim-code>
    osheaf key pull \ \ \ \ # asks the passphrase (or the passkey), keeps the key here
  </verbatim-code>
  </html-div-class>

  With the offline level, a new computer makes its own key, which two rotation keys add to the key log:

  <\html-div-class|language-bash>
  <\verbatim-code>
    osheaf key new \ \ \ \ \ # on the new computer: prints its did:key

    osheaf owner rotate -<no-break>-add did:key:z6Mk.<no-break>.<no-break>. \\

    \ \ -<no-break>-rotation-key /Volumes/USB/opensheaf-keys/rotation-.<no-break>.<no-break>.-1.txt \\

    \ \ -<no-break>-rotation-key /Volumes/USB/opensheaf-keys/rotation-.<no-break>.<no-break>.-2.txt \\

    \ \ -<no-break>-export /Volumes/USB/opensheaf-keys-2 -<no-break>-print
  </verbatim-code>
  </html-div-class>

  Each rotation uses up the rotation keys that sign it and makes new ones, exported as the first were; destroy the old ones once it is done. <verbatim|owner rotate -<no-break>-retire DID> retires a key you no longer use.

  <subsection*|Unlocking with a passkey><label|unlocking-with-a-passkey>

  With a key wallet, a <strong|passkey> (Touch ID on a Mac, or a security key) can replace the passphrase:

  <\html-div-class|language-bash>
  <\verbatim-code>
    osheaf key enroll \ \ # once: asks the passphrase, then makes the passkey in the browser

    osheaf key unlock \ \ # on another computer: Touch ID, and the current keys are pulled
  </verbatim-code>
  </html-div-class>

  <verbatim|key enroll> opens the page <hlink|unlock.opensheaf.org|https://unlock.opensheaf.org/> in the browser, which makes a passkey for <verbatim|unlock.opensheaf.org> and hands a secret derived from it back to <verbatim|osheaf> on your own computer. <verbatim|osheaf> opens the page a second time, to check that the new passkey alone gives the same secret, and only then locks the keys of the owner in the wallet under that secret as well as under the passphrase. A passkey kept in iCloud Keychain is on all your Macs. From then on, whenever <verbatim|osheaf> needs a key of the wallet, it opens the page, which asks for Touch ID. The page needs a recent browser (Safari 17, Chrome 133, Firefox 130 or later) and a passkey provider that supports the PRF extension (iCloud Keychain, Google Password Manager, 1Password, or a security key).

  <strong|Check the code.> Each time, <verbatim|osheaf> prints a code of six digits ("Check that the browser shows the code 123 456"), and the page shows one too. The page does nothing until you tick <strong|The terminal shows the same code>; a page that shows another code was not opened by this <verbatim|osheaf>: close it.

  The passphrase remains the way back: <verbatim|osheaf> asks for it if the page reports an error, after two minutes without an answer, when you press Ctrl-C while it waits, or when the browser's answer does not open a key. Writing new keys into the wallet still needs the passphrase. Run <verbatim|osheaf key enroll> again after a rotation that did not unlock with the passkey, so that it opens the new keys too; <verbatim|-<no-break>-new-passkey> adds a passkey of another provider. <verbatim|-<no-break>-no-browser> prints the address instead of opening it.

  <strong|From the browser.> The <hlink|OpenSheaf Manager|https://manager.opensheaf.org/> does the same for the owner of an archive it keeps ("Write directly", then "Set up a key wallet"): it puts the current key of your computer's key store in a private repository you created, locked with the passphrase, as <verbatim|osheaf key push> does, and adds the lock of a passkey made by the same page of <verbatim|unlock.opensheaf.org>, opened as a popup of the Manager, as <verbatim|osheaf key enroll> does. The files are the same, and <verbatim|osheaf key pull> and <verbatim|osheaf key unlock> read them. When the current key is not at hand, the page can make a new one instead ("Create a new key here"): it adds the key to the owner's key log by a new version, as <verbatim|osheaf owner rotate -<no-break>-add> does, signed by the rotation keys you give it (the files <verbatim|-<no-break>-export> wrote, or those the wallet keeps at the security level <verbatim|-<no-break>-keys github:OWNER/REPO>), commits that version to the archive and puts the key in the wallet. With files, the new rotation keys are given back as files of the same names and text (and the sheets of <verbatim|-<no-break>-print>), locked with the passphrase, and the version is committed only once you have typed their checks; with the wallet, the new ones are put there. The rotation keys then pass through the page's memory: the maximum security level keeps them offline, used by <verbatim|osheaf> alone.

  <strong|A new archive from the browser.> For a repository made from the archive template and not set up yet, the Manager can also make the owner itself ("Create the owner and set up the archive here"), as <verbatim|osheaf init -<no-break>-new-owner -<no-break>-key DID> makes it: a current key that signs in the page and goes to your key wallet, a current key for the archive's workflows (the <verbatim|DID>, stored as the repository secret <verbatim|OPENSHEAF_SIGNING_KEY> when your sign-in may set secrets, otherwise shown once for you to store), and three rotation keys, two of which sign the next version of the key log; the first version of the key log is the one <verbatim|osheaf> makes for the same keys and time. The rotation keys are given as the files of <verbatim|-<no-break>-export> (one zip, or one by one) and the sheets of <verbatim|-<no-break>-print>, locked with the passphrase, and nothing is committed until their checks are typed back; or, at the level <verbatim|-<no-break>-keys github:OWNER/REPO>, they are kept in the wallet. The page then sets the archive up as the template's "Set up the archive" does, with the same files, and opens it with your key unlocked. The rotation keys pass through the page's memory: to keep them away from any browser, make the owner with <verbatim|osheaf> (the key ceremony of the template's README), which the Manager also guides.

  <strong|Passkeys made on opensheaf.org.> The first version of the page, at <verbatim|opensheaf.org/manager/unlock.html>, made passkeys for <verbatim|opensheaf.org>, which <verbatim|osheaf> no longer asks the browser for; the keys they locked still open with the passphrase. Move once, to a passkey for <verbatim|unlock.opensheaf.org>, then remove the old locks (the passphrase lock stays):

  <\html-div-class|language-bash>
  <\verbatim-code>
    osheaf key enroll -<no-break>-new-passkey

    osheaf key forget -<no-break>-rp opensheaf.org
  </verbatim-code>
  </html-div-class>

  <verbatim|osheaf key forget -<no-break>-passkey CRED> likewise removes the locks of one passkey, named by its credential.

  <subsection*|Where the keys are kept><label|where-the-keys-are-kept>

  On each computer, the current key is kept in the system's credential store (the macOS keychain, with the extra <verbatim|keys>), or else in the keychain through the <verbatim|security> command, or else in a file under <verbatim|~/.config/opensheaf/keys> readable only by you. The environment variable <verbatim|OPENSHEAF_KEY_STORE> chooses: <verbatim|keyring>, <verbatim|security> (the macOS keychain through its own command) or <verbatim|file> use that store alone, and <strong|<verbatim|none>> keeps no key on the computer at all: every command that signs opens the key from the wallet (one Touch ID, or the passphrase) and forgets it when it ends. <verbatim|none> needs a key wallet, and suits <verbatim|uvx>, whose Pythons come and go:

  <\html-div-class|language-bash>
  <\verbatim-code>
    export OPENSHEAF_KEY_STORE=none
  </verbatim-code>
  </html-div-class>

  Other variables: <verbatim|OPENSHEAF_WALLET> names the wallet instead of <verbatim|osheaf.json> (to keep its name out of a public archive, or for a command wallet); <verbatim|OPENSHEAF_PASSPHRASE_COMMAND> names a command that prints the passphrase (for instance <verbatim|security find-generic-password -w -s opensheaf-passphrase>); <verbatim|OPENSHEAF_UNLOCK=passphrase> skips the passkey, as does <verbatim|OPENSHEAF_PASSPHRASE> (the passphrase itself, for scripts). In a workflow on GitHub, a key of its own, added with <verbatim|owner rotate -<no-break>-add>, is given in the secret <verbatim|OPENSHEAF_SIGNING_KEY>; the template's README shows how.

  A key also moves through a password manager by the clipboard: <verbatim|osheaf key export -<no-break>-clipboard> (with <verbatim|-<no-break>-encrypt> to encrypt it under the passphrase), and <verbatim|osheaf key import -<no-break>-clipboard> on the other computer.

  <subsection*|Moving up to offline><label|moving-up-to-offline>

  A wallet's rotation keys can be replaced by offline ones in one rotation, after which those in the wallet are used up and can be removed:

  <\html-div-class|language-bash>
  <\verbatim-code>
    osheaf owner rotate -<no-break>-keys offline -<no-break>-export /Volumes/USB/opensheaf-keys -<no-break>-print

    osheaf key forget -<no-break>-from-wallet -<no-break>-used
  </verbatim-code>
  </html-div-class>

  <subsection*|If a computer is lost or stolen><label|if-a-computer-is-lost-or-stolen>

  Its current key must be treated as known to someone else. From another computer, make a new key and <strong|expose> the old one: a new version of the key log, signed by two rotation keys, which a thief holding only the current key cannot contest (section <hlink|6.3|opensheaf-specification-0.2.tm#63-ending-exposed-keys-and-forks>). <verbatim|osheaf owner show> gives the <verbatim|did:key> of the lost key.

  <\html-div-class|language-bash>
  <\verbatim-code>
    osheaf key new \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ # prints did:key:NEW

    osheaf owner expose did:key:OLD -<no-break>-add did:key:NEW \\

    \ \ -<no-break>-rotation-key /Volumes/USB/opensheaf-keys/rotation-.<no-break>.<no-break>.-1.txt \\

    \ \ -<no-break>-rotation-key /Volumes/USB/opensheaf-keys/rotation-.<no-break>.<no-break>.-2.txt \\

    \ \ -<no-break>-export /Volumes/USB/opensheaf-keys-2 -<no-break>-print
  </verbatim-code>
  </html-div-class>

  With a key wallet, leave out <verbatim|-<no-break>-rotation-key> and <verbatim|-<no-break>-export>: the rotation keys are read from the wallet. If the passphrase of the wallet may also be known, move up to offline at the same time (<verbatim|-<no-break>-keys offline -<no-break>-export DIR>). Versions that only the exposed key signed are now <strong|contested>; if you made them, sign them again with the new key:

  <\html-div-class|language-bash>
  <\verbatim-code>
    osheaf sign kpz-uniqueness -<no-break>-version v3
  </verbatim-code>
  </html-div-class>

  Publish the result at once, so that readers learn of the exposure.

  <subsection*|Ending an owner><label|ending-an-owner>

  <verbatim|osheaf owner end> signs the last version of the key log, with two rotation keys, for instance when the work moves to another owner (<verbatim|-<no-break>-successor OWNER>), or when rotation keys may have been stolen, which is the one thing an exposure cannot repair; <verbatim|-<no-break>-expose DID> also exposes keys. An ended owner signs nothing more; what it signed before stays good.

  <subsection*|If writing the key log was interrupted><label|if-writing-the-key-log-was-interrupted>

  A new version of a key log is written in its own folder before the root inventory names it. If that is interrupted (a crash, a full disk), the folder is left after the head, and the tools sign no other version of that number, since two signed versions of one number would fork the key log, and a fork ends the owner. <verbatim|osheaf owner complete> settles it: a signed version that passes the checks is completed and becomes the head, an unsigned one is removed, and a signed one that fails the checks is left with an explanation, since removing it is safe only if it was never copied.

  <section*|Collections and other archives><label|collections-and-other-archives>

  <subsection*|Collections><label|collections>

  A <dfn|collection> gathers papers of any archive, each pinned to a version (section <hlink|8|opensheaf-specification-0.2.tm#8-collections>). A <strong|catalogue> may follow its papers to their new versions; a <strong|selection>, such as a reading list or a journal issue, lists only the versions you vetted.

  <\html-div-class|language-bash>
  <\verbatim-code>
    osheaf collection new reading -<no-break>-type selection -<no-break>-title "Reading list"

    osheaf collection add reading "sheaf:\<less\>name\<gtr\>:\<less\>owner\<gtr\>?at=https%3A%2F%2Fother.example%2Fpapers%2F" -<no-break>-revision 2

    osheaf collection add reading kpz-uniqueness -<no-break>-revision 1

    osheaf collection status reading
  </verbatim-code>
  </html-div-class>

  A member is given by its <verbatim|sheaf:> URI (shown on its page), with <verbatim|at> or <verbatim|-<no-break>-at URL> saying where to find it, or by a label of your own archive; only verified versions are pinned. In a catalogue, <verbatim|-<no-break>-follow> (or <verbatim|osheaf collection follow>) follows a paper; <verbatim|osheaf collection update> then moves it to the latest signed version, and for a selection lists the versions not yet vetted. <verbatim|collection remove> removes a member or a revision, and <verbatim|collection sync LABEL -<no-break>-from collection.yaml> writes a whole collection from a file. To show a collection first on the home page, set <verbatim|"featured": "reading"> under <verbatim|index>, <verbatim|html> in <verbatim|osheaf.json>.

  <subsection*|Finding a paper><label|finding-a-paper>

  <verbatim|osheaf resolve> finds and checks what a <verbatim|sheaf:> URI names, in any archive: every copy found is checked against its owner's key log, and the URI resolves to the latest signed version among the copies that agree (section <hlink|12.3|opensheaf-specification-0.2.tm#123-resolution>).

  <\html-div-class|language-bash>
  <\verbatim-code>
    osheaf resolve "sheaf:\<less\>name\<gtr\>:\<less\>owner\<gtr\>/v2" -<no-break>-at https://mgubi.org/papers/
  </verbatim-code>
  </html-div-class>

  <subsection*|Mirrors><label|mirrors>

  A library, or a colleague keeping a preservation copy, <strong|mirrors> a paper written elsewhere: a byte-for-byte copy, checked, with its owner's key log (section <hlink|11|opensheaf-specification-0.2.tm#11-copies-and-mirrors>). Your archive answers for having the right to redistribute it, by its licence or the authors' agreement (section 11.2): a version not under a licence the tool knows to be open is copied with a warning, which <verbatim|-<no-break>-licence-checked> silences. <verbatim|osheaf mirror -<no-break>-all> brings every mirror up to date, and reports a line taken down where it was copied from: the takedown does not reach your mirror, which you keep or take down yourself (section 13.3).

  <\html-div-class|language-bash>
  <\verbatim-code>
    osheaf mirror "sheaf:\<less\>name\<gtr\>:\<less\>owner\<gtr\>" -<no-break>-at https://mgubi.org/papers/ -<no-break>-label kpz-copy
  </verbatim-code>
  </html-div-class>

  <subsection*|Branches and accepted copies><label|branches-and-accepted-copies>

  A <strong|branch> continues a signed version of someone else's paper as a paper of your own, keeping the evidence of where it started (section <hlink|9|opensheaf-specification-0.2.tm#9-branches-and-accepted-copies>). A journal <strong|accepts> a paper as an accepted copy, a branch listed by one of its selections (section <hlink|9.6|opensheaf-specification-0.2.tm#96-accepted-copies>); its own typeset version is then deposited as a later version of that copy, with <verbatim|-<no-break>-stage VoR> and <verbatim|-<no-break>-agreement>. A branch numbers its own versions from 1: its first version is its version 1, whatever the parent's number, which it records. Branching or accepting a later version of the same paper again gives the existing branch a new branch point, its next version, which keeps the branch's own notices (section <hlink|9.4|opensheaf-specification-0.2.tm#94-later-versions-and-new-branch-points>).

  <\html-div-class|language-bash>
  <\verbatim-code>
    osheaf branch "sheaf:\<less\>name\<gtr\>:\<less\>owner\<gtr\>/v3" -<no-break>-at https://other.example/papers/ -<no-break>-label kpz-continued

    osheaf accept "sheaf:\<less\>name\<gtr\>:\<less\>owner\<gtr\>/v2" -<no-break>-at https://other.example/papers/ -<no-break>-selection issue-1
  </verbatim-code>
  </html-div-class>

  <subsection*|Key logs of other owners><label|key-logs-of-other-owners>

  <verbatim|osheaf owner pull URL> compares your copy of an owner's key log with the copy at another archive: it extends yours, or, if the two disagree, records a fork, which freezes that owner.

  <\html-div-class|language-bash>
  <\verbatim-code>
    osheaf owner pull https://other.example/papers/ -<no-break>-owner \<less\>owner\<gtr\>
  </verbatim-code>
  </html-div-class>

  <subsection*|Drafts and sealing><label|drafts-and-sealing>

  A <strong|draft> is unsigned work in progress at <verbatim|draft/\<less\>id\<gtr\>/>, listed apart in the discovery document and deleted without a trace (section <hlink|10|opensheaf-specification-0.2.tm#10-drafts-and-sealing>). It takes the options of <verbatim|deposit>. <strong|Sealing> makes it a signed paper, version 1.

  <\html-div-class|language-bash>
  <\verbatim-code>
    osheaf draft new notes notes.tex -<no-break>-pdf notes.pdf -<no-break>-title "Notes on KPZ" -<no-break>-author "Doe, Jane"

    osheaf draft deposit notes notes.tex -<no-break>-pdf notes.pdf -<no-break>-replace

    osheaf seal notes -<no-break>-label kpz-notes -<no-break>-delete-draft
  </verbatim-code>
  </html-div-class>

  <subsection*|Taking down><label|taking-down>

  <verbatim|osheaf takedown> deletes an object, leaving a tombstone in the discovery document. It is for what must not be served (by law, for a breach of rights, to erase personal data) or a paper the archive stops keeping, not for a paper that is merely wrong, which is withdrawn instead (section <hlink|13|opensheaf-specification-0.2.tm#13-withdrawal-takedown-and-tombstones>).

  <\html-div-class|language-bash>
  <\verbatim-code>
    osheaf takedown kpz-notes -<no-break>-reason "Deposited by mistake."
  </verbatim-code>
  </html-div-class>

  <section*|arXiv and Zenodo><label|arxiv-and-zenodo>

  <subsection*|Importing from arXiv><label|importing-from-arxiv>

  <verbatim|osheaf arxiv fetch> downloads papers from arXiv, every version with its licence and comments (it needs no archive, and can be run again: what is already downloaded is not fetched again). <verbatim|osheaf arxiv import> makes one signed paper per arXiv paper, one version per arXiv version, with arXiv's files byte for byte; the labels come from <verbatim|identifiers.json> in the downloads folder.

  <\html-div-class|language-bash>
  <\verbatim-code>
    osheaf arxiv fetch downloads -<no-break>-author doe_j_1 \ \ \ \ \ \ \ # or arXiv identifiers

    echo '{"1508.07764": "kpz-uniqueness"}' \<gtr\> downloads/identifiers.json

    osheaf arxiv import downloads -<no-break>-agreement "deposited by an author"

    osheaf arxiv fetch downloads -<no-break>-refresh 1508.07764 \ \ \ # later: new arXiv versions

    osheaf arxiv import downloads 1508.07764 -<no-break>-update
  </verbatim-code>
  </html-div-class>

  <verbatim|-<no-break>-dry-run> shows what would be imported, and <verbatim|-<no-break>-versions v1,v3> imports only some versions.

  <subsection*|DOIs from Zenodo><label|dois-from-zenodo>

  <verbatim|osheaf zenodo LABEL> deposits the current version of a paper on Zenodo and records its DOI in a new, signed version (appendix <hlink|A.1|opensheaf-specification-0.2.tm#a1-zenodo-zenodo>). By default it uses the Zenodo <strong|sandbox>, on a copy, leaving the archive unchanged: try it there first. <verbatim|-<no-break>-production> deposits on zenodo.org for real.

  <\html-div-class|language-bash>
  <\verbatim-code>
    osheaf zenodo kpz-uniqueness \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ # the sandbox

    osheaf zenodo kpz-uniqueness -<no-break>-production
  </verbatim-code>
  </html-div-class>

  The tokens are read from <verbatim|ZENODO_SANDBOX_TOKEN> and <verbatim|ZENODO_TOKEN>, or from the credential store under <verbatim|zenodo-sandbox-token> and <verbatim|zenodo-token>.

  <section*|Command reference><label|command-reference>

  <block|<tformat|<cwith|1|1|1|-1|font-series|bold>|<cwith|1|-1|1|-1|cell-valign|top>|<cwith|1|-1|1|-1|cell-hyphen|t>|<table|<row|<cell|Command>|<cell|What it does>>|<row|<cell|<verbatim|init>>|<cell|create an archive: <verbatim|osheaf.json>, storage, owner, its owner catalogue>>|<row|<cell|<verbatim|deposit LABEL [SOURCE]>>|<cell|deposit a paper (<verbatim|-<no-break>-new>) or a new version of it>>|<row|<cell|<verbatim|notice LABEL>>|<cell|a notice about a version (<verbatim|-<no-break>-about N -<no-break>-text TEXT>)>>|<row|<cell|<verbatim|describe LABEL>>|<cell|correct the title, abstract, keywords or authors>>|<row|<cell|<verbatim|relicense LABEL>>|<cell|record a new licence, with the authors' agreement>>|<row|<cell|<verbatim|relate LABEL>>|<cell|link the same work elsewhere (arXiv, DOI)>>|<row|<cell|<verbatim|withdraw LABEL>>|<cell|withdraw a paper (<verbatim|-<no-break>-reason TEXT>); the content stays>>|<row|<cell|<verbatim|complete LABEL>>|<cell|add the sources of a version deposited without them>>|<row|<cell|<verbatim|collect>>|<cell|new versions of the owner catalogues, when needed (<verbatim|-<no-break>-owner>: one)>>|<row|<cell|<verbatim|index>>|<cell|rewrite <verbatim|opensheaf.json>, the indexes and the website>>|<row|<cell|<verbatim|verify>>|<cell|check the archive (<verbatim|-<no-break>-remote>, <verbatim|-<no-break>-json>)>>|<row|<cell|<verbatim|collection new LABEL>>|<cell|make a collection (<verbatim|-<no-break>-type>, <verbatim|-<no-break>-title>)>>|<row|<cell|<verbatim|collection add>, <verbatim|remove>>|<cell|add or remove members>>|<row|<cell|<verbatim|collection follow>, <verbatim|update>>|<cell|follow members to their new versions>>|<row|<cell|<verbatim|collection status>, <verbatim|sync>>|<cell|the status of members; write from a file>>|<row|<cell|<verbatim|resolve URI>>|<cell|find and check what a <verbatim|sheaf:> URI names>>|<row|<cell|<verbatim|mirror URI>>|<cell|copy a paper written elsewhere (<verbatim|-<no-break>-all>: update every mirror)>>|<row|<cell|<verbatim|branch URI>>|<cell|continue another owner's version as a paper of yours>>|<row|<cell|<verbatim|accept URI>>|<cell|an accepted copy, listed by a selection>>|<row|<cell|<verbatim|draft new DRAFT>, <verbatim|deposit>, <verbatim|delete>>|<cell|unsigned work in progress>>|<row|<cell|<verbatim|seal DRAFT>>|<cell|seal a draft as a new paper (<verbatim|-<no-break>-label LABEL>)>>|<row|<cell|<verbatim|label LINE LABEL>>|<cell|give a paper or collection a new label (<verbatim|-<no-break>-unset>; <verbatim|-<no-break>-owner OWNER>: the owner object)>>|<row|<cell|<verbatim|takedown LABEL>>|<cell|delete an object, leaving a tombstone>>|<row|<cell|<verbatim|owner init>>|<cell|make an owner (done by <verbatim|init -<no-break>-new-owner>); in an archive, with its owner catalogue>>|<row|<cell|<verbatim|owner show>>|<cell|show the key log>>|<row|<cell|<verbatim|owner rotate>>|<cell|add or retire current keys, new rotation keys>>|<row|<cell|<verbatim|owner expose DID>>|<cell|declare stolen or leaked keys>>|<row|<cell|<verbatim|owner end>>|<cell|the last version of the key log>>|<row|<cell|<verbatim|owner complete>>|<cell|settle a version of the key log left by an interrupted write>>|<row|<cell|<verbatim|owner pull URL>>|<cell|meet another copy of a key log>>|<row|<cell|<verbatim|sign LABEL>>|<cell|sign again a version contested by an exposed key (<verbatim|-<no-break>-version vN>)>>|<row|<cell|<verbatim|key new>>|<cell|a new current key for this computer>>|<row|<cell|<verbatim|key push>, <verbatim|pull>>|<cell|current keys to and from the key wallet (<verbatim|-<no-break>-wallet WALLET>; a wallet only <verbatim|osheaf.json> names is used after asking, or with <verbatim|-<no-break>-yes>)>>|<row|<cell|<verbatim|key list>>|<cell|what the key wallet holds>>|<row|<cell|<verbatim|key wallet>>|<cell|the wallets an owner's keys are looked for in; hints in <verbatim|osheaf.json> (<verbatim|-<no-break>-add>, <verbatim|-<no-break>-remove>)>>|<row|<cell|<verbatim|key wallets>>|<cell|your wallets and the owners each holds (<verbatim|-<no-break>-add>, <verbatim|-<no-break>-remove>)>>|<row|<cell|<verbatim|key forget>>|<cell|remove keys from this computer, after asking (<verbatim|-<no-break>-yes>; <verbatim|-<no-break>-from-wallet>: also from the wallet)>>|<row|<cell|<verbatim|key forget -<no-break>-rp RP>, <verbatim|-<no-break>-passkey CRED>>|<cell|remove the passkey locks of a relying party or a passkey>>|<row|<cell|<verbatim|key export>, <verbatim|import>>|<cell|a key to and from a password manager>>|<row|<cell|<verbatim|key enroll>, <verbatim|unlock>>|<cell|open the keys of the wallet with a passkey>>|<row|<cell|<verbatim|arxiv fetch>>|<cell|download papers from arXiv>>|<row|<cell|<verbatim|arxiv import DOWNLOADS>>|<cell|import them, one signed paper each>>|<row|<cell|<verbatim|zenodo LABEL>>|<cell|a DOI from Zenodo (sandbox, or <verbatim|-<no-break>-production>)>>|<row|<cell|<verbatim|help-config>>|<cell|describe <verbatim|osheaf.json> and <verbatim|~/.config/opensheaf/config.json>>>>>>

  <section*|Where to go next><label|where-to-go-next>

  <\itemize>
    <item>To keep an archive from the browser, without the command line: the <hlink|archive template|https://github.com/opensheaf/archive-template>, whose README also walks through the key ceremony, and the <hlink|OpenSheaf Manager|https://manager.opensheaf.org/>, which keeps an archive made from the template from a page. Both run <verbatim|osheaf> for you.

    <item>To look at an archive and check it: the <hlink|Explorer|https://opensheaf.org/explorer/>, for instance on the <hlink|first archive|https://opensheaf.org/explorer/?url=https://mgubi.org/papers/>, <hlink|mgubi.org/papers|https://mgubi.org/papers/>, which is kept with these tools.

    <item>To understand how the tools work: the <hlink|literate program|https://opensheaf.org/opensheaf-py/>, which explains the code along the specification.

    <item>Problems, questions and ideas about the tools: the <hlink|issues of opensheaf-py|https://github.com/opensheaf/opensheaf-py/issues>; about the format: the <hlink|issues of the specification|https://github.com/opensheaf/opensheaf.github.io/issues>.
  </itemize>

</body>

<\initial>
  <\collection>
    <associate|page-medium|paper>
  </collection>
</initial>
