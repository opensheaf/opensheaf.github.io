<TeXmacs|2.1.5>

<style|<tuple|notes|notes-meta>>

<\body>
  <notes-header>

  <chapter*|OpenSheaf: an open format for document archives and collections>

  <notes-abstract|Specification, version 0.1 (draft), 19 November 2026. OpenSheaf is a common, open format for archives of scholarly documents and for collections of them, built on the Oxford Common File Layout (OCFL 1.1) and the DataCite Metadata Schema (4.7). The text is licensed under CC BY-SA 4.0; the JSON Schemas are dedicated to the public domain (CC0 1.0).>

  <os-alert|warning|Warning.|<strong|Draft, being rebuilt.> This text is being rebuilt, concept by concept, from the <hlink|reference text|reference/opensheaf-specification-0.1-full.md> of PR #30, into a shorter and coherent whole. A concept not yet rebuilt is read in the reference text. Until version 1.0, any revision may change the format in incompatible ways.>

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

  Two companion texts go with this specification: <hlink|OpenSheaf archives in git|opensheaf-git-0.1.tm>, for archives kept in git repositories, and the <hlink|timestamps extension|opensheaf-timestamps-0.1.tm>, for dating signatures. Questions about the design are answered in the <hlink|FAQ|faq.tm>, and the <hlink|use cases|use-cases.tm> show the format at work.

  The name: a sheaf is a bundle of papers and, in mathematics, the structure in which local pieces glue into a whole, as archives kept and checked separately compose into collections. The home of the format is <verbatim|https://opensheaf.org/>; the first archive is <verbatim|https://mgubi.org/papers/>, whose values appear in the examples.

  <section*|2. Conventions and conformance><label|2-conventions-and-conformance>

  The key words MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, RECOMMENDED, NOT RECOMMENDED, MAY and OPTIONAL are to be interpreted as described in BCP 14 (RFC 2119 and RFC 8174) when, and only when, they appear in all capitals. Sections marked non-normative, examples and notes are informative.

  JSON means RFC 8259 JSON in UTF-8 without a byte order mark. URLs are absolute unless stated otherwise; a relative URL in a JSON file is resolved against the URL of that file. Digests are written in lowercase hexadecimal unless stated otherwise. DOIs are written bare (<verbatim|10.5281/zenodo.123>), without a resolver prefix. Terms are defined where they are first introduced, written <dfn|thus>.

  <strong|Conformance classes.> An archive, an object or a program conforms to a class when it meets every MUST and MUST NOT of the sections listed for it:

  <\itemize>
    <item><strong|archive:> sections 3 to 13 and 15;

    <item><strong|collection:> section 8, with the rules on objects of sections 4 to 7;

    <item><strong|owner tool>, a program that seals, signs or keeps an owner's key log: sections 5 to 7, 10 and 15;

    <item><strong|verifier:> sections 14, 15.2 (on untrusted input) and 16 (as a reader), with the rules it checks;

    <item><strong|resolver:> sections 12 and 15.2 (on untrusted input), with sections 6 and 7 for checking signatures and key logs; a gateway also follows the rules on gateways of section 12.
  </itemize>

  <strong|Profiles.> An archive MAY also follow the profiles of appendix A (Zenodo, TeXmacs, website), and MUST list in its discovery document those it follows.

  <strong|Extensions.> An extension is a specification published apart, named by a URI (RECOMMENDED: the <verbatim|https> URL where it is published), that records what this specification leaves open, so that tools aware of it can act on it. Its data is kept under <verbatim|extensions>, keyed by the extension's name: in <verbatim|object.json> (section 4), where the inventory and the pins fix it, or in <verbatim|keys.json> (section 6), where the owner's signatures fix it. An extension MUST NOT change the meaning of what this specification defines, nor relax its requirements: archives, objects and collections are read and verified without knowing any extension, and readers ignore extensions they do not know. The discovery document SHOULD list the extensions its objects use. The <hlink|timestamps extension|opensheaf-timestamps-0.1.tm> is one.

  <strong|Schemas.> The JSON files defined here MUST validate against the JSON Schemas of appendix B for their declared format version.

  <section*|3. Archives><label|3-archives>

  An <dfn|archive> is a host of objects, served at a <dfn|base URL> ending with <verbatim|/>. It holds the lines that owners write there (section 7) and copies of lines written elsewhere (section 11). No file of an object names the archive that holds it (section 4.3), and what is authentic is decided by pins and the owners' signatures (sections 4 and 7), never by where a file was fetched; an archive decides only which owners it hosts and how they deposit (a university admitting its staff, a journal its editors). Its base URL is a location, not a name, and may change; an archive's files MAY be served at several base URLs, each a location of the same archive.

  An archive consists of a <strong|discovery document>, REQUIRED (section 3.1); a <strong|storage root>, REQUIRED (section 3.2); <strong|indexes>, RECOMMENDED (section 12); and <strong|presentation files>, OPTIONAL: web pages and other files generated for readers, never authoritative, kept outside the storage root (appendix A).

  <strong|Serving.> The discovery document, the storage root and the indexes MUST be served byte for byte, as stored: no conversion of line endings or character sets, and no compression that changes the bytes delivered after decoding. Archives SHOULD be served over HTTPS, and SHOULD allow cross-origin requests to these files (<verbatim|Access-Control-Allow-Origin: *>), so that tools in a browser can read them. Any static web server will do; an archive kept in git follows <hlink|OpenSheaf archives in git|opensheaf-git-0.1.tm>.

  <strong|Moving.> An archive moving to another site, or served at another, copies its files unchanged, its drafts included (section 10); nothing in them changes, so every pin, signature and witness stays valid. Its base URL, and every location of a copy given elsewhere (in collections, <verbatim|sheaf:> URIs, indexes), is a hint that needs no signature: whatever is fetched from it is checked against pins and signatures, so a wrong or stale location gives a reader nothing, or an older valid copy, never a forged one.

  <subsection*|3.1 The discovery document><label|31-the-discovery-document>

  The <dfn|discovery document> is the JSON file <verbatim|opensheaf.json> at the base URL. Static web servers cannot list folders; this one file makes an archive's objects known. It MUST contain:

  <\itemize>
    <item><verbatim|format>: <verbatim|"opensheaf-archive/0.1">, and <verbatim|specification>: <verbatim|"0.1">;

    <item><verbatim|name>: a readable name of the archive;

    <item><verbatim|storageRoot>: the URL of the storage root, ending with <verbatim|/> (it may be relative);

    <item><verbatim|storageLayout>: its layout, <verbatim|"opensheaf-owner-name-storage-layout"> or <verbatim|"0003-hash-and-id-n-tuple-storage-layout"> (section 3.2);

    <item><verbatim|profiles>: the profiles it follows, from <verbatim|zenodo>, <verbatim|texmacs>, <verbatim|website> (appendix A), possibly none;

    <item><verbatim|objects>: every object of the storage root except drafts, each with <verbatim|id> (section 4), <verbatim|kind>, <verbatim|name> and <verbatim|owner> (section 7), <verbatim|head> (its OCFL head version), <verbatim|inventorySha512> (the SHA-512 digest of the head inventory, as its checksum file states it) and <verbatim|status> (<verbatim|active> or <verbatim|withdrawn>, that of its latest version that is signed or unchecked, sections 7.3 and 13.1), and OPTIONALLY a <verbatim|label>.
  </itemize>

  It SHOULD contain <verbatim|mainCollection>, the identifier of the catalogue of the archive's documents (section 8); <verbatim|contact>, a URI; and <verbatim|extensions>, the names of the extensions its objects use (section 2). It MAY contain <verbatim|owners>, the owner names of the owners it hosts (section 6); <verbatim|drafts>, the drafts it chooses to show, with <verbatim|id>, <verbatim|kind> and <verbatim|head>, as unfinished work on which nothing may rely (section 10); <verbatim|indexes>, which maps each index kept to the length of the prefixes of its files (section 12.5); and <verbatim|feed>, the URL of an Atom feed of new object versions. It MUST contain <verbatim|tombstones> once an object has been taken down (section 13.3).

  The discovery document is rewritten whenever an object is added or changed. It is a map, not a witness: everything it states about objects MUST agree with the storage root, which verifiers check (section 14), and it lists what the archive holds, not every line an owner has elsewhere.

  <strong|Labels.> A <dfn|label> is a short readable name an archive MAY give a line it holds, for readable URLs on its website: it matches <verbatim|^[a-z0-9]+(-[a-z0-9]+)*$>, has at most 64 characters, and is unique in the discovery document. It is the archive's choice, may change, and is not an identifier; permanent links use <verbatim|sheaf:> URIs (section 12). Labels SHOULD be chosen by the depositor, not derived from the title.

  <subsection*|3.2 The storage root><label|32-the-storage-root>

  The <dfn|storage root> is an OCFL 1.1 storage root at the URL <verbatim|storageRoot>, holding the archive's objects (section 4). Since OCFL allows in it only the folders that lead to objects, and extensions, it SHOULD be a dedicated folder (by convention <verbatim|ocfl/>), and presentation files MUST NOT be placed in it. It MAY contain, as loose files, copies of the OCFL specification and of this one. Its <verbatim|ocfl_layout.json> names its storage layout, which MUST be the one given by <verbatim|storageLayout>:

  <\itemize>
    <item><strong|The owner-name layout>, <verbatim|opensheaf-owner-name-storage-layout>, the default, defined here (not yet registered with OCFL, so validators may warn about it). The object whose identifier is <verbatim|sheaf:\<less\>name\<gtr\>:\<less\>owner\<gtr\>> (section 4) is at <verbatim|\<less\>owner\<gtr\>/\<less\>name\<gtr\>/>, and a draft <verbatim|sheaf:draft:\<less\>id\<gtr\>> at <verbatim|draft/\<less\>id\<gtr\>/>; any other identifier is an error. An owner's object is thus at <verbatim|\<less\>owner\<gtr\>/\<less\>owner\<gtr\>/>, and the folder of an owner holds its key log and every line of it in the archive, so that an owner moving elsewhere copies one folder. The layout has no parameters; <verbatim|ocfl_layout.json> describes it as <verbatim|"Lines at \<less\>owner\<gtr\>/\<less\>name\<gtr\>, drafts at draft/\<less\>id\<gtr\>">.

    <item><strong|The hashed layout>, for large archives: OCFL's <verbatim|0003-hash-and-id-n-tuple-storage-layout> with its default parameters (<verbatim|sha256>, tuples of 3 characters, 3 tuples), which a configuration file, if present, MUST NOT change. An object is at <verbatim|\<less\>t1\<gtr\>/\<less\>t2\<gtr\>/\<less\>t3\<gtr\>/\<less\>encoded id\<gtr\>/>, where <verbatim|\<less\>t1\<gtr\>>, <verbatim|\<less\>t2\<gtr\>>, <verbatim|\<less\>t3\<gtr\>> are the first three groups of three characters of the hexadecimal SHA-256 digest of its identifier, and <verbatim|\<less\>encoded id\<gtr\>> is the identifier percent-encoded as the extension says (every character but <verbatim|A-Z>, <verbatim|a-z>, <verbatim|0-9>, <verbatim|-> and <verbatim|_>, in lowercase hexadecimal, <verbatim|%3a>), shortened, when longer than 100 characters, to its first 100 characters, <verbatim|-> and the full digest; identifiers of lines are always shortened so (appendix C). Readers compute the path; they never decode it.
  </itemize>

  Archives SHOULD use the owner-name layout, unless one folder per owner or per name becomes impractical (tens of thousands of lines, fewer in a git repository). The layout is chosen when the archive is created and SHOULD NOT be changed: pins stay valid, since readers compute paths from <verbatim|storageLayout>, but every URL into the storage root changes.

  <section*|4. Objects><label|4-objects>

  An <dfn|object> is an OCFL 1.1 object in a storage root. Its <dfn|kind>, given by its <verbatim|object.json> and never by its identifier, is <verbatim|document>, one work (an article, notes, a thesis, a book) with its sources and renditions; <verbatim|collection>, a list of members (section 8); or <verbatim|owner>, the key log of an owner (section 6).

  <strong|Identifier.> The <dfn|identifier> of an object, its OCFL <verbatim|id>, is <verbatim|sheaf:\<less\>name\<gtr\>:\<less\>owner\<gtr\>>, the name of the work (section 5) and the owner name of its line's owner (section 6), which <verbatim|object.json> records as <verbatim|name> and <verbatim|owner>. It names the line (section 7), in every archive. A branch is a new object with its own identifier (section 9); a draft is <verbatim|sheaf:draft:\<less\>id\<gtr\>> (section 10). The identifier MUST be unique in the storage root, and that of a sealed object MUST NOT be reused there, also after a takedown (section 13).

  <strong|Versions.> An <dfn|object version> is an OCFL version of an object (<verbatim|v1>, <verbatim|v2>, ...): every change of the object makes one, and none changes once made, except in a draft (section 10) and at a fork of a key log (section 6.3). A <dfn|document version> is a version of the work, a positive integer numbered by the owner of the line and recorded in <verbatim|object.json> and <verbatim|datacite.json>; it changes only when the document's own files change (section 4.2), so several object versions may hold one document version, with different descriptions or notices.

  <strong|Pins.> A <dfn|pin> is the pair (object version, SHA-512 digest of that version's inventory file, as its checksum file states it). An inventory records the digests of the files of its version and of every earlier one, so a pin fixes the object up to that version, in any copy. Collections (section 8), branches (section 9) and <verbatim|sheaf:> URIs (section 12) refer to object versions by pins, and pin only signed versions (section 7).

  <subsection*|4.1 Common rules><label|41-common-rules>

  Every object MUST be a valid OCFL 1.1 object, and:

  <\itemize>
    <item>its inventories MUST use the digest algorithm <verbatim|sha512>; they MAY also record MD5 and SHA-256 digests in <verbatim|fixity> (the Zenodo profile requires MD5, appendix A);

    <item>every version directory MUST contain the inventory as of that version, with its checksum file, so that each version can be pinned and fetched on its own;

    <item>version directories MUST NOT be zero-padded (<verbatim|v1>, not <verbatim|v001>);

    <item>logical paths MUST be in UTF-8 and Unicode normalisation form C, and MUST NOT begin or end with <verbatim|/>, or contain empty, <verbatim|.> or <verbatim|..> segments, or <verbatim|\\>.
  </itemize>

  <strong|Deposits.> Each version in the inventory MUST have a <verbatim|user> with a <verbatim|name>, SHOULD give its <verbatim|address> (an ORCID iD, a <verbatim|mailto:> URI or another URI identifying the depositor), and MUST have a <verbatim|message> describing the change. The <verbatim|created> date and <verbatim|user> of an object version record its <dfn|deposit>, not repeated in <verbatim|object.json>; the deposit of a document version is that of the first object version holding it.

  <strong|Content.> Every object version MUST contain, at the top level of its content, <verbatim|object.json> (section 4.3); <verbatim|datacite.json> (section 4.4), except in an owner object; and the genesis record <verbatim|genesis.json> (section 5), except in a draft. Every version of a branch also holds the evidence of its branch point: <verbatim|parent.inventory.json>, <verbatim|parent.object.json>, <verbatim|parent.signatures/> and, for a branch of a branch, <verbatim|parent.chain/> (section 9). The genesis record and this evidence are the <dfn|identity files> of the object, never files of the document's own. The names of every file this specification defines at the top level of the content (<verbatim|object.json>, <verbatim|datacite.json>, <verbatim|genesis.json>, <verbatim|members.json>, <verbatim|keys.json>, <verbatim|forked>, <verbatim|parent.inventory.json>, <verbatim|parent.object.json>, <verbatim|parent.signatures>, <verbatim|parent.chain>) are reserved for those files. A collection version also holds <verbatim|members.json> (section 8). An owner object holds <verbatim|genesis.json> and <verbatim|keys.json> (section 6), a fork record <verbatim|forked/> instead of <verbatim|keys.json> (section 6.3), and no <verbatim|datacite.json>; it has no document versions, and is never withdrawn or branched. Signatures and other witnesses are kept outside every version, in the object's extension folder <verbatim|extensions/opensheaf-witnesses/> (section 7).

  <subsection*|4.2 Documents and document versions><label|42-documents-and-document-versions>

  A document version holds, at the top level of its content, besides the files of section 4.1:

  <\itemize>
    <item>the <dfn|sources>: the main source and every file needed to produce the renditions that is not part of the toolchain (images, bibliography databases, local style files); they SHOULD be flat (no sub-folders) when possible;

    <item>the <dfn|renditions>, files produced from the sources (a PDF, an EPUB): OPTIONAL, but RECOMMENDED, at least a PDF for a document meant to be read and cited;

    <item>the files of its notes, if any (section 4.3).
  </itemize>

  The sources, the renditions and the change note (<verbatim|changes>, section 4.3) are the document's own files. HTML versions and other presentation files SHOULD NOT be deposited.

  <strong|Numbering.> The owner of the line numbers document versions from 1, without gaps, independently of any external numbering: a work whose versions 1, 3 and 4 are on arXiv has document versions 1, 2 and 3. External labels (arXiv's <verbatim|v3>) are recorded in <verbatim|external> (section 4.3); presentations SHOULD show them with the document version. Branches number as section 9 says.

  <strong|New versions.> A new document version is made exactly when the document's own files change (a file added, changed or removed, the change note included), except when a version without sources is completed (below); an object version holding the same own files as an earlier document version keeps its number. A collection makes a new document version exactly when its member list changes (section 8). A version not public at the time (the manuscript submitted to a journal), deposited later, is a document version like any other; a version published by someone else (the journal's version of record) is not, and is linked by a relation (section 4.4).

  <strong|Description-only versions.> A <dfn|description-only version> holds an existing document version with its files unchanged, and changes only its description (<verbatim|datacite.json>: a DOI, a link to the published article), its <verbatim|stage>, the state of the object or its notices. It MAY hold any document version, so that an earlier one can be described; tools otherwise hold the current version. If the object has <verbatim|history>, the entry of that document version becomes the new object version.

  <strong|Completion.> A document version deposited with <verbatim|sourcesMissing> (section 4.3) MAY be completed, keeping its number, by object versions that add its sources, possibly with renditions made from them, and change or remove no file of the version. It keeps <verbatim|sourcesMissing> until the sources are complete; the object version that completes them names the main source and drops <verbatim|sourcesMissing>, and the version is then fixed like any other.

  <strong|History.> The <dfn|history> of a document is the order of its document versions in the history of the work: the order of their numbers, unless <verbatim|object.json> has <verbatim|history>, the list, in that order, of the last object version holding each document version. An object version that deposits a document version out of order (an earlier version found later) MUST write <verbatim|history>, and every later object version MUST keep it. A version whose place is unknown goes just before the current version, and its change note SHOULD say so. The history is read from the latest signed version of the line (section 7); earlier object versions keep it as it was then known. Dates never order document versions.

  <strong|Current version.> The <dfn|current version> of a document is the last of its history. The latest signed version may hold another document version, deposited out of order or newly described; the current version stays where it was. Landing pages, indexes and citations use the current version.

  <strong|Notices.> A <dfn|notice> is a statement about a document version made after it, since the version cannot change (that a theorem of version 2 is wrong as stated, and corrected in version 3). Notices are added to <verbatim|notices> by description-only versions, and stay, unchanged, in every later object version (for a branch whose branch point moves, see section 9); a notice is corrected or withdrawn only by a later notice. Presentations showing a document version SHOULD show the current notices about it.

  <subsection*|4.3 The object record: object.json><label|43-the-object-record-objectjson>

  Every object version MUST contain <verbatim|object.json>, the record of the object's identity, content, versions and state; it names no archive. It MUST contain:

  <\itemize>
    <item><verbatim|format>: <verbatim|"opensheaf-object/0.1">, and <verbatim|specification>: <verbatim|"0.1">;

    <item><verbatim|kind>: <verbatim|document>, <verbatim|collection> or <verbatim|owner>;

    <item><verbatim|status>: <verbatim|active> or <verbatim|withdrawn> (section 13.1), always <verbatim|active> for an owner or a draft;

    <item><verbatim|documentVersion>, for a document or a collection: equal to <verbatim|version> in <verbatim|datacite.json>;

    <item>in every version of a line, <verbatim|name> and <verbatim|owner> (sections 5 and 6), and in a branch <verbatim|parent>, its branch point (section 9); a draft has none of them.
  </itemize>

  An owner object has only these fields, and MAY have <verbatim|extensions> (below), though data concerning its key log goes in <verbatim|keys.json> (section 6).

  A <dfn|note> is an object with <verbatim|text>, a short plain text, or <verbatim|path> and <verbatim|mediaType>, a file of the content of the same object version, or both.

  A document MUST have <verbatim|mainSource> (a logical path) and <verbatim|sourceFormat> (its media type), and SHOULD have <verbatim|renditions>, a list of <verbatim|path> (a logical path) and <verbatim|mediaType>, and <verbatim|toolchain>, a list of tools with <verbatim|name>, <verbatim|version> and, OPTIONALLY, <verbatim|packages>, enough to reproduce the renditions. A document version without its sources has instead <verbatim|sourcesMissing>, a note saying why ("arXiv keeps only the PDF of this version"), and at least one rendition; a rendition is never presented as a source. A document MAY have:

  <\itemize>
    <item><verbatim|changes>: a note saying what changed in this document version, deposited with it (like arXiv's comments);

    <item><verbatim|stage>: the stage of this document version, with <verbatim|scheme> and <verbatim|value>; for articles the RECOMMENDED scheme is <verbatim|NISO-JAV> (NISO Journal Article Versions: <verbatim|AO>, <verbatim|SMUR>, <verbatim|AM>, <verbatim|P>, <verbatim|VoR>, <verbatim|CVoR>, <verbatim|EVoR>), and other content uses other schemes (editions, software releases), named by the archive;

    <item><verbatim|history> and <verbatim|notices> (section 4.2), each notice a note with the <verbatim|documentVersion> it is about and a <verbatim|date>;

    <item><verbatim|licence>: a note with the full text or terms of the licence (for licences without an SPDX identifier); <verbatim|rightsList> in <verbatim|datacite.json> remains the description for readers.
  </itemize>

  A collection has none of these fields of a document, and its notes are text only (section 8.2). A document or a collection MAY have:

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

    <item><verbatim|rightsList>: for a licence with an SPDX identifier, that identifier in lower case and the licence URL; for one without, its name in <verbatim|rights> and, REQUIRED then, the URL identifying it in <verbatim|rightsUri> (for arXiv's default licence, <verbatim|http://arxiv.org/licenses/nonexclusive-distrib/1.0/>); or a statement such as "All rights reserved", without URL;

    <item><verbatim|language>, <verbatim|formats> (the media types of sources and renditions) and <verbatim|sizes>;

    <item>identifiers of creators (ORCID) and affiliations (ROR), where they exist;

    <item><verbatim|relatedIdentifiers> (below).
  </itemize>

  <verbatim|publisher> is the owner of the line, the body behind it (a journal, an institution), or the service registering the version's DOI (appendix A). <verbatim|publisher> and <verbatim|affiliation> SHOULD be objects, with <verbatim|name> and, where available, an identifier; readers MUST also accept strings. <verbatim|doi> and <verbatim|url> are present when the version has a DOI. <verbatim|resourceTypeGeneral> is from DataCite's list (<verbatim|Collection> for collections), with <verbatim|resourceType> for detail ("Lecture notes"). An author's versions of a work not published elsewhere, the accepted manuscript included, are <verbatim|Preprint>; <verbatim|stage> in <verbatim|object.json> gives their stage.

  <strong|Mathematics.> Titles and abstracts are plain text, in which mathematics MAY be written in LaTeX between single dollar signs (<verbatim|$\\Phi^4_3$>; a literal dollar is <verbatim|\\$>). It SHOULD use only the mathematical commands of LaTeX with <verbatim|amsmath> and <verbatim|amssymb>, which common renderers display without the document's preamble. Tools importing them SHOULD replace the authors' macros (<verbatim|\\R>) with standard LaTeX when their definitions are known, and otherwise keep them; they MUST NOT invent definitions.

  <strong|Dates.> Each date type has one meaning:

  <\itemize>
    <item><verbatim|Issued>: the first public appearance of the work, anywhere, the same in every version; RECOMMENDED, and tools importing works published elsewhere SHOULD set it;

    <item><verbatim|Available>, SHOULD be present: when this document version first became public, anywhere (its date on the service it was imported from, or its deposit, section 4.1, if it was first made public by its deposit);

    <item><verbatim|Updated>: the date of the latest description-only version holding this document version, if any;

    <item><verbatim|Created> (when a version not public at the time was written), <verbatim|Submitted> and <verbatim|Accepted>, OPTIONAL;

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
    <item><verbatim|format>: <verbatim|"opensheaf-genesis/0.1">;

    <item><verbatim|kind>: <verbatim|document>, <verbatim|collection> or <verbatim|owner>, the <verbatim|kind> of the object;

    <item><verbatim|created>: the date and time it was written, in UTC (<verbatim|2026-03-02T09:14:00Z>);

    <item><verbatim|nonce>: at least 128 bits from a cryptographically secure random generator, in lowercase hexadecimal;

    <item>for a document or a collection, <verbatim|originator>: the owner name of the owner of the first line (section 5.3);

    <item>for an owner, instead, <verbatim|keys> and <verbatim|threshold>: its first keys and how many must sign, which the first version of its key log repeats (section 6).
  </itemize>

  The genesis record MUST be part of every object version of the object and of its branches (section 9), byte for byte. It MUST be in UTF-8 without a byte order mark, and SHOULD have LF line ends. Since the name is the digest of its bytes as stored, tools MUST NOT rewrite or re-serialise it. A tool MUST NOT copy a genesis record into an object that is not a copy or a branch of the work it was written for, nor reuse a nonce.

  <subsection*|5.2 Computing a name><label|52-computing-a-name>

  Algorithm k, for k from 0 to 15, takes the SHA-256 digest of the seed <verbatim|opensheaf-name-\<less\>k\<gtr\>> (ASCII, k in decimal, followed by a line feed) followed by the bytes of <verbatim|genesis.json>, and writes it in lowercase base32 (RFC 4648, without padding): 52 characters, the last of which holds the last bit of the digest and four zero bits, which are set to k. A name thus matches <verbatim|^[a-z2-7]{52}$>, and its last character gives its algorithm (<verbatim|a> or <verbatim|q> for algorithm 0), so names made by different algorithms never coincide. Names are compared as strings, never decoded. <verbatim|object.json> records a line's name as <verbatim|name>; appendix C gives examples.

  A genesis record thus has 16 names of one work (section 12 searches for a work by all of them). Its <dfn|genesis name>, made by algorithm 0, is the same for every line of the work. Every line is named by its genesis name, except a branch renamed after a clash (section 5.3).

  <subsection*|5.3 Origin and clashes><label|53-origin-and-clashes>

  <strong|Origin.> The <dfn|originator> of a work is the owner its genesis record names in <verbatim|originator>; an owner is its own originator. The originator's line is the origin of the name: it has no parent, and its first version MUST be signed by the originator (section 7). Every other line of the genesis record is a branch and MUST declare its parent (section 9); a line of another owner that declares none is not a valid line of the name. A tool refuses a branch owned by the originator (how the originator takes in another line's work is open, #57).

  <strong|Clashes.> An owner has one line of each name, and no two objects of a storage root have the same line (section 4). A clash can arise only when a line is made, and the tool that makes it resolves it against the archive where it writes and the lines of the same owner it knows elsewhere that are signed (section 7):

  <\itemize>
    <item><strong|Sealing.> If the line is taken, the tool draws a new nonce, so that an originator's line is always named by algorithm 0. A work sealed elsewhere that meets, when deposited, a taken line with another genesis record (a collision) is refused, and its owner seals it anew; with the same genesis record, it is a copy (below), or a reused record (section 5.4).

    <item><strong|Branches.> A branch is named by <verbatim|parent.name>, unless its line is taken by another line of its owner, in which case it is named by the smallest algorithm number greater than that of <verbatim|parent.name> that gives a line free for its owner, and <verbatim|parent> keeps the parent's name; if none up to 15 is free, the branch is refused. When the line taken is the owner's own branch of the same parent line, section 9 says when the owner moves that branch's branch point instead.

    <item><strong|Copies.> A copy whose line is taken in a storage root by a different history of it is a fork of the line (section 7): the archive keeps the history it holds, and reports the other.

    <item><strong|Takedowns.> A line stays taken in an archive after a takedown, since its tombstone keeps its identifier (section 13).
  </itemize>

  Lines of different owners never clash. A renamed branch is always written with its owner part, since a <verbatim|sheaf:> URI without one names the originator's line (section 12).

  <subsection*|5.4 Reused genesis records><label|54-reused-genesis-records>

  A genesis record reused for another work gives no valid line: the originator's line needs the originator's signature, and every other line needs a chain of signed parents back to it (section 9). A second history that the originator signs under its own record is a fork of its line (section 7).

  When an object is created or deposited, an archive that holds an object or a tombstone with the same genesis record, compared by genesis name (<verbatim|genesisName> of a tombstone, section 13), MUST refuse it unless it is signed by the originator (the originator's line) or is a branch whose branch points are confirmed back to the originator's line (section 9.3).

  <strong|Open question.> Whether aliases, new genesis records wrapping an old one, are needed if refusing reused genesis records proves too strict (#44).

  <section*|6. Owners><label|6-owners>

  An <dfn|owner> is a keyed identity: a person, a group or an institution that decides the versions of its lines and signs them (section 7), wherever they are stored. It is an object of kind <verbatim|owner> (section 4), named by its genesis record (section 5): its <dfn|owner name> is the name of that record, the name that genesis records (<verbatim|originator>), <verbatim|object.json> (<verbatim|owner>, and <verbatim|owner> in <verbatim|parent>) and <verbatim|sheaf:> URIs (section 12) record. The owner object is the owner's own line, <verbatim|(owner name, owner name)>, at <verbatim|\<less\>owner\<gtr\>/\<less\>owner\<gtr\>/> in the owner-name layout (section 3.2). Its object versions are the owner's <dfn|key log>.

  <subsection*|6.1 The key log><label|61-the-key-log>

  Every version of the key log holds, besides the files of section 4.1, the file <verbatim|keys.json>, with:

  <\itemize>
    <item><verbatim|format>: <verbatim|"opensheaf-keys/0.1">;

    <item><verbatim|keys>: the public keys of the owner, at least one, each distinct, each an Ed25519 key written as a <verbatim|did:key> URI (W3C CCG; multibase base58btc, multicodec <verbatim|ed25519-pub>, code <verbatim|0xed>, written as the varint bytes <verbatim|0xed 0x01>);

    <item><verbatim|threshold>: the number of distinct keys of this version that must sign, a positive integer;

    <item><verbatim|extensions>, OPTIONAL: the data of extensions concerning the key log, keyed by their names (section 2), each an object; for instance the declaration of the <hlink|timestamps extension|opensheaf-timestamps-0.1.tm>;

    <item><verbatim|keeper>, OPTIONAL: <verbatim|https> URLs of whoever answers for the owner (section 6.6);

    <item><verbatim|ended>, OPTIONAL: <verbatim|true> in the last version of the key log of an owner that ends (section 6.3);

    <item><verbatim|successor>, OPTIONAL, only with <verbatim|ended>: the owner name of the owner that continues its work (section 6.3).
  </itemize>

  In the genesis record of an owner and in every <verbatim|keys.json>, <verbatim|threshold> MUST NOT exceed the number of <verbatim|keys>.

  Key-log versions are the OCFL versions of the owner object (<verbatim|v1>, <verbatim|v2>, ...); an owner object has no document versions. The first version holds the genesis record and the first <verbatim|keys.json>, whose <verbatim|keys> (compared as a set) and <verbatim|threshold> MUST be those of the genesis record; it MAY add <verbatim|keeper> and <verbatim|extensions>. Its authority comes from the genesis record: another first version under the same owner name would need other keys, and so another name. It is signed by <verbatim|threshold> of its own keys. Every later version vN+1 MUST be signed by at least <verbatim|threshold> distinct keys of vN, <verbatim|threshold> being that of vN. Signature files, and when a signature is good, are defined in section 7.

  A key is added or retired, the threshold or the data of an extension changed, a keeper named, or the owner ended, by a new version of the key log; the owner name never changes. Changing the keys or the threshold affects only signatures naming the new version or a later one: signatures naming earlier versions stay good (section 7), and nothing is signed again.

  <subsection*|6.2 Creating an owner and choosing its keys><label|62-creating-an-owner-and-choosing-its-keys>

  An owner tool creates an owner by writing its genesis record, with <verbatim|kind> <verbatim|owner> and the first <verbatim|keys> and <verbatim|threshold> (section 5.1), and the first version of its key log, signed as above. An owner is its own originator, and its owner object has no parent, so its owner name is made by algorithm 0 (section 5.2). If the owner name is taken, in the archive where the tool writes or among the owners it knows elsewhere, the tool draws a new nonce (section 5.3).

  <strong|Choosing a threshold.> One <verbatim|threshold> governs the key log and every line of the owner. Owners choose between two risks: a threshold of 1 with a spare key kept apart (on a hardware token, for instance) survives the loss of a key, and the theft of the key in daily use by healing (section 6.3), though what the thief signed stays good (section 6.4); a threshold of 2 with three keys kept apart, from the first version of the key log, survives the loss of one key and the theft of one. Owner tools SHOULD offer both, and SHOULD NOT create an owner with a single key, since an owner that loses every key of the latest version of its key log cannot recover.

  <strong|Retiring a key.> An owner retires a key it no longer uses (a replaced laptop, a member who leaves the group) by leaving it out of <verbatim|keys> in a new version of its key log. Signatures made with it stay good, and a retired key in someone else's hands still makes good signatures naming the versions that list it; so retiring is enough after an exposure only when the exposed keys cannot reach a threshold (section 6.3).

  <subsection*|6.3 Ending, forks and healing><label|63-ending-forks-and-healing>

  <strong|Ending.> An owner ends by signing, as usual, a last version of its key log with <verbatim|ended> <verbatim|true> and, OPTIONALLY, <verbatim|successor>, the owner name of a new owner that continues its work, which MUST differ from its own owner name. The ending version only ends: a version after one with <verbatim|ended> is not a version of the key log, and no signature of a line may name the ending version (section 7). Signatures made before it name earlier versions, and stay good. Owner tools MUST NOT sign anything for an ended owner. A successor is a hint, never followed automatically; its keeper MAY confirm it (section 6.6). An owner is <dfn|ended> when its key log has an ending version.

  <strong|Exposed keys.> An owner whose keys may have been exposed (stolen, leaked, copied), and could together reach the <verbatim|threshold> of some version of its key log that lists them, MUST end, or nullify them by a fork of its key log and heal it (below); otherwise retiring them is enough (a threshold of 2 from the first version, and one key exposed).

  <strong|Forks of a key log.> Two different versions of a key log with the same number, each signed by <verbatim|threshold> keys of the version before, are a <dfn|fork of the key log>; that number is the <dfn|fork point>. Whoever holds <verbatim|threshold> keys of the version before can make one: a thief, or the owner itself, signing two versions with keys it wants nullified. The format cannot tell which side is the owner's, so it trusts neither: an archive that holds one side and meets the other replaces, in its copy, the version it holds at the fork point by a fork record, and drops every later version.

  <strong|Fork records.> A <dfn|fork record> is a version of the key log at the fork point, made by the archive that records the fork (its deposit, section 4.1), and not signed: besides <verbatim|genesis.json> and <verbatim|object.json>, it holds only the conflicting versions it <dfn|carries>, each under <verbatim|forked/\<less\>d\<gtr\>/>, where <verbatim|\<less\>d\<gtr\>> is the first 16 characters of the lowercase base32 (RFC 4648, without padding) SHA-256 digest of its inventory file: that inventory file as <verbatim|inventory.json>, its checksum file as <verbatim|inventory.json.sha512>, its <verbatim|keys.json>, and its signature files <verbatim|signature-\<less\>k\<gtr\>.json> with the witnesses beside them (section 7.2), byte for byte. It is valid when it carries at least two versions of its number, with different inventory files, each signed (section 7.3) against the version before it, which anyone checks from its content and that version; otherwise it is not a version of the key log. The keys that sign the versions a fork record or a healing version carries, and the keys those nullify, are <dfn|nullified>. A key log whose latest version is a fork record is <dfn|tainted>: no version follows a fork record but by healing, no signature names one, and owner tools sign nothing for a tainted owner but a healing version. Fork records are copied with the key log like any version, so that every copy shows the fork.

  <strong|Healing.> A <dfn|healing version> is a version of the key log at a fork point that carries, as a fork record does, one or more versions of its number, each signed against the version before; that holds a <verbatim|keys.json> listing none of the keys it nullifies; and that is signed by <verbatim|threshold> keys of the version before, none of them nullified by it. It is otherwise a version like any other, and the key log continues from it. The owner heals a tainted key log by a healing version carrying every version the fork record carries; it answers a thief directly by a healing version carrying the thief's version. An owner that cannot heal, having too few keys left, stays tainted, which is treated as an end (section 6.4); its keeper MAY name a successor (section 6.6). Owner tools SHOULD keep, besides the keys in daily use, at least <verbatim|threshold> spare keys kept apart and used only to heal, and MUST show the owner a version of its key log that the owner did not make before signing anything.

  <strong|When versions meet.> When a reader or an archive holding a version of a key log meets a different version of the same number, after the same versions: a fork record or a healing version <dfn|supersedes> a version it carries, a version signed by a key it nullifies, and a fork record that carries no version it does not carry; the version superseded is replaced by the one that supersedes it. Otherwise the two are replaced by a fork record carrying every version they are or, for fork records and healing versions, carry. The versions after a version replaced are dropped; signatures naming them are unchecked there (section 7.3). The files of the witness folder of a version replaced or dropped go with it, those of a carried version into <verbatim|forked/\<less\>d\<gtr\>/>. These replacements are made only to key logs, and are the only changes of an object version outside drafts (section 4).

  <subsection*|6.4 After an end, a fork or healing><label|64-after-an-end-a-fork-or-healing>

  The signatures of an ended or tainted owner, and the signatures made with nullified keys, stay good, since the format does not date signatures; but versions signed after a key was exposed cannot be told from a thief's, so readers trust them only as far as other evidence goes: copies held before, the pins of collections (section 8), timestamps (the <hlink|timestamps extension|opensheaf-timestamps-0.1.tm>).

  <strong|Nullified keys.> An archive adds no version, of a line or of a key log, that is signed only thanks to a signature made with a nullified key or naming a version carried by a fork record or a healing version (section 7.5); the versions it holds stay. Since fork records and healing versions travel with key logs, every archive that receives one applies this rule from then on.

  <strong|Ended and tainted owners.> An archive that knows an owner is ended or tainted adds that owner's key log up to the ending version or the fork record, and takes that owner's lines only from copies found elsewhere, never as new deposits; section 7 gives the rule for adding their versions. The work of an ended owner continues under its successor, by branches of its versions (section 9); a healed owner continues its own lines. Resolvers and verifiers report ended, tainted and healed owners, and successors (sections 12 and 14).

  <subsection*|6.5 Key logs travel with the objects they sign><label|65-key-logs-travel-with-the-objects-they-sign>

  A key log checks itself from its owner name: the genesis record of its first version lists the first keys, and each later version is signed by the keys of the one before. A copy from any source is therefore as good as the original, and a line can be checked without trusting any host, also after the archives that served it have gone.

  Every copy of an object, in any archive, MUST hold beside it, as owner objects in the same storage root at their paths (section 3.2), the key logs of the owner of its line and, for a branch, of the owner of each parent whose signatures its evidence holds, in <verbatim|parent.signatures/> and at every level of <verbatim|parent.chain/> (section 9). Each is copied up to the latest version that whoever makes the copy knows, and at least up to the versions its signatures name. The key logs of third parties whose witnesses a copy holds (section 7) MAY be copied too. Key logs are never copied into an object's content. An archive MUST keep an owner object as long as it keeps an object whose signatures need it, unless the owner object is itself taken down; a tombstone then stands in for it, and a takedown of a line leaves its owner objects in place (section 13). An owner object MAY also be copied on its own, to keep a fresher copy of its key log.

  Of two copies of a key log, either one extends the other, and readers use the longer, or they meet at a fork point, as section 6.3 says. No one can prove offline that a key log is complete: a copy that stops early may hide that the owner has ended.

  <strong|Moving.> An owner moving to another archive copies its owner object there, with the lines it wants to keep there, and continues its lines in the new archive: the same owner and the same lines, not branches. The old copies stay valid where they are, as older copies of the same lines (section 7). In the owner-name layout this is one folder (section 3.2).

  <subsection*|6.6 Keepers><label|66-keepers>

  An owner MAY name, in <verbatim|keeper> of its key log, the person or institution who answers for it: an ORCID iD (<verbatim|https://orcid.org/...>) or a domain written as <verbatim|https://\<less\>domain\<gtr\>/>. The keeper MAY confirm it, in a place only the keeper controls: a link naming the owner in its ORCID record, or the file <verbatim|https://\<less\>domain\<gtr\>/.well-known/opensheaf> on its domain, a JSON object with <verbatim|format> <verbatim|"opensheaf-keeper/0.1">, <verbatim|owners>, the owner names it answers for, and OPTIONALLY <verbatim|successors>, an object mapping owner names it answers for to their successors (on ORCID, a link naming both). A successor the keeper names confirms the owner's own <verbatim|successor>; for an owner that cannot sign any more (every key lost), the keeper MAY name one alone, which is reported as named by the keeper, and does not end the owner.

  When a keeper is named, a verifier MAY check both directions, and reports the link as confirmed, claimed only (the keeper does not confirm it) or absent. A confirmation is read as it is now: a keeper who withdraws it ends the link, and what the owner signed stays authentic. The link says who answers for an owner, not who owns its lines, which only its keys decide, nor who wrote its documents, which <verbatim|creators> in <verbatim|datacite.json> say (#41). The keeper's other roles, in takedowns and for privacy, are in sections 13 and 15.

  <strong|Open questions.>

  <\itemize>
    <item>The field names of <verbatim|keys.json> (#55).

    <item>Fork records and healing, provisional: the rule for versions that meet, spare keys, and what a reader holding only one side can know (#58; <verbatim|drafts/keys-and-forks.md> on <verbatim|main>).

    <item>Whether nullifying keys from when an archive learns of it, rather than dating signatures (revocation dated by trusted time, transparency logs), is enough against backdating (#55, #58).

    <item>The form of a keeper's confirmation on ORCID, which depends on an <verbatim|https> form of <verbatim|sheaf:\<less\>owner\<gtr\>>, and so on the gateway (section 12; #13, #35).
  </itemize>

  <section*|7. Lines and signatures><label|7-lines-and-signatures>

  A <dfn|line> is the history of a work as decided by one owner, identified by the pair (name, owner) and so by the identifier <verbatim|sheaf:\<less\>name\<gtr\>:\<less\>owner\<gtr\>> (section 4). Its object versions form a single sequence, signed by its owner. <strong|A line is its signed versions, wherever they are stored>: in an archive where its owner writes, or in a mirror (section 11). Lines of other owners with the same genesis record are branches (section 9). An owner's key log is the line of its owner object (section 6).

  <subsection*|7.1 Signing><label|71-signing>

  Every sealed object version of a line MUST be signed by its owner when it is made: by at least <verbatim|threshold> distinct keys of one version of the owner's key log, <verbatim|threshold> being that version's, each key signing in its own signature file (section 7.2), which names that key-log version. The key-log version named SHOULD be the latest its signer knows. A signature is judged against the key-log version it names alone (section 6.1), and nothing is ever signed again. An owner MAY add signatures to a version later, with keys that have not signed it. Versions of a key log are signed in the same way, by the keys of the version before, or for the first version by its own (section 6.1).

  <subsection*|7.2 Witnesses and signature files><label|72-witnesses-and-signature-files>

  A <dfn|witness> is evidence about an object version made after it: a signature, a timestamp, an external deposit (appendix A), a software archive snapshot. The witnesses kept with an object are in its <dfn|witness folder>, the OCFL object extension folder <verbatim|extensions/opensheaf-witnesses/> (not yet registered with OCFL, so validators may warn), which is part of no version, is not covered by the inventory digests, and travels with the object. Witnesses MAY be added at any time, by the owner of the line or by others; they are kept, never re-serialised or replaced once made, since some (timestamps) are made of their bytes, and MUST NOT be removed except by a takedown (section 13) or the replacements at a fork of a key log (section 6.3).

  <strong|Signature files.> A <dfn|signature file> holds one signature of an object version by the owner of its line. The signature of version <verbatim|\<less\>version\<gtr\>> by a key is the JSON file <verbatim|\<less\>version\<gtr\>/signature-\<less\>k\<gtr\>.json> in the witness folder, where <verbatim|\<less\>k\<gtr\>> is the first 16 characters of the lowercase base32 (RFC 4648, without padding) SHA-256 digest of the key's <verbatim|did:key> URI, as UTF-8, so that a reader that knows the keys builds every name without listing the folder. It has:

  <\itemize>
    <item><verbatim|format>: <verbatim|"opensheaf-signature/0.1">;

    <item><verbatim|object>: the identifier of the object, <verbatim|sheaf:\<less\>name\<gtr\>:\<less\>owner\<gtr\>>;

    <item><verbatim|version>: the object version signed, <verbatim|\<less\>version\<gtr\>>;

    <item><verbatim|inventorySha512>: the SHA-512 digest of that version's inventory file, as its checksum file states it;

    <item><verbatim|signer>: the owner name of the signer, which MUST be the owner part of <verbatim|object>;

    <item><verbatim|key>: the <verbatim|did:key> URI of the key that signs, one of the <verbatim|keys> of the key-log version named;

    <item><verbatim|keyLog>: that key-log version, as a pin of the owner object written as a <verbatim|sheaf:> URI, <verbatim|sheaf:\<less\>owner\<gtr\>/v\<less\>n\<gtr\>?sha512=\<less\>digest\<gtr\>> (section 12), whose owner MUST be <verbatim|signer>; for a signature of a key-log version vN+1 it names vN, and for the first version the first version itself;

    <item><verbatim|signature>: the Ed25519 signature (RFC 8032) of the signed message, 64 bytes in base64 (RFC 4648, with padding).
  </itemize>

  <strong|The signed message.> What is signed is not a file but the message made of these five lines, each ended by a line feed (LF, <verbatim|0x0A>), in UTF-8, with no other characters, spaces or blank lines:

  <\verbatim-code>
    opensheaf-signature/0.1

    object \<less\>the value of object\<gtr\>

    version \<less\>the value of version\<gtr\>

    inventory \<less\>the value of inventorySha512\<gtr\>

    keylog \<less\>the value of keyLog\<gtr\>
  </verbatim-code>

  The first line keeps these signatures apart from any other use of the key; the others bind the signature to one object version, its inventory and one key-log version. A verifier rebuilds the message from the fields of the signature file and verifies the signature.

  <strong|Others' witnesses.> A signature by someone other than the owner of the line, attesting a version, is a witness, not a signature of the line, and never a signature file: it is <verbatim|\<less\>version\<gtr\>/witness-\<less\>label\<gtr\>.json>, where <verbatim|\<less\>label\<gtr\>> is chosen by whoever adds it and matches <verbatim|^[a-z0-9]+(-[a-z0-9]+)*$>. It has the fields and the signed message of a signature file, with <verbatim|signer> and <verbatim|keyLog> naming the signer's own owner object, which MUST NOT be the line's owner; its key log MAY be copied beside the object (section 6.5).

  <strong|Other witnesses.> The <hlink|timestamps extension|opensheaf-timestamps-0.1.tm> keeps timestamps of signature files beside them, dates that readers may weigh; it changes no status. The parent signatures a branch carries are in its content (section 9).

  <strong|Files that are not witnesses.> A file of the witness folder that is not a witness (a stray file, a malformed or invalid signature file) is ignored, reported, never fatal, and kept; a file a reader does not recognise, stray or of an extension it does not know, is reported as an unknown file, not as an error: a host cannot break a version by adding a file. A copy MAY leave such files out (section 11).

  <subsection*|7.3 Statuses><label|73-statuses>

  A signature file is:

  <\itemize>
    <item><dfn|invalid> when it is malformed; its name does not match the digest of its key; its signature does not verify; its <verbatim|object>, <verbatim|version> and <verbatim|inventorySha512> are not those of the version whose folder holds it (the digest also as its checksum file states it; in <verbatim|parent.signatures/>, those of the parent version, section 9; in <verbatim|forked/\<less\>d\<gtr\>/>, those of the version carried, section 6.3); its <verbatim|signer> is not the line's owner; the reader reaches the key-log version named, with that digest (also as carried by a fork record or a healing version, section 6.3), and the key is not in its <verbatim|keys>; or the version named follows one with <verbatim|ended>, or is a fork record, or, for a signature of a line, has <verbatim|ended> itself (section 6.3);

    <item><dfn|unchecked> when it is not invalid but the reader cannot reach the key-log version it names, with that digest (the key log is absent, taken down, or shorter, or the reader holds another version of that number, which verifiers report as a sign of a fork of the key log, section 6.3); nothing is added on such signatures (section 7.5);

    <item>otherwise <dfn|good>, for ever: later versions of the key log, an end or a fork never change it.
  </itemize>

  A version of a key log is <dfn|signed> when at least <verbatim|threshold> distinct keys of the version before (for the first version, of itself), <verbatim|threshold> being that version's, sign it with good signature files. Key logs are read version by version from the first, and are never vouched for (below): each version is checked with the keys of the one before; a version after one with <verbatim|ended> is not a version of the key log; a fork record is a version when it is valid, though not signed, and a healing version is signed only when it is valid (section 6.3).

  A version of a line is:

  <\itemize>
    <item><dfn|signed> when it is <dfn|signed directly>, by at least <verbatim|threshold> distinct keys of one key-log version, <verbatim|threshold> being that version's, with good signature files naming that version; or <dfn|vouched for>, when a later version of the same line signed directly extends it;

    <item><dfn|unchecked> when it is not signed, but would be if its unchecked signatures were good;

    <item>otherwise <dfn|not a version> of the line, wherever it is found, and never shown as one: reported as invalid if at least one signature file of the owner is invalid, and otherwise as <dfn|unsigned>.
  </itemize>

  <strong|A signed version vouches for its past.> The inventory of a version records the digests of every file of every version before it (section 4), so a version signed directly vouches for every version it extends, whatever their own signatures; a version vouched for needs no signatures of its own.

  <strong|Readers use the latest signed version.> The <dfn|latest signed version> of a copy of a line gives the line's history, current version and status (section 4.2). Nothing relies on a version that is not signed: not a pin, a resolution, a collection member or a branch point. An unchecked version is shown with its status until the key log is found.

  <strong|Owner tools MUST show the owner> a version that a new version would extend and that is not signed, before signing, so that an owner never takes a thief's version into its line unknowingly; for versions of its key log, see section 6.3.

  <subsection*|7.4 One writer per line, and forks><label|74-one-writer-per-line-and-forks>

  An owner MUST NOT sign two different object versions with the same number for the same line. Since every version directory keeps the inventory as of that version (section 4.1), two copies of a line whose heads are <verbatim|vk> and <verbatim|vm>, with k not greater than m, <dfn|agree> when <verbatim|vk/inventory.json> is the same file, byte for byte, in both. A copy that stops earlier is older: readers use the latest signed version among the copies that agree. Two copies that do not agree are a <dfn|fork of the line>, reported with the status of each side, and never recorded (an archive keeps the side it holds, section 5.3); a fork whose sides are both signed was made with keys of the owner, and is attributable to whoever holds them.

  <subsection*|7.5 Adding versions><label|75-adding-versions>

  An archive adds a version to a line only if, once added, it is signed against the key log the archive holds: signed directly by its owner, or vouched for by a version signed directly that is added with it from the same copy. Tools SHOULD fetch the latest version of the key log they can find before adding. An archive adds no invalid signature file. An archive that continues another owner's line makes a branch, under its own owner (section 9).

  <strong|Ended and tainted owners.> For an owner that has ended or is tainted, as far as the archive knows (section 6.3), the archive takes its lines only from copies found elsewhere, never as new deposits: it MAY copy a line, or extend one it holds, up to the latest signed version of a copy that agrees with it, since holding earlier versions is no reason to trust later ones less or more; when the copies found fork, it takes only the versions they share, and reports the fork. Readers weigh these versions as they weigh that owner's history (section 6.4). The key log itself is added as section 6.4 says, and no version needing a nullified key is added (section 6.4).

  <strong|Versions held stay.> Nothing that a host or a thief can produce leads to removing a version an archive holds; only a takedown does (section 13), and, for a key log, a fork (section 6.3). A version let in against this section that is not signed is reported, and never shown as a version of the line. Since OCFL versions cannot be skipped, the owner's own version of that number can then never be added there: that archive's copy is one side of a fork of the line, and the owner continues the line in another archive.

  <subsection*|7.6 Integrity><label|76-integrity>

  Integrity rests on OCFL digests: every file is fixed by its SHA-512 digest in the inventory, every inventory by its checksum file, and every member of a collection by a pin (sections 4 and 8). Digests show that files were not changed, signatures which owner's keys signed them; neither shows who wrote them or when (sections 7.2 and 15.1).

  <strong|Open questions.>

  <\itemize>
    <item>The field names and the format of signature files (#55).

    <item>Fork records, healing and nullified keys, provisional (section 6.3; #58).
  </itemize>

  <section*|8. Collections><label|8-collections>

  A <dfn|collection> is an object of kind <verbatim|collection> (section 4) whose versions hold a list of members, <verbatim|members.json>. Each <dfn|member> is a line (section 7) of a document or of another collection, in any archive, pinned (section 4). A collection is a line like any other, signed by its owner (section 7), its <dfn|curator>; what it contains changes only by a new version.

  <subsection*|8.1 Catalogues and selections><label|81-catalogues-and-selections>

  Collections are of two types, which treat the versions of their members differently; <verbatim|type> in <verbatim|members.json> states which.

  <\itemize>
    <item>A <dfn|catalogue> keeps objects whole and is impartial about their versions. Each member pins an object with all its versions up to the pin, and the catalogue may follow it as it grows (section 8.3): the owner of each member decides what its versions are.

    <item>A <dfn|selection> vets particular versions: a journal the version it accepted, a digest or a review journal the version it reviewed, a reading list the version it recommends. Each member pins a revision set (section 8.4); earlier and later versions of the same member are not part of the selection unless its curator adds them, by a new version of the selection.
  </itemize>

  Both types may have collections as members (an archive of archives, a selection of issues).

  <strong|An archive's collections.> An archive that makes collections does so as an owner, with a key log like any other (section 6). Its <dfn|main catalogue>, named by <verbatim|mainCollection> in its discovery document (section 3.1), is a catalogue of the documents of the lines its owners write in the archive, not of the copies it holds. It MAY also keep a catalogue of the lines it holds as copies (section 11). A selection is kept by the owner of the body that vets (a journal, a review journal), which also owns the accepted copies the selection keeps (section 9).

  <subsection*|8.2 The member list: members.json><label|82-the-member-list-membersjson>

  Every collection version MUST contain, besides the files of section 4.1, <verbatim|members.json>, and no other files of its own, with:

  <\itemize>
    <item><verbatim|format>: <verbatim|"opensheaf-collection/0.1">;

    <item><verbatim|type>: <verbatim|catalogue> or <verbatim|selection>;

    <item><verbatim|members>: the list of members, in the order in which they are presented. This order is authoritative: presentations MUST present members in it.
  </itemize>

  It MAY contain <verbatim|order>, the rule by which tools maintaining the collection place members: <verbatim|manual>, the default (tools append new members and never reorder); <verbatim|issued-desc> or <verbatim|issued-asc>, by the members' <verbatim|Issued> date (section 4.4), then their <verbatim|Available> date, members with neither last, ties broken by <verbatim|name> and then <verbatim|owner>, so that the result is reproducible.

  Each member MUST have:

  <\itemize>
    <item><verbatim|kind>: <verbatim|document> or <verbatim|collection>;

    <item><verbatim|name> and <verbatim|owner>: its line (sections 5 and 6), by which copies are found (section 12) and checked against its owner's signatures; never a label (section 3.1) or a location;

    <item><verbatim|at>: a non-empty list of base URLs where copies of the line may be found, also of one URL: equal hints, which need no signature (section 3), read as the <verbatim|at> parameter of a <verbatim|sheaf:> URI (section 12). They locate copies of the member's own line, mirrors included (section 11), never a branch of it (section 9).
  </itemize>

  Each member MAY have <verbatim|doi>, the version DOI, and <verbatim|conceptDoi>, the concept DOI, of the member; and <verbatim|cite>, a cached citation, not authoritative, so that the collection can be read and ordered without resolving its members, also when they become unavailable: <verbatim|title>, <verbatim|creators> (a list of names), <verbatim|year>, and <verbatim|issued>, the member's <verbatim|Issued> date.

  <subsection*|8.3 Members of a catalogue><label|83-members-of-a-catalogue>

  Each member of a catalogue MUST have <verbatim|version>, the object version pinned, and <verbatim|inventorySha512>, the SHA-512 digest of its inventory file: a pin (section 4), which fixes the object with all its versions up to that one. It MUST NOT have <verbatim|revisions>.

  A member MAY have <verbatim|follow>, <verbatim|"latest">: a setting of the curator, not a floating reference. A followed member pins the latest signed version of its line (section 7.3) when the collection version was made; a member without <verbatim|follow> keeps the version its curator pinned, which MAY be earlier, until the curator changes it. A tool maintaining the catalogue reads the member's archive (its discovery document or feed) and, when a followed line has a new signed version, writes a new collection version pinning it, whatever that version holds (a new document version, a description, a notice, a withdrawal): a catalogue does not judge the versions of its members. A tool follows only a signed version that extends the version pinned; a copy that does not is a fork of the line (section 7.4), which it reports, keeping the pin.

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
    <item><strong|verified>, when a copy of the version pinned is found, matches the pin, and is signed (section 7.3);

    <item><strong|mismatch>, when a copy is found and does not match the pin;

    <item><strong|unchecked>, when the version pinned is unchecked (section 7.3), shown with its status until the key log is found;

    <item><strong|not a version> (section 7.3): the collection pinned what it MUST NOT;

    <item><strong|unavailable>, when no copy is found;

    <item><strong|removed>, when no copy is found and an archive holds a tombstone of the line (section 13.3).
  </itemize>

  <subsection*|8.6 Description and rights><label|86-description-and-rights>

  <strong|Description.> A collection version's <verbatim|datacite.json> (section 4.4) has <verbatim|resourceTypeGeneral> <verbatim|Collection>, and MUST have in <verbatim|relatedIdentifiers> a <verbatim|HasPart> relation to the version DOI of each member of a catalogue (its <verbatim|doi>) and of each revision of a selection (the revision's <verbatim|doi>) that has one; members without a DOI are listed only in <verbatim|members.json>. Members never name the collections that include them (section 4.4).

  <strong|Document versions.> A collection makes a new document version exactly when its member list changes (section 4.2); <verbatim|object.json> of a collection has none of the fields of a document (section 4.3).

  <strong|Rights.> A collection version holds only metadata, placed under CC0 (section 15.6), and its <verbatim|rightsList> SHOULD say so. The licence of a collection never extends to its members.

  <strong|Open questions.>

  <\itemize>
    <item>Whether <verbatim|follow> applies to every object version of a catalogue or only to its document versions, so that a catalogue with followed members can still have description-only versions, notices and a withdrawal (#45).

    <item>What counts as a change of the member list: every change of <verbatim|members.json> (<verbatim|cite> and a reorder included), or of the members and pins only (#27).

    <item>Ordering by <verbatim|Available> without resolving members, which <verbatim|cite> does not cache (#27).

    <item>Which status a member has when the checksum file of its inventory is missing or wrong (#48).

    <item>What a collection may state about its members (volume, acceptance, the journal's own DOI, a retraction by the journal) (#40).
  </itemize>

  <section*|9. Branches and accepted copies><label|9-branches-and-accepted-copies>

  A <dfn|branch> is a line of another owner that continues a work from a signed version of another line, its <dfn|branch point> or <dfn|parent version>: a co-author carrying the work on, the successor of an ended owner (section 6.4), a journal keeping the version it vetted. It has the work's genesis record, and so its name, or after a clash another name of the same record (section 5.3). It is a new object, with its own identifier <verbatim|sheaf:\<less\>name\<gtr\>:\<less\>owner\<gtr\>> (section 4), holding the branch point and its own versions, never the parent's other versions. An originator never owns a branch of its own work (section 5.3).

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

  The first object version of a branch holds exactly the files of the parent version, the genesis record included, except its <verbatim|datacite.json>, its <verbatim|object.json> and its own evidence; the branch's own <verbatim|datacite.json> and <verbatim|object.json>; and the <dfn|evidence> of the branch point, as files of its content:

  <\itemize>
    <item><verbatim|parent.inventory.json>: the inventory of the parent version;

    <item><verbatim|parent.object.json>: its <verbatim|object.json>;

    <item><verbatim|parent.signatures/>: the parent owner's signature files of the parent version, named as in its witness folder without the <verbatim|\<less\>version\<gtr\>/> folder (<verbatim|parent.signatures/signature-\<less\>k\<gtr\>.json>, section 7.2), with the witnesses kept beside them, if any (timestamps); other witnesses of the parent version (a third party's signature) MAY be kept with them;

    <item><verbatim|parent.chain/>, when the parent is itself a branch: the parent version's own evidence, so that the grandparent's is at <verbatim|parent.chain/parent.inventory.json>, the great-grandparent's at <verbatim|parent.chain/parent.chain/parent.inventory.json>, and so on back to a version of the originator's line.
  </itemize>

  Every file copied is copied byte for byte, and never re-serialised or replaced. A branch MUST hold <verbatim|parent.signatures/> at every branch point, and <verbatim|parent.chain/> when its parent is a branch. The evidence is covered by the branch's own inventories and signatures; with the genesis record it forms the branch's identity files (section 4.1). The key logs that the evidence needs are kept beside every copy of the branch, never in it (section 6.5).

  <subsection*|9.3 Checking a branch><label|93-checking-a-branch>

  The evidence shows, without access to the parent's line, that a branch point is the parent owner's. A branch point is consistent when:

  <\itemize>
    <item><strong|the name:> the branch's <verbatim|name> and <verbatim|parent.name> are names of <verbatim|genesis.json> (section 5.2), and the branch's <verbatim|name> is <verbatim|parent.name> unless it was renamed after a clash, by a greater algorithm number (section 5.3);

    <item><strong|the pin:> the SHA-512 digest of <verbatim|parent.inventory.json> is <verbatim|parent.inventorySha512>, and its <verbatim|head> is <verbatim|parent.objectVersion>;

    <item><strong|the files:> every file of the head state of <verbatim|parent.inventory.json>, <verbatim|genesis.json> included, except <verbatim|datacite.json>, <verbatim|object.json> and the parent's evidence, is present at the same logical path with the same digest; no other file is present besides the branch's <verbatim|datacite.json>, <verbatim|object.json> and evidence; and <verbatim|parent.object.json> has the digest of <verbatim|object.json> in that state;

    <item><strong|the parent:> <verbatim|parent.owner>, <verbatim|parent.name> and <verbatim|parent.documentVersion> are those of <verbatim|parent.object.json>; the branch's owner is neither the parent's owner nor the originator; and either the parent's owner is the originator and <verbatim|parent.object.json> has no <verbatim|parent>, or it has one;

    <item><strong|the signatures:> the parent version is signed (section 7.3), by the signature files of <verbatim|parent.signatures/> against the parent owner's key log kept beside the branch, or vouched for by a signed version of the parent's line that the verifier finds; or it is unchecked;

    <item><strong|the chain:> when <verbatim|parent.object.json> has a <verbatim|parent>, <verbatim|parent.chain/> holds that evidence, each file with the digest <verbatim|parent.inventory.json> records for it, and it passes these checks in turn, level by level, up to the originator's line.
  </itemize>

  A chain is finite, since each level is fixed by a digest in the level below. Verifiers MAY bound the depth they follow, and report where they stop; a branch point checked only down to that bound is unchecked.

  <strong|Verdicts.> A branch point is, in this order:

  <\itemize>
    <item><dfn|inconsistent> when a check fails, a parent version is not a version (section 7.3), or the parent version, resolved, does not match the pin;

    <item><dfn|confirmed> when the parent version, at every level, is signed;

    <item>otherwise <dfn|unchecked>: consistent, but a parent version is unchecked.
  </itemize>

  The verdict of a branch is the weakest of those of its branch points. Verifiers report apart whether the parent's line is found, unavailable or removed (section 13), and whether it is withdrawn.

  <strong|Ended owners.> A branch point stays confirmed when its parent's owner ends, is tainted or heals afterwards, since signatures stay good; readers weigh it as they weigh that owner's history (section 6.4). A signature naming an ending version is invalid (section 7.3), and cannot sign a parent version.

  <subsection*|9.4 Later versions and moving the branch point><label|94-later-versions-and-moving-the-branch-point>

  The later versions of a branch are its owner's, signed like those of any line (section 7). They MUST keep the identity files unchanged, byte for byte, until a version that moves the branch point.

  <strong|Moving the branch point.> A branch MAY take as a new branch point a later version of the same parent line (a journal vetting the authors' corrected version): with the same <verbatim|owner> and <verbatim|name>, a higher object version, and a document version later than the previous branch point's in the history of the new parent version (section 4.2). A parent version holding the same document version (a DOI added) is not a new branch point; a branch point never moves back and is never dropped. The version whose <verbatim|parent> differs from the one before holds exactly the files of the new parent version with new evidence, and is checked as a first version is (section 9.3), and also for continuity: the two parent inventories have the same <verbatim|id>, every entry of <verbatim|versions> of the previous one is equal, as a JSON value, to the entry of the same version in the new one, and every digest in those entries is in the manifest of the new one. The branch's own notes and notices then lose their files (#57).

  <strong|Numbering.> The first version of a branch holds the document version of its branch point. Provisionally, later versions continue from it without gaps (section 4.2), a version that moves the branch point taking the next number, while <verbatim|parent.documentVersion> keeps the parent's (#57).

  <strong|Naming.> A branch is named as section 5.3 says. When the line it would take is its owner's branch of the same parent line, and the new branch point is later in that line's history than that branch's current one, the owner moves that branch's branch point instead; otherwise the new branch is renamed.

  <subsection*|9.5 Continuing another owner's work><label|95-continuing-another-owners-work>

  A line is not handed over. When another owner continues the work (an author leaving an institution whose line it was, a journal handing a report to its referee), the new owner makes a branch, and the previous owner MAY add a notice to its line pointing to it. An owner moving its lines to another archive hands nothing over: they stay its lines (section 6.5).

  A branch holds none of the parent's earlier versions. An owner who wants them at hand keeps beside the branch a copy of the parent's line (section 11), at the parent's identifier, with its signatures and key log.

  <subsection*|9.6 Accepted copies><label|96-accepted-copies>

  An <dfn|accepted copy> is a branch kept by the owner of a selection (section 8.4) from a revision it vetted. Selections that keep copies of the same document MUST have different owners, also in one archive, so that their accepted copies are different lines, never renamed against each other. The later versions of an accepted copy are acts of the selection's curator (a corrected version accepted, by moving the branch point; a notice; a withdrawal); the authors' later versions change nothing in it.

  The selection lists the accepted copy as a member; it MAY also list the original revision set. An accepted copy is not a mirror: a location holding only it is never given in <verbatim|at> for the parent's line (section 8.2).

  A version the selection makes itself, such as a typeset version of record, is a later version of its accepted copy, with the selection as <verbatim|publisher>, the authors' <verbatim|agreement> (section 4.3), and relations to the authors' versions (section 4.4). A branch carries versions of the same work; a derived work (a translation, a review, a collected edition) is a new object, with its own genesis record and a relation to its source.

  <subsection*|9.7 Description and rights><label|97-description-and-rights>

  <strong|Description.> A branch's <verbatim|datacite.json> has as <verbatim|publisher> its owner, or for a selection the body behind it, and keeps the relations of the parent version. Its first version, and every version that moves its branch point, SHOULD link the parent version with <verbatim|IsIdenticalTo>: its DOI if it has one, otherwise <verbatim|parent.url> as a <verbatim|URL>.

  <strong|Rights.> A branch needs only the right to redistribute its parent versions, and the files it copies keep their licence; a copy of the parent's line beside it needs the right to redistribute every version copied (section 11). The evidence is metadata, under CC0 (section 15.6).

  <strong|Open questions.>

  <\itemize>
    <item>The numbering of document versions on a branch: continued from the branch point (provisional), or numbered from it (3.1, 3.2), which makes <verbatim|documentVersion> more than an integer; <verbatim|/v\<less\>n\<gtr\>> of a <verbatim|sheaf:> URI follows it (#57).

    <item>Moving a branch point when the branch has files of its own (of its notes, a withdrawal, a version of record): probably a merge keeping both, with evidence that tells them apart (#57).

    <item>The field and folder names of the evidence (#55).
  </itemize>

  <section*|10. Drafts and sealing><label|10-drafts-and-sealing>

  A <dfn|draft> is a sandbox for a work not yet sealed, on which nothing may rely. <dfn|Sealing> makes from a work, under a new genesis record (section 5), the first version of its originator's line (section 7); the work's other lines are branches (section 9).

  <subsection*|10.1 Drafts><label|101-drafts>

  <strong|Identifier.> A draft belongs to the reserved owner <verbatim|draft>, never a name or an owner name (52 characters, section 5.2). Its identifier is <verbatim|sheaf:draft:\<less\>id\<gtr\>>, where <verbatim|\<less\>id\<gtr\>> is chosen by the archive, MUST match <verbatim|^[a-z0-9]+(-[a-z0-9]+)*$>, and MUST have at most 64 characters (76 for the identifier). It MUST NOT be reused in the archive while the draft exists, and MAY be once the draft is gone. It is local, never resolved. A draft is at the path its identifier gives (<verbatim|draft/\<less\>id\<gtr\>/> in the owner-name layout, section 3.2).

  <strong|Format.> A draft is a <verbatim|document> or a <verbatim|collection>, in the format of any object of its kind (section 4). It has no genesis record and no other identity files (section 4.1), and its <verbatim|object.json> has no <verbatim|name>, <verbatim|owner> or <verbatim|parent> (section 4.3). Its document versions are numbered by whoever keeps it, by the rules of section 4.2.

  <strong|A draft is its archive's alone.> A draft is never signed (section 7), pinned (sections 8, 9 and 12), copied out of its archive (section 11), indexed or named by a <verbatim|sheaf:> URI (section 12). The archive keeps its drafts when it moves to another site (section 3). The discovery document does not list drafts in <verbatim|objects>; it MAY list them apart, in <verbatim|drafts>, as unfinished work on which nothing may rely, or not at all (section 3.1).

  <strong|A draft may change.> A draft is the only object that MAY be rewritten or deleted: the rule that object versions never change (section 4) does not apply to it, and a draft deleted leaves no tombstone (section 13).

  <strong|Content.> A tool MAY read any object and recreate its files in a draft, as far as their licences allow.

  <subsection*|10.2 Sealing><label|102-sealing>

  <strong|When.> A work is sealed before a version of it first leaves its owner's hands: shared privately (submitted to a journal, sent to a co-author) or published. Sealing is done at the owner's request; tools SHOULD seal only at the owner's request, never as a side effect of another operation.

  <strong|What.> An owner tool seals a work by writing its genesis record (section 5.1), with the owner as <verbatim|originator>, and making a new object: the line <verbatim|sheaf:\<less\>name\<gtr\>:\<less\>owner\<gtr\>>, at its path in the storage layout (section 3.2), whose first version holds the genesis record and the work as document version 1 (section 4.2), and is signed by the owner (section 7.1). If the line is taken, the tool draws a new nonce (section 5.3).

  <strong|Drafts stay outside the line.> A work may be sealed from a draft or from files outside any archive. The versions of a draft are never part of the line sealed from it, and nothing in the line refers to them.

  <strong|Open question.> Whether and how drafts are shared before sealing (among co-authors, with a journal under review), and how an archive serves them, which bears on when a work must be sealed (#29).

  <section*|11. Copies and mirrors><label|11-copies-and-mirrors>

  A <dfn|copy> of a line is its object as held in one storage root; a <dfn|mirror> is a copy kept in an archive where the owner of the line does not write, which is the archive's policy (section 3). Nothing marks a mirror: it is listed in <verbatim|objects> like any line (section 3.1), and the rules of every copy apply to it. Whoever keeps mirrors of other owners' lines, or indexes of them (section 12), is a <dfn|custodian>.

  <subsection*|11.1 Mirrors><label|111-mirrors>

  <strong|What a mirror holds.> An archive MAY keep a mirror of a line written elsewhere: the object's versions up to the latest signed version of the copy it copies (section 7.3), with their inventories, files and witnesses, byte for byte, at the path its layout gives the line's identifier (section 3.2), and beside it the key logs its signatures need (section 6.5). Files of the witness folder that are not witnesses need not be copied (section 7.2): not copying them is not removing them. When a copy holds, under the same name, a witness file other than the mirror's, the mirror keeps its own and reports the other.

  <strong|How a mirror grows.> A mirror is the same line, signed by its owner, never a new one. It MUST NOT be changed except by adding the owner's signed versions as section 7.5 allows, from a copy that agrees with it (section 7.4); by adding witnesses (section 7.2); for a key log, by the replacements at a fork (section 6.3); or by a takedown (section 13). It keeps every version it holds (section 7.5). A copy that does not agree with it is a fork of the line: the archive keeps the side it holds, and reports the other (sections 5.3 and 7.4). The lines of an ended owner are added only in this way, from copies found elsewhere (section 7.5).

  <strong|Elsewhere.> A mirror may be listed in a catalogue of copies, never in the main catalogue (section 8.1), and located by the <verbatim|at> of collection members (section 8.2). A copy of a parent's line kept beside a branch is a mirror (section 9.5); an accepted copy is a branch, not a mirror (section 9.6). Drafts are never mirrored (section 10.1).

  <subsection*|11.2 Rights><label|112-rights>

  An archive MUST NOT keep a mirror unless the licences of every object version it copies (<verbatim|rightsList>, section 4.4, which a description-only version may change) allow redistribution. A copy keeps the licences of what it copies. A copy of a parent's line beside a branch follows this rule for every version it copies (section 9.7). Key logs, inventories, signature files and the other metadata are under CC0 (section 15.6), and are copied freely; a reference, a pin without a copy, needs no permission (section 8.5).

  <strong|Open questions.>

  <\itemize>
    <item>Whether a copy MAY stop before the latest signed version of the copy it copies, at a pinned version, so that a custodian keeps exactly what it pins or what the licences allow (#39).

    <item>Copying by the agreement of the rights holders, besides the licences, recorded minimally (#39), and which licences allow redistribution (#34).

    <item>What a custodian promises to keep (all the lines of an owner, the members of a collection, the revisions a selection vets), and where it says so (#54).

    <item>Whether a custodian follows a takedown of a line it mirrors (section 13).
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

  <strong|Syntax.> The parts are, in this order: <verbatim|sheaf:> and the name; OPTIONALLY the <dfn|owner part>, <verbatim|:> and an owner name, or instead <verbatim|:*>; OPTIONALLY <verbatim|/v> and a positive integer without leading zeros; OPTIONALLY <verbatim|?> and parameters <verbatim|key=value> joined by <verbatim|&>, with at most one <verbatim|sha512>, only after a version, whose value is an inventory digest as in a pin (section 4), 128 lowercase hexadecimal digits, and at most one <verbatim|at>, after <verbatim|sha512> if both are present. Only the value of <verbatim|at> is percent-encoded; no fragment is defined. The scheme, the name, the owner name, <verbatim|v>, the digest and the parameter names are lowercase, and a resolver MAY fold uppercase letters in them; the value of <verbatim|at> is case-sensitive. A resolver ignores parameters it does not know.

  <strong|The owner.> Without an owner part, a URI names the originator's line (section 5.3), read from the genesis record every copy carries; never the latest or most authoritative line, so a branch is always written with its owner part. An owner is the originator of its own genesis record, so <verbatim|sheaf:\<less\>owner\<gtr\>> names its key log.

  <strong|The work.> <verbatim|sheaf:\<less\>name\<gtr\>:*> names every line of the work (section 12.4). It takes <verbatim|at>, but a resolver rejects it with a version or <verbatim|sha512>, since every line has its own document versions.

  <strong|The version.> <verbatim|/v\<less\>n\<gtr\>> is a document version of the line (section 4.2, also on a branch), or for a key log an object version. It names only signed versions (section 7.3) whose <verbatim|object.json> has the URI's name and the line's owner: a branch names only its own versions, from its branch point, and drafts are never named (section 10.1). Without a digest, it names the object version holding n that the history of the line's latest signed version lists (section 4.2), or without <verbatim|history> the last signed one holding n; what it names may change as the line grows.

  <strong|The pin.> With a digest, the URI names exactly the object version whose inventory file has that digest. Citations of a fixed version SHOULD carry the digest.

  <strong|The hint.> <verbatim|at> gives the base URL of an archive where a copy is expected, which a resolver tries first: an <verbatim|https> URL ending with <verbatim|/>, every character outside the unreserved characters of RFC 3986 percent-encoded, decoded once (<verbatim|sheaf:\<less\>name\<gtr\>/v3?sha512=\<less\>digest\<gtr\>&at=https%3A%2F%2Fauthors.example.org%2F>). It is not part of what the URI names.

  <strong|Canonical form.> The canonical form has complete parts (section 12.2), lowercase where case is folded, no owner part when the owner is the originator, the genesis name (section 5.2) with <verbatim|:*>, and no <verbatim|at> or unknown parameters. Two URIs name the same thing when their canonical forms are equal byte for byte, which may need a copy of the genesis record to decide. Files record <verbatim|sheaf:> URIs in canonical form (<verbatim|keyLog>, section 7.2; relations, section 4.4), except identifiers (section 4), which always have the owner part.

  <subsection*|12.2 Short forms><label|122-short-forms>

  For people, the name and the owner name MAY be shortened to a prefix of at least 8 characters (<verbatim|sheaf:lvfmiq2z:iztwg6bj/v3>); a part of 52 characters is complete. A resolver expands a short form among the lines it knows that pass the checks of section 12.3. The candidates are the lines whose name and owner name start with the parts given (without an owner part, the originators' lines; with <verbatim|:*>, every name starting with the name part, whose work is then searched for, section 12.4). If they all have the same owner, the short form names the one whose first object version of that owner has the earliest <verbatim|created> in its inventory, compared as instants; otherwise (several owners or genesis records, or a tie), it is ambiguous, and the resolver MUST NOT choose but lists the candidates with their full forms and originators.

  Expansions may differ between resolvers and over time, so every file defined by this specification MUST use complete parts. A resolver SHOULD show the full form of what it resolved; landing pages and citation metadata SHOULD give the full form, and MAY add a short one. A short form printed where it cannot be corrected (a paper, a slide) SHOULD have at least 16 characters in each part.

  <subsection*|12.3 Resolution><label|123-resolution>

  <strong|Where to look.> A resolver tries, in any order, the locations it has: the URI's <verbatim|at> first, the <verbatim|at> of a collection member (section 8.2), a branch's <verbatim|parent.url> (section 9.1), the indexes it knows (section 12.5), its user's configuration. At an archive it reads the discovery document, finds the line in the indexes or in <verbatim|objects>, and fetches <verbatim|\<less\>storageRoot\<gtr\>\<less\>path\<gtr\>/\<less\>version\<gtr\>/inventory.json>, <verbatim|\<less\>path\<gtr\>> being given by the archive's layout (section 3.2). The parent version of a branch is fetched at <verbatim|parent.url> and otherwise found as any version of <verbatim|sheaf:\<less\>parent.name\<gtr\>:\<less\>parent.owner\<gtr\>>.

  <strong|Checks.> Every copy found is checked: the URI's name is a name of its <verbatim|genesis.json> (section 5.2); its <verbatim|object.json> has that <verbatim|name> and the line's owner (the owner part, or the originator); its versions are signed (section 7.3), against the key log kept beside it (section 6.5) or a longer copy found elsewhere. For a pin, the inventory file has the digest and the version holds document version n (for a key log, is object version n); a copy that does not match is reported as a mismatch (section 8.5). A copy that passes is a copy of the line, wherever found. Unchecked versions and versions that are not versions (section 7.3) are reported with their status and location, and never resolved to.

  <strong|Copies, forks and ended owners.> Since a copy that stops early looks complete, a resolver uses the latest signed version among the copies it found that agree (section 7.4), and says where it found them. A fork of the line (section 7.4) is reported with the status of each side; the resolver uses only signed versions and does not choose between signed sides. A resolver reports an owner that has ended, is tainted or has healed (section 6.3), with any successor, its own or named by its keeper (section 6.6), and never follows a successor by itself.

  <strong|Tombstones.> A tombstone (section 13) is not signed: a resolver that meets one keeps looking, and when it finds a copy that passes the checks, reports the copy and the tombstone.

  <strong|External records.> A deposit with an external service (<verbatim|external>, section 4.3; appendix A) or a software archive snapshot is a witness (section 7.2), not a copy: it holds no inventory, so it is never checked against a pin and resolves nothing; a resolver MAY report it as a place where the files may be found. A snapshot holding an archive's storage root (an archive kept in git) is read as that archive.

  <subsection*|12.4 Searching for a work><label|124-searching-for-a-work>

  Resolving one line needs no search (the originator's line is always named by algorithm 0). But the lines of a work may carry any of the 16 names of its genesis record (section 5.2). To find them all (for <verbatim|:*>, or a search by work), a resolver obtains the genesis record from any copy or index entry found under the name, checked against it; computes its 16 names and looks each up in the indexes it knows; keeps only the entries whose genesis record is byte for byte the one obtained, discarding others as collisions (removed entries without a genesis record are listed apart, as removed lines of those names, and removed entries that kept it are marked removed); and keeps only the lines that pass the checks of section 12.3 and hold back to the origin: the originator's line signed by its originator, and branches whose branch points are confirmed (section 9.3). A reused genesis record thus yields no line (section 5.4), and no hash is assumed free of collisions. If several genesis records have the URI's name, the URI is ambiguous: the resolver lists them with their originators.

  <subsection*|12.5 Indexes><label|125-indexes>

  An archive SHOULD keep three <dfn|indexes> of its objects, by name, by owner and by inventory digest, next to its discovery document, declared in its <verbatim|indexes> (section 3.1). A custodian (section 11) or a resolver MAY keep them for many archives at a base URL of its own, declared in <verbatim|indexes.json> there. Indexes are maps, not witnesses: what they lead to is checked (section 12.3).

  <strong|Files.> An index is a folder of files <verbatim|\<less\>p\<gtr\>.json>, where <verbatim|\<less\>p\<gtr\>> is a prefix of the key, each a JSON object with <verbatim|format>, <verbatim|"opensheaf-index/0.1">; <verbatim|index>, its folder; and <verbatim|entries>, every key starting with <verbatim|\<less\>p\<gtr\>>. A file without entries is omitted, so a missing file means no entry. The declaration (<verbatim|indexes> in the discovery document, or <verbatim|indexes.json>, with <verbatim|format> and <verbatim|indexes>) maps each index kept to the length of its <verbatim|\<less\>p\<gtr\>>, from 2 to 4 characters.

  <\itemize>
    <item><verbatim|names/>, by name: for each object with a genesis record, <verbatim|name>, <verbatim|owner>, <verbatim|id> (section 4), <verbatim|status>, <verbatim|originator> (for an owner object, itself), <verbatim|genesis> (the text of <verbatim|genesis.json>, whose UTF-8 encoding is exactly its bytes, so that works are searched for from indexes alone) and, if any, <verbatim|label> (section 3.1);

    <item><verbatim|owners/>, by owner name: for each owner with lines in the storage root, <verbatim|owner> and <verbatim|names>, the names of those lines, its key log among them when kept there (section 6.5);

    <item><verbatim|sha512/>, by inventory digest: for each sealed object version, <verbatim|inventorySha512>, <verbatim|id>, <verbatim|version> and <verbatim|status>.
  </itemize>

  <strong|Content.> An archive's indexes list every object with a genesis record and every sealed version of it, never drafts. <verbatim|status> is the object's, <verbatim|active> or <verbatim|withdrawn>, or <verbatim|removed> after a takedown (section 13): a tombstoned object keeps its entries in <verbatim|names/> and <verbatim|sha512/>, of which those in <verbatim|names/> MAY drop <verbatim|originator> and <verbatim|genesis>, while a takedown removes the name from <verbatim|owners/>, and the entry once it lists none. In indexes kept for several archives, every entry has <verbatim|at>, a list of base URLs of the archive serving the copy, equal hints (section 3), and <verbatim|owners/> has an entry for each owner and archive.

  <strong|Lookups.> A resolver looks a line up in <verbatim|names/>, starting from <verbatim|at>, keeping the entries whose <verbatim|owner> matches the owner part, or without one, whose <verbatim|owner> is their <verbatim|originator>; a removed entry without <verbatim|originator> is matched against the originator of any copy of the genesis record, or reported as a removed line of that name, originator unknown. It looks a pin up in <verbatim|sha512/> and an owner's lines in <verbatim|owners/>. At an archive without indexes, it MAY read <verbatim|objects> of the discovery document and fetch <verbatim|genesis.json> and <verbatim|object.json> from the objects.

  <subsection*|12.6 Gateways><label|126-gateways>

  A gateway serves a URI at its base URL followed by the URI unchanged (<verbatim|https://opensheaf.org/sheaf:\<less\>name\<gtr\>/v3>, provisionally, #35); gateway links are written in full, since a relative link starting with <verbatim|sheaf:> is read as a URI. A gateway:

  <\itemize>
    <item>MUST answer with a page (200) showing what it resolved, or a temporary redirect (302, 303 or 307) only to a copy it has checked (section 12.3); it MUST NOT redirect permanently (301, 308), and MAY cache its result only for a URI with a digest;

    <item>MUST show where what it resolved was found, that a URI without a digest resolves to the latest copy it found, not necessarily the owner's latest, and when the owner has ended, is tainted or has healed, with any successor;

    <item>MUST NOT serve an archive's files from its own origin, but redirects or links to the archive (section 15.3);

    <item>MUST fetch on its users' behalf only <verbatim|https> URLs at public addresses, with limits on size and time.
  </itemize>

  <strong|Open questions.>

  <\itemize>
    <item>Registering the scheme <verbatim|sheaf> with IANA, as a provisional scheme (RFC 7595), until which DataCite records <verbatim|sheaf:> URIs as <verbatim|URL> (section 4.4) (#36).

    <item>Whether the project runs a gateway, on which domain, and whether a domain used only for resolution drops <verbatim|sheaf:> from the path, as <verbatim|https://doi.org/> drops <verbatim|doi:> (#35).

    <item>Who keeps indexes of many archives, so that a line can be found once its archives have gone, and how resolvers find them (#13, #20).

    <item>Whether an external record can resolve a pin if it also holds the version's inventory file, its checksum file and its signature files (a Zenodo record version uploading them, a member's <verbatim|swhid>) (#22).

    <item>Whether a tombstone in one archive should stop resolution at copies elsewhere (section 13).

    <item>The numbering of document versions on a branch, which <verbatim|/v\<less\>n\<gtr\>> follows (section 9; #57).
  </itemize>

  <section*|13. Withdrawal, takedown and tombstones><label|13-withdrawal-takedown-and-tombstones>

  An owner withdraws a line, which keeps its versions; an archive takes down an object, which leaves a tombstone. A draft is neither withdrawn nor taken down: it is deleted, and leaves no tombstone (section 10.1).

  <subsection*|13.1 Withdrawal><label|131-withdrawal>

  A document or a collection is <dfn|withdrawn> by a description-only version (section 4.2) whose <verbatim|object.json> has <verbatim|status> <verbatim|withdrawn> and <verbatim|withdrawal> (section 4.3), and whose <verbatim|datacite.json> has <verbatim|withdrawal.date> as <verbatim|Withdrawn> (section 4.4). The status is the line's, read from its latest signed version (section 7.3), whatever document version that holds; a single document version is retracted by a notice (section 4.2). A branch or an accepted copy is withdrawn only by its own owner (section 9).

  A withdrawn line keeps every version, signed, pinned and copied as before. Presentations showing a version of a line they know to be withdrawn MUST show the withdrawal, also when the version shown is earlier.

  <subsection*|13.2 Takedown><label|132-takedown>

  A <dfn|takedown> deletes a sealed object, witness folder included, from an archive's storage root (with the folders the deletion leaves empty) and from its presentation files, and adds a tombstone (section 13.3). It is the only way an archive removes what it holds, besides the replacements of key-log versions at a fork (sections 6.3, 7.2 and 7.5), and every removal of a sealed object is one, whatever its reason: content that must not be served (by law, for a breach of rights, to erase personal data, section 15.5), or a line the archive stops keeping. It removes one object: others holding the same files, such as a branch holding its parent version (section 9), are taken down on their own.

  <strong|Owner objects.> A takedown of a line leaves in place the owner objects its copy carries (section 6.5). An owner object that an object of the archive needs is taken down only for itself: at its owner's request, signed by <verbatim|threshold> keys of the latest version of its key log that the archive holds, or by law; for an ended or tainted owner (section 6.3), only at its keeper's request (section 6.6) or by law. An archive SHOULD also hear the keeper, when one is named, before acting on a signed request, which a thief can make. The owner's signatures in what the archive keeps are then unchecked there (section 7.3), and the tombstone stands in for the owner object in the rule of section 6.5.

  <strong|Returning.> A line taken down (an owner object found elsewhere, for instance) MAY return to the archive only from a copy holding the version its tombstone pins or, when that version is not signed, the latest signed version before it, added as section 7.5 says: it is the same line, not a reuse of its identifier (section 4), and its tombstone is dropped.

  <subsection*|13.3 Tombstones><label|133-tombstones>

  A <dfn|tombstone> is an entry of <verbatim|tombstones> in the discovery document (section 3.1), one for each object taken down, with:

  <\itemize>
    <item><verbatim|id>, <verbatim|kind>, <verbatim|name> and <verbatim|owner>: those of the object (section 4.3);

    <item><verbatim|genesisName>: the genesis name of its genesis record (sections 5.2 and 5.4);

    <item><verbatim|lastVersion> and <verbatim|inventorySha512>: its head when taken down, and the SHA-512 digest of that version's inventory file, a pin (section 4);

    <item><verbatim|date>: the date of the takedown;

    <item><verbatim|reason>: a plain text, which SHOULD NOT repeat what was taken down.
  </itemize>

  A tombstone is never removed, except when its line returns: it keeps the line taken (section 5.3), and <verbatim|objects> never lists its <verbatim|id>. It is not signed: a resolver keeps looking past it (section 12.3). A line, or a version of it no later than <verbatim|lastVersion>, of which no copy is found but a tombstone is, is reported as removed (sections 8.5 and 9.3).

  <strong|Open questions.>

  <\itemize>
    <item>Whether a tombstone in one archive stops resolution at copies elsewhere, and whether mirrors, branches holding the version taken down, indexes kept by others and gateways follow a takedown (#33, #39).

    <item>The form of an owner's signed request for a takedown, and of a keeper's (#33).

    <item>Whether a tombstone lists the inventory digests of every version taken down, so that a pin of a removed version is told from a pin that never named one; meanwhile the archive's <verbatim|sha512/> index keeps them (section 12.5; #33).

    <item>Whether a withdrawn line takes new document versions; whether and how it is reinstated; whether <verbatim|withdrawal> stays in later versions; what a verifier reports for a pin of an earlier version of a withdrawn line; and how the line of an ended owner, which signs nothing, is withdrawn (#25).

    <item>A retraction by a collection (a journal) of one of its members, distinct from a withdrawal by the member's owner (#40).

    <item>Takedowns of single files or versions, should a later OCFL provide them (#32).
  </itemize>

  <section*|14. Verification><label|14-verification>

  A <dfn|verifier> is a program that checks an archive, or an object with the key logs kept beside it, against this specification. It checks every requirement of sections 3 to 13 that the files decide, in the order of sections 14.2 to 14.6, each step using the results of those before; the rules are those of the sections cited. The discovery document, the indexes and presentation files are maps: a verifier checks them against the storage root, and never takes them as authoritative (section 3.1).

  <subsection*|14.1 Findings><label|141-findings>

  A verifier reports every finding with its place (the archive, an object, a version, a file), and does not stop at the first. A finding is:

  <\itemize>
    <item>an <dfn|error>: a breach of a MUST or MUST NOT, except where this section makes it a warning. An archive or an object without errors <dfn|passes> verification;

    <item>a <dfn|warning>: a breach of a SHOULD; a breach that the archive cannot repair, where this section says so; a check not made or not completed;

    <item>a <dfn|result>, neither: the statuses of signature files, versions and members (sections 7.3 and 8.5), the verdicts of branches (section 9.3), forks of lines and of key logs (sections 6.3 and 7.4), ended owners and their successors (sections 6.3 and 6.6), withdrawals (section 13.1) and removals (section 13.3).
  </itemize>

  <strong|Checks not made.> A verifier reading an archive over HTTP cannot list folders: it checks the objects the discovery document lists, and warns that it has not checked that the storage root holds no others, nor the files of witness folders whose names it cannot compute; one with access to the files checks them. A verifier MAY bound the depth of the chains and collections it follows (section 9.3), SHOULD bound the size of what it fetches (section 15.2), and warns where it stops.

  <subsection*|14.2 Files and storage><label|142-files-and-storage>

  The verifier checks:

  <\itemize>
    <item>every JSON file this specification defines against its schema (section 2), formats (dates, URIs) included as assertions, which JSON Schema 2020-12 leaves optional: the discovery document, the files of every object version (<verbatim|parent.object.json> and the files of <verbatim|parent.chain/> included), the files of witness folders, the indexes, and a keeper's file when it reads one; a malformed file of a witness folder is a warning (section 7.2);

    <item>that the storage root and every object are valid OCFL 1.1, with an OCFL validator or equivalent checks, leaving out the warnings validators give on the owner-name layout and witness folders (sections 3.2 and 7.2);

    <item>that <verbatim|ocfl_layout.json> names <verbatim|storageLayout> with the parameters of section 3.2, and that every object is at the path its identifier gives there;

    <item>the rules of section 4.1 in every object version, and that the inventory of each version folder is the inventory as of that version: its <verbatim|head> is that version, and its <verbatim|versions> are those of the head inventory up to it, equal as JSON values.
  </itemize>

  <subsection*|14.3 Key logs><label|143-key-logs>

  The verifier checks the owner objects first, each from its first version (section 6): its genesis record and first <verbatim|keys.json> (sections 5.1 and 6.1); that each version is signed (section 7.3) and none follows an ending version or a fork record, a version held against either being a warning, as for lines (section 14.4); <verbatim|ended> and <verbatim|successor>; and each fork record and healing version (section 6.3): that it is valid, each version it carries under the name its inventory digest gives, with its <verbatim|keys.json> and checksum file against its inventory and its signatures against the version before, and that no version it supersedes is held beside it. It reports as results the latest version of each key log, the nullified keys, and ended, tainted and healed owners with their successors; when a keeper is named, it MAY check the link (section 6.6).

  <subsection*|14.4 Objects><label|144-objects>

  For every other object, the verifier checks:

  <\itemize>
    <item><strong|its records:> the rules of sections 4.2 to 4.4 in every version and between versions (numbering, new versions, completion, <verbatim|history>, notices), as far as the files decide them;

    <item><strong|its identity:> the genesis record, the name and the identifier in every version (sections 4 and 5), and that the objects and tombstones of the archive with the same genesis name are its originator's line and branches of it (section 5.4);

    <item><strong|its signatures:> the status of every signature file and version, and the latest signed version (section 7.3), against key logs kept beside it as section 6.5 asks. A key log missing, or shorter than the versions its signatures name, is an error, one taken down a warning (section 13.2); the signatures that need it are unchecked. A version that is not a version of its line is a warning (section 7.5);

    <item><strong|a branch:> the verdict of each branch point (section 9.3), at its first version and at every version that moves it, with the continuity of section 9.4, and that the identity files are unchanged between them. An inconsistent branch point is an error, an unchecked one a warning; the branch's verdict, and whether its parent's line is found, unavailable, removed or withdrawn, are results. A rename whose algorithm number is not greater than that of <verbatim|parent.name> is an error (section 9.3); one that neither the objects nor the tombstones of the archive justify, or not by the smallest number free there, is a warning (section 5.3);

    <item><strong|a draft:> the rules of section 10.1, and that nothing in the archive pins it.
  </itemize>

  <subsection*|14.5 Collections><label|145-collections>

  For each collection version, the verifier checks the rules of section 8 on <verbatim|members.json> and its members. It resolves every member of the head version (every revision, in a selection) as a resolver does (section 12.3), and the members held in the archive in every earlier version; resolving the other members of earlier versions is OPTIONAL. The status of each member is a result (section 8.5). A member that is not a version is an error, and so is a mismatch of a copy held in the archive; any other status but verified is a warning.

  <subsection*|14.6 The archive as a whole><label|146-the-archive-as-a-whole>

  The verifier then checks, against the objects:

  <\itemize>
    <item><strong|the discovery document> (section 3.1): that <verbatim|objects> lists every object of the storage root except drafts, each entry with the values its object gives (<verbatim|status> that of its latest version that is signed or unchecked, section 7.3), with distinct labels; that <verbatim|mainCollection> names a catalogue it lists; that <verbatim|drafts> lists only drafts of the storage root, with their heads; and, a breach being a warning, that <verbatim|owners> lists only owner objects it holds and <verbatim|extensions> every extension its objects use;

    <item><strong|the tombstones> (section 13.3): that each is well formed, with <verbatim|id> the line of its <verbatim|name> and <verbatim|owner>; that no two have the same <verbatim|id>; and that no object of the storage root, and no entry of <verbatim|objects>, has the <verbatim|id> of one;

    <item><strong|the indexes> it declares (section 12.5): that every object with a genesis record and every sealed version has its entry, in the file of its prefix, with the values its object gives; that each tombstone has its entries in <verbatim|names/> and <verbatim|sha512/>, with <verbatim|status> <verbatim|removed>, and none in <verbatim|owners/>; that no draft has one; and, with access to the files, that there are no other entries.
  </itemize>

  <strong|Beyond the archive.> A verifier SHOULD check the copies it knows elsewhere (the sources of mirrors, members, parents, longer key logs): whether they agree (section 7.4), reporting a fork of a line with the status of each side and where each copy was found, and a later version of a key log (section 6.5). It SHOULD check the requirements of the profiles the archive declares (appendix A), the witnesses it finds and the extensions it knows, and warns of those it does not know (sections 2 and 7.2).

  <strong|Open questions.>

  <\itemize>
    <item>Which status a member has when the checksum file of its inventory is missing or wrong (#48), and whether a mismatch at the member's archive falls through to mirrors (#37).

    <item>Whether a pin fixes the bytes of the inventories of earlier version folders, which are compared here as JSON values only (#46); whether digests in OCFL files must be in lower case (#49).

    <item>The parts of section 4.2 that the files do not decide: whether a version deposited out of order wrote <verbatim|history> (#51), and when a document version is new (#23).

    <item>How a verifier tells a licence from a rights statement in <verbatim|rightsList> (#50), and which licences allow a mirror (#34), which is therefore not checked.

    <item>What a verifier reports for a pin of an earlier version of a withdrawn line (#25).

    <item>Fork records and healing, provisional (section 6.3; #58).
  </itemize>

  <section*|15. Security, privacy and rights><label|15-security-privacy-and-rights>

  <subsection*|15.1 What the format protects><label|151-what-the-format-protects>

  Pins and signatures make every copy checkable wherever it is fetched (sections 4 and 7); discovery documents, indexes, locations and tombstones are maps and hints (sections 3, 12.3 and 13.3). A host or a network therefore cannot forge a version, nor add one to another owner's line (section 7.5), nor make a valid line from a reused genesis record (section 5.4), nor take over a short form (section 12.2). It can withhold: serve an older copy, or a key log that stops before an end or a fork record, which looks complete (sections 6.5 and 12.3); and it can delete what it serves, never a copy held elsewhere (section 13).

  Whoever holds <verbatim|threshold> keys of an owner acts as that owner until they are nullified or the owner ends (section 6.3), and the format cannot tell what was signed before an exposure from what was signed after (section 6.4).

  <strong|Forks of a line.> A fork of a line whose sides are both signed (section 7.4) ends nothing by itself; whether to end is the owner's call. If the owner did not make both sides, its keys may have been exposed, and section 6.3 applies; if it did (two tools, a version made again), it continues from one side, and archives holding the other keep it (section 7.5).

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

  An archive does not vouch for the files of its objects (section 3). Its presentation files MUST NOT include files of objects, or pages of other archives, as HTML or scripts; they link to them. An archive SHOULD serve its storage root so that its files run no scripts in the origin of its presentation files: from another origin, or with <verbatim|Content-Security-Policy: sandbox>. A gateway serves no archive's files (section 12.6).

  <subsection*|15.4 Keys and secrets><label|154-keys-and-secrets>

  Private keys, and other secrets (tokens of external services, the secrets of a review), MUST NOT be stored in an archive: in an object, a witness folder, a draft, presentation files, or the repository of an archive kept in git. Whatever an archive holds is public and copied.

  <subsection*|15.5 Privacy><label|155-privacy>

  What an archive serves is public, its drafts included (section 10.1); a sealed version, its witnesses and the key logs beside it travel with every copy and branch, and never change.

  <\itemize>
    <item><strong|Personal data.> Archives record only the personal data needed to describe and cite a work (section 4.4) and the depositor of each version (section 4.1), whose <verbatim|address> SHOULD be a public identifier (an ORCID iD) rather than a personal e-mail address.

    <item><strong|Owners.> An owner name is the digest of a record with a random nonce, and identifies no one. An owner is tied to a person only by what its versions say (<verbatim|creators>, <verbatim|user>, <verbatim|agreement>), by keys it shares with another owner, and by its keeper, who alone confirms that link and can withdraw the confirmation (section 6.6), though <verbatim|keeper> stays in the key log. An owner that must stay anonymous (a referee) SHOULD have its own keys and no <verbatim|keeper>, and its versions SHOULD NOT identify the person.

    <item><strong|Erasure.> Personal data is erased by a takedown (section 13.2), from that archive and its indexes only. The tombstone and index entries keep only names, owner names and digests, which identify no one (section 13.3); an archive kept in git also rewrites its history (<hlink|OpenSheaf archives in git|opensheaf-git-0.1.tm>, section 9).
  </itemize>

  <subsection*|15.6 Rights><label|156-rights>

  <strong|Metadata.> The JSON files this specification defines, inventories with their checksum files, fork records and the evidence of branches are metadata, texts of notes and abstracts included. Whoever writes them dedicates them to the public domain under CC0 1.0, so that they can be harvested and copied freely; an archive admits only owners that accept this. Files of notes (section 4.3) are content.

  <strong|Content.> The files of a document version are under the licence its owner states (sections 4.3 and 4.4); "All rights reserved" is allowed, since depositing grants readers access, not reuse. Copies and branches keep the licences of what they copy, and need the right to redistribute it (sections 9.7 and 11.2).

  <strong|Open questions.>

  <\itemize>
    <item>Which licences allow a mirror, and how a verifier tells a licence from a rights statement (#34, #50); copying by the agreement of the rights holders (#39).

    <item>Whether a takedown reaches mirrors, branches holding the files, indexes kept by others and gateways (#33).

    <item>Private archives and drafts, anonymous referees and the secrets of a review (#29).

    <item>Tying owners to ORCID iDs and domains beyond the keeper (#41).

    <item>What a reader holding only one side of a fork of a key log can know, and whether nullifying keys from when an archive learns of it is enough against backdating (#55, #58).
  </itemize>

  <section*|16. Versioning of this specification><label|16-versioning-of-this-specification>

  <subsection*|16.1 Versions><label|161-versions>

  This specification is versioned MAJOR.MINOR.PATCH:

  <\itemize>
    <item>a <strong|major> version (1.0, 2.0) MAY make incompatible changes;

    <item>a <strong|minor> version (1.1, 1.2) only adds: every file valid under 1.x stays valid under 1.y, for y greater than x, with the same meaning;

    <item>a <strong|patch> version (1.1.1) corrects or clarifies the text, and changes no requirement.
  </itemize>

  Before 1.0, every minor version MAY be incompatible. A draft MAY change in any way; archives made with a draft are rebuilt when its version is final. Drafts are told apart by the date in the heading and by the changelog (section 16.2).

  <strong|In files.> Files record the version as MAJOR.MINOR only, since a patch changes nothing that is valid: in the name of every format (<verbatim|"opensheaf-object/0.1">), and in <verbatim|specification> of the discovery document and of every <verbatim|object.json> (sections 3.1 and 4.3).

  <strong|Readers.> A reader that finds a major version it does not know, or before 1.0 a minor version it does not know, SHOULD report it, and MUST NOT treat the files as valid. From 1.0, a reader that finds a later minor version of a major version it knows reads the files as of that major version, ignores the properties it does not know, and SHOULD report the version; it does not validate such files against the schemas of its own version (section 2).

  <strong|Publication.> The text of each version is published at <verbatim|https://opensheaf.org/opensheaf-specification-\<less\>MAJOR.MINOR\<gtr\>.md>, with its schemas (appendix B), and is not changed once final, except by patch versions, listed in its changelog.

  <subsection*|16.2 Changelog><label|162-changelog>

  <\itemize>
    <item><strong|0.1 (draft), 13 November 2026:> first version.

    <item><strong|0.1 (draft), 13 to 18 November 2026:> revisions, and the proposal of PR #30 (names from genesis records, owners and key logs, lines, branches, <verbatim|sheaf:> URIs, signatures), each listed in the changelog of the <hlink|reference text|reference/opensheaf-specification-0.1-full.md>.

    <item><strong|0.1 (draft), 18 November 2026, rebuilt (PR #30):> the text rebuilt concept by concept into a shorter whole, from the reference text. Decided in the rebuild: archives are named by no file, and <verbatim|replicas> is dropped (section 3); external records are witnesses, not copies (section 12.3); index declarations name only <verbatim|names>, <verbatim|owners> and <verbatim|sha512> (section 12.5); every removal is a takedown, and tombstones are required once an object is taken down (section 13); drafts are never withdrawn; key-log forks are recorded by fork records, which nullify the keys involved, and healed by the owner, versions of key logs being replaced only there (section 6.3, provisional, #58); findings are errors, warnings or results (section 14.1); security, privacy and rights rewritten (section 15); <verbatim|licence> for documents only; logical paths exclude empty segments, a final <verbatim|/> and <verbatim|\\> (section 4.1).

    <item><strong|0.1 (draft), 19 November 2026, rebuilt (PR #30):> appendices A (profiles), B (JSON Schemas) and C (examples, checked against the schemas) rebuilt; DOIs written bare; signature files closed to other properties; fork records carry the witnesses of the versions they carry, under named files (section 6.3, provisional, #58); a threshold of 1 with a spare key survives the theft of the daily key by healing (section 6.2).
  </itemize>

  <section*|Appendix A. Profiles (normative for archives declaring them)><label|appendix-a-profiles-normative-for-archives-declaring-them>

  A <dfn|profile> is a set of rules for an external service or a tool, normative for an archive that lists it in <verbatim|profiles> (sections 2 and 3.1), and checked by verifiers (section 14.6). A profile only adds rules. They apply to the versions that owners make in the archive, never to copies of lines made elsewhere (section 11); only sealed, signed versions are deposited (sections 7.3 and 10.1).

  <subsection*|A.1 Zenodo (<verbatim|zenodo>)><label|a1-zenodo-zenodo>

  Zenodo registers DataCite DOIs (prefix <verbatim|10.5281>) and keeps files permanently. A record is a witness of the versions it holds, not a copy (section 12.3).

  <\itemize>
    <item><strong|Records.> Each line of a document is one record, whose concept DOI stands for the line. Each document version is one version of the record, with its own DOI, the document version as Zenodo's version, and the Zenodo type <verbatim|publication-preprint> or the one matching <verbatim|resourceTypeGeneral>. A branch is a record of its own, and deposits a version holding the files of its branch point only when the parent version has no DOI (section 9.7).

    <item><strong|Fixed files.> A description-only version (section 4.2) edits the metadata of the record version of the document version it holds; the files it adds, and the sources added by a completion (section 4.2), are not uploaded, since the files of a published record version are fixed. Archives MUST NOT use Zenodo's 30-day window for changing them: a correction is a new document version.

    <item><strong|Versions out of order.> Zenodo orders the versions of a record by publication, and its concept DOI leads to the latest. A document version deposited out of order (section 4.2) MAY be deposited only as a record of its own, with <verbatim|IsVersionOf> the concept DOI.

    <item><strong|Files.> The record version holds the content files of the object version. Records have no folders and a limited number of files: sources with sub-folders, or too many, are uploaded as one file <verbatim|sources.zip>, at their logical paths, its entries in the byte order of their names, dated 1980-01-01 00:00:00, without extra fields. The inventories of the line MUST record in <verbatim|fixity> the MD5 digest of every content file (section 4.1), to be compared with the checksums Zenodo reports.

    <item><strong|The deposit recorded.> The object version deposited has its DOI in <verbatim|datacite.json> and, in <verbatim|external> of <verbatim|object.json> (section 4.3), an entry with <verbatim|role> <verbatim|deposit>, <verbatim|service> <verbatim|Zenodo>, <verbatim|record> the URL of the record version, <verbatim|doi> and, for <verbatim|sources.zip>, <verbatim|files>.

    <item><strong|Order of operations.> (1) Create an unpublished version of the record (a new version inherits the files of the previous one, which are deleted). (2) Reserve its DOI. (3) Build the object version in a staging area, with that DOI, and have its owner sign it (section 7.1). (4) Upload the files, and compare their MD5 checksums with the fixity block. (5) Publish. (6) Add the object version with its signature files (section 7.5), and update the discovery document. If a step fails before publication, the unpublished version is discarded; if step 6 fails after it, the tool MUST complete step 6 from the staging area before any other deposit of the line. A tool SHOULD hold a lock per line during a deposit, since Zenodo allows one unpublished version per record. DOIs of Zenodo's sandbox are not registered, and MUST NOT be recorded in an archive.

    <item><strong|Metadata.> Zenodo's DataCite record of a DOI has Zenodo's landing page as <verbatim|url>, Zenodo as <verbatim|publisher> (which <verbatim|datacite.json> MAY also name, section 4.4), relations of its own, and only the properties Zenodo keeps. <verbatim|datacite.json> stays authoritative; verifiers compare the DOI, <verbatim|titles>, <verbatim|creators>, <verbatim|publicationYear> and <verbatim|version> of the two, a difference being a warning.

    <item><strong|Collections.> A collection MAY be deposited when its curator releases it, not at every change, as a record of type <verbatim|other> whose files include <verbatim|members.json>. A Zenodo community MAY group an archive's records for browsing; it is not authoritative.
  </itemize>

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
    <item><strong|Index.> An index page presents the latest signed version (section 7.3) of the main catalogue (section 8.1), in its order, possibly over several pages; other collections MAY have pages of their own. A flattened list, not authoritative, for programs that do not read OCFL MAY be published as <verbatim|catalog.json>.

    <item><strong|Landing pages.> Each line of the main catalogue has one landing page, for its current version (section 4.2), giving the full <verbatim|sheaf:> URI of the line (section 12.2) and every signed document version in the order of the history, each with its external labels, stage, change note, notices, renditions, sources and DOI, and the withdrawal if any (sections 4.2, 4.3 and 13.1).

    <item><strong|Search engines.> Landing pages MUST carry the meta tags read by Google Scholar: <verbatim|citation_title>, <verbatim|citation_author> (one per creator), <verbatim|citation_publication_date> (the <verbatim|Issued> date, or else the <verbatim|Available> date of the current version) and <verbatim|citation_pdf_url>, a PDF on the landing page's host (served with <verbatim|Content-Security-Policy: sandbox>, section 15.3). They SHOULD carry schema.org <verbatim|ScholarlyArticle> JSON-LD and FAIR Signposting links (<verbatim|cite-as>, <verbatim|describedby>, <verbatim|item>, <verbatim|license>), and offer BibTeX and CSL-JSON entries made from <verbatim|datacite.json>.

    <item><strong|Feed and harvesters.> The feed (<verbatim|feed>, section 3.1) lists the signed object versions the archive holds, by the <verbatim|created> date of their inventories. The website SHOULD publish a <verbatim|sitemap.xml>, and MAY publish an OAI-PMH static repository or a ResourceSync description.
  </itemize>

  <section*|Appendix B. JSON Schemas (normative)><label|appendix-b-json-schemas-normative>

  The schemas are written in JSON Schema 2020-12, published at <verbatim|https://opensheaf.org/schemas/\<less\>file\<gtr\>>, their <verbatim|$id>, and dedicated to the public domain under CC0 1.0 (section 15.6). They validate:

  <\itemize>
    <item><verbatim|opensheaf-archive-0.1.schema.json>: <verbatim|opensheaf.json> (section 3.1);

    <item><verbatim|opensheaf-object-0.1.schema.json>: <verbatim|object.json>, also as <verbatim|parent.object.json> and in <verbatim|parent.chain/> (sections 4.3 and 9.2);

    <item><verbatim|opensheaf-collection-0.1.schema.json>: <verbatim|members.json> (section 8.2);

    <item><verbatim|opensheaf-genesis-0.1.schema.json>: <verbatim|genesis.json> (section 5.1);

    <item><verbatim|opensheaf-keys-0.1.schema.json>: <verbatim|keys.json>, also as carried by fork records and healing versions (section 6);

    <item><verbatim|opensheaf-signature-0.1.schema.json>: signature files, wherever kept or carried, and others' <verbatim|witness-\<less\>label\<gtr\>.json> (sections 7.2 and 9.2);

    <item><verbatim|opensheaf-keeper-0.1.schema.json>: <verbatim|/.well-known/opensheaf> (section 6.6);

    <item><verbatim|opensheaf-index-0.1.schema.json>: index files and <verbatim|indexes.json> (section 12.5).
  </itemize>

  <strong|Validation.> A file is valid when it validates against its schema with <verbatim|format> asserted (section 14.2). The schemas of <verbatim|genesis.json>, <verbatim|keys.json>, signature files and the keeper's file allow no other properties; the others do, and such properties carry no meaning here (the data of extensions goes under <verbatim|extensions>, section 2). Where a schema and the text disagree, the text prevails.

  <strong|Other files.> <verbatim|datacite.json> is validated by converting it to XML, following DataCite's mapping between the JSON of its REST API and XML, against the DataCite 4.7 XML Schema, with the requirements of section 4.4. Inventories, their checksum files and <verbatim|ocfl_layout.json> are OCFL's (section 14.2). The schema of the <hlink|timestamps extension|opensheaf-timestamps-0.1.tm> is published with it.

  <strong|Beyond the schemas.> A schema checks one file alone; whatever relates it to another file, its place, a digest or a key (names and identifiers, <verbatim|documentVersion> and <verbatim|datacite.json>, thresholds, signatures, fork records, uniqueness across entries, index prefixes) is checked by verifiers (section 14).

  <strong|Open questions.>

  <\itemize>
    <item>Registering DOIs with an archive's own DataCite prefix (a <verbatim|datacite> profile), and documents that already have a DOI elsewhere (#8).

    <item>Whether a Zenodo record version also uploads the version's inventory file, its checksum file and its signature files, so that it can be checked against a pin (#22; section 12.6).

    <item>Whether a takedown reaches the records of external services (#33).

    <item>The field names of <verbatim|keys.json>, signature files and the evidence of branches, which the schemas follow (#55); the files of fork records and healing versions, provisional (#58).
  </itemize>

  <section*|Appendix C. Examples (non-normative)><label|appendix-c-examples-non-normative>

  The examples follow one paper of the first archive (section 1) through an illustrative history: its owner is created, the paper is sealed and revised, kept in the archive's main catalogue, and accepted by a journal, which keeps an accepted copy and lists it in an issue. The title and the authors are those of the archive; the dates, the journal and its domain are invented, and the DOIs (with Zenodo's prefix) and the ORCID iD (with a valid check digit) are placeholders. Every name, owner name, <verbatim|did:key>, file name derived from a key or a digest, and signature is computed: names from the genesis records shown (section 5.2), keys from private keys made for these examples, signatures over the messages shown (section 7.2), and inventory digests from inventories that are not shown. Every JSON file shown validates against its schema (appendix B).

  <subsection*|C.1 An owner and its key log><label|c1-an-owner-and-its-key-log>

  The genesis record of the authors' owner. It takes the first choice of section 6.2: two keys from the first version and a threshold of 1, the first key in daily use on a laptop, the second a spare kept apart on a hardware token and used only to heal (section 6.3):

  <\html-div-class|language-json>
  <\verbatim-code>
    {

    \ \ "format": "opensheaf-genesis/0.1",

    \ \ "kind": "owner",

    \ \ "created": "2026-03-01T17:40:00Z",

    \ \ "nonce": "1b4d9964664d9825076eb8558af61162",

    \ \ "keys": [

    \ \ \ \ "did:key:z6MksKLDefPeXwhL6SJCLqpW1dGZcvBjfsv9mxGCFpMkMuVW",

    \ \ \ \ "did:key:z6MkkmL4ZLBakiEjfqGa5KrRJQ3bAWDgowW2AicNGxBrxwP5"

    \ \ ],

    \ \ "threshold": 1

    }
  </verbatim-code>
  </html-div-class>

  Its name, the owner name, is <verbatim|ttm4koeifphkud7j5wkmqqovbpbhlycbunxavensjixgjyc5u3eq>: the SHA-256 digest of <verbatim|opensheaf-name-0>, a line feed and the bytes shown, with a final line feed, in base32 (section 5.2). The owner object is at <verbatim|ttm4koeifphkud7j5wkmqqovbpbhlycbunxavensjixgjyc5u3eq/ttm4koeifphkud7j5wkmqqovbpbhlycbunxavensjixgjyc5u3eq/> in the owner-name layout (section 3.2), and its <verbatim|object.json> is the same in every version:

  <\html-div-class|language-json>
  <\verbatim-code>
    {

    \ \ "format": "opensheaf-object/0.1",

    \ \ "specification": "0.1",

    \ \ "kind": "owner",

    \ \ "status": "active",

    \ \ "name": "ttm4koeifphkud7j5wkmqqovbpbhlycbunxavensjixgjyc5u3eq",

    \ \ "owner": "ttm4koeifphkud7j5wkmqqovbpbhlycbunxavensjixgjyc5u3eq"

    }
  </verbatim-code>
  </html-div-class>

  The <verbatim|keys.json> of the first version of the key log repeats the keys and threshold of the genesis record, names the keeper (section 6.6), and adopts the <hlink|timestamps extension|opensheaf-timestamps-0.1.tm> with one RFC 3161 authority (a placeholder fingerprint):

  <\html-div-class|language-json>
  <\verbatim-code>
    {

    \ \ "format": "opensheaf-keys/0.1",

    \ \ "keys": [

    \ \ \ \ "did:key:z6MksKLDefPeXwhL6SJCLqpW1dGZcvBjfsv9mxGCFpMkMuVW",

    \ \ \ \ "did:key:z6MkkmL4ZLBakiEjfqGa5KrRJQ3bAWDgowW2AicNGxBrxwP5"

    \ \ ],

    \ \ "threshold": 1,

    \ \ "keeper": [

    \ \ \ \ "https://orcid.org/0000-0002-1234-5677"

    \ \ ],

    \ \ "extensions": {

    \ \ \ \ "https://opensheaf.org/opensheaf-timestamps-0.1": {

    \ \ \ \ \ \ "timestampAuthorities": [

    \ \ \ \ \ \ \ \ "5b4e3f0c9d2a7e18c6f4b0a39d7e2c51f8a6b3d09e4c7a12f5b8d6e3a0c9f147"

    \ \ \ \ \ \ ]

    \ \ \ \ }

    \ \ }

    }
  </verbatim-code>
  </html-div-class>

  It is signed by its own first key, in <verbatim|v1/signature-w7htq42yt7tllefi.json> of the owner object's witness folder, whose <verbatim|keyLog> names this version itself (section 7.2). When the laptop is replaced, the second version adds the new laptop's key and retires the old one (section 6.2); it is signed by the old key, listed in the first version, in <verbatim|v2/signature-w7htq42yt7tllefi.json>, whose <verbatim|keyLog> is <verbatim|sheaf:ttm4koeifphkud7j5wkmqqovbpbhlycbunxavensjixgjyc5u3eq/v1?sha512=2d04f58c210a61cdf4fef1ed4300443f8a99ccb728f27c6765ffc281ff7b3c7c721f6f4421485c1e6697a68106841746f73ae8015f656e9333ac2f05d02e3cfb>:

  <\html-div-class|language-json>
  <\verbatim-code>
    {

    \ \ "format": "opensheaf-keys/0.1",

    \ \ "keys": [

    \ \ \ \ "did:key:z6MkkmL4ZLBakiEjfqGa5KrRJQ3bAWDgowW2AicNGxBrxwP5",

    \ \ \ \ "did:key:z6MkugKqPPkysjyartSzszBbMh8fVhENmqGXvddtD8DDvThn"

    \ \ ],

    \ \ "threshold": 1,

    \ \ "keeper": [

    \ \ \ \ "https://orcid.org/0000-0002-1234-5677"

    \ \ ],

    \ \ "extensions": {

    \ \ \ \ "https://opensheaf.org/opensheaf-timestamps-0.1": {

    \ \ \ \ \ \ "timestampAuthorities": [

    \ \ \ \ \ \ \ \ "5b4e3f0c9d2a7e18c6f4b0a39d7e2c51f8a6b3d09e4c7a12f5b8d6e3a0c9f147"

    \ \ \ \ \ \ ]

    \ \ \ \ }

    \ \ }

    }
  </verbatim-code>
  </html-div-class>

  The journal's owner, <verbatim|rvv4h5sjjhpumjybemqnsscf544aonqmvmthqma3xc3ldmim73ba>, took the other choice: three keys and a threshold of 2 from its first version, so that every version it makes carries two signature files.

  <subsection*|C.2 A document version><label|c2-a-document-version>

  The genesis record of the paper, written when the owner sealed it (section 10.2):

  <\html-div-class|language-json>
  <\verbatim-code>
    {

    \ \ "format": "opensheaf-genesis/0.1",

    \ \ "kind": "document",

    \ \ "created": "2026-03-02T09:14:00Z",

    \ \ "originator": "ttm4koeifphkud7j5wkmqqovbpbhlycbunxavensjixgjyc5u3eq",

    \ \ "nonce": "6f65cd32058c16d6d78b05011772ff1d"

    }
  </verbatim-code>
  </html-div-class>

  Its genesis name is <verbatim|glncddtxk4yxiiqzzht5j6rzbu2xangkvezhj3inn2s4icxjgvva>; by algorithm 1 its name is <verbatim|osms3d3jl3nx3qfsfb5tze2qbgtehtdrxhaylj6cd3whpk62njqr>, which a branch renamed after a clash would take (section 5.3). The line is <verbatim|sheaf:glncddtxk4yxiiqzzht5j6rzbu2xangkvezhj3inn2s4icxjgvva:ttm4koeifphkud7j5wkmqqovbpbhlycbunxavensjixgjyc5u3eq>. The <verbatim|object.json> of its first version (section 4.3), which was deposited with Zenodo (appendix A.1):

  <\html-div-class|language-json>
  <\verbatim-code>
    {

    \ \ "format": "opensheaf-object/0.1",

    \ \ "specification": "0.1",

    \ \ "kind": "document",

    \ \ "name": "glncddtxk4yxiiqzzht5j6rzbu2xangkvezhj3inn2s4icxjgvva",

    \ \ "owner": "ttm4koeifphkud7j5wkmqqovbpbhlycbunxavensjixgjyc5u3eq",

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

  The <verbatim|datacite.json> of the same version (section 4.4). The version has a Zenodo DOI, so Zenodo is its <verbatim|publisher>, and <verbatim|url> is its landing page (appendix A.3):

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

    \ \ "descriptions": [ { "description": "We present a new, simple ...",

    \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ "descriptionType": "Abstract" } ],

    \ \ "formats": [ "application/x-texmacs", "application/pdf" ],

    \ \ "relatedIdentifiers": [ { "relatedIdentifier": "10.5281/zenodo.1234566",

    \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ "relatedIdentifierType": "DOI", "relationType": "IsVersionOf" } ]

    }
  </verbatim-code>
  </html-div-class>

  The second object version holds document version 2 (section 4.2), corrected after the referee's report and accepted by the journal: its <verbatim|object.json> has <verbatim|documentVersion> 2, <verbatim|changes>, <verbatim|stage> <verbatim|AM> and the DOI <verbatim|10.5281/zenodo.1234568>, and its <verbatim|datacite.json> has <verbatim|version> <verbatim|"2"> and <verbatim|IsNewVersionOf> the DOI of version 1.

  <subsection*|C.3 A signature><label|c3-a-signature>

  The signature of that version by the new laptop's key, <verbatim|extensions/opensheaf-witnesses/v2/signature-4hz7zgsiazl6hx7i.json> in the paper's object, <verbatim|4hz7zgsiazl6hx7i> being the first 16 characters of the base32 SHA-256 digest of the <verbatim|did:key> (section 7.2); it names version 2 of the key log, which lists the key:

  <\html-div-class|language-json>
  <\verbatim-code>
    {

    \ \ "format": "opensheaf-signature/0.1",

    \ \ "object": "sheaf:glncddtxk4yxiiqzzht5j6rzbu2xangkvezhj3inn2s4icxjgvva:ttm4koeifphkud7j5wkmqqovbpbhlycbunxavensjixgjyc5u3eq",

    \ \ "version": "v2",

    \ \ "inventorySha512": "a7cf31b8075b26d140d4961075996d25bdcbeb72edd97d455333f58051368f2bb65ee0e6a61b744edbf316eeae335b964ae0c658255fbfee9395520b417f8689",

    \ \ "signer": "ttm4koeifphkud7j5wkmqqovbpbhlycbunxavensjixgjyc5u3eq",

    \ \ "key": "did:key:z6MkugKqPPkysjyartSzszBbMh8fVhENmqGXvddtD8DDvThn",

    \ \ "keyLog": "sheaf:ttm4koeifphkud7j5wkmqqovbpbhlycbunxavensjixgjyc5u3eq/v2?sha512=a624c2dc10c0dbd369b7da9bd1326c445efd453afd5b84e5a6f53812c59ae393799452387d905980beae7f6a06ec05a08e73d1a0d3813a47f4c5fe08686601ae",

    \ \ "signature": "PMhzGXcpbLdw/khQDgsrAj7Z0nuJnY6/UDXGoAekLENCBllYJY3QLERKFvBZXPTwaeGCh7z61evcUE3X9s/DBw=="

    }
  </verbatim-code>
  </html-div-class>

  The message it signs, each line ended by a line feed (section 7.2):

  <\verbatim-code>
    opensheaf-signature/0.1

    object sheaf:glncddtxk4yxiiqzzht5j6rzbu2xangkvezhj3inn2s4icxjgvva:ttm4koeifphkud7j5wkmqqovbpbhlycbunxavensjixgjyc5u3eq

    version v2

    inventory a7cf31b8075b26d140d4961075996d25bdcbeb72edd97d455333f58051368f2bb65ee0e6a61b744edbf316eeae335b964ae0c658255fbfee9395520b417f8689

    keylog sheaf:ttm4koeifphkud7j5wkmqqovbpbhlycbunxavensjixgjyc5u3eq/v2?sha512=a624c2dc10c0dbd369b7da9bd1326c445efd453afd5b84e5a6f53812c59ae393799452387d905980beae7f6a06ec05a08e73d1a0d3813a47f4c5fe08686601ae
  </verbatim-code>

  With a threshold of 1, this one good signature makes the version signed (section 7.3).

  <subsection*|C.4 Collections><label|c4-collections>

  The <verbatim|members.json> of the second version of the archive's main catalogue (section 8.3), owned by the authors' owner. The member is followed, so that when version 2 of the paper was signed, the catalogue's tool wrote this version, pinning it in place of version 1:

  <\html-div-class|language-json>
  <\verbatim-code>
    {

    \ \ "format": "opensheaf-collection/0.1",

    \ \ "type": "catalogue",

    \ \ "order": "issued-desc",

    \ \ "members": [

    \ \ \ \ { "kind": "document",

    \ \ \ \ \ \ "name": "glncddtxk4yxiiqzzht5j6rzbu2xangkvezhj3inn2s4icxjgvva",

    \ \ \ \ \ \ "owner": "ttm4koeifphkud7j5wkmqqovbpbhlycbunxavensjixgjyc5u3eq",

    \ \ \ \ \ \ "at": [ "https://mgubi.org/papers/" ],

    \ \ \ \ \ \ "version": "v2",

    \ \ \ \ \ \ "inventorySha512": "a7cf31b8075b26d140d4961075996d25bdcbeb72edd97d455333f58051368f2bb65ee0e6a61b744edbf316eeae335b964ae0c658255fbfee9395520b417f8689",

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

    \ \ "format": "opensheaf-collection/0.1",

    \ \ "type": "selection",

    \ \ "members": [

    \ \ \ \ { "kind": "document",

    \ \ \ \ \ \ "name": "glncddtxk4yxiiqzzht5j6rzbu2xangkvezhj3inn2s4icxjgvva",

    \ \ \ \ \ \ "owner": "rvv4h5sjjhpumjybemqnsscf544aonqmvmthqma3xc3ldmim73ba",

    \ \ \ \ \ \ "at": [ "https://journal.example.org/" ],

    \ \ \ \ \ \ "revisions": [ { "documentVersion": 2, "version": "v1",

    \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ "inventorySha512": "fd4f4ea3c71eb9ca6d5653298771606154b1b1f665438068a80d1139cdf2c622d88d596867ef627b52aef27af51189db9d92836e06cc5cadb9480ed568792183" } ],

    \ \ \ \ \ \ "cite": { "title": "Mass gap for the fractional $\\\\Phi^4_2$ model",

    \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ "creators": [ "P. Duch", "M. Gubinelli" ], "year": 2026, "issued": "2026-03-02" } },

    \ \ \ \ { "kind": "document",

    \ \ \ \ \ \ "name": "glncddtxk4yxiiqzzht5j6rzbu2xangkvezhj3inn2s4icxjgvva",

    \ \ \ \ \ \ "owner": "ttm4koeifphkud7j5wkmqqovbpbhlycbunxavensjixgjyc5u3eq",

    \ \ \ \ \ \ "at": [ "https://mgubi.org/papers/" ],

    \ \ \ \ \ \ "revisions": [ { "documentVersion": 2, "version": "v2",

    \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ "inventorySha512": "a7cf31b8075b26d140d4961075996d25bdcbeb72edd97d455333f58051368f2bb65ee0e6a61b744edbf316eeae335b964ae0c658255fbfee9395520b417f8689",

    \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ "doi": "10.5281/zenodo.1234568" } ] }

    \ \ ]

    }
  </verbatim-code>
  </html-div-class>

  <subsection*|C.5 A branch: an accepted copy><label|c5-a-branch-an-accepted-copy>

  The <verbatim|object.json> of the first version of the journal's accepted copy, a branch of the authors' line at their object version <verbatim|v2> (sections 9.1 and 9.6). No line of that name is the journal's, so the branch takes the genesis name, and its line is <verbatim|sheaf:glncddtxk4yxiiqzzht5j6rzbu2xangkvezhj3inn2s4icxjgvva:rvv4h5sjjhpumjybemqnsscf544aonqmvmthqma3xc3ldmim73ba>:

  <\html-div-class|language-json>
  <\verbatim-code>
    {

    \ \ "format": "opensheaf-object/0.1",

    \ \ "specification": "0.1",

    \ \ "kind": "document",

    \ \ "name": "glncddtxk4yxiiqzzht5j6rzbu2xangkvezhj3inn2s4icxjgvva",

    \ \ "owner": "rvv4h5sjjhpumjybemqnsscf544aonqmvmthqma3xc3ldmim73ba",

    \ \ "parent": {

    \ \ \ \ "owner": "ttm4koeifphkud7j5wkmqqovbpbhlycbunxavensjixgjyc5u3eq",

    \ \ \ \ "name": "glncddtxk4yxiiqzzht5j6rzbu2xangkvezhj3inn2s4icxjgvva",

    \ \ \ \ "objectVersion": "v2",

    \ \ \ \ "documentVersion": 2,

    \ \ \ \ "inventorySha512": "a7cf31b8075b26d140d4961075996d25bdcbeb72edd97d455333f58051368f2bb65ee0e6a61b744edbf316eeae335b964ae0c658255fbfee9395520b417f8689",

    \ \ \ \ "url": "https://mgubi.org/papers/ocfl/ttm4koeifphkud7j5wkmqqovbpbhlycbunxavensjixgjyc5u3eq/glncddtxk4yxiiqzzht5j6rzbu2xangkvezhj3inn2s4icxjgvva/v2/"

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

  Its content holds the files of the parent version except <verbatim|datacite.json> and <verbatim|object.json> (<verbatim|genesis.json>, the source and the PDF), its own <verbatim|datacite.json> and <verbatim|object.json>, and the evidence (section 9.2): <verbatim|parent.inventory.json>, the authors' <verbatim|v2/inventory.json>; <verbatim|parent.object.json>, their <verbatim|object.json> of that version; and <verbatim|parent.signatures/signature-4hz7zgsiazl6hx7i.json>, the file of section C.3, byte for byte. Its witness folder holds two signature files of the journal's keys, naming the first version of the journal's key log. The journal's storage root keeps beside it the owner objects of the journal and of the authors (section 6.5).

  <subsection*|C.6 The archive><label|c6-the-archive>

  The storage root of the authors' archive in the owner-name layout (section 3.2), showing the paper's witness folder, with an RFC 3161 token of each signature (timestamps extension; the tokens are not shown):

  <\verbatim-code>
    ocfl/

    \ \ 0=ocfl_1.1

    \ \ ocfl_layout.json

    \ \ ttm4koeifphkud7j5wkmqqovbpbhlycbunxavensjixgjyc5u3eq/

    \ \ \ \ ttm4koeifphkud7j5wkmqqovbpbhlycbunxavensjixgjyc5u3eq/ \ \ \ \ \ the key log

    \ \ \ \ glncddtxk4yxiiqzzht5j6rzbu2xangkvezhj3inn2s4icxjgvva/ \ \ \ \ \ the paper

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

    \ \ \ \ qgtkkcwbbao2powpxpge4f6w27rr3drqzt3eljswnv2ymvlkbxma/ \ \ \ \ \ the main catalogue
  </verbatim-code>

  In the hashed layout, the paper would be at <verbatim|933/34d/349/sheaf%3aglncddtxk4yxiiqzzht5j6rzbu2xangkvezhj3inn2s4icxjgvva%3attm4koeifphkud7j5wkmqqovbpbhlycbunxav-93334d349fc19e8fbbc73330df99a0606e54fe0e3f68a1ebe117416b8f96f945/>: its identifier of 111 characters encodes to 115, each <verbatim|:> becoming <verbatim|%3a>, and is shortened (section 3.2).

  The discovery document (section 3.1). The archive hosts one owner, whose key log, paper and catalogue it lists, with labels for the website; a second paper of the owner was taken down, and its tombstone (section 13.3) keeps its line taken:

  <\html-div-class|language-json>
  <\verbatim-code>
    {

    \ \ "format": "opensheaf-archive/0.1",

    \ \ "specification": "0.1",

    \ \ "name": "Papers of Massimiliano Gubinelli",

    \ \ "contact": "https://orcid.org/0000-0002-1234-5677",

    \ \ "storageRoot": "ocfl/",

    \ \ "storageLayout": "opensheaf-owner-name-storage-layout",

    \ \ "mainCollection": "sheaf:qgtkkcwbbao2powpxpge4f6w27rr3drqzt3eljswnv2ymvlkbxma:ttm4koeifphkud7j5wkmqqovbpbhlycbunxavensjixgjyc5u3eq",

    \ \ "profiles": [ "zenodo", "texmacs", "website" ],

    \ \ "extensions": [ "https://opensheaf.org/opensheaf-timestamps-0.1" ],

    \ \ "owners": [ "ttm4koeifphkud7j5wkmqqovbpbhlycbunxavensjixgjyc5u3eq" ],

    \ \ "indexes": { "names": 2, "owners": 2, "sha512": 2 },

    \ \ "objects": [

    \ \ \ \ { "id": "sheaf:ttm4koeifphkud7j5wkmqqovbpbhlycbunxavensjixgjyc5u3eq:ttm4koeifphkud7j5wkmqqovbpbhlycbunxavensjixgjyc5u3eq",

    \ \ \ \ \ \ "kind": "owner", "name": "ttm4koeifphkud7j5wkmqqovbpbhlycbunxavensjixgjyc5u3eq", "owner": "ttm4koeifphkud7j5wkmqqovbpbhlycbunxavensjixgjyc5u3eq",

    \ \ \ \ \ \ "head": "v2", "inventorySha512": "a624c2dc10c0dbd369b7da9bd1326c445efd453afd5b84e5a6f53812c59ae393799452387d905980beae7f6a06ec05a08e73d1a0d3813a47f4c5fe08686601ae",

    \ \ \ \ \ \ "status": "active" },

    \ \ \ \ { "id": "sheaf:glncddtxk4yxiiqzzht5j6rzbu2xangkvezhj3inn2s4icxjgvva:ttm4koeifphkud7j5wkmqqovbpbhlycbunxavensjixgjyc5u3eq",

    \ \ \ \ \ \ "kind": "document", "name": "glncddtxk4yxiiqzzht5j6rzbu2xangkvezhj3inn2s4icxjgvva", "owner": "ttm4koeifphkud7j5wkmqqovbpbhlycbunxavensjixgjyc5u3eq",

    \ \ \ \ \ \ "head": "v2", "inventorySha512": "a7cf31b8075b26d140d4961075996d25bdcbeb72edd97d455333f58051368f2bb65ee0e6a61b744edbf316eeae335b964ae0c658255fbfee9395520b417f8689",

    \ \ \ \ \ \ "status": "active", "label": "fractional-phi42-mass-gap" },

    \ \ \ \ { "id": "sheaf:qgtkkcwbbao2powpxpge4f6w27rr3drqzt3eljswnv2ymvlkbxma:ttm4koeifphkud7j5wkmqqovbpbhlycbunxavensjixgjyc5u3eq",

    \ \ \ \ \ \ "kind": "collection", "name": "qgtkkcwbbao2powpxpge4f6w27rr3drqzt3eljswnv2ymvlkbxma", "owner": "ttm4koeifphkud7j5wkmqqovbpbhlycbunxavensjixgjyc5u3eq",

    \ \ \ \ \ \ "head": "v2", "inventorySha512": "29c17c0325606d503059a6276a0ff9366f9ee0f70aecd8dc5393089d2648609910b6261895533af250e89bd8c3061e564f2026b6153a5cea0dd569a85f506c50",

    \ \ \ \ \ \ "status": "active", "label": "papers" }

    \ \ ],

    \ \ "tombstones": [

    \ \ \ \ { "id": "sheaf:tsck634axtq5brrchz2oxxanzztzd4drsoirdnuh5eyvs6ty4fua:ttm4koeifphkud7j5wkmqqovbpbhlycbunxavensjixgjyc5u3eq",

    \ \ \ \ \ \ "kind": "document", "name": "tsck634axtq5brrchz2oxxanzztzd4drsoirdnuh5eyvs6ty4fua", "owner": "ttm4koeifphkud7j5wkmqqovbpbhlycbunxavensjixgjyc5u3eq",

    \ \ \ \ \ \ "genesisName": "tsck634axtq5brrchz2oxxanzztzd4drsoirdnuh5eyvs6ty4fua",

    \ \ \ \ \ \ "lastVersion": "v1", "inventorySha512": "ede3e9be2e8e74503af7df6408f0f43846b80ebaece2737e16019e37a8ce7e8fba0bb6945fde5973a94d6373c7d8118413fd6587d5e9a3cbade685eae2ea5ae3",

    \ \ \ \ \ \ "date": "2026-05-04", "reason": "Taken down at the request of the holder of the rights." }

    \ \ ]

    }
  </verbatim-code>
  </html-div-class>

  <subsection*|C.7 sheaf: URIs><label|c7-sheaf-uris>

  URIs of the paper, of the accepted copy and of the authors' owner (section 12):

  <\verbatim-code>
    sheaf:glncddtxk4yxiiqzzht5j6rzbu2xangkvezhj3inn2s4icxjgvva

    \ \ \ \ the authors' line (its owner is the originator)

    sheaf:glncddtxk4yxiiqzzht5j6rzbu2xangkvezhj3inn2s4icxjgvva/v2

    \ \ \ \ document version 2 of the authors' line

    sheaf:glncddtxk4yxiiqzzht5j6rzbu2xangkvezhj3inn2s4icxjgvva/v2?sha512=a7cf31b8075b26d140d4961075996d25bdcbeb72edd97d455333f58051368f2bb65ee0e6a61b744edbf316eeae335b964ae0c658255fbfee9395520b417f8689

    \ \ \ \ the authors' object version v2, which the journal vetted

    sheaf:glncddtxk4yxiiqzzht5j6rzbu2xangkvezhj3inn2s4icxjgvva/v2?sha512=a7cf31b8075b26d140d4961075996d25bdcbeb72edd97d455333f58051368f2bb65ee0e6a61b744edbf316eeae335b964ae0c658255fbfee9395520b417f8689&at=https%3A%2F%2Fmgubi.org%2Fpapers%2F

    \ \ \ \ the same, with a hint

    sheaf:glncddtxk4yxiiqzzht5j6rzbu2xangkvezhj3inn2s4icxjgvva:rvv4h5sjjhpumjybemqnsscf544aonqmvmthqma3xc3ldmim73ba/v2

    \ \ \ \ document version 2 of the journal's line, its accepted copy

    sheaf:glncddtxk4yxiiqzzht5j6rzbu2xangkvezhj3inn2s4icxjgvva:*

    \ \ \ \ the work: the authors' line, the journal's and any other

    sheaf:ttm4koeifphkud7j5wkmqqovbpbhlycbunxavensjixgjyc5u3eq

    \ \ \ \ the authors' owner: its key log

    sheaf:ttm4koeifphkud7j5wkmqqovbpbhlycbunxavensjixgjyc5u3eq/v2?sha512=a624c2dc10c0dbd369b7da9bd1326c445efd453afd5b84e5a6f53812c59ae393799452387d905980beae7f6a06ec05a08e73d1a0d3813a47f4c5fe08686601ae

    \ \ \ \ version 2 of its key log, as keyLog names it

    sheaf:glncddtx/v2

    sheaf:glncddtx:rvv4h5sj/v2

    \ \ \ \ short forms of the second and fifth (section 12.2)

    https://opensheaf.org/sheaf:glncddtxk4yxiiqzzht5j6rzbu2xangkvezhj3inn2s4icxjgvva/v2

    \ \ \ \ the second, through a gateway (provisional, #35)
  </verbatim-code>

  <subsection*|C.8 A fork of a key log (provisional, #58)><label|c8-a-fork-of-a-key-log-provisional-58>

  Later, the new laptop is stolen. The thief signs with its key a version 3 of the key log listing only a key of its own; the owner, not yet aware, has signed with the same key another version 3, adding a domain to <verbatim|keeper>. Both are signed against version 2, so an archive holding one that meets the other replaces its version 3 by a fork record (section 6.3), which nullifies the stolen key. The owner object there:

  <\verbatim-code>
    ttm4koeifphkud7j5wkmqqovbpbhlycbunxavensjixgjyc5u3eq/ttm4koeifphkud7j5wkmqqovbpbhlycbunxavensjixgjyc5u3eq/

    \ \ inventory.json

    \ \ inventory.json.sha512

    \ \ v1/

    \ \ v2/

    \ \ v3/ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ the fork record

    \ \ \ \ inventory.json

    \ \ \ \ inventory.json.sha512

    \ \ \ \ content/forked/w6s5uujjs56ilzmn/ \ \ \ \ \ \ \ \ \ the owner's version 3

    \ \ \ \ \ \ inventory.json

    \ \ \ \ \ \ inventory.json.sha512

    \ \ \ \ \ \ keys.json

    \ \ \ \ \ \ signature-4hz7zgsiazl6hx7i.json

    \ \ \ \ content/forked/gqqa23zsg6ehczgj/ \ \ \ \ \ \ \ \ \ the thief's version 3

    \ \ \ \ \ \ inventory.json

    \ \ \ \ \ \ inventory.json.sha512

    \ \ \ \ \ \ keys.json

    \ \ \ \ \ \ signature-4hz7zgsiazl6hx7i.json
  </verbatim-code>

  The fork record's <verbatim|genesis.json> and <verbatim|object.json> are those of <verbatim|v1>, to which its inventory refers, and it has no <verbatim|keys.json>. The owner heals with its spare key, which signed neither version: a healing version 3 carrying both, whose <verbatim|keys.json> lists the spare key and a new one, not the stolen key (section 6.3). The signatures made with the stolen key stay good, and readers weigh them as section 6.4 says.

  <section*|Plan of the rebuilt text><label|plan-of-the-rebuilt-text>

  Each part is rebuilt in turn, from the reference text and an audit of the concept, and agreed before the next. Sections 1 to 16 are rebuilt; the others are planned as follows, and read meanwhile in the reference text.

  Appendices: D. rationale; E. references.

</body>

<\initial>
  <\collection>
    <associate|page-medium|paper>
  </collection>
</initial>
