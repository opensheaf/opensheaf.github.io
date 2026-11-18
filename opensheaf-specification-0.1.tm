<TeXmacs|2.1.5>

<style|<tuple|notes|notes-meta>>

<\body>
  <notes-header>

  <chapter*|OpenSheaf: an open format for document archives and collections>

  <notes-abstract|Specification, version 0.1 (draft), 18 November 2026. OpenSheaf is a common, open format for archives of scholarly documents and for collections of them, built on the Oxford Common File Layout (OCFL 1.1) and the DataCite Metadata Schema (4.7). The text is licensed under CC BY-SA 4.0; the JSON Schemas are dedicated to the public domain (CC0 1.0).>

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

  JSON means RFC 8259 JSON in UTF-8 without a byte order mark. URLs are absolute unless stated otherwise; a relative URL in a JSON file is resolved against the URL of that file. Digests are written in lowercase hexadecimal unless stated otherwise. Terms are defined where they are first introduced, written <dfn|thus>.

  <strong|Conformance classes.> An archive, an object or a program conforms to a class when it meets every MUST and MUST NOT of the sections listed for it:

  <\itemize>
    <item><strong|archive:> sections 3 to 13 and 15;

    <item><strong|collection:> section 8, with the rules on objects of sections 4 to 7;

    <item><strong|owner tool>, a program that seals, signs or keeps an owner's key log: sections 5 to 7 and 10;

    <item><strong|verifier:> sections 14 and 16 (as a reader), with the rules it checks;

    <item><strong|resolver:> section 12, with sections 6 and 7 for checking signatures and key logs; a gateway also follows the rules on gateways of section 12.
  </itemize>

  <strong|Profiles.> An archive MAY also follow the profiles of appendix A (Zenodo, TeXmacs, website), and MUST list in its discovery document those it follows.

  <strong|Extensions.> An extension is a specification published apart, named by a URI (RECOMMENDED: the <verbatim|https> URL where it is published), that records what this specification leaves open, so that tools aware of it can act on it. Its data is kept under <verbatim|extensions>, keyed by the extension's name: in <verbatim|object.json> (section 4), where the inventory and the pins fix it, or in <verbatim|keys.json> (section 6), where the owner's signatures fix it. An extension MUST NOT change the meaning of what this specification defines, nor relax its requirements: archives, objects and collections are read and verified without knowing any extension, and readers ignore extensions they do not know. The discovery document SHOULD list the extensions its objects use. The <hlink|timestamps extension|opensheaf-timestamps-0.1.tm> is one.

  <strong|Schemas.> The JSON files defined here MUST validate against the JSON Schemas of appendix B for their declared format version.

  <section*|3. Archives><label|3-archives>

  An <dfn|archive> is a host of objects, served at a <dfn|base URL> ending with <verbatim|/>. It holds the lines that owners write there (section 7) and copies of lines written elsewhere (section 11). It has no identity of its own and owns nothing by hosting: what is authentic is decided by the owners' signatures (section 7), and an archive decides only which owners it hosts and how they deposit (a university admitting its staff, a journal its editors). Its base URL is a location, not a name, and may change.

  An archive consists of a <strong|discovery document>, REQUIRED (section 3.1); a <strong|storage root>, REQUIRED (section 3.2); <strong|indexes>, RECOMMENDED (section 12); and <strong|presentation files>, OPTIONAL: web pages and other files generated for readers, never authoritative, kept outside the storage root (appendix A).

  <strong|Serving.> The discovery document, the storage root and the indexes MUST be served byte for byte, as stored: no conversion of line endings or character sets, and no compression that changes the bytes delivered after decoding. Archives SHOULD be served over HTTPS, and SHOULD allow cross-origin requests to these files (<verbatim|Access-Control-Allow-Origin: *>), so that tools in a browser can read them. Any static web server will do; an archive kept in git follows <hlink|OpenSheaf archives in git|opensheaf-git-0.1.tm>.

  <strong|Moving.> An archive moving to another site copies its files; nothing in them changes, so every pin, signature and witness stays valid. Its base URL, and every location of a copy given elsewhere (in collections, <verbatim|sheaf:> URIs, discovery documents), is a hint that needs no signature: whatever is fetched from it is checked against pins and signatures, so a wrong or stale location gives a reader nothing, or an older valid copy, never a forged one.

  <subsection*|3.1 The discovery document><label|31-the-discovery-document>

  The <dfn|discovery document> is the JSON file <verbatim|opensheaf.json> at the base URL. Static web servers cannot list folders; this one file makes an archive's objects known. It MUST contain:

  <\itemize>
    <item><verbatim|format>: <verbatim|"opensheaf-archive/0.1">, and <verbatim|specification>: <verbatim|"0.1">;

    <item><verbatim|name>: a readable name of the archive;

    <item><verbatim|storageRoot>: the URL of the storage root, ending with <verbatim|/> (it may be relative);

    <item><verbatim|storageLayout>: its layout, <verbatim|"opensheaf-owner-name-storage-layout"> or <verbatim|"0003-hash-and-id-n-tuple-storage-layout"> (section 3.2);

    <item><verbatim|profiles>: the profiles it follows, from <verbatim|zenodo>, <verbatim|texmacs>, <verbatim|website> (appendix A), possibly none;

    <item><verbatim|objects>: every object of the storage root except drafts, each with <verbatim|id> (section 4), <verbatim|kind>, <verbatim|name> and <verbatim|owner> (section 7), <verbatim|head> (its OCFL head version), <verbatim|inventorySha512> (the SHA-512 digest of the head inventory, as its checksum file states it) and <verbatim|status> (<verbatim|active> or <verbatim|withdrawn>, section 13), and OPTIONALLY a <verbatim|label>.
  </itemize>

  It SHOULD contain <verbatim|mainCollection>, the identifier of the catalogue of the archive's documents (section 8); <verbatim|contact>, a URI; and <verbatim|extensions>, the names of the extensions its objects use (section 2). It MAY contain <verbatim|owners>, the owner names of the owners it hosts (section 6); <verbatim|drafts>, the drafts it chooses to show, with <verbatim|id>, <verbatim|kind> and <verbatim|head>, as unfinished work on which nothing may rely (section 10); <verbatim|replicas>, base URLs of complete copies of the whole archive (distinct from mirrors of lines, section 11); <verbatim|tombstones> (section 13); <verbatim|indexes> (section 12); and <verbatim|feed>, the URL of an Atom feed of new object versions.

  The discovery document is rewritten whenever an object is added or changed. It is a map, not a witness: everything it states about objects MUST agree with the storage root, which verifiers check (section 14), and it lists what the archive holds, not every line an owner has elsewhere.

  <strong|Labels.> A <dfn|label> is a short readable name an archive MAY give a line it holds, for readable URLs on its website: it matches <verbatim|^[a-z0-9]+(-[a-z0-9]+)*$>, has at most 64 characters, and is unique in the discovery document. It is the archive's choice, may change, and is not an identifier; permanent links use <verbatim|sheaf:> URIs (section 12). Labels SHOULD be chosen by the depositor, not derived from the title.

  <subsection*|3.2 The storage root><label|32-the-storage-root>

  The <dfn|storage root> is an OCFL 1.1 storage root at the URL <verbatim|storageRoot>, holding the archive's objects (section 4). Since OCFL allows in it only the folders that lead to objects, and extensions, it SHOULD be a dedicated folder (by convention <verbatim|ocfl/>), and presentation files MUST NOT be placed in it. It MAY contain, as loose files, copies of the OCFL specification and of this one. Its <verbatim|ocfl_layout.json> names its storage layout, which MUST be the one given by <verbatim|storageLayout>:

  <\itemize>
    <item><strong|The owner-name layout>, <verbatim|opensheaf-owner-name-storage-layout>, the default, defined here (not yet registered with OCFL, so validators may warn about it). The object whose identifier is <verbatim|sheaf:\<less\>name\<gtr\>:\<less\>owner\<gtr\>> (section 4) is at <verbatim|\<less\>owner\<gtr\>/\<less\>name\<gtr\>/>, and a draft <verbatim|sheaf:draft:\<less\>id\<gtr\>> at <verbatim|draft/\<less\>id\<gtr\>/>; any other identifier is an error. An owner's object is thus at <verbatim|\<less\>owner\<gtr\>/\<less\>owner\<gtr\>/>, and the folder of an owner holds its key log and every line of it in the archive, so that an owner moving elsewhere copies one folder. The layout has no parameters; <verbatim|ocfl_layout.json> describes it as <verbatim|"Lines at \<less\>owner\<gtr\>/\<less\>name\<gtr\>, drafts at draft/\<less\>id\<gtr\>">.

    <item><strong|The hashed layout>, for large archives: OCFL's <verbatim|0003-hash-and-id-n-tuple-storage-layout> with its default parameters (<verbatim|sha256>, tuples of 3 characters, 3 tuples), which a configuration file, if present, MUST NOT change. An object is at <verbatim|\<less\>t1\<gtr\>/\<less\>t2\<gtr\>/\<less\>t3\<gtr\>/\<less\>encoded id\<gtr\>/>, where <verbatim|\<less\>t1\<gtr\>>, <verbatim|\<less\>t2\<gtr\>>, <verbatim|\<less\>t3\<gtr\>> are the first three groups of three characters of the hexadecimal SHA-256 digest of its identifier, and <verbatim|\<less\>encoded id\<gtr\>> is the identifier percent-encoded as the extension says (every character but <verbatim|A-Z>, <verbatim|a-z>, <verbatim|0-9>, <verbatim|-> and <verbatim|_>), shortened, when longer than 100 characters, to its first 100 characters, <verbatim|-> and the full digest; identifiers of lines are always shortened so (appendix C). Readers compute the path; they never decode it.
  </itemize>

  Archives SHOULD use the owner-name layout, unless one folder per owner or per name becomes impractical (tens of thousands of lines, fewer in a git repository). The layout is chosen when the archive is created and SHOULD NOT be changed: pins stay valid, since readers compute paths from <verbatim|storageLayout>, but every URL into the storage root changes.

  <section*|4. Objects><label|4-objects>

  An <dfn|object> is an OCFL 1.1 object in a storage root. Its <dfn|kind>, given by its <verbatim|object.json> and never by its identifier, is <verbatim|document>, one work (an article, notes, a thesis, a book) with its sources and renditions; <verbatim|collection>, a list of members (section 8); or <verbatim|owner>, the key log of an owner (section 6).

  <strong|Identifier.> The <dfn|identifier> of an object, its OCFL <verbatim|id>, is <verbatim|sheaf:\<less\>name\<gtr\>:\<less\>owner\<gtr\>>, the name of the work (section 5) and the owner name of its line's owner (section 6), which <verbatim|object.json> records as <verbatim|name> and <verbatim|owner>. It names the line (section 7), in every archive. A branch is a new object with its own identifier (section 9); a draft is <verbatim|sheaf:draft:\<less\>id\<gtr\>> (section 10). The identifier MUST be unique in the storage root, and that of a sealed object MUST NOT be reused there, also after a takedown (section 13).

  <strong|Versions.> An <dfn|object version> is an OCFL version of an object (<verbatim|v1>, <verbatim|v2>, ...): every change of the object makes one, and none changes once made. A <dfn|document version> is a version of the work, a positive integer numbered by the owner of the line and recorded in <verbatim|object.json> and <verbatim|datacite.json>; it changes only when the document's own files change (section 4.2), so several object versions may hold one document version, with different descriptions or notices.

  <strong|Pins.> A <dfn|pin> is the pair (object version, SHA-512 digest of that version's inventory file, as its checksum file states it). An inventory records the digests of the files of its version and of every earlier one, so a pin fixes the object up to that version, in any copy. Collections (section 8), branches (section 9) and <verbatim|sheaf:> URIs (section 12) refer to object versions by pins, and pin only signed versions (section 7).

  <subsection*|4.1 Common rules><label|41-common-rules>

  Every object MUST be a valid OCFL 1.1 object, and:

  <\itemize>
    <item>its inventories MUST use the digest algorithm <verbatim|sha512>; they MAY also record MD5 and SHA-256 digests in <verbatim|fixity> (the Zenodo profile requires MD5, appendix A);

    <item>every version directory MUST contain the inventory as of that version, with its checksum file, so that each version can be pinned and fetched on its own;

    <item>version directories MUST NOT be zero-padded (<verbatim|v1>, not <verbatim|v001>);

    <item>logical paths MUST be in UTF-8 and Unicode normalisation form C, and MUST NOT begin with <verbatim|/> or contain <verbatim|.> or <verbatim|..> segments.
  </itemize>

  <strong|Deposits.> Each version in the inventory MUST have a <verbatim|user> with a <verbatim|name>, SHOULD give its <verbatim|address> (an ORCID iD, a <verbatim|mailto:> URI or another URI identifying the depositor), and MUST have a <verbatim|message> describing the change. The <verbatim|created> date and <verbatim|user> of an object version record its <dfn|deposit>, not repeated in <verbatim|object.json>; the deposit of a document version is that of the first object version holding it.

  <strong|Content.> Every object version MUST contain, at the top level of its content, <verbatim|object.json> (section 4.3); <verbatim|datacite.json> (section 4.4), except in an owner object; and the genesis record <verbatim|genesis.json> (section 5), except in a draft. Every version of a branch also holds the evidence of its branch point: <verbatim|parent.inventory.json>, <verbatim|parent.object.json>, <verbatim|parent.signatures/> and, for a branch of a branch, <verbatim|parent.chain/> (section 9). The genesis record and this evidence are the <dfn|identity files> of the object, never files of the document's own. The names of every file this specification defines at the top level of the content (<verbatim|object.json>, <verbatim|datacite.json>, <verbatim|genesis.json>, <verbatim|members.json>, <verbatim|keys.json>, <verbatim|parent.inventory.json>, <verbatim|parent.object.json>, <verbatim|parent.signatures>, <verbatim|parent.chain>) are reserved for those files. A collection version also holds <verbatim|members.json> (section 8). An owner object holds <verbatim|genesis.json> and <verbatim|keys.json> (section 6) and no <verbatim|datacite.json>; it has no document versions, and is never withdrawn or branched. Signatures and other witnesses are kept outside every version, in the object's extension folder <verbatim|extensions/opensheaf-witnesses/> (section 7).

  <subsection*|4.2 Documents and document versions><label|42-documents-and-document-versions>

  A document version holds, at the top level of its content unless a profile says otherwise, besides the files of section 4.1:

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

    <item><verbatim|status>: <verbatim|active> or <verbatim|withdrawn> (section 13), always <verbatim|active> for an owner;

    <item><verbatim|documentVersion>, for a document or a collection: equal to <verbatim|version> in <verbatim|datacite.json>;

    <item>in every version of a line, <verbatim|name> and <verbatim|owner> (sections 5 and 6), and in a branch <verbatim|parent>, its branch point (section 9); a draft has none of them.
  </itemize>

  An owner object has only these fields, and MAY have <verbatim|extensions> (below), though data concerning its key log goes in <verbatim|keys.json> (section 6).

  A <dfn|note> is an object with <verbatim|text>, a short plain text, or <verbatim|path> and <verbatim|mediaType>, a file of the content of the same object version, or both.

  A document MUST have <verbatim|mainSource> (a logical path) and <verbatim|sourceFormat> (its media type), and SHOULD have <verbatim|renditions>, a list of <verbatim|path> (a logical path) and <verbatim|mediaType>, and <verbatim|toolchain>, a list of tools with <verbatim|name>, <verbatim|version> and, OPTIONALLY, <verbatim|packages>, enough to reproduce the renditions. A document version without its sources has instead <verbatim|sourcesMissing>, a note saying why ("arXiv keeps only the PDF of this version"), and at least one rendition; a rendition is never presented as a source. A document MAY have:

  <\itemize>
    <item><verbatim|changes>: a note saying what changed in this document version, deposited with it (like arXiv's comments);

    <item><verbatim|stage>: the stage of this document version, with <verbatim|scheme> and <verbatim|value>; for articles the RECOMMENDED scheme is <verbatim|NISO-JAV> (NISO Journal Article Versions: <verbatim|AO>, <verbatim|SMUR>, <verbatim|AM>, <verbatim|P>, <verbatim|VoR>, <verbatim|CVoR>, <verbatim|EVoR>), and other content uses other schemes (editions, software releases), named by the archive;

    <item><verbatim|history> and <verbatim|notices> (section 4.2), each notice a note with the <verbatim|documentVersion> it is about and a <verbatim|date>.
  </itemize>

  A collection has none of these fields of a document. A document or a collection MAY have:

  <\itemize>
    <item><verbatim|licence>: a note with the full text or terms of the licence (for licences without an SPDX identifier); <verbatim|rightsList> in <verbatim|datacite.json> remains the description for readers;

    <item><verbatim|agreement>: a minimal record that the authors agreed to the deposit and the licence: <verbatim|by> (names only), <verbatim|date> and <verbatim|method> ("by e-mail"), all REQUIRED. It MUST NOT contain e-mail addresses, correspondence or signatures of persons;

    <item><verbatim|external>: the external records of this version, each with <verbatim|role> (<verbatim|deposit> for a deposit by the archive, appendix A; <verbatim|source> for the record it was imported from), <verbatim|service> (its name) and <verbatim|record> (its URL), all REQUIRED, and OPTIONALLY <verbatim|doi>, <verbatim|label> (the service's label for the version, such as <verbatim|v3>) and <verbatim|files>, the files kept there but not in the content (a deposit's source archive) or received from there, as received, each with <verbatim|name> and <verbatim|sha512> (REQUIRED), <verbatim|md5> and <verbatim|bytes>;

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

    <item><verbatim|Available>, SHOULD be present: when this document version first became public, anywhere (its date on the service it was imported from, or its deposit, section 4.1, if this archive made it public);

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

  When an object is created or deposited, an archive that holds an object or a tombstone with the same genesis record, compared by genesis name (<verbatim|genesisName> of a tombstone, section 13), MUST refuse it unless it is signed by the originator (the originator's line) or carries a chain of parent evidence that holds back to the originator's line (a branch, section 9).

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

  <strong|Choosing a threshold.> One <verbatim|threshold> governs the key log and every line of the owner. Owners choose between two risks: a threshold of 1 with a spare key kept apart (on a hardware token, for instance) survives the loss of a key but not its theft; a threshold of 2 with three keys kept apart, from the first version of the key log, survives the loss of one key and the theft of one. Owner tools SHOULD offer both, and SHOULD NOT create an owner with a single key, since an owner that loses every key of the latest version of its key log cannot recover.

  <strong|Retiring a key.> An owner retires a key it no longer uses (a replaced laptop, a member who leaves the group) by leaving it out of <verbatim|keys> in a new version of its key log. Signatures made with it stay good, and a retired key in someone else's hands still makes good signatures naming the versions that list it; so retiring is enough after an exposure only when the exposed keys cannot reach a threshold (section 6.3).

  <subsection*|6.3 Ending an owner, and forks><label|63-ending-an-owner-and-forks>

  <strong|Ending.> An owner whose keys may have been exposed (stolen, leaked, copied) MUST end when those keys could together reach the <verbatim|threshold> of some version of its key log that lists them; otherwise retiring them is enough (a threshold of 2 from the first version, and one key exposed). It signs, as usual, a last version of its key log with <verbatim|ended> <verbatim|true> and, OPTIONALLY, <verbatim|successor>, the owner name of a new owner that continues its work, which MUST differ from its own owner name. The ending version only ends: a version after one with <verbatim|ended> is not a version of the key log, and no signature of a line may name the ending version (section 7). Signatures made before it name earlier versions, and stay good. Owner tools MUST NOT sign anything for an ended owner. A successor is a hint, never followed automatically; its keeper MAY confirm it (section 6.6). An owner is <dfn|ended> when its key log has an ending version, or is forked (below).

  <strong|Forks of a key log.> Two different versions of a key log with the same number, each signed by <verbatim|threshold> keys of the version before, are a <dfn|fork of the key log>; that number, the number of the first differing versions, is the <dfn|fork point>. Whoever holds <verbatim|threshold> keys of the version before can make one. The format cannot tell which side is the owner's: the versions each side holds stay versions of the key log, and signatures naming them stay good, but the owner is treated as ended at the fork point, and no archive that knows the fork adds a version of the key log after it; an archive whose copy stops before the fork point records every side as evidence (below) and adds none. Two successors named on two sides of a fork are reported, and settled outside the format.

  <strong|Answering a thief.> Owner tools MUST show the owner a version of its key log that the owner did not make before signing anything. If someone else makes a version of its key log, ending or not, the owner signs a competing ending version of the same number, with its own <verbatim|successor> if any; this makes a fork, so that readers see that the owner has ended, and every successor named.

  <strong|Evidence of forks.> An archive holds one copy of each key log, since identifiers are unique in a storage root (section 4). When it learns of a fork, it keeps the side it holds, and records the first differing version of each other side in the owner object's extension folder, under <verbatim|extensions/opensheaf-witnesses/fork/\<less\>n\<gtr\>/\<less\>d\<gtr\>/>, where <verbatim|\<less\>n\<gtr\>> is that version (<verbatim|v3>) and <verbatim|\<less\>d\<gtr\>> the first 16 characters of the lowercase base32 (RFC 4648, without padding) SHA-256 digest of its inventory file. It records, byte for byte, the inventory file, its checksum file, its <verbatim|keys.json> (checked against the inventory), and its signature files with the witnesses beside them, so that readers holding one side see the fork, and whether the other side ended and names a successor. A fork of a line is reported, not recorded (section 7).

  <subsection*|6.4 After an end or a fork><label|64-after-an-end-or-a-fork>

  The signatures of an ended owner stay good, since the format does not date signatures; but versions signed after a key was exposed cannot be told from a thief's, so readers trust the owner's history only as far as other evidence goes: copies held before, the pins of collections (section 8), timestamps (the <hlink|timestamps extension|opensheaf-timestamps-0.1.tm>).

  An archive that knows an owner is ended adds that owner's key log up to and including the end (for a fork, up to the fork point on the side it keeps, with the evidence of the other sides), and takes that owner's lines only from copies found elsewhere, never as new deposits; section 7 gives the rule for adding their versions. The owner's work continues under its successor, by branches of its versions (section 9). Resolvers and verifiers report ended owners and their successors (sections 12 and 14).

  <subsection*|6.5 Key logs travel with the objects they sign><label|65-key-logs-travel-with-the-objects-they-sign>

  A key log checks itself from its owner name: the genesis record of its first version lists the first keys, and each later version is signed by the keys of the one before. A copy from any source is therefore as good as the original, and a line can be checked without trusting any host, also after the archives that served it have gone.

  Every copy of an object, in any archive, MUST hold beside it, as owner objects in the same storage root at their paths (section 3.2), the key logs of the owner of its line and, for a branch, of the owner of each parent whose signatures its evidence holds, in <verbatim|parent.signatures/> and at every level of <verbatim|parent.chain/> (section 9). Each is copied up to the latest version that whoever makes the copy knows, and at least up to the versions its signatures name; for a forked key log, the side the archive keeps, with the evidence of the fork. The key logs of third parties whose witnesses a copy holds (section 7) MAY be copied too. Key logs are never copied into an object's content. An archive MUST keep an owner object as long as it keeps an object whose signatures need it, unless the owner object is itself taken down; a tombstone then stands in for it, and a takedown of a line leaves its owner objects in place (section 13). An owner object MAY also be copied on its own, to keep a fresher copy of its key log.

  Of two copies of a key log, either one extends the other, and readers use the longer, or they fork (section 6.3). No one can prove offline that a key log is complete: a copy that stops early may hide that the owner has ended.

  <strong|Moving.> An owner moving to another archive copies its owner object there, with the lines it wants to keep there, and continues its lines in the new archive: the same owner and the same lines, not branches. The old copies stay valid where they are, as older copies of the same lines (section 7). In the owner-name layout this is one folder (section 3.2).

  <subsection*|6.6 Keepers><label|66-keepers>

  An owner MAY name, in <verbatim|keeper> of its key log, the person or institution who answers for it: an ORCID iD (<verbatim|https://orcid.org/...>) or a domain written as <verbatim|https://\<less\>domain\<gtr\>/>. The keeper MAY confirm it, in a place only the keeper controls: a link naming the owner in its ORCID record, or the file <verbatim|https://\<less\>domain\<gtr\>/.well-known/opensheaf> on its domain, a JSON object with <verbatim|format> <verbatim|"opensheaf-keeper/0.1">, <verbatim|owners>, the owner names it answers for, and OPTIONALLY <verbatim|successors>, an object mapping owner names it answers for to their successors (on ORCID, a link naming both). A successor the keeper names confirms the owner's own <verbatim|successor>; for an owner that cannot sign any more (every key lost), the keeper MAY name one alone, which is reported as named by the keeper, and does not end the owner.

  When a keeper is named, a verifier MAY check both directions, and reports the link as confirmed, claimed only (the keeper does not confirm it) or absent. A confirmation is read as it is now: a keeper who withdraws it ends the link, and what the owner signed stays authentic. The link says who answers for an owner, not who owns its lines, which only its keys decide, nor who wrote its documents, which <verbatim|creators> in <verbatim|datacite.json> say (#41). The keeper's other roles, in takedowns and for privacy, are in sections 13 and 15.

  <strong|Open questions.>

  <\itemize>
    <item>The field names of <verbatim|keys.json> (#55).

    <item>Whether owners should survive the exposure of a key (revocation dated by trusted time, transparency logs), which the core leaves to ending the owner (#55; <verbatim|drafts/keys-and-forks.md> on <verbatim|main>).

    <item>The form of a keeper's confirmation on ORCID, which depends on an <verbatim|https> form of <verbatim|sheaf:\<less\>owner\<gtr\>>, and so on the gateway (section 12; #13, #35).
  </itemize>

  <section*|7. Lines and signatures><label|7-lines-and-signatures>

  A <dfn|line> is the history of a work as decided by one owner, identified by the pair (name, owner) and so by the identifier <verbatim|sheaf:\<less\>name\<gtr\>:\<less\>owner\<gtr\>> (section 4). Its object versions form a single sequence, signed by its owner. <strong|A line is its signed versions, wherever they are stored>: in an archive where its owner writes, in a mirror (section 11), in any other archive. Lines of other owners with the same genesis record are branches (section 9). An owner's key log is the line of its owner object (section 6).

  <subsection*|7.1 Signing><label|71-signing>

  Every sealed object version of a line MUST be signed by its owner when it is made: by at least <verbatim|threshold> distinct keys of one version of the owner's key log, <verbatim|threshold> being that version's, each key signing in its own signature file (section 7.2), which names that key-log version. The key-log version named SHOULD be the latest its signer knows. A signature is judged against the key-log version it names alone (section 6.1), and nothing is ever signed again. An owner MAY add signatures to a version later, with keys that have not signed it. Versions of a key log are signed in the same way, by the keys of the version before, or for the first version by its own (section 6.1).

  <subsection*|7.2 Witnesses and signature files><label|72-witnesses-and-signature-files>

  A <dfn|witness> is evidence about an object version made after it: a signature, a timestamp, an external deposit (appendix A), a software archive snapshot. The witnesses kept with an object are in its <dfn|witness folder>, the OCFL object extension folder <verbatim|extensions/opensheaf-witnesses/> (not yet registered with OCFL, so validators may warn), which is part of no version, is not covered by the inventory digests, and travels with the object. Witnesses MAY be added at any time, by the owner of the line or by others; they are kept, never re-serialised or replaced once made, since some (timestamps) are made of their bytes, and MUST NOT be removed except by a takedown (section 13).

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

  <strong|Other witnesses.> The <hlink|timestamps extension|opensheaf-timestamps-0.1.tm> keeps timestamps of signature files beside them, dates that readers may weigh; it changes no status. The witness folder of an owner object also holds the evidence of forks of its key log (section 6.3); the parent signatures a branch carries are in its content (section 9).

  <strong|Files that are not witnesses.> A file of the witness folder that is not a witness (a stray file, a malformed or invalid signature file) is ignored, reported, never fatal, and kept; a file a reader does not recognise, stray or of an extension it does not know, is reported as an unknown file, not as an error: a host cannot break a version by adding a file. A copy MAY leave such files out (section 11).

  <subsection*|7.3 Statuses><label|73-statuses>

  A signature file is:

  <\itemize>
    <item><dfn|invalid> when it is malformed; its name does not match the digest of its key; its signature does not verify; its <verbatim|object>, <verbatim|version> and <verbatim|inventorySha512> are not those of the version whose folder holds it (the digest also as its checksum file states it; in <verbatim|parent.signatures/>, those of the parent version, section 9); its <verbatim|signer> is not the line's owner; the reader reaches the key-log version named, with that digest, and the key is not in its <verbatim|keys>; or the version named follows one with <verbatim|ended>, or, for a signature of a line, has <verbatim|ended> itself (section 6.3);

    <item><dfn|unchecked> when it is not invalid but the reader cannot reach the key-log version it names, with that digest (the key log is absent, taken down, or shorter, or the reader holds another version of that number, which verifiers report as a sign of a fork of the key log, section 6.3); nothing is added on such signatures (section 7.5);

    <item>otherwise <dfn|good>, for ever: later versions of the key log, an end or a fork never change it.
  </itemize>

  A version of a key log is <dfn|signed> when at least <verbatim|threshold> distinct keys of the version before (for the first version, of itself), <verbatim|threshold> being that version's, sign it with good signature files. Key logs are read version by version from the first, and are never vouched for (below): each version is checked with the keys of the one before; a version after one with <verbatim|ended> is not a version of the key log, and at a fork the versions each side holds stay versions (section 6.3).

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

  <strong|Ended owners.> For an owner that has ended, as far as the archive knows (section 6.3), the archive takes its lines only from copies found elsewhere, never as new deposits: it MAY copy a line, or extend one it holds, up to the latest signed version of a copy that agrees with it, since holding earlier versions is no reason to trust later ones less or more; when the copies found fork, it takes only the versions they share, and reports the fork. Readers weigh these versions as they weigh that owner's history (section 6.4). The key log itself is added as section 6.4 says.

  <strong|Versions held stay.> Nothing that a host or a thief can produce leads to removing a version an archive holds; only a takedown does (section 13). A version let in against this section that is not signed is reported, and never shown as a version of the line. Since OCFL versions cannot be skipped, the owner's own version of that number can then never be added there: that archive's copy is one side of a fork of the line, and the owner continues the line in another archive.

  <subsection*|7.6 Integrity><label|76-integrity>

  Integrity rests on OCFL digests: every file is fixed by its SHA-512 digest in the inventory, every inventory by its checksum file, and every member of a collection by a pin (sections 4 and 8). Digests show that files were not changed, signatures who made them; neither shows when (section 7.2).

  <strong|Open questions.>

  <\itemize>
    <item>The field names and the format of signature files (#55).

    <item>Whether owners should survive the exposure of a key (revocation dated by trusted time), which the core leaves to ending the owner (#55; section 6).
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

  <strong|An archive's collections.> An archive has no identity of its own (section 3); an archive that makes collections does so as an owner, with a key log like any other (section 6). Its <dfn|main catalogue>, named by <verbatim|mainCollection> in its discovery document (section 3.1), is a catalogue of the documents of the lines its owners write in the archive, not of the copies it holds. It MAY also keep a catalogue of the lines it holds as copies (section 11). A selection is kept by the owner of the body that vets (a journal, a review journal), which also owns the accepted copies the selection keeps (section 9).

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

  A withdrawn member stays, and presentations show the withdrawal (section 13). Presentations show the current version of each member as read from the history of the version pinned (section 4.2), not from later versions of its line: a pin that is not followed is the curator's choice.

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

    <item><strong|removed>, when the line is taken down (section 13).
  </itemize>

  <subsection*|8.6 Description and rights><label|86-description-and-rights>

  <strong|Description.> A collection version's <verbatim|datacite.json> (section 4.4) has <verbatim|resourceTypeGeneral> <verbatim|Collection>, and MUST have in <verbatim|relatedIdentifiers> a <verbatim|HasPart> relation to the version DOI of each member of a catalogue (its <verbatim|doi>) and of each revision of a selection (the revision's <verbatim|doi>) that has one; members without a DOI are listed only in <verbatim|members.json>. Members never name the collections that include them (section 4.4).

  <strong|Document versions.> A collection makes a new document version exactly when its member list changes (section 4.2); <verbatim|object.json> of a collection has none of the fields of a document (section 4.3).

  <strong|Rights.> A collection version holds only metadata, placed under CC0 (section 15), and its <verbatim|rightsList> SHOULD say so. The licence of a collection never extends to its members.

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

  <strong|Ended owners.> A branch point stays confirmed when its parent's owner ends or its key log forks afterwards, since signatures stay good; readers weigh it as they weigh that owner's history (section 6.4). A signature naming an ending version is invalid (section 7.3), and cannot sign a parent version.

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

  <strong|Rights.> A branch needs only the right to redistribute its parent versions, and the files it copies keep their licence; a copy of the parent's line beside it needs the right to redistribute every version copied (section 11). The evidence is metadata, under CC0 (section 15).

  <strong|Open questions.>

  <\itemize>
    <item>The numbering of document versions on a branch: continued from the branch point (provisional), or numbered from it (3.1, 3.2), which makes <verbatim|documentVersion> more than an integer; <verbatim|/v\<less\>n\<gtr\>> of a <verbatim|sheaf:> URI follows it (#57).

    <item>Moving a branch point when the branch has files of its own (of its notes, a withdrawal, a version of record): probably a merge keeping both, with evidence that tells them apart (#57).

    <item>The field and folder names of the evidence (#55).
  </itemize>

  <section*|Plan of the rebuilt text><label|plan-of-the-rebuilt-text>

  Each part is rebuilt in turn, from the reference text and an audit of the concept, and agreed before the next. Sections 1 to 9 are rebuilt; the others are planned as follows, and read meanwhile in the reference text.

  10. Drafts and sealing. 11. Copies and mirrors (moving an owner is in section 6.5). 12. Identifiers: <verbatim|sheaf:> URIs, resolution, indexes. 13. Withdrawal, takedown and tombstones. 14. Verification. 15. Security, privacy and rights (with: after a fork of a line, whether to end is the owner's call). 16. Versioning of this specification, and changelog.

  Appendices (the worked key log of appendix C creates its owner with two keys from v1): A. profiles (Zenodo, TeXmacs, website); B. JSON Schemas (with the new keeper schema); C. examples; D. rationale; E. references.

</body>

<\initial>
  <\collection>
    <associate|page-medium|paper>
  </collection>
</initial>
