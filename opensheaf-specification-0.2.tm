<TeXmacs|2.1.5>

<style|<tuple|notes|notes-meta>>

<\body>
  <notes-header>

  <chapter*|OpenSheaf: an open format for document archives and collections>

  <notes-abstract|Specification, version 0.2 (draft), 22 November 2026. OpenSheaf is a common, open format for archives of scholarly documents and for collections of them, built on the Oxford Common File Layout (OCFL 1.1) and the DataCite Metadata Schema (4.7). The text is licensed under CC BY-SA 4.0; the JSON Schemas are dedicated to the public domain (CC0 1.0).>

  <os-alert|warning|Warning.|<strong|Draft.> Until version 1.0, any revision may change the format in incompatible ways. Version 0.2 is incompatible with <hlink|version 0.1|opensheaf-specification-0.1.tm>, which is kept as published (section 16.1). The text before its rebuild, with the changelog of every revision of the draft, is kept as the <hlink|reference text|reference/opensheaf-specification-0.1-full.md>.>

  <section*|1. Introduction (non-normative)><label|1-introduction-non-normative>

  OpenSheaf is a lean alternative to arXiv and to the usual publication infrastructure. Any author, group or institution can keep an archive of its documents as plain files, served as a static website, checkable by anyone, and composable with other archives:

  <\itemize>
    <item><strong|Sources, not only PDFs.> A deposit keeps the sources of a document with its renditions, so that the archive can be read as a website and in the authoring tool.

    <item><strong|Fixed versions.> Every version is fixed by content digests and never changes once deposited. Corrections are new versions, and the history can be checked from the files alone.

    <item><strong|Owners, not hosts.> Each history of a work belongs to an owner, a person, group or institution holding keys, who signs its versions. An archive only hosts what owners write there, and copies what others wrote elsewhere; it decides nothing about what is authentic.

    <item><strong|Standards, not inventions.> Storage follows OCFL 1.1 and description follows DataCite 4.7. This specification defines only what they leave open: discovery, names, owners and signatures, collections, withdrawal, and profiles for external services and tools.

    <item><strong|Composable collections.> A collection is itself a versioned object. It can include documents and collections of other archives, pinned by digest, so that selections (a seminar, an editorial board, a reading list) compose without copying.

    <item><strong|External services are optional.> Archives may deposit their documents with a DOI service such as Zenodo, publish them as a website, and keep their files in git; the core requires none of these.
  </itemize>

  Two companion texts go with this specification: <hlink|OpenSheaf archives in git|opensheaf-git-0.2.tm>, for archives kept in git repositories, and the <hlink|timestamps extension|opensheaf-timestamps-0.2.tm>, for dating signatures. Questions about the design are answered in the <hlink|FAQ|faq.tm>, and the <hlink|use cases|use-cases.tm> show the format at work.

  The name: a sheaf is a bundle of papers and, in mathematics, the structure in which local pieces glue into a whole, as archives kept and checked separately compose into collections. The home of the format is <verbatim|https://opensheaf.org/>; the first archive is <verbatim|https://mgubi.org/papers/>, whose values appear in the examples.

  <section*|2. Conventions and conformance><label|2-conventions-and-conformance>

  The key words MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, RECOMMENDED, NOT RECOMMENDED, MAY and OPTIONAL are to be interpreted as described in BCP 14 (RFC 2119 and RFC 8174) when, and only when, they appear in all capitals. Sections marked non-normative, examples and notes are informative.

  JSON means RFC 8259 JSON in UTF-8 without a byte order mark. URLs are absolute unless stated otherwise; a relative URL in a JSON file is resolved against the URL of that file. Digests are written in lowercase hexadecimal unless stated otherwise. DOIs are written bare (<verbatim|10.5281/zenodo.123>), without a resolver prefix. Terms are defined where they are first introduced, written <dfn|thus>. Numbers in the JSON files this specification defines are integers, written without a fraction or an exponent, of absolute value at most 2^53 - 1, so that every reader parses them exactly; in a genesis record and in <verbatim|keys.json>, whose values are compared and recomputed byte for byte (sections 5.1 and 6.1), this holds for every number, in the data of extensions included, and a file breaking it is malformed.

  <strong|Conformance classes.> An archive, an object or a program conforms to a class when it meets every MUST and MUST NOT of the sections listed for it:

  <\itemize>
    <item><strong|archive:> sections 3 to 13 and 15;

    <item><strong|collection:> section 8, with the rules on objects of sections 4 to 7;

    <item><strong|owner tool>, a program that seals, signs or keeps an owner's key log: sections 5 to 7, 9, 10 and 15;

    <item><strong|verifier:> sections 14, 15.2 (on untrusted input) and 16 (as a reader), with the rules it checks;

    <item><strong|resolver:> sections 12 and 15.2 (on untrusted input), with sections 5, 6, 7 and 9.3 for checking names, signatures, key logs and branches; a gateway also follows the rules on gateways of section 12.
  </itemize>

  <strong|Profiles.> An archive MAY also follow the profiles of appendix A (Zenodo, TeXmacs, website), and MUST list in its discovery document those it follows.

  <strong|Extensions.> An extension is a specification published apart, named by a URI (RECOMMENDED: the <verbatim|https> URL where it is published), that records what this specification leaves open, so that tools aware of it can act on it. Its data is kept under <verbatim|extensions>, keyed by the extension's name: in <verbatim|object.json> (section 4), where the inventory and the pins fix it, or in <verbatim|keys.json> (section 6), where the owner's signatures fix it, and for the first version of a key log in the genesis record of the owner, which its owner name fixes (section 5.1). An extension MUST NOT change the meaning of what this specification defines, nor relax its requirements: archives, objects and collections are read and verified without knowing any extension, and readers ignore extensions they do not know. The discovery document lists the extensions its objects use (section 3.1). The <hlink|timestamps extension|opensheaf-timestamps-0.2.tm> is one.

  <strong|Schemas.> The JSON files defined here MUST validate against the JSON Schemas of appendix B for their declared format version.

  <section*|3. Archives><label|3-archives>

  An <dfn|archive> is a host of objects, served at a <dfn|base URL> ending with <verbatim|/>. It holds the lines that owners write there (section 7) and copies of lines written elsewhere (section 11). No file of an object names the archive that holds it (section 4.3), and what is authentic is decided by pins and the owners' signatures (sections 4 and 7), never by where a file was fetched; an archive decides only which owners it hosts and how they deposit (a university admitting its staff, a journal its editors). Its base URL is a location, not a name, and may change; an archive's files MAY be served at several base URLs, each a location of the same archive.

  An archive consists of a <strong|discovery document>, REQUIRED (section 3.1); a <strong|storage root>, REQUIRED (section 3.2); <strong|indexes>, RECOMMENDED (section 12); and <strong|presentation files>, OPTIONAL: web pages and other files generated for readers, never authoritative, kept outside the storage root (appendix A).

  <strong|Serving.> The discovery document, the storage root and the indexes MUST be served byte for byte, as stored: no conversion of line endings or character sets, and no compression that changes the bytes delivered after decoding. Archives SHOULD be served over HTTPS, and SHOULD allow cross-origin requests to these files (<verbatim|Access-Control-Allow-Origin: *>), so that tools in a browser can read them. Any static web server will do; an archive kept in git follows <hlink|OpenSheaf archives in git|opensheaf-git-0.2.tm>.

  <strong|Moving.> An archive moving to another site, or served at another, copies its files unchanged, its drafts included (section 10); nothing in them changes, so every pin, signature and witness stays valid. Its base URL, and every location of a copy given elsewhere (in collections, <verbatim|sheaf:> URIs, indexes), is a hint that needs no signature: whatever is fetched from it is checked against pins and signatures, so a wrong or stale location gives a reader nothing, or an older valid copy, never a forged one.

  <subsection*|3.1 The discovery document><label|31-the-discovery-document>

  The <dfn|discovery document> is the JSON file <verbatim|opensheaf.json> at the base URL. Static web servers cannot list folders; this one file makes an archive's objects known. It MUST contain:

  <\itemize>
    <item><verbatim|format>: <verbatim|"opensheaf-archive/0.2">, and <verbatim|specification>: <verbatim|"0.2">;

    <item><verbatim|name>: a readable name of the archive;

    <item><verbatim|storageRoot>: the URL of the storage root, ending with <verbatim|/> (it may be relative);

    <item><verbatim|storageLayout>: its layout, <verbatim|"opensheaf-owner-name-storage-layout"> or <verbatim|"0003-hash-and-id-n-tuple-storage-layout"> (section 3.2);

    <item><verbatim|profiles>: the profiles it follows, from <verbatim|zenodo>, <verbatim|texmacs>, <verbatim|website> (appendix A), possibly none;

    <item><verbatim|owners>: the owners it hosts (section 6), in the order in which the archive presents them (appendix A.3), each with <verbatim|owner>, its owner name, and <verbatim|catalogue>, the identifier of its owner catalogue (section 8.1); empty for an archive that hosts no owner and holds only copies (section 11);

    <item><verbatim|objects> or, in its place, <verbatim|objectPages> (below): every object of the storage root except drafts, each with <verbatim|id> (section 4), <verbatim|kind>, <verbatim|name> and <verbatim|owner> (sections 5 and 6), <verbatim|head> (its OCFL head version), <verbatim|inventorySha512> (the SHA-512 digest of the head inventory, as its checksum file states it) and <verbatim|status> (<verbatim|active> or <verbatim|withdrawn>, the line's status, read from its latest signed version or, in a copy without one, from its head, section 13.1), and OPTIONALLY a <verbatim|label>.
  </itemize>

  It SHOULD contain <verbatim|contact>, a URI, and <verbatim|extensions>, the names of the extensions its objects use (section 2). It MAY contain <verbatim|drafts>, the drafts it chooses to show, with <verbatim|id>, <verbatim|kind> and <verbatim|head>, as unfinished work on which nothing may rely (section 10); <verbatim|indexes>, which maps each index kept to the length of the prefixes of its files (section 12.5); and <verbatim|feed>, the URL of an Atom feed of new object versions. It MUST contain <verbatim|tombstones> once an object has been taken down (section 13.3).

  The discovery document is rewritten whenever an object is added or changed. It is a map, not a witness: everything it states about objects MUST agree with the storage root, which verifiers check (section 14), and it lists what the archive holds, not every line an owner has elsewhere.

  <strong|Labels.> A <dfn|label> is a short readable name an archive MAY give a line it holds, for readable URLs on its website: it matches <verbatim|^[a-z0-9]+(-[a-z0-9]+)*$>, has at most 64 characters, and is unique in the discovery document. It is the archive's choice, may change, and is not an identifier; permanent links use <verbatim|sheaf:> URIs (section 12). Labels SHOULD be chosen by the depositor, not derived from the title.

  <strong|Private archives.> An archive need not be public. Kept in a private repository or on its owner's machine, or served only to some readers (a journal behind a paywall), it follows this specification all the same, and whoever has its files deposits, pins and verifies in it as in any other. An archive serves all its lines or none: its discovery document lists every object of its storage root, and no archive serves only part of its lines. An owner who wants to publish some of the lines it keeps privately copies them into a public archive (section 11): a copy of a line is the same line, with the same inventories, signatures and witnesses, so that pins made before stay valid. A version that no reader can reach is reported unavailable (section 8.5).

  <strong|Pages.> An archive with many objects lists them in pages: in place of <verbatim|objects>, <verbatim|objectPages>, a non-empty list of the paths of page files, relative to the discovery document (no scheme, no leading <verbatim|/>, no <verbatim|.> or <verbatim|.<no-break>.> segment). A page is a JSON file with <verbatim|format>, <verbatim|"opensheaf-objects/0.2">, and <verbatim|objects>, a non-empty list of entries of the form above; every object is in exactly one page, and labels are unique across the pages. Wherever this specification speaks of <verbatim|objects>, it means the entries of the pages for an archive that pages them. Pages SHOULD group objects by a prefix of their name, so that a deposit rewrites one page, and hold about a thousand entries each (some 0.5 MB); tools SHOULD page <verbatim|objects> beyond about a thousand objects. Readers MUST accept both forms.

  <subsection*|3.2 The storage root><label|32-the-storage-root>

  The <dfn|storage root> is an OCFL 1.1 storage root at the URL <verbatim|storageRoot>, holding the archive's objects (section 4). Since OCFL allows in it only the folders that lead to objects, and extensions, it SHOULD be a dedicated folder (by convention <verbatim|ocfl/>), and presentation files MUST NOT be placed in it. It MAY contain, as loose files, copies of the OCFL specification and of this one. Its storage layout is the one <verbatim|storageLayout> names in the discovery document, which is authoritative. OCFL's <verbatim|ocfl_layout.json>, OPTIONAL in OCFL, may name only a layout registered as an OCFL extension (OCFL 1.1, section 4.1), and is therefore present for the hashed layout only:

  <\itemize>
    <item><strong|The owner-name layout>, <verbatim|opensheaf-owner-name-storage-layout>, the default, defined here, and not registered as an OCFL extension. The object whose identifier is <verbatim|sheaf:\<less\>name\<gtr\>:\<less\>owner\<gtr\>> (section 4) is at <verbatim|\<less\>owner\<gtr\>/\<less\>name\<gtr\>/>, and a draft <verbatim|sheaf:draft:\<less\>id\<gtr\>> at <verbatim|draft/\<less\>id\<gtr\>/>; any other identifier is an error. An owner's object is thus at <verbatim|\<less\>owner\<gtr\>/\<less\>owner\<gtr\>/>, and the folder of an owner holds its key log and every line of it in the archive, so that an owner moving elsewhere copies one folder. The layout has no parameters. The storage root MUST NOT contain <verbatim|ocfl_layout.json>, whose <verbatim|extension> would not be a registered extension name; it SHOULD contain instead the plain text file <verbatim|opensheaf-owner-name-storage-layout.md>, which describes the layout, for instance as <verbatim|Lines at \<less\>owner\<gtr\>/\<less\>name\<gtr\>/, drafts at draft/\<less\>id\<gtr\>/: the owner-name layout of the OpenSheaf specification 0.2, section 3.2>, as OCFL allows for documenting local extensions (OCFL 1.1, sections 4.1 and 4.5).

    <item><strong|The hashed layout>, for large archives: OCFL's <verbatim|0003-hash-and-id-n-tuple-storage-layout> with its default parameters (<verbatim|sha256>, tuples of 3 characters, 3 tuples), which a configuration file, if present, MUST NOT change; the storage root MUST contain <verbatim|ocfl_layout.json>, with <verbatim|extension> <verbatim|0003-hash-and-id-n-tuple-storage-layout> and a <verbatim|description>. An object is at <verbatim|\<less\>t1\<gtr\>/\<less\>t2\<gtr\>/\<less\>t3\<gtr\>/\<less\>encoded id\<gtr\>/>, where <verbatim|\<less\>t1\<gtr\>>, <verbatim|\<less\>t2\<gtr\>>, <verbatim|\<less\>t3\<gtr\>> are the first three groups of three characters of the hexadecimal SHA-256 digest of its identifier, and <verbatim|\<less\>encoded id\<gtr\>> is the identifier percent-encoded as the extension says (every character but <verbatim|A-Z>, <verbatim|a-z>, <verbatim|0-9>, <verbatim|-> and <verbatim|_>, in lowercase hexadecimal, <verbatim|%3a>), shortened, when longer than 100 characters, to its first 100 characters, <verbatim|-> and the full digest; identifiers of lines are always shortened so (appendix C). Readers compute the path; they never decode it.
  </itemize>

  Archives SHOULD use the owner-name layout, unless one folder per owner or per name becomes impractical (tens of thousands of lines, fewer in a git repository). The layout is chosen when the archive is created and SHOULD NOT be changed: pins stay valid, since readers compute paths from <verbatim|storageLayout>, but every URL into the storage root changes.

  <strong|Open question.> Registering the owner-name layout as an OCFL community extension, so that <verbatim|ocfl_layout.json> can name it (#59).

  <section*|4. Objects><label|4-objects>

  An <dfn|object> is an OCFL 1.1 object in a storage root. Its <dfn|kind>, given by its <verbatim|object.json> and never by its identifier, is <verbatim|document>, one work (an article, notes, a thesis, a book) with its sources and renditions; <verbatim|collection>, a list of members (section 8); or <verbatim|owner>, the key log of an owner (section 6).

  <strong|Identifier.> The <dfn|identifier> of an object, its OCFL <verbatim|id>, is <verbatim|sheaf:\<less\>name\<gtr\>:\<less\>owner\<gtr\>>, the name of the work (section 5) and the owner name of its line's owner (section 6), which <verbatim|object.json> records as <verbatim|name> and <verbatim|owner>. It names the line (section 7), in every archive. A branch is a new object with its own identifier (section 9); a draft is <verbatim|sheaf:draft:\<less\>id\<gtr\>> (section 10). The identifier MUST be unique in the storage root, and that of a sealed object MUST NOT be reused there, also after a takedown (section 13).

  <strong|Versions.> An <dfn|object version> is an OCFL version of an object (<verbatim|v1>, <verbatim|v2>, ...): every change of the object makes one. Once made, no object version, and no file of the object's witness folder (section 7.2), is changed or removed, except: in a draft, which may be rewritten or deleted (section 10); and by a takedown, which deletes the whole object (section 13.2). A <dfn|document version> is a version of the work, a positive integer numbered by the owner of the line and recorded in <verbatim|object.json> and <verbatim|datacite.json>; it changes only when the document's own files change (section 4.2), so several object versions may hold one document version, with different descriptions or notices.

  <strong|Pins.> A <dfn|pin> is the pair (object version, SHA-512 digest of that version's inventory file, as its checksum file states it). An inventory records the digests of the files of its version and of every earlier one, and the <verbatim|object.json> of every sealed version after the first records the digest of the inventory file of the version before (<verbatim|previous>, section 4.3), so a pin fixes the object up to that version, the bytes of every earlier inventory included, in any copy. Collections (section 8), branches (section 9) and <verbatim|sheaf:> URIs (section 12) refer to object versions by pins, and pin only signed versions (section 7). In a valid object the checksum file states the digest of the bytes of its inventory file (OCFL 1.1), so the two are the same; tools write the digest the checksum file states, and verifiers check both, a difference being an error (section 14.2).

  <subsection*|4.1 Common rules><label|41-common-rules>

  Every object MUST be a valid OCFL 1.1 object, and:

  <\itemize>
    <item>its inventories MUST use the digest algorithm <verbatim|sha512>; they MAY also record MD5 and SHA-256 digests in <verbatim|fixity> (the Zenodo profile requires MD5, appendix A);

    <item>every version directory MUST contain the inventory as of that version, with its checksum file, so that each version can be pinned and fetched on its own;

    <item>version directories MUST NOT be zero-padded (<verbatim|v1>, not <verbatim|v001>);

    <item>digests in inventories (<verbatim|manifest>, <verbatim|fixity>, <verbatim|state>) and in checksum files MUST be in lower case, which OCFL allows but does not require, so that a digest is compared as a string and quoted the same way everywhere (pins, <verbatim|previous>, signatures, the discovery document);

    <item>logical paths MUST be in UTF-8 and Unicode normalisation form C, and MUST NOT begin or end with <verbatim|/>, or contain empty, <verbatim|.> or <verbatim|.<no-break>.> segments, or <verbatim|\\>.
  </itemize>

  <strong|Deposits.> Each version in the inventory MUST have a <verbatim|user> with a <verbatim|name>, SHOULD give its <verbatim|address> (an ORCID iD, a <verbatim|mailto:> URI or another URI identifying the depositor), and MUST have a <verbatim|message> describing the change, except the first version of a key log, which has neither (section 6.1). The <verbatim|created> date and <verbatim|user> of an object version record its <dfn|deposit>, not repeated in <verbatim|object.json>; the deposit of a document version is that of the first object version holding it.

  <strong|Content.> Every object version MUST contain, at the top level of its content, <verbatim|object.json> (section 4.3); <verbatim|datacite.json> (section 4.4), except in an owner object; and the genesis record <verbatim|genesis.json> (section 5), except in a draft. Every version of a branch also holds the evidence of its branch point, in the folder <verbatim|parent/>: <verbatim|parent/inventory.json>, <verbatim|parent/object.json>, <verbatim|parent/signatures/> and, for a branch of a branch, <verbatim|parent/parent/> (section 9). The genesis record and this evidence are the <dfn|identity files> of the object, never files of the document's own. The names of every file this specification defines at the top level of the content (<verbatim|object.json>, <verbatim|datacite.json>, <verbatim|genesis.json>, <verbatim|members.json>, <verbatim|keys.json>, <verbatim|forked>, <verbatim|parent>) are reserved for those files. A collection version also holds <verbatim|members.json> (section 8). An owner object holds <verbatim|genesis.json> and <verbatim|keys.json> (section 6), a fork record <verbatim|forked/> instead of <verbatim|keys.json> (section 6.3), and no <verbatim|datacite.json>; it has no document versions, and is never withdrawn or branched. Signatures and other witnesses are kept outside every version, in the object's extension folder <verbatim|extensions/opensheaf-witnesses/> (section 7).

  <subsection*|4.2 Documents and document versions><label|42-documents-and-document-versions>

  A document version holds, at the top level of its content, besides the files of section 4.1:

  <\itemize>
    <item>the <dfn|sources>: the main source and every file needed to produce the renditions that is not part of the toolchain (images, bibliography databases, local style files); they SHOULD be flat (no sub-folders) when possible;

    <item>the <dfn|renditions>, files produced from the sources (a PDF, an EPUB): OPTIONAL, but RECOMMENDED, at least a PDF for a document meant to be read and cited;

    <item>the files of its notes, if any (section 4.3).
  </itemize>

  The sources, the renditions and the change note (<verbatim|changes>, section 4.3) are the document's own files. A collection (section 8) is a document whose source is its member list: its own files are <verbatim|members.json>, its renditions, if any, and its change note, and the rules of this section hold for it as for any document. HTML versions and other presentation files SHOULD NOT be deposited.

  <strong|Numbering.> The owner of the line numbers document versions from 1, without gaps, independently of any external numbering: a work whose versions 1, 3 and 4 are on arXiv has document versions 1, 2 and 3. External labels (arXiv's <verbatim|v3>) are recorded in <verbatim|external> (section 4.3); presentations SHOULD show them with the document version. Branches number as section 9 says.

  <strong|New versions.> The own files of a document version are compared as pairs of a logical path and a digest, so that a renamed file is a change. A new document version is made exactly when the document's own files differ from those of the current version (a file added, changed, renamed or removed, the change note included), except when a version without sources is completed (below). An object version that holds an existing document version (a description-only version, a completion) holds exactly its own files. Own files that are those of an earlier document version other than the current one, deposited again, are a <dfn|revert>: a new document version, with the next number, whose change note SHOULD name the version it returns to. For a collection, any change of <verbatim|members.json> is thus a new document version: a member added or removed, a pin moved, a reorder, a citation refreshed (section 8.2). A version not public at the time (the manuscript submitted to a journal), deposited later, is a document version like any other; a version published by someone else (the journal's version of record) is not, and is linked by a relation (section 4.4).

  <strong|Description-only versions.> A <dfn|description-only version> holds an existing document version with its own files unchanged, and changes only the description of the object: <verbatim|datacite.json> (a DOI, a link to the published article, the licence in <verbatim|rightsList>) and, in <verbatim|object.json>, <verbatim|stage>, <verbatim|agreement>, <verbatim|licence>, <verbatim|extensions>, the state of the object (<verbatim|status> and <verbatim|withdrawal>, section 13), its notices and its history (below); it MAY add entries to <verbatim|external>, which stay, unchanged, in every later object version holding that document version. The fields that say what the files of a document version are (<verbatim|mainSource>, <verbatim|sourceFormat>, <verbatim|sourcesMissing>, <verbatim|renditions> and <verbatim|toolchain>, section 4.3) belong to the document version, like its change note, and are the same in every object version holding it, except as a completion adds to them (below): a wrong one is corrected by a notice or by a new document version. A description-only version MAY hold any document version, so that an earlier one can be described, a collection's earlier member list included; tools otherwise hold the current version. If the object has <verbatim|history>, the entry of that document version becomes the new object version.

  <strong|Completion.> A document version deposited with <verbatim|sourcesMissing> (section 4.3) MAY be completed, keeping its number, by object versions that add its sources, possibly with renditions made from them (named in <verbatim|mainSource>, <verbatim|sourceFormat>, <verbatim|renditions> and <verbatim|toolchain>), and change or remove no file of the version. It keeps <verbatim|sourcesMissing> until the sources are complete; the object version that completes them names the main source and drops <verbatim|sourcesMissing>, and the version is then fixed like any other.

  <strong|History.> The <dfn|history> of a document is the order of its document versions in the history of the work: the order of their numbers, unless <verbatim|object.json> has <verbatim|history>, the list, in that order, of the last object version holding each document version. A document version deposited out of order (an earlier version found later) gets the next number like any other, and is placed earlier in the history by <verbatim|history>, which the object version depositing it writes: writing <verbatim|history> is how a deposit out of order is recorded, and a version deposited without it is the last of the history, and so the current version (a later description-only version MAY then write <verbatim|history> to place it). Once written, every later object version MUST keep <verbatim|history>. A version whose place is unknown goes just before the current version, and its change note SHOULD say so. The history is read from the latest signed version of the line (section 7); earlier object versions keep it as it was then known. Dates never order document versions.

  <strong|Current version.> The <dfn|current version> of a document is the last of its history. The latest signed version may hold another document version, deposited out of order or newly described; the current version stays where it was. Landing pages, indexes and citations use the current version.

  <strong|Notices.> A <dfn|notice> is a statement about a document version made after it, since the version cannot change (that a theorem of version 2 is wrong as stated, and corrected in version 3). Notices are added to <verbatim|notices> by description-only versions, at its end, and stay, unchanged and in the same order, at the start of <verbatim|notices> in every later object version (for a branch taking a new branch point, see section 9.4). A notice is thus identified by its position: <strong|notice <em|k>> of a line is the <em|k>-th entry of <verbatim|notices>, counted from 1, in every version that holds it. A notice is corrected or withdrawn only by a later notice about the same document version that names it in <verbatim|replaces> (section 4.3), and saying what it corrects or that it withdraws it; each notice is replaced at most once. The <dfn|current notices> about a document version are its notices that no notice replaces, read from the latest signed version of the line (section 7.3); a withdrawing notice is itself current, so that readers see what was said and taken back. Presentations showing a document version SHOULD show the current notices about it, and MAY show those replaced, as such. The <verbatim|date> of a notice is the date its author issued it, which may be earlier than its deposit (an erratum printed before); the deposit is that of the object version that added it (section 4.1), and the <verbatim|date> SHOULD NOT be later.

  <subsection*|4.3 The object record: object.json><label|43-the-object-record-objectjson>

  Every object version MUST contain <verbatim|object.json>, the record of the object's identity, content, versions and state; it names no archive. It MUST contain:

  <\itemize>
    <item><verbatim|format>: <verbatim|"opensheaf-object/0.2">, and <verbatim|specification>: <verbatim|"0.2">;

    <item><verbatim|kind>: <verbatim|document>, <verbatim|collection> or <verbatim|owner>;

    <item><verbatim|status>: <verbatim|active> or <verbatim|withdrawn> (section 13.1), always <verbatim|active> for an owner or a draft;

    <item><verbatim|documentVersion>, for a document or a collection: equal to <verbatim|version> in <verbatim|datacite.json>;

    <item>in every version of a line, <verbatim|name> and <verbatim|owner> (sections 5 and 6), and in a branch <verbatim|parent>, its branch point (section 9); a draft has none of them;

    <item>in every version of a line after the first, <verbatim|previous>: the SHA-512 digest of the inventory file of the version before, in lowercase hexadecimal, as its checksum file states it, the digest of its pin (section 4), whatever the version changes (a description-only version, a withdrawal, a fork record of a key log, sections 4.2, 13.1 and 6.3). A first version has none, since sealing starts a new line (section 10.2), and neither has the computed first version of a key log (section 6.1), the first version of a branch (section 9.2) or a draft, whose versions may be rewritten (section 10.1).
  </itemize>

  <strong|The inventory chain.> Signing a version fixes, through <verbatim|previous>, the bytes of the inventory file of every version before it, not only the files they record: a version vouched for by a later signed version (section 7.3) is fixed byte for byte, and its pin is as reliable as that of a version signed directly (#46). Two versions of one number with the same <verbatim|previous> share their history; with different ones, they differ in an earlier version too.

  An owner object has only these fields, <verbatim|previous> included, and MAY have <verbatim|extensions> (below), though data concerning its key log goes in <verbatim|keys.json> or, for the first version, the owner's genesis record (sections 5.1 and 6.1).

  A <dfn|note> is an object with <verbatim|text>, a short plain text, or <verbatim|path> and <verbatim|mediaType>, a file of the content of the same object version, or both.

  A document MUST have <verbatim|mainSource> (a logical path) and <verbatim|sourceFormat> (its media type), and SHOULD have <verbatim|renditions>, a list of <verbatim|path> (a logical path) and <verbatim|mediaType>, and <verbatim|toolchain>, a list of tools with <verbatim|name>, <verbatim|version> and, OPTIONALLY, <verbatim|packages>, enough to reproduce the renditions. A document version without its sources has instead <verbatim|sourcesMissing>, a note saying why ("arXiv keeps only the PDF of this version"), and at least one rendition; a rendition is never presented as a source. A document MAY have:

  <\itemize>
    <item><verbatim|changes>: a note saying what changed in this document version, deposited with it (like arXiv's comments);

    <item><verbatim|stage>: the stage of this document version, with <verbatim|scheme> and <verbatim|value>; for articles the RECOMMENDED scheme is <verbatim|NISO-JAV> (NISO Journal Article Versions: <verbatim|AO>, <verbatim|SMUR>, <verbatim|AM>, <verbatim|P>, <verbatim|VoR>, <verbatim|CVoR>, <verbatim|EVoR>), and other content uses other schemes (editions, software releases), named by the archive;

    <item><verbatim|history> and <verbatim|notices> (section 4.2), each notice a note with the <verbatim|documentVersion> it is about and a <verbatim|date>, the date it was issued, and OPTIONALLY <verbatim|replaces>, the number of the earlier notice it corrects or withdraws;

    <item><verbatim|licence>: a note with the full text or terms of the licence (for licences without an SPDX identifier); <verbatim|rightsList> in <verbatim|datacite.json> remains the description for readers.
  </itemize>

  A collection has no <verbatim|mainSource>, <verbatim|sourceFormat>, <verbatim|sourcesMissing> or <verbatim|licence>, since its source is <verbatim|members.json> and its own files are under CC0 (section 8.6); it MAY have the other fields of a document, its renditions holding no part of its members. A document or a collection MAY have:

  <\itemize>
    <item><verbatim|agreement>: a minimal record that the authors agreed to the deposit and the licence: <verbatim|by> (names only), <verbatim|date> and <verbatim|method> ("by e-mail"), all REQUIRED. It MUST NOT contain e-mail addresses, correspondence or signatures of persons;

    <item><verbatim|external>: the external records of this version, each with <verbatim|role> (<verbatim|deposit> for a deposit of this version made under a profile, appendix A; <verbatim|source> for the record it was imported from), <verbatim|service> (its name) and <verbatim|record> (its URL), all REQUIRED, and OPTIONALLY <verbatim|doi>, <verbatim|label> (the service's label for the version, such as <verbatim|v3>) and <verbatim|files>, the files kept there but not in the content (a deposit's source archive) or received from there, as received, each with <verbatim|name> and <verbatim|sha512> (REQUIRED), <verbatim|md5> and <verbatim|bytes>;

    <item><verbatim|withdrawal>, REQUIRED when <verbatim|status> is <verbatim|withdrawn>: a <verbatim|date> and a <verbatim|reason>, a note (section 13);

    <item><verbatim|extensions>: the data of extensions (section 2), keyed by the names of the extensions.
  </itemize>

  <subsection*|4.4 The description: datacite.json><label|44-the-description-datacitejson>

  Every object version except in an owner object MUST contain <verbatim|datacite.json>, the DataCite 4.7 properties in the form of the <verbatim|attributes> of a DOI in the DataCite REST API: the authoritative description of the object version. It MUST contain <verbatim|titles>, <verbatim|creators> (with <verbatim|name> and <verbatim|nameType>; personal names SHOULD also have <verbatim|givenName> and <verbatim|familyName>), <verbatim|publicationYear>, <verbatim|types> (with <verbatim|resourceTypeGeneral>), <verbatim|version> (the document version as a decimal string without leading zeros, <verbatim|"3">) and <verbatim|publisher>. It SHOULD contain:

  <\itemize>
    <item><verbatim|descriptions>, with an <verbatim|Abstract>, and <verbatim|subjects>, with a <verbatim|subjectScheme> (MSC2020 is common in mathematics);

    <item><verbatim|dates> (below);

    <item><verbatim|rightsList>: licences and rights statements. An entry with <verbatim|rightsIdentifier> or <verbatim|rightsUri> is a <dfn|licence>: one with an SPDX identifier has it in <verbatim|rightsIdentifier>, in lower case, with <verbatim|rightsIdentifierScheme> <verbatim|SPDX>, and SHOULD have the licence URL; one without has its name in <verbatim|rights> and the URL identifying it in <verbatim|rightsUri> (for arXiv's default licence, <verbatim|http://arxiv.org/licenses/nonexclusive-distrib/1.0/>). An entry with neither is a <dfn|rights statement>, such as "All rights reserved";

    <item><verbatim|language>, <verbatim|formats> (the media types of sources and renditions) and <verbatim|sizes>;

    <item>identifiers of creators (ORCID) and affiliations (ROR), where they exist;

    <item><verbatim|relatedIdentifiers> (below).
  </itemize>

  <verbatim|publisher> is the owner of the line, the body behind it (a journal, an institution), or the service registering the version's DOI (appendix A). <verbatim|publisher> and <verbatim|affiliation> SHOULD be objects, with <verbatim|name> and, where available, an identifier; readers MUST also accept strings. <verbatim|doi> and <verbatim|url> are present when the version has a DOI. <verbatim|resourceTypeGeneral> is from DataCite's list (<verbatim|Collection> for collections), with <verbatim|resourceType> for detail ("Lecture notes"). An author's versions of a work not published elsewhere, the accepted manuscript included, are <verbatim|Preprint>; <verbatim|stage> in <verbatim|object.json> gives their stage.

  <strong|Mathematics.> Titles and abstracts are plain text, in which mathematics MAY be written in LaTeX between single dollar signs (<verbatim|$\\Phi^4_3$>; a literal dollar is <verbatim|\\$>). It SHOULD use only the mathematical commands of LaTeX with <verbatim|amsmath> and <verbatim|amssymb>, which common renderers display without the document's preamble. Tools importing them SHOULD replace the authors' macros (<verbatim|\\R>) with standard LaTeX when their definitions are known, and otherwise keep them; they MUST NOT invent definitions.

  <strong|Dates.> Each date type has one meaning:

  <\itemize>
    <item><verbatim|Issued>: the first public appearance of the work, anywhere, the same in every version; RECOMMENDED, and tools importing works published elsewhere SHOULD set it;

    <item><verbatim|Available>, SHOULD be present: when this document version was first made available, anywhere: its date on the service it was imported from, if it appeared there first, or else its deposit (section 4.1); a version is available from its deposit whether the archive is public or not (section 3.1), and the date does not change when the version is later made public;

    <item><verbatim|Updated>: the date of the latest description-only version holding this document version, if any;

    <item><verbatim|Created> (when a version deposited later, a manuscript found years after, was written), <verbatim|Submitted> and <verbatim|Accepted>, OPTIONAL;

    <item><verbatim|Withdrawn>: equal to <verbatim|withdrawal.date> in <verbatim|object.json>.
  </itemize>

  Dates MAY be approximate, as DataCite allows (<verbatim|2019-03>, <verbatim|2018/2019>), with <verbatim|dateInformation> saying why; unknown dates are omitted.

  <strong|Relations.> In <verbatim|relatedIdentifiers>:

  <\itemize>
    <item>a document version with a DOI SHOULD have <verbatim|IsVersionOf> the concept DOI of the document, and <verbatim|IsNewVersionOf> the DOI of the version before it in the history, if it has one; after a version is deposited out of order, the relation of the version following it MAY be corrected by a description-only version;

    <item>the same work published elsewhere SHOULD be linked with <verbatim|IsIdenticalTo> (same content, such as an arXiv version) or <verbatim|IsVariantFormOf> (different content or form);

    <item>a preprint SHOULD be linked to its published article with <verbatim|IsVersionOf> the article's DOI, as DataCite recommends, by a description-only version;

    <item>the sources MAY be linked to a software archive snapshot (<verbatim|SWHID>);

    <item>a <verbatim|sheaf:> URI (section 12) is recorded in its canonical form as a <verbatim|URL>, provisionally, until the scheme is registered (#36);

    <item>a document MUST NOT name the collections that include it: membership is stated only by collections, so that including a document never changes it.
  </itemize>

  <section*|5. Names><label|5-names>

  A work, and an owner, has a <dfn|name>: a digest of its genesis record, the same in every archive and copy, which anyone holding a copy can check. An owner's name is its owner name (section 6).

  <subsection*|5.1 The genesis record><label|51-the-genesis-record>

  The <dfn|genesis record> is the JSON file <verbatim|genesis.json> at the top level of the content, written when a work is sealed (section 10) or an owner created (section 6). It contains:

  <\itemize>
    <item><verbatim|format>: <verbatim|"opensheaf-genesis/0.2">;

    <item><verbatim|kind>: <verbatim|document>, <verbatim|collection> or <verbatim|owner>, the <verbatim|kind> of the object;

    <item><verbatim|created>: the date and time it was written, in UTC (<verbatim|2026-03-02T09:14:00Z>);

    <item><verbatim|nonce>: at least 128 bits from a cryptographically secure random generator, in lowercase hexadecimal;

    <item>for a document or a collection, <verbatim|originator>: the owner name of the owner of the first line (section 5.3);

    <item>for an owner, instead, <verbatim|keys> and <verbatim|threshold>, its first current keys and how many must sign, and <verbatim|next> and <verbatim|nextThreshold>, the digests of its first rotation keys and how many must sign the second version of its key log, from which the first version of its key log is computed (section 6.1); and, OPTIONALLY, <verbatim|keeper>, a list of one URI, the person or institution who answers for the owner, fixed with its owner name (section 6.6), and <verbatim|extensions>, the data of extensions concerning its key log as of the first version (section 6.1).
  </itemize>

  The genesis record MUST be part of every object version of the object and of its branches (section 9), byte for byte. It MUST be in UTF-8 without a byte order mark, and SHOULD have LF line ends. Since the name is the digest of its bytes as stored, tools MUST NOT rewrite or re-serialise it. A tool MUST NOT copy a genesis record into an object that is not a copy or a branch of the work it was written for, nor reuse a nonce.

  <subsection*|5.2 Computing a name><label|52-computing-a-name>

  Algorithm k, for k from 0 to 15, takes the SHA-256 digest of the seed <verbatim|opensheaf-name-\<less\>k\<gtr\>> (ASCII, k in decimal, followed by a line feed) followed by the bytes of <verbatim|genesis.json>, and writes it in lowercase base32 (RFC 4648, without padding): 52 characters, the last of which holds the last bit of the digest and four zero bits, which are set to k. A name thus matches <verbatim|^[a-z2-7]{52}$>, and its last character gives its algorithm (<verbatim|a> or <verbatim|q> for algorithm 0), so names made by different algorithms never coincide. Names are compared as strings, never decoded: a name of algorithm 1 to 15 sets bits that RFC 4648 requires to be zero, so it is not canonical base32, and a strict decoder may reject it. <verbatim|object.json> records a line's name as <verbatim|name>; appendix C gives examples.

  A genesis record thus has 16 names of one work (section 12 searches for a work by all of them). Its <dfn|genesis name>, made by algorithm 0, is the same for every line of the work. Every line is named by its genesis name, except a branch renamed after a clash, and branches named after it (section 5.3).

  <subsection*|5.3 Origin and clashes><label|53-origin-and-clashes>

  <strong|Origin.> The <dfn|originator> of a work is the owner its genesis record names in <verbatim|originator>; an owner is its own originator. The originator's line is the origin of the name: it has no parent, and its first version MUST be signed by the originator (section 7), except the first version of a key log, which is computed from the genesis record (section 6.1). Every other line of the genesis record is a branch and MUST declare its parent (section 9); a line of another owner that declares none is not a valid line of the name. A tool refuses a branch owned by the originator, which takes in another line's work by depositing it (section 9.5).

  <strong|Clashes.> An owner has one line of each name, and no two objects of a storage root have the same line (section 4). A clash can arise only when a line is made, and the tool that makes it resolves it against the archive where it writes and the lines of the same owner it knows elsewhere that are signed (section 7):

  <\itemize>
    <item><strong|Sealing.> If the line is taken, the tool draws a new nonce, so that an originator's line is always named by algorithm 0. A work sealed elsewhere that meets, when deposited, a taken line with another genesis record (a collision) is refused, and its owner seals it anew; with the same genesis record, it is a copy (below), or a reused record (section 5.4).

    <item><strong|Branches.> A branch is named by <verbatim|parent.name>, unless its line is taken by another line of its owner, in which case it is named by the smallest algorithm number greater than that of <verbatim|parent.name> that gives a line free for its owner, and <verbatim|parent> keeps the parent's name; if none up to 15 is free, the branch is refused. When the line taken is the owner's own branch of the same parent line, section 9.4 says when the owner gives that branch a new branch point instead.

    <item><strong|Copies.> A copy whose line is taken in a storage root by a different history of it is a fork of the line (section 7.4).

    <item><strong|Takedowns.> A line stays taken in an archive after a takedown (section 13.3).
  </itemize>

  Lines of different owners never clash. A branch is always written with its owner part (section 12.1).

  <subsection*|5.4 Reused genesis records><label|54-reused-genesis-records>

  A genesis record reused for another work gives no valid line: the originator's line needs the originator's signature, and every other line needs a chain of signed parents back to it (section 9). A second history that the originator signs under its own record is a fork of its line (section 7).

  When an object is created or deposited, an archive that holds an object or a tombstone with the same genesis record, compared by genesis name (<verbatim|genesisName> of a tombstone, section 13), MUST refuse it unless it is signed by the originator (the originator's line) or is a branch whose branch points are confirmed back to the originator's line (section 9.3).

  A work refused for a reused genesis record is sealed anew, under a genesis record of its own, and its <verbatim|datacite.json> MAY relate it to the version it was refused as (<verbatim|IsIdenticalTo> or <verbatim|IsVariantFormOf>, section 4.4). No record wraps another: a genesis record never names another one.

  <section*|6. Owners><label|6-owners>

  An <dfn|owner> is a keyed identity: a person, a group or an institution that decides the versions of its lines and signs them (section 7), wherever they are stored. It is an object of kind <verbatim|owner> (section 4), named by its genesis record (section 5): its <dfn|owner name> is the name of that record, the name that genesis records (<verbatim|originator>), <verbatim|object.json> (<verbatim|owner>, and <verbatim|owner> in <verbatim|parent>) and <verbatim|sheaf:> URIs (section 12) record. The owner object is the owner's own line, <verbatim|(owner name, owner name)>, at <verbatim|\<less\>owner\<gtr\>/\<less\>owner\<gtr\>/> in the owner-name layout (section 3.2). Its object versions are the owner's <dfn|key log>.

  <subsection*|6.1 The key log><label|61-the-key-log>

  Every version of the key log, except a fork record (section 6.3), holds, besides the files of section 4.1, the file <verbatim|keys.json>, with:

  <\itemize>
    <item><verbatim|format>: <verbatim|"opensheaf-keys/0.2">;

    <item><verbatim|keys>, except in an ending version (section 6.3): the owner's <dfn|current keys>, which sign the versions of its lines (section 7), at least one, each distinct, each an Ed25519 key written as a <verbatim|did:key> URI (W3C CCG; multibase base58btc, multicodec <verbatim|ed25519-pub>, code <verbatim|0xed>, written as the varint bytes <verbatim|0xed 0x01>);

    <item><verbatim|threshold>, with <verbatim|keys>: the number of distinct current keys that must sign a version of a line, a positive integer;

    <item><verbatim|next>, except in an ending version (section 6.3): the digests of the <dfn|rotation keys> that sign the next version of the key log, at least one, each distinct, each the lowercase base32 (RFC 4648, without padding) SHA-256 digest of a <verbatim|did:key> URI, as UTF-8, of 52 characters;

    <item><verbatim|nextThreshold>, with <verbatim|next>: the number of distinct rotation keys that must sign the next version, a positive integer;

    <item><verbatim|extensions>, OPTIONAL, never in the first version, whose data of extensions is in the genesis record (section 5.1): the data of extensions concerning the key log in force as of this version, keyed by their names (section 2), each an object, which replaces that of the version before: each version states the extensions in force, so data that continues is repeated, and a version without <verbatim|extensions> has none; for instance the declaration of the <hlink|timestamps extension|opensheaf-timestamps-0.2.tm>;

    <item><verbatim|ended>, OPTIONAL: <verbatim|true> in the last version of the key log of an owner that ends (section 6.3);

    <item><verbatim|successor>, OPTIONAL, only with <verbatim|ended>: the owner name of the owner that continues its work (section 6.3);

    <item><verbatim|exposed>, OPTIONAL: keys listed in <verbatim|keys> of earlier versions of this key log that this version declares exposed (section 6.3), each a <verbatim|did:key> URI.
  </itemize>

  A rotation key is <dfn|revealed> once it has signed a version of the key log. In the genesis record of an owner and in every <verbatim|keys.json>, earlier versions being those before it on its side of a fork (section 6.3):

  <\enumerate>
    <item><verbatim|threshold> MUST NOT exceed the number of <verbatim|keys>, nor <verbatim|nextThreshold> that of <verbatim|next>;

    <item><verbatim|keys> MUST NOT list a key that this version or an earlier one exposes, nor a rotation key, revealed or not (a key whose digest <verbatim|next> of this version or an earlier one holds);

    <item><verbatim|next> MUST NOT hold the digest of a current key of this version or an earlier one, nor a digest that <verbatim|next> of an earlier version holds, so that each rotation key is committed in one version only;

    <item><verbatim|exposed> MUST list only keys that <verbatim|keys> of an earlier version lists.
  </enumerate>

  Key-log versions are the OCFL versions of the owner object (<verbatim|v1>, <verbatim|v2>, ...); an owner object has no document versions. <strong|The first version is computed> from the genesis record, and is never signed. It MUST hold exactly three files, whose bytes are fixed: <verbatim|genesis.json>, the genesis record; <verbatim|object.json>, the JCS form (RFC 8785, the JSON Canonicalization Scheme, without a final line feed) of an object with <verbatim|format>, <verbatim|specification>, <verbatim|kind> <verbatim|owner>, <verbatim|status> <verbatim|active>, and <verbatim|name> and <verbatim|owner>, both the owner name (section 4.3); and <verbatim|keys.json>, the JCS form of an object with <verbatim|format> and the <verbatim|keys>, <verbatim|threshold>, <verbatim|next> and <verbatim|nextThreshold> of the genesis record. Its inventory file MUST be the JCS form of the OCFL 1.1 inventory of these files, with nothing else: <verbatim|digestAlgorithm> <verbatim|sha512>; <verbatim|head> <verbatim|v1>; <verbatim|id> the identifier of the owner object, <verbatim|sheaf:\<less\>owner\<gtr\>:\<less\>owner\<gtr\>>; <verbatim|type> <verbatim|https://ocfl.io/1.1/spec/#inventory>; <verbatim|manifest>, mapping the SHA-512 digest of each file, in lowercase hexadecimal, to a list of its content path, <verbatim|v1/content/> followed by its name; and <verbatim|versions>, holding only <verbatim|v1>, with <verbatim|created>, the <verbatim|created> of the genesis record, and <verbatim|state>, mapping the same digests to lists of the names of the files; no <verbatim|contentDirectory>, <verbatim|fixity>, <verbatim|message> or <verbatim|user>. Its checksum file states the SHA-512 digest of that inventory file, as OCFL requires. These files, and so the digest of the inventory file, are thus the same in every copy, and any reader can rebuild them from the genesis record; a signature naming the first version pins them. A first version with other files or other bytes is invalid, an error (section 14.3), never a fork (section 6.3). No owner tool writes a signature file for it. The keeper and the data of extensions as of the first version are those of the genesis record (section 5.1).

  The versions after the first are signed by rotation keys:

  <\enumerate>
    <item>every later version vN+1, except a fork record (section 6.3), MUST be signed by at least <verbatim|nextThreshold> distinct <dfn|rotation keys of vN>, the keys whose digests <verbatim|next> of vN holds, <verbatim|nextThreshold> being that of vN (for v2, those of the genesis record);

    <item>its signature files name these keys, and so reveal them (section 7.2);

    <item>current keys never sign a version of the key log, and rotation keys sign nothing else.
  </enumerate>

  From the second version on, <verbatim|object.json> has <verbatim|previous> (section 4.3), and a version MAY also hold files that this specification does not define (a display name, for instance), signed with it. Signature files, and when a signature is good, are defined in section 7.

  A current key is added, retired or exposed, a threshold or the data of an extension changed, or the owner ended, by a new version of the key log, which also commits the next rotation keys; the owner name never changes, nor does the keeper, which the genesis record fixes: another keeper means another owner (section 6.6). Changing the current keys or <verbatim|threshold> affects only signatures naming the new version or a later one: signatures naming earlier versions stay good (section 7.1).

  <subsection*|6.2 Creating an owner and choosing its keys><label|62-creating-an-owner-and-choosing-its-keys>

  An owner tool creates an owner by making its first current keys and rotation keys, writing its genesis record, with <verbatim|kind> <verbatim|owner>, <verbatim|keys>, <verbatim|threshold>, <verbatim|next> and <verbatim|nextThreshold>, and OPTIONALLY <verbatim|keeper> and <verbatim|extensions> (section 5.1), and the first version of its key log, computed as section 6.1 says. An owner is its own originator, and its owner object has no parent, so its owner name is made by algorithm 0 (section 5.2). If the owner name is taken, in the archive where the tool writes or among the owners it knows elsewhere, the tool draws a new nonce (section 5.3).

  <strong|Current keys.> Current keys are in daily use: one on each device the owner signs from (a laptop, a desktop), made there and never copied to another device. A person usually has a <verbatim|threshold> of 1; a group or an institution MAY require the keys of several members, by a <verbatim|threshold> of 2 or more, so that a thief holding one of them signs nothing alone.

  <strong|Rotation keys.> Rotation keys are kept apart from the current keys and from each other (on hardware tokens, for instance), and used only to sign the next version of the key log. Owner tools SHOULD offer three, with a <verbatim|nextThreshold> of 2, which survive the loss of one or the theft of one. The minimal setup, which owner tools MAY offer, is a <verbatim|nextThreshold> of 1 with at least one rotation key kept offline (printed, or on a USB key kept apart); its risk MUST then be stated: the loss of that key leaves the owner unable to change its keys or end, and its theft lets the thief take the owner over (section 15.1). A rotation key is used once, and committed in the <verbatim|next> of one version only (section 6.1): once the next version is signed, the rotation keys of the version before, whether they signed or not, are never used again, and the owner SHOULD destroy them. Owner tools MUST warn that an owner left with fewer than <verbatim|nextThreshold> rotation keys of the latest version of its key log can never change its keys or end.

  <strong|Retiring a key.> An owner retires a current key it no longer uses (a replaced laptop, a member who leaves the group) by leaving it out of <verbatim|keys> in a new version of its key log. Signatures made with it stay good, and a retired key in someone else's hands still makes good signatures naming the versions that list it; section 6.3 says when to expose it instead.

  <subsection*|6.3 Ending, exposed keys and forks><label|63-ending-exposed-keys-and-forks>

  <strong|Ending.> An owner ends by signing, as usual, a last version of its key log with <verbatim|ended> <verbatim|true>, without <verbatim|keys>, <verbatim|threshold>, <verbatim|next> and <verbatim|nextThreshold>, and, OPTIONALLY, <verbatim|successor>, the owner name of a new owner that continues its work, which MUST differ from its own owner name. The ending version only ends: it has no keys, so nothing is signed against it, and signatures made before it name earlier versions, and stay good. Owner tools MUST NOT sign anything for an ended owner. A successor is a hint, never followed automatically, and is accepted only as section 6.6 says. An owner is <dfn|ended> when its key log has an ending version or a fork record (below).

  <strong|Exposed keys.> A current key is <dfn|exposed> when a version of the key log lists it in <verbatim|exposed>: a key listed in <verbatim|keys> of an earlier version of the same key log, retired or not. An exposure counts in any version of the key log, on either side of a fork (below), in a version a fork record carries included: a thief that forks the key log may thus expose the owner's earlier keys, which makes contested what they signed (section 7.3), but never makes a version signed. Exposed keys concern only the versions of the owner's lines (section 7.3), never those of its key log (section 6.1). An owner whose current keys may have been exposed (stolen, leaked, copied), and could together reach the <verbatim|threshold> of some version of its key log that lists them, MUST at once sign a version of its key log that exposes them, or end; otherwise retiring them is enough. Only rotation keys sign that version, so whoever holds the current keys can neither prevent nor contest it.

  <strong|Forks of a key log.> Two signed versions of a key log with the same number whose inventory files differ are a <dfn|fork of the key log>; the first number at which two copies hold such versions is its <dfn|fork point>. The first version is computed, the same in every copy (section 6.1), so a key log never forks there; only <verbatim|nextThreshold> rotation keys of the version before can make a fork: rotation keys stolen before use, or kept after it. The format cannot tell which side is the owner's, so a fork ends the owner, at the fork point, and freezes it (section 7.5); no version of either side from the fork point on names a successor that is accepted (section 6.6). An owner that finds a version of its key log it did not make, and still holds <verbatim|nextThreshold> rotation keys of the version before, MAY sign another version of that number, which ends it (section 7.4).

  <strong|Fork records.> An archive keeps the versions of a key log it holds, the side it saw first (when it meets both sides at once, either one, since each ends the owner), and never replaces or removes one but by a takedown (section 4). When it meets, directly or carried by a fork record of another copy, a signed version of the key log whose inventory file differs from that of the version of that number it holds, after versions with the same inventory files as its own, it MUST append a <dfn|fork record>: a version of the key log after the latest it holds, made by the archive (its deposit, section 4.1), and not signed. When the copy that carries that version in a fork record holds, below the record, the same versions as the archive, that copy is the longer (section 6.5): the archive appends its fork record, byte for byte, like any version, instead of making one. A fork record:

  <\enumerate>
    <item>holds <verbatim|genesis.json>, that of the first version byte for byte; <verbatim|object.json>, with the fields of that of the first version and <verbatim|previous> (section 4.3); no <verbatim|keys.json>; and the versions of the other side it met, from the fork point to the latest signed version of that side, each under <verbatim|forked/\<less\>d\<gtr\>/>, where <verbatim|\<less\>d\<gtr\>> is the first 16 characters of the lowercase base32 (RFC 4648, without padding) SHA-256 digest of its inventory file: that inventory file as <verbatim|inventory.json>, its checksum file as <verbatim|inventory.json.sha512>, its <verbatim|keys.json>, and its signature files <verbatim|signature-\<less\>k\<gtr\>.json> with the witnesses beside them (section 7.2), byte for byte, under the names they have in the witness folder of that version. These versions are <dfn|carried>, and each carried inventory has the <verbatim|id> of the owner object;

    <item>is valid only when it holds nothing but these files, every file under <verbatim|forked/\<less\>d\<gtr\>/> but <verbatim|inventory.json>, <verbatim|inventory.json.sha512> and <verbatim|keys.json> being read as a file of the witness folder of that version (section 7.2), so that a file a reader does not recognise there is reported and never makes the record invalid; the first version it carries is signed (section 7.3) against the version before it held below the fork record, and its inventory file differs from that of the version of its number held below it; and every later version it carries is signed against the version before it on its side. The earlier versions a carried inventory records, and its <verbatim|previous>, are not compared with those held: its signatures, whose <verbatim|keyLog> pins the version before it as held (section 7.2), show the fork. Otherwise it is not a version of the key log;

    <item>has as its fork point the number of the first version it carries;

    <item>is never a side of a fork: copies of a key log are compared up to the version before their fork records, and a version held in one copy at the number of a fork record of another, or after it, is no fork;

    <item>is copied with the key log like any version, so that every copy shows the fork; copies of a key log may differ after the fork point, each archive keeping the side it saw first.
  </enumerate>

  <strong|The end of a key log.> No version of the key log follows a valid fork record, and none follows an ending version but a fork record, which carries the other side from the fork point on: any other version held after either is not a version of the key log, and a fork met once the key log has a fork record is reported, not recorded.

  <subsection*|6.4 After an end or an exposure><label|64-after-an-end-or-an-exposure>

  The signatures of an ended owner, and those made with exposed keys, stay good, since the format does not date signatures; but readers cannot tell them from a thief's, and trust them only as far as other evidence goes: copies held before, the pins of collections (section 8), timestamps (the <hlink|timestamps extension|opensheaf-timestamps-0.2.tm>). A version of a line that needs an exposed key, or whose signatures name a version of its owner's key log from a fork point on, is contested, unless other evidence dates its signatures before (section 7.3). While it is not ended, the owner MAY sign again, with current keys not exposed, versions it knows it made that are contested by an exposed key (section 7.1); owner tools sign nothing for an ended owner (section 6.3), and after a fork nothing is added without evidence (section 7.5).

  <strong|Ended owners.> An archive that knows an owner is ended adds that owner's key log up to the ending version, with the fork record that may follow it, or up to the fork record, also as a new deposit, and that owner's other lines only as section 7.5 says, a fork freezing the owner. The work of an ended owner continues only under its successor, by branches of its versions (section 9). Resolvers and verifiers report ended owners, by an ending version or by a fork with its fork point, exposed keys, and successors, accepted or claimed (sections 6.6, 12 and 14).

  <subsection*|6.5 Key logs travel with the objects they sign><label|65-key-logs-travel-with-the-objects-they-sign>

  A key log checks itself from its owner name: its first version is computed from the genesis record, which lists the first current keys and the digests of the first rotation keys, and each later version is signed by the rotation keys that the one before commits to. A copy from any source is therefore as good as the original, and a line can be checked without trusting any host, also after the archives that served it have gone.

  Every copy of an object, in any archive, MUST hold beside it, as owner objects in the same storage root at their paths (section 3.2), the key logs of the owner of its line and, for a branch, of the owner of each parent whose signatures its evidence holds, in <verbatim|parent/signatures/> and at every level of <verbatim|parent/parent/> (section 9). Each is copied up to the latest version that whoever makes the copy knows, and at least up to the versions its signatures name, or up to a fork record that carries them (section 6.3). The key logs of third parties whose witnesses a copy holds (section 7) MAY be copied too. Key logs are never copied into an object's content. An archive MUST keep an owner object as long as it keeps an object whose signatures need it, unless the owner object is itself taken down; a tombstone then stands in for it, and a takedown of a line leaves its owner objects in place (section 13). An owner object MAY also be copied on its own, to keep a fresher copy of its key log.

  Of two copies of a key log, compared up to their fork records (section 6.3), either one extends the other, and readers use the longer, or they differ from a fork point, as section 6.3 says. A reader that meets copies that differ from a fork point reads them, writing nothing, as an archive holding one of them would once it has appended a fork record carrying the other: the owner is ended at the fork point, and signatures naming versions of either side are judged against them (section 7.3). No one can prove offline that a key log is complete: a copy that stops early may hide that the owner has ended, and a reader holding only one side of a fork sees no fork. Readers judge by the versions they hold, and verifiers report the key-log version they judged against, so that a reader who later meets a longer copy, or the other side, judges again.

  <strong|Moving.> An owner moving to another archive copies its owner object there, with the lines it wants to keep there, and continues its lines in the new archive: the same owner and the same lines, not branches. The old copies stay valid where they are, as older copies of the same lines (section 7). In the owner-name layout this is one folder (section 3.2).

  <subsection*|6.6 Keepers><label|66-keepers>

  An owner MAY name, in <verbatim|keeper> of its genesis record (section 5.1), a single person or institution who answers for it, as a list of one URI: an ORCID iD (<verbatim|https://orcid.org/.<no-break>.<no-break>.>), whose last character is a check digit (ISO 7064 MOD 11-2) that verifiers check (section 14.3), since no schema pattern can, or a domain written as <verbatim|https://\<less\>domain\<gtr\>/>. The keeper is fixed by the owner name: no version of the key log names or changes it, and another keeper means another owner. The keeper MAY confirm it, in a place only the keeper controls: a link naming the owner in its ORCID record, or the file <verbatim|https://\<less\>domain\<gtr\>/.well-known/opensheaf> on its domain, a JSON object with <verbatim|format> <verbatim|"opensheaf-keeper/0.2">, <verbatim|owners>, the owner names it answers for, and OPTIONALLY <verbatim|successors>, an object mapping owner names it answers for to their successors (on ORCID, a link naming both).

  <strong|Successors.> An owner has at most one <dfn|accepted successor>: the one named by an ending version of its key log before any fork point (section 6.3); failing that, the one its keeper names in the place it controls, as above. The keeper MAY name one for an owner that can no longer change its key log (fewer than <verbatim|nextThreshold> rotation keys left), that a fork has ended, or that ended without naming one; that successor is reported as named by the keeper, and does not by itself end the owner. Any other successor, named in a version of either side of a fork from the fork point on, or by the keeper when an ending version before any fork point names another, is reported as a claim.

  When a keeper is named, a verifier MAY check both directions, and reports the link as confirmed, claimed only (the keeper does not confirm it) or absent. A confirmation is read as it is now: a keeper who withdraws it ends the link, and what the owner signed stays authentic. The link says who answers for an owner, not who owns its lines, which only its keys decide, nor who wrote its documents, which <verbatim|creators> in <verbatim|datacite.json> say (#41). The keeper's other roles, in takedowns and for privacy, are in sections 13 and 15.

  <strong|Open questions.>

  <\itemize>
    <item>Weighted thresholds for owners that are groups, as KERI's (#69), and witnesses that record which version of a key log they saw first, as an extension (#70); neither changes a key log made without them (<verbatim|drafts/keys-and-forks.md> and <verbatim|drafts/federated-identity.md> on <verbatim|main>).

    <item>The form of a keeper's confirmation on ORCID, which depends on an <verbatim|https> form of <verbatim|sheaf:\<less\>owner\<gtr\>>, and so on the gateway (section 12; #35).
  </itemize>

  <section*|7. Lines and signatures><label|7-lines-and-signatures>

  A <dfn|line> is the history of a work as decided by one owner, identified by the pair (name, owner) and so by the identifier <verbatim|sheaf:\<less\>name\<gtr\>:\<less\>owner\<gtr\>> (section 4). Its object versions form a single sequence, each signed by its owner, except the first version of a key log, which is computed (section 6.1). <strong|A line is its signed versions, wherever they are stored>: in an archive where its owner writes, or in a mirror (section 11). Lines of other owners with the same genesis record are branches (section 9). An owner's key log is the line of its owner object (section 6).

  <subsection*|7.1 Signing><label|71-signing>

  Every sealed object version of a line MUST be signed by its owner when it is made, except the first version of a key log, which is computed (section 6.1): by at least <verbatim|threshold> distinct current keys of one version of the owner's key log, <verbatim|threshold> being that version's, each key signing in its own signature file (section 7.2), which names that key-log version. The key-log version named SHOULD be the latest its signer knows. A signature is judged against the key-log version it names alone (section 6.1), and no signature is ever replaced. An owner MAY add signatures to a version later, with current keys that have not signed it, only to a version it knows it made, and only while it is not ended (section 6.3): so it signs again, with keys not exposed, a version contested by an exposed key (section 7.3), or one it has not yet added when a key that signed it was exposed (appendix A.1). Versions of a key log are signed as section 6.1 says.

  <subsection*|7.2 Witnesses and signature files><label|72-witnesses-and-signature-files>

  A <dfn|witness> is evidence about an object version made after it: a signature, a timestamp, an external deposit (appendix A), a software archive snapshot. The witnesses kept with an object are in its <dfn|witness folder>, the OCFL object extension folder <verbatim|extensions/opensheaf-witnesses/> (not yet registered with OCFL, so validators may warn), which is part of no version, is not covered by the inventory digests, and travels with the object. Witnesses MAY be added at any time, by the owner of the line or by others; they are kept, never re-serialised or replaced once made, since some (timestamps) are made of their bytes, and MUST NOT be removed except as section 4 says.

  <strong|Signature files.> A <dfn|signature file> holds one signature of an object version by the owner of its line. The signature of version <verbatim|\<less\>version\<gtr\>> by a key is the JSON file <verbatim|\<less\>version\<gtr\>/signature-\<less\>k\<gtr\>.json> in the witness folder, where <verbatim|\<less\>k\<gtr\>> is the first 16 characters of the lowercase base32 (RFC 4648, without padding) SHA-256 digest of the key's <verbatim|did:key> URI, as UTF-8, so that a reader that knows the keys builds every name without listing the folder. It has:

  <\itemize>
    <item><verbatim|format>: <verbatim|"opensheaf-signature/0.2">;

    <item><verbatim|object>: the identifier of the object, <verbatim|sheaf:\<less\>name\<gtr\>:\<less\>owner\<gtr\>>;

    <item><verbatim|version>: the object version signed, <verbatim|\<less\>version\<gtr\>>;

    <item><verbatim|inventorySha512>: the SHA-512 digest of that version's inventory file, as its checksum file states it;

    <item><verbatim|signer>: the owner name of the signer, which MUST be the owner part of <verbatim|object>;

    <item><verbatim|key>: the <verbatim|did:key> URI of the key that signs: one of the <verbatim|keys> of the key-log version named or, for a signature of a key-log version, a rotation key of the version named (section 6.1);

    <item><verbatim|keyLog>: that key-log version, as a pin of the owner object written as a <verbatim|sheaf:> URI, <verbatim|sheaf:\<less\>owner\<gtr\>/v\<less\>n\<gtr\>?sha512=\<less\>digest\<gtr\>> (section 12), whose owner MUST be <verbatim|signer>; for a signature of a key-log version vN+1 it names vN;

    <item><verbatim|signature>: the Ed25519 signature (RFC 8032) of the signed message, 64 bytes in canonical base64 (RFC 4648, with padding, the unused bits of the last character being zero, section 3.5): 86 characters, the last of them <verbatim|A>, <verbatim|Q>, <verbatim|g> or <verbatim|w>, followed by <verbatim|==>; a signature file with any other encoding is malformed (section 7.3).
  </itemize>

  <strong|The signed message.> What is signed is not a file but the message made of these five lines, each ended by a line feed (LF, <verbatim|0x0A>), in UTF-8, with no other characters, spaces or blank lines:

  <\verbatim-code>
    opensheaf-signature/0.2

    object \<less\>the value of object\<gtr\>

    version \<less\>the value of version\<gtr\>

    inventorySha512 \<less\>the value of inventorySha512\<gtr\>

    keyLog \<less\>the value of keyLog\<gtr\>
  </verbatim-code>

  The first line keeps these signatures apart from any other use of the key; each of the others is the name of a field of the signature file, a space and its value, and they bind the signature to one object version, its inventory and one key-log version. A verifier rebuilds the message from the fields of the signature file and verifies the signature as RFC 8032 (section 5.1.7) says, without the cofactor, and MUST reject it when its <verbatim|S> is not less than the group order L, or when the key is not the canonical encoding of a point or is a point of small order, or <verbatim|R> is not the canonical encoding of a point or is a point of small order; tools make keys as RFC 8032 (section 5.1.5) says.

  <strong|Others' witnesses.> A signature by someone other than the owner of the line, attesting a version, is a witness, not a signature of the line, and never a signature file: it is <verbatim|\<less\>version\<gtr\>/witness-\<less\>label\<gtr\>.json>, where <verbatim|\<less\>label\<gtr\>> is chosen by whoever adds it and matches <verbatim|^[a-z0-9]+(-[a-z0-9]+)*$>. It has the fields and the signed message of a signature file, with <verbatim|signer> and <verbatim|keyLog> naming the signer's own owner object, which MUST NOT be the line's owner; its key log MAY be copied beside the object (section 6.5).

  <strong|Other witnesses.> The <hlink|timestamps extension|opensheaf-timestamps-0.2.tm> keeps timestamps of signature files beside them, dates that readers may weigh; timestamps change no status by themselves, and section 7.3 admits trusted dates as evidence against <verbatim|contested>. The parent signatures a branch carries are in its content (section 9).

  <strong|Files that are not witnesses.> A file of the witness folder that is not a witness (a stray file, a malformed or invalid signature file) is ignored, reported, never fatal, and kept; a file a reader does not recognise, stray or of an extension it does not know, is reported as an unknown file, not as an error: a host cannot break a version by adding a file. A copy MAY leave such files out (section 11).

  <subsection*|7.3 Statuses><label|73-statuses>

  A signature file is <dfn|invalid> when:

  <\enumerate>
    <item>it is malformed, or its name does not match the digest of its key;

    <item>its signature does not verify;

    <item>its <verbatim|object>, <verbatim|version> and <verbatim|inventorySha512> are not those of the version whose folder holds it (the digest also as its checksum file states it; in <verbatim|parent/signatures/>, those of the parent version, section 9; in <verbatim|forked/\<less\>d\<gtr\>/>, those of the version carried, section 6.3);

    <item>its <verbatim|signer> is not the line's owner;

    <item>the reader reaches the key-log version named, with that digest (also as carried by a fork record, section 6.3), and the key is not in its <verbatim|keys> (for a signature of a key-log version, is not one of its rotation keys, section 6.1);

    <item>the version named is not a version of the key log, or is a fork record; or

    <item>for a signature of a key-log version, it signs the first version, or its <verbatim|keyLog> names another number than that of the version before it (section 6.1).
  </enumerate>

  A signature file that is not invalid is <dfn|unchecked> when the reader cannot reach the key-log version it names, with that digest (the key log is absent, taken down, or shorter, or the reader holds another version of that number, which verifiers report: a fork of the key log once the version named is found signed, section 6.3); a key-log version that the reader's copy neither holds nor carries, also after its fork record, is reached in a copy that holds it, and the signature is judged against that copy; nothing is added on unchecked signatures (section 7.5). Otherwise it is <dfn|good>, for ever: later versions of the key log, an end or a fork never change it.

  A version of a key log is signed when it is signed as section 6.1 says, with good signature files; its first version is never signed, and counts as signed when it is the version section 6.1 computes. Key logs are read version by version from the first, and are never vouched for (below): each version is checked against the one before, and a fork record is a version when it is valid, though not signed (section 6.3).

  A version of a line is:

  <\itemize>
    <item><dfn|signed> when it is <dfn|signed directly>, by at least <verbatim|threshold> distinct current keys of one key-log version, <verbatim|threshold> being that version's, with good signature files naming that version; or <dfn|vouched for>, when a later version of the same line signed directly extends it;

    <item>unchecked when it is not signed, but would be if its unchecked signatures were good; the reader does not know the <verbatim|threshold> of a key-log version it cannot reach, so a version with an unchecked signature file naming that version is unchecked;

    <item>otherwise <dfn|not a version> of the line, wherever it is found, and never shown as one: reported as invalid if at least one signature file of the owner is invalid, and otherwise as <dfn|unsigned>.
  </itemize>

  <strong|Contested versions.> A signed version of a line is <dfn|contested> when it would not be signed if these good signature files of its owner, its own or those of the versions that vouch for it, were left out:

  <\enumerate>
    <item>those made with a key that its owner's key log exposes, in any version, on either side of a fork (section 6.3);

    <item>those naming a version of its owner's key log from a fork point on, of either side.
  </enumerate>

  Such signature files count nonetheless when other evidence that the reader trusts (a timestamp of these signature files, with the <hlink|timestamps extension|opensheaf-timestamps-0.2.tm>) shows them made before the version of the key log that exposes the key, or before the fork. A key that another owner's key log exposes, shared between owners (section 15.5), counts only for that owner's lines. Only versions of lines are contested, never versions of key logs (section 6.1). A contested version is reported with its status (for archives, section 7.5); it is never the latest signed version (below), nor a confirmed branch point (section 9.3) or a verified member (section 8.5). A version signed directly with such signature files, and vouched for by a later version signed directly without them, is signed and not contested.

  <strong|A signed version vouches for its past.> The inventory of a version records the digests of every file of every version before it, and its <verbatim|object.json> the digest of the inventory file of the version before (<verbatim|previous>, section 4.3), so a version signed directly vouches for every version it extends, byte for byte, inventories included, whatever their own signatures; a version vouched for needs no signatures of its own, and its pin is as reliable as that of a version signed directly.

  <strong|Readers use the latest signed version.> The <dfn|latest signed version> of a copy of a line, its latest version that is signed and not contested, gives the line's history, current version and status (section 4.2). Nothing relies on a version that is not signed: not a pin, a resolution, a collection member or a branch point. An unchecked version is shown with its status until the key log is found, a contested one with its status. A reader that cannot list a witness folder (over HTTP, section 14.1) finds signature files only by the names that the keys of the owner's key log give (section 7.2): without the key log it finds none, and reports the versions unchecked, never unsigned.

  <strong|Owner tools MUST show the owner>, before signing a new version, the versions it would extend that are not signed or that need an exposed key, whatever evidence dates them, so that an owner never takes a thief's version into its line unknowingly. They MUST NOT sign it until the owner has acknowledged these versions explicitly (with an option given for that signature, for instance), and MAY sign it then.

  <subsection*|7.4 One writer per line, and forks><label|74-one-writer-per-line-and-forks>

  An owner MUST NOT sign two different object versions with the same number for the same line, except as section 6.3 allows. Since every version directory keeps the inventory as of that version (section 4.1), two copies of a line whose latest signed versions (section 7.3) are <verbatim|vk> and <verbatim|vm>, with k not greater than m, <dfn|agree> when <verbatim|vk/inventory.json> is the same file, byte for byte, in both. Versions held after the latest signed version of a copy are not versions of the line: they are reported with their status, and make no fork (an unchecked one is compared again once its key log is found). A copy that stops earlier is older: readers use the latest signed version among the copies that agree. Two copies that do not agree are a <dfn|fork of the line>, reported with the status of each side, and never recorded (an archive keeps the side it holds, section 5.3), except that a fork of a key log ends the owner and is recorded (section 6.3); since both sides of a fork of a line are signed, it was made with keys of the owner, and is attributable to whoever holds them.

  <subsection*|7.5 Adding versions><label|75-adding-versions>

  An archive adds a version to a line only if, once added, it is signed and not contested (section 7.3) against the key log the archive holds: signed directly by its owner, or vouched for by a version signed directly that is added with it from the same copy. Tools SHOULD fetch the latest version of the key log they can find before adding. An archive adds no invalid signature file. An archive that continues another owner's line makes a branch, under its own owner (section 9).

  <strong|Ended owners.> For an owner whose key log has an ending version (section 6.3), an archive takes versions of its other lines only from copies found elsewhere, never as new deposits, and of copies that fork, only the versions they share.

  <strong|A fork freezes the owner.> Once an archive knows of a fork of an owner's key log (section 6.3), it adds no version of that owner's other lines, from a copy or as a deposit, unless other evidence it trusts (a timestamp, with the <hlink|timestamps extension|opensheaf-timestamps-0.2.tm>) dates signature files enough to make the version signed before any version of the key log at the fork point was signed.

  <strong|Versions held stay.> Nothing that a host or a thief can produce leads to removing a version an archive holds, except as section 4 says. A version let in against this section that is not signed is reported, and never shown as a version of the line. Since OCFL versions cannot be skipped, the owner's own version of that number can then never be added there: that archive's copy of the line grows no further, and the owner continues the line in another archive.

  <subsection*|7.6 Integrity><label|76-integrity>

  Integrity rests on OCFL digests: every file is fixed by its SHA-512 digest in the inventory, every inventory by its checksum file, and every member of a collection by a pin (sections 4 and 8). Digests show that files were not changed, signatures which owner's keys signed them; neither shows who wrote them or when (sections 7.2 and 15.1).

  <section*|8. Collections><label|8-collections>

  A <dfn|collection> is an object of kind <verbatim|collection> (section 4) whose versions hold a list of members, <verbatim|members.json>. Each <dfn|member> is a line (section 7) of a document or of another collection, in any archive, pinned (section 4). A collection is a line like any other, signed by its owner (section 7), its <dfn|curator>; what it contains changes only by a new version.

  <subsection*|8.1 Catalogues and selections><label|81-catalogues-and-selections>

  Collections are of two types, which treat the versions of their members differently; <verbatim|type> in <verbatim|members.json> states which.

  <\itemize>
    <item>A <dfn|catalogue> keeps objects whole and is impartial about their versions. Each member pins an object with all its versions up to the pin, and the catalogue may follow it as it grows (section 8.3): the owner of each member decides what its versions are.

    <item>A <dfn|selection> vets particular versions: a journal the version it accepted, a digest or a review journal the version it reviewed, a reading list the version it recommends. Each member pins a revision set (section 8.4); earlier and later versions of the same member are not part of the selection unless its curator adds them, by a new version of the selection.
  </itemize>

  Both types may have collections as members (an archive of archives, a selection of issues).

  <strong|Owner catalogues.> Each owner an archive hosts has there an <dfn|owner catalogue>: a catalogue of that owner, created when the owner is set up in the archive, and named with the owner in <verbatim|owners> of the discovery document (section 3.1). It lists the documents of the owner's own lines in the archive, branches of its own included (section 9), never copies of lines (section 11); it need not list all of them: its curator MAY choose. It is a line of its owner like any other, so a change by one owner (a deposit, a new version, a branch) touches that owner's catalogue only, and no owner signs for another. An owner catalogue is not mirrored: a mirror of a line never brings its owner's catalogue (section 11). An archive MAY also keep, as one of the owners it hosts, a catalogue of the lines it holds as copies (section 11). An archive that makes other collections does so as an owner too, with a key log like any other (section 6). A selection is kept by the owner of the body that vets (a journal, a review journal), which also owns the accepted copies the selection keeps (section 9).

  <subsection*|8.2 The member list: members.json><label|82-the-member-list-membersjson>

  Every collection version MUST contain, besides the files of section 4.1, <verbatim|members.json>, and no other files of its own but its renditions (a table of contents, the cover of an issue) and the files of its notes (section 4.3), with:

  <\itemize>
    <item><verbatim|format>: <verbatim|"opensheaf-collection/0.2">;

    <item><verbatim|type>: <verbatim|catalogue> or <verbatim|selection>;

    <item><verbatim|members>: the list of members, in the order in which they are presented. This order is authoritative: presentations MUST present members in it.
  </itemize>

  It MAY contain <verbatim|order>, the rule by which tools maintaining the collection place members: <verbatim|manual>, the default (tools append new members and never reorder); <verbatim|issued-desc> or <verbatim|issued-asc>, by the members' <verbatim|Issued> date (section 4.4), then their <verbatim|Available> date, members with neither last, ties broken by <verbatim|name> and then <verbatim|owner>, so that the result is reproducible.

  Each member MUST have:

  <\itemize>
    <item><verbatim|kind>: <verbatim|document> or <verbatim|collection>;

    <item><verbatim|name> and <verbatim|owner>: its line (sections 5 and 6), by which copies are found (section 12) and checked against its owner's signatures; never a label (section 3.1) or a location;

    <item><verbatim|at>: a non-empty list of base URLs where copies of the line may be found, also of one URL: equal hints, which need no signature (section 3), read as the <verbatim|at> parameter of a <verbatim|sheaf:> URI (section 12). They locate copies of the member's own line, mirrors included (section 11), never a branch of it (section 9). The base URL of a private archive (section 3.1) is the one at which it is kept, whether or not readers can reach it; readers who have its files map it to where they are (section 12.3).
  </itemize>

  Each member MAY have <verbatim|doi>, the version DOI, and <verbatim|conceptDoi>, the concept DOI, of the member; and <verbatim|cite>, a cached citation, not authoritative, so that the collection can be read and ordered without resolving its members, also when they become unavailable: <verbatim|title>, <verbatim|creators> (a list of names), <verbatim|year>, <verbatim|issued>, the member's <verbatim|Issued> date, and <verbatim|available>, its <verbatim|Available> date, so that <verbatim|order> can be followed from <verbatim|members.json> alone. Since <verbatim|members.json> is the source of the collection, any change of it, <verbatim|cite> included, is a new document version (section 4.2); tools SHOULD refresh <verbatim|cite> only when the member list changes otherwise.

  <subsection*|8.3 Members of a catalogue><label|83-members-of-a-catalogue>

  Each member of a catalogue MUST have <verbatim|version>, the object version pinned, and <verbatim|inventorySha512>, the SHA-512 digest of its inventory file: a pin (section 4), which fixes the object with all its versions up to that one. It MUST NOT have <verbatim|revisions>.

  A member MAY have <verbatim|follow>, <verbatim|"latest">: a setting of the curator, not a floating reference. A followed member pins the latest signed version of its line (section 7.3) when the document version of the collection that holds it was made; a description-only version of the collection keeps the member list of the document version it holds (section 4.2), so that a catalogue with followed members can be described and withdrawn without moving them (#45); a member without <verbatim|follow> keeps the version its curator pinned, which MAY be earlier, until the curator changes it. A tool maintaining the catalogue reads the member's archive (its discovery document or feed) and, when a followed line has a new signed version, writes a new document version of the collection pinning it, whatever that version holds (a new document version, a description, a notice, a withdrawal): a catalogue does not judge the versions of its members, but never follows to a contested version, which is not the latest signed version (section 7.3), nor, once it knows the owner's key log forks, to a version that an archive would not add (section 7.5). A tool follows only a signed version that extends the version pinned; a copy that does not is a fork of the line (section 7.4), which it reports, keeping the pin.

  A withdrawn member stays, and presentations show its withdrawal (section 13.1), also one made after the version pinned. Presentations show the current version of each member as read from the history of the version pinned (section 4.2), not from later versions of its line: a pin that is not followed is the curator's choice.

  <subsection*|8.4 Members of a selection><label|84-members-of-a-selection>

  A <dfn|revision> is a document version of a member as a selection vetted it, pinned by the object version that held it when it was vetted. A <dfn|revision set> is the revisions of one member vetted by a selection: usually one, more after a correction is accepted.

  Each member of a selection MUST have <verbatim|revisions>, its revision set: a non-empty list, in the order of the member's history (section 4.2), no two revisions with the same <verbatim|documentVersion>, each with:

  <\itemize>
    <item><verbatim|documentVersion>: the document version vetted;

    <item><verbatim|version>: the object version vetted, which holds that document version; when several do, the last of them when the revision was vetted, which is its entry in the history (section 4.2);

    <item><verbatim|inventorySha512>: the SHA-512 digest of that version's inventory file;

    <item><verbatim|doi>, OPTIONAL: the version DOI of that document version.
  </itemize>

  A member of a selection MUST NOT have <verbatim|version>, <verbatim|inventorySha512> or <verbatim|follow>. The revision presented as the selection's is the last of the list.

  A revision pins what was vetted, and keeps its pin in later versions of the selection. Descriptions and notices added later by the member's owner are not vetted by the selection, and presentations that show them SHOULD say where they come from. If the member's owner withdraws it, its revisions stay vetted, and presentations show the withdrawal as section 13 asks, saying that it comes from the member's owner.

  Tools MUST NOT change revision sets on their own. Adding a revision (a corrected version accepted after review), removing one, or adding or removing a member is a new version of the selection, made by its curator, whose deposit (section 4.1) records who and when, with a message saying what was decided.

  A selection MAY also keep its own copy of a revision it vetted, an accepted copy, which is a branch of the member's line under the selection's owner, and lists it as a member (section 9).

  <subsection*|8.5 Pins and statuses of members><label|85-pins-and-statuses-of-members>

  Every member is pinned: a collection version states exactly which object versions it contains, whole objects up to a version in a catalogue, revisions in a selection. Since a pin fixes an inventory, which fixes every file and earlier version, a collection version fixes everything it contains, also across archives: collections are hash trees, and pins cannot form cycles. A pin fixes one history: a fork of a member's line found later (section 7.4) does not change the member, and is reported.

  A collection pins only signed versions (section 7.3), never a draft (section 10). The <verbatim|kind>, <verbatim|name> and <verbatim|owner> of a member are those of the <verbatim|object.json> of every version pinned, and the <verbatim|documentVersion> of a revision is the one its pinned version holds.

  <strong|Members of other archives.> A member may be kept in another archive. Nothing is copied: it is resolved from its <verbatim|at> as section 12 says, and any copy whose bytes match the pin will do. A reference, a pin without a copy, needs no permission. An archive that also keeps a copy keeps it as a mirror (section 11) or a branch (section 9).

  <strong|Statuses.> A member, or in a selection each revision, is, as read by a verifier (section 14):

  <\itemize>
    <item><strong|verified>, when a copy of the version pinned is found, matches the pin, and is signed and not contested (section 7.3);

    <item><strong|contested>, when a copy of the version pinned is found, matches the pin, and is contested (section 7.3);

    <item><strong|mismatch>, when copies are found and none matches the pin;

    <item><strong|unchecked>, when the version pinned is unchecked (section 7.3), shown with its status until the key log is found;

    <item><strong|not a version> (section 7.3): the collection pinned what it MUST NOT;

    <item><strong|unavailable>, when no copy is found;

    <item><strong|removed>, when no copy is found and an archive holds a tombstone of the line (section 13.3).
  </itemize>

  Whether a copy matches is decided by the bytes of its inventory file: a checksum file missing or wrong does not change the status. A copy that does not match, found beside one that does, does not change it either: the status is that of the copy that matches. Both are reported apart, with their location (section 12.3).

  <subsection*|8.6 Description and rights><label|86-description-and-rights>

  <strong|Description.> A collection version's <verbatim|datacite.json> (section 4.4) has <verbatim|resourceTypeGeneral> <verbatim|Collection>, and MUST have in <verbatim|relatedIdentifiers> a <verbatim|HasPart> relation to the version DOI of each member of a catalogue (its <verbatim|doi>) and of each revision of a selection (the revision's <verbatim|doi>) that has one; members without a DOI are listed only in <verbatim|members.json>. Its document versions and the fields of its <verbatim|object.json> are as sections 4.2 and 4.3 say.

  <strong|Rights.> A collection version holds only metadata, its renditions included, placed under CC0 (section 15.6), and its <verbatim|rightsList> SHOULD say so. The licence of a collection never extends to its members.

  <strong|Open questions.>

  <\itemize>
    <item>What a collection may state about its members (volume, acceptance, the journal's own DOI, a retraction by the journal) (#40).

    <item>Binding an owner catalogue to its archive, keys that an archive requires to create lines there, and a curated selection over the owner catalogues of an archive (#72).
  </itemize>

  <section*|9. Branches and accepted copies><label|9-branches-and-accepted-copies>

  A <dfn|branch> is a line of another owner that continues a work from a signed version of another line, its <dfn|branch point> or <dfn|parent version>: a co-author carrying the work on, the successor of an ended owner (section 6.4), a journal keeping the version it vetted. It has the work's genesis record, and so its name, or after a clash another name of the same record (section 5.3). It is a new object, with its own identifier <verbatim|sheaf:\<less\>name\<gtr\>:\<less\>owner\<gtr\>> (section 4), holding the branch point and its own versions, never the parent's other versions. An originator never owns a branch of its own work (section 5.3). A branch is a line of its owner: an archive hosting that owner lists it in that owner's catalogue, never in the catalogue of the parent's owner (section 8.1).

  <subsection*|9.1 The parent: parent in object.json><label|91-the-parent-parent-in-objectjson>

  Every version of a branch MUST have in <verbatim|object.json> (section 4.3) <verbatim|parent>, its branch point, with:

  <\itemize>
    <item><verbatim|owner> and <verbatim|name>: the line of the parent version;

    <item><verbatim|objectVersion> and <verbatim|inventorySha512>: the parent version and the SHA-512 digest of its inventory file, a pin (section 4);

    <item><verbatim|documentVersion>: the document version it holds;

    <item><verbatim|url>, which it SHOULD have: the URL of that object version, <verbatim|\<less\>storage root URL\<gtr\>\<less\>path\<gtr\>/\<less\>version\<gtr\>/>, where <verbatim|\<less\>path\<gtr\>> is the parent object's path in the layout of that storage root (section 3.2). It is a hint (section 3), used in resolution (section 12), and MAY point to a copy of the parent's line kept beside the branch (section 9.5).
  </itemize>

  The branch's <verbatim|owner> MUST differ from <verbatim|parent.owner>. Only a signed version is branched (section 7.3).

  <subsection*|9.2 The first version and its evidence><label|92-the-first-version-and-its-evidence>

  The first object version of a branch holds exactly the files of the parent version, the genesis record included, except its <verbatim|datacite.json>, its <verbatim|object.json> and its own evidence; the branch's own <verbatim|datacite.json> and <verbatim|object.json>; and the <dfn|evidence> of the branch point, as files of its content in the folder <verbatim|parent/>:

  <\itemize>
    <item><verbatim|parent/inventory.json>: the inventory of the parent version;

    <item><verbatim|parent/object.json>: its <verbatim|object.json>;

    <item><verbatim|parent/signatures/>: the parent owner's signature files of the parent version that are good when the branch is made (section 7.3; an archive adds no invalid signature file, section 7.5), named as in its witness folder without the <verbatim|\<less\>version\<gtr\>/> folder (<verbatim|parent/signatures/signature-\<less\>k\<gtr\>.json>, section 7.2), with the witnesses kept beside them, if any (timestamps); other witnesses of the parent version (a third party's signature) MAY be kept with them;

    <item><verbatim|parent/parent/>, when the parent is itself a branch: the parent version's own evidence, its folder <verbatim|parent/>, so that the grandparent's inventory is at <verbatim|parent/parent/inventory.json>, the great-grandparent's at <verbatim|parent/parent/parent/inventory.json>, and so on back to a version of the originator's line.
  </itemize>

  Every file copied is copied byte for byte, and never re-serialised or replaced. A branch MUST hold <verbatim|parent/signatures/> at every branch point, and <verbatim|parent/parent/> when its parent is a branch. The evidence is covered by the branch's own inventories and signatures; with the genesis record it forms the branch's identity files (section 4.1). The key logs that the evidence needs are kept beside every copy of the branch, never in it (section 6.5).

  <subsection*|9.3 Checking a branch><label|93-checking-a-branch>

  The evidence shows, without access to the parent's line, that a branch point is the parent owner's. A branch point is consistent when:

  <\itemize>
    <item><strong|the name:> the branch's <verbatim|name> and <verbatim|parent.name> are names of <verbatim|genesis.json> (section 5.2), and the branch's <verbatim|name> is <verbatim|parent.name> unless it was renamed after a clash, by a greater algorithm number (section 5.3);

    <item><strong|the pin:> the SHA-512 digest of <verbatim|parent/inventory.json> is <verbatim|parent.inventorySha512>, its <verbatim|head> is <verbatim|parent.objectVersion>, and <verbatim|parent/object.json> has the digest it records for <verbatim|object.json> in its head state;

    <item><strong|the files:> every file of the head state of <verbatim|parent/inventory.json>, <verbatim|genesis.json> included, except <verbatim|datacite.json>, <verbatim|object.json> and the parent's evidence, is present at the same logical path with the same digest; no other file is present besides the branch's <verbatim|datacite.json>, <verbatim|object.json> and evidence, and, at a new branch point, the files of the branch's own notices that its <verbatim|object.json> names (section 9.4);

    <item><strong|the parent:> <verbatim|parent.owner>, <verbatim|parent.name> and <verbatim|parent.documentVersion> are those of <verbatim|parent/object.json>; the branch's owner is neither the parent's owner nor the originator; and either the parent's owner is the originator and <verbatim|parent/object.json> has no <verbatim|parent>, or it has one;

    <item><strong|the signatures:> the parent version is signed (section 7.3), by the signature files of <verbatim|parent/signatures/> against the parent owner's key log kept beside the branch, or vouched for by a signed version of the parent's line that the verifier finds; or it is unchecked;

    <item><strong|the chain:> when <verbatim|parent/object.json> has a <verbatim|parent>, <verbatim|parent/parent/> holds that evidence, each file <verbatim|parent/parent/\<less\>path\<gtr\>> with the digest <verbatim|parent/inventory.json> records for <verbatim|parent/\<less\>path\<gtr\>>, and it passes these checks in turn, level by level, up to the originator's line, except the files, checked at the first level only (a parent version may be a later version of its own branch).
  </itemize>

  A chain is finite, since each level is fixed by a digest in the level below. Verifiers MAY bound the depth they follow, and report where they stop; a branch point checked only down to that bound is unchecked.

  <strong|Verdicts.> A branch point is, in this order:

  <\itemize>
    <item><dfn|inconsistent> when a check fails, a parent version is not a version (section 7.3), or the parent version, resolved, does not match the pin;

    <item><dfn|confirmed> when the parent version, at every level, is signed and not contested;

    <item>otherwise unchecked: consistent, but a parent version is unchecked or contested (section 7.3).
  </itemize>

  The verdict of a branch is the weakest of those of its branch points. Verifiers report apart whether the parent's line is found, unavailable or removed (section 13), and whether it is withdrawn.

  <strong|Ended owners.> A branch point stays confirmed when its parent's owner ends, also by a fork, or exposes keys afterwards, as long as the parent version is not contested (section 7.3), since signatures stay good; readers weigh it as they weigh that owner's history (section 6.4).

  <subsection*|9.4 Later versions and new branch points><label|94-later-versions-and-new-branch-points>

  The later versions of a branch are its owner's, signed like those of any line (section 7). They MUST keep the identity files unchanged, byte for byte, until a version that takes a new branch point.

  <strong|A new branch point.> A branch MAY take as a new branch point, by a new object version of the same branch, a later version of the same parent line (a journal vetting the authors' corrected version): with the same <verbatim|owner> and <verbatim|name>, a higher object version, and a document version later than the previous branch point's in the history of the new parent version (section 4.2). A parent version holding the same document version (a DOI added) is not a new branch point; a branch point never moves back and is never dropped. Nothing is changed in place: the earlier object versions keep their branch point. The version whose <verbatim|parent> differs from the one before is a new document version of the branch (and so reinstates a withdrawn branch, section 13.1); it holds the files of the new parent version with new evidence, and the files of the branch's own notices (section 4.2), which its <verbatim|object.json> names and which MUST NOT have the logical path of a file of the new parent version; it is checked as a first version is (section 9.3), and also for continuity: the two parent inventories have the same <verbatim|id>, every entry of <verbatim|versions> of the previous one is equal, as a JSON value, to the entry of the same version in the new one, and every digest in those entries is in the manifest of the new one. The branch's earlier document versions, such as its version of record, stay in its earlier object versions.

  <strong|Numbering.> A branch numbers its own document versions, from 1 without gaps, as every line does (section 4.2): its first version is its document version 1, whatever the number of the parent version, which <verbatim|parent.documentVersion> keeps, and a version that takes a new branch point has the next number of the branch. Presentations SHOULD show both numbers ("version 1, the authors' version 3"). The notices of a branch are its own, about its document versions; those of the parent stay in <verbatim|parent/object.json> and in the parent's line, and the branch's <verbatim|object.json> does not repeat them, although their files are among the files of the parent version it holds.

  <strong|Naming.> A branch is named as section 5.3 says. When the line it would take is its owner's branch of the same parent line, the owner gives that branch a new branch point instead if the new branch point is later in that line's history than that branch's current one, and otherwise the new branch is refused, since a branch point never moves back and an owner keeps one branch of a parent line; when it is another line of its owner, the new branch is renamed.

  <subsection*|9.5 Continuing another owner's work><label|95-continuing-another-owners-work>

  A line is not handed over. When another owner continues the work (an author leaving an institution whose line it was, a journal handing a report to its referee), the new owner makes a branch, and the previous owner MAY add a notice to its line pointing to it. An owner moving its lines to another archive hands nothing over: they stay its lines (section 6.5).

  <strong|Taking in another line's work.> Any line, the originator's included, takes in work from another line (a co-author's changes, a journal's corrections) by depositing it as a new document version of its own: its change note says where the work comes from, and its <verbatim|datacite.json> SHOULD link the version taken in with <verbatim|IsDerivedFrom> or <verbatim|IsNewVersionOf>, by its DOI, or else by the gateway URL of a <verbatim|sheaf:> URI with its <verbatim|sha512> (section 12.6), which fixes the version taken in. The originator never branches its own work (section 5.3); a branch takes in later work of its parent line by a new branch point instead, or by such a deposit.

  A branch holds none of the parent's earlier versions. An owner who wants them at hand keeps beside the branch a copy of the parent's line (section 11), at the parent's identifier, with its signatures and key log.

  <subsection*|9.6 Accepted copies><label|96-accepted-copies>

  An <dfn|accepted copy> is a branch kept by the owner of a selection (section 8.4) from a revision it vetted. Selections that keep different accepted copies of the same document MUST have different owners, also in one archive, so that their accepted copies are different lines, never renamed against each other; the selections of one owner (the issues of a journal) share its accepted copy of a document, which each of them MAY list. The later versions of an accepted copy are acts of the selection's curator (a corrected version accepted, by a new branch point; a notice; a withdrawal); the authors' later versions change nothing in it.

  The selection lists the accepted copy as a member; it MAY also list the original revision set. An accepted copy is not a mirror: a location holding only it is never given in <verbatim|at> for the parent's line (section 8.2).

  A version the selection makes itself, such as a typeset version of record, is a later version of its accepted copy, with the selection as <verbatim|publisher>, the authors' <verbatim|agreement> (section 4.3), and relations to the authors' versions (section 4.4). A branch carries versions of the same work; a derived work (a translation, a review, a collected edition) is a new object, with its own genesis record and a relation to its source.

  <subsection*|9.7 Description and rights><label|97-description-and-rights>

  <strong|Description.> A branch's <verbatim|datacite.json> has as <verbatim|publisher> its owner, or for a selection the body behind it, and keeps the relations of the parent version. Its first version, and every version that takes a new branch point, SHOULD link the parent version with <verbatim|IsIdenticalTo>: its DOI if it has one, otherwise <verbatim|parent.url> as a <verbatim|URL>.

  <strong|Rights.> A branch redistributes the files of its parent versions, and its archive is responsible for having the right to (section 11.2); a copy of the parent's line beside it is a mirror. The evidence is metadata, under CC0 (section 15.6).

  <section*|10. Drafts and sealing><label|10-drafts-and-sealing>

  A <dfn|draft> is a sandbox for a work not yet sealed, on which nothing may rely. <dfn|Sealing> makes from a work, under a new genesis record (section 5), the first version of its originator's line (section 7); the work's other lines are branches (section 9).

  <subsection*|10.1 Drafts><label|101-drafts>

  <strong|Identifier.> A draft belongs to the reserved owner <verbatim|draft>, never a name or an owner name (52 characters, section 5.2). Its identifier is <verbatim|sheaf:draft:\<less\>id\<gtr\>>, where <verbatim|\<less\>id\<gtr\>> is chosen by the archive, MUST match <verbatim|^[a-z0-9]+(-[a-z0-9]+)*$>, and MUST have at most 64 characters (76 for the identifier). It MUST NOT be reused in the archive while the draft exists, and MAY be once the draft is gone. It is local, never resolved. A draft is at the path its identifier gives (<verbatim|draft/\<less\>id\<gtr\>/> in the owner-name layout, section 3.2).

  <strong|Format.> A draft is a <verbatim|document> or a <verbatim|collection>, in the format of any object of its kind (section 4). It has no genesis record and no other identity files (section 4.1), and its <verbatim|object.json> has no <verbatim|name>, <verbatim|owner> or <verbatim|parent> (section 4.3). Its document versions are numbered by whoever keeps it, by the rules of section 4.2.

  <strong|A draft is its archive's alone.> A draft is never signed (section 7), pinned (sections 8, 9 and 12), copied out of its archive (section 11), indexed or named by a <verbatim|sheaf:> URI (section 12). The discovery document does not list drafts in <verbatim|objects>; it MAY list them apart, in <verbatim|drafts>, as unfinished work on which nothing may rely, or not at all (section 3.1).

  <strong|A draft may change.> A draft is the only object that MAY be rewritten or deleted: the rule that object versions never change (section 4) does not apply to it, and a draft deleted leaves no tombstone (section 13). OCFL 1.1 expects the contents of a version directory to be immutable once created (OCFL 1.1, section 3.3), and its extension <verbatim|0005-mutable-head> keeps a mutable version outside the version directories, which a draft does not: a draft is an OCFL object as it stands, but outside OCFL's guarantees, and verifiers check it only as it stands, never against an earlier state (section 14.4).

  <strong|Content.> A tool MAY read any object and recreate its files in a draft, as far as their licences allow.

  <subsection*|10.2 Sealing><label|102-sealing>

  <strong|When.> A work is sealed before a version of it first leaves its owner's hands: shared privately (submitted to a journal, sent to a co-author) or published. Tools SHOULD seal only at the owner's request, never as a side effect of another operation.

  <strong|What.> An owner tool seals a work by writing its genesis record (section 5.1), with the owner as <verbatim|originator>, and making a new object: the line <verbatim|sheaf:\<less\>name\<gtr\>:\<less\>owner\<gtr\>>, at its path in the storage layout (section 3.2), whose first version holds the genesis record and the work as document version 1 (section 4.2), and is signed by the owner (section 7.1). If the line is taken, the tool draws a new nonce (section 5.3).

  <strong|Drafts stay outside the line.> A work may be sealed from a draft or from files outside any archive. The versions of a draft are never part of the line sealed from it, and nothing in the line refers to them. Sealed from a draft, the first version holds the files of the draft's latest version as document version 1: its <verbatim|object.json> drops <verbatim|history> and <verbatim|notices>, with the files of the notices, which concern the draft's document versions; its <verbatim|datacite.json> keeps the description, with <verbatim|version> <verbatim|"1">, and drops the <verbatim|Updated> date (section 4.4).

  <strong|Sharing before sealing.> A draft is not shared as an object (section 10.1). Co-authors working on a draft share its files by any means outside this specification: a git repository, e-mail, a shared folder. Whatever a recipient must be able to rely on, cite or pin, a submission to a journal above all, is sealed first and shared as a line, privately if need be (section 3.1).

  <section*|11. Copies and mirrors><label|11-copies-and-mirrors>

  A <dfn|copy> of a line is its object as held in one storage root; a <dfn|mirror> is a copy kept in an archive where the owner of the line does not write, which is the archive's policy (section 3). Nothing marks a mirror: it is listed in <verbatim|objects> like any line (section 3.1), and the rules of every copy apply to it. Whoever keeps mirrors of other owners' lines, or indexes of them (section 12), is a <dfn|custodian>.

  <subsection*|11.1 Mirrors><label|111-mirrors>

  <strong|What a mirror holds.> An archive MAY keep a mirror of a line written elsewhere: the object's versions up to the latest signed version of the copy it copies (section 7.3), with their inventories, files and the witnesses it can find (over HTTP, only those whose names it can compute, section 14.1), byte for byte, at the path its layout gives the line's identifier (section 3.2), and beside it the key logs its signatures need (section 6.5). Files of the witness folder that are not witnesses need not be copied (section 7.2): not copying them is not removing them. When a copy holds, under the same name, a witness file other than the mirror's, the mirror keeps its own and reports the other.

  <strong|How a mirror grows.> A mirror is the same line, signed by its owner, never a new one. It MUST NOT be changed except by adding the owner's signed versions as section 7.5 allows, from a copy that agrees with it (section 7.4); by adding witnesses (section 7.2); or as section 4 says. A copy that does not agree with it is a fork of the line (section 7.4).

  <strong|Elsewhere.> A mirror may be listed in a catalogue of copies, never in an owner catalogue (section 8.1), and located by the <verbatim|at> of collection members (section 8.2). A copy of a parent's line kept beside a branch is a mirror (section 9.5); an accepted copy is a branch, not a mirror (section 9.6). Drafts are never mirrored (section 10.1), nor are owner catalogues: a mirror of a line never brings the catalogue of its owner, which lists the owner's lines in the archive that hosts it (section 8.1).

  <subsection*|11.2 Rights><label|112-rights>

  An archive that keeps a mirror redistributes the files it copies, and is responsible for having the right to: by their licences (<verbatim|rightsList>, section 4.4, which a description-only version may change), by the agreement of the rights holders, or by law. This specification does not judge it, and verifiers do not check it; tools MAY warn when no licence of the versions copied is one they know to allow redistribution. Key logs, inventories, signature files and the other metadata are under CC0 (section 15.6), and are copied freely; a reference needs no permission (section 8.5).

  <strong|Open questions.>

  <\itemize>
    <item>Whether a copy MAY stop before the latest signed version of the copy it copies, at a pinned version, so that a custodian keeps exactly what it pins or what it has the right to redistribute (#39).

    <item>What a custodian promises to keep (all the lines of an owner, the members of a collection, the revisions a selection vets), and where it says so (#54).
  </itemize>

  <section*|12. Identifiers: sheaf: URIs, resolution, indexes><label|12-identifiers-sheaf-uris-resolution-indexes>

  Lines, versions, pins, works and owners are written as <verbatim|sheaf:> URIs. A <dfn|resolver> is a program that finds and checks what a <verbatim|sheaf:> URI names; a <dfn|gateway> is a resolver serving web links (section 12.6).

  <subsection*|12.1 sheaf: URIs><label|121-sheaf-uris>

  Where <verbatim|\<less\>name\<gtr\>> is a name (section 5) and <verbatim|\<less\>owner\<gtr\>> an owner name (section 6):

  <\verbatim-code>
    sheaf:\<less\>name\<gtr\> \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ the originator's line

    sheaf:\<less\>name\<gtr\>:\<less\>owner\<gtr\> \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ the line of that owner

    sheaf:\<less\>name\<gtr\>:* \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ the work: all its lines

    sheaf:\<less\>name\<gtr\>[:\<less\>owner\<gtr\>]/v\<less\>n\<gtr\> \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ document version n of the line

    sheaf:\<less\>name\<gtr\>[:\<less\>owner\<gtr\>]/v\<less\>n\<gtr\>?sha512=\<less\>digest\<gtr\> \ \ one object version holding it

    sheaf:\<less\>owner\<gtr\> \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ an owner: its key log

    sheaf:\<less\>owner\<gtr\>/v\<less\>n\<gtr\>?sha512=\<less\>digest\<gtr\> \ \ \ \ \ \ \ \ \ \ \ a version of its key log
  </verbatim-code>

  <strong|Syntax.> The parts are, in this order: <verbatim|sheaf:> and the name; OPTIONALLY the <dfn|owner part>, <verbatim|:> and an owner name, or instead <verbatim|:*>; OPTIONALLY <verbatim|/v> and a positive integer without leading zeros; OPTIONALLY <verbatim|?> and parameters <verbatim|key=value> joined by <verbatim|&>, with at most one <verbatim|sha512>, only after a version, whose value is an inventory digest as in a pin (section 4), 128 lowercase hexadecimal digits, and at most one <verbatim|at>, after <verbatim|sha512> if both are present; other parameters MAY come anywhere among them, and tools write them after <verbatim|sha512> and <verbatim|at>. Only the value of <verbatim|at> is percent-encoded; no fragment is defined. The scheme, the name, the owner name, <verbatim|v>, the digest and the parameter names are lowercase, and a resolver MAY fold uppercase letters in them; the value of <verbatim|at> is case-sensitive. A resolver ignores parameters it does not know. An owner part of 52 characters is a name of algorithm 0, as every owner name is (section 6.2), and a resolver rejects any other.

  <strong|The owner.> Without an owner part, a URI names the originator's line (section 5.3), read from the genesis record every copy carries; never the latest or most authoritative line, so a branch is always written with its owner part. An owner is the originator of its own genesis record, so <verbatim|sheaf:\<less\>owner\<gtr\>> names its key log.

  <strong|The work.> <verbatim|sheaf:\<less\>name\<gtr\>:*> names every line of the work (section 12.4). It takes <verbatim|at>, but a resolver rejects it with a version or <verbatim|sha512>, since every line has its own document versions.

  <strong|The version.> <verbatim|/v\<less\>n\<gtr\>> is a document version of the line (section 4.2, also on a branch), or for a key log an object version. It names only signed versions (section 7.3) whose <verbatim|object.json> has the URI's name and the line's owner: a branch names only its own versions, numbered from 1 (section 9.4), and drafts are never named (section 10.1). Without a digest, it names the object version holding n that the history of the line's latest signed version lists (section 4.2), or without <verbatim|history> the last signed one holding n; what it names may change as the line grows.

  <strong|The pin.> With a digest, the URI names exactly the object version whose inventory file has that digest. Citations of a fixed version SHOULD carry the digest.

  <strong|The hint.> <verbatim|at> gives the base URL of an archive where a copy is expected, which a resolver tries first: an <verbatim|https> URL ending with <verbatim|/>, every character outside the unreserved characters of RFC 3986 percent-encoded, decoded once (<verbatim|sheaf:\<less\>name\<gtr\>/v3?sha512=\<less\>digest\<gtr\>&at=https%3A%2F%2Fauthors.example.org%2F>). It is not part of what the URI names.

  <strong|Canonical form.> The canonical form has complete parts (section 12.2), lowercase where case is folded, no owner part when the owner is the originator, the genesis name (section 5.2) with <verbatim|:*>, and no <verbatim|at> or unknown parameters. Two URIs name the same thing when their canonical forms are equal byte for byte, which may need a copy of the genesis record to decide. Files record <verbatim|sheaf:> URIs in canonical form (<verbatim|keyLog>, section 7.2; relations, section 4.4), except identifiers (section 4), which always have the owner part.

  <subsection*|12.2 Short forms><label|122-short-forms>

  For people, the name and the owner name MAY be shortened to a prefix of at least 8 characters (<verbatim|sheaf:lvfmiq2z:iztwg6bj/v3>); a part of 52 characters is complete. A resolver expands a short form among the lines it knows that pass the checks of section 12.3. The candidates are the lines whose name and owner name start with the parts given (without an owner part, the originators' lines; with <verbatim|:*>, every name starting with the name part, whose work is then searched for, section 12.4). If exactly one line (with <verbatim|:*>, one genesis record) is a candidate, the short form names it; otherwise it is ambiguous, and the resolver MUST NOT choose but lists the candidates with their full forms and originators.

  Expansions may differ between resolvers and over time, so every file defined by this specification MUST use complete parts. A resolver SHOULD show the full form of what it resolved; landing pages and citation metadata SHOULD give the full form, in canonical form (section 12.1: without an owner part for the originator's line), and MAY add a short one. A short form printed where it cannot be corrected (a paper, a slide) SHOULD have at least 16 characters in each part.

  <subsection*|12.3 Resolution><label|123-resolution>

  <strong|Where to look.> A resolver tries, in any order, the locations it has: the URI's <verbatim|at> first, the <verbatim|at> of a collection member (section 8.2), a branch's <verbatim|parent.url> (section 9.1), the indexes it knows (section 12.5), its user's configuration. That configuration MAY also map a base URL to another place where its files are read (a local folder, a test server), so that locations that <verbatim|at>, always <verbatim|https>, cannot give are tried; such a mapping is the reader's own, and is never written in files. At an archive it reads the discovery document, finds the line in the indexes or in <verbatim|objects>, and fetches <verbatim|\<less\>storageRoot\<gtr\>\<less\>path\<gtr\>/\<less\>version\<gtr\>/inventory.json>, <verbatim|\<less\>path\<gtr\>> being given by the archive's layout (section 3.2); a key-log version carried by a fork record is found under <verbatim|forked/> in the fork record, whose inventory lists it (section 6.3). The parent version of a branch is fetched at <verbatim|parent.url> and otherwise found as any version of <verbatim|sheaf:\<less\>parent.name\<gtr\>:\<less\>parent.owner\<gtr\>>. <verbatim|parent.url> names no archive: a resolver that needs the archive serving it (for the parent owner's key log, section 6.5) tries as base URL each prefix of <verbatim|parent.url> ending with <verbatim|/>, and takes one whose discovery document has a storage root that <verbatim|parent.url> starts with.

  <strong|Checks.> Every copy found is checked: the URI's name is a name of its <verbatim|genesis.json> (section 5.2); its <verbatim|object.json> has that <verbatim|name> and the line's owner (the owner part, or the originator); its versions are signed (section 7.3), against the key log kept beside it (section 6.5) or a longer copy found elsewhere. For a pin, the bytes of the inventory file have the digest, whatever its checksum file states, and the version holds document version n (for a key log, is object version n, or is carried with that number by a fork record, section 6.3). A copy that does not match is reported with its location, and the pin is a mismatch only if no copy found matches (section 8.5); a resolver MAY stop at the first copy that matches. A checksum file missing, or not stating the digest of its inventory, is reported with its location, and does not make the copy fail; the archive holding it fails its own verification (section 4). A copy that passes is a copy of the line, wherever found. Unchecked versions and versions that are not versions (section 7.3) are reported with their status and location, and never resolved to; a contested version is resolved to only by a pin naming it, and reported as contested.

  <strong|Copies, forks and ended owners.> Since a copy that stops early looks complete, a resolver uses the latest signed version among the copies it found that agree (section 7.4), and says where it found them. A fork of the line (section 7.4) is reported with the status of each side; the resolver uses only signed versions and does not choose between signed sides. A fork of a key log is not one of a line: it ends and freezes the owner (sections 6.3 and 7.5), and signatures naming versions of either side are checked against them, wherever held, the versions they sign being contested from the fork point on (section 7.3). A resolver reports an owner that has ended, by an ending version or a fork, or has exposed keys (section 6.3), with any successor, its own or named by its keeper (section 6.6), and never follows a successor by itself.

  <strong|Tombstones.> A tombstone (section 13) is not signed and speaks for its archive only (section 13.3): a resolver that meets one keeps looking, and when it finds a copy that passes the checks, reports the copy and the tombstone.

  <strong|External records.> A deposit with an external service (<verbatim|external>, section 4.3; appendix A) or a software archive snapshot is a witness (section 7.2), not a copy: it holds no inventory, so it is never checked against a pin and resolves nothing; a resolver MAY report it as a place where the files may be found. A snapshot holding an archive's storage root (an archive kept in git) is read as that archive.

  <subsection*|12.4 Searching for a work><label|124-searching-for-a-work>

  Resolving one line needs no search (the originator's line is always named by algorithm 0). But the lines of a work may carry any of the 16 names of its genesis record (section 5.2). To find them all (for <verbatim|:*>, or a search by work), a resolver obtains the genesis record from any copy or index entry found under the name, checked against it; computes its 16 names and looks each up in the indexes it knows; keeps only the entries whose genesis record is byte for byte the one obtained, discarding others as collisions (removed entries without a genesis record are listed apart, as removed lines of those names, and removed entries that kept it are marked removed); and keeps only the lines that pass the checks of section 12.3 and hold back to the origin: the originator's line signed by its originator, and branches whose branch points are confirmed (section 9.3). A reused genesis record thus yields no line (section 5.4), and no hash is assumed free of collisions. If several genesis records have the URI's name, the URI is ambiguous: the resolver lists them with their originators.

  <subsection*|12.5 Indexes><label|125-indexes>

  An archive SHOULD keep three <dfn|indexes> of its objects, by name, by owner and by inventory digest, next to its discovery document, declared in its <verbatim|indexes> (section 3.1). A custodian (section 11) or a resolver MAY keep them for many archives at a base URL of its own, declared in <verbatim|indexes.json> there. Indexes are maps, not witnesses: what they lead to is checked (section 12.3).

  <strong|Files.> An index is a folder of files <verbatim|\<less\>p\<gtr\>.json>, where <verbatim|\<less\>p\<gtr\>> is a prefix of the key, each a JSON object with <verbatim|format>, <verbatim|"opensheaf-index/0.2">; <verbatim|index>, its folder; and <verbatim|entries>, every key starting with <verbatim|\<less\>p\<gtr\>>. A file without entries is omitted, so a missing file means no entry. The declaration (<verbatim|indexes> in the discovery document, or <verbatim|indexes.json>, with <verbatim|format> and <verbatim|indexes>) maps each index kept to the length of its <verbatim|\<less\>p\<gtr\>>, from 2 to 4 characters.

  <\itemize>
    <item><verbatim|names/>, by name: for each object with a genesis record, <verbatim|name>, <verbatim|owner>, <verbatim|id> (section 4), <verbatim|status>, <verbatim|originator> (for an owner object, itself), <verbatim|genesis> (the text of <verbatim|genesis.json>, whose UTF-8 encoding is exactly its bytes, so that works are searched for from indexes alone) and, if any, <verbatim|label> (section 3.1);

    <item><verbatim|owners/>, by owner name: for each owner with lines in the storage root, <verbatim|owner> and <verbatim|names>, the names of those lines, its key log among them when kept there (section 6.5);

    <item><verbatim|sha512/>, by inventory digest: for each sealed object version, and each key-log version carried by a fork record (section 6.3), <verbatim|inventorySha512>, <verbatim|id>, <verbatim|version> and <verbatim|status>, a carried version having the <verbatim|id> of its key log and its own number.
  </itemize>

  <strong|Content.> An archive's indexes list every object with a genesis record and every sealed version of it, carried key-log versions included, never drafts. <verbatim|status> is the object's, <verbatim|active> or <verbatim|withdrawn>, or <verbatim|removed> after a takedown (section 13): a tombstoned object keeps its entries in <verbatim|names/> and <verbatim|sha512/>, in <verbatim|sha512/> one for every version up to <verbatim|lastVersion>, the tombstone's pin among them (section 13.3), of which those in <verbatim|names/> MAY drop <verbatim|originator> and <verbatim|genesis>, while a takedown removes the name from <verbatim|owners/>, and the entry once it lists none. In indexes kept for several archives, every entry has <verbatim|at>, a list of base URLs of the archive serving the copy, equal hints (section 3), and <verbatim|owners/> has an entry for each owner and archive.

  <strong|Lookups.> A resolver looks a line up in <verbatim|names/>, starting from <verbatim|at>, keeping the entries whose <verbatim|owner> matches the owner part, or without one, whose <verbatim|owner> is their <verbatim|originator>; a removed entry without <verbatim|originator> is matched against the originator of any copy of the genesis record, or reported as a removed line of that name, originator unknown. It looks a pin up in <verbatim|sha512/> and an owner's lines in <verbatim|owners/>. At an archive without indexes, it MAY read <verbatim|objects> of the discovery document and fetch <verbatim|genesis.json> and <verbatim|object.json> from the objects.

  <subsection*|12.6 Gateways><label|126-gateways>

  A gateway serves a URI at its base URL followed by the URI unchanged (<verbatim|https://opensheaf.org/sheaf:\<less\>name\<gtr\>/v3>, provisionally, #35); gateway links are written in full, since a relative link starting with <verbatim|sheaf:> is read as a URI. A gateway:

  <\itemize>
    <item>MUST answer with a page (200) showing what it resolved, or a temporary redirect (302, 303 or 307) only to a copy it has checked (section 12.3); it MUST NOT redirect permanently (301, 308), and MAY cache its result only for a URI with a digest;

    <item>MUST show where what it resolved was found, that a URI without a digest resolves to the latest copy it found, not necessarily the owner's latest, and when the owner has ended, by an ending version or a fork, or has exposed keys, with any successor;

    <item>MUST NOT serve an archive's files from its own origin, but redirects or links to the archive (section 15.3);

    <item>MUST fetch on its users' behalf only <verbatim|https> URLs at public addresses, with limits on size and time.
  </itemize>

  <strong|Open questions.>

  <\itemize>
    <item>Registering the scheme <verbatim|sheaf> with IANA, as a provisional scheme (RFC 7595), until which DataCite records <verbatim|sheaf:> URIs as <verbatim|URL> (section 4.4) (#36).

    <item>Whether the project runs a gateway, on which domain, and whether a domain used only for resolution drops <verbatim|sheaf:> from the path, as <verbatim|https://doi.org/> drops <verbatim|doi:> (#35).

    <item>Who keeps indexes of many archives, so that a line can be found once its archives have gone, and how resolvers find them (#20).

    <item>Whether an external record can resolve a pin if it also holds the version's inventory file, its checksum file and its signature files (a Zenodo record version uploading them, a member's <verbatim|swhid>) (#22).
  </itemize>

  <section*|13. Withdrawal, takedown and tombstones><label|13-withdrawal-takedown-and-tombstones>

  An owner withdraws a line, which keeps its versions; an archive takes down an object, which leaves a tombstone. A draft is neither withdrawn nor taken down: it is deleted, and leaves no tombstone (section 10.1).

  <subsection*|13.1 Withdrawal><label|131-withdrawal>

  A document or a collection is <dfn|withdrawn> by a description-only version (section 4.2), the <dfn|withdrawal>, whose <verbatim|object.json> has <verbatim|status> <verbatim|withdrawn> and <verbatim|withdrawal> (section 4.3), and whose <verbatim|datacite.json> has <verbatim|withdrawal.date> as <verbatim|Withdrawn> (section 4.4). A withdrawal holds the files of an existing document version, unchanged (tools hold the current one), and adds no document version: it changes the meaning of the versions before it, which stay inspectable. It withdraws every document version deposited before it, in the order of deposit (section 4.1): a version found later and placed earlier by <verbatim|history> is withdrawn if it was deposited before the withdrawal. A single document version is retracted by a notice instead (section 4.2).

  <strong|Until a new document version.> Every later description-only version (a notice, a DOI) keeps <verbatim|status> <verbatim|withdrawn> and the same <verbatim|withdrawal>. A new document version <dfn|reinstates> the line: it has <verbatim|status> <verbatim|active> and no <verbatim|withdrawal>, and its change note SHOULD say why the work is back. The document versions withdrawn stay withdrawn; those deposited after the reinstatement are not, until a later withdrawal, which withdraws them in turn. A new document version is never itself a withdrawal. These rules are read from the object versions of the line, every one of which stays: a document version is withdrawn when an object version after the one that first held it is a withdrawal, which gives its date and reason.

  <strong|Status.> The status of the line is that of its latest signed version (section 7.3), whatever document version that holds: <verbatim|withdrawn> from a withdrawal until a reinstatement. A copy without a signed version has no status as a line, and its discovery document gives that of its head (section 3.1). A branch or an accepted copy is withdrawn only by its own owner (section 9). An ended owner signs nothing, and so withdraws nothing (section 6.3), nor does an owner that has lost its keys: an owner withdraws its lines before it ends.

  A withdrawn document version keeps every object version, signed, pinned and copied as before. Presentations showing a document version they know to be withdrawn MUST show it as withdrawn, with the date and reason of the withdrawal, also when the line has been reinstated since; presentations showing a version of a line they know to be withdrawn MUST show the withdrawal, also when the version shown is earlier.

  <subsection*|13.2 Takedown><label|132-takedown>

  A <dfn|takedown> deletes a sealed object, witness folder included, from an archive's storage root (with the folders the deletion leaves empty) and from its presentation files, and adds a tombstone (section 13.3). An archive removes what it holds only as section 4 says, and every removal of a sealed object is a takedown, whatever its reason: content that must not be served (by law, for a breach of rights, to erase personal data, section 15.5), or a line the archive stops keeping. It removes one object: others holding the same files, such as a branch holding its parent version (section 9), are taken down on their own. A takedown of a line listed by an owner catalogue SHOULD be followed by a version of that catalogue without it (section 8.1); earlier versions keep their pins, and the member is read there as removed (section 8.5).

  <strong|Owner objects.> A takedown of a line leaves in place the owner objects its copy carries (section 6.5). An owner object that an object of the archive needs is taken down only for itself, and only by law or at its keeper's request (section 6.6); never at a request signed by the owner's keys, which a thief may hold. The owner's signatures in what the archive keeps are then unchecked there (section 7.3), and the tombstone stands in for the owner object in the rule of section 6.5.

  <strong|Returning.> A line taken down (an owner object found elsewhere, for instance) MAY return to the archive only from a copy holding the version its tombstone pins, its inventory file having the pin's digest, so that the archive knows it is the line it held: up to that version or, when that version is not signed (a fork record counts as signed here), up to the latest signed version before it in that copy, added as section 7.5 says: it is the same line, not a reuse of its identifier (section 4), and its tombstone is dropped.

  <subsection*|13.3 Tombstones><label|133-tombstones>

  A <dfn|tombstone> is an entry of <verbatim|tombstones> in the discovery document (section 3.1), one for each object taken down, with:

  <\itemize>
    <item><verbatim|id>, <verbatim|kind>, <verbatim|name> and <verbatim|owner>: those of the object (section 4.3);

    <item><verbatim|genesisName>: the genesis name of its genesis record (sections 5.2 and 5.4);

    <item><verbatim|lastVersion> and <verbatim|inventorySha512>: its head when taken down, and the SHA-512 digest of that version's inventory file, a pin (section 4);

    <item><verbatim|date>: the date of the takedown;

    <item><verbatim|reason>: a plain text, which SHOULD NOT repeat what was taken down.
  </itemize>

  A tombstone is never removed, except when its line returns: it keeps the line taken (section 5.3), and <verbatim|objects> never lists its <verbatim|id>. It is not signed (section 12.3). A line, or a version of it no later than <verbatim|lastVersion>, of which no copy is found but a tombstone is, is reported as removed (sections 8.5 and 9.3).

  <strong|Elsewhere.> A tombstone speaks for its archive only: it says that this archive no longer serves the line, not that nobody may. It binds no other archive, and does not stop resolution at copies elsewhere (section 12.3). Mirrors, branches holding the files, indexes kept by others, gateways and the records of external services (appendix A) do not follow a takedown by themselves: each answers for what it serves, as for what it copies (section 11.2), and content that must not be served anywhere is taken down at each archive that serves it, at a request made to each. Requests are outside this specification. Tools that meet a tombstone of a line they copy, index or serve from elsewhere (a mirror brought up to date, a resolver, a gateway) report it, with the copy they found. An owner who wants every copy to show that a work is no longer valid withdraws it (section 13.1), which copies follow, since it is a signed version.

  <strong|Earlier versions.> A tombstone pins the last version taken down. A pin of an earlier version of the line, of which no copy is found, is reported as removed (section 8.5); the archive's <verbatim|sha512/> index, if kept, holds the digest of every version (section 12.5).

  <strong|Open questions.>

  <\itemize>
    <item>A retraction by a collection (a journal) of one of its members, distinct from a withdrawal by the member's owner (#40).

    <item>Takedowns of single files or versions, should a later OCFL provide them (#32).
  </itemize>

  <section*|14. Verification><label|14-verification>

  A <dfn|verifier> is a program that checks an archive, or an object with the key logs kept beside it, against this specification. It checks every requirement of sections 3 to 13 that the files decide, in the order of sections 14.2 to 14.6, each step using the results of those before; the rules are those of the sections cited. The discovery document, the indexes and presentation files are maps: a verifier checks them against the storage root, and never takes them as authoritative (section 3.1). Rules on what an archive received or saw, rather than on what it holds, are not checked from the files: that an archive takes the lines of an ended owner only from copies, never as new deposits (section 7.5), and keeps the side of a fork of a key log it saw first (section 6.3).

  <subsection*|14.1 Findings><label|141-findings>

  A verifier reports every finding with its place (the archive, an object, a version, a file), and does not stop at the first. A finding is:

  <\itemize>
    <item>an <dfn|error>: a breach of a MUST or MUST NOT, except where this section makes it a warning. An archive or an object without errors <dfn|passes> verification;

    <item>a <dfn|warning>: a breach of a SHOULD; a breach that the archive cannot repair, where this section says so; a check not made or not completed;

    <item>a <dfn|result>, neither: the statuses of signature files, versions and members (sections 7.3 and 8.5), the verdicts of branches (section 9.3), forks of lines and of key logs (sections 6.3 and 7.4), ended owners (by an ending version or a fork), exposed keys, contested versions (section 7.3), and successors, accepted or claimed (sections 6.3 and 6.6), withdrawals (section 13.1) and removals (section 13.3).
  </itemize>

  <strong|Checks not made.> A verifier reading an archive over HTTP cannot list folders: it checks the objects the discovery document lists, and warns that it has not checked that the storage root holds no others, nor the files of witness folders whose names it cannot compute, nor that the indexes hold no entries but those of the archive's objects (section 14.6); one with access to the files checks them. A verifier MAY bound the depth of the chains and collections it follows (section 9.3), SHOULD bound the size of what it fetches (section 15.2), and warns where it stops. A verifier MAY check part of an archive (one line, a collection and what it pins, the versions the feed lists since a date), and warns that the rest is not checked: an archive too large to check at once is checked as it grows.

  <subsection*|14.2 Files and storage><label|142-files-and-storage>

  The verifier checks:

  <\itemize>
    <item>every JSON file this specification defines against its schema (section 2), formats (dates, URIs) included as assertions, which JSON Schema 2020-12 leaves optional: the discovery document, the files of every object version (<verbatim|parent/object.json> and the files of <verbatim|parent/parent/> included), the files of witness folders, the indexes, and a keeper's file when it reads one; a malformed file of a witness folder is a warning (section 7.2);

    <item>that the storage root and every object are valid OCFL 1.1, with an OCFL validator or equivalent checks, leaving out the warnings validators give on witness folders (section 7.2); a draft is checked as it stands (section 10.1);

    <item>the layout that <verbatim|storageLayout> names (section 3.2): for the hashed layout, that <verbatim|ocfl_layout.json> names it with its parameters; for the owner-name layout, that the storage root has no <verbatim|ocfl_layout.json>, and, a breach being a warning, that it holds <verbatim|opensheaf-owner-name-storage-layout.md>; and that every object is at the path its identifier gives in that layout;

    <item>the rules of section 4.1 in every object version, and that the inventory of each version folder is the inventory as of that version: its <verbatim|head> is that version, and its <verbatim|versions> are those of the head inventory up to it, equal as JSON values;

    <item>the inventory chain (section 4.3): that the <verbatim|object.json> of every sealed version after the first has <verbatim|previous>, equal to the SHA-512 digest of the inventory file of the version before, as held in its version folder, and that a first version and a draft have none; a missing or differing <verbatim|previous> is an error.
  </itemize>

  <subsection*|14.3 Key logs><label|143-key-logs>

  The verifier checks the owner objects first, each from its first version (section 6):

  <\enumerate>
    <item>its genesis record (section 5.1), and that its first version is the one section 6.1 computes, by computing <verbatim|object.json>, <verbatim|keys.json> and the inventory file from the genesis record and comparing them with those held, byte for byte, with no other file (a signature file of the first version is invalid, section 7.3, and a warning, as any invalid file of a witness folder, section 7.2);

    <item>when a keeper is named by an ORCID iD, its check digit (section 6.6);

    <item>that every later version but a fork record holds <verbatim|keys.json>, and that each later version is signed (section 7.3);

    <item>that no version is held after a fork record, nor after an ending version but a fork record (section 6.3), a breach of these two being a warning, as for lines (section 14.4);

    <item>that an ending version has no <verbatim|keys>, <verbatim|threshold>, <verbatim|next> or <verbatim|nextThreshold>, that <verbatim|successor> is not the owner itself, and whether it is accepted or claimed (sections 6.3 and 6.6);

    <item>the thresholds, and the rules of section 6.1 on <verbatim|keys>, <verbatim|next> and <verbatim|exposed>, among them that no digest is in the <verbatim|next> of two versions;

    <item>each fork record (section 6.3): that it is valid, holding the <verbatim|genesis.json> of the first version, byte for byte, an <verbatim|object.json> with the fields of that of the first version and <verbatim|previous>, no <verbatim|keys.json>, and nothing else but the versions it carries, each under the name its inventory digest gives, with the owner object's <verbatim|id> in its inventory, its <verbatim|keys.json> and checksum file against its inventory, and its signatures against the version before, the first differing from the version of its number held.
  </enumerate>

  It reports as results the latest version of each key log, the exposed keys, on either side of a fork, and ended owners, by an ending version or by a fork with its fork point, with their successors, accepted or claimed; when a keeper is named, it MAY check the link (section 6.6).

  <subsection*|14.4 Objects><label|144-objects>

  For every other object, the verifier checks:

  <\itemize>
    <item><strong|its records:> the rules of sections 4.2 to 4.4 in every version and between versions (numbering, new versions, the fields that belong to a document version and <verbatim|external>, completion, <verbatim|history>, notices kept in order and the notices they replace, a withdrawal kept until a new document version reinstates the line and never made by one, section 13.1), and, as a warning, a notice dated after its deposit, for collections as for documents, as far as the files decide them;

    <item><strong|its identity:> the genesis record, the name and the identifier in every version (sections 4 and 5), and that the objects and tombstones of the archive with the same genesis name are its originator's line and branches of it (section 5.4);

    <item><strong|its signatures:> the status of every signature file and version, and the latest signed version (section 7.3), against key logs kept beside it as section 6.5 asks. A key log missing is an error; one taken down (section 13.2), or not reaching the versions its signatures name (section 7.3), a warning; the signatures that need it are unchecked. A version that is not a version of its line is a warning (section 7.5); a contested version is a result (section 7.3);

    <item><strong|a branch:> the verdict of each branch point (section 9.3), at its first version and at every version that takes a new branch point, with the continuity of section 9.4, and that the identity files are unchanged between them. An inconsistent branch point is an error, an unchecked one a warning; the branch's verdict, and whether its parent's line is found, unavailable, removed or withdrawn, are results. A rename whose algorithm number is not greater than that of <verbatim|parent.name> is an error (section 9.3); one that neither the objects nor the tombstones of the archive justify, or not by the smallest number free there, is a warning (section 5.3);

    <item><strong|a draft:> the rules of section 10.1, as it stands, and that nothing in the archive pins it.
  </itemize>

  <subsection*|14.5 Collections><label|145-collections>

  For each collection version, the verifier checks the rules of section 8 on <verbatim|members.json> and its members. It resolves every member of the current version (section 4.2; every revision, in a selection) as a resolver does (section 12.3), and the members held in the archive in every earlier version; resolving the other members of earlier versions is OPTIONAL. The status of each member is a result (section 8.5); a copy that does not match, beside one that does, and a checksum file missing or wrong at a location are warnings (section 12.3). It also checks that no owner of selections of the archive keeps two accepted copies, two lines, of the same document (section 9.6); several selections of one owner listing the same accepted copy are no breach. A member that is not a version is an error, and so is a mismatch of a copy held in the archive; any other status but verified, contested included, is a warning. A member whose document version pinned (in a selection, a revision) is withdrawn, as the verifier reads the member's line, is reported so, as a result, also when the line has been reinstated since (section 13.1).

  <subsection*|14.6 The archive as a whole><label|146-the-archive-as-a-whole>

  The verifier then checks, against the objects:

  <\itemize>
    <item><strong|the discovery document> (section 3.1): for an archive that pages <verbatim|objects>, that every page is found and valid, and that no object is in two pages; that <verbatim|objects> lists every object of the storage root except drafts, each entry with the values its object gives (<verbatim|status> as section 13.1 says), with distinct labels; that no two entries of <verbatim|owners> have the same <verbatim|owner> or the same <verbatim|catalogue>, and that each <verbatim|catalogue> names a catalogue it lists, of the entry's owner (section 8.1); a breach being a warning, that <verbatim|owners> names only owner objects it holds, and that the members of each owner catalogue are documents of lines of its owner that the storage root holds (section 8.1); that <verbatim|drafts> lists only drafts of the storage root, with their heads; and, a breach being a warning, that <verbatim|extensions> lists every extension its objects use;

    <item><strong|the tombstones> (section 13.3): that each is well formed, with <verbatim|id> the line of its <verbatim|name> and <verbatim|owner>; that no two have the same <verbatim|id>; and that no object of the storage root, and no entry of <verbatim|objects>, has the <verbatim|id> of one; and, as a warning, that no tombstone stands for an owner object that objects of the archive need, which only the law or its keeper justifies (section 13.2);

    <item><strong|the indexes> it declares (section 12.5): that every object with a genesis record and every sealed version, carried key-log versions included, has its entry, in the file of its prefix, with the values its object gives; that each tombstone has its entries in <verbatim|names/> and <verbatim|sha512/>, with <verbatim|status> <verbatim|removed>, and none in <verbatim|owners/>; that no draft has one; and, with access to the files, that there are no other entries.
  </itemize>

  <strong|Beyond the archive.> A verifier SHOULD check the copies it knows elsewhere (the sources of mirrors, members, parents, longer key logs): whether they agree (section 7.4), reporting a fork of a line with the status of each side and where each copy was found, a later version of a key log (section 6.5), and a fork of a key log between its copy and copies elsewhere, with its fork point (section 6.3). It SHOULD check the requirements of the profiles the archive declares (appendix A), the witnesses it finds and the extensions it knows, and warns of those it does not know (sections 2 and 7.2).

  <section*|15. Security, privacy and rights><label|15-security-privacy-and-rights>

  <subsection*|15.1 What the format protects><label|151-what-the-format-protects>

  Pins and signatures make every copy checkable wherever it is fetched (sections 4 and 7); discovery documents, indexes, locations and tombstones are maps and hints (sections 3, 12.3 and 13.3). A host or a network therefore cannot forge a version, nor add one to another owner's line (section 7.5), nor make a valid line from a reused genesis record (section 5.4), nor take over a short form (section 12.2). It can withhold: serve an older copy, or a key log that stops before an end or a fork record, which looks complete (sections 6.5 and 12.3); and it can delete what it serves, never a copy held elsewhere (section 13).

  Whoever holds <verbatim|threshold> current keys of an owner signs versions of its lines as that owner until the owner exposes them, after which what those keys alone sign is contested, and archives aware of it never add it (sections 7.3 and 7.5), though readers still find its signatures good; it cannot change the key log, which only rotation keys sign. Whoever holds <verbatim|nextThreshold> rotation keys of the latest version of a key log, not revealed, takes the owner over (with a <verbatim|nextThreshold> of 1, a single key, section 6.2), without a fork, by signing the next version with keys of its own; the owner can then only end it, and only if it still holds copies of those keys itself, by signing another version of that number, a fork (section 6.3). Whoever holds <verbatim|nextThreshold> rotation keys of an earlier version, kept after use, can fork the key log there, which ends the owner and freezes it (section 7.5). No one can fork a key log at its first version, which is computed from the genesis record (section 6.1). The format cannot tell what was signed before an exposure from what was signed after (section 6.4).

  <strong|The keeper.> The keeper an owner names, at most one, fixed by its owner name, names the accepted successor when no ending version before any fork point names one, and may have the owner object taken down from an archive that keeps it (sections 6.6 and 13.2). Whoever controls the keeper's ORCID record or domain holds these powers, also after a domain lapses and is registered by someone else, or an account is taken over; an owner whose keeper may lapse is better named with an institution's domain, or with no keeper.

  <strong|Residual risks.> The format leaves these to readers and to other evidence:

  <\itemize>
    <item>a host can withhold an exposure or a fork record, serving a key log that stops before it, so that its readers find signed and uncontested what is contested elsewhere, and an archive it serves does not yet freeze the owner (sections 6.5 and 7.5);

    <item>archives that see one side of a fork and not yet the other show different views of the owner until a copy holding both reaches them (section 6.3);

    <item>whoever holds the old current keys of an owner that ended honestly signs versions of its lines naming key-log versions before the end, which are signed and not contested unless those keys were exposed; archives take them only from copies (section 7.5), which the holder can make;

    <item>a thief gains no forgery by forking a key log, since the fork freezes the owner and what it signs is contested; but on its side it may expose the owner's earlier keys, which makes the owner's own versions signed with them contested unless trusted evidence dates them (sections 6.3 and 7.3): this harms trust in the owner's past, and never lets a forgery pass; and an owner whose rotation keys are stolen can add nothing more under that identity, and continues under a successor (sections 6.6 and 7.5);

    <item>a timestamp dates what a thief signs between a theft and its exposure as well as what the owner signed, so evidence that dates a version before the exposure admits both (section 7.3);

    <item>a retired key never exposed still makes good, uncontested signatures naming the versions that list it (section 6.2); an owner unsure that a retired key is destroyed exposes it;

    <item>the keeper, as above.
  </itemize>

  <strong|Forks of a line.> A fork of a line (section 7.4), whose sides are both signed, ends nothing by itself; whether to end is the owner's call. If the owner did not make both sides, its current keys may have been exposed, and section 6.3 applies; if it did (two tools, a version made again), it continues from one side, and archives holding the other keep it (section 7.5).

  <strong|What a signature shows.> A good signature shows that a key of the owner's key log signed one object version and one key-log version (section 7.2); not who wrote the document (section 4.4), who the owner is (section 6.6), when it was signed, or that no later version exists.

  <subsection*|15.2 Untrusted input><label|152-untrusted-input>

  Every file a program reads is untrusted until checked, also in its own storage root. A program reading files (a verifier, a resolver, an archive copying a line, a tool recreating files in a draft):

  <\itemize>
    <item>MUST NOT read or write outside the object, or outside the folder it writes into, whatever path a file gives (logical and content paths, the <verbatim|path> of notes and renditions, entries of an archive file such as <verbatim|sources.zip>, appendix A), and MUST NOT follow symbolic links; a path that breaks section 4.1 is never followed;

    <item>SHOULD bound the size of what it fetches or unpacks, the number of objects, versions, files and members, the depth of chains and collections (section 9.3) and its time, and reports where it stops (section 14.1);

    <item>MUST show the texts of these files (titles, abstracts, notes, reasons) as text, never as HTML, and SHOULD render their mathematics (section 4.4) with a renderer that runs no scripts and follows no links;

    <item>when it fetches URLs found in files on behalf of others (a custodian, an index service), follows the rule of section 12.6 for gateways.
  </itemize>

  Deposited sources are code: a tool building renditions from sources it did not write SHOULD run the toolchain isolated, without shell escapes. MD5 (section 4.1) and SHA-1 (git) serve only comparison with external services, never integrity (section 7.6).

  <subsection*|15.3 Serving and presentation><label|153-serving-and-presentation>

  An archive does not vouch for the files of its objects (section 3). Its presentation files MUST NOT include files of objects, or pages of other archives, as HTML or scripts; they link to them. An archive SHOULD serve its storage root so that its files run no scripts in the origin of its presentation files: from another origin, or with <verbatim|Content-Security-Policy: sandbox>. A host that sets no response headers and serves the archive from one origin (GitHub Pages) can do neither; its presentation files SHOULD then keep no state of their own (cookies, logins, stored data) that a script among the files of objects could reach. A gateway serves no archive's files (section 12.6).

  <subsection*|15.4 Keys and secrets><label|154-keys-and-secrets>

  Private keys, and other secrets (tokens of external services, the secrets of a review), MUST NOT be stored in an archive: in an object, a witness folder, a draft, presentation files, or the repository of an archive kept in git. Whatever an archive holds, a private archive included (section 3.1), may be made public and copied.

  <subsection*|15.5 Privacy><label|155-privacy>

  What an archive serves is public, its drafts included (section 10.1); a sealed version, its witnesses and the key logs beside it travel with every copy and branch, and never change.

  <\itemize>
    <item><strong|Personal data.> Archives record only the personal data needed to describe and cite a work (section 4.4) and the depositor of each version (section 4.1), whose <verbatim|address> SHOULD be a public identifier (an ORCID iD) rather than a personal e-mail address.

    <item><strong|Owners.> An owner name is the digest of a record with a random nonce, and identifies no one. An owner is tied to a person only by what its versions say (<verbatim|creators>, <verbatim|user>, <verbatim|agreement>), by keys it shares with another owner, and by its keeper, who alone confirms that link and can withdraw the confirmation (section 6.6), though <verbatim|keeper> stays in the genesis record. An owner that must stay anonymous (a referee) SHOULD have its own keys and no <verbatim|keeper>, and its versions SHOULD NOT identify the person.

    <item><strong|Erasure.> Personal data is erased by a takedown (section 13.2), from that archive and its indexes only. The tombstone and index entries keep only names, owner names and digests, which identify no one (section 13.3); an archive kept in git also rewrites its history (<hlink|OpenSheaf archives in git|opensheaf-git-0.2.tm>, section 9).
  </itemize>

  <subsection*|15.6 Rights><label|156-rights>

  <strong|Metadata.> The JSON files this specification defines, inventories with their checksum files, fork records and the evidence of branches are metadata, texts of notes and abstracts included. Whoever writes them dedicates them to the public domain under CC0 1.0, so that they can be harvested and copied freely; an archive admits only owners that accept this. Files of notes (section 4.3) are content.

  <strong|Content.> The files of a document version are under the licence its owner states (sections 4.3 and 4.4); "All rights reserved" is allowed, since depositing grants readers access, not reuse. Copies and branches keep the licences of what they copy; whoever keeps them is responsible for having the right to redistribute it (sections 9.7 and 11.2).

  <strong|Open questions.>

  <\itemize>
    <item>How a referee's commitment is written as a creator in DataCite, and exactly what is hashed (#63).

    <item>Tying owners to ORCID iDs and domains beyond the keeper (#41).

    <item>How an archive on a host that sets no response headers (GitHub Pages) keeps the files of its objects from running scripts in the origin of its presentation files, while search engines want its PDFs on the host of its landing pages (section 15.3, appendix A.3) (#64).
  </itemize>

  <section*|16. Versioning of this specification><label|16-versioning-of-this-specification>

  <subsection*|16.1 Versions><label|161-versions>

  This specification is versioned MAJOR.MINOR.PATCH:

  <\itemize>
    <item>a <strong|major> version (1.0, 2.0) MAY make incompatible changes;

    <item>a <strong|minor> version (1.1, 1.2) only adds: every file valid under 1.x stays valid under 1.y, for y greater than x, with the same meaning;

    <item>a <strong|patch> version (1.1.1) corrects or clarifies the text, and changes no requirement.
  </itemize>

  Before 1.0, a minor version MAY be incompatible with the one before it. Version 0.2 is incompatible with version 0.1: it changes the format names, owners, signatures and storage layout. <hlink|Version 0.1|opensheaf-specification-0.1.tm> is kept as published; archives made under it remain readable as 0.1, by its text, and move to 0.2 by being rebuilt. A reader tells them apart by <verbatim|specification> in the discovery document and in every <verbatim|object.json>, and by the format names (<verbatim|opensheaf-object/0.1> or <verbatim|opensheaf-object/0.2>): a discovery document with <verbatim|specification> <verbatim|"0.1"> is of a 0.1 archive, and one without <verbatim|specification>, or whose <verbatim|format> and <verbatim|specification> disagree, is of no version this specification defines (below). A draft MAY change in any way; archives made with a draft are rebuilt when its version is final. Drafts are told apart by the date in the heading and by the changelog (section 16.2).

  <strong|In files.> Files record the version as MAJOR.MINOR only, since a patch changes nothing that is valid: in the name of every format (<verbatim|"opensheaf-object/0.2">), and in <verbatim|specification> of the discovery document and of every <verbatim|object.json> (sections 3.1 and 4.3).

  <strong|Readers.> A reader that finds a major version it does not know, or before 1.0 a minor version it does not know, SHOULD report it, and MUST NOT treat the files as valid. From 1.0, a reader that finds a later minor version of a major version it knows reads the files as of that major version, ignores the properties it does not know, and SHOULD report the version; it does not validate such files against the schemas of its own version (section 2).

  <strong|Publication.> The text of each version is published at <verbatim|https://opensheaf.org/opensheaf-specification-\<less\>MAJOR.MINOR\<gtr\>.md>, with its schemas (appendix B), and is not changed once final, except by patch versions, listed in its changelog.

  <subsection*|16.2 Changelog><label|162-changelog>

  <\itemize>
    <item><strong|0.1, 13 November 2026:> first version, revised to 16 November 2026, kept as published at <hlink|opensheaf-specification-0.1.md|opensheaf-specification-0.1.tm>.

    <item><strong|0.2 (draft), 14 to 19 November 2026: from 0.1, by PR #30.> Incompatible with 0.1 (section 16.1): objects are named by the digests of their genesis records (section 5); owners, named the same way, sign through key logs with pre-rotation (section 6); objects are lines of signed versions, and branches hold their branch point with its evidence (sections 7 and 9); <verbatim|sheaf:> URIs name lines, versions and pins (section 12.1); the inventory chain, <verbatim|previous> (section 4.3); the owner-name storage layout, the default (section 3.2); drafts (section 10.1); indexes (section 12.5); every removal a takedown, with tombstones (section 13); every format name and <verbatim|specification> become <verbatim|0.2>. Timestamps moved to the <hlink|timestamps extension|opensheaf-timestamps-0.2.tm>, and the <hlink|git companion|opensheaf-git-0.2.tm> follows. The revisions below are its history as a draft.

    <item><strong|0.2 (draft), 14 to 18 November 2026:> the proposal of PR #30 (names from genesis records, owners and key logs, lines, branches, <verbatim|sheaf:> URIs, signatures) and its reviews, each listed in the changelog of the <hlink|reference text|reference/opensheaf-specification-0.1-full.md>, where they are written as revisions of 0.1.

    <item><strong|0.2 (draft), 18 November 2026, rebuilt (PR #30):> the text rebuilt concept by concept into a shorter whole, from the reference text. Decided in the rebuild: archives are named by no file, and <verbatim|replicas> is dropped (section 3); external records are witnesses, not copies (section 12.3); index declarations name only <verbatim|names>, <verbatim|owners> and <verbatim|sha512> (section 12.5); every removal is a takedown, and tombstones are required once an object is taken down (section 13); drafts are never withdrawn; key-log forks are recorded by fork records, which nullify the keys involved, and healed by the owner, versions of key logs being replaced only there (section 6.3, provisional, #58); findings are errors, warnings or results (section 14.1); security, privacy and rights rewritten (section 15); <verbatim|licence> for documents only; logical paths exclude empty segments, a final <verbatim|/> and <verbatim|\\> (section 4.1).

    <item><strong|0.2 (draft), 19 November 2026 (PR #30):> the rebuilt text completed and audited. Appendices A (profiles), B (JSON Schemas) and C (examples, computed and checked against the schemas) rebuilt; DOIs written bare; conformance classes; one status rule for lines, read from the latest signed version (section 13.1); signature files closed to other properties, and owner names, <verbatim|did:key> URIs and ORCID check digits checked exactly (appendix B, sections 6.6 and 14.3). Key logs, provisional (#58), replacing the fork records that nullified keys and the healing of the rebuilt text: pre-rotation, as in KERI, current keys (<verbatim|keys>, <verbatim|threshold>) signing lines, and each version committing in <verbatim|next> and <verbatim|nextThreshold> to the digests of the rotation keys that alone sign the next one, each committed in one version only and never made current, with three rotation keys and a threshold of 2 recommended and one offline key with a threshold of 1 allowed, its risk stated (sections 6.1 and 6.2); the first version of a key log computed from the owner's genesis record, byte for byte, and never signed (section 6.1); the keeper, at most one, and the data of extensions of the first version fixed in that genesis record (sections 5.1 and 6.6); <verbatim|exposed>, in a version that whoever holds current keys cannot contest, an exposure counting in any version, on either side of a fork (section 6.3); an ending version without keys, and at most one accepted successor (sections 6.3 and 6.6); a fork of a key log ends the owner, the archive keeping the side it saw first and appending a fork record that carries the other, and freezes it, nothing more being added unless trusted evidence dates it before the fork (sections 6.3 and 7.5); one status, contested, for versions of lines that need an exposed key or name a key-log version from a fork point on, which owner tools show before extending them, and which an owner not ended may sign again (sections 6.4, 7.1 and 7.3); owner objects taken down only by law or at the keeper's request (section 13.2); strict Ed25519 verification (section 7.2). The inventory chain: every sealed version after the first has <verbatim|previous> in <verbatim|object.json>, the digest of the inventory file before it, so that signing a version fixes the bytes of every earlier inventory, and pins of versions vouched for are as reliable as those of versions signed directly (sections 4, 4.3, 7.3 and 14.2; #46). The owner-name layout is described by the plain text file <verbatim|opensheaf-owner-name-storage-layout.md> in the storage root instead of <verbatim|ocfl_layout.json>, which names only registered OCFL extensions, the discovery document being authoritative (sections 3.2 and 14.2). Readability: the rules of sections 6.1, 6.3, 7.3 and 14.3 numbered, a walkthrough of the common path at the head of appendix C, and clarifications on names of algorithms 1 to 15 (section 5.2), the owners of the main catalogue (section 8.1), drafts and OCFL (section 10.1), rules not checked from the files (section 14) and the validation of <verbatim|datacite.json> (appendix B); rules stated once; the checks of section 14 and the risks of section 15.1 completed.

    <item><strong|0.2 (draft), 19 November 2026:> the text of PR #30 named version 0.2, version 0.1 being kept as published: format names, <verbatim|specification>, the extension URI of the timestamps extension, the schemas and their file names set to 0.2, and the examples of appendix C recomputed, since format names enter names and signatures; section 16.1 states how 0.2 and 0.1 differ.

    <item><strong|0.2 (draft), 20 November 2026:> editorial: the link to the KERI specification, which has moved, updated (appendix E).

    <item><strong|0.2 (draft), 20 November 2026:> ambiguities found while implementing the reference tools resolved. Clarified: a reader's configuration may map locations (section 12.3); an owner part of 52 characters is of algorithm 0 (section 12.1); the checksum file and the inventory bytes give the same digest (section 4); <verbatim|status> of a copy without a signed version (section 3.1); the main catalogue may be curated (section 8.1); a version signed directly with an exposed key and vouched for cleanly is not contested (section 7.3); a fork record copied byte for byte from a longer copy, and readers meeting copies of a key log (sections 6.3 and 6.5); the <verbatim|sha512/> entries of a removed object (section 12.5); indexes not checked complete over HTTP (section 14.1); telling 0.1 from 0.2 (section 16.1); Zenodo, an owner ended during a deposit, and the genesis record uploaded (appendix A.1). Decided: numbers are integers, exactly, in genesis records and <verbatim|keys.json> also in extensions (section 2); signatures in canonical base64, and <verbatim|R> canonical (section 7.2); copies agree at their latest signed versions, versions after them making no fork (sections 7.4, 7.5 and 15.1); a version is unchecked when the threshold of the key-log version named is unknown, and when a reader without the key log cannot find signature files (section 7.3); owner tools sign over versions not signed only once the owner acknowledges them (section 7.3); files beside carried signatures read as witnesses, and carried inventories checked by their signatures only (section 6.3); <verbatim|parent.signatures/> holds good signature files only (section 9.2); a branch of the same parent line at the same or an earlier point refused, not renamed (section 9.4); selections of one owner share its accepted copy (sections 9.6 and 14.5); what sealing keeps from a draft (section 10.2); unknown parameters of <verbatim|sheaf:> URIs anywhere, written last (section 12.1); finding the archive of <verbatim|parent.url> (section 12.3); landing pages give the canonical form and have an address per line (section 12.2, appendix A.3); a line returns only from a copy holding the pinned version (section 13.2); the main catalogue drops a line taken down (section 13.2); the index page when the main catalogue has no signed version (appendix A.3). Open: hosts that set no headers and <verbatim|Content-Security-Policy: sandbox> (section 15.3); depositing branches on Zenodo (appendix A.1).

    <item><strong|0.2 (draft), 20 November 2026:> editorial, from a triage of the issues: the rule that a tombstone does not stop resolution at copies elsewhere (section 12.3) marked provisional, as sections 12.6 and 13.3 list it as open (#66); open questions added to section 4.2 for what a description-only version may change (#24) and for the identity of notices (#26); two open questions pointed to the issues that hold them (#35, #20).

    <item><strong|0.2 (draft), 21 November 2026:> editorial: open questions added to section 3.1 for paging the discovery document (#19) and for archives serving part of their lines (#29); the open question of #37 in section 14.6 restated, locations being tried in any order (section 12.3).

    <item><strong|0.2 (draft), 21 November 2026:> decided in #55: the field names of <verbatim|keys.json>, of signature files and of the evidence of branches are those of the text; the lines of the signed message are named as the fields of the signature file, <verbatim|inventorySha512> and <verbatim|keyLog> (section 7.2), so every signature changes (appendix C recomputed); the evidence of a branch point is the folder <verbatim|parent/>, with <verbatim|parent/inventory.json>, <verbatim|parent/object.json>, <verbatim|parent/signatures/> and <verbatim|parent/parent/> for a branch of a branch, <verbatim|parent> being the reserved name (sections 4.1 and 9.2); exposing keys from when an archive learns of it, with no dated signatures in the core, is kept against backdating (section 6.4 and appendix D).

    <item><strong|0.2 (draft), 21 November 2026:> decided in #58: pre-rotation, exposed keys, fork records and a fork that ends and freezes the owner are no longer provisional (sections 6.1 to 6.4, 7.5, 14.6 and C.8); a reader holding one side of a fork sees no fork, and verifiers report the key-log version they judged against (section 6.5); weighted thresholds (#69) and witnesses of the versions of key logs seen first (#70) are left for after 0.2.

    <item><strong|0.2 (draft), 22 November 2026:> decided in #72 (follow-up): <verbatim|owners> of the discovery document is required, empty for an archive that hosts no owner, and the rule for an archive without it is removed (sections 3.1 and 8.1, appendix B); the index page presents the members of the owner catalogues grouped by owner, in the order of <verbatim|owners>, or together, naming the owner of each when the archive hosts several (appendix A.3).

    <item><strong|0.2 (draft), 22 November 2026:> decided in #27: <verbatim|cite> caches the member's <verbatim|Available> date in <verbatim|available>, beside <verbatim|issued>, so that an <verbatim|order> by date is followed from <verbatim|members.json> alone (section 8.2); the open question of section 8.6 removed.

    <item><strong|0.2 (draft), 22 November 2026:> decided in #44: no aliases; a work refused for a reused genesis record is sealed anew and MAY relate to the version it was refused as (section 5.4, appendix D); the open question of section 5.4 removed.

    <item><strong|0.2 (draft), 22 November 2026:> decided in #57: a branch numbers its own document versions from 1, <verbatim|parent.documentVersion> keeping the parent's number (sections 9.4 and 12.1); "moving the branch point" renamed taking a new branch point, by a new object version of the same branch, which is a new document version and keeps the branch's own notices with their files, the parent's notices staying in its evidence (sections 9.3 and 9.4); a line takes in another line's work by depositing it with a relation to the version taken in (sections 5.3 and 9.5); the open questions of sections 9.7 and 12.6 on branches removed.

    <item><strong|0.2 (draft), 22 November 2026:> decided in #25: a withdrawal withdraws every document version deposited before it, and later description-only versions keep it; a new document version reinstates the line, the versions withdrawn staying withdrawn, and a later withdrawal is possible; a new document version is never a withdrawal; an ended owner withdraws nothing; verifiers report members pinning a withdrawn document version (sections 13.1, 14.4 and 14.5, appendix D); the open questions of sections 13.3 and 14.6 on withdrawal removed.

    <item><strong|0.2 (draft), 22 November 2026:> decided in #49: digests in inventories and checksum files MUST be in lower case (section 4.1, appendix D); the item is removed from the open questions of section 14.6.

    <item><strong|0.2 (draft), 22 November 2026:> decided in #51: a deposit out of order is recorded by writing <verbatim|history>, which defines the history, in place of a requirement verifiers cannot check; a version deposited without it is the current version (section 4.2, appendix D); the item is removed from the open questions of section 14.6.

    <item><strong|0.2 (draft), 22 November 2026:> decided in #29: an archive need not be public, and serves all its lines or none; an owner publishes lines kept privately by copying them into a public archive, the same lines (section 3.1); the <verbatim|at> of a member in a private archive is the base URL at which it is kept (section 8.2); <verbatim|Available> is the deposit, whether the archive is public or not, unless the version appeared elsewhere first, and <verbatim|Created> dates a version deposited later (section 4.4); drafts are not shared as objects, and whatever a recipient relies on is sealed (section 10.2); what an archive holds may be made public (section 15.4); the open questions of sections 3.1 and 10.2 removed, and that of section 15 on referees pointed to #63 (appendix D).

    <item><strong|0.2 (draft), 22 November 2026:> decided in #50 and #34: an entry of <verbatim|rightsList> with <verbatim|rightsIdentifier> or <verbatim|rightsUri> is a licence, one with neither a rights statement (section 4.4); an archive keeping a mirror or a branch is responsible for having the right to redistribute what it copies, by licence, agreement or law, which the specification does not judge and verifiers do not check (sections 9.7, 11.2 and 15.6, appendix D); the open questions of sections 11.2, 14.6 and 15.6 on licences removed.

    <item><strong|0.2 (draft), 22 November 2026:> decided in #48 and #37: whether a copy matches a pin is decided by the bytes of its inventory file, a checksum file missing or wrong being reported with its location without making the copy fail; a pin is a mismatch only if no copy found matches, every copy that does not match being reported with its location, and a resolver MAY stop at the first copy that matches (sections 8.5, 12.3 and 14.5, appendix D); the open questions of sections 8.5 and 14.6 removed.

    <item><strong|0.2 (draft), 22 November 2026:> decided in #66 and #33: a tombstone speaks for its archive only and does not stop resolution at copies elsewhere, no longer provisionally (sections 12.3 and 13.3); mirrors, branches, indexes kept by others, gateways and external records do not follow a takedown by themselves, each answering for what it serves, content to be removed everywhere being taken down at each archive at a request to each, and tools report the tombstones they meet; no signed takedown requests in the format, an owner withdrawing instead; tombstones keep one pin, earlier versions being reported as removed (section 13.3, appendix D); the open questions of sections 11.2, 12.6, 13.3, 15.6 and appendix A on takedowns removed.

    <item><strong|0.2 (draft), 22 November 2026:> decided in #19: <verbatim|objects> may be paged, by <verbatim|objectPages> and page files of format <verbatim|opensheaf-objects/0.2>, which tools SHOULD use beyond about a thousand objects (section 3.1, appendix B, with a new schema); the feed SHOULD hold the recent versions and MAY link archived feeds (RFC 5005, appendix A.3); a verifier MAY check part of an archive (section 14.1); the open question of section 3.1 removed (appendix D).

    <item><strong|0.2 (draft), 22 November 2026:> decided in #26: a notice is numbered by its position in <verbatim|notices>, kept in order in every later version; a later notice about the same document version corrects or withdraws one by naming it in <verbatim|replaces>, each notice being replaced at most once; the current notices are those not replaced; the <verbatim|date> of a notice is the date its author issued it, not later than its deposit (sections 4.2, 4.3 and 14.4, appendix D).

    <item><strong|0.2 (draft), 22 November 2026:> decided in #24, #45 and #27 (its first point): a collection is a document whose source is <verbatim|members.json>, with renditions and the fields of a document but <verbatim|mainSource>, <verbatim|sourceFormat>, <verbatim|sourcesMissing> and <verbatim|licence>, so any change of <verbatim|members.json> is a new document version and a description-only version of a collection may hold an earlier member list (sections 4.2, 4.3 and 8.2); a description-only version changes the description of the object and adds to <verbatim|external>, while <verbatim|mainSource>, <verbatim|sourceFormat>, <verbatim|sourcesMissing>, <verbatim|renditions> and <verbatim|toolchain> belong to the document version, except as a completion adds to them (section 4.2); a followed member moves with new document versions of its catalogue only (section 8.3); verifiers resolve the members of the current version (sections 14.4 and 14.5, appendix D).

    <item><strong|0.2 (draft), 21 November 2026:> decided in #23: a new document version is made when the own files differ from those of the current version, compared by logical path and digest, so that a rename is a change; an object version holding an existing document version holds exactly its files; files of an earlier version deposited again are a revert, a new document version (section 4.2, appendix D).

    <item><strong|0.2 (draft), 22 November 2026:> decided in #72: each owner an archive hosts has an owner catalogue there, a catalogue of that owner created when the owner is set up, listing the documents of its own lines in the archive, branches included, and changed by that owner only; it replaces the archive's main catalogue, and is never mirrored (sections 8.1, 9 and 11.1); <verbatim|owners> of the discovery document becomes recommended and names each owner with its catalogue, in the order of presentation, and <verbatim|mainCollection> is dropped (section 3.1, appendix B); the index page presents the owner catalogues in that order (appendix A.3); verifiers check <verbatim|owners> and the owner catalogues (section 14.6); a takedown is followed by a version of the owner catalogue that listed the line (section 13.2); appendix C and the rationale (appendix D) updated. Binding a catalogue to its archive, keys an archive requires to create lines, and an archive-wide selection over the owner catalogues are left open (#72).
  </itemize>

  <section*|Appendix A. Profiles (normative for archives declaring them)><label|appendix-a-profiles-normative-for-archives-declaring-them>

  A <dfn|profile> is a set of rules for an external service or a tool, normative for an archive that lists it in <verbatim|profiles> (sections 2 and 3.1), and checked by verifiers (section 14.6). A profile only adds rules. They apply to the versions that owners make in the archive, never to copies of lines made elsewhere (section 11); only sealed, signed versions are deposited (sections 7.3 and 10.1).

  <subsection*|A.1 Zenodo (<verbatim|zenodo>)><label|a1-zenodo-zenodo>

  Zenodo registers DataCite DOIs (prefix <verbatim|10.5281>) and keeps files permanently. A record is a witness of the versions it holds, not a copy (section 12.3).

  <\itemize>
    <item><strong|Records.> Each line of a document is one record, whose concept DOI stands for the line. Each document version is one version of the record, with its own DOI, the document version as Zenodo's version, and the Zenodo type <verbatim|publication-preprint> or the one matching <verbatim|resourceTypeGeneral>. A branch is a record of its own, and deposits a version holding the files of its branch point only when the parent version has no DOI (section 9.7).

    <item><strong|Fixed files.> A description-only version (section 4.2) edits the metadata of the record version of the document version it holds; the files it adds, and the sources added by a completion (section 4.2), are not uploaded, since the files of a published record version are fixed. Archives MUST NOT use Zenodo's 30-day window for changing them: a correction is a new document version.

    <item><strong|Versions out of order.> Zenodo orders the versions of a record by publication, and its concept DOI leads to the latest. A document version deposited out of order (section 4.2) MAY be deposited only as a record of its own, with <verbatim|IsVersionOf> the concept DOI.

    <item><strong|Files.> The record version holds the content files of the object version, the genesis record included. Records have no folders and a limited number of files: sources with sub-folders, or too many, are uploaded as one file <verbatim|sources.zip>, at their logical paths, its entries in the byte order of their names, dated 1980-01-01 00:00:00, without extra fields. The inventories of the line MUST record in <verbatim|fixity> the MD5 digest of every content file (section 4.1), to be compared with the checksums Zenodo reports.

    <item><strong|The deposit recorded.> The object version deposited has its DOI in <verbatim|datacite.json> and, in <verbatim|external> of <verbatim|object.json> (section 4.3), an entry with <verbatim|role> <verbatim|deposit>, <verbatim|service> <verbatim|Zenodo>, <verbatim|record> the URL of the record version, <verbatim|doi> and, for <verbatim|sources.zip>, <verbatim|files>, with its <verbatim|md5>.

    <item><strong|Order of operations.> (1) Create an unpublished version of the record (a new version inherits the files of the previous one, which are deleted). (2) Reserve its DOI. (3) Build the object version in a staging area, with that DOI, and have its owner sign it (section 7.1). (4) Upload the files, and compare their MD5 checksums with the fixity block, and that of <verbatim|sources.zip> with its <verbatim|md5> in <verbatim|external>. (5) Publish. (6) Add the object version with its signature files (section 7.5), and update the discovery document. If a step fails before publication, the unpublished version is discarded; if step 6 fails after it, the tool MUST complete step 6 from the staging area before any other deposit of the line, signing the version again with current keys not exposed (section 7.1) if a key that signed it was exposed meanwhile. If the owner has ended meanwhile, the version is not added, since nothing is signed for an ended owner and its lines take no new deposits (sections 6.3 and 7.5): the tool reports the published record, which then witnesses no version the archive holds. A tool SHOULD hold a lock per line during a deposit, since Zenodo allows one unpublished version per record. DOIs of Zenodo's sandbox are not registered, and MUST NOT be recorded in an archive.

    <item><strong|Metadata.> Zenodo's DataCite record of a DOI has Zenodo's landing page as <verbatim|url>, Zenodo as <verbatim|publisher> (which <verbatim|datacite.json> MAY also name, section 4.4), relations of its own, and only the properties Zenodo keeps. <verbatim|datacite.json> stays authoritative; verifiers compare the DOI, <verbatim|titles>, <verbatim|creators>, <verbatim|publicationYear> and <verbatim|version> of the two, a difference being a warning.

    <item><strong|Collections.> A collection MAY be deposited when its curator releases it, not at every change, as a record of type <verbatim|other> whose files include <verbatim|members.json>. A Zenodo community MAY group an archive's records for browsing; it is not authoritative.
  </itemize>

  <strong|Open question.> How a branch is deposited: the evidence of its branch point (the folder <verbatim|parent/>) has folders, which records do not, and is not sources, which <verbatim|sources.zip> holds (#65).

  <subsection*|A.2 TeXmacs (<verbatim|texmacs>)><label|a2-texmacs-texmacs>

  For a document whose main source is a TeXmacs document:

  <\itemize>
    <item><verbatim|sourceFormat> is <verbatim|application/x-texmacs> (not a registered media type; the type TeXmacs uses);

    <item><verbatim|toolchain> has an entry for TeXmacs with its version, whose <verbatim|packages> list the style packages and plugins used that are not part of the TeXmacs distribution;

    <item>renditions are produced without regenerating bibliographies or tables of contents, so that the sources, with the references stored in them, reproduce the renditions; the sources SHOULD nevertheless include the bibliography databases used;

    <item>HTML presentation files are exported from a copy of the sources, with presentation packages added to its style, and the deposited sources are never changed.
  </itemize>

  An archive kept inside a website built with the TeXmacs website converter SHOULD place an empty file <verbatim|.texmacs-noconvert> at its top (honoured by the <verbatim|max-html> plugin), so that the converter never rewrites its files.

  <subsection*|A.3 Website (<verbatim|website>)><label|a3-website-website>

  Presentation files (section 3) are generated from the storage root, never edited by hand, and regenerated after every change, a takedown included (section 13.2). Under this profile:

  <\itemize>
    <item><strong|Index.> An index page presents the members of the owner catalogues (section 8.1) of the owners the archive hosts, of each the latest signed version (section 7.3), either grouped by owner, in the order of <verbatim|owners> (section 3.1) and each catalogue in its order, or together in one list that names the owner of each member when the archive hosts several, possibly over several pages; other collections MAY have pages of their own. When an owner catalogue has no signed version (its versions contested after an exposure, or unchecked), the index page presents none of its members and says why, until its owner, if not ended, signs a version again (section 7.1). A flattened list, not authoritative, for programs that do not read OCFL MAY be published as <verbatim|catalog.json>.

    <item><strong|Landing pages.> Each line listed by an owner catalogue has one landing page, at an address of the archive's choice, distinct for each line and not an identifier (from its label, section 3.1, or for a line without one from its name, and its owner name when the archive holds several lines of that name), for its current version (section 4.2), giving the full <verbatim|sheaf:> URI of the line in canonical form (sections 12.1 and 12.2) and every signed document version in the order of the history, each with its external labels, stage, change note, notices, renditions, sources and DOI, and the withdrawal if any (sections 4.2, 4.3 and 13.1).

    <item><strong|Search engines.> Landing pages MUST carry the meta tags read by Google Scholar: <verbatim|citation_title>, <verbatim|citation_author> (one per creator), <verbatim|citation_publication_date> (the <verbatim|Issued> date, or else the <verbatim|Available> date of the current version) and <verbatim|citation_pdf_url>, a PDF on the landing page's host (served, where the host allows, with <verbatim|Content-Security-Policy: sandbox>, section 15.3). They SHOULD carry schema.org <verbatim|ScholarlyArticle> JSON-LD and FAIR Signposting links (<verbatim|cite-as>, <verbatim|describedby>, <verbatim|item>, <verbatim|license>), and offer BibTeX and CSL-JSON entries made from <verbatim|datacite.json>.

    <item><strong|Feed and harvesters.> The feed (<verbatim|feed>, section 3.1) lists the signed object versions the archive holds, by the <verbatim|created> date of their inventories. It SHOULD hold the recent versions only, and MAY link the earlier ones as archived feeds (RFC 5005). The website SHOULD publish a <verbatim|sitemap.xml>, and MAY publish an OAI-PMH static repository or a ResourceSync description.
  </itemize>

  <section*|Appendix B. JSON Schemas (normative)><label|appendix-b-json-schemas-normative>

  The schemas are written in JSON Schema 2020-12, published at <verbatim|https://opensheaf.org/schemas/\<less\>file\<gtr\>>, their <verbatim|$id>, and dedicated to the public domain under CC0 1.0 (section 15.6). They validate:

  <\itemize>
    <item><verbatim|opensheaf-archive-0.2.schema.json>: <verbatim|opensheaf.json> (section 3.1);

    <item><verbatim|opensheaf-objects-0.2.schema.json>: the pages of <verbatim|objects> (section 3.1);

    <item><verbatim|opensheaf-object-0.2.schema.json>: <verbatim|object.json>, also as <verbatim|parent/object.json> and in <verbatim|parent/parent/> (sections 4.3 and 9.2);

    <item><verbatim|opensheaf-collection-0.2.schema.json>: <verbatim|members.json> (section 8.2);

    <item><verbatim|opensheaf-genesis-0.2.schema.json>: <verbatim|genesis.json> (section 5.1);

    <item><verbatim|opensheaf-keys-0.2.schema.json>: <verbatim|keys.json>, also as carried by fork records (section 6);

    <item><verbatim|opensheaf-signature-0.2.schema.json>: signature files, wherever kept or carried, and others' <verbatim|witness-\<less\>label\<gtr\>.json> (sections 7.2 and 9.2);

    <item><verbatim|opensheaf-keeper-0.2.schema.json>: <verbatim|/.well-known/opensheaf> (section 6.6);

    <item><verbatim|opensheaf-index-0.2.schema.json>: index files and <verbatim|indexes.json> (section 12.5).
  </itemize>

  <strong|Validation.> A file is valid when it validates against its schema with <verbatim|format> asserted (section 14.2). The schemas of <verbatim|genesis.json>, <verbatim|keys.json>, signature files and the keeper's file allow no other properties; the others do, and such properties carry no meaning here (the data of extensions goes under <verbatim|extensions>, section 2). Where a schema and the text disagree, the text prevails.

  <strong|Other files.> <verbatim|datacite.json> is validated by converting it to XML against the DataCite 4.7 XML Schema, with the requirements of section 4.4. The conversion follows the correspondence between the attributes of a DOI in DataCite's REST API and the elements of DataCite XML that DataCite documents (its "DataCite XML to JSON Mapping", appendix E), property by property, for the properties of schema 4.7; a verifier without such a converter checks at least the requirements of section 4.4, and warns that the rest was not checked (section 14.1). Inventories, their checksum files and <verbatim|ocfl_layout.json> are OCFL's (section 14.2). The schema of the <hlink|timestamps extension|opensheaf-timestamps-0.2.tm> is published with it.

  <strong|Beyond the schemas.> A schema checks one file alone; whatever relates it to another file, its place, a digest or a key (names and identifiers, <verbatim|documentVersion> and <verbatim|datacite.json>, thresholds, signatures, fork records, uniqueness across entries, index prefixes) is checked by verifiers (section 14).

  <strong|Open questions.>

  <\itemize>
    <item>Registering DOIs with an archive's own DataCite prefix (a <verbatim|datacite> profile), and documents that already have a DOI elsewhere (#8).

    <item>Whether a Zenodo record version also uploads the version's inventory file, its checksum file and its signature files, so that it can be checked against a pin (#22; section 12.6).

    <item>Which converter is the reference for validating <verbatim|datacite.json> through XML, since DataCite documents the correspondence but specifies no converter for it (#60).
  </itemize>

  <section*|Appendix C. Examples (non-normative)><label|appendix-c-examples-non-normative>

  The examples follow one paper of the first archive (section 1) through an illustrative history: its owner is created, the paper is sealed and revised, kept in its owner's catalogue in the archive, and accepted by a journal, which keeps an accepted copy and lists it in an issue. The title and the authors are those of the archive; the dates, the journal and its domain are invented, and the DOIs (with Zenodo's prefix) and the ORCID iD (with a valid check digit) are placeholders. Every name, owner name, <verbatim|did:key>, file name derived from a key or a digest, and signature is computed: names from the genesis records shown (section 5.2), keys from private keys made for these examples, signatures over the messages shown (section 7.2), and inventory digests from inventories that are not shown. The exceptions are the names of the timestamp files of section C.6, which stand for tokens that are not shown, and the fingerprint of the timestamp authority, a placeholder. Every JSON file shown validates against its schema (appendix B).

  <strong|The common path.> In brief, what an owner does in the common case; the sections cited give the rules, and the examples below show the files.

  <\enumerate>
    <item><strong|Create an owner> (sections 5.1, 6.1 and 6.2). The owner tool makes a current key on each device the owner signs from, and rotation keys kept offline, apart from those devices and from each other: three hardware tokens with a <verbatim|nextThreshold> of 2, or at least a single key, printed or on a USB key, with a <verbatim|nextThreshold> of 1. It writes the owner's genesis record, with the current keys, the digests of the rotation keys and, if wanted, a keeper. The owner name is the digest of that record, and the first version of the key log is computed from it (section C.1). The rotation keys are then put away: they are used only to change keys.

    <item><strong|Deposit a paper> (sections 4, 7.1 and 10.2). When the paper first leaves the owner's hands, the tool seals it: it writes a genesis record naming the owner as <verbatim|originator>, makes the object <verbatim|sheaf:\<less\>name\<gtr\>:\<less\>owner\<gtr\>> at <verbatim|\<less\>owner\<gtr\>/\<less\>name\<gtr\>/>, whose version <verbatim|v1> holds the sources, a PDF, <verbatim|genesis.json>, <verbatim|object.json> and <verbatim|datacite.json>, and signs it with a current key, naming the latest version of the key log (sections C.2 and C.3). The owner object goes beside it in the storage root, and the discovery document lists both (section 6.5, section C.6).

    <item><strong|Make a new version> (sections 4.2, 4.3 and 7.1). A corrected paper is a new object version, <verbatim|v2>, holding document version 2. Its <verbatim|object.json> has <verbatim|previous>, the digest of the inventory file of <verbatim|v1>, and it is signed like the first; signing it fixes <verbatim|v1> too, byte for byte, so a pin of either is reliable (section C.2).

    <item><strong|Follow it in a catalogue> (sections 8.1 to 8.3). The owner catalogue, a collection of the same owner made when the archive set the owner up, pins each paper by its object version and inventory digest; with <verbatim|follow> <verbatim|latest>, its tool writes a new document version of the catalogue pinning <verbatim|v2> once <verbatim|v2> is signed (section C.4). A journal that accepts the paper keeps an accepted copy, a branch of its own, and lists it in a selection (sections C.4 and C.5).
  </enumerate>

  A new device, or a lost one, is a new version of the key log, signed by the rotation keys (section C.1); a stolen key is exposed the same way (section C.8).

  <subsection*|C.1 An owner and its key log><label|c1-an-owner-and-its-key-log>

  The genesis record of the authors' owner, which follows section 6.2: one current key, made on the laptop the authors sign from, with a <verbatim|threshold> of 1, and the digests of three rotation keys, each on a hardware token of its own kept apart, with a <verbatim|nextThreshold> of 2; the keeper, an ORCID iD, fixed with the owner name (section 6.6); and the <hlink|timestamps extension|opensheaf-timestamps-0.2.tm>, adopted with one RFC 3161 authority (a placeholder fingerprint):

  <\html-div-class|language-json>
  <\verbatim-code>
    {

    \ \ "format": "opensheaf-genesis/0.2",

    \ \ "kind": "owner",

    \ \ "created": "2026-03-01T17:40:00Z",

    \ \ "nonce": "1b4d9964664d9825076eb8558af61162",

    \ \ "keys": [

    \ \ \ \ "did:key:z6MksKLDefPeXwhL6SJCLqpW1dGZcvBjfsv9mxGCFpMkMuVW"

    \ \ ],

    \ \ "threshold": 1,

    \ \ "next": [

    \ \ \ \ "oxthfb6b4q3sqathmcpnciqggfxlr3aekgfg2tpm2lgrm2qnalha",

    \ \ \ \ "h6k4k6c5u4dusj4szwimmaa5cozrwu4jo45xa6erpjggpyvla6vq",

    \ \ \ \ "lnaifwjnrmhyjj3x7uikmzxznxfbgydi25iftupd2ktobmnpaklq"

    \ \ ],

    \ \ "nextThreshold": 2,

    \ \ "keeper": [

    \ \ \ \ "https://orcid.org/0000-0002-1234-5677"

    \ \ ],

    \ \ "extensions": {

    \ \ \ \ "https://opensheaf.org/opensheaf-timestamps-0.2": {

    \ \ \ \ \ \ "timestampAuthorities": [

    \ \ \ \ \ \ \ \ "5b4e3f0c9d2a7e18c6f4b0a39d7e2c51f8a6b3d09e4c7a12f5b8d6e3a0c9f147"

    \ \ \ \ \ \ ]

    \ \ \ \ }

    \ \ }

    }
  </verbatim-code>
  </html-div-class>

  Its name, the owner name, is <verbatim|56wo6cdpjsxk7ddgnqfp2quipfghukhtmvjuahvwzko7m4tkz3pa>: the SHA-256 digest of <verbatim|opensheaf-name-0>, a line feed and the bytes shown, with a final line feed, in base32 (section 5.2). The owner object is at <verbatim|56wo6cdpjsxk7ddgnqfp2quipfghukhtmvjuahvwzko7m4tkz3pa/56wo6cdpjsxk7ddgnqfp2quipfghukhtmvjuahvwzko7m4tkz3pa/> in the owner-name layout (section 3.2). The first version of its key log is computed from the genesis record, and holds nothing else (section 6.1): <verbatim|genesis.json>, the bytes shown; <verbatim|object.json>, whose fields every later version repeats, adding <verbatim|previous> (below); and <verbatim|keys.json>, which holds only the <verbatim|keys>, <verbatim|threshold>, <verbatim|next> and <verbatim|nextThreshold> of the genesis record. Both are the JCS form (RFC 8785) of their fields, without a final line feed:

  <\html-div-class|language-json>
  <\verbatim-code>
    {"format":"opensheaf-object/0.2","kind":"owner","name":"56wo6cdpjsxk7ddgnqfp2quipfghukhtmvjuahvwzko7m4tkz3pa","owner":"56wo6cdpjsxk7ddgnqfp2quipfghukhtmvjuahvwzko7m4tkz3pa","specification":"0.2","status":"active"}
  </verbatim-code>
  </html-div-class>

  <\html-div-class|language-json>
  <\verbatim-code>
    {"format":"opensheaf-keys/0.2","keys":["did:key:z6MksKLDefPeXwhL6SJCLqpW1dGZcvBjfsv9mxGCFpMkMuVW"],"next":["oxthfb6b4q3sqathmcpnciqggfxlr3aekgfg2tpm2lgrm2qnalha","h6k4k6c5u4dusj4szwimmaa5cozrwu4jo45xa6erpjggpyvla6vq","lnaifwjnrmhyjj3x7uikmzxznxfbgydi25iftupd2ktobmnpaklq"],"nextThreshold":2,"threshold":1}
  </verbatim-code>
  </html-div-class>

  The inventory of the first version is the JCS form of the following JSON value, shown here indented: the digests are those of the three files, <verbatim|created> is that of the genesis record, and there is no <verbatim|message> or <verbatim|user>. Its SHA-512 digest is <verbatim|afaabe7b9489bc408ecbb20e8477a7eeb4e8a0ebde0dc15e32d30be17d922207504953e3e52101015f770844449c8382c4c4d9bec472a908ed47200efaef1220>, so this version is pinned by <verbatim|sheaf:56wo6cdpjsxk7ddgnqfp2quipfghukhtmvjuahvwzko7m4tkz3pa/v1?sha512=afaabe7b9489bc408ecbb20e8477a7eeb4e8a0ebde0dc15e32d30be17d922207504953e3e52101015f770844449c8382c4c4d9bec472a908ed47200efaef1220> (section 12.1). It is not signed, and the owner object's witness folder holds no signature file for it:

  <\html-div-class|language-json>
  <\verbatim-code>
    {

    \ \ "digestAlgorithm": "sha512",

    \ \ "head": "v1",

    \ \ "id": "sheaf:56wo6cdpjsxk7ddgnqfp2quipfghukhtmvjuahvwzko7m4tkz3pa:56wo6cdpjsxk7ddgnqfp2quipfghukhtmvjuahvwzko7m4tkz3pa",

    \ \ "manifest": {

    \ \ \ \ "1f44ad271940fd01fa7f1ed2c952c709a7ca075c9028cc732deb8a15197ba93337c2edd19a3f6f57539c18004c6a3493f088a8524ea1fcce3aded371ca654cd2": [

    \ \ \ \ \ \ "v1/content/object.json"

    \ \ \ \ ],

    \ \ \ \ "4b991411121c91115c9b15d685c1045916cf2cafdd9a377bf522ac01b96e805479469cf018d81af9da1b591942e5f538ce5af0a4555f2029f79eaf66115998eb": [

    \ \ \ \ \ \ "v1/content/genesis.json"

    \ \ \ \ ],

    \ \ \ \ "6ffe743532eaa77a16d66d2168f547cb00ca7905235e4f6a435a42a127efdb8fe998359eb560472fd7e57ee38a1484c9bbf1723756d684fd697157ffec275f52": [

    \ \ \ \ \ \ "v1/content/keys.json"

    \ \ \ \ ]

    \ \ },

    \ \ "type": "https://ocfl.io/1.1/spec/#inventory",

    \ \ "versions": {

    \ \ \ \ "v1": {

    \ \ \ \ \ \ "created": "2026-03-01T17:40:00Z",

    \ \ \ \ \ \ "state": {

    \ \ \ \ \ \ \ \ "1f44ad271940fd01fa7f1ed2c952c709a7ca075c9028cc732deb8a15197ba93337c2edd19a3f6f57539c18004c6a3493f088a8524ea1fcce3aded371ca654cd2": [

    \ \ \ \ \ \ \ \ \ \ "object.json"

    \ \ \ \ \ \ \ \ ],

    \ \ \ \ \ \ \ \ "4b991411121c91115c9b15d685c1045916cf2cafdd9a377bf522ac01b96e805479469cf018d81af9da1b591942e5f538ce5af0a4555f2029f79eaf66115998eb": [

    \ \ \ \ \ \ \ \ \ \ "genesis.json"

    \ \ \ \ \ \ \ \ ],

    \ \ \ \ \ \ \ \ "6ffe743532eaa77a16d66d2168f547cb00ca7905235e4f6a435a42a127efdb8fe998359eb560472fd7e57ee38a1484c9bbf1723756d684fd697157ffec275f52": [

    \ \ \ \ \ \ \ \ \ \ "keys.json"

    \ \ \ \ \ \ \ \ ]

    \ \ \ \ \ \ }

    \ \ \ \ }

    \ \ }

    }
  </verbatim-code>
  </html-div-class>

  When the laptop is replaced, the second version lists the new laptop's key and retires the old one (section 6.2). It is signed by two of the three tokens, in <verbatim|v2/signature-oxthfb6b4q3sqath.json> and <verbatim|v2/signature-h6k4k6c5u4dusj4s.json> of the owner object's witness folder, each naming the first version by its pin; <verbatim|oxthfb6b4q3sqath> and <verbatim|h6k4k6c5u4dusj4s> begin two digests of <verbatim|next> in the first version, whose keys the signature files reveal. The first of them:

  <\html-div-class|language-json>
  <\verbatim-code>
    {

    \ \ "format": "opensheaf-signature/0.2",

    \ \ "object": "sheaf:56wo6cdpjsxk7ddgnqfp2quipfghukhtmvjuahvwzko7m4tkz3pa:56wo6cdpjsxk7ddgnqfp2quipfghukhtmvjuahvwzko7m4tkz3pa",

    \ \ "version": "v2",

    \ \ "inventorySha512": "7673bfae6ba91f6e9acf862635649efde7b6af0e1a787f6dc2cb2f2a583d5d4fab7bf236f7284582a4894aebef2769eacbf69d9036f1ecd4f89c07bc31313f84",

    \ \ "signer": "56wo6cdpjsxk7ddgnqfp2quipfghukhtmvjuahvwzko7m4tkz3pa",

    \ \ "key": "did:key:z6Mkh5i2epG9LsWNnYbBHG7ctEiNLZPjsBNXxNUcsaYgEtNm",

    \ \ "keyLog": "sheaf:56wo6cdpjsxk7ddgnqfp2quipfghukhtmvjuahvwzko7m4tkz3pa/v1?sha512=afaabe7b9489bc408ecbb20e8477a7eeb4e8a0ebde0dc15e32d30be17d922207504953e3e52101015f770844449c8382c4c4d9bec472a908ed47200efaef1220",

    \ \ "signature": "1SHM2Xc8RX7/lE8fJq4cbJ/iNV5+v3jji4ObMcjjJZdDKjxsV+j3SKMn8g2kGnf6QCe0FOfPenFkXcjWYGauAQ=="

    }
  </verbatim-code>
  </html-div-class>

  Every token of the first version, the third, which did not sign, included, is then destroyed, and <verbatim|next> commits three new ones, since a rotation key is committed in one version only (section 6.1); the data of the timestamps extension, declared in the genesis record, is repeated:

  <\html-div-class|language-json>
  <\verbatim-code>
    {

    \ \ "format": "opensheaf-keys/0.2",

    \ \ "keys": [

    \ \ \ \ "did:key:z6MkugKqPPkysjyartSzszBbMh8fVhENmqGXvddtD8DDvThn"

    \ \ ],

    \ \ "threshold": 1,

    \ \ "next": [

    \ \ \ \ "j77iavvdclktxkwmwefs7lw6fisdi7lqphwe33g4nboea35t2zga",

    \ \ \ \ "nzvwkea25p62akdygzheep4qgoo3fw7ryimwytckea4njabtlfzq",

    \ \ \ \ "fhujijfn3zmvteieps5l6raae73kndteaoju5js3ja33l2wvrqmq"

    \ \ ],

    \ \ "nextThreshold": 2,

    \ \ "extensions": {

    \ \ \ \ "https://opensheaf.org/opensheaf-timestamps-0.2": {

    \ \ \ \ \ \ "timestampAuthorities": [

    \ \ \ \ \ \ \ \ "5b4e3f0c9d2a7e18c6f4b0a39d7e2c51f8a6b3d09e4c7a12f5b8d6e3a0c9f147"

    \ \ \ \ \ \ ]

    \ \ \ \ }

    \ \ }

    }
  </verbatim-code>
  </html-div-class>

  Its <verbatim|object.json> repeats the fields of that of the first version, and adds <verbatim|previous>, the digest of the inventory file of the first version, which fixes the bytes of that inventory (section 4.3):

  <\html-div-class|language-json>
  <\verbatim-code>
    {"format":"opensheaf-object/0.2","kind":"owner","name":"56wo6cdpjsxk7ddgnqfp2quipfghukhtmvjuahvwzko7m4tkz3pa","owner":"56wo6cdpjsxk7ddgnqfp2quipfghukhtmvjuahvwzko7m4tkz3pa","previous":"afaabe7b9489bc408ecbb20e8477a7eeb4e8a0ebde0dc15e32d30be17d922207504953e3e52101015f770844449c8382c4c4d9bec472a908ed47200efaef1220","specification":"0.2","status":"active"}
  </verbatim-code>
  </html-div-class>

  The journal's owner, <verbatim|tqr6lchnd2vk7ezskdc5zdxpaidpsiuduo5sqhiis3i55iautdka>, is a group: three current keys, one for each of its editors, with a <verbatim|threshold> of 2, so that every version it makes carries two signature files, and three rotation keys with a <verbatim|nextThreshold> of 2; its genesis record names its domain, <verbatim|https://journal.example.org/>, as keeper.

  <subsection*|C.2 A document version><label|c2-a-document-version>

  The genesis record of the paper, written when the owner sealed it (section 10.2):

  <\html-div-class|language-json>
  <\verbatim-code>
    {

    \ \ "format": "opensheaf-genesis/0.2",

    \ \ "kind": "document",

    \ \ "created": "2026-03-02T09:14:00Z",

    \ \ "originator": "56wo6cdpjsxk7ddgnqfp2quipfghukhtmvjuahvwzko7m4tkz3pa",

    \ \ "nonce": "6f65cd32058c16d6d78b05011772ff1d"

    }
  </verbatim-code>
  </html-div-class>

  Its genesis name is <verbatim|zzgdggwlldcrw4bdeuvntiaobtw2kge6bc4go737pfekhfc5oz4q>; by algorithm 1 its name is <verbatim|aajozkubvmxu37pbu2lumdl37llv4ntkazd6j2es54zn23fkiknb>, which a branch renamed after a clash would take (section 5.3). The line is <verbatim|sheaf:zzgdggwlldcrw4bdeuvntiaobtw2kge6bc4go737pfekhfc5oz4q:56wo6cdpjsxk7ddgnqfp2quipfghukhtmvjuahvwzko7m4tkz3pa>. The <verbatim|object.json> of its first version (section 4.3), which was deposited with Zenodo (appendix A.1):

  <\html-div-class|language-json>
  <\verbatim-code>
    {

    \ \ "format": "opensheaf-object/0.2",

    \ \ "specification": "0.2",

    \ \ "kind": "document",

    \ \ "name": "zzgdggwlldcrw4bdeuvntiaobtw2kge6bc4go737pfekhfc5oz4q",

    \ \ "owner": "56wo6cdpjsxk7ddgnqfp2quipfghukhtmvjuahvwzko7m4tkz3pa",

    \ \ "documentVersion": 1,

    \ \ "mainSource": "fractional-phi42-mass-gap.tm",

    \ \ "sourceFormat": "application/x-texmacs",

    \ \ "renditions": [ { "path": "fractional-phi42-mass-gap.pdf", "mediaType": "application/pdf" } ],

    \ \ "toolchain": [ { "name": "TeXmacs", "version": "2.1.5" } ],

    \ \ "stage": { "scheme": "NISO-JAV", "value": "AO" },

    \ \ "agreement": { "by": [ "P. Duch", "M. Gubinelli" ], "date": "2026-03-01", "method": "by e-mail" },

    \ \ "external": [ { "role": "deposit", "service": "Zenodo",

    \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ "record": "https://zenodo.org/records/1234567", "doi": "10.5281/zenodo.1234567" } ],

    \ \ "status": "active"

    }
  </verbatim-code>
  </html-div-class>

  The <verbatim|datacite.json> of the same version (section 4.4). The version has a Zenodo DOI, so Zenodo is its <verbatim|publisher>, and <verbatim|url> (section 4.4) is the version's landing page on the archive's website (appendix A.3), while Zenodo's own record of the DOI has Zenodo's (appendix A.1):

  <\html-div-class|language-json>
  <\verbatim-code>
    {

    \ \ "doi": "10.5281/zenodo.1234567",

    \ \ "url": "https://mgubi.org/papers/fractional-phi42-mass-gap/",

    \ \ "version": "1",

    \ \ "types": { "resourceTypeGeneral": "Preprint" },

    \ \ "titles": [ { "title": "Mass gap for the fractional $\\\\Phi^4_2$ model" } ],

    \ \ "creators": [

    \ \ \ \ { "name": "Duch, P.", "nameType": "Personal", "givenName": "P.", "familyName": "Duch" },

    \ \ \ \ { "name": "Gubinelli, M.", "nameType": "Personal", "givenName": "M.", "familyName": "Gubinelli",

    \ \ \ \ \ \ "nameIdentifiers": [ { "nameIdentifier": "https://orcid.org/0000-0002-1234-5677",

    \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ "nameIdentifierScheme": "ORCID" } ] } ],

    \ \ "publisher": { "name": "Zenodo" },

    \ \ "publicationYear": 2026,

    \ \ "dates": [ { "date": "2026-03-02", "dateType": "Issued" },

    \ \ \ \ \ \ \ \ \ \ \ \ \ { "date": "2026-03-02", "dateType": "Available" } ],

    \ \ "rightsList": [ { "rights": "Creative Commons Attribution 4.0 International",

    \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ "rightsUri": "https://creativecommons.org/licenses/by/4.0/",

    \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ "rightsIdentifier": "cc-by-4.0", "rightsIdentifierScheme": "SPDX" } ],

    \ \ "descriptions": [ { "description": "We present a new, simple .<no-break>.<no-break>.",

    \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ "descriptionType": "Abstract" } ],

    \ \ "formats": [ "application/x-texmacs", "application/pdf" ],

    \ \ "relatedIdentifiers": [ { "relatedIdentifier": "10.5281/zenodo.1234566",

    \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ "relatedIdentifierType": "DOI", "relationType": "IsVersionOf" } ]

    }
  </verbatim-code>
  </html-div-class>

  The second object version holds document version 2 (section 4.2), corrected after the referee's report and accepted by the journal: its <verbatim|object.json> has <verbatim|previous>, the digest of the inventory file of the first version (section 4.3), <verbatim|documentVersion> 2, <verbatim|changes>, <verbatim|stage> <verbatim|AM> and the DOI <verbatim|10.5281/zenodo.1234568>, and its <verbatim|datacite.json> has <verbatim|version> <verbatim|"2"> and <verbatim|IsNewVersionOf> the DOI of version 1.

  <subsection*|C.3 A signature><label|c3-a-signature>

  The signature of that version by the new laptop's key, <verbatim|extensions/opensheaf-witnesses/v2/signature-4hz7zgsiazl6hx7i.json> in the paper's object, <verbatim|4hz7zgsiazl6hx7i> being the first 16 characters of the base32 SHA-256 digest of the <verbatim|did:key> (section 7.2); it names version 2 of the key log, which lists the key:

  <\html-div-class|language-json>
  <\verbatim-code>
    {

    \ \ "format": "opensheaf-signature/0.2",

    \ \ "object": "sheaf:zzgdggwlldcrw4bdeuvntiaobtw2kge6bc4go737pfekhfc5oz4q:56wo6cdpjsxk7ddgnqfp2quipfghukhtmvjuahvwzko7m4tkz3pa",

    \ \ "version": "v2",

    \ \ "inventorySha512": "e3e1319055b967af645713c3baa4dc1974eb8ce02f6b2591bbcce55b068e7a98df54dfa8ab2fd8996d27a2b31df8bee814281d681187014eaa0316f048edbb25",

    \ \ "signer": "56wo6cdpjsxk7ddgnqfp2quipfghukhtmvjuahvwzko7m4tkz3pa",

    \ \ "key": "did:key:z6MkugKqPPkysjyartSzszBbMh8fVhENmqGXvddtD8DDvThn",

    \ \ "keyLog": "sheaf:56wo6cdpjsxk7ddgnqfp2quipfghukhtmvjuahvwzko7m4tkz3pa/v2?sha512=7673bfae6ba91f6e9acf862635649efde7b6af0e1a787f6dc2cb2f2a583d5d4fab7bf236f7284582a4894aebef2769eacbf69d9036f1ecd4f89c07bc31313f84",

    \ \ "signature": "Gf9KOxH/6Bg4HzaXGt/HHP+iwdDkSpc/3laukJ5YDSxT6Vy7YDJslpFB3zsi1H/L6QsIaf+mNFhsLCYYqipyBA=="

    }
  </verbatim-code>
  </html-div-class>

  The message it signs, each line ended by a line feed (section 7.2):

  <\verbatim-code>
    opensheaf-signature/0.2

    object sheaf:zzgdggwlldcrw4bdeuvntiaobtw2kge6bc4go737pfekhfc5oz4q:56wo6cdpjsxk7ddgnqfp2quipfghukhtmvjuahvwzko7m4tkz3pa

    version v2

    inventorySha512 e3e1319055b967af645713c3baa4dc1974eb8ce02f6b2591bbcce55b068e7a98df54dfa8ab2fd8996d27a2b31df8bee814281d681187014eaa0316f048edbb25

    keyLog sheaf:56wo6cdpjsxk7ddgnqfp2quipfghukhtmvjuahvwzko7m4tkz3pa/v2?sha512=7673bfae6ba91f6e9acf862635649efde7b6af0e1a787f6dc2cb2f2a583d5d4fab7bf236f7284582a4894aebef2769eacbf69d9036f1ecd4f89c07bc31313f84
  </verbatim-code>

  With a threshold of 1, this one good signature makes the version signed (section 7.3).

  <subsection*|C.4 Collections><label|c4-collections>

  The <verbatim|members.json> of the second version of the owner catalogue of the authors' owner in their archive (sections 8.1 and 8.3). The member is followed, so that when version 2 of the paper was signed, the catalogue's tool wrote this version, pinning it in place of version 1:

  <\html-div-class|language-json>
  <\verbatim-code>
    {

    \ \ "format": "opensheaf-collection/0.2",

    \ \ "type": "catalogue",

    \ \ "order": "issued-desc",

    \ \ "members": [

    \ \ \ \ { "kind": "document",

    \ \ \ \ \ \ "name": "zzgdggwlldcrw4bdeuvntiaobtw2kge6bc4go737pfekhfc5oz4q",

    \ \ \ \ \ \ "owner": "56wo6cdpjsxk7ddgnqfp2quipfghukhtmvjuahvwzko7m4tkz3pa",

    \ \ \ \ \ \ "at": [ "https://mgubi.org/papers/" ],

    \ \ \ \ \ \ "version": "v2",

    \ \ \ \ \ \ "inventorySha512": "e3e1319055b967af645713c3baa4dc1974eb8ce02f6b2591bbcce55b068e7a98df54dfa8ab2fd8996d27a2b31df8bee814281d681187014eaa0316f048edbb25",

    \ \ \ \ \ \ "follow": "latest",

    \ \ \ \ \ \ "doi": "10.5281/zenodo.1234568",

    \ \ \ \ \ \ "conceptDoi": "10.5281/zenodo.1234566",

    \ \ \ \ \ \ "cite": { "title": "Mass gap for the fractional $\\\\Phi^4_2$ model",

    \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ "creators": [ "P. Duch", "M. Gubinelli" ], "year": 2026, "issued": "2026-03-02" } }

    \ \ ]

    }
  </verbatim-code>
  </html-div-class>

  The <verbatim|members.json> of an issue of the journal, a selection owned by the journal's owner (section 8.4). Its first member is the journal's accepted copy (section C.5); its second, the original revision set, which a selection MAY also list (section 9.6):

  <\html-div-class|language-json>
  <\verbatim-code>
    {

    \ \ "format": "opensheaf-collection/0.2",

    \ \ "type": "selection",

    \ \ "members": [

    \ \ \ \ { "kind": "document",

    \ \ \ \ \ \ "name": "zzgdggwlldcrw4bdeuvntiaobtw2kge6bc4go737pfekhfc5oz4q",

    \ \ \ \ \ \ "owner": "tqr6lchnd2vk7ezskdc5zdxpaidpsiuduo5sqhiis3i55iautdka",

    \ \ \ \ \ \ "at": [ "https://journal.example.org/" ],

    \ \ \ \ \ \ "revisions": [ { "documentVersion": 2, "version": "v1",

    \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ "inventorySha512": "1c4e62bb1f89510405cbf63998b049f49b8b5349231bc928313ad17ab1e9fd7460aa570e3bbbce70a9627f2ec71440f0f55facd1c4fc1fb5050f23f6127a9a5a" } ],

    \ \ \ \ \ \ "cite": { "title": "Mass gap for the fractional $\\\\Phi^4_2$ model",

    \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ "creators": [ "P. Duch", "M. Gubinelli" ], "year": 2026, "issued": "2026-03-02" } },

    \ \ \ \ { "kind": "document",

    \ \ \ \ \ \ "name": "zzgdggwlldcrw4bdeuvntiaobtw2kge6bc4go737pfekhfc5oz4q",

    \ \ \ \ \ \ "owner": "56wo6cdpjsxk7ddgnqfp2quipfghukhtmvjuahvwzko7m4tkz3pa",

    \ \ \ \ \ \ "at": [ "https://mgubi.org/papers/" ],

    \ \ \ \ \ \ "revisions": [ { "documentVersion": 2, "version": "v2",

    \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ "inventorySha512": "e3e1319055b967af645713c3baa4dc1974eb8ce02f6b2591bbcce55b068e7a98df54dfa8ab2fd8996d27a2b31df8bee814281d681187014eaa0316f048edbb25",

    \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ "doi": "10.5281/zenodo.1234568" } ] }

    \ \ ]

    }
  </verbatim-code>
  </html-div-class>

  <subsection*|C.5 A branch: an accepted copy><label|c5-a-branch-an-accepted-copy>

  The <verbatim|object.json> of the first version of the journal's accepted copy, a branch of the authors' line at their object version <verbatim|v2> (sections 9.1 and 9.6). No line of that name is the journal's, so the branch takes the genesis name, and its line is <verbatim|sheaf:zzgdggwlldcrw4bdeuvntiaobtw2kge6bc4go737pfekhfc5oz4q:tqr6lchnd2vk7ezskdc5zdxpaidpsiuduo5sqhiis3i55iautdka>. The first version of a line, it has no <verbatim|previous>:

  <\html-div-class|language-json>
  <\verbatim-code>
    {

    \ \ "format": "opensheaf-object/0.2",

    \ \ "specification": "0.2",

    \ \ "kind": "document",

    \ \ "name": "zzgdggwlldcrw4bdeuvntiaobtw2kge6bc4go737pfekhfc5oz4q",

    \ \ "owner": "tqr6lchnd2vk7ezskdc5zdxpaidpsiuduo5sqhiis3i55iautdka",

    \ \ "parent": {

    \ \ \ \ "owner": "56wo6cdpjsxk7ddgnqfp2quipfghukhtmvjuahvwzko7m4tkz3pa",

    \ \ \ \ "name": "zzgdggwlldcrw4bdeuvntiaobtw2kge6bc4go737pfekhfc5oz4q",

    \ \ \ \ "objectVersion": "v2",

    \ \ \ \ "documentVersion": 2,

    \ \ \ \ "inventorySha512": "e3e1319055b967af645713c3baa4dc1974eb8ce02f6b2591bbcce55b068e7a98df54dfa8ab2fd8996d27a2b31df8bee814281d681187014eaa0316f048edbb25",

    \ \ \ \ "url": "https://mgubi.org/papers/ocfl/56wo6cdpjsxk7ddgnqfp2quipfghukhtmvjuahvwzko7m4tkz3pa/zzgdggwlldcrw4bdeuvntiaobtw2kge6bc4go737pfekhfc5oz4q/v2/"

    \ \ },

    \ \ "documentVersion": 2,

    \ \ "mainSource": "fractional-phi42-mass-gap.tm",

    \ \ "sourceFormat": "application/x-texmacs",

    \ \ "renditions": [ { "path": "fractional-phi42-mass-gap.pdf", "mediaType": "application/pdf" } ],

    \ \ "stage": { "scheme": "NISO-JAV", "value": "AM" },

    \ \ "status": "active"

    }
  </verbatim-code>
  </html-div-class>

  Its content holds the files of the parent version except <verbatim|datacite.json> and <verbatim|object.json> (<verbatim|genesis.json>, the source and the PDF), its own <verbatim|datacite.json> and <verbatim|object.json>, and the evidence (section 9.2): <verbatim|parent/inventory.json>, the authors' <verbatim|v2/inventory.json>; <verbatim|parent/object.json>, their <verbatim|object.json> of that version; and <verbatim|parent/signatures/signature-4hz7zgsiazl6hx7i.json>, the file of section C.3, byte for byte. Its witness folder holds two signature files of the journal's keys, naming the first version of the journal's key log. The journal's storage root keeps beside it the owner objects of the journal and of the authors (section 6.5).

  <subsection*|C.6 The archive><label|c6-the-archive>

  The storage root of the authors' archive in the owner-name layout (section 3.2), with the plain text file that describes that layout in place of OCFL's <verbatim|ocfl_layout.json>, which names only registered layouts, and showing the paper's witness folder, with an RFC 3161 token of each signature (timestamps extension; the tokens are not shown):

  <\verbatim-code>
    ocfl/

    \ \ 0=ocfl_1.1

    \ \ opensheaf-owner-name-storage-layout.md

    \ \ 56wo6cdpjsxk7ddgnqfp2quipfghukhtmvjuahvwzko7m4tkz3pa/

    \ \ \ \ 56wo6cdpjsxk7ddgnqfp2quipfghukhtmvjuahvwzko7m4tkz3pa/ \ \ \ \ \ the key log

    \ \ \ \ zzgdggwlldcrw4bdeuvntiaobtw2kge6bc4go737pfekhfc5oz4q/ \ \ \ \ \ the paper

    \ \ \ \ \ \ 0=ocfl_object_1.1

    \ \ \ \ \ \ inventory.json

    \ \ \ \ \ \ inventory.json.sha512

    \ \ \ \ \ \ v1/

    \ \ \ \ \ \ v2/

    \ \ \ \ \ \ extensions/opensheaf-witnesses/

    \ \ \ \ \ \ \ \ v1/signature-w7htq42yt7tllefi.json

    \ \ \ \ \ \ \ \ v1/signature-w7htq42yt7tllefi.json.3mpvi64zr26ezfvh.tsr

    \ \ \ \ \ \ \ \ v2/signature-4hz7zgsiazl6hx7i.json

    \ \ \ \ \ \ \ \ v2/signature-4hz7zgsiazl6hx7i.json.5xjh5tk24wrufjrz.tsr

    \ \ \ \ kdye5s4igsyn6i6c46lqhercobkiv5avkepkdy6hcs6wr2pakxeq/ \ \ \ \ \ the owner catalogue
  </verbatim-code>

  In the hashed layout, the paper would be at <verbatim|946/75e/b2e/sheaf%3azzgdggwlldcrw4bdeuvntiaobtw2kge6bc4go737pfekhfc5oz4q%3a56wo6cdpjsxk7ddgnqfp2quipfghukhtmvjua-94675eb2e27de7146a912666db928784432a4c206a6b390da5a0ed7d15975580/>: its identifier of 111 characters encodes to 115, each <verbatim|:> becoming <verbatim|%3a>, and is shortened (section 3.2).

  The discovery document (section 3.1). The archive hosts one owner, whose key log, paper and catalogue it lists, with labels for the website, and which <verbatim|owners> names with its catalogue; a second paper of the owner was taken down, and its tombstone (section 13.3) keeps its line taken:

  <\html-div-class|language-json>
  <\verbatim-code>
    {

    \ \ "format": "opensheaf-archive/0.2",

    \ \ "specification": "0.2",

    \ \ "name": "Papers of Massimiliano Gubinelli",

    \ \ "contact": "https://orcid.org/0000-0002-1234-5677",

    \ \ "storageRoot": "ocfl/",

    \ \ "storageLayout": "opensheaf-owner-name-storage-layout",

    \ \ "profiles": [ "zenodo", "texmacs", "website" ],

    \ \ "extensions": [ "https://opensheaf.org/opensheaf-timestamps-0.2" ],

    \ \ "owners": [

    \ \ \ \ { "owner": "56wo6cdpjsxk7ddgnqfp2quipfghukhtmvjuahvwzko7m4tkz3pa",

    \ \ \ \ \ \ "catalogue": "sheaf:kdye5s4igsyn6i6c46lqhercobkiv5avkepkdy6hcs6wr2pakxeq:56wo6cdpjsxk7ddgnqfp2quipfghukhtmvjuahvwzko7m4tkz3pa" }

    \ \ ],

    \ \ "indexes": { "names": 2, "owners": 2, "sha512": 2 },

    \ \ "objects": [

    \ \ \ \ { "id": "sheaf:56wo6cdpjsxk7ddgnqfp2quipfghukhtmvjuahvwzko7m4tkz3pa:56wo6cdpjsxk7ddgnqfp2quipfghukhtmvjuahvwzko7m4tkz3pa",

    \ \ \ \ \ \ "kind": "owner", "name": "56wo6cdpjsxk7ddgnqfp2quipfghukhtmvjuahvwzko7m4tkz3pa", "owner": "56wo6cdpjsxk7ddgnqfp2quipfghukhtmvjuahvwzko7m4tkz3pa",

    \ \ \ \ \ \ "head": "v2", "inventorySha512": "7673bfae6ba91f6e9acf862635649efde7b6af0e1a787f6dc2cb2f2a583d5d4fab7bf236f7284582a4894aebef2769eacbf69d9036f1ecd4f89c07bc31313f84",

    \ \ \ \ \ \ "status": "active" },

    \ \ \ \ { "id": "sheaf:zzgdggwlldcrw4bdeuvntiaobtw2kge6bc4go737pfekhfc5oz4q:56wo6cdpjsxk7ddgnqfp2quipfghukhtmvjuahvwzko7m4tkz3pa",

    \ \ \ \ \ \ "kind": "document", "name": "zzgdggwlldcrw4bdeuvntiaobtw2kge6bc4go737pfekhfc5oz4q", "owner": "56wo6cdpjsxk7ddgnqfp2quipfghukhtmvjuahvwzko7m4tkz3pa",

    \ \ \ \ \ \ "head": "v2", "inventorySha512": "e3e1319055b967af645713c3baa4dc1974eb8ce02f6b2591bbcce55b068e7a98df54dfa8ab2fd8996d27a2b31df8bee814281d681187014eaa0316f048edbb25",

    \ \ \ \ \ \ "status": "active", "label": "fractional-phi42-mass-gap" },

    \ \ \ \ { "id": "sheaf:kdye5s4igsyn6i6c46lqhercobkiv5avkepkdy6hcs6wr2pakxeq:56wo6cdpjsxk7ddgnqfp2quipfghukhtmvjuahvwzko7m4tkz3pa",

    \ \ \ \ \ \ "kind": "collection", "name": "kdye5s4igsyn6i6c46lqhercobkiv5avkepkdy6hcs6wr2pakxeq", "owner": "56wo6cdpjsxk7ddgnqfp2quipfghukhtmvjuahvwzko7m4tkz3pa",

    \ \ \ \ \ \ "head": "v2", "inventorySha512": "f587b029968a50cb91b31d64d8612e26a5f13f676584f46cc04a5c014442e9056398b560023e8d6a952a530c55d132fe6d21a9455c87fe30297a59d8579eff94",

    \ \ \ \ \ \ "status": "active", "label": "papers" }

    \ \ ],

    \ \ "tombstones": [

    \ \ \ \ { "id": "sheaf:eyr6bc6toi6a4m4fkipowx7qe7f23piugoqvzurxmfo5buhjmr5a:56wo6cdpjsxk7ddgnqfp2quipfghukhtmvjuahvwzko7m4tkz3pa",

    \ \ \ \ \ \ "kind": "document", "name": "eyr6bc6toi6a4m4fkipowx7qe7f23piugoqvzurxmfo5buhjmr5a", "owner": "56wo6cdpjsxk7ddgnqfp2quipfghukhtmvjuahvwzko7m4tkz3pa",

    \ \ \ \ \ \ "genesisName": "eyr6bc6toi6a4m4fkipowx7qe7f23piugoqvzurxmfo5buhjmr5a",

    \ \ \ \ \ \ "lastVersion": "v1", "inventorySha512": "0e1cbffdc6412511c0f178f2ae9c23247e02eba1b061c3dc799a75919f682d3f6471ab1f2b07af9871cf3ad6d1f388a28a5878c340b7c5e3ca072c8a5f2d6c81",

    \ \ \ \ \ \ "date": "2026-05-04", "reason": "Taken down at the request of the holder of the rights." }

    \ \ ]

    }
  </verbatim-code>
  </html-div-class>

  <subsection*|C.7 sheaf: URIs><label|c7-sheaf-uris>

  URIs of the paper, of the accepted copy and of the authors' owner (section 12):

  <\verbatim-code>
    sheaf:zzgdggwlldcrw4bdeuvntiaobtw2kge6bc4go737pfekhfc5oz4q

    \ \ \ \ the authors' line (its owner is the originator)

    sheaf:zzgdggwlldcrw4bdeuvntiaobtw2kge6bc4go737pfekhfc5oz4q/v2

    \ \ \ \ document version 2 of the authors' line

    sheaf:zzgdggwlldcrw4bdeuvntiaobtw2kge6bc4go737pfekhfc5oz4q/v2?sha512=e3e1319055b967af645713c3baa4dc1974eb8ce02f6b2591bbcce55b068e7a98df54dfa8ab2fd8996d27a2b31df8bee814281d681187014eaa0316f048edbb25

    \ \ \ \ the authors' object version v2, which the journal vetted

    sheaf:zzgdggwlldcrw4bdeuvntiaobtw2kge6bc4go737pfekhfc5oz4q/v2?sha512=e3e1319055b967af645713c3baa4dc1974eb8ce02f6b2591bbcce55b068e7a98df54dfa8ab2fd8996d27a2b31df8bee814281d681187014eaa0316f048edbb25&at=https%3A%2F%2Fmgubi.org%2Fpapers%2F

    \ \ \ \ the same, with a hint

    sheaf:zzgdggwlldcrw4bdeuvntiaobtw2kge6bc4go737pfekhfc5oz4q:tqr6lchnd2vk7ezskdc5zdxpaidpsiuduo5sqhiis3i55iautdka/v2

    \ \ \ \ document version 2 of the journal's line, its accepted copy

    sheaf:zzgdggwlldcrw4bdeuvntiaobtw2kge6bc4go737pfekhfc5oz4q:*

    \ \ \ \ the work: the authors' line, the journal's and any other

    sheaf:56wo6cdpjsxk7ddgnqfp2quipfghukhtmvjuahvwzko7m4tkz3pa

    \ \ \ \ the authors' owner: its key log

    sheaf:56wo6cdpjsxk7ddgnqfp2quipfghukhtmvjuahvwzko7m4tkz3pa/v2?sha512=7673bfae6ba91f6e9acf862635649efde7b6af0e1a787f6dc2cb2f2a583d5d4fab7bf236f7284582a4894aebef2769eacbf69d9036f1ecd4f89c07bc31313f84

    \ \ \ \ version 2 of its key log, as keyLog names it

    sheaf:zzgdggwl/v2

    sheaf:zzgdggwl:tqr6lchn/v2

    \ \ \ \ short forms of the second and fifth (section 12.2)

    https://opensheaf.org/sheaf:zzgdggwlldcrw4bdeuvntiaobtw2kge6bc4go737pfekhfc5oz4q/v2

    \ \ \ \ the second, through a gateway (provisional, #35)
  </verbatim-code>

  <subsection*|C.8 An exposed key and a fork of a key log><label|c8-an-exposed-key-and-a-fork-of-a-key-log>

  Later, the new laptop is stolen. The owner signs with two tokens of the second version a version 3 of its key log, in <verbatim|v3/signature-j77iavvdclktxkwm.json> and <verbatim|v3/signature-nzvwkea25p62akdy.json>, naming version 2. It lists a new current key, made on another laptop, the stolen key in <verbatim|exposed>, and the digests of three new tokens in <verbatim|next>:

  <\html-div-class|language-json>
  <\verbatim-code>
    {

    \ \ "format": "opensheaf-keys/0.2",

    \ \ "keys": [

    \ \ \ \ "did:key:z6MkteCfnkhWgCnLtR7Wdzi81tk4FDb9Juk5CxgjqCRo4UHJ"

    \ \ ],

    \ \ "threshold": 1,

    \ \ "next": [

    \ \ \ \ "lnk5erp4kdue5zo5g6tryoy5jvxhjxzquopufqu7cfqaase5kdhq",

    \ \ \ \ "uilj7nmkhupsxi2isidszwwexj5w5ffieqxq27hhhlbpomh22ioa",

    \ \ \ \ "ibqesflkpunkv7w75elkgmbflw62jwi3uecj5hngyn6eq6ps475a"

    \ \ ],

    \ \ "nextThreshold": 2,

    \ \ "extensions": {

    \ \ \ \ "https://opensheaf.org/opensheaf-timestamps-0.2": {

    \ \ \ \ \ \ "timestampAuthorities": [

    \ \ \ \ \ \ \ \ "5b4e3f0c9d2a7e18c6f4b0a39d7e2c51f8a6b3d09e4c7a12f5b8d6e3a0c9f147"

    \ \ \ \ \ \ ]

    \ \ \ \ }

    \ \ },

    \ \ "exposed": [

    \ \ \ \ "did:key:z6MkugKqPPkysjyartSzszBbMh8fVhENmqGXvddtD8DDvThn"

    \ \ ]

    }
  </verbatim-code>
  </html-div-class>

  The first of its signature files:

  <\html-div-class|language-json>
  <\verbatim-code>
    {

    \ \ "format": "opensheaf-signature/0.2",

    \ \ "object": "sheaf:56wo6cdpjsxk7ddgnqfp2quipfghukhtmvjuahvwzko7m4tkz3pa:56wo6cdpjsxk7ddgnqfp2quipfghukhtmvjuahvwzko7m4tkz3pa",

    \ \ "version": "v3",

    \ \ "inventorySha512": "d006b40d988e88c16cfe7d83d81c5b8a0cb318daad1a78180566568c2553f4b7ef7de1d3ebadd785fba94bb3648e70d6a8f8b40cb8a7cfdd913fc76ba959ce7e",

    \ \ "signer": "56wo6cdpjsxk7ddgnqfp2quipfghukhtmvjuahvwzko7m4tkz3pa",

    \ \ "key": "did:key:z6MksaMy3cmXbnUKqzGv18xhbBreY6berNYVtTZyDrYRb1Hn",

    \ \ "keyLog": "sheaf:56wo6cdpjsxk7ddgnqfp2quipfghukhtmvjuahvwzko7m4tkz3pa/v2?sha512=7673bfae6ba91f6e9acf862635649efde7b6af0e1a787f6dc2cb2f2a583d5d4fab7bf236f7284582a4894aebef2769eacbf69d9036f1ecd4f89c07bc31313f84",

    \ \ "signature": "1zEI4EoFG/ZJlZ+e2Y0iswNCCi4oceb8k/gTR8KV+qKM8FAcJocW/eCfJ2zLYhjRlguS1lpoVwGnxBX8lMGKCg=="

    }
  </verbatim-code>
  </html-div-class>

  The thief, holding the stolen key, can sign versions of the owner's lines naming version 2; their signatures stay good, but these versions need a key that version 3 exposes, so they are contested, and archives that know version 3 never add them (sections 7.3 and 7.5). It can sign no version of the key log, which only rotation keys sign (section 6.1). The paper's version 2, signed only with the stolen key (section C.3), is contested too, though the owner made it: the owner signs it again with the new key, naming version 3 (section 7.1), and its RFC 3161 token, dated before version 3, is evidence a reader may trust (section 7.3).

  Had the thief also copied, before the owner used them, the tokens whose digests begin <verbatim|nzvwkea25p62akdy> and <verbatim|fhujijfn3zmvteie> in <verbatim|next> of the second version, it could sign another version 3, against version 2, listing a key of its own: a fork of the key log, which ends the owner (section 6.3). An archive holding the owner's versions 1 to 3 that meets the thief's version 3 keeps its own, and appends a fork record as version 4, which carries the other version 3:

  <\verbatim-code>
    56wo6cdpjsxk7ddgnqfp2quipfghukhtmvjuahvwzko7m4tkz3pa/56wo6cdpjsxk7ddgnqfp2quipfghukhtmvjuahvwzko7m4tkz3pa/

    \ \ inventory.json

    \ \ inventory.json.sha512

    \ \ v1/ v2/ v3/ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ the archive's own versions

    \ \ v4/ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ the fork record

    \ \ \ \ inventory.json

    \ \ \ \ inventory.json.sha512

    \ \ \ \ content/forked/f35la3m3ue36z36u/ \ \ \ \ \ \ \ \ \ the other version 3

    \ \ \ \ \ \ inventory.json

    \ \ \ \ \ \ inventory.json.sha512

    \ \ \ \ \ \ keys.json

    \ \ \ \ \ \ signature-nzvwkea25p62akdy.json

    \ \ \ \ \ \ signature-fhujijfn3zmvteie.json
  </verbatim-code>

  The fork record's <verbatim|genesis.json> is that of <verbatim|v1>, byte for byte, and its <verbatim|object.json> has the fields of that of <verbatim|v1> and <verbatim|previous>, the digest of the inventory file of the owner's version 3 (section 4.3); it has no <verbatim|keys.json>. The inventory carried has the owner object's <verbatim|id>, and <verbatim|f35la3m3ue36z36u> begins the base32 SHA-256 digest of its bytes. Readers report the owner ended at version 3, its fork point, and the fork freezes it: an archive that knows of the fork adds no version of its lines, from a copy or as a deposit, unless evidence it trusts shows it signed before either version 3 (section 7.5). The exposure in the owner's version 3 still counts, as an exposure does on either side of a fork (section 6.3), so the versions the thief signs with the stolen key naming version 2 stay contested; and versions of lines whose signatures name version 3, of either side, are contested too, the owner's new signature of the paper's version 2 included, so that the paper's version 2 is contested. Had the thief's version 3 also exposed the first laptop's key, the paper's version 1, signed with it, would be contested as well, though the owner made it. Archives holding the paper's versions keep them; others add them only if they trust their RFC 3161 tokens to date them before the fork, and readers weigh them by such evidence (section 6.4). The keeper may name a successor (section 6.6), under which the authors continue their papers as branches. An archive that met the thief's version 3 first keeps that one, and appends a fork record carrying the owner's.

  <section*|Appendix D. Rationale (non-normative)><label|appendix-d-rationale-non-normative>

  The reasons for the main choices, in the order of the sections.

  <subsection*|D.1 Archives and objects><label|d1-archives-and-objects>

  <\itemize>
    <item><strong|Why OCFL and DataCite.> OCFL is a published specification for versioned objects as plain files with digests, with independent validators; DataCite is the metadata of DOIs, with relations for versions and collections, and its REST API form lets <verbatim|datacite.json> be sent to a DOI service as it is.

    <item><strong|Why a minimal core.> Richer structures (a proof and its detailed argument, a dataset and its analyses) are built on top, by links, DataCite relations or extensions, whose data the pins and signatures fix with each version (section 2), leaving room for designs not yet imagined.

    <item><strong|Why archives are hosts.> Once owners sign their lines, a name for an archive identifies no authority and ties lines to places (#52, #55); every location is a hint, checked by pins and signatures. <verbatim|replicas> was dropped for that reason, and because it is read from the very site that may be gone.

    <item><strong|Why identifiers from lines, and two layouts.> Identifiers chosen by archives clash once an archive keeps copies of another's objects; lines never clash (#52). The owner-name layout keeps each owner in one folder, which moves by copying; the hashed layout serves archives too large for that, mostly in git.

    <item><strong|Why no <verbatim|ocfl_layout.json> for the owner-name layout.> OCFL allows in it only the name of a registered extension (OCFL 1.1, section 4.1), which the owner-name layout is not; OCFL lets a plain text file in the storage root document a local arrangement (section 4.5), and the discovery document names the layout for readers, who compute paths from it.

    <item><strong|Why document and object versions.> Readers and DOI services see versions of the work; the storage keeps every change, a corrected description or a notice included, each fixed by its pin.

    <item><strong|Why the owner numbers its document versions.> External numberings have gaps and miss versions never public there; external labels are kept beside the owner's numbers.

    <item><strong|Why the files of a document version are described once.> <verbatim|mainSource>, <verbatim|renditions> and <verbatim|toolchain> say what the deposited files are and how they were made; a reader who cited a version gets the same answer later, and a mistake in them is a notice, as for the files. Records at external services are added as they are made, after the deposit, and are evidence, so they are only added (#24).

    <item><strong|Why notices are numbered by position.> The list only grows, so a position never changes; an identifier chosen by the owner would add a field to generate and check for uniqueness, and give nothing more. A withdrawal is a replacement that stays visible, since readers who saw the notice should see it taken back (#26).

    <item><strong|Why a revert is a new version.> The current version is the last of the history, so a revert holding the earlier number would leave the reverted version current; and readers who cited the later version need to see that the work went back. Files are compared with their paths, since <verbatim|object.json>, links and citations name files by path (#23).

    <item><strong|Why digests in OCFL files are in lower case.> OCFL compares digests without regard to case; OpenSheaf quotes the digest of an inventory as its checksum file states it in pins, <verbatim|previous> and signatures, so one case keeps every quotation of a pin the same string, and tools compare digests as strings (#49).

    <item><strong|Why a deposit out of order is recorded by <verbatim|history>.> Only the author knows that a version belongs earlier in the work; the files cannot show it, so no rule could require <verbatim|history> of such a version and be checked. The history is therefore defined by what is written: the order of the numbers, unless <verbatim|history> says otherwise (#51).

    <item><strong|Why an explicit history.> Dates may be approximate or unknown, and fixed versions cannot correct pointers to their predecessors when a version is found later. A list of object versions, read from the latest signed version, can be corrected; it cannot list digests, since a version cannot contain the digest of its own inventory.

    <item><strong|Why the deposit is read from the inventory.> OCFL already records it; repeating it in <verbatim|object.json> would let the two disagree.

    <item><strong|Why <verbatim|objects> may be paged.> A discovery document listing every object grows by some 0.5 MB a thousand objects, is read first by every reader and rewritten at every deposit; pages keep it small and a deposit's rewrite local. Pages are listed explicitly, rather than found as index files by prefix, so that a reader over HTTP can enumerate the objects without trying every prefix (#19).

    <item><strong|Why an archive serves all its lines or none.> A discovery document listing only some objects of its storage root could no longer be checked against it, and readers could not tell a line kept back from one lost. Since a copy of a line is the same line, publishing some lines of a private archive is copying them, and pins made privately stay valid (#29).

    <item><strong|Why <verbatim|Available> is the deposit, in a private archive too.> Whether a version is public is not in the files, and changes with the archive's access (a paywall, a repository made public); the deposit is fixed, recorded in the inventory, and the same for every archive, and a later date would need a new version only to state it (#29).
  </itemize>

  <subsection*|D.2 Names><label|d2-names>

  <\itemize>
    <item><strong|Why names from genesis records.> A digest of a file every copy carries is checked by anyone, needs no registry and names no archive; its nonce makes it unique in practice, and taking the bytes as stored needs no canonical form of JSON.

    <item><strong|Why algorithm numbers.> Clashes are resolved where lines are made, and a branch, sharing its parent's record, is renamed by another algorithm. The number fills the four bits that RFC 4648 leaves zero, so names of algorithm 0 are plain digests and algorithms never coincide.

    <item><strong|Why no aliases.> A record wrapping an old one would give a work a second name that anyone could make, split its identity, and need exceptions to the rules of genesis records and branches. The clashes it was meant for are resolved where lines are made, a branch by another algorithm number (section 5.3); collisions are told apart by comparing genesis records byte for byte (section 12.3); and a reused record is useless to anyone else, so a work refused for one is sealed anew (#44).

    <item><strong|Why signatures decide reused genesis records.> Only the originator signs the originator's line, and every other line carries signed parents back to it, the whole chain, since one level would let a chain of branches pass. A reused record is useless to anyone else, and no archive keeps a first-come register of names (section 5.4).
  </itemize>

  <subsection*|D.3 Owners><label|d3-owners>

  <\itemize>
    <item><strong|Why keyed owners with key logs.> An owner asserted by a name (an ORCID iD, an archive's identifier) cannot stop others writing under it; signatures make every version checkable anywhere, also after its archives have gone (#55). A key cannot change, so the owner keeps its keys in a log, each version signed by the rotation keys committed by the one before, as Radicle's identity documents and The Update Framework do.

    <item><strong|Why the owner name fixes the first keys.> Otherwise anyone could write a first key-log version under a published owner name; as Radicle's repository identifier commits to its first delegates, and KERI's identifier to its first keys, the name commits to the first current keys and to the digests of the first rotation keys, from which the first version of the key log is computed.

    <item><strong|Why the first version of a key log is computed.> As KERI's inception event is fixed by its identifier, the first version of a key log is fixed by the owner name: every byte of it, its inventory included, is computed from the genesis record in canonical JSON (JCS), so every copy holds the same version, a signature can pin it, and no key log forks there. No key that might later be stolen ever signed it, so current keys sign no version of a key log at all, and versions of one number with different inventories are simply a fork, with no notion of equivalent versions.

    <item><strong|Why pre-rotation.> As in KERI, each version of the key log commits to the digests of the keys that may sign the next one, kept apart and used once. The roles are separate: current keys, in daily use and the likeliest to be stolen, sign lines and never the key log, so a thief holding them cannot change it, and the owner answers the theft by one version the thief cannot contest. The commitment is made before any theft, and a digest shows nothing of a key before its use. Earlier drafts let the same keys sign lines and the key log, so a thief could contest the owner's answer, and settling the contest needed fork records that nullified keys and healing that did not converge against a thief holding several keys (<hlink|keys and forks|https://github.com/opensheaf/opensheaf.github.io/blob/main/drafts/keys-and-forks.md>; <hlink|federated identity|https://github.com/opensheaf/opensheaf.github.io/blob/main/drafts/federated-identity.md>).

    <item><strong|Why a rotation key is committed once.> A key committed in the <verbatim|next> of two versions could sign both, so whoever stole it could fork the key log at either; committed once, the rotation keys of each version are fresh, a stolen one that did not sign is useless once the next version is signed, and whether a key is revealed is read from one version.

    <item><strong|Why revealed rotation keys do not become current keys.> KERI makes them current, and detects a thief's competing versions by witnesses and watchers, which OpenSheaf does not have. A rotation key that became current would be in daily use, so its theft would again let a thief contest the key log.

    <item><strong|Why the first seen is kept.> Without witnesses, an archive cannot tell which side of a fork came first elsewhere; it keeps what it holds, which no one can then remove, and appends a fork record carrying the other side, so that nothing a signature names is dropped and every copy shows the fork. Meeting both sides at once, it may keep either: each ends the owner.

    <item><strong|Why a fork freezes the owner.> Only rotation keys, kept apart and used once, can fork a key log, so a fork is rare and shows that they were exposed; the format cannot tell the owner's side, and healing, tried before, did not settle against a thief (<hlink|keys and forks|https://github.com/opensheaf/opensheaf.github.io/blob/main/drafts/keys-and-forks.md>). Without a clock, no rule can tell what the owner signed before the fork from what a thief signs after it, also with old current keys naming earlier versions of the key log, and each attempt to salvage part of it (taking a forked owner's versions only from copies, for instance) made new edge cases. So a fork ends the owner and freezes it: archives keep what they hold, signatures stay good, nothing more is added unless evidence dates it before the fork, and, as in Radicle, where a compromised key means a new identity, the work continues under a successor.

    <item><strong|Why exposed keys are exposed, never revoked.> Signatures carry no time, so nothing tells what a key signed before it leaked from what a thief signs after; revocation would need trusted time to decide which signatures count. So no signature is undone: the owner exposes the keys, what needs them is contested, never added to an archive unless other evidence dates it before the exposure, and readers weigh the past by other evidence (section 6.4). Dating every signature (a timestamp on each, a transparency log) would need a service online at signing time; such evidence can be added later as witnesses without changing any archive (#55).

    <item><strong|Why one status, contested.> An exposed key and a fork of a key log raise one question, whether a good signature may be a thief's, so one status answers both, once, for archives (never added), readers (never the latest signed version), branches and collections, and the same evidence lifts it. An exposure counts in any version, on either side of a fork: the format cannot tell which side is the owner's, and an exposure only makes versions contested, never signed, so counting a thief's costs trust in the owner's past at most, while ignoring the owner's would let what the thief signs with a stolen key pass. Versions of key logs are never contested: current keys never sign them.

    <item><strong|Why key logs travel beside objects.> A key log checks itself from its owner name, so any copy will do; as an owner object it is copied once per storage root and grows without changing the lines it signs.

    <item><strong|Why timestamps are an extension.> A single researcher needs none, since signatures stay good; an institution may want signatures dated by a provider it names, to tell what came before an exposure. The extension keeps the trade-offs of RFC 3161 authorities and OpenTimestamps out of the core; timestamps change no status by themselves, and section 7.3 admits trusted dates as evidence against <verbatim|contested>.

    <item><strong|Why the keeper is in the genesis record.> A keeper named in the key log could be changed by whoever holds rotation keys, a thief included, and after a fork by either side. Fixed by the owner name, the keeper answers for the owner from outside its keys, and a successor named after a fork counts only when the keeper names it. There is at most one keeper, so that at most one successor is accepted.

    <item><strong|Why keepers confirm.> A genesis record could name anyone as keeper; the keeper confirms the link where only it can, and can withdraw it without touching anything signed (#41).
  </itemize>

  <subsection*|D.4 Lines and signatures><label|d4-lines-and-signatures>

  <\itemize>
    <item><strong|Why signatures name the key-log version.> A signature of a checksum file alone could be paired with any key-log version. Judged against the version it names, a signature survives retired keys: an owner cannot find every copy of its lines to sign them again.

    <item><strong|Why a signed version vouches for its past.> An inventory fixes every earlier version, so one signature covers them all, as Radicle's canonical head vouches for the commits it reaches.

    <item><strong|Why <verbatim|previous> chains inventories.> As a git commit names its parents by digest, each version names the digest of the inventory file before it. OCFL chains content, not inventories: an inventory records the digests of earlier versions' files, and earlier inventories need only state the same versions as JSON values (OCFL 1.1, section 3.7). A pin is the digest of an inventory's bytes, so without the chain a version vouched for would be fixed in its files but not in the bytes its pin names, and its pin would be less reliable than that of a version signed directly (#46).

    <item><strong|Where witnesses live.> A witness follows its version, so it cannot be in it, and a new version for each would mix evidence with the work. OCFL closes the object folder, and its <verbatim|logs/> are not covered by digests; extension folders hold data outside every version, as the mutable-head extension does.

    <item><strong|Why no list of an owner's lines.> Copies are compared through the inventories they share, so a copy that stops early is only older.

    <item><strong|Why versions held are never removed.> If a host or a thief could cause a removal, it could remove the owner's own versions; keeping everything costs at most one blocked version number in one archive.
  </itemize>

  <subsection*|D.5 Collections><label|d5-collections>

  <\itemize>
    <item><strong|Why pins by inventory digest.> One digest fixes a whole object version, so collections are hash trees across archives, any matching copy will do, and locations are equal hints.

    <item><strong|Why catalogues and selections.> Keeping and vetting are different acts. A catalogue keeps every version without judging it; a selection attests particular revisions, so a later version cannot enter by itself, and a change of what is vetted is an editorial act in the selection's history.

    <item><strong|Why <verbatim|follow> is a setting.> A collection version states exactly what it contains; a floating "latest" would change its meaning over time.

    <item><strong|Why one catalogue per owner.> A catalogue is a line, signed by its owner. One catalogue for an archive hosting several owners would need one owner's keys for every other owner's deposit, or an archive that signs for its owners; with one catalogue each, every owner signs only its own lines, a branch is listed by the owner who made it, and an archive adding an owner changes nothing of the others (#72).

    <item><strong|Why a collection is a document.> One set of rules for versions, history, reverts, notices and description-only versions serves both; a collection whose member list changed without a new document version would make "version 3" of it name different lists, or need a history of its own. A followed member moves only with a new document version, so a catalogue can still be described or withdrawn (#24, #45).
  </itemize>

  <subsection*|D.6 Branches and accepted copies><label|d6-branches-and-accepted-copies>

  <\itemize>
    <item><strong|Why every branch is a new object.> A journal needs only the version it vetted, a co-author perhaps the whole past, which a copy of the parent's line beside the branch gives. A branch continuing the parent's object would hold inventories naming the parent's identifier, and collide with that copy; Radicle likewise keeps forks beside their sources.

    <item><strong|Why the evidence carries signatures and the whole chain.> Without the parent owner's signatures a branch shows only a parent inventory that agrees with itself; the chain lets a branch of a branch be checked back to the originator's line after its parents' archives have gone (#22).

    <item><strong|Why accepted copies are branches, not mirrors.> A mirror grows only by its owner's versions; an accepted copy continues one revision under the selection's responsibility, and OCFL cannot hold part of an object.
  </itemize>

  <subsection*|D.7 Drafts and sealing><label|d7-drafts-and-sealing>

  <\itemize>
    <item><strong|Why drafts.> A version that has left its owner's hands may be cited, pinned or copied, and must stay fixed and signed; a draft keeps unfinished work in the usual format, marked, outside its content, as something on which nothing may rely.

    <item><strong|Why sealing makes a new object.> Continuing the draft would start the line with unsigned history that may have changed; a new object starts it at its first signed version.

    <item><strong|Why only at the owner's request.> Sealing fixes a name and signs for ever; a tool sealing as a side effect would make the owner answer for a version it did not choose to share.

    <item><strong|Why drafts are not shared as objects.> A draft may change, so a recipient could rely on nothing in it; files shared to work together need no format, and whatever must be relied on is sealed (#29).
  </itemize>

  <subsection*|D.8 Copies and mirrors><label|d8-copies-and-mirrors>

  <\itemize>
    <item><strong|Why a mirror is not marked.> It is the same line, checked by its owner's signatures, so a mark would add nothing a reader could rely on; identifiers from lines made the earlier <verbatim|mirrorOf> unnecessary (#52).

    <item><strong|Why mirrors grow only by the owner's versions.> Like catalogues they are impartial; and OCFL objects only grow, so a copy that departs from a mirror is a fork, never a correction.
  </itemize>

  <subsection*|D.9 Identifiers><label|d9-identifiers>

  <\itemize>
    <item><strong|Why <verbatim|sheaf:> URIs.> Earlier global names built on an archive's identifier (<verbatim|tag:> or ARK URIs) tied lines to places (#14, #52). One scheme writes lines, versions, pins and owners, and signatures name key-log versions with it.

    <item><strong|Why the owner part defaults to the originator.> The genesis record every copy carries names the originator, so the URI is fixed by the work; "the latest" line would depend on what a resolver knows.

    <item><strong|Why a branch numbers from 1.> The owner of a line numbers its own document versions (section 4.2); continuing the parent's numbers made the journal's version 4 look like the authors' version 4 while holding other content, and dotted numbers would make <verbatim|documentVersion> more than an integer. <verbatim|parent.documentVersion> keeps the parent's number, so nothing is lost (#57).

    <item><strong|Why a new branch point is a new version, not a merge.> A branch point is recorded in each object version, so a later one is a new version of the same branch, which keeps the branch's own notices as every version does; work taken in from another line is a deposit with a relation, since the files are what a version holds, and a relation says where they came from (#57).

    <item><strong|Why <verbatim|/v\<less\>n\<gtr\>> is a document version.> Readers cite versions of the work; object versions change at every notice, and a citation that must not move carries the digest.

    <item><strong|Why short forms are only for people.> Eight characters are 40 bits: another owner can make a short form ambiguous, never take it over, and resolvers may know different lines.

    <item><strong|Why gateways redirect only temporarily, and only to checked copies.> Copies move and are taken down, so a permanent redirect would fix a stale location in browsers' caches; a gateway that serves only what it checked cannot send readers to a forged copy.

    <item><strong|Why external records do not resolve pins.> A deposit or a snapshot keeps a version's files but not its inventory or signatures, so nothing ties them to the pin or the owner (#22).
  </itemize>

  <subsection*|D.10 Withdrawal, takedown and tombstones><label|d10-withdrawal-takedown-and-tombstones>

  <\itemize>
    <item><strong|Why a withdrawal can be followed by a new version.> A retraction is a statement about the versions made so far; work corrected later is a new version of the same work, as on arXiv, whose withdrawal is itself a version after which a replacement may come. The withdrawn versions stay withdrawn, so a reinstatement never rewrites what readers were told. No list of withdrawals is kept: every object version stays, and the withdrawals are read from them (#25).

    <item><strong|Why a withdrawal keeps the content.> A retracted paper stays part of the record, cited and collected; deleting it would break every pin and signature that includes it.

    <item><strong|Why a takedown deletes the whole object.> OCFL 1.1 cannot remove a file without changing the inventories, and so every pin and signature; deleting the object leaves all else valid, which is also why erasure is a takedown. Every removal is one, so nothing leaves an archive silently.

    <item><strong|Why a tombstone is not signed.> Takedowns are often made against the owner's will, and a host can add a tombstone falsely; it speaks for one archive only.

    <item><strong|Why a takedown binds only its archive.> A tombstone that stopped resolution elsewhere would let any host suppress lines kept by others, falsely or under pressure; and what an archive must not serve depends on the law that applies to it. Each archive answers for what it serves, as for what it copies, and an owner who wants every copy to say that a work is not valid withdraws it, by a signed version (#66, #33).

    <item><strong|Why no signed takedown requests.> Requests come from people with many standings (a court, a rights holder, a person whose data is held), which no key in the format can show; the owner's keys are not enough, since a thief may hold them (section 13.2), and the owner's own means is a withdrawal (#33).

    <item><strong|Why a tombstone keeps the genesis name.> A work taken down cannot then return there under a reused record (section 5.4).

    <item><strong|Why owner objects outlive takedowns of lines.> Every other line, branch and copy the owner signed needs the key log; and since a thief may hold current keys, or rotation keys, a takedown of an owner object needs the law or the keeper, never the owner's keys.
  </itemize>

  <subsection*|D.11 Verification><label|d11-verification>

  <\itemize>
    <item><strong|Why errors, warnings and results.> An error is a breach the archive can repair; what it cannot repair (a version let in against section 7.5, another archive's copy), and states of the world (an end, a fork, a withdrawal), would make it fail for ever.

    <item><strong|Why the inventory's bytes decide a pin.> A pin is the digest of the inventory file; the checksum file only repeats it. Discarding a copy whose bytes match for a checksum file missing or wrong would make a member unavailable that every reader can check (#48).

    <item><strong|Why a copy that does not match does not decide.> Locations are equal hints, tried in any order, and any copy that matches is the version pinned; a copy that does not is damage or tampering at one location, reported there, and would otherwise make the status depend on the order in which locations are tried (#37).
  </itemize>

  <subsection*|D.12 Security, privacy and rights><label|d12-security-privacy-and-rights>

  <\itemize>
    <item><strong|Why one's own storage root is untrusted.> An archive checks signatures, not intentions: a path or a text is as dangerous in a signed version as in a forged one.

    <item><strong|Why object files never run in an archive's origin.> A script served from an origin acts as that site: it reads what its pages store, and presents forged pages under a trusted address.

    <item><strong|Why owners are pseudonymous.> Owner names, key logs and signatures travel with every copy and can never be removed; if they named persons, no takedown could erase them.

    <item><strong|Why metadata is under CC0.> Pins, signatures and key logs are checked only where they can be copied; a licence would make every copy, index and reference a question of rights.

    <item><strong|Why the format does not judge the right to copy.> Whether a copy is lawful depends on the licence, on agreements with the rights holders, on the law where the archive is and on who keeps it, none of which is in the files; a list of licences checked by verifiers would refuse lawful copies and could not make others lawful. The archive that serves a copy answers for it, as any publisher does (#34).

    <item><strong|Why an entry with an identifier or a URL is a licence.> The kind of a <verbatim|rightsList> entry must be read from the file, not guessed from its name; a licence is identified, a statement is not (#50).
  </itemize>

  <subsection*|D.13 Versioning><label|d13-versioning>

  <\itemize>
    <item><strong|Why MAJOR.MINOR in files.> A patch changes no requirement; recording it would make equal files differ.

    <item><strong|Why unknown properties are ignored only from 1.0.> Before 1.0 a minor version may change the meaning of what a reader knows.
  </itemize>

  <subsection*|D.14 Profiles and schemas><label|d14-profiles-and-schemas>

  <\itemize>
    <item><strong|Why profiles.> Services and tools differ between archives, and the core needs none; a profile states what an archive using one promises, so that it can be checked.

    <item><strong|Why a Zenodo deposit is signed before publication.> The reserved DOI is then under the owner's signature, and no record is published for a version the line cannot take.

    <item><strong|Why Zenodo files never change.> The archive keeps each version fixed, so the 30-day window is not used, and description-only versions edit metadata, keeping one DOI per document version. MD5 is recorded because Zenodo reports only MD5.

    <item><strong|Why some schemas are closed.> Genesis records, key logs and keeper files decide names and keys, and a signature file holds exactly what it signs; an extra property there would seem committed to.

    <item><strong|Why <verbatim|datacite.json> is validated through XML.> It keeps the form of the REST API, and DataCite publishes no JSON Schema.
  </itemize>

  <section*|Appendix E. References><label|appendix-e-references>

  <\itemize>
    <item><hlink|RFC 2119|https://www.rfc-editor.org/rfc/rfc2119> and <hlink|RFC 8174|https://www.rfc-editor.org/rfc/rfc8174>, together <hlink|BCP 14|https://www.rfc-editor.org/info/bcp14>: key words

    <item><hlink|RFC 8259|https://www.rfc-editor.org/rfc/rfc8259>: JSON; <hlink|RFC 3629|https://www.rfc-editor.org/rfc/rfc3629>: UTF-8; <hlink|Unicode Standard Annex #15|https://www.unicode.org/reports/tr15/>: normalisation form C

    <item><hlink|RFC 3339|https://www.rfc-editor.org/rfc/rfc3339>: dates and times (the <verbatim|date-time> format of JSON Schema)

    <item><hlink|RFC 3986|https://www.rfc-editor.org/rfc/rfc3986>: URIs and percent-encoding; <hlink|RFC 7595|https://www.rfc-editor.org/rfc/rfc7595> and the <hlink|IANA registry of URI schemes|https://www.iana.org/assignments/uri-schemes/uri-schemes.xhtml>: registering <verbatim|sheaf>

    <item><hlink|RFC 4648|https://www.rfc-editor.org/rfc/rfc4648>: base32 and base64

    <item><hlink|FIPS 180-4|https://csrc.nist.gov/pubs/fips/180-4/upd1/final>: SHA-256, SHA-512 and SHA-1; <hlink|RFC 1321|https://www.rfc-editor.org/rfc/rfc1321>: MD5

    <item><hlink|RFC 8032|https://www.rfc-editor.org/rfc/rfc8032>: Ed25519

    <item><hlink|The did:key method|https://w3c-ccg.github.io/did-key-spec/> (W3C Credentials Community Group), with <hlink|multibase|https://github.com/multiformats/multibase> and <hlink|multicodec|https://github.com/multiformats/multicodec>

    <item><hlink|RFC 3161|https://www.rfc-editor.org/rfc/rfc3161>: time-stamp protocol; <hlink|OpenTimestamps|https://opentimestamps.org/>

    <item><hlink|RFC 9110|https://www.rfc-editor.org/rfc/rfc9110>: HTTP semantics, redirects; <hlink|RFC 8615|https://www.rfc-editor.org/rfc/rfc8615>: well-known URIs; <hlink|Fetch|https://fetch.spec.whatwg.org/>: cross-origin requests; <hlink|Content Security Policy Level 3|https://www.w3.org/TR/CSP3/>: <verbatim|sandbox>

    <item><hlink|OCFL 1.1 specification|https://ocfl.io/1.1/spec/> and <hlink|OCFL extensions|https://ocfl.github.io/extensions/>, among them <hlink|0003-hash-and-id-n-tuple-storage-layout|https://ocfl.github.io/extensions/0003-hash-and-id-n-tuple-storage-layout.html> and <hlink|0005-mutable-head|https://ocfl.github.io/extensions/0005-mutable-head.html>

    <item><hlink|DataCite Metadata Schema 4.7|https://schema.datacite.org/meta/kernel-4.7/>, <hlink|DataCite REST API|https://support.datacite.org/docs/api>, <hlink|its mapping between JSON and XML|https://support.datacite.org/docs/datacite-xml-to-json-mapping>, <hlink|the change for publisher and affiliation|https://support.datacite.org/docs/datacite-rest-api-affiliation-and-publisher-default-change> and <hlink|guidance on preprints|https://support.datacite.org/docs/preprints-post-prints-and-author-manuscripts>

    <item><hlink|JSON Schema 2020-12|https://json-schema.org/draft/2020-12>

    <item><hlink|ORCID|https://orcid.org/>, <hlink|ROR|https://ror.org/>, <hlink|SPDX License List|https://spdx.org/licenses/>, <hlink|MSC2020|https://msc2020.org/>, <hlink|NISO Journal Article Versions (NISO RP-8-2008)|https://www.niso.org/publications/niso-rp-8-2008-jav>, <hlink|Software Heritage identifiers (SWHID)|https://docs.softwareheritage.org/devel/swh-model/persistent-identifiers.html>

    <item><hlink|CC0 1.0|https://creativecommons.org/publicdomain/zero/1.0/> and <hlink|CC BY-SA 4.0|https://creativecommons.org/licenses/by-sa/4.0/>

    <item><hlink|arXiv|https://arxiv.org/> and its <hlink|default licence|https://arxiv.org/licenses/nonexclusive-distrib/1.0/>

    <item><hlink|amsmath|https://ctan.org/pkg/amsmath> and <hlink|amssymb|https://ctan.org/pkg/amsfonts> (CTAN); <hlink|TeXmacs|https://www.texmacs.org/>

    <item><hlink|Zenodo developer documentation|https://developers.zenodo.org/>, <hlink|InvenioRDM records API|https://inveniordm.docs.cern.ch/reference/rest_api_drafts_records/>, <hlink|Zenodo on folders|https://support.zenodo.org/help/en-gb/1-upload-deposit/74-can-i-upload-folders-directories>, <hlink|managing files|https://help.zenodo.org/docs/deposit/manage-files/>, <hlink|resource types|https://zenodo.org/api/vocabularies/resourcetypes>, <hlink|versioning|https://zenodo.org/help/versioning> and <hlink|the sandbox|https://sandbox.zenodo.org/>

    <item><hlink|Google Scholar inclusion guidelines|https://scholar.google.com/intl/en/scholar/inclusion.html>, <hlink|schema.org ScholarlyArticle|https://schema.org/ScholarlyArticle>, <hlink|JSON-LD 1.1|https://www.w3.org/TR/json-ld11/>, <hlink|FAIR Signposting|https://signposting.org/FAIR/>, <hlink|BibTeX|https://www.bibtex.org/>, <hlink|CSL-JSON|https://github.com/citation-style-language/schema>, <hlink|Atom (RFC 4287)|https://www.rfc-editor.org/rfc/rfc4287> and its <hlink|paged and archived feeds (RFC 5005)|https://www.rfc-editor.org/rfc/rfc5005>, <hlink|Sitemaps|https://www.sitemaps.org/protocol.html>, <hlink|OAI-PMH static repositories|https://www.openarchives.org/OAI/2.0/guidelines-static-repository.htm> and <hlink|ResourceSync|https://www.openarchives.org/rs/toc>

    <item><hlink|Radicle protocol guide|https://radicle.xyz/guides/protocol> and <hlink|The Update Framework|https://theupdateframework.io/>: identities and key logs compared in appendix D

    <item><hlink|KERI specification|https://trustoverip.github.io/kswg-keri-specification/> (Trust over IP Foundation) and <hlink|the KERI white paper|https://arxiv.org/abs/1907.02143> (S. M. Smith): pre-rotation of keys; <hlink|Sidetree|https://identity.foundation/sidetree/spec/> (Decentralized Identity Foundation): commitments to the next update keys
  </itemize>

  <strong|Companion documents.> <hlink|OpenSheaf archives in git|opensheaf-git-0.2.tm>, for archives kept in git repositories, and the <hlink|timestamps extension|opensheaf-timestamps-0.2.tm>, for dating signatures with RFC 3161 tokens and OpenTimestamps proofs.

</body>

<\initial>
  <\collection>
    <associate|page-medium|paper>
  </collection>
</initial>
