<TeXmacs|2.1.5>

<style|<tuple|notes|notes-meta>>

<\body>
  <notes-header>

  <chapter*|OpenSheaf: frequently asked questions>

  <notes-abstract|Answers to questions that come up about the design of <hlink|OpenSheaf|https://opensheaf.org>. The specification (<hlink|opensheaf-specification-0.1.md|opensheaf-specification-0.1.tm>) is authoritative; this page explains its choices.>

  <section*|What is OpenSheaf for?><label|what-is-opensheaf-for>

  It is an open format for archives of scholarly documents and for collections of them: a lean alternative to arXiv and to the usual publication infrastructure. Anyone can keep an archive of their documents as plain files on a static website, with sources, versions fixed by hashes, standard metadata, and collections that combine documents from several archives.

  <section*|Why not just use arXiv, or Zenodo?><label|why-not-just-use-arxiv-or-zenodo>

  Both are excellent services, and OpenSheaf works with them: a document can also be on arXiv (linked with <verbatim|IsIdenticalTo>), and the Zenodo profile gives every version a DOI on Zenodo. What OpenSheaf adds is an archive that you keep and control, that stores sources (not only PDFs) in a documented layout, that anyone can verify file by file, and that can be combined with other archives into collections and selections without asking any central service.

  <section*|Do I need Zenodo, TeXmacs, git or GitHub?><label|do-i-need-zenodo-texmacs-git-or-github>

  No. The core of the format is an OCFL storage root and a discovery document served over HTTPS. Zenodo, TeXmacs and the website are optional profiles (appendix A). Git and GitHub Pages are convenient ways to keep and serve an archive, but any static web server will do.

  <section*|Can an archive be served straight from GitHub, without GitHub Pages?><label|can-an-archive-be-served-straight-from-github-without-github-pages>

  For tools, yes; for readers, no. The raw file server of a public GitHub repository (<verbatim|https://raw.githubusercontent.com/\<less\>owner\<gtr\>/\<less\>repository\<gtr\>/main/>) serves every file byte for byte and allows cross-origin requests, so the Explorer, and other tools that read archives over HTTP, can read and verify an archive from it. It does not serve a website: it sends pages as plain text and PDFs as downloads, so landing pages are neither shown nor read by search engines, and it serves the pointers of Git LFS, not the files. It is best used as a second location of the archive, beside a GitHub Pages site or another web server: an archive's files may be served at several base URLs, each a location of the same archive. See section 7.4 of <hlink|OpenSheaf archives in git|opensheaf-git-0.1.tm>.

  <section*|Why OCFL? Isn't git enough?><label|why-ocfl-isnt-git-enough>

  Git records history, but its layout is internal to git and its hashes (SHA-1 in most repositories) are not meant for long-term preservation. OCFL (the Oxford Common File Layout) is a published specification for exactly this problem: versioned objects stored as plain files, every file fixed by a SHA-512 digest, readable without any special software, with independent validators, used by research libraries. An OpenSheaf archive can still be kept in git; git just is not part of its integrity.

  <section*|Why DataCite metadata, and not RO-Crate, Dublin Core or JATS?><label|why-datacite-metadata-and-not-ro-crate-dublin-core-or-jats>

  DataCite is the metadata behind DOIs for repositories (Zenodo, arXiv's DOIs, university repositories). It has the relations needed here (versions, preprints and published articles, collections), it maps directly to Zenodo, and its records are harvested by ORCID, OpenAlex and search services. RO-Crate is richer but heavier; Dublin Core is too thin; JATS is for the full text of journal articles.

  <section*|Why JSON and not YAML?><label|why-json-and-not-yaml>

  The metadata files are written by tools and checked by machines. JSON is strict, has one way of writing each value, and is read everywhere without extra libraries. YAML is nicer to edit by hand but converts values silently (dates, version numbers like <verbatim|1.10>, identifiers like <verbatim|2611.14296>).

  <section*|Why is there a discovery document (opensheaf.json)?><label|why-is-there-a-discovery-document-opensheafjson>

  Static web servers cannot list folders, so a program visiting an archive could not find its objects. <verbatim|opensheaf.json>, at the archive's address, lists them with their head versions and digests, names the storage root and the main collection, and says which version of the specification the archive follows. It is only a map: everything it says is checked against the storage root.

  <section*|How are objects identified?><label|how-are-objects-identified>

  A work has a name independent of any archive, the digest of its genesis record, and each history of it an owner; the identifier of an object is its line, written as a <verbatim|sheaf:> URI, <verbatim|sheaf:\<less\>name\<gtr\>:\<less\>owner\<gtr\>>. Identifiers chosen by each archive would clash as soon as one archive kept copies of another's objects; identifiers made from lines never do, so one storage root can hold the lines its owners write and copies of others' side by side. The default layout puts a line at <verbatim|\<less\>owner\<gtr\>/\<less\>name\<gtr\>/>, one folder per owner, so that paths can be computed over plain HTTP; a large archive may instead spread its objects over folders named by parts of the hash of their identifiers. Archives have no identifiers of their own: they are found at their addresses. Readable names (<verbatim|kpz-details>) are <strong|labels> in the discovery document, used for the website's URLs; they are not permanent, and permanent links use <verbatim|sheaf:> URIs, for instance <verbatim|sheaf:\<less\>name\<gtr\>/v3> for document version 3 of the originator's line. Drafts, which have no name yet, are identified locally, as <verbatim|sheaf:draft:\<less\>id\<gtr\>>.

  <section*|What is the difference between a document version and an object version?><label|what-is-the-difference-between-a-document-version-and-an-object-version>

  The document version is the version of the work, what readers see and what gets a DOI: it changes only when the document's own files change (sources, renditions, change note). The object version (<verbatim|v1>, <verbatim|v2>, ...) is OCFL's: it changes at every change of the object, including corrections of the description (adding the DOI of the journal version, fixing an affiliation) and notices about earlier versions.

  <section*|How are versions numbered and ordered?><label|how-are-versions-numbered-and-ordered>

  The owner of a line numbers its document versions itself, from 1 and without gaps, even when an external service numbers them differently: if arXiv still serves only v1, v3 and v4 of a paper, they are document versions 1, 2 and 3, and the arXiv labels are recorded beside them. Versions are normally in the order of their numbers. When an earlier version turns up later, it gets the next number and an explicit <verbatim|history> in <verbatim|object.json> puts it in its place; the current version, the one readers are directed to, is the last in the history. Dates are only information: they may be approximate or unknown, so they never decide the order.

  <section*|What if a version turns out to be wrong?><label|what-if-a-version-turns-out-to-be-wrong>

  Deposit a corrected version, with a change note saying what changed. To warn readers of the earlier version, add a notice about it (for instance an erratum, as text or as a file): notices are later statements about a version, kept with the object and shown with that version, and they never change the version itself.

  <section*|How do collections work across archives? What if an archive disappears?><label|how-do-collections-work-across-archives-what-if-an-archive-disappears>

  A collection lists its members by line (name and owner), the addresses where copies may be found, and a version with the SHA-512 digest of its inventory (the "pin"), or, in a selection, its revisions. Since an inventory fixes all its files, the pin fixes the member completely, and a collection becomes a hash tree over everything it contains. If the member's archive moves or disappears, the member can be fetched from a mirror or any other copy: any copy that matches the pin is the right one. External records, such as a DOI deposit or a Software Heritage snapshot, are witnesses, not copies: they keep the files but not the inventory, so they cannot be checked against the pin, and only tell a reader where the files may be found (#22). A collection also keeps a cached citation of each member, so that it stays readable even if no copy is found.

  <section*|Why both archives and collections?><label|why-both-archives-and-collections>

  They answer different questions. An <strong|archive> is custody: a storage root and a discovery document, served at an address. It says what is kept there and where its files are. An archive hosts the lines of any number of owners and owns none of them by hosting them: every version of a line is signed by its owner, wherever it is stored, and an archive cannot add to another owner's line. A copy kept elsewhere (a mirror) stays its owner's line and can only receive the owner's versions (see "Who owns an object, and what is a branch?").

  A <strong|collection> is a statement: a versioned list of pins, made by a curator, over objects kept anywhere. It says which objects, in which versions, go together: an author's papers, an issue of a journal, a reading list. Collections are objects themselves, so they can be pinned, nested and included in other collections, across archives.

  The two are kept apart because an archive changes at every deposit and holds facts that are nobody's claim (which objects it holds, their heads, its tombstones), while a collection changes by the rules its curator set (adding members, following them as they grow, vetting their versions), and each of its versions can be cited and verified as it stood. When an archive's documents should be cited as they stood, that is what its main collection is for: a catalogue of them, pinned like any other. Archives hold copies, each line possibly in several; collections overlay them, any number of views over any copies.

  <section*|What is the difference between a catalogue and a selection?><label|what-is-the-difference-between-a-catalogue-and-a-selection>

  Keeping and vetting are different acts, and OpenSheaf has a kind of collection for each. A <strong|catalogue> keeps objects whole and is impartial about their versions: each member pins an object with all its versions, and the collection may follow it as its owner adds versions. An author's archive, an institution's repository and a storage site list what they keep in catalogues. A <strong|selection> vets particular revisions: a journal its accepted version, a digest or a review journal the version it read. Each member pins the revision set that was vetted; later versions by the authors are not part of it, and any change of what is vetted (a correction accepted by the editors) is an explicit act of the curator, recorded as a new version of the selection. The <hlink|use cases|use-cases.tm> show both at work.

  <section*|Can I put someone else's paper in my collection?><label|can-i-put-someone-elses-paper-in-my-collection>

  Yes. A reference (a pin) copies nothing and needs no permission. There are two ways to keep a copy, both allowed only if the licence of what is copied permits redistribution (copying by the authors' agreement is still open, #39): a <strong|mirror> copies the whole line, every version, and stays its owner's line (for an institution or a storage site); an <strong|accepted copy> takes the one revision a selection vetted into a line of the selection's owner, where later changes are the curator's acts (for a journal). The licence of a collection (CC0 for the list) never extends to its members.

  <section*|Who owns an object, and what is a branch?><label|who-owns-an-object-and-what-is-a-branch>

  A work has a <strong|name>, the digest of the genesis record written when it is sealed, at its owner's request, before it is first shared. Each history of it has an <strong|owner>: a person, a group or an institution, which decides its versions and signs them. The pair (name, owner) identifies a <strong|line>: one history, with a single writer. A line is its signed versions, wherever they are stored: the archive that keeps a copy is only where it lives, and an owner who moves to another archive continues its lines there.

  An owner is itself an object, named by its own genesis record, which lists its first keys, and whose versions are its <strong|key log>. Each version lists the owner's <strong|current keys>, which sign its documents and collections, with the number of them that must sign, and commits, by their digests, to the <strong|rotation keys> that alone sign the next version of the key log, as in KERI (pre-rotation is provisional, #58). Current keys are in daily use, one on each device; rotation keys are kept apart (on hardware tokens, for instance), used once, and never become current keys; three of them with two required survive the loss of one or the theft of one. Keys can thus be added or retired while the owner stays the same, and what was signed stays signed: a signature that verifies against the key-log version it names is good for ever. A version signed with good keys vouches for every version before it, since its inventory fixes them. A person usually needs one signature; a group of co-authors can share one owner with a threshold, for instance two signatures out of three. If current keys that could reach the threshold may have been exposed, the owner signs with its rotation keys a version of its key log listing them as <strong|exposed>, which a thief holding current keys cannot contest; or it <strong|ends>, by a last version of its key log that may name a successor, which continues the work by branches. A thief holding enough unused rotation keys takes the owner over by signing the next version of its key log, without a fork; the owner can then only end it, and only with its own copies of those keys. Two signed versions of a key log with one number whose key lists differ are a fork, which needs rotation keys stolen or kept after use, and never happens at the first version, which repeats the genesis record: since no one can tell the owner's side from a thief's, the fork ends the owner; an archive keeps the side it saw first and appends a fork record carrying the other, so that every copy shows the fork. Either way the old signatures stay good, but readers trust them only as far as other evidence goes, since nothing tells the owner's signatures from a thief's; archives never add versions that need an exposed key, unless other evidence (a timestamp) dates them before the exposure, and take the lines of an ended owner only from copies, never as new deposits. Every version of every line is signed, and the key logs travel with the objects they sign, so a line can be checked from any copy, even when the archives that served it have gone. An owner may name in its genesis record who answers for it (an ORCID iD, an institution), a keeper fixed with the owner name, which the keeper may confirm in a place only it controls, and which alone may name a successor once a fork has ended the owner; nothing requires it. Drafts are a sandbox: objects of a reserved owner, <verbatim|draft>, kept by one archive, never signed, pinned or copied out of it, and free to be rewritten or deleted. Sealing makes a new object, the first version of the line; the draft's versions are not part of it.

  Anyone can copy a genesis record, so the name alone cannot say whose history is the right one. That is why the owner is part of the identity: a copy continued by another owner is a <strong|branch>, which declares the version it starts from, and an archive cannot pass its own changes off as another owner's, since it cannot sign for it. A branch is a new object: it keeps only the version it starts from, with the parent's inventory, <verbatim|object.json> and signatures as evidence, and, for a branch of a branch, the evidence of its own parents, and adds its own versions (a journal keeping the version it vetted, then its corrections; a co-author carrying the work on). It cannot continue the parent's object, whose inventories record the parent's identifier. A co-author who wants the whole past at hand keeps a copy of the parent's line beside the branch, as a separate object; in git the files they share are stored once. The key logs of the parents' owners travel beside the branch as owner objects, one for each owner, as every key log does, never inside its content. An accepted copy is a branch kept by a selection's owner.

  A branch can be checked without its parent: the genesis record gives the name, the copied inventory gives the parent pin, the files match that inventory, the copied <verbatim|object.json> says whose version it was, and the parent owner's signature, checked against the parent owner's key log, kept beside the branch as an owner object, shows that the version is that owner's; for a branch of a branch, the same holds for each parent in turn, back to the originator's line.

  <section*|Can documents be linked in richer ways (a short account and its proof)?><label|can-documents-be-linked-in-richer-ways-a-short-account-and-its-proof>

  Yes, on top of the format rather than in it. The core keeps only what every archive needs to keep, cite, compose and verify documents. Other relations are built from it: by links inside the documents and DataCite relations, which need nothing more, or by <strong|extensions> (section 2 of the specification), published separately, whose data an object version records in its <verbatim|object.json>, so that tools that know them can follow the relation when they copy, verify or present documents. Extensions never change the core: an archive is read and verified without them. The <hlink|use cases|use-cases.tm> show a journal publishing a short account of a proof whose detailed argument, possibly written with AI, stays online in the version reviewed.

  <section*|Where do signatures and timestamps go, and why not in the version itself?><label|where-do-signatures-and-timestamps-go-and-why-not-in-the-version-itself>

  A signature of an object version, or a timestamp of that signature, can only be made after the version is committed, so it cannot be part of that version: a signature of an inventory cannot be listed in the inventory it signs. Making a new version for each signature would mix evidence with changes of the work, and every completion of a timestamp proof (an OpenTimestamps proof is completed once a Bitcoin block attests it) would be another version. Witnesses are never replaced: a completed proof is a new file beside the pending one.

  OCFL does not allow arbitrary files in an object folder; its <verbatim|logs/> folder is meant for unstructured records of actions and is not covered by digests. The place OCFL provides for data that is not part of any version is the object's <verbatim|extensions/> folder (the registered mutable-head extension keeps its data there). So OpenSheaf puts witnesses in <verbatim|extensions/opensheaf-witnesses/>, where they travel with the object: the owner's signature of every version, required, and timestamps and others' signatures, optional. Timestamps are defined by an extension, <hlink|OpenSheaf timestamps|opensheaf-timestamps-0.1.tm>: RFC 3161 tokens from authorities the owner trusts, OpenTimestamps proofs, or both. An owner that wants its signatures dated, a journal or an institution for instance, adopts it in its key log, from the first version, so that if a key is ever stolen, readers can tell which of its versions were signed before. The extension changes no status: dates are evidence that readers weigh. A single researcher may not need it. Anyone holding a copy may add timestamps later; the earliest is what counts. Witnesses are not covered by the inventory digests, and need not be: a signature is checked against the version it names, which the pins fix, and a timestamp against the signature file it stamps.

  <section*|Why is the HTML version not part of the deposit?><label|why-is-the-html-version-not-part-of-the-deposit>

  Because presentations improve (stylesheets, exporters, fixes) and deposits must not change. The deposit keeps the sources and the PDF; the HTML is regenerated from the sources whenever the presentation changes.

  <section*|How do I withdraw or take down a document?><label|how-do-i-withdraw-or-take-down-a-document>

  To withdraw a document (for instance a retraction), its owner makes a new object version that only marks it withdrawn, with a date and a reason: the content and its history stay, and presentations show the withdrawal. Content is removed only by a <strong|takedown> (by law, for a breach of rights, or because the archive stops keeping it): the object is deleted and a tombstone is left in the discovery document, so that collections pinning it report it as removed rather than corrupt. Every removal is a takedown, so nothing leaves an archive silently. The owners' key logs stay, since other objects need them to be checked; an owner's key log is taken down only for itself. Drafts are neither withdrawn nor taken down: they are simply deleted. OCFL version 2 is expected to add a native mechanism for deleting single files; whether OpenSheaf uses it is open (#32).

  <section*|Can I use "All rights reserved"?><label|can-i-use-all-rights-reserved>

  Yes. Each document carries the licence its authors choose; "All rights reserved" means readers may access the document but not reuse it. The metadata (descriptions, object records, member lists, inventories) is CC0, so that it can be harvested and mirrored freely. On Zenodo, "All rights reserved" is entered as a custom licence.

  <section*|Will Google Scholar find the papers?><label|will-google-scholar-find-the-papers>

  If the archive follows the website profile: each document then has a landing page with the <verbatim|citation_*> meta tags Google Scholar reads, and a PDF on the same host. The profile (appendix A.3) also recommends a sitemap and FAIR Signposting links.

  <section*|How do I check an archive?><label|how-do-i-check-an-archive>

  A verifier validates the JSON files against the schemas in <hlink|schemas/|schemas/>, validates the storage root with a standard OCFL validator (such as <verbatim|ocfl-py>), checks that the discovery document matches the storage root, checks the key logs and the owners' signatures of every version, and resolves and checks the members of the head of every collection (and, optionally, those of earlier versions). It reports errors (breaches of what the specification requires), warnings, and results that are neither (the status of each signature and member, forks, ended owners, withdrawals). The specification (section 14) lists the checks.

  <section*|Is the format stable?><label|is-the-format-stable>

  Not yet: version 0.1 is a draft, and versions before 1.0 may change in incompatible ways. Every file declares the version of the format it follows, so that tools can tell. From version 1.0, minor versions will be backward compatible.

  <section*|Why the name?><label|why-the-name>

  A sheaf is a bundle of papers. In mathematics, a sheaf is the structure in which local pieces glue into a whole: archives kept and verified separately compose into collections.

</body>

<\initial>
  <\collection>
    <associate|page-medium|paper>
  </collection>
</initial>
