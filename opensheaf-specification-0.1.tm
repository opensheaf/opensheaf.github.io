<TeXmacs|2.1.5>

<style|<tuple|notes|notes-meta>>

<\body>
  <notes-header>

  <chapter*|OpenSheaf: an open format for document archives and collections>

  <notes-abstract|Specification, version 0.1 (draft), 18 November 2026. OpenSheaf is a common, open format for archives of scholarly documents and for collections of them, built on the Oxford Common File Layout (OCFL 1.1) and the DataCite Metadata Schema (4.7). This version is experimental and may change in incompatible ways before version 1.0. The text is licensed under CC BY-SA 4.0; the JSON Schemas are dedicated to the public domain under CC0 1.0.>

  <os-alert|warning|Warning.|<strong|Draft.> This version is a draft. Until version 1.0, any revision may change the format in incompatible ways, and archives and collections made now may have to be rebuilt or migrated. Do not rely on it yet for anything you cannot redo. Changes are listed in the changelog (section 17) and discussed in the <hlink|issues|https://github.com/opensheaf/opensheaf.github.io/issues>.>

  <section*|1. Introduction (non-normative)><label|1-introduction-non-normative>

  OpenSheaf is meant as a lean alternative to arXiv and to the usual publication infrastructure. Any author, group or institution can keep an archive of its documents as plain files, served as a static website, checkable by anyone, and composable with other archives:

  <\itemize>
    <item><strong|Sources, not only PDFs.> A deposit keeps the sources of a document with its renditions (a PDF, typically), so that the archive can be read as a website and in the authoring tool.

    <item><strong|Fixed versions.> Every version of every document is fixed by content hashes and never changes once deposited. Corrections are new versions, and the history can be verified from the files alone.

    <item><strong|Standards, not inventions.> Storage follows OCFL 1.1 and description follows DataCite 4.7. This specification only defines what these leave open: discovery of an archive, collections, provenance, withdrawal, and the profiles for external services and tools.

    <item><strong|Composable collections.> A collection is itself a versioned object. It can include documents and collections of other archives, pinned by digest, so that selections (by a seminar, an editorial board, a reading list) compose without copying.

    <item><strong|External services are optional.> Archives may deposit their documents with a DOI service such as Zenodo, publish them as a website, and keep their files in git; none of this is required by the core of the format.
  </itemize>

  Answers to common questions about the design are collected in the <hlink|FAQ|https://github.com/opensheaf/opensheaf.github.io/blob/main/FAQ.md>.

  The name: a sheaf is a bundle of papers and, in mathematics, the structure in which local pieces glue into a whole, as archives kept and verified separately compose into collections. The home of the format is <verbatim|https://opensheaf.org/>. The first OpenSheaf archive is <verbatim|https://mgubi.org/papers/>; its values appear in the examples.

  <section*|2. Conventions><label|2-conventions>

  The key words MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, RECOMMENDED, NOT RECOMMENDED, MAY and OPTIONAL in this document are to be interpreted as described in BCP 14 (RFC 2119 and RFC 8174) when, and only when, they appear in all capitals.

  Sections marked non-normative, examples, notes and the appendices marked as such are informative. JSON means RFC 8259 JSON encoded in UTF-8 without a byte order mark. URLs are absolute unless stated otherwise; a relative URL in a JSON file is resolved against the URL of that file.

  <section*|3. Terminology><label|3-terminology>

  <\itemize>
    <item><dfn|Archive>: a host of lines: one storage root and one discovery document, served at a base URL, holding the objects of any number of owners, the lines they write there and copies of lines kept elsewhere. With the proposal of section 6.5, an archive has no identity of its own: it is found at its base URL, and owns nothing by hosting it (sections 6.2 and 6.5).

    <item><dfn|Base URL>: the URL at which an archive is currently served, ending with <verbatim|/>; its discovery document is at <verbatim|\<less\>base URL\<gtr\>opensheaf.json>. It is a location, not an identity, and may change.

    <item><dfn|Storage root>: an OCFL 1.1 storage root holding the objects of the archive.

    <item><dfn|Object>: an OCFL object. Its <dfn|kind> is <verbatim|document>, <verbatim|collection> or (proposal, section 6.5) <verbatim|owner>.

    <item><dfn|Document>: an object holding one scholarly work (an article, notes, a thesis, a book) with its sources and renditions.

    <item><dfn|Collection>: an object holding a list of members. A collection is a catalogue or a selection (section 10.1).

    <item><dfn|Catalogue>: a collection that keeps objects whole, impartial about their versions: each member pins an object with all its versions, and may follow it as it grows. The main collection of an archive's documents, and the list of lines an archive keeps copies of, both kept by the archive acting as an owner, are catalogues.

    <item><dfn|Selection>: a collection that vets particular revisions of documents (a journal, a digest, a review journal, a reading list): each member pins a revision set, and earlier or later versions are not part of the selection unless its curator adds them, by a new version of the selection.

    <item><dfn|Revision>: a document version, as vetted by a selection, pinned by the object version that held it when it was vetted.

    <item><dfn|Revision set>: the revisions of one document vetted by a selection (usually one; more after a correction).

    <item><dfn|Mirror>: a copy of a line, whole and byte for byte, with the key logs of its signers, kept in an archive where its owner does not write it (section 10.4).

    <item><dfn|Accepted copy>: a branch kept by the owner of a selection, starting from a revision it vetted (section 10.5).

    <item><dfn|Draft>: an object of the reserved owner <verbatim|draft>, kept by one archive (at <verbatim|draft/\<less\>id\<gtr\>/> in the owner-name layout): never signed, pinned or copied out of its archive, and the only object that MAY be rewritten or deleted; sealing it makes a new object, the first version of a line (section 6.5).

    <item><dfn|Sealing>: making the first version of a line from a work: a new object holding the genesis record and the work, signed by its owner, made at the owner's request before the work first leaves the owner's hands (section 6.5).

    <item><dfn|Genesis record>: the file <verbatim|genesis.json>, written when a work is sealed or an owner is created, and kept unchanged in all later versions and in branches; its seeded digest is the name of the work or of the owner (section 6.5).

    <item><dfn|Name>: 52 characters of base32 from the digest of a genesis record, the same in every archive, copy and branch, except a branch renamed after a clash, which takes another name of the same genesis record (section 6.5).

    <item><dfn|Owner>: a keyed identity (a person, a group, an institution) that decides the versions of its lines and signs them, wherever they are stored. It is an object of kind <verbatim|owner>, whose versions are its key log (section 6.5).

    <item><dfn|Owner name>: the name of an owner's genesis record, which names the owner in genesis records, in <verbatim|object.json> and in <verbatim|sheaf:> URIs (sections 6.5 and 6.6).

    <item><dfn|Key log>: the versions of an owner object, each listing the owner's keys and the threshold of signatures it requires; the first is signed by its own keys, which its genesis record fixes, and each later one by the keys of the one before (section 6.5).

    <item><dfn|Signature file>: a witness holding an owner's signature of an object version, naming the version of the owner's key log it relies on (section 13.2).

    <item><dfn|Signed version>: a version of a line signed by its owner with good signatures, or extended by a later signed version; readers rely only on signed versions, and the latest in a copy is its current state (section 13.2).

    <item><dfn|Ended owner>: an owner whose key log ends, by a last version it signs after a key may have been exposed, or by a fork; its signatures stay good, archives take its lines only from copies, never as new deposits, and its work continues under a successor (section 6.5).

    <item><dfn|Originator>: the owner named in the genesis record of a work, whose line is the origin of the name and has no parent (section 6.5).

    <item><dfn|Line>: the history of a work as decided by one owner, identified by the pair (name, owner); its object versions form a single sequence, signed by the owner, and it is the same line wherever its copies are stored (section 6.5).

    <item><dfn|Branch>: a line of another owner continuing a work from one of its versions, the branch point: a new object holding the branch point, with the evidence of the parent version, and its own versions; the parent's earlier versions, if they are kept, are kept as a copy of the parent's line (section 10.5).

    <item><dfn|Label>: a short readable name that an archive gives a line it holds, in its discovery document; not an identifier (section 6.3).

    <item><dfn|Object version>: an OCFL version of an object (<verbatim|v1>, <verbatim|v2>, ...). It changes at every change of the object.

    <item><dfn|Document version>: the version of the work, a positive integer numbered by the owner of the line (for a draft, by whoever keeps it), in <verbatim|object.json> and <verbatim|datacite.json>. It changes exactly when the document's own files change (section 7.3).

    <item><dfn|Description-only version>: an object version that holds an existing document version with its files unchanged, changing only the description, the state or the notices of the object (section 7.3).

    <item><dfn|History>: the order of a document's versions in the history of the work (section 7.3).

    <item><dfn|Current version>: the document version to which readers are directed: the last in the history.

    <item><dfn|Note>: a short text, a file of the content, or both, as used for change notes, notices and withdrawals (section 9).

    <item><dfn|Member>: an entry of a collection: an object (in a catalogue) or a revision set of a document (in a selection), of any line.

    <item><dfn|Pin>: the pair (object version, SHA-512 digest of that version's inventory file).

    <item><dfn|Rendition>: a file produced from the sources and deposited with them (a PDF, an EPUB).

    <item><dfn|Presentation>: files generated from the archive for readers (web pages, indexes, HTML versions of documents). It is never authoritative.

    <item><dfn|Custodian>: anyone who keeps copies of other owners' lines, or indexes of them (section 6.6, #39).

    <item><dfn|Resolver>: a program that finds and checks the object versions named by a <verbatim|sheaf:> URI (section 6.6); a <dfn|gateway> is a resolver serving web links.

    <item><dfn|Witness>: an independent copy or proof: a signature, a timestamp, an external deposit, a software archive snapshot.

    <item><dfn|Verifier>: a program that checks an archive or a collection against this specification.
  </itemize>

  <section*|4. Conformance><label|4-conformance>

  This specification defines the following conformance classes. An archive, object or program conforms to a class if it satisfies every MUST and MUST NOT of the sections listed for it.

  <\itemize>
    <item><strong|OpenSheaf archive:> sections 5 to 13 and 16 (section 10 for the collections it contains).

    <item><strong|OpenSheaf collection:> section 10, in addition to the requirements on objects in sections 7 to 9.

    <item><strong|OpenSheaf verifier:> sections 12 (as a reader), 14 and 15. Tools that build presentations follow the requirements on presentations in sections 11.1, 15 and appendix C.

    <item><strong|OpenSheaf resolver> (proposal): section 6.6, sections 6.5 and 13.2 for checking signatures and key logs, and section 6.4 for fetching; a gateway also follows the requirements on gateways in section 6.6.

    <item><strong|Profiles>, optional: an archive MAY additionally conform to the Zenodo binding (appendix A), the TeXmacs profile (appendix B) and the website profile (appendix C). A conforming archive MUST state in its discovery document which profiles it follows.

    <item><strong|Extensions>, optional: an extension is a specification published separately from this one, named by a URI (RECOMMENDED: the <verbatim|https> URL at which it is published), that records in <verbatim|object.json> what this specification leaves open, so that tools aware of it can act on it (for instance relations between documents that tools must follow when they copy or verify them). An object version records the data of an extension under <verbatim|extensions> in its <verbatim|object.json> (section 9), keyed by the name of the extension; the discovery document SHOULD list the extensions its objects use (section 6.1). Extensions MUST NOT change the meaning of what this specification defines, nor relax its requirements: an archive is conforming, and its objects and collections are read and verified, without knowing any of its extensions. Readers ignore extensions they do not know, as they ignore unknown properties (section 12). The data of an extension is part of the object version, covered by its inventory like the rest of <verbatim|object.json>, so pins fix it too. An extension that concerns an owner's key log records its data, in the same way, under <verbatim|extensions> in <verbatim|keys.json> (section 6.5), where the owner's signatures of the key-log version fix it; the <hlink|timestamps extension|opensheaf-timestamps-0.1.tm> is one.
  </itemize>

  The JSON files defined here (<verbatim|opensheaf.json>, <verbatim|object.json>, <verbatim|members.json>, <verbatim|genesis.json>, <verbatim|keys.json>, the signature files of section 13.2, the index files and <verbatim|indexes.json> of section 6.6) MUST validate against the JSON Schemas of appendix D for their declared format version.

  <section*|5. Layout><label|5-layout>

  An archive consists of:

  <\itemize>
    <item><strong|A discovery document>, <verbatim|opensheaf.json>, at its base URL (section 6). It is REQUIRED.

    <item><strong|A storage root>, REQUIRED, conforming to OCFL 1.1, at a URL given by the discovery document. It MUST contain <verbatim|ocfl_layout.json>, whose <verbatim|extension> MUST be the storage layout named by <verbatim|storageLayout> in the discovery document (section 6.1), one of two: <verbatim|opensheaf-owner-name-storage-layout>, the default, defined below; or, for large archives, the OCFL extension <verbatim|0003-hash-and-id-n-tuple-storage-layout> with its default parameters (<verbatim|digestAlgorithm> <verbatim|sha256>, <verbatim|tupleSize> 3, <verbatim|numberOfTuples> 3; its configuration file <verbatim|extensions/0003-hash-and-id-n-tuple-storage-layout/config.json>, if present, MUST NOT set other values, and a parameter it omits takes its default), so that an object is at <verbatim|\<less\>storage root URL\<gtr\>\<less\>t1\<gtr\>/\<less\>t2\<gtr\>/\<less\>t3\<gtr\>/\<less\>encoded id\<gtr\>/>, where <verbatim|\<less\>t1\<gtr\>>, <verbatim|\<less\>t2\<gtr\>> and <verbatim|\<less\>t3\<gtr\>> are the first three groups of three characters of the lowercase hexadecimal SHA-256 digest of the identifier (as UTF-8), and <verbatim|\<less\>encoded id\<gtr\>> is the identifier encoded as that extension says: every character other than <verbatim|A-Z>, <verbatim|a-z>, <verbatim|0-9>, <verbatim|-> and <verbatim|_> percent-encoded in lowercase hexadecimal, and, when the result is longer than 100 characters, its first 100 characters followed by <verbatim|-> and the full digest. Identifiers of lines (<verbatim|sheaf:\<less\>name\<gtr\>:\<less\>owner\<gtr\>>, 111 characters, 115 once encoded) are always shortened so: the line <verbatim|sheaf:72kqjazmz3pvvf4a2t4wzefimdzwrkxwum2ta4b73ikqude7dljq:zgjup5lqdg4kec2lyvdq2f3d55b6wyouvji5wwbregthijfnsu3a> of appendix E is at <verbatim|c3e/a2b/045/sheaf%3a72kqjazmz3pvvf4a2t4wzefimdzwrkxwum2ta4b73ikqude7dljq%3azgjup5lqdg4kec2lyvdq2f3d55b6wyouvji5w-c3ea2b045d0d7a97e38820cbe32a544877df289e66d786dad722a14811662921/>. The path is computed from the identifier, so readers need not decode it. Archives SHOULD use the owner-name layout unless their size makes one folder per owner, or per name, impractical (for instance from tens of thousands of lines, or fewer in a git repository; appendix F). The layout is chosen when the archive is created: changing it keeps every pin valid, since clients compute paths from <verbatim|storageLayout>, but moves every object and so changes every URL into the storage root (the <verbatim|url> of a branch's <verbatim|parent>, section 10.5, or a link in a document), so archives SHOULD NOT change it. The storage root MAY contain, as loose files allowed by OCFL, a copy of the OCFL specification and of this specification.

    <item><strong|Witnesses>, OPTIONAL except for the signatures that section 13.2 requires: signatures of object versions, and timestamp proofs of signature files, in each object's extension folder <verbatim|extensions/opensheaf-witnesses/> (section 13.2).

    <item><strong|Indexes>, RECOMMENDED: <verbatim|names/>, <verbatim|owners/> and <verbatim|sha512/> next to the discovery document (section 6.6, proposal).

    <item><strong|Presentation files>, OPTIONAL, anywhere outside the storage root and the indexes (appendix C).
  </itemize>

  <strong|The owner-name layout (proposal).> <verbatim|opensheaf-owner-name-storage-layout> is a storage layout extension defined by this specification, not yet registered with OCFL, so validators may warn about it. It places the object whose identifier is <verbatim|sheaf:\<less\>name\<gtr\>:\<less\>owner\<gtr\>> (section 6.3) at <verbatim|\<less\>storage root URL\<gtr\>\<less\>owner\<gtr\>/\<less\>name\<gtr\>/>, and a draft, whose identifier is <verbatim|sheaf:draft:\<less\>id\<gtr\>> (section 6.3), at <verbatim|\<less\>storage root URL\<gtr\>draft/\<less\>id\<gtr\>/>. An owner object, whose line is <verbatim|sheaf:\<less\>owner\<gtr\>:\<less\>owner\<gtr\>>, is thus at <verbatim|\<less\>owner\<gtr\>/\<less\>owner\<gtr\>/>, so that the folder of an owner holds its key log and every line of that owner in the archive, and an owner moving to another archive (section 6.5) copies one folder. An identifier of neither form is an error. It has no parameters and no configuration file; <verbatim|ocfl_layout.json> names it with a <verbatim|description> (<verbatim|"Lines at \<less\>owner\<gtr\>/\<less\>name\<gtr\>, drafts at draft/\<less\>id\<gtr\>">).

  Because OCFL allows inside a storage root only the folders that hold objects (the objects themselves and the folders above them that the layout gives: the folders of owners and <verbatim|draft/>, or the folders of the hash) and extensions, the storage root SHOULD be a dedicated folder (by convention <verbatim|ocfl/>), and presentation files MUST NOT be placed inside it.

  All files of the discovery document, the storage root and the indexes (if used) MUST be served byte for byte, as stored: no conversion of line endings or character sets, no compression that changes the bytes delivered after decoding. Archives kept in git SHOULD mark these files as binary (for instance with <verbatim|.gitattributes> lines <verbatim|ocfl/** -text>, <verbatim|opensheaf.json -text> and, where used, <verbatim|names/** -text>, <verbatim|owners/** -text> and <verbatim|sha512/** -text>). Archives SHOULD be served over HTTPS and SHOULD allow cross-origin requests to these files (<verbatim|Access-Control-Allow-Origin: *>), so that tools running in a browser can resolve members.

  An archive MAY be kept in git and served by any static web server (GitHub Pages, object storage, a university server). The companion document <hlink|OpenSheaf archives in git|opensheaf-git-0.1.tm>, outside this specification, says how to keep, publish and copy an archive in git without changing its bytes.

  <section*|6. Discovery and identity><label|6-discovery-and-identity>

  <subsection*|6.1 The discovery document><label|61-the-discovery-document>

  The discovery document is the JSON file <verbatim|opensheaf.json> at the base URL of the archive. It MUST contain:

  <\itemize>
    <item><verbatim|format>: <verbatim|"opensheaf-archive/0.1">;

    <item><verbatim|specification>: the version of this specification the archive follows, <verbatim|"0.1">;

    <item><verbatim|name>: a human-readable name of the archive;

    <item><verbatim|storageRoot>: the URL of the storage root, ending with <verbatim|/> (relative URLs are allowed);

    <item><verbatim|storageLayout>: the storage layout of the storage root, <verbatim|"opensheaf-owner-name-storage-layout"> or <verbatim|"0003-hash-and-id-n-tuple-storage-layout"> (section 5);

    <item><verbatim|objects>: the list of all objects in the storage root except drafts, each with <verbatim|id> (its identifier, section 6.3), <verbatim|kind>, <verbatim|head> (the head object version), <verbatim|inventorySha512> (the SHA-512 digest of the head inventory, as written in its checksum file) and <verbatim|status> (<verbatim|active> or <verbatim|withdrawn>, section 11); an object with a genesis record (section 6.5) also has its <verbatim|name> and <verbatim|owner>, and MAY have a <verbatim|label> (section 6.3).
  </itemize>

  It MUST also contain <verbatim|profiles>, the list of profiles followed, from <verbatim|zenodo>, <verbatim|texmacs>, <verbatim|website> (an empty list if none). It SHOULD contain <verbatim|mainCollection> (the identifier of the collection that lists the archive's documents), <verbatim|contact> (a URI) and, if its objects use extensions, <verbatim|extensions> (their names, section 4). It MAY contain <verbatim|drafts> (drafts it chooses to show as unfinished work, each with <verbatim|id>, <verbatim|kind> and <verbatim|head>, on which nothing may rely, section 6.5; or none), <verbatim|owners> (the owner names of the owners it hosts, section 6.5), <verbatim|mirrors> (base URLs of complete copies of the archive), <verbatim|tombstones> (section 11.3), <verbatim|indexes> (the indexes kept, each with the length of its prefix, section 6.6) and <verbatim|feed> (the URL of an Atom feed of new object versions).

  The discovery document is mutable: it is rewritten whenever an object is added or changed. It is a map, not a witness: what it states about objects (<verbatim|objects>: kinds, head versions, digests, status, names and owners) MUST be verifiable from the storage root. It is a convenient list of the lines an archive holds, not a guarantee that an owner has no lines elsewhere (section 6.5). Digests are written in lowercase hexadecimal, here and in every file defined by this specification.

  <subsection*|6.2 Archives and their addresses><label|62-archives-and-their-addresses>

  An archive is found at its base URL. With the proposal of section 6.5, an archive has no identifier of its own: it hosts lines, which belong to their owners, and is not named in their files (#52). Its base URL, the <verbatim|mirrors> of its discovery document, and the locations given in collection members and <verbatim|sheaf:> URIs (sections 6.4 and 6.6) are locations: hints of where copies are expected, which need no signature, since every copy fetched from them is checked against pins and signatures. A wrong or stale location can give a reader nothing, or an older valid copy, never a forged one.

  An archive moving to another site copies its files (its discovery document, its storage root and its indexes); nothing in them changes, so every pin, signature and witness stays valid. Collections, indexes and resolvers learn the new base URL over time; meanwhile, copies found elsewhere stay valid.

  <subsection*|6.3 Object identifiers and labels><label|63-object-identifiers-and-labels>

  The identifier of an object (its OCFL <verbatim|id>) is its line, written as a <verbatim|sheaf:> URI with its owner part: <verbatim|sheaf:\<less\>name\<gtr\>:\<less\>owner\<gtr\>>, the name and owner that its <verbatim|object.json> records (section 6.5). For every sealed object (an originator's line, a branch, an owner object) this is the line itself: a branch is a new object, never a continuation of the parent's (section 10.5). Two objects of different lines never have the same identifier, in any archive, so an archive keeps the lines its owners write and copies of lines kept elsewhere side by side in one storage root. The identifier MUST be unique in the storage root; the identifier of a sealed object MUST NOT be reused, also after a takedown (a draft's may be, once the draft is gone). The kind of an object is given by its <verbatim|object.json>, never by its identifier.

  A draft (section 6.5) belongs to the reserved owner <verbatim|draft>, which is never a name or an owner name (those have 52 characters): its identifier is <verbatim|sheaf:draft:\<less\>id\<gtr\>>, where <verbatim|\<less\>id\<gtr\>> is chosen locally by the archive, MUST match the pattern of labels, <verbatim|^[a-z0-9]+(-[a-z0-9]+)*$>, and MUST be at most 64 characters long, so that the whole identifier has at most 76 characters; it MUST NOT be reused in the archive while the draft exists. It is a local identifier, never resolved and never written in a <verbatim|sheaf:> URI outside the archive (private archives and how drafts are shared are discussed in #29). A draft never becomes a line: sealing makes a new object (section 6.5).

  <strong|Labels.> An archive MAY give each line it holds a label, in <verbatim|objects> of its discovery document: a short readable name, matching <verbatim|^[a-z0-9]+(-[a-z0-9]+)*$>, at most 64 characters, unique among the labels of the discovery document, which its website MAY use for readable URLs. A label is not an identifier: it is the archive's choice, may be added or changed, and URLs built on it may break; permanent links use <verbatim|sheaf:> URIs (section 6.6). Labels SHOULD be short, readable and chosen by the depositor, and SHOULD NOT be derived mechanically from the title.

  <subsection*|6.4 Resolution><label|64-resolution>

  To fetch an object version of a member, a client:

  <\itemize>
    <item>reads the discovery document at a location of the member (one of its <verbatim|at>, section 10.2; all are equal, and a client tries them in any order) and fetches <verbatim|\<less\>storageRoot\<gtr\>\<less\>path\<gtr\>/\<less\>version\<gtr\>/inventory.json>, where <verbatim|\<less\>path\<gtr\>> is the path of the member's object, <verbatim|sheaf:\<less\>name\<gtr\>:\<less\>owner\<gtr\>> (section 6.3), given by the <verbatim|storageLayout> of that discovery document (section 5): <verbatim|\<less\>owner\<gtr\>/\<less\>name\<gtr\>>, or, in the hashed layout, the folders of the hash and the encoded, shortened identifier (section 5);

    <item>if this fails at every location of <verbatim|at>, tries the mirrors listed in those archives' discovery documents, each resolved through its own discovery document and layout, then MAY look the line up in indexes and resolvers (section 6.6);

    <item>if this fails, MAY use external copies: the files of an external record named in the version's <verbatim|object.json> (a DOI record), or a software archive snapshot (a SWHID).
  </itemize>

  To fetch the parent version of a branch (section 10.5, proposal), a client fetches <verbatim|inventory.json> at the <verbatim|url> of <verbatim|parent>; if this fails, or no <verbatim|url> is given, it looks for the parent's line as above and then for external copies. Whatever location it was fetched from, a parent version is the parent owner's when its signature holds (section 13.2), which a branch carries (section 10.5).

  Any copy whose bytes match the pinned digest is acceptable: integrity comes from the pin, not from the place; and a version without a digest is its owner's when its signatures hold, wherever it was found (section 6.5).

  <subsection*|6.5 Names, owners and lines><label|65-names-owners-and-lines>

  <os-alert|note|Note.|<strong|Proposal.> This section, and the sections it changes (3 to 5, 6.1 to 6.4, 7, 8.1, 9, 10.2 to 10.6, 11.3, 13.2, 14 to 16 and appendices D to F, with the FAQ, the use cases and the companion OpenSheaf archives in git), together with section 6.6, are a proposal on the branch <verbatim|proposal/identity> (PR #30), not yet agreed. It builds on the discussions of self-certifying names (#20), decentralised holding and keys (#13), private and draft objects (#29) and the evidence of accepted copies (#22); the revision follows #55 (owners are keyed identities with a key log; archives host their lines) and #52 (archives are hosts; identifiers from lines), which also settle #14 and #53.>

  A work has a name, independent of any archive, and each history of it an owner. The pair (name, owner) identifies a line: the history of the work as decided by that owner, made of object versions that the owner signs. <strong|A line is its signed versions, wherever they are stored>: in an archive where its owner writes, in a mirror, in any other archive. Lines of other owners with the same genesis record are branches (section 10.5). An archive hosts the lines of any number of owners, and owns nothing by hosting them (section 6.2).

  <strong|Genesis record.> When a work is sealed, at its owner's request, before a version of it first leaves its owner's hands (shared privately, for instance submitted to a journal, or published; #29), its owner writes the genesis record, the JSON file <verbatim|genesis.json> at the root of the content, with <verbatim|format> (<verbatim|"opensheaf-genesis/0.1">), <verbatim|kind> (<verbatim|document> or <verbatim|collection>, the <verbatim|kind> of the object), <verbatim|created> (the date and time, in UTC), <verbatim|originator> (the owner name of the owner of the first line) and <verbatim|nonce> (at least 128 bits from a cryptographically secure random generator, in lowercase hexadecimal). The genesis record of an owner (below) has <verbatim|kind> <verbatim|owner>, no <verbatim|originator>, and the owner's first <verbatim|keys> and <verbatim|threshold> (as in <verbatim|keys.json>, below), so that the owner name fixes the keys that can first sign for it; an owner object is its own originator. The genesis record MUST be part of every later object version of the object and of its branches, byte for byte. It contains neither its own name nor the object identifier, so that the name does not depend on itself. It MUST be written in UTF-8 without a byte order mark (section 2), and SHOULD have LF line ends; since the name is the digest of its bytes as stored, tools MUST NOT rewrite or re-serialise it, and need no canonical form to check it.

  <strong|Name.> The name of a work, or of an owner, is the SHA-256 digest of the seed <verbatim|opensheaf-name-0> (ASCII, followed by a line feed) followed by the bytes of <verbatim|genesis.json>, written in lowercase base32 (RFC 4648, without padding): 52 characters. The last character carries the last bit of the digest and, in its four remaining bits, the number k of the algorithm that made the name, from 0 to 15: algorithm k is the same with the seed <verbatim|opensheaf-name-\<less\>k\<gtr\>> (k in decimal), so that algorithm 0 gives a last character <verbatim|a> or <verbatim|q>. Names are made by algorithm 0, except a branch named by another algorithm to avoid a clash (below); names made by different algorithms never coincide. A later format version of the genesis record MAY use another hash function. Since RFC 4648 sets the four bits to zero, names are compared as strings and never decoded. Anyone holding a copy can compute it; it is unique without a registry in practice, since the record holds a random nonce; since a name is used to refer to objects, clashes are resolved where lines are made (below). <verbatim|object.json> records it as <verbatim|name>.

  <strong|Owners.> An owner is a keyed identity: a person, a group or an institution, which decides the versions of its lines and signs them. It is an object of kind <verbatim|owner> (section 7.5), whose genesis record names it: its <strong|owner name> is the name of that record, and is what genesis records (<verbatim|originator>), <verbatim|object.json> (<verbatim|owner>, and <verbatim|owner> in <verbatim|parent>) and <verbatim|sheaf:> URIs record. The line of an owner object is <verbatim|(owner name, owner name)>, and its object versions are the owner's <strong|key log>: each holds a file <verbatim|keys.json> with:

  <\itemize>
    <item><verbatim|format>: <verbatim|"opensheaf-keys/0.1">;

    <item><verbatim|keys>: the public keys of the owner, each an Ed25519 key written as a <verbatim|did:key> URI (W3C CCG, multibase base58btc, multicodec <verbatim|ed25519-pub>, code <verbatim|0xed>, written as the varint bytes <verbatim|0xed 0x01>); at least one;

    <item><verbatim|threshold>: the number of distinct keys of this version that must sign, a positive integer not greater than the number of keys;

    <item><verbatim|extensions>, OPTIONAL: the data of extensions concerning the key log (section 4), keyed by the names of the extensions, for instance the declaration of the <hlink|timestamps extension|opensheaf-timestamps-0.1.tm>;

    <item><verbatim|keeper>, OPTIONAL: <verbatim|https> URLs of the person or institution who answers for the owner (below);

    <item><verbatim|ended>, OPTIONAL: <verbatim|true> in the last version of the key log of an owner that ends (below);

    <item><verbatim|successor>, OPTIONAL, only with <verbatim|ended>: the owner name of the owner that continues its work.
  </itemize>

  The first version of the key log holds the genesis record and the first <verbatim|keys.json>, whose <verbatim|keys> (compared as a set: the same keys, in any order) and <verbatim|threshold> MUST be exactly those of the genesis record (it MAY add <verbatim|keeper> and <verbatim|extensions>). Its authority comes from the genesis record, whose digest is the owner name: no one can make another first version under that name without changing the keys it lists, and so the name. It is signed by <verbatim|threshold> of those keys, its signatures naming the first version itself in <verbatim|keyLog>. **Every later version vN+1 MUST be signed by at least <verbatim|threshold> distinct keys of vN, its signatures naming vN.** A key is added or retired, the threshold or the data of an extension changed, or the owner ended (below), by a new version; the owner name never changes. The field names of <verbatim|keys.json> are provisional (#55).

  <strong|Signing.> Every sealed object version of a line MUST be signed by its owner when it is made: one signature file for each key that signs (section 13.2), naming in <verbatim|keyLog> a version of the owner's key log, which SHOULD be the latest its signer knows. A signature is judged against the version it names alone, and stays good: adding or retiring keys, or changing the threshold, affects only the signatures naming that version or a later one, so nothing is ever signed again. An owner MAY add a signature to a version later, with a key that has not signed it. When a signature is good and a version is signed is defined once, in section 13.2; throughout this specification, the signatures of a version <strong|hold> when it is signed. Other files in the witness folder of a version (stray, malformed, or invalid signature files) are ignored, reported and kept: a host cannot break a version by adding a file.

  <strong|Choosing a threshold.> One <verbatim|threshold> governs the key log and every line of the owner, as in Radicle, where the threshold of an identity document also decides its canonical branch. It binds only the signatures naming its version: a version needs <verbatim|threshold> signatures naming one key-log version. Owners choose between two risks: a threshold of 1, with a spare key kept apart (on a hardware token, for instance), survives the loss of a key but not its theft; a threshold of 2 with three keys kept apart, from the first version of the key log, survives the loss of one key and the theft of one. Tools creating an owner SHOULD offer both, and SHOULD NOT create an owner with a single key, since losing every key of the latest version cannot be recovered. A second threshold, for lines alone, can be added later if needed.

  <strong|Retiring a key.> An owner retires a key it no longer uses (a replaced laptop, a member who leaves the group) by leaving it out of <verbatim|keys> in a new version of its key log; its signatures stay good. A retired key in someone else's hands still makes good signatures (above): <strong|an owner whose key may have been exposed (stolen, leaked, copied) MUST end> (below).

  <strong|A signed version vouches for its past.> In OCFL the inventory of a version records the digests of every file of every version before it (section 7.1), so a version signed directly by its owner vouches for every version it extends, whatever their own signatures: those versions are signed too, <strong|vouched for> rather than signed directly (section 13.2). Readers rely only on signed versions: the latest signed version of a copy gives the line's history, current version and status, for presentations, pins, collections and resolution, and versions after it that are not signed are never shown as versions of the line. <strong|Owner tools MUST show the owner> a version that a new version would extend and that is not signed, or a version of its key log that the owner did not make, before signing, so that an owner never takes a thief's version into its line unknowingly.

  <strong|Ending an owner.> An owner whose key may have been exposed ends: it signs, as usual, a last version of its key log with <verbatim|ended> <verbatim|true> and, OPTIONALLY, <verbatim|successor>, the owner name of a new owner that continues its work, which MUST differ from its own. The ending version only ends: no version of the key log follows it, and no signature of a line may name it (section 13.2); signatures made before it name earlier versions, and stay good. A successor is a hint, never followed automatically, which the keeper (below) MAY confirm. If someone else ends the owner with its keys, the owner signs a competing ending version of the same number, with its own <verbatim|successor> if any, which makes a fork (below).

  <strong|Forks of a key log.> Two different valid versions of a key log with the same number, each signed by <verbatim|threshold> keys of the version before, are a <strong|fork>, made by whoever holds <verbatim|threshold> keys of the version before. The core cannot tell which side is the owner's: the versions each side holds stay versions of the key log, and signatures naming them stay good, but no archive that knows the fork adds a version after the fork point, and the owner is treated as ended there (below). Two successors named on two sides of a fork are reported, and settled outside the format.

  <strong|After an end or a fork.> The owner's signatures stay good, since the core cannot date them; but versions signed after its key was exposed cannot be told apart from a thief's, so readers trust its history only as far as other evidence goes (copies held before, the pins of collections, timestamps, section 13.2). Archives that know the end or the fork take its lines only from copies, never as new deposits (below), and its work continues under its successor, by branches of its versions (section 10.5). A thief holding a key that is still current is the owner until found out: the format cannot prevent it, only make it visible; a threshold of 2 or more from the first version makes a theft harder (above). This is Radicle's answer, where a node's key is its identity and a compromised key means a new node.

  <strong|Evidence of forks.> An archive keeps one copy of each key log (section 6.3). When it learns of a fork, it keeps the side it holds, and records the first differing version of each other side in the owner object's extension folder, under <verbatim|extensions/opensheaf-witnesses/fork/\<less\>n\<gtr\>/\<less\>d\<gtr\>/>, where <verbatim|\<less\>n\<gtr\>> is that version (<verbatim|v3>) and <verbatim|\<less\>d\<gtr\>> the first 16 characters of the lowercase base32 (RFC 4648, without padding) SHA-256 digest of its inventory file: the inventory file, its checksum file, its <verbatim|keys.json> (checked against the inventory) and its signature files with the timestamp files beside them, byte for byte, so that readers who hold one side see the fork, and whether the other side ended and names a successor. A fork of a line is reported, not recorded.

  <strong|Key logs travel with the objects they sign.> A copy of an object, in any archive, MUST include, as owner objects in the same storage root (at their paths, section 5), the key logs of the owner of its line and, for a branch, of the owner of each parent whose signatures its evidence holds (in <verbatim|parent.signatures/> and at every level of <verbatim|parent.chain/>, section 10.5), up to the latest version of each that whoever makes the copy knows, and at least up to the versions its signatures name (for a forked key log, the side the archive keeps, with the evidence of the fork); a tombstone stands in for an owner object taken down (section 11.2), and a takedown of a line leaves these owner objects in place. Third parties' key logs MAY be copied too. Key logs are never copied into an object's content: a key log checks itself from its owner name (its first version's genesis record lists the first keys, and each later version is signed by the keys of the one before), so a copy from any source is as good as the original, and a line can be checked without trusting any host, also after the archives that served it have gone. Of two copies of a key log, either one extends the other, and readers use the longer, or they fork (above). No one can prove offline that a key log is complete: a copy that stops early may hide that the owner has ended.

  <strong|Keepers (optional).> An owner MAY name, in <verbatim|keeper> of its key log, the person or institution who answers for it: an ORCID iD (<verbatim|https://orcid.org/...>), a web address, an institution's domain written as <verbatim|https://\<less\>domain\<gtr\>/>. The keeper MAY confirm it, in a place only the keeper controls: a link naming the owner in its ORCID record, or a file <verbatim|https://\<less\>domain\<gtr\>/.well-known/opensheaf> on its domain, a JSON object with <verbatim|owners>, the owner names it answers for, and, OPTIONALLY, <verbatim|successors>, an object mapping owner names it answers for to their successors, which confirms them (on ORCID, a link naming both). When a keeper is named, a verifier MAY check both directions, and reports the link as confirmed, claimed only (the owner names a keeper who does not confirm it), or absent. A confirmation is read as it is now: a keeper who withdraws it ends the link, and what the owner signed stays authentic. The link says who answers for an owner, not who owns its lines, which only keys decide, nor who wrote its documents, which <verbatim|creators> in <verbatim|datacite.json> say (#41). The form of a confirmation on ORCID depends on an <verbatim|https> form of <verbatim|sheaf:\<less\>owner\<gtr\>>, and so on the gateway (section 6.6).

  <strong|Drafts.> A draft is a sandbox: an object of the reserved owner <verbatim|draft>, kept by one archive at the path of <verbatim|sheaf:draft:\<less\>id\<gtr\>> (<verbatim|draft/\<less\>id\<gtr\>/> in the owner-name layout; sections 5 and 6.3), in the same format as any object (OCFL versions, <verbatim|object.json>, <verbatim|datacite.json>) but without a genesis record. It is never signed and never pinned, and it belongs to its archive alone: mirrors, custodians, collections, indexes and <verbatim|sheaf:> URIs never take drafts, and only the archive itself keeps them, also when it moves to another site (section 6.2). It is the only object that MAY be rewritten or deleted: the rule that versions are fixed, and the tombstones of section 11.3, do not apply to it. The discovery document MAY list drafts apart, as unfinished work on which nothing may rely, or not at all (section 6.1, #29). The format says nothing about where a draft's content came from: a tool may read any object and recreate its files in a draft, as far as their licences allow.

  <strong|One writer per line.> The object versions of a line form a single sequence, each extending the one before, as OCFL objects do: an owner MUST NOT sign two different object versions with the same number for the same line. Since every version directory keeps the inventory as of that version (section 7.1), two copies whose heads are <verbatim|vk> and <verbatim|vm>, with k not greater than m, agree when <verbatim|vk/inventory.json> is the same file, byte for byte, in both; a copy that stops at an earlier version is simply older, readers use the latest signed version among the copies that agree, and no signed list of an owner's lines is needed: an archive's discovery document lists what it holds, without guaranteeing that an owner has no lines elsewhere. Two copies that do not agree are a <strong|fork of the line>, reported with the status of each side (section 13.2); a fork whose sides are both signed was made with keys of the owner, and is attributable to whoever holds them.

  <strong|Adding versions.> An archive adds a version to a line only if, once added, it is signed (section 13.2) against the key log the archive holds: signed by its owner, or extended by a signed version added with it from the same copy; tools fetch the latest key log they can find before adding. For an owner that has ended or whose key log is forked, as far as it knows (above), it adds the key log up to and including the end (for a fork, up to the fork point on the side it keeps, with the evidence of the other), and takes that owner's lines only from copies found elsewhere, never as new deposits: it MAY copy a line, or extend one it holds, up to the latest signed version of a copy that agrees with it, since holding earlier versions is no reason to trust later ones less or more; readers weigh them as they weigh that owner's history (above). It adds no invalid signature file. An archive that continues another owner's line makes a branch, under its own owner (section 10.5). <strong|Versions an archive holds stay>: nothing that a host or a thief can produce leads to removing one; only a takedown does (section 11.2). A version let in against this rule that is not signed is reported, and never shown as a version of the line; since OCFL versions cannot be skipped, the owner's own version of that number can then never be added there: that archive's copy is one side of a fork of the line, and the owner continues the line in another archive.

  <strong|Archives and owners.> An archive decides which owners it hosts (a university admitting its staff, a journal its editors), and how they deposit; this is its own policy. It MAY list the owners it hosts in <verbatim|owners> of its discovery document. What is authentic is decided by each owner's signatures, not by the archive. An archive that makes collections (a catalogue of its documents, a journal's selections) does so as an owner, with a key log like any other.

  <strong|Moving.> An owner moving to another archive copies its key log there (its owner object), with the lines it wants to keep there, and continues its lines in the new archive: the same owner, the same lines, not a branch. The old copies stay valid where they are, and copies of different heads are older and newer copies of the same line (above). An archive moving to another site copies its files (section 6.2).

  <strong|Origin.> The line of the originator is the origin of the name, and has no parent. Every other line with the same genesis record MUST declare its parent (section 10.5); a line of another owner that declares none is not a valid line of the name.

  <strong|Sealing and transfer.> Sealing makes a new object: the line <verbatim|sheaf:\<less\>name\<gtr\>:\<less\>owner\<gtr\>>, at its path in the layout (<verbatim|\<less\>owner\<gtr\>/\<less\>name\<gtr\>/> in the owner-name layout), whose first version holds the genesis record and the work, signed by its owner. The versions of a draft it was made from are not part of the line, and nothing in the line refers to them. The owner seals a work before first sharing or publishing it, and tools SHOULD seal only at the owner's request, not as a side effect. A line is not handed over: when another owner continues the work (an author leaving an institution, when the line is the institution's; a journal handing a report to its referee), the new owner makes a branch (section 10.5), and MAY keep a copy of the previous owner's line beside it, and the previous owner MAY add a notice to its own line pointing to the branch. An owner taking its own lines elsewhere moves (above), which is not a hand-over.

  <strong|Clashes.> A name is used to refer to objects, so the format does not assume that two works never share one. No two objects of a storage root have the same line, since their identifiers would coincide (section 6.3), and an owner has one line of each name. A clash can arise only when a line is made, and is resolved by the tool that makes it, against the archive where it writes and the lines of the same owner it knows elsewhere (whose signatures hold):

  <\itemize>
    <item>when sealing, a tool checks the line (name, owner) and, if it is taken, draws a new nonce, so that the originator's line is always named by algorithm 0; an object sealed outside the archive and shared before its deposit can still meet a taken line when it is deposited (after a reused genesis record or a collision), and is then refused, and its owner seals it anew;

    <item>a branch is never owned by the originator, whose line is the origin and has no parent: how the originator takes in another line's work is open (below); a tool refuses such a branch;

    <item>a branch is named by <verbatim|parent.name>, unless its line (its owner, that name) is taken by another line of its owner; if that line is the owner's own branch of the same parent line and the new branch point is later in the parent line's history than that branch's current branch point, the owner moves its branch point instead (section 10.5); otherwise (another genesis record, another parent line, an earlier or equal branch point) the branch is named by the smallest algorithm number greater than that of <verbatim|parent.name> whose name, over the same genesis record, gives a line free for its owner; <verbatim|parent> keeps the parent's name; if no number up to 15 is free, the branch is refused. An accepted copy of another selection is not renamed: selections are different owners (section 10.5);

    <item>a copy of a line whose identifier is taken in a storage root by a different history of the same line is a fork (above): the archive keeps the history it holds, and reports the other;

    <item>a line stays taken in an archive after a takedown (section 11.3: the tombstone keeps the identifier), so that a removed line and a new one never share an identifier there.
  </itemize>

  Other owners' lines are different lines and never clash. A renamed branch is always written with its owner part (section 6.6), since a URI without an owner part names the originator's line, which is named by algorithm 0.

  <strong|Refusals.> One genesis record names one work and its originator. The first version of the originator's line MUST be signed by the originator named in the genesis record, and every other line of the record is a branch, whose evidence carries the chain of its parents back to a version of the originator's line, each signed by its owner (section 10.5). Someone who reuses a genesis record for another work therefore cannot make a valid line of it: the originator's signature cannot be made by anyone else, and a branch needs a chain of signed parents ending in the originator's line. Only the originator can reuse its own record, and a second history it signs under it is a fork of its line, detected and attributable to it. When an object is created or deposited, an archive that holds an object (or a tombstone) with the same genesis record (compared by its name by algorithm 0, which objects' genesis records and tombstones give) accepts it only if it is signed by the genesis record's originator (the same line) or carries a chain of parent evidence that holds back to the originator's line (a branch), and otherwise refuses it. A tool MUST NOT copy a genesis record into an object that is not a copy or a branch of the work it was written for, nor reuse a nonce.

  <strong|Existing objects.> This draft assumes that every sealed object has a genesis record and an owner with a key log: archives made under earlier drafts are rebuilt, as the warning at the head of this specification allows before version 1.0.

  <strong|Open questions.>

  <\itemize>
    <item>Registering the scheme <verbatim|sheaf> with IANA, as a provisional scheme (RFC 7595) (#36).

    <item>Who keeps indexes of many archives, so that an object can be found once its archives have gone, how resolvers find them, and whether the project runs a shared resolver of <verbatim|sheaf:> URIs, a gateway (section 6.6), and on which domain; the gateway's domain, and the format strings <verbatim|opensheaf-...>, follow the name chosen for the format (#13, #20, #35).

    <item>How the originator takes in another line's work (a co-author's, a journal's corrections), since its line has no parent and it does not branch its own work (#57).

    <item>The numbering of document versions on branches after the branch point (section 10.5), which <verbatim|/v\<less\>n\<gtr\>> in a <verbatim|sheaf:> URI follows (section 6.6) (#57).

    <item>Moving a branch point when the branch has files of its own (the files of its notices, of a withdrawal, of its version of record): the moving version should probably be a merge keeping both, the new parent version's files and the branch's own, with evidence that tells them apart (section 10.5) (#57).

    <item>How drafts are shared before sealing (among co-authors, with a journal under review), and how an archive serves them (#29).

    <item>The field names of <verbatim|keys.json> and of signature files, and the format of signature files (section 13.2) (#55).

    <item>Whether owners should survive the exposure of a key (revocation dated by trusted time, transparency logs), which the core leaves to ending the owner (#55; <verbatim|drafts/keys-and-forks.md> on <verbatim|main>).

    <item>Holding and copying among custodians: copies up to a pinned version, copying by agreement, and what a custodian promises to keep (#39, #54).

    <item>Takedowns: a branch keeps the parent version after the parent is taken down, and mirrors, indexes kept by others and gateways may go on serving a taken-down object; with lines stored anywhere, an owner's takedown needs a statement signed by the owner, and for an owner that has ended or whose key log is forked, its keeper or the law (#33).

    <item>Whether aliases (a new genesis record that wraps the old one) are needed, if refusing reused genesis records at creation proves too strict (#44).
  </itemize>

  <subsection*|6.6 Names as URIs and finding objects><label|66-names-as-uris-and-finding-objects>

  <os-alert|note|Note.|<strong|Proposal.> This section is part of the proposal of section 6.5: writing lines, versions, pins and owners as URIs, and finding objects by name (#14, #20). It replaces the decision first recorded in #14 (global names as <verbatim|tag:> or ARK URIs built from an archive identifier): a line has a name and an owner independent of any archive, and <verbatim|sheaf:> URIs write them; archives have no identifiers (section 6.2, #52).>

  **The <verbatim|sheaf> URI.** A line, a document version of a line, one object version, the work as a whole, or an owner, is written as a URI of the scheme <verbatim|sheaf>:

  <\verbatim-code>
    sheaf:\<less\>name\<gtr\> \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ the line of the originator

    sheaf:\<less\>name\<gtr\>:\<less\>owner\<gtr\> \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ the line of that owner

    sheaf:\<less\>name\<gtr\>:* \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ the work as a whole, all its lines

    sheaf:\<less\>name\<gtr\>/v\<less\>n\<gtr\> \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ document version n of the originator's line

    sheaf:\<less\>name\<gtr\>:\<less\>owner\<gtr\>/v\<less\>n\<gtr\> \ \ \ \ \ \ \ \ \ \ \ \ \ \ document version n of that owner's line

    sheaf:\<less\>name\<gtr\>[:\<less\>owner\<gtr\>]/v\<less\>n\<gtr\>?sha512=\<less\>digest\<gtr\> \ \ one object version holding it

    sheaf:\<less\>owner\<gtr\> \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ an owner (its key log)

    sheaf:\<less\>owner\<gtr\>/v\<less\>n\<gtr\>?sha512=\<less\>digest\<gtr\> \ \ \ \ \ a version of an owner's key log
  </verbatim-code>

  where <verbatim|\<less\>owner\<gtr\>> is an owner name (section 6.5). The parts are, in this order: <verbatim|sheaf:> and the name; optionally <verbatim|:> and an owner name, or <verbatim|:*>, which names all the lines and takes no document version and no <verbatim|sha512> (the owner part is <verbatim|:> and an owner name; <verbatim|:*> is not an owner part); optionally <verbatim|/v> and a document version, a positive integer without leading zeros; optionally <verbatim|?> and a query of parameters <verbatim|key=value> joined by <verbatim|&>, among them at most one <verbatim|sha512>, only after a version (a document version, or for a key log an object version), whose value is the SHA-512 digest of an inventory file, 128 lowercase hexadecimal digits, as in a pin (section 10.2), and at most one <verbatim|at>, after <verbatim|sha512> if both are present (below). A resolver ignores parameters it does not know; no part other than the value of <verbatim|at> is percent-encoded; this proposal defines no fragment. The scheme, the name, the owner name, <verbatim|v>, the digest and the parameter names are lowercase, and a resolver MAY fold uppercase letters in them; the value of <verbatim|at> is case-sensitive. The name of an owner is the name of its genesis record, so <verbatim|sheaf:\<less\>owner\<gtr\>> names the originator's line of that record, which is the owner object itself; for the versions of a key log, <verbatim|/v\<less\>n\<gtr\>> is the object version number.

  <\itemize>
    <item><strong|The owner.> Without an owner part, a URI names the line of the originator, the owner named by <verbatim|originator> in the genesis record (for an owner, the owner itself: <verbatim|sheaf:\<less\>owner\<gtr\>> names its key log), which every copy of the object and of its branches carries. If a resolver finds several genesis records under one name (with the same originator or not), the URI is ambiguous: it lists them with their originators and does not choose. It does not mean the latest line or the most authoritative one: the versions of any other line, such as a journal's or a co-author's, are written with their owner, and if the originator stops and another owner continues the work in a branch, the URI still names the originator's line. <verbatim|sheaf:\<less\>name\<gtr\>:*> names the work as a whole, with all its lines: a resolver shows the lines it knows that pass the checks below. A resolver rejects <verbatim|:*> with a document version or <verbatim|sha512>, since every line has its own document versions (section 10.5); <verbatim|at> is allowed with it.

    <item><strong|The version.> <verbatim|/v\<less\>n\<gtr\>> is a document version of the line (section 7.3, also on a branch), not an OCFL object version, except for an owner's key log. It names only object versions of the line: sealed versions (with a genesis record) whose <verbatim|object.json> has the line's owner and whose signatures hold. A branch's line holds only its own versions, from its branch point (section 10.5); the parent's versions are named with the parent's owner; drafts have no <verbatim|sheaf:> URI (section 6.5). Several object versions of the line may hold document version n: without a digest, the URI names the one listed for n in the <verbatim|history> of the line's latest signed version, or, without <verbatim|history>, the last signed object version of the line holding n (section 7.3). What it names can then change as the line grows, by a description or a notice, and copies may answer differently: a resolver uses the latest signed version among the copies it found that agree (section 6.5), and says where it found them, since a copy that stops early looks complete by itself.

    <item><strong|The pin.> With a digest, the URI names exactly the object version whose inventory file has that digest. A resolver MUST check that digest, and that the version holds a genesis record whose name, by the algorithm of the name's last character, is the name, has the URI's name as <verbatim|name> and the line's owner as <verbatim|owner> in its <verbatim|object.json> (the owner part, or the originator), holds document version n (for a version of a key log, is object version n), and is signed by that owner (section 13.2); it reports a mismatch as section 14 does. Citations of a fixed version SHOULD carry the digest.

    <item><strong|The hint.> <verbatim|at> names an archive where a copy is expected, where a resolver looks first: its value is the archive's base URL, an <verbatim|https> URL ending with <verbatim|/>, percent-encoded in full (every character outside the unreserved characters of RFC 3986 is encoded, as <verbatim|encodeURIComponent> does) and decoded once: <verbatim|sheaf:\<less\>name\<gtr\>/v3?sha512=\<less\>digest\<gtr\>&at=https%3A%2F%2Fauthors.example.org%2F>. It is a location (section 6.2), not part of the identity.

    <item><strong|Equality.> The canonical form of a <verbatim|sheaf:> URI has complete parts, lowercase where the case is folded, and, for <verbatim|:*>, the name made by algorithm 0, since all the names of a genesis record name the same work; it has no owner part when the owner is the originator (read from the genesis record, which any copy carries and the name certifies, section 6.5, so that deciding equality may need one copy of <verbatim|genesis.json>), and no <verbatim|at> and no unknown parameters. Two URIs name the same thing when their canonical forms are equal, byte for byte, and files that record a <verbatim|sheaf:> URI (for instance among the relations of <verbatim|datacite.json>) record its canonical form.
  </itemize>

  <strong|Checks.> A resolver checks every copy it finds: the name is a name of its <verbatim|genesis.json>, by the algorithm of its last character, the <verbatim|name> and <verbatim|owner> in <verbatim|object.json> are the line's, the versions are signed by the owner, checked against its key log (section 13.2), and, with a digest, the rest of the checks of a pin. A copy that passes them is a copy of the line, wherever it was found; unchecked versions, and versions that are not versions of the line (section 13.2), are reported with their status and where they were found, and not used for a pin or a resolution. When copies of a line disagree, they are a fork (section 6.5): the resolver reports it, with the status of each side, uses only signed versions, and does not choose between signed sides. It reports an owner that has ended or whose key log is forked, with any successor (section 6.5).

  <strong|Searching for a work.> A work is its genesis record, and its lines may be named by any of the 16 names the record gives (section 6.5: a branch is renamed after a clash). To find every line of a work (for <verbatim|sheaf:\<less\>name\<gtr\>:*>, or a search by work), a resolver: obtains the genesis record (from any entry or copy found under the name, checked against it); computes its 16 names, by every algorithm; looks each of them up in the indexes it knows; and keeps only the entries whose genesis record is, byte for byte, the one it obtained, discarding the others as collisions (removed entries without a genesis record are listed apart, as removed lines of those names, and removed entries that kept it are marked removed); and it keeps only the lines whose signatures hold: the originator's line signed by the originator its genesis record names, and branches whose chains of parent evidence hold back to the originator's line (section 10.5). Since no one else can make the originator's signature, the lines kept are lines of one work, and a genesis record reused for another work yields no valid line. The comparison is of bytes, so it does not rely on any hash being free of collisions. Resolving a line needs no search: <verbatim|sheaf:\<less\>name\<gtr\>> names the originator's line, always named by algorithm 0 (a clash when sealing draws a new nonce), and <verbatim|sheaf:\<less\>name\<gtr\>:\<less\>owner\<gtr\>> names exactly that line.

  <strong|Short forms.> For people reading and typing them, the name and the owner name MAY be shortened to a prefix of at least 8 characters: <verbatim|sheaf:lvfmiq2z/v3>, <verbatim|sheaf:lvfmiq2z:iztwg6bj/v3>. A part of 52 characters is complete; a shorter one is a prefix. A short name with <verbatim|:*> (<verbatim|sheaf:lvfmiq2z:*>) expands among names, whatever their owners, and is ambiguous when names of several genesis records match; once expanded, the work is searched for as above. A resolver expands a short form among the lines it knows of (from the indexes below, the archives and collections it reads, and its user's configuration), counting only the lines whose copies pass the checks above:

  <\itemize>
    <item>the candidates are the lines whose name starts with the name part and whose owner name starts with the owner part; without an owner part, the lines of the originators;

    <item>if all the candidates have the same owner, the short form names the first of them in that owner's order: the line whose first object version of that owner (for the originator, the version that sealed it; for a branch, its first version) has the earliest <verbatim|created> in its inventory, compared as instants;

    <item>otherwise (candidates of different owners, or two with the same <verbatim|created>), the short form is ambiguous: the resolver MUST NOT choose one, and lists the candidates with their full forms and their originators.
  </itemize>

  Only an owner can sign its lines, so another owner can at most make a short form ambiguous, by making lines of its own whose names start with it (8 characters are 40 bits), and cannot take it over. A resolver knows only the lines it has seen, so two resolvers may expand a short form differently, and a short form that is unique today may become ambiguous later, while a full form never changes. Short forms are therefore for people (text, citations, a lookup typed by hand): pins, <verbatim|parent>, <verbatim|members.json> and every other file defined by this specification MUST use complete parts, never prefixes, a resolver SHOULD show the full form of what it resolved, and landing pages and citation metadata SHOULD give the full form, and MAY add a short one. A short form printed or kept where it cannot be corrected (a paper, a slide) SHOULD have at least 16 characters in each part (80 bits), which cannot be searched for.

  <strong|Indexes.> To find objects by name, by owner or by inventory digest without knowing where they are kept, an archive SHOULD keep three indexes of its own objects next to its discovery document, declared there in <verbatim|indexes> (section 6.1), and a custodian or a resolver MAY keep the same files for the objects of many archives, at a base URL of its own, declared in <verbatim|\<less\>base URL\<gtr\>indexes.json>:

  <\itemize>
    <item><verbatim|names/\<less\>p\<gtr\>.json>, where <verbatim|\<less\>p\<gtr\>> is the first characters of a name: the objects whose names start with them, each entry with <verbatim|name>, <verbatim|originator> (from the genesis record; for an owner object, its own name), <verbatim|owner> and <verbatim|id> (the object identifier in that storage root), <verbatim|label> if the archive gives one, and <verbatim|genesis>, the exact text of its <verbatim|genesis.json>, the string whose UTF-8 encoding is exactly the bytes of the file, so that a work can be searched for, and collisions removed, from the indexes alone (above);

    <item><verbatim|owners/\<less\>p\<gtr\>.json>, where <verbatim|\<less\>p\<gtr\>> is the first characters of an owner name: the owners whose names start with them, each entry with <verbatim|owner> and <verbatim|names>, the names of that owner's lines in the storage root (in an index kept for several archives, one entry for each owner and archive); a takedown removes the name, and the entry once it lists none;

    <item><verbatim|sha512/\<less\>p\<gtr\>.json>, where <verbatim|\<less\>p\<gtr\>> is the first hexadecimal digits of an inventory digest: the sealed object versions whose inventories have digests starting with them, each entry with <verbatim|inventorySha512>, <verbatim|id> and <verbatim|version> (the object version), and <verbatim|status>, the object's.
  </itemize>

  The length of <verbatim|\<less\>p\<gtr\>> is declared for each index, from 2 to 4 characters: 2 suits a small archive, while an archive of millions of versions declares 4, so that each file stays small. Each index file is a JSON object with <verbatim|format> (<verbatim|"opensheaf-index/0.1">), <verbatim|index> (<verbatim|names>, <verbatim|owners> or <verbatim|sha512>, the folder it is in) and <verbatim|entries>, every entry starting with the file's <verbatim|\<less\>p\<gtr\>>; the declaration (in <verbatim|indexes> of the discovery document, or in <verbatim|indexes.json>, a JSON object with <verbatim|format> and <verbatim|indexes>) maps each index kept to the length of its <verbatim|\<less\>p\<gtr\>>. An index kept for several archives adds to each entry <verbatim|at>: a list holding the base URL of the archive serving that copy, a location (section 6.2). An archive's indexes list every object of its storage root with a genesis record (never drafts) and every sealed version of it, each entry of <verbatim|names/> and <verbatim|sha512/> with <verbatim|status> (<verbatim|active> or <verbatim|withdrawn>); a tombstoned object keeps its entries with <verbatim|status> <verbatim|removed>, so that a resolver can report it as section 11.3 asks; a removed entry of <verbatim|names/> keeps <verbatim|name>, <verbatim|owner>, <verbatim|id> and <verbatim|status>, and MAY drop <verbatim|originator> and <verbatim|genesis>. A file with no entries is omitted, so that, where the indexes are declared, a missing file means no entry. A resolver looks up a URI in <verbatim|names/> at the archives and indexes it knows, starting from <verbatim|at>, keeping the entries whose <verbatim|owner> matches the owner part, or, without an owner part, those whose <verbatim|owner> is their <verbatim|originator> (for a removed entry without <verbatim|originator>, whose <verbatim|owner> is the originator read from any copy of the genesis record; when no copy of the genesis record is found, it is reported as a removed line of that name, originator unknown), or, for <verbatim|:*>, every entry found by the search for the work (above), each line checked separately, then reads the history of the object it finds, at the path given by the layout of that archive's discovery document (section 6.4); it looks up a pin in <verbatim|sha512/>, and an owner in <verbatim|owners/>; at an archive that keeps no indexes, it MAY read <verbatim|objects> of the discovery document instead, which gives each object's <verbatim|name> and <verbatim|owner>, and fetches <verbatim|genesis.json> and <verbatim|object.json> from the objects for the search. Like the discovery document, indexes are maps, not witnesses: they are rewritten when objects change, and a resolver checks what it finds as above.

  <strong|Gateways.> Browsers do not resolve <verbatim|sheaf:> URIs. A gateway is a web service that does it for them: it serves a URI at its base URL followed by the URI, unchanged, for instance <verbatim|https://opensheaf.org/sheaf:lvfmiq2z/v3?sha512=c07a...> (provisionally; the domain is open, section 6.5), so that an absolute link and its URI are turned into each other by adding or removing the base URL (a relative link starting with <verbatim|sheaf:> is read as a <verbatim|sheaf:> URI, so gateway links are written in full). A gateway is a resolver like any other, and:

  <\itemize>
    <item>it MUST answer with a real HTTP status: a page (200) showing what it resolved, or a temporary redirect (302, 303 or 307) to a copy; it MUST NOT redirect permanently (301 or 308), since copies move and are taken down, and it MAY cache its own result for a URI with a digest, but not for one without; it MUST redirect only to a copy it has checked as above, and otherwise answers with a page; <verbatim|sheaf:\<less\>name\<gtr\>:*> shows the lines it knows;

    <item>it MUST show where what it resolved was found, and that a URI without a digest resolves to the latest copy it found, which may not be the latest the owner made;

    <item>it MUST show when the owner of what it resolved has ended or its key log is forked, with any successor;

    <item>it MUST NOT serve the files of an archive from its own origin, but redirects or links to the archive (section 15);

    <item>when it fetches on behalf of its users, it MUST fetch only <verbatim|https> URLs at public addresses, with limits on size and time.
  </itemize>

  Whether the project runs a gateway, on which domain, and whether a domain used only for resolution (such as <verbatim|sheaf.pub>) drops <verbatim|sheaf:> from the path, as <verbatim|https://doi.org/> drops <verbatim|doi:>, is still to be decided (section 6.5, #35).

  <section*|7. Objects><label|7-objects>

  <subsection*|7.1 Common rules><label|71-common-rules>

  Every object MUST be a valid OCFL 1.1 object. Its inventories MUST use <verbatim|sha512> as digest algorithm. Every object version MUST contain, in its content, the files <verbatim|object.json> and, except in an owner object (section 7.5), <verbatim|datacite.json> at the top level, and, except in a draft, <verbatim|genesis.json> (section 6.5); every version of a branch also holds the evidence of its current branch point, <verbatim|parent.inventory.json>, <verbatim|parent.object.json>, <verbatim|parent.signatures/> and, for a branch of a branch, <verbatim|parent.chain/> (section 10.5), unchanged until the branch point moves again. These are the identity files of the object; they are not files of the document's own (section 7.3), and the names <verbatim|genesis.json>, <verbatim|parent.inventory.json>, <verbatim|parent.object.json>, <verbatim|parent.signatures> and <verbatim|parent.chain> are reserved for them at the top level of the content. Every version directory MUST contain a copy of the inventory as of that version, with its checksum file (OCFL makes this a recommendation; OpenSheaf requires it, so that each version can be pinned and fetched on its own). Version directories MUST NOT be zero-padded (<verbatim|v1>, <verbatim|v2>, ..., not <verbatim|v001>), which OCFL allows. OCFL recommends that object identifiers be URIs; with the proposal of section 6.5 they are <verbatim|sheaf:> URIs (section 6.3), drafts included.

  Each version in the inventory MUST have a <verbatim|user> with a <verbatim|name>, and SHOULD have an <verbatim|address> (an ORCID iD, a <verbatim|mailto:> URI or another URI identifying the depositor), and MUST have a <verbatim|message> describing the change. The inventory is the record of deposits: the <verbatim|created> date and the <verbatim|user> of an object version are when and by whom it was deposited, and the deposit of a document version is that of the first object version holding it. They are not repeated in <verbatim|object.json>.

  Logical paths MUST be encoded in UTF-8 in Unicode normalisation form C, MUST NOT begin with <verbatim|/>, and MUST NOT contain <verbatim|.> or <verbatim|..> segments.

  <subsection*|7.2 Documents><label|72-documents>

  A document version contains, at the top level of its content unless a profile says otherwise:

  <\itemize>
    <item>the <strong|sources>: the main source and every file needed to produce the renditions that is not part of the toolchain (images, bibliography databases, local style files). The main source is named in <verbatim|object.json>. Sources SHOULD be flat (no sub-folders) when possible. When the sources of a version are not available (for instance a version imported from a service that keeps only its PDF), the version has none, and <verbatim|object.json> says so (section 9);

    <item>the <strong|renditions>, OPTIONAL but RECOMMENDED: at least a PDF for documents meant to be read and cited, named in <verbatim|object.json>;

    <item>the files of notes, if any (the change note, notices, a withdrawal; section 9), named in <verbatim|object.json>;

    <item><verbatim|datacite.json> (section 8) and <verbatim|object.json> (section 9), and the identity files of section 7.1 (<verbatim|genesis.json>, and, in a branch, its evidence: <verbatim|parent.inventory.json>, <verbatim|parent.object.json>, <verbatim|parent.signatures/> and, for a branch of a branch, <verbatim|parent.chain/>).
  </itemize>

  HTML versions and other presentation files SHOULD NOT be deposited, since they depend on the presentation and are regenerated when it improves.

  <subsection*|7.3 Document versions><label|73-document-versions>

  <strong|Numbering.> Document versions are numbered by the owner of the line, from 1, without gaps, independently of any external numbering: a work whose versions 1, 3 and 4 are available on arXiv has document versions 1, 2 and 3. A branch (section 10.5) starts from the document version of its first branch point, and continues without gaps from it (provisionally: option (a) of the open question of section 10.5); an object version that moves the branch point is the branch's next document version, and <verbatim|parent> keeps the parent's own number.

  <strong|Sealing.> The first version of a line, made by sealing (section 6.5), holds the work as its owner seals it: document version 1 for an originator's line, the document version of the branch point for a branch (section 10.5). The drafts it was made from are not part of it. External labels (arXiv's <verbatim|v3>) are recorded in <verbatim|external> (section 9), and presentations SHOULD show them with the document version.

  <strong|New versions.> A new document version number is assigned exactly when files of the document's own (sources, renditions, change note) that were not deposited before are added, except when a version without sources is completed (below). An object version holding the same sources, renditions and change note as an earlier document version keeps its number.

  <strong|Description-only versions.> A description-only version holds an existing document version, with its files unchanged, and changes only its description (<verbatim|datacite.json>, such as a DOI, a stage or a link to the published article), the state of the object or its notices. It MAY hold any document version, not only the current one, so that an earlier version can be described after later versions exist; tools otherwise hold the current version. If the object has <verbatim|history>, its entry for that document version becomes the new object version.

  <strong|Completion.> A document version recorded without sources (section 9, <verbatim|sourcesMissing>) MAY be completed later, keeping its number: the completing object version adds the sources, and MAY add renditions produced from them (for instance a PDF typeset from the added sources, beside the one received), but changes or removes no file of the version; until the sources are complete it keeps <verbatim|sourcesMissing> and names no main source; the object version that completes them names the main source and removes <verbatim|sourcesMissing>, after which the version is fixed like any other.

  <strong|Other versions.> A version that was not public at the time, such as the manuscript submitted to a journal, deposited later, is a document version like any other. A version published by someone else, such as the journal's version of record, is not a document version of the author's object: it is linked by a relation (section 8.1). Conversely, a branch holds files of its parent's owner only at its branch points; the parent's earlier versions are kept, if at all, in a copy of the parent's line (section 10.5).

  <strong|History.> The order of the document versions in the history of the work is the order of their numbers, unless <verbatim|object.json> has <verbatim|history> (section 9): the list, in the order of the work, of the last object version holding each document version. The last object version is used because it carries the most complete description of that document version (a DOI added later, a corrected stage). An object version that deposits a document version out of order (an earlier version found later) MUST write <verbatim|history>, and once an object version has <verbatim|history>, every later object version MUST have it. A version whose place in the history is unknown goes just before the current version, and its <verbatim|object.json> SHOULD say so in its change note. The history is read from the head version; earlier object versions keep the history as it was known when they were made.

  <strong|Current version.> The current version of a document is the last entry of the history of its head version (without <verbatim|history>: the highest document version); for a sealed line, the head is its latest signed version (section 6.5). The head may hold another document version, after an earlier version is deposited out of order or described by a description-only version; the current version stays where it was. Landing pages, indexes and citations use the current version, not the head; selections vet revisions explicitly (section 10.2).

  <strong|Notices.> A notice about a document version (for instance that a theorem of version 2 is wrong as stated, and is corrected in version 3) is written after that version, which cannot change. Notices are added to <verbatim|notices> in <verbatim|object.json> (section 9) by description-only versions. A notice present in an object version is present, unchanged, in every later object version; a notice is corrected or withdrawn by a later notice that says so. Presentations showing a document version SHOULD show the current notices about it.

  Dates never order document versions and never decide the current version (section 8).

  <subsection*|7.4 Collections><label|74-collections>

  A collection version contains <verbatim|datacite.json>, <verbatim|object.json>, <verbatim|members.json> (section 10), which states whether the collection is a catalogue or a selection, and the identity files of section 7.1. Its <verbatim|object.json> declares <verbatim|kind> <verbatim|collection>; its document version counts the changes of the member list, and it has none of the fields specific to documents (<verbatim|mainSource>, <verbatim|sourceFormat>, <verbatim|sourcesMissing>, <verbatim|renditions>, <verbatim|toolchain>, <verbatim|changes>, <verbatim|stage>, <verbatim|history>, <verbatim|notices>).

  <subsection*|7.5 Owners><label|75-owners>

  <os-alert|note|Note.|<strong|Proposal> (section 6.5).>

  An owner object (kind <verbatim|owner>) holds the key log of an owner (section 6.5). Every version of it contains, at the top level of its content, <verbatim|genesis.json> (the owner's genesis record, kind <verbatim|owner>), <verbatim|keys.json> (section 6.5) and <verbatim|object.json> with <verbatim|format>, <verbatim|specification>, <verbatim|kind> <verbatim|owner>, <verbatim|name> and <verbatim|owner> (both the owner name) and <verbatim|status>, always <verbatim|active>, and MAY have <verbatim|extensions> (section 4; an extension concerning the key log records its data in <verbatim|keys.json> instead); it has no <verbatim|datacite.json>, no document versions and none of the fields specific to documents, collections or lines (<verbatim|documentVersion>, <verbatim|parent>), nor <verbatim|withdrawal>, <verbatim|licence>, <verbatim|agreement> or <verbatim|external>. Its object versions are numbered as OCFL numbers them, and each later one MUST be signed by at least <verbatim|threshold> keys of the one before (section 13.2). An owner object is never withdrawn or branched. It is copied with the lines it signs (section 6.5), and MAY be copied, or mirrored, on its own: when its owner moves (section 6.5), or to keep a fresher copy of its key log.

  <section*|8. Description: datacite.json><label|8-description-datacitejson>

  Every object version, except in an owner object (section 7.5), MUST contain <verbatim|datacite.json>, a JSON object with the DataCite 4.7 properties in the form of the <verbatim|attributes> of a DOI in the DataCite REST API. It is the authoritative description of the object version. It MUST contain:

  <\itemize>
    <item><verbatim|titles>, <verbatim|creators> (with <verbatim|name>, and <verbatim|nameType>; personal names SHOULD also have <verbatim|givenName> and <verbatim|familyName>), <verbatim|publicationYear>, <verbatim|types> (with <verbatim|resourceTypeGeneral>), <verbatim|version> (the document version, as a decimal string without leading zeros, such as <verbatim|"3">), and <verbatim|publisher>.
  </itemize>

  It SHOULD contain:

  <\itemize>
    <item><verbatim|descriptions> with a <verbatim|descriptionType> <verbatim|Abstract>, as plain text with mathematics as below;

    <item><verbatim|subjects> with a <verbatim|subjectScheme> (any scheme; MSC2020 is common in mathematics);

    <item><verbatim|dates>, as below;

    <item><verbatim|rightsList>: for a licence with an SPDX identifier, that identifier in lower case and the licence URL; for a licence without one, its name in <verbatim|rights> and the URL identifying it in <verbatim|rightsUri> (for arXiv's default licence, <verbatim|http://arxiv.org/licenses/nonexclusive-distrib/1.0/>), which MUST then be present, so that archives record the same licence the same way; or a statement such as "All rights reserved", without URL;

    <item><verbatim|language>, <verbatim|formats> (the media types of the sources and renditions) and <verbatim|sizes>;

    <item>identifiers of creators (ORCID) and of affiliations (ROR), where they exist;

    <item><verbatim|relatedIdentifiers> (section 8.1).
  </itemize>

  <verbatim|publisher> is the owner of the line, or the body behind it (a journal, an institution), or the external service registering a DOI for the version (appendix A). <verbatim|publisher> and <verbatim|affiliation> SHOULD be written as objects (with <verbatim|name> and, where available, an identifier); readers MUST also accept plain strings.

  <verbatim|doi> and <verbatim|url> are OPTIONAL: they are present when the version has a DOI. <verbatim|types> gives the kind of content: <verbatim|resourceTypeGeneral> from DataCite's list (<verbatim|Preprint>, <verbatim|JournalArticle>, <verbatim|Book>, <verbatim|Dissertation>, <verbatim|Report>, <verbatim|Text>, <verbatim|Dataset>, <verbatim|Software>, <verbatim|Audiovisual>, <verbatim|Presentation> (slides, since DataCite 4.7) and so on, and <verbatim|Collection> for collections), with <verbatim|resourceType> for detail (for instance "Lecture notes"). An author's versions of a work not published elsewhere are <verbatim|Preprint>, also the accepted manuscript; the stage of a version is given by <verbatim|stage> in <verbatim|object.json> (section 9).

  <strong|Dates.> Dates are information for readers and services: they never order document versions (section 7.3). Each date type has one meaning:

  <\itemize>
    <item><verbatim|Issued>: the first public appearance of the work, anywhere; the same in every version. RECOMMENDED for documents; tools importing works published elsewhere SHOULD set it.

    <item><verbatim|Available>: when this document version first became public, anywhere: for a version imported from another service, its date there; for a version first made public by this archive, the date of its deposit (section 7.1). SHOULD be present.

    <item><verbatim|Updated>: the date of the latest description-only version holding this document version; absent when the document version has had none.

    <item><verbatim|Created> (when a version was written, for a version not public at the time), <verbatim|Submitted> and <verbatim|Accepted> (journal milestones), OPTIONAL.

    <item><verbatim|Withdrawn>: the date of a withdrawal, equal to <verbatim|withdrawal.date> in <verbatim|object.json> (section 11.1).
  </itemize>

  <strong|Mathematics in titles and abstracts.> Titles and abstracts are plain text in which mathematics MAY be written in LaTeX between single dollar signs (<verbatim|$\\Phi^4_3$>); a literal dollar sign is written <verbatim|\\$>. The LaTeX SHOULD use only the mathematical commands of LaTeX with the <verbatim|amsmath> and <verbatim|amssymb> packages, which common renderers (MathJax, KaTeX) display without the document's preamble; presentations render it, and readers that do not are left with readable LaTeX. Tools importing titles and abstracts from elsewhere SHOULD replace the authors' own macros (such as <verbatim|\\R> or <verbatim|\\be>) with standard LaTeX when their definitions are known, for instance from the preamble of the imported sources, and otherwise keep them unchanged; they MUST NOT invent definitions.

  Dates MAY be approximate, as DataCite allows (<verbatim|2019>, <verbatim|2019-03>, a range <verbatim|2018/2019>), with <verbatim|dateInformation> explaining them (for instance "from file timestamps"); unknown dates are omitted.

  <subsection*|8.1 Relations><label|81-relations>

  <\itemize>
    <item>A document version with a DOI SHOULD have <verbatim|IsVersionOf> the concept DOI of the document, and <verbatim|IsNewVersionOf> the DOI of the document version before it in the history (section 7.3), if that version has a DOI. Relations state what was known when a version was described; after a version is deposited out of order, the relation of the version that follows it MAY be corrected by a description-only version.

    <item>The same work published elsewhere SHOULD be linked with <verbatim|IsIdenticalTo> (same content, for instance an arXiv version) or <verbatim|IsVariantFormOf> (different content or form).

    <item>A preprint SHOULD be linked to its later published article with <verbatim|IsVersionOf> the article's DOI, as DataCite recommends; consumers distinguish this relation from the concept DOI by its target. It is added by a description-only version.

    <item>The sources MAY be linked to a software archive snapshot (<verbatim|relatedIdentifierType> <verbatim|SWHID>).

    <item>(Proposal) A <verbatim|sheaf:> URI (section 6.6) is recorded with <verbatim|relatedIdentifierType> <verbatim|URL>, in its canonical form, since DataCite has no type for it; this is provisional, until the scheme is registered (#36).

    <item>A collection version MUST have <verbatim|HasPart> for each member (each revision, in a selection) that has a version DOI, pointing to that version DOI. Members without a DOI are listed only in <verbatim|members.json>.

    <item>A document MUST NOT state the collections that include it: membership is stated only by collections, so that including a document in any collection never changes the document.
  </itemize>

  <section*|9. The object: object.json><label|9-the-object-objectjson>

  Every object version MUST contain <verbatim|object.json>, OpenSheaf's record of the object as of that version: its identity, the structure of its content, its versions and its state. It MUST contain:

  <\itemize>
    <item><verbatim|format>: <verbatim|"opensheaf-object/0.1">;

    <item><verbatim|specification>: <verbatim|"0.1">;

    <item><verbatim|kind>: <verbatim|document>, <verbatim|collection> or <verbatim|owner> (an owner object has only the fields of section 7.5);

    <item><verbatim|documentVersion>: a positive integer, equal to the <verbatim|version> of <verbatim|datacite.json>;

    <item><verbatim|status>: <verbatim|active> or <verbatim|withdrawn> (section 11).
  </itemize>

  In every version of a line (section 6.5), an object MUST also contain <verbatim|name> and <verbatim|owner> (the owner name), and a branch <verbatim|parent> (section 10.5); a draft has neither. With the proposal of section 6.5, <verbatim|object.json> names no archive: lines belong to their owners, wherever they are kept (#52).

  A document MUST also have <verbatim|mainSource> (a logical path) and <verbatim|sourceFormat> (the media type of the main source), and SHOULD have <verbatim|renditions> (a list of objects with <verbatim|path>, a logical path, and <verbatim|mediaType>) and <verbatim|toolchain> (a list of tools with <verbatim|name>, <verbatim|version> and, optionally, <verbatim|packages>), enough to reproduce the renditions. A document version whose sources are not available instead has <verbatim|sourcesMissing>, a note (see below) saying why (for instance "arXiv keeps only the PDF of this version"), no <verbatim|mainSource> and <verbatim|sourceFormat>, and at least one rendition; a rendition is never presented as a source.

  A <strong|note> is an object with <verbatim|text> (a short plain text), or <verbatim|path> and <verbatim|mediaType> (a file of the content of the same object version), or both: the text serves feeds, indexes and external services, the file holds the full statement (with mathematics, or as a PDF). Files of notes are covered by the inventory like every file of the content.

  A document MAY contain:

  <\itemize>
    <item><verbatim|changes>: a note saying what changed in this document version, written and deposited with it (like arXiv's comments). It is part of the document version (section 7.3);

    <item><verbatim|stage>: the stage of this document version, an object with <verbatim|scheme> and <verbatim|value>. For articles the RECOMMENDED scheme is <verbatim|NISO-JAV>, the NISO Journal Article Versions: <verbatim|AO> (author's original), <verbatim|SMUR> (submitted manuscript under review), <verbatim|AM> (accepted manuscript), <verbatim|P> (proof), <verbatim|VoR> (version of record), <verbatim|CVoR> (corrected version of record), <verbatim|EVoR> (enhanced version of record). Other kinds of content use other schemes (editions, software releases), named by the archive. A description-only version MAY add or correct it;

    <item><verbatim|history>: the list of object versions giving the order of the document versions (section 7.3);

    <item><verbatim|notices>: a list of notices (section 7.3), each a note with the <verbatim|documentVersion> it is about and a <verbatim|date>.
  </itemize>

  Any object MAY contain:

  <\itemize>
    <item><verbatim|licence>: a note with the full text or terms of the licence of the content, kept in the package (useful for licences without an SPDX identifier); <verbatim|rightsList> in <verbatim|datacite.json> remains the description for readers and services;

    <item><verbatim|agreement>: a minimal record that the authors agreed to the deposit and to the licence: <verbatim|by> (the names of those who agreed, names only), <verbatim|date>, and <verbatim|method> (how, for instance "by e-mail"), all three required. It MUST NOT contain e-mail addresses, correspondence or signatures of persons;

    <item><verbatim|external>: the external records of this version, each with its <verbatim|role> (required): <verbatim|deposit> for a deposit of the version made by the archive (appendix A), <verbatim|source> for the record it was imported from; the <verbatim|service> (required, its name), the <verbatim|record> (required, the URL of the record), the <verbatim|doi>, the <verbatim|label> the service gives the version (for instance <verbatim|v3> on arXiv), and <verbatim|files>: the files kept there that are not in the content (for a deposit, such as a source archive uploaded instead of the sources) or the files received from it (for a source, as they were received before being unpacked), each with <verbatim|name> and <verbatim|sha512> (required), <verbatim|md5> and <verbatim|bytes>;

    <item><verbatim|withdrawal> (section 11);

    <item><verbatim|extensions>: the data of extensions (section 4), an object whose keys are the names of the extensions and whose values are defined by them.
  </itemize>

  <verbatim|object.json> is metadata and is placed under CC0 (section 16).

  <section*|10. Collections: members.json><label|10-collections-membersjson>

  <subsection*|10.1 Catalogues and selections><label|101-catalogues-and-selections>

  Collections are of two kinds, which differ in how they treat the versions of their members.

  <\itemize>
    <item>A <strong|catalogue> keeps objects whole and is impartial about their versions. Each member pins an object, with all its versions, and the collection may follow it as it grows, whoever adds the versions: the owner of the object decides what its versions are. The main collection of an archive's documents, and the list of lines an archive keeps copies of (section 10.4), both kept by the archive acting as an owner (section 6.5), are catalogues.

    <item>A <strong|selection> vets particular revisions: a journal its accepted version, a digest or a review journal the version it reviewed, a reading list the version it recommends. Each member pins a revision set, the document versions the curator vetted; earlier and later versions of the same document are not part of the selection, and the selection changes only by an explicit act of its curator, which is a new version of the selection. A selection may also keep its own copies of the revisions it vetted (section 10.5).
  </itemize>

  Both kinds may contain collections as members (an archive of archives, a selection of issues). <verbatim|members.json> states the kind.

  <subsection*|10.2 The member list><label|102-the-member-list>

  A collection version MUST contain <verbatim|members.json> with:

  <\itemize>
    <item><verbatim|format>: <verbatim|"opensheaf-collection/0.1">;

    <item><verbatim|type>: <verbatim|"catalogue"> or <verbatim|"selection">;

    <item><verbatim|members>: a list, in the order in which the members are presented. This order is authoritative: presentations MUST present members in it.
  </itemize>

  It MAY contain <verbatim|order>, the rule by which tools maintaining the collection place members: <verbatim|manual> (the default: tools append new members and never reorder), <verbatim|issued-desc> or <verbatim|issued-asc> (by the members' <verbatim|Issued> date, then their <verbatim|Available> date, members with neither last, ties broken by name and then owner name, so that the result is reproducible).

  Each member MUST have:

  <\itemize>
    <item><verbatim|kind>: <verbatim|document> or <verbatim|collection>;

    <item><verbatim|name> and <verbatim|owner>: its line (section 6.5), so that copies of it can be recognised, found by name (section 6.6) and checked against its owner's signatures wherever they are found;

    <item><verbatim|at>: a non-empty list of base URLs where copies of the line may be found, all equal hints (section 6.2), as the <verbatim|at> parameter of <verbatim|sheaf:> URIs (section 6.6); always a list, also of one URL.
  </itemize>

  Each member MAY have <verbatim|doi> (the version DOI), <verbatim|conceptDoi> and <verbatim|cite>, a cached citation (<verbatim|title>, <verbatim|creators> as a list of names, <verbatim|year>, and <verbatim|issued>, the member's <verbatim|Issued> date) so that the collection stays readable, and can be ordered, without resolving its members, also if they become unavailable. <verbatim|cite> is not authoritative.

  <strong|Members of a catalogue> MUST have <verbatim|version>, the pinned object version, and <verbatim|inventorySha512>, the SHA-512 digest of that version's inventory file. Since the inventory of an object version lists every earlier version, the pin fixes the object with all its versions up to it. A member MAY have <verbatim|follow>, <verbatim|"latest">: a curation setting, not a floating reference. A followed member pins the head of the object (for a sealed line, its latest signed version, section 6.5) when the collection version was made; a member without <verbatim|follow> keeps the version its curator pinned, which MAY be earlier than the head, until the curator changes it. A tool maintaining the collection reads the member archive's discovery document (or its feed); when the followed object has a new head, the tool writes a new collection version pinning it, whatever the new head holds (a new document version, a description, a notice, a withdrawal): a catalogue does not judge the versions of its members. A withdrawn member stays, and presentations show the withdrawal. Presentations show the current version of each member, read from the history of the pinned version (section 7.3).

  <strong|Members of a selection> MUST have <verbatim|revisions>: a non-empty list of the revisions vetted, in the order of the document's history, each with <verbatim|documentVersion>, <verbatim|version> (the object version vetted, which holds that document version: when several do, the last of them when the revision was vetted, which is its entry in the history, section 7.3) and <verbatim|inventorySha512> (the digest of its inventory file). They MUST NOT have <verbatim|version>, <verbatim|inventorySha512> or <verbatim|follow> themselves. The revision presented as the selection's is the last of the list. A revision pins the object version that was vetted: descriptions and notices added later by the document's owner are not vetted by the selection, and presentations that show them SHOULD say where they come from; a revision keeps its pin in later versions of the selection. If the document is withdrawn by its owner, the revisions stay vetted, and presentations show the withdrawal as section 11.1 asks, saying that it comes from the member's owner. Tools MUST NOT change revision sets on their own: adding a revision (for instance a corrected version, accepted after review), removing one, or adding or removing a member is a new version of the selection, made by its curator, recorded in the inventory (who and when) with a message saying what was decided. A revision set MAY hold several revisions of the same document, for instance a version accepted and its later correction.

  Every member is pinned: a collection version states exactly which object versions it contains, whole objects up to a version in a catalogue, revisions in a selection. A collection version therefore fixes everything it contains, also across archives; since a pin fixes an inventory, which fixes all its files, collections are hash trees. Pins cannot form cycles.

  <subsection*|10.3 Members of other archives><label|103-members-of-other-archives>

  A member may be kept in another archive. Nothing is copied: the member is resolved as in section 6.4. A reference (a pin without a copy) needs no permission. Copies are of two kinds: mirrors (section 10.4), which are the same line, and branches (section 10.5), which are lines of other owners; accepted copies are branches.

  <subsection*|10.4 Mirrors><label|104-mirrors>

  An archive MAY keep a copy of a line written elsewhere, a mirror: the object's versions up to the latest signed version of the copy it copies (section 13.2), with their inventories, files and witnesses, byte for byte, in its own storage root, at the path its layout gives the object's identifier (section 6.3), together with the key logs of its owners, up to the latest signed versions known (section 6.5). A mirror is the same line, not a new one: its versions are its owner's, checked by its owner's signatures, and nothing in its files names the archive that keeps it, so no mark of a mirror is needed (<verbatim|mirrorOf> is withdrawn, #52). A mirror is brought up to date only by copying the new versions of the line up to its latest signed version, with the new versions of the key logs they name, which is possible because OCFL objects only grow; it MUST NOT be changed otherwise (except to add witnesses, and to record the evidence of forks of key logs, section 6.5), and never drops a version it holds, whatever its status: new versions are added only as section 6.5 says, so a mirror lags at the latest signed version, and a copy that departs from it is a fork, reported. A copy MAY leave out files of a witness folder that are not witnesses (section 6.5): not copying them is not removing them. Mirroring is allowed only if the licences of all the versions copied allow redistribution. A collection MAY list the location of a copy in the member's <verbatim|at>. An archive that keeps a copy of another archive entirely SHOULD be listed in the <verbatim|mirrors> of that archive's discovery document, with the agreement of those who keep it.

  Mirrors serve preservation and access (an institution keeping copies of its members' lines, an independent storage site): they are impartial, like catalogues, and carry every version.

  <subsection*|10.5 Branches and accepted copies><label|105-branches-and-accepted-copies>

  A branch is a line of another owner continuing an object from one of its versions, the branch point: a co-author carrying the work on, a journal keeping the version it vetted and correcting it afterwards. Its genesis record is the object's, so it has the parent's name (section 6.5), or, after a clash, another name of the same genesis record. From its first version, its <verbatim|object.json> records its own <verbatim|owner> and <verbatim|parent>: the <verbatim|owner>, <verbatim|name>, <verbatim|objectVersion> (the branch point), <verbatim|documentVersion> and <verbatim|inventorySha512> of the parent version, and SHOULD record the <verbatim|url> of that object version, an absolute URL (<verbatim|\<less\>storage root URL\<gtr\>\<less\>path\<gtr\>/\<less\>version\<gtr\>/>, with <verbatim|\<less\>path\<gtr\>> the object's path in the layout of the parent's storage root, section 5), so that it can be resolved (section 6.4). Its <verbatim|datacite.json> describes it with the branch owner (for a selection, the body behind it) as <verbatim|publisher> and keeps the relations of the parent version; the first version of a branch, and every version that moves its branch point, SHOULD link the parent version with <verbatim|IsIdenticalTo>: its DOI if it has one, otherwise a <verbatim|URL> (the <verbatim|url> of <verbatim|parent>).

  <strong|A branch is a new object.> Its identifier is its own line, <verbatim|sheaf:\<less\>name\<gtr\>:\<less\>owner\<gtr\>> (section 6.3), and it holds only the branch point and its own versions. It does not continue the parent's object: OCFL inventories record the identifier of their object, every inventory of an object carries the same one, and the parent's are fixed by pins and signatures, so copied versions of the parent's line can only belong to an object with the parent's identifier. Its first object version holds exactly the files of the parent version (every file except <verbatim|datacite.json>, <verbatim|object.json> and the parent version's own evidence, <verbatim|parent.inventory.json>, <verbatim|parent.object.json>, <verbatim|parent.signatures/> and <verbatim|parent.chain/>; the genesis record included), byte for byte, and the evidence of the parent version, as plain files of its content (the field and folder names below are provisional, #55). Signature files, and any witnesses kept beside them, are copied byte for byte, never re-serialised or replaced:

  <\itemize>
    <item><verbatim|parent.inventory.json>, a copy of the inventory of the parent version;

    <item><verbatim|parent.object.json>, a copy of its <verbatim|object.json>;

    <item><verbatim|parent.signatures/>, the parent owner's signature files of the parent version (section 13.2), under their names in the parent's extension folder without the <verbatim|\<less\>version\<gtr\>/> folder (<verbatim|parent.signatures/signature-\<less\>k\<gtr\>.json>), with the witnesses kept beside them (such as timestamp proofs of the <hlink|timestamps extension|opensheaf-timestamps-0.1.tm>), if any;

    <item><verbatim|parent.chain/>, when the parent is itself a branch: the parent version's own evidence (its <verbatim|parent.inventory.json>, <verbatim|parent.object.json>, <verbatim|parent.signatures/> and <verbatim|parent.chain/>), byte for byte, so that the branch carries the chain of its parents back to a version of the originator's line: the grandparent's evidence is at <verbatim|parent.chain/parent.inventory.json> and so on, the great-grandparent's at <verbatim|parent.chain/parent.chain/parent.inventory.json>, one level of <verbatim|parent.chain/> for each generation. A chain is finite, since each level is fixed by a digest recorded in the level below and digests cannot form a cycle; verifiers MAY bound the depth they follow, and report when they stop.
  </itemize>

  Being content, these files are covered by the branch's own inventories and signatures, and never conflict with the parent's identifier. Its later versions are its owner's own, and keep the identity files unchanged until the branch point moves. A branch of a branch names its grandparent through <verbatim|parent.object.json>, and carries its evidence in <verbatim|parent.chain/>: the evidence, with the key logs of the parents' owners, which travel with the branch as owner objects beside it (section 6.5), is self-contained, so that a branch can be checked back to the originator's line after every archive of its parents has gone; a chain grows by one set of evidence files for each level, which is small beside the files of a version. It needs the right to redistribute only the parent version. This is the evidence #22 proposes for accepted copies, completed by the parent owner's signature.

  <strong|Keeping the parent's history.> A branch holds no earlier versions of its parent. A co-author carrying the work on, who wants its whole past at hand, makes a branch and keeps beside it an ordinary copy of the parent's line (section 10.4): the parent's object, under the parent's identifier and at the parent's path (<verbatim|\<less\>parent owner\<gtr\>/\<less\>name\<gtr\>/> in the owner-name layout), with the parent's signatures and key log, in the same archive or anywhere; a reader of the branch follows <verbatim|parent> to it (its <verbatim|url> MAY point to that copy). Nothing is lost: the branch point's files are stored twice only on plain file systems, and once in git, which shares them. This is how Radicle keeps forks: a fork has its own namespace, and the parent's is replicated beside it. A copy of the parent's line is a mirror, allowed only if the licences of its versions allow redistribution (section 10.4; copying by agreement is open, #39).

  <strong|The evidence of a branch.> Its first version shows, without access to the parent, that it is consistent:

  <\itemize>
    <item>the name: a name of <verbatim|genesis.json>, by the algorithm of its last character;

    <item>the parent pin: the digest of <verbatim|parent.inventory.json> equals <verbatim|inventorySha512> of <verbatim|parent>, and its <verbatim|head> is the parent's <verbatim|objectVersion>;

    <item>the files: every file of the head state of that inventory, except <verbatim|datacite.json>, <verbatim|object.json> and the parent's own evidence (<verbatim|parent.inventory.json>, <verbatim|parent.object.json>, <verbatim|parent.signatures/> and <verbatim|parent.chain/>), is present at the same logical path with the same digest, no other file is present besides <verbatim|datacite.json>, <verbatim|object.json> and the branch's evidence, and <verbatim|parent.object.json> has the digest of <verbatim|object.json> in that state;

    <item>the parent: the fields of <verbatim|parent> equal the <verbatim|owner>, <verbatim|name> and <verbatim|documentVersion> of <verbatim|parent.object.json>; <verbatim|parent.name> is a name of this genesis record, by the algorithm of its last character, and is the branch's own <verbatim|name> unless the branch was renamed after a clash (section 6.5), the branch's <verbatim|owner> differs from the parent's, and the parent's owner is the <verbatim|originator> of the genesis record, or <verbatim|parent.object.json> declares a <verbatim|parent> of its own (the parent is itself a branch);

    <item>the genesis record: <verbatim|genesis.json> is in the head state of that inventory with the same digest;

    <item>the parent owner's key log: the owner object of the parent's <verbatim|owner>, kept beside the branch (section 6.5), is a valid key log (section 6.5), and includes the version the signatures name, with the digest in their <verbatim|keyLog>; a key-log version not found leaves the parent's signatures unchecked (section 13.2), which is reported, and is not a failure of this check; an owner that has ended, or whose key log is forked, is reported;

    <item>the parent's signature: the parent version is signed (section 13.2) when the signature files in <verbatim|parent.signatures/>, of the parent's owner, are good signatures of it from <verbatim|threshold> distinct keys of one key-log version, or when the verifier finds a signed version of the parent's line that extends it (section 6.5); it is <strong|unchecked> when it would be signed if its unchecked signatures were good; otherwise it is not a version, a failure of this check;

    <item>the chain: when <verbatim|parent.object.json> declares a <verbatim|parent>, <verbatim|parent.chain/> holds the parent version's evidence, each file with the digest that <verbatim|parent.inventory.json> records for it, and that evidence passes the same checks, level by level, until a parent whose owner is the <verbatim|originator> of the genesis record and that declares no parent.
  </itemize>

  Since every owner signs its versions (section 6.5), this evidence is complete: the parent pin and the files show that the branch is consistent, and the parent owner's signature, checked against its key log, shows that the parent version is that owner's, without access to wherever the parent's line is kept. A branch MUST therefore hold <verbatim|parent.signatures/>, and <verbatim|parent.chain/> when its parent is a branch, at each of its branch points, and its copies MUST carry the key logs of its parents' owners (section 6.5); a copy without one of them leaves the signatures that need it unchecked, and the branch point unchecked (section 14). When a parent's owner later ends, or its key log forks, the branch point stays confirmed, since signatures stay good; readers weigh it as they weigh that owner's history (section 6.5). Without <verbatim|parent.signatures/>, or when they leave the parent version not a version, the branch shows only that someone made a parent inventory that agrees with itself, and is inconsistent (section 14).

  <strong|Moving the branch point.> A branch MAY take a later version of its parent's line as a new branch point: a journal that vets the authors' corrected version. The new parent has the same <verbatim|owner> and <verbatim|name> as the previous one, a higher object version, and a document version later than the previous branch point's in the history of the new parent version (its <verbatim|parent.object.json>, section 7.3; without <verbatim|history>, a higher number), not merely a higher number (a parent version that only changes the description, such as a DOI added, is not a new branch point); a branch point never moves back, and is never dropped. The object version that moves it is the one whose <verbatim|parent> differs from the previous version's; it holds exactly the files of the new parent version, as the first version of a branch does, with new evidence (<verbatim|parent.inventory.json>, <verbatim|parent.object.json>, <verbatim|parent.signatures/> and <verbatim|parent.chain/>), and is checked like that first version (this drops the files of the branch's own notes, such as the files of its notices, which section 7.3 keeps in every later version: how a move keeps them is open, section 6.5), and also for continuity: the new parent inventory continues the previous one: both MUST have the same <verbatim|id>, every entry of <verbatim|versions> in the previous one is equal, as a JSON value, to the entry of the same version in the new one, and every digest of those entries is in the manifest of the new one. This shows, from the branch alone, that the corrected version continues the version first vetted. The branch stays one sequence of versions under one owner, numbered as section 7.3 says.

  <strong|Accepted copies.> An accepted copy is a branch kept by a selection from a revision it vetted. Its owner is the owner of the selection (an owner with a key log, for the body behind it: a journal, a review journal), and MUST differ between selections that keep copies of the same document, also in one archive, and MUST NOT be the originator (section 6.5): two selections are two owners, hence two lines. Its later document versions are acts of the selection's curator (a corrected version accepted, a notice, a withdrawal); the authors' later versions change nothing in it. The selection lists the accepted copy as its member; it MAY list the original revision set as well. A branch is not a mirror: it is another line, with its own inventories, and its own versions cannot stand for the parent in the resolution of a pin (section 6.4), so a location holding only the branch is never given in <verbatim|at> for the parent; a copy of the parent's line kept beside it is a mirror like any other.

  A version that the selection makes itself, such as a journal's typeset version of record, is a later version of the selection's branch, with the selection as <verbatim|publisher>, the authors' agreement in <verbatim|object.json> (section 9), and relations to the authors' versions (sections 7.3 and 8.1). A branch carries versions of the same work: typesetting, copy-editing, corrections, notices. A derived work (a translation, an abridgement, a commentary or review, a collected edition) is a new object, with its own genesis record and a relation to its source (section 8.1).

  <strong|Open question: numbering on branches.> The branch point keeps its document version (version 3 stays version 3). Later versions of the branch either (a) continue the numbering within the branch (the journal's version 4, distinct from the authors' version 4, the owner telling them apart), or (b) are numbered from the branch point (3.1, 3.2), which reads more clearly but makes <verbatim|documentVersion> more than an integer.

  <subsection*|10.6 Rights><label|106-rights>

  The member list of a collection is placed under CC0. The licence of a collection never extends to its members. Mirrors and branches keep the licences of what they copy.

  <section*|11. Withdrawal and takedown><label|11-withdrawal-and-takedown>

  <subsection*|11.1 Withdrawal><label|111-withdrawal>

  A document or collection is withdrawn (for instance retracted by its authors) by a description-only version whose <verbatim|object.json> has <verbatim|status> <verbatim|withdrawn> and a <verbatim|withdrawal> object with a <verbatim|date> and a <verbatim|reason> (a note, section 9), and whose <verbatim|datacite.json> has the same date as <verbatim|Withdrawn>. The status belongs to the object, whatever document version its head holds. Its content is kept, its history remains verifiable, and the discovery document lists it with <verbatim|status> <verbatim|withdrawn>. Presentations MUST show the withdrawal notice with the document.

  <subsection*|11.2 Takedown><label|112-takedown>

  When content must be removed (by law, or for a breach of rights), the object is deleted from the storage root, together with the folders above it that the deletion leaves empty (the folder of an owner in the owner-name layout, the folders of the hash in the hashed layout, section 5; OCFL forbids empty folders in a storage root), and a tombstone MUST be added to the discovery document.

  <strong|Owner objects.> A takedown of a line does not take down the owner objects whose key logs its copies carry (section 6.5): they are CC0 metadata (section 16) under pseudonymous owner names, and every line, branch and copy that those owners signed, in that archive and in others, needs them to be checked. An archive MUST keep an owner object as long as it keeps an object whose signatures need it (section 6.5), except when the owner object is itself taken down, and MAY keep it after. An owner object is taken down only for itself: at its owner's request, by a statement signed by <verbatim|threshold> keys of the latest version of its key log, or by law; for an owner that has ended or whose key log is forked, only through its keeper or by law. Whoever holds a current key can make such a statement, so an archive SHOULD also hear the owner's keeper (section 6.5), when it names one, before acting on a statement alone. Its line then gets a tombstone like any other (section 11.3); the signatures of that owner in the objects the archive still keeps cannot be checked there, so they are unchecked (section 13.2), and the versions and branch points that rely on them are unchecked, not invalid or inconsistent, until the key log is found elsewhere. The rule that a copy carries its owners' key logs (section 6.5), and the checks of section 14, then accept the tombstone in place of the owner object. An owner object restored later, with the same genesis record and a key log whose versions extend the version the tombstone pins, is the same line returning, not a reuse of its identifier (section 11.3).

  <subsection*|11.3 Tombstones><label|113-tombstones>

  A tombstone records <verbatim|id>, <verbatim|kind>, <verbatim|lastVersion>, <verbatim|inventorySha512> of that version, <verbatim|date> and <verbatim|reason> (plain text, since the discovery document has no content files), and, for an object with a genesis record, its <verbatim|name>, <verbatim|owner> and <verbatim|genesisName> (the name of its genesis record by algorithm 0, the same for every line of the work), which it MUST record, so that its line stays taken in that archive and a genesis record is compared with it whatever the algorithm of its lines' names (section 6.5). Drafts leave no tombstone. Identifiers of tombstoned objects MUST NOT be reused, except by the same line returning (an owner object restored, section 11.2). Verifiers report a pin to a tombstoned object as "removed", not as a corruption. A tombstone is not signed, so a host can add one falsely: a resolver that meets a tombstone keeps looking at other locations and indexes; when it finds a valid copy elsewhere, it reports the copy as found, and the tombstone beside it. External copies (DOI records, snapshots) follow the rules of their services.

  Note: OCFL 1.1 has no way to remove files from an object short of deleting and rebuilding it. Physical deletion of files, and the flagging of lost or corrupted files, are accepted as in scope for OCFL version 2, with a tombstone or status recorded in the inventory. When that mechanism is published, a later version of this specification will adopt it for takedowns of single files.

  <section*|12. Versioning of this specification><label|12-versioning-of-this-specification>

  This specification is versioned MAJOR.MINOR.PATCH, a form of semantic versioning adapted to a format:

  <\itemize>
    <item>a <strong|major> version (1.0, 2.0) may make incompatible changes;

    <item>a <strong|minor> version (1.1, 1.2) only adds: every file valid under 1.x remains valid under 1.y for y \<gtr\> x, with the same meaning;

    <item>a <strong|patch> version (1.1.1) corrects or clarifies the text without changing any requirement.
  </itemize>

  Before version 1.0, any change of the minor version (0.1, 0.2, ...) may be incompatible, as semantic versioning allows for initial development.

  Every JSON file defined here declares its format version, and the discovery document and every <verbatim|object.json> declare the version of this specification, both as MAJOR.MINOR only (for instance <verbatim|"opensheaf-object/0.1"> and <verbatim|"0.1">): a patch version never changes what is valid, so files do not record it.

  A reader that finds a major version it does not know (or, before 1.0, a minor version it does not know) SHOULD report it and MUST NOT silently treat the files as valid. A reader that finds a later minor version of a major version it knows (from 1.0) reads the files as that major version, ignoring properties it does not know, and SHOULD report the version. For this to work, readers MUST ignore unknown properties in files of a major version they know, and the schemas of this specification do not forbid additional properties.

  While a version is a draft, successive drafts are identified by the date in the heading and by the changelog (section 17). The text of each version is published at <verbatim|https://opensheaf.org/opensheaf-specification-\<less\>MAJOR.MINOR\<gtr\>.md> and is not changed after the version is final, except by patch versions, which are listed in its changelog.

  <section*|13. Integrity and authenticity><label|13-integrity-and-authenticity>

  <subsection*|13.1 Integrity><label|131-integrity>

  Integrity rests on OCFL digests: every file is fixed by its SHA-512 digest in the inventory, every inventory by its checksum file, and every collection version pins its members by inventory digest. Inventories MAY also record MD5 and SHA-256 digests in their <verbatim|fixity> block; archives following the Zenodo binding MUST record MD5 (appendix A).

  <subsection*|13.2 Authenticity and dates><label|132-authenticity-and-dates>

  Digests show that files were not changed; they do not show who made them or when. With the proposal of section 6.5, every sealed object version is signed by the owner of its line, and MAY be timestamped and witnessed by others. Witness files are kept in the object's extension folder <verbatim|extensions/opensheaf-witnesses/>, so that they travel with the object when it is copied or mirrored. OCFL allows object extension folders, which are not part of any version; the extension name <verbatim|opensheaf-witnesses> is not yet registered with OCFL, so validators may warn about it. Witnesses can be added later, by the owner of the line or by others, and are never replaced once made (a completed timestamp proof is a new file beside the pending one, as the <hlink|timestamps extension|opensheaf-timestamps-0.1.tm> says); they are not covered by the inventory digests, and need not be, since a signature is checked against the version it names, which the pins fix, and a timestamp against the signature file it stamps.

  <strong|Signature files.> An owner's signature of object version <verbatim|\<less\>version\<gtr\>> is a JSON file <verbatim|\<less\>version\<gtr\>/signature-\<less\>k\<gtr\>.json> in the extension folder, one for each key that signs, where <verbatim|\<less\>k\<gtr\>> is the first 16 characters of the lowercase base32 (RFC 4648, without padding) SHA-256 digest of the key's <verbatim|did:key> URI, as UTF-8, so that file names never collide after keys rotate, and a reader that knows the keys of the key log builds every name without listing the folder, which plain web servers do not allow. It has:

  <\itemize>
    <item><verbatim|format>: <verbatim|"opensheaf-signature/0.1">;

    <item><verbatim|object>: the identifier of the object, <verbatim|sheaf:\<less\>name\<gtr\>:\<less\>owner\<gtr\>> (section 6.3);

    <item><verbatim|version>: the object version signed, <verbatim|\<less\>version\<gtr\>>;

    <item><verbatim|inventorySha512>: the SHA-512 digest of that version's inventory file, as its checksum file states it;

    <item><verbatim|signer>: the owner name of the signer, which for an owner's signature MUST be the owner part of <verbatim|object> (the line's owner);

    <item><verbatim|key>: the <verbatim|did:key> of the key that signs, one of the <verbatim|keys> of the key-log version named;

    <item><verbatim|keyLog>: that key-log version, as a <verbatim|sheaf:> URI with a digest, <verbatim|sheaf:\<less\>owner\<gtr\>/v\<less\>n\<gtr\>?sha512=\<less\>digest\<gtr\>>, a pin of the owner object (section 6.6), whose owner MUST be <verbatim|signer>; for a signature of a key-log version vN+1 it names vN, and for the first version, the first version itself (section 6.5). A third party signs as a witness, never in a signature file (below);

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

  The first line separates these signatures from any other use of the key; the others bind the signature to one object, one version, its inventory, and the key-log version that says which keys may sign, so that none of them can be changed, nor the signature moved to another object or another key-log version, without breaking it. A verifier rebuilds the message from the fields of the signature file and verifies the signature.

  <strong|Statuses.> A signature file is:

  <\itemize>
    <item><strong|invalid> when it is malformed, its name does not match the digest of its key, its signature does not verify, its <verbatim|object>, <verbatim|version> and <verbatim|inventorySha512> are not those of the version whose folder holds it (in <verbatim|parent.signatures/>, of the parent version; the digest also in its checksum file), its <verbatim|signer> is not the line's owner, the key log reaches the version named, with that digest, and the key is not listed in its <verbatim|keys>, or the version named follows one with <verbatim|ended>, or, for a signature of a line, has <verbatim|ended> itself (section 6.5);

    <item><strong|unchecked> when it is not invalid but the reader cannot reach the key-log version it names, with that digest (the key log is absent, taken down, section 11.2, or shorter); anyone can name a key-log version that does not exist, so archives never add versions that rely on such signatures (section 6.5);

    <item>otherwise <strong|good>, for ever: later versions of the key log, an end or a fork never change it (section 6.5).
  </itemize>

  A version of a key log is <strong|signed> when at least <verbatim|threshold> distinct keys of the version before (for the first version, of itself), <verbatim|threshold> being that version's, have good signature files naming it; key logs are read version by version, and a version after one with <verbatim|ended> is not a version of the key log; at a fork, the versions each side holds stay versions, and the owner is treated as ended (section 6.5).

  A version of a line is:

  <\itemize>
    <item><strong|signed> when it is <strong|signed directly>, at least <verbatim|threshold> distinct keys of one key-log version, <verbatim|threshold> being that version's, having good signature files naming that version, or <strong|vouched for>, a later version of the same line signed directly extending it, since its inventory fixes it (sections 6.5 and 7.1); a version vouched for needs no signatures of its own;

    <item><strong|unchecked> when it is not signed, but would be if its unchecked signatures were good;

    <item>otherwise <strong|not a version> of the line, wherever it is found, and never shown as one: reported as <strong|unsigned> (too few signature files of the owner) or <strong|invalid>.
  </itemize>

  An unchecked version is kept, and shown with its status, until the key log is found. Nothing relies on a version that is not signed: not a pin, a resolution, a collection member or a branch point, and archives do not add it (section 6.5). Files that are not witnesses (section 6.5) are reported, never fatal, and kept; a copy MAY leave them out (section 10.4). Signature files, and the witnesses kept beside them, are never re-serialised or replaced once made, here or in <verbatim|parent.signatures/>, since witnesses such as timestamps are made of their bytes.

  <strong|Timestamps.> The <hlink|timestamps extension|opensheaf-timestamps-0.1.tm> keeps timestamps of signature files beside them, dates that readers may weigh; a verifier that does not know it ignores them, as any witness it does not know.

  <strong|Others' witnesses.> A signature by someone other than the owner (a third party attesting a version) is <verbatim|\<less\>version\<gtr\>/witness-\<less\>label\<gtr\>.json>, where <verbatim|\<less\>label\<gtr\>> is chosen by whoever adds it and matches <verbatim|^[a-z0-9]+(-[a-z0-9]+)*$>, with the fields and the signed message of a signature file, <verbatim|signer> and <verbatim|keyLog> naming the signer's own owner object, which MUST NOT be the line's owner, and whose key log the copy MAY keep beside it (section 6.5). It is a witness, not a signature of the line.

  <strong|Copies and branches.> A copy of an object copies its witnesses with it, and keeps the key logs of its owners up to the latest versions known (section 6.5). A branch holds the evidence of each branch point, the parent owner's signatures, in its content (section 10.5), not among its witnesses, and its copies carry the key logs of its parents' owners as owner objects beside it (section 6.5); the branch's own versions are signed by the branch's owner like any line. Witnesses of the parent's signatures (such as timestamp proofs) are kept beside them in <verbatim|parent.signatures/>, and other witnesses of a parent version (a third party's signature) MAY be kept with them.

  External deposits (appendix A) and software archive snapshots are further witnesses. Archives kept in git MAY also sign their commits or tags, but git hashes are not part of the integrity chain of this specification.

  <section*|14. Verification><label|14-verification>

  A verifier checking an archive MUST:

  <\itemize>
    <item>validate the discovery document, and every <verbatim|object.json> (<verbatim|parent.object.json> included), <verbatim|members.json>, <verbatim|genesis.json>, <verbatim|keys.json> and signature file, including those inside <verbatim|parent.signatures/> and <verbatim|parent.chain/>, against the schemas (a stray or malformed signature file is reported, never fatal) of their declared versions (and the index files of section 6.6, if present), checking formats (dates, URIs) as assertions, which JSON Schema 2020-12 leaves optional;

    <item>validate the storage root and every object against OCFL 1.1 (with a standard OCFL validator or equivalent checks), and check that the storage root's <verbatim|ocfl_layout.json> names the layout given by <verbatim|storageLayout>, that its configuration does not change the parameters of section 5, and that every object is at the path that layout gives;

    <item>check that the discovery document lists the objects of the storage root with their kinds, head versions, inventory digests and status as their head versions state them, and that no listed object has the identifier of a tombstone; a verifier reading the archive over HTTP cannot list folders, so it checks the listed objects and reports that completeness was not checked, while a verifier with access to the files also checks that no object is missing;

    <item>check the requirements of sections 7 to 11 on every object version, including that <verbatim|datacite.json> and <verbatim|object.json> agree on the document version and on the date of a withdrawal, and that <verbatim|Available>, for a version first made public by the archive, is the date of its deposit (section 8);

    <item>check the document versions of each document (section 7.3): object versions with the same document version have the same sources, renditions and change note, except that a version with <verbatim|sourcesMissing> may be completed by adding files (section 7.3); new numbers follow the rule of new versions, without gaps (for a branch, from the document version of its first branch point, a version that moves the branch point taking the next number); <verbatim|history>, when present, lists distinct document versions, covers all of them, each entry being the last object version holding its document version; no object version after the first one with <verbatim|history> lacks it; every notice is kept unchanged in every later object version;

    <item>check that each <verbatim|members.json> has a <verbatim|type>, that the members of a catalogue have <verbatim|version> and <verbatim|inventorySha512>, and that the members of a selection have <verbatim|revisions> and none of <verbatim|version>, <verbatim|inventorySha512> or <verbatim|follow>, with distinct document versions;

    <item>for the head of each collection, resolve each member (each revision, in a selection) as in section 6.4 and check its pin, and for earlier collection versions check the pins of members of the archive itself (resolving the members of other archives for every earlier collection version is OPTIONAL); for a revision, check that the pinned object version holds the stated document version; check the <verbatim|name> and <verbatim|owner> of each member against the <verbatim|object.json> of the pinned version, and that the pinned version is signed by its owner (section 13.2); check that no pin names a draft (section 6.5); report each as verified, mismatch (a copy was found and does not match), unchecked (the pinned version is unchecked), not a version (section 13.2), unavailable (no copy found) or removed (tombstoned);

    <item>for each owner object (section 7.5): that its first version holds a genesis record of kind <verbatim|owner> whose name is the owner name and whose <verbatim|keys> (as a set) and <verbatim|threshold> are those of its first <verbatim|keys.json>; that every <verbatim|threshold> is at most the number of keys; that every version is signed by <verbatim|threshold> keys of the version before it (of its own, for the first), naming it; that no version follows one with <verbatim|ended>, and that <verbatim|successor> appears only with <verbatim|ended> and differs from the owner name; and the evidence of forks it keeps, reporting ended and forked owners (section 6.5); for every object, that the storage root holds the key logs its signatures need, or the tombstones of those taken down (section 6.5), reporting when a later version of a key log is known elsewhere; and for every line, its latest signed version and the status of each of its versions, as in section 13.2 (the signed message rebuilt, each key counted once): unchecked versions are reported, and so are files that are not witnesses, never fatal; a version that is not a version of the line is reported as a breach of the rule on adding versions (section 6.5), not as a failure of verification, since a verifier cannot tell when it was added and the archive cannot remove it, while the checks an archive runs on what it adds fail on it (the git companion, section 10);

    <item>for each object with a genesis record (section 6.5): that <verbatim|genesis.json> is the same in every object version, that <verbatim|name> is its digest by the algorithm named in its last character, that its <verbatim|kind> is the <verbatim|kind> of <verbatim|object.json>, that the identifier of the object is <verbatim|sheaf:\<less\>name\<gtr\>:\<less\>owner\<gtr\>>, that <verbatim|owner> and <verbatim|name> do not change between versions, that no two objects of the archive, nor an object and a tombstone, have the same <verbatim|name> and <verbatim|owner>, that a line without <verbatim|parent> is named by algorithm 0, is owned by the originator its genesis record names (an owner object by itself) and is signed by it from its first version, that objects with the same genesis record (compared by its algorithm-0 name, also against tombstones' <verbatim|genesisName>) are that line and branches whose chains of parent evidence hold back to it, that the discovery document lists the head's <verbatim|name> and <verbatim|owner>, and that a line whose owner is not the originator declares a parent and that the originator's line declares none; and that drafts are only at the path of <verbatim|sheaf:draft:\<less\>id\<gtr\>> (<verbatim|draft/\<less\>id\<gtr\>/> in the owner-name layout), unlisted in <verbatim|objects> and in the indexes;

    <item>for each branch (section 10.5): the evidence of its first version, including the parent owner's signature, against the key log of its owner object kept beside the branch, and, for a branch of a branch, the chain of <verbatim|parent.chain/> back to the originator's line, each level against the key log of its owner, and that its later versions keep the identity files unchanged until a version that moves the branch point; for every branch, that its <verbatim|owner> differs from the <verbatim|owner> of <verbatim|parent>, that <verbatim|parent.name> is a name of its genesis record and its own <verbatim|name> unless it was renamed after a clash, that a renamed branch has an algorithm number greater than that of <verbatim|parent.name> (a failure otherwise), and that its owner is not the originator; reporting as a warning, not a failure, a rename that neither the objects nor the tombstones of the archive justify, or a number that is not the smallest free one, since the line that caused it may be kept elsewhere; that the parent's owner is the <verbatim|originator> of the genesis record or the parent version's <verbatim|object.json> (<verbatim|parent.object.json>) declares a <verbatim|parent> of its own, and declares none when the parent's owner is the originator; for every version that moves the branch point, the same evidence, that the new parent has the same <verbatim|owner> and <verbatim|name> as the previous one and a higher object version holding a document version later than the previous branch point's in the history of the new parent version, and the continuity of the two parent inventories (section 10.5); for each branch point, report the first of these verdicts that applies: inconsistent (a check fails, including a parent version that is not a version, or the parent was resolved and does not match), confirmed (the parent version is signed, against its owner's key log, section 10.5), unchecked (consistent, but the parent version is unchecked, section 10.5); report as the branch's verdict the weakest of those of its branch points (inconsistent, unchecked, confirmed, from the weakest); and report separately whether the parent was found, unavailable or removed (tombstoned), and whether it is withdrawn;

    <item>where several copies of a line or of a key log are known (mirrors, members, branches' parents), that they agree (section 6.5), reporting a fork with the status of each side and where each copy was found (section 6.6), and checking the evidence of forks that objects keep.
  </itemize>

  A verifier SHOULD check the witnesses it finds, the indexes the archive declares (section 6.6: every entry agrees with the objects and starts with its file's prefix, every object with a genesis record and every sealed version is listed, and tombstoned objects are listed as <verbatim|removed> in <verbatim|names/> and <verbatim|sha512/>), the requirements of the profiles the archive declares, and those of the extensions it knows; it SHOULD report the extensions it does not know, which do not make an archive fail verification. It MUST NOT treat the presentation as authoritative. It SHOULD limit the depth and size of the collections it follows, and report when it stops.

  <section*|15. Security considerations><label|15-security-considerations>

  <\itemize>
    <item><strong|Untrusted inventories.> Inventories, logical paths and member lists from other archives are untrusted input. Verifiers MUST reject logical paths that break the rules of section 7.1 (absolute, with <verbatim|.> or <verbatim|..> segments, not in Unicode normalisation form C), and SHOULD limit the size of the files they fetch.

    <item><strong|Archives of sources.> Tools unpacking source archives (appendix A) MUST guard against paths leaving the target folder and against archives that expand to excessive sizes.

    <item><strong|Presentation.> A website MUST NOT embed HTML of other archives in its own pages; it links to them. Documents' HTML versions are generated by the archive's own tools.

    <item><strong|Subdomains.> A domain that offers subdomains to archives (as <verbatim|opensheaf.org> does) MUST remove the DNS records of abandoned archives, to prevent takeover by others.

    <item><strong|Weak hashes.> SHA-1 (as in most git repositories) and MD5 are not used for integrity: MD5 appears only for comparison with external services.

    <item><strong|Branches and owners (proposal).> The evidence a branch carries, and the key logs of its parents' owners beside it, are untrusted input, checked like inventories from other archives. Every line is signed by its owner, and archives add only signed versions, so no archive can add to another owner's line, and a version let in against the rule blocks the owner's version of that number in that archive (section 6.5).

    <item><strong|Keys (proposal).> A signature stays good whatever later happens to the key log; since the core does not date signatures, an exposed key or a fork ends the owner (section 6.5). A copy that withholds the later versions of a key log hides an end, and an owner that loses every key cannot even end; its keeper can only name a successor in <verbatim|successors> (section 6.5), which readers weigh.

    <item><strong|Reused genesis records (proposal).> A genesis record names its originator, whose signature no one else can make, so reusing it for another work gives no valid line; a branch carries the chain of its parents' evidence back to the originator's line, so a chain of branches cannot escape the check; an archive accepts an object whose genesis record it holds (compared by its algorithm-0 name, also against tombstones) only when it is signed by that originator or carries a chain of parent evidence that holds (section 6.5). Lines cannot be written under another owner, since only signatures decide whose a version is.

    <item><strong|Short forms (proposal).> Another owner can make lines whose names start with a given short form, and so make it ambiguous, but cannot take it over, since only an owner signs its lines (section 6.6); files record only complete names, and printed short forms are long enough (16 characters) not to be searched for.

    <item><strong|Resolving without a digest (proposal).> A copy found anywhere is checked by its owner's signatures, so it cannot be forged; but a copy that stops at an earlier version looks complete by itself, so a resolver uses the latest signed version among the copies it found, and says where it found them (section 6.6). A gateway that fetches URLs given in links guards against requests to private addresses and against large responses, does not serve archives' files from its own origin, and redirects only, and only temporarily, to copies it has checked, so that a link through it cannot send readers to a forged copy.

    <item><strong|Mutable maps.> The discovery document, the indexes and presentation files can be changed by whoever controls the server; their statements are only trusted after checking them against the storage root and the pins.
  </itemize>

  <section*|16. Privacy and rights><label|16-privacy-and-rights>

  <\itemize>
    <item><strong|Documents.> Each document carries the licence chosen by its authors in <verbatim|rightsList>. "All rights reserved" is allowed: deposit grants readers access, not reuse.

    <item><strong|Metadata.> <verbatim|datacite.json>, <verbatim|object.json>, <verbatim|members.json>, inventories and the discovery document (and, with the proposal of section 6.5, <verbatim|genesis.json>, <verbatim|keys.json>, signature files, <verbatim|parent.inventory.json>, <verbatim|parent.object.json>, <verbatim|parent.signatures/>, <verbatim|parent.chain/> and the index files) are placed under CC0, so that they can be harvested and mirrored freely.

    <item><strong|Personal data.> Archives record only the personal data needed to describe and cite the work (names, identifiers, affiliations) and the depositor of each version. The depositor is recorded in the inventory (section 7.1). Agreement records are minimal (section 9). A request to erase personal data from an immutable history is handled by a takedown (section 11.2); with the proposal of section 6.5, the tombstone and the indexes then keep the name and the owner name, which identify no person by themselves.

    <item><strong|Owners (proposal).> The <verbatim|originator> of a genesis record, and the <verbatim|owner> and <verbatim|parent> of every version, are owner names, copied into every copy and branch and never removable from them. An owner name is the digest of a genesis record holding a random nonce, so it identifies no one by itself; an owner is tied to a person or an institution only through its optional <verbatim|keeper> and the keeper's confirmation (section 6.5), which the keeper can withdraw. An owner who must stay anonymous, such as the referee of a report (#29), SHOULD use an owner made for that purpose, without <verbatim|keeper>; the <verbatim|user> of the inventory and <verbatim|by> of an <verbatim|agreement> MUST then not identify them either, since they are copied too.
  </itemize>

  <section*|17. Changelog><label|17-changelog>

  <\itemize>
    <item><strong|0.1 (draft), 13 November 2026:> first version.

    <item><strong|0.1 (draft), 13 November 2026, revision:> collections are archive collections or selections (<verbatim|type> in <verbatim|members.json>): an archive collection pins objects whole and may follow them; a selection pins revision sets, the document versions it vetted, and changes only by an act of its curator. A member of an archive collection without <verbatim|follow> may stay at an earlier version; a revision pins the last object version holding its document version when it was vetted; accepted copies are never listed as mirrors; verifiers resolve remote members for the head of a collection. Mirrors (whole objects, <verbatim|mirrorOf> in the discovery document) and accepted copies (one vetted revision, as a document of the selection's archive) are defined. <verbatim|follow> is for archive collections only, and follows the head.

    <item><strong|0.1 (draft), 14 November 2026, revision:> extensions (section 4): specifications published separately, whose data <verbatim|object.json> records under <verbatim|extensions>, keyed by their names; the discovery document should list them; they never change the core, and verifiers report those they do not know.

    <item><strong|0.1 (draft), 14 November 2026, revision:> the impartial kind of collection is named catalogue (<verbatim|type> <verbatim|catalogue> in <verbatim|members.json>), formerly archive collection, so that it is not confused with an archive.

    <item><strong|0.1 (draft), 14 November 2026, revision:> <verbatim|Presentation> (slides) named among the values of <verbatim|resourceTypeGeneral> (section 8).

    <item>**0.1 (draft), 14 November 2026, proposal (branch <verbatim|proposal/identity>, not yet agreed):** names from genesis records; owners (none for drafts, named or keyed) and lines (owner, name) with a single writer each; branches, deep and shallow, of which accepted copies are a case, and the evidence a shallow branch carries; verification of names, lines and branches; schemas for <verbatim|genesis.json> and the new fields (#13, #14, #20, #29).

    <item>**0.1 (draft), 14 November 2026, proposal revised after review (branch <verbatim|proposal/identity>):** branches start from the document version of their branch point; the rules of a line apply from its first version, so deep branches keep the parent's earlier versions unchanged; a shallow branch also copies <verbatim|parent.object.json>, which makes every <verbatim|parent> field checkable, and does not copy its parent's parent files; the evidence proves consistency only; signatures of keyed owners defined (Ed25519 for <verbatim|did:key>, OpenPGP with the key kept in the object), witness files named by signer; verdicts ordered, with <verbatim|inconsistent> and the parent's availability reported separately; agreement of copies defined by version inventories; <verbatim|genesis.json> never re-serialised; tombstones carry name and owner; the DataCite description of branches restored; open questions listed.

    <item>**0.1 (draft), 14 November 2026, proposal revised after a second review (branch <verbatim|proposal/identity>):** sealing is the first time a version leaves its owner's hands (#29), drafts are marked outside their content and objects made before the proposal keep their pins; keyed branches sign after the branch point; witness files named exactly (owner, third parties with a sidecar naming the signer, the parent's under <verbatim|parent/>); resolution of a parent (<verbatim|parent.url> recommended); exact checks of shallow and deep branches, identity files kept in every version of a shallow branch and their names reserved; verification of <verbatim|genesis.json>, of names and owners in the discovery document and members; owners compared as strings, in canonical forms; <verbatim|did:key> and OpenPGP subkeys specified; existing objects may choose their owner; branch numbering marked provisional; security considerations for branches and owners; the example name is the real digest; "owner" of an archive written "archive owner".

    <item>**0.1 (draft), 14 November 2026, proposal revised after a third review and the issues (branch <verbatim|proposal/identity>):** a draft is an object without a genesis record, which must not be pinned; every sealed object has one (archives made before are rebuilt); sealing explicit, at the owner's request; a line may move its branch point to a later version of another line of the same name, with the same evidence; each selection is an owner of its own; a derived work is a new object; agreement for a deep branch recorded in <verbatim|agreement>; a resolved parent confirms only through a location known independently of the branch; attested witnesses listed; deep-branch and mirror checks precise; third-party signatures in the owners' forms; a privacy note on owners; open questions completed from #13, #14, #20, #29 and #33; #22 cited.

    <item>**0.1 (draft), 14 November 2026, proposal revised after a fourth review (branch <verbatim|proposal/identity>):** a branch moves its branch point only to a later version of its parent's line, never back; the moving version takes the branch's next document version; continuity of two parent inventories defined; witnesses of each branch point in <verbatim|parent/\<less\>w\<gtr\>/>; a verdict per branch point, the weakest for the branch; the originator's line has no parent; owners of accepted copies differ between selections; the sealing version keeps its document version; no pin names a version without a genesis record; a resolved parent confirms only from a base URL known independently; the examples carry names and owners; privacy of depositors of anonymous owners.

    <item><strong|0.1 (draft), 15 November 2026, revision:> section 5 points to the companion document OpenSheaf archives in git, in place of a deployment guide.

    <item>**0.1 (draft), 15 November 2026, proposal (branch <verbatim|proposal/identity>):** <verbatim|sheaf:> URIs for objects, lines, document versions and pins (section 6.6), the owner defaulting to the originator; owner identifiers (the digest of the owner's URI); short forms of at least 8 characters, resolved within one owner by the order of its lines and otherwise listed as ambiguous; indexes by name (with the originator), owner and inventory digest, grouped by two characters, with their schema; an <verbatim|at> hint, outside the identity; gateways serving a URI after their base URL, the gateway's domain and form still to be decided (#14, #20).

    <item>**0.1 (draft), 15 November 2026, proposal revised after a fifth review (branch <verbatim|proposal/identity>):** <verbatim|sheaf:> URIs: query grammar, case, percent-encoding of <verbatim|at>, canonical form and equality; <verbatim|/v\<less\>n\<gtr\>> names only sealed versions of the line; a pin checks name, owner and document version; copies found without a digest are confirmed only through the owner's archive or keys, others reported as unconfirmed, forks reported; gateways answer with real statuses, do not serve archives' files, and fetch safely; short forms ordered only among confirmed lines, unconfirmed ones shown as warnings; indexes declared (<verbatim|indexes>, <verbatim|indexes.json>) with prefixes of 2 to 4 characters, sealed versions only, tombstones kept as <verbatim|removed>, <verbatim|owners/> listing each owner's names; resolvers as a conformance class; printed short forms of 16 characters; the replacement of #14's <verbatim|tag:> decision stated; the example ORCID iD given a valid check digit, and the example name recomputed.

    <item>**0.1 (draft), 15 November 2026, proposal revised after a sixth review (branch <verbatim|proposal/identity>):** a branch point moves only to a higher document version; how a move keeps the branch's own files (notices, a version of record) is an open question, probably a merge; identity versions apply to sealing an existing draft; the parent line's validity checked (the parent's owner is the originator or a branch, owners differ, names agree, the originator's line has no parent); deep branches' witnesses and first moves; resolver and gateway rules written with MUST; drafts and sealing defined, sealing at the owner's request before sharing; document versions numbered by the line's owner; open questions merged and linked to #35 and #36, takedowns widened (#33); <verbatim|IsIdenticalTo> prefers a DOI; CC0, <verbatim|.gitattributes> and validated files list the new files; examples: placeholders stated, the accepted copy listed by the selection; resolution uses the latest head and declares forks among confirmed copies only, unconfirmed ones reported as warnings; a third party's signature attests only when the verifier trusts the signer, and a timestamp proves existence by its date; the canonical form of a <verbatim|sheaf:> URI omits the originator's owner part; a copy is confirmed through the archive that keeps the line (its <verbatim|archiveId>), which confirms the archive, not the person; a line keeps one archive and one object identifier.

    <item>**0.1 (draft), 15 November 2026, proposal revised after a seventh review (branch <verbatim|proposal/identity>):** <verbatim|sheaf:\<less\>name\<gtr\>> names the originator's line and <verbatim|sheaf:\<less\>name\<gtr\>:*> the object as a whole, so that the canonical form always omits the originator's owner part; resolution without a digest and with no confirmed copy is defined; short forms of a named owner are ordered only within one archive, and copies of one line confirmed in different archives are reported as a conflict; confirmation reads <verbatim|archiveId> from the copy, never from an index; external records attest only from a trusted depositor or when reached independently; a branch's own collections do not confirm its parent; resolving a parent confirms its archive, not its owner; a branch point moves to a version later in the parent's history; checks added for deep branches of branches, owner forms, and fixed archive and object identifiers; custodian defined.

    <item>**0.1 (draft), 15 November 2026, proposal revised after an eighth review (branch <verbatim|proposal/identity>):** gateways redirect only temporarily and only to confirmed archives; <verbatim|:*> is not an owner part, allows <verbatim|at>, lists only lines that pass the checks, and works with a short name; a line appears only once in an archive; a branch point is later in the history of the new parent version; the index declarations allow further indexes; a <verbatim|sheaf:> URI is recorded in DataCite as a <verbatim|URL>, provisionally; owner proofs refer to #41 and custodians to #39; drafts kept in an archive described; the fallback without a confirmed copy in section 15.

    <item>**0.1 (draft), 15 November 2026, proposal (branch <verbatim|proposal/identity>):** the last character of a name (and of an owner identifier) also carries the number of the algorithm that made it, 0 for SHA-512 truncated to 256 bits, so that existing names are unchanged and names of other algorithms never coincide with them; collisions and aliases listed as an open question (#44).

    <item>**0.1 (draft), 15 November 2026, proposal (branch <verbatim|proposal/identity>):** clashes of names are resolved where an object is created in an archive: an archive keeps at most one object per line (owner, name); sealing draws a new nonce when the line is taken; a branch whose line is taken by another genesis record is named by the next algorithm over the same record (seeded SHA-256, the seed carrying the algorithm number), its <verbatim|parent> keeping the parent's name, and found under it by searching all the names of its genesis record; a mirror whose line is taken cannot be kept; a full name with several originators is ambiguous; aliases left to #44 as a last resort.

    <item>**0.1 (draft), 15 November 2026, proposal (branch <verbatim|proposal/identity>):** names and owner identifiers made by one function: SHA-256 over the seed <verbatim|opensheaf-name-\<less\>k\<gtr\>> and the record, k from 0 to 15 written in the last character (replacing SHA-512 truncated to 256 bits, SHA3-256, BLAKE2b-256 and the seeded algorithms 3 to 15); the examples recomputed.

    <item>**0.1 (draft), 15 November 2026, proposal (branch <verbatim|proposal/identity>):** a work is searched for by all 16 names of its genesis record, keeping only the entries whose genesis record is the same, byte for byte, and discarding collisions; <verbatim|names/> entries carry the genesis record itself (<verbatim|genesis>), replacing <verbatim|parentName>.

    <item>**0.1 (draft), 15 November 2026, proposal (branch <verbatim|proposal/identity>):** an archive refuses at creation a genesis record reused for another work (objects with one genesis record must have the same first sealed version) and an owner whose identifier is another owner's; nonces from a secure random generator, genesis records never copied; resolvers list colliding owner URIs; aliases left as an open question in case refusing proves too strict (#44).

    <item>**0.1 (draft), 15 November 2026, proposal revised after a ninth review (branch <verbatim|proposal/identity>):** every line records <verbatim|sealed>, the originator's sealing version, copied by branches, which decides reused genesis records and groups the search for a work; a branch takes <verbatim|parent.name>, or after a clash the smallest free algorithm number above it, also when its branch point cannot be moved; an originator's line is named by algorithm 0; an unjustified rename is a warning; genesis records may be copied only into mirrors and branches of their work; <verbatim|genesis.json> MUST be UTF-8; owner identifiers compared at the heads; the gateway example fixed; stale "same name" wording.

    <item>**0.1 (draft), 15 November 2026, proposal revised after a tenth review (branch <verbatim|proposal/identity>):** the originator does not branch its own work (an open question); a branch checks its line among the owner's lines the tool knows, not only in its archive, duplicates elsewhere left as an open question; resolvers check that <verbatim|object.json> has the URI's name; <verbatim|sealed> never changes within a line and is read from copies; a renamed number not above the parent's is a failure, other unjustified renames warnings; no free number refuses the branch; first deposit wins, in section 15; wording.

    <item>**0.1 (draft), 16 November 2026, proposal revised after an eleventh review (branch <verbatim|proposal/identity>):** a branch renames only for confirmed lines of its owner elsewhere, and moves onto an existing branch only if the owner made it, in the archive that keeps it; lines stay taken after a takedown; an accepted copy's owner is not the originator; a deep branch's first own version keeps the branch point's number only if it adds no files of its own; the handover example limited to lines the institution owns; section 15 rewritten; wording.

    <item>**0.1 (draft), 16 November 2026, proposal revised after a twelfth review (branch <verbatim|proposal/identity>):** a deep branch's first own version that adds files takes the number after the highest copied document version; a named owner's branch point is moved only under the authority the keeping archive requires for new versions of that line, and archives with many depositors bind each line to who may add to it; renames for any object or tombstone in the archive and for confirmed lines elsewhere; a mirror of the owner's branch counts as that branch; tombstones and removed index entries keep the name and the owner identifier, and may drop the owner's URI, so that takedowns can erase it; the canonical form of <verbatim|:*> uses the algorithm-0 name; originator defined; section 15 aligned with section 6.5.

    <item>**0.1 (draft), 16 November 2026, proposal revised after a thirteenth review (branch <verbatim|proposal/identity>):** every own version of a deep branch that adds files takes the number after the highest in the object and goes last in <verbatim|history>; removed index entries still match by owner identifier and are listed apart in a search; archives accepting more than one depositor MUST bind lines and named owner URIs to their depositors (section 6.5); a mirror of anything but the owner's branch is renamed; tombstones keep <verbatim|sealed>; <verbatim|owners/> lists only objects of the storage root, and owner identifiers are pseudonyms; wording.

    <item>**0.1 (draft), 16 November 2026, proposal revised after a fourteenth review (branch <verbatim|proposal/identity>):** only a deep branch's first own version that adds files of the document's own goes last in <verbatim|history>, and a branch does not complete its parent's versions; the depositor binding in a paragraph of its own, for named lines the archive keeps, to depositors it has checked, not for keyed lines or mirrors; reused genesis records refused against tombstones too; removed entries: owner unknown only without a genesis record, <verbatim|status> and <verbatim|sealed> kept, grouping in a search; <verbatim|owners/> loses names at every takedown; a deep branch's copied versions serve pins; <verbatim|/v\<less\>n\<gtr\>> of a copied version points to the parent; wording.

    <item>**0.1 (draft), 16 November 2026, proposal revised after a fifteenth review (branch <verbatim|proposal/identity>):** <verbatim|mirrorOf> is never the archive itself, and the lines an archive keeps name its own <verbatim|archiveId> (section 14); on a deep branch a move takes the number after the highest in the object; a deposit meets a taken line also with a copy or tombstone of it; <verbatim|parent.object.json> validated; wording.

    <item>**0.1 (draft), 16 November 2026, proposal revised after a sixteenth review (branch <verbatim|proposal/identity>):** <verbatim|archiveId> defined in section 9 as the identifier of the archive that keeps the line, the archive's own except in mirrors and copied versions; copied versions of a deep branch of a deep branch name their own lines; a deposit meeting a copy of its line leaves the line with the archive that keeps it; the deep-branch move number in section 14; a deep branch holds the earlier versions too; the gateway rule counts the keeping archive's mirrors; owner identifiers end in <verbatim|a> or <verbatim|q> in the schemas.

    <item><strong|0.1 (draft), 16 November 2026, revision:> a storage root MAY use the hashed layout <verbatim|0003-hash-and-id-n-tuple-storage-layout>, with its default parameters, in place of the flat-direct layout, for large archives (issue #19); <verbatim|ocfl_layout.json> is required and names the same layout as <verbatim|storageLayout> in the discovery document; archives should keep the flat-direct layout unless their size requires otherwise, and should not change their layout; resolution (section 6.4), mirrors (section 10.4), takedown (section 11.2, removing empty folders of the hash) and verification (section 14) follow it; sections 6.3 and appendix F updated.

    <item>**0.1 (draft), 16 November 2026, proposal aligned with the hashed layout (branch <verbatim|proposal/identity>):** the <verbatim|url> of a branch's <verbatim|parent> and the copies of a deep branch use the object's path in the layout; index entries are resolved through the layout of the archive they name; appendix F notes that a name used as identifier sits under the hash of that identifier; section 5 names <verbatim|parent.url> in place of the <verbatim|record> of an accepted copy; the git companion keeps the indexes (its sections 2, 4.1, 5.1 and 9) and calls its git branches working branches.

    <item>**0.1 (draft), 16 November 2026, proposal (branch <verbatim|proposal/identity>):** open questions of section 6.5 point to #52 (one storage root per archive held, archives named from genesis records).

    <item>**0.1 (draft), 17 November 2026, proposal revised (branch <verbatim|proposal/owners>, on <verbatim|proposal/identity>; #55, #52):** owners are keyed identities, objects of kind <verbatim|owner> named by their genesis records, whose versions are their key logs (<verbatim|keys.json>: keys, threshold, revoked keys, an optional keeper), each version signed by the threshold of the keys of the one before; every sealed version of a line is signed by its owner, in signature files naming the key-log version they rely on, with timestamps for keys revoked later; key logs travel with the objects they sign; a line is its signed versions, wherever stored, and an archive cannot add to another owner's line; an owner moving to another archive continues its lines; named owners, owner identifiers, archive identifiers, <verbatim|archiveId>, <verbatim|mirrorOf>, <verbatim|keys> of the discovery document and the depositor binding are withdrawn; archives are hosts, found at their base URLs, locations being hints; object identifiers are lines (<verbatim|sheaf:\<less\>name\<gtr\>:\<less\>owner\<gtr\>>), in a new default layout <verbatim|\<less\>owner\<gtr\>/\<less\>name\<gtr\>> (or the hashed layout), with readable labels in the discovery document; <verbatim|sealed> is a pin of the originator's sealing version; collection members name lines; a branch keeps its parent owner's signatures, so its evidence is complete; verdicts, resolution, short forms, indexes, gateways, security and privacy follow; #14 and #53 are settled; the examples recomputed.

    <item>**0.1 (draft), 17 November 2026, proposal revised (branch <verbatim|proposal/owners>):** deep branches removed: every branch is a new object, under its own line's identifier, holding the branch point with its evidence (<verbatim|parent.inventory.json>, <verbatim|parent.object.json>, and now <verbatim|parent.signatures/> and <verbatim|parent.keylog/>, the parent owner's signatures and the part of its key log they need) as content files; the parent's history, when wanted, is a copy of the parent's line kept beside it, since OCFL inventories record their object's identifier and a branch cannot continue the parent's object; the open question on deep branches and storage roots is resolved.

    <item>**0.1 (draft), 17 November 2026, proposal revised (branch <verbatim|proposal/owners>):** one <verbatim|threshold> governs both the key log and the owner's lines, as in Radicle, no longer provisional; <verbatim|sealed> withdrawn, since signatures make it redundant (an archive accepts an object whose genesis record it holds only if it is signed by the record's originator or carries parent evidence signed by its parent's owner); drafts are a sandbox owner <verbatim|draft>, at <verbatim|draft/\<less\>id\<gtr\>/> with the identifier <verbatim|sheaf:draft:\<less\>id\<gtr\>>, never signed, pinned or copied out of their archive, and the only objects that may be rewritten or deleted; sealing makes a new object, and versions made before sealing are no longer part of the line (changing PR #30); collection members give their locations as <verbatim|at>, a list of base URLs, all equal hints, replacing <verbatim|archiveUrl> and <verbatim|mirrors> (#39, in part); index entries for several archives give <verbatim|at> too.

    <item>**0.1 (draft), 17 November 2026, proposal revised (branch <verbatim|proposal/owners>):** the identifier of a draft settled: <verbatim|sheaf:draft:\<less\>id\<gtr\>>, <verbatim|\<less\>id\<gtr\>> following the pattern of labels, at most 64 characters (76 in all), chosen locally and not reused while the draft exists; the examples use full-length names; the use cases, the FAQ and the companion on git describe the proposal throughout.

    <item><strong|0.1 (draft), 17 November 2026, proposal revised after an audit (security):> an owner's genesis record lists its first <verbatim|keys> and <verbatim|threshold>, which the first <verbatim|keys.json> repeats, so that an owner name fixes its first keys; signatures sign a defined message binding the object, the version, the inventory digest and the key-log version (<verbatim|object>, <verbatim|version>, <verbatim|inventorySha512>, <verbatim|signer> replace <verbatim|signed> and <verbatim|owner> in signature files), and signature files are named by a digest of their key; all signatures of a version name one key-log version, which MUST be the latest, an older one counting only with an earlier timestamp; copies carry key logs up to the latest version known, readers use the longest, and freshness cannot be proved offline; a branch carries the chain of its parents' evidence (<verbatim|parent.chain/>) back to the originator's line; owner objects are their own originators (URIs, pins, indexes); tombstones keep <verbatim|genesisName>, the algorithm-0 name of the genesis record.

    <item><strong|0.1 (draft), 17 November 2026, proposal revised after an audit:> the path of a line in the hashed layout (shortened with its digest, as extension 0003 does for identifiers over 100 characters) with a worked example; copying a parent's line by agreement left open (#39), as for mirrors; <verbatim|keys.json> has a <verbatim|format>; <verbatim|keeper> holds <verbatim|https> URLs; <verbatim|publisher> is the line's owner or the body behind it; a draft's identifier may be reused once it is gone; empty folders of owners removed at a takedown; <verbatim|sha512> allowed after a key log's object version; catalogues of copies kept by the archive as an owner; identity files listed in full in the CC0 list; references and wording corrected; the examples consistent (the catalogue pins the head).

    <item><strong|0.1 (draft), 17 November 2026, proposal revised after a second audit:> timestamps are optional and of two kinds, RFC 3161 tokens (<verbatim|.tsr>) and OpenTimestamps proofs (<verbatim|.ots>) of the signature file, beside it; an owner declares its policy in <verbatim|keys.json> (<verbatim|timestamps>: <verbatim|keylog> or <verbatim|all>), which then makes untimestamped versions invalid; a fork of a key log is resolved by the earliest timestamp when a policy is declared, and otherwise reported, not resolved, and the longest key log is chosen only among copies that extend one another; a signature naming an older key-log version counts without a timestamp while its key is still listed and the threshold has not been raised, and otherwise needs a timestamp earlier than the change; a version is signed when <verbatim|threshold> valid signature files of its owner name one key-log version, others being ignored and reported; <verbatim|signer> and the owner of <verbatim|keyLog> are the line's owner; key-log signatures name the previous version (the first, itself); revoked keys are not listed in <verbatim|keys>; the owner-name layout has no configuration and rejects other identifiers; tombstones do not stop a resolver; verifiers check thresholds, signature file names and files inside branch evidence; owner objects are always active; branch evidence and nested chains made explicit; wording.

    <item><strong|0.1 (draft), 17 November 2026, proposal revised after a third audit:> RFC 3161 tokens count only from authorities listed in <verbatim|timestampAuthorities> (certificate fingerprints), checked at <verbatim|genTime> with the certificates the token carries, and may be re-stamped; the policy in force is that of the latest known key-log version, and a signature under an older key-log version counts without a timestamp only if nothing was tightened since; <verbatim|revoked> withdrawn, a key being revoked by removing it; the time of a version is the <verbatim|threshold>-th earliest timestamp, and ties (equal, or within two hours of a Bitcoin block time) are reported; missing timestamps make a version unconfirmed, not invalid; forks of valid versions after which signatures are unconfirmed; tools declare a policy from the first version; branches are not taken from versions with pending stamps, and <verbatim|parent.keylog/> carries the stamps; a key signs a version once, and signature files are never re-serialised; owner objects carry none of <verbatim|withdrawal>, <verbatim|licence>, <verbatim|agreement>, <verbatim|external>; resolvers report copies found beside tombstones; references added; wording.

    <item><strong|0.1 (draft), 17 November 2026, proposal revised:> the timestamp rules move to a separate extension, <hlink|OpenSheaf timestamps|opensheaf-timestamps-0.1.tm> (<verbatim|https://opensheaf.org/opensheaf-timestamps-0.1>): the core reports forks of key logs and does not resolve them, and leaves unconfirmed a signature under an older key-log version whose key has been removed or whose threshold has been raised; <verbatim|timestamps> and <verbatim|timestampAuthorities> leave <verbatim|keys.json>, which gains <verbatim|extensions>, as <verbatim|object.json> has (section 4); the rules on <verbatim|.tsr> and <verbatim|.ots> files, authorities, <verbatim|genTime>, re-stamping, pending proofs, the time of a version and ties are in the extension; section 13.2 keeps timestamps as witnesses the core ignores.

    <item><strong|0.1 (draft), 17 November 2026, proposal revised after a fourth audit:> unconfirmed defined, in section 6.5 and the terminology, as a status distinct from invalid: an unconfirmed signature or version is kept, copied and shown, but not relied on (for pins, resolution, members, branch points and later key-log versions) until confirmed, and sections 6.6, 13.2 and 14 use it so; an extension concerning the key log acts on signatures only within that status (section 4); under a fork of a key log, a signature naming an older key-log version counts only if the rule holds on every side; witnesses are never replaced (a completed timestamp proof is a new file); the definition of a key log for its first version, the evidence of a branch (<verbatim|parent.chain/> only for a branch of a branch, <verbatim|parent.signatures/> without the version folder) and the witnesses of section 5 corrected; mentions of the merged branch <verbatim|proposal/owners> removed.

    <item><strong|0.1 (draft), 17 November 2026, proposal revised:> <verbatim|parent.keylog/> removed from the evidence of a branch and from every level of <verbatim|parent.chain/>: a copy carries, as owner objects in the same storage root, the key log of every owner whose signature it holds, its own versions', in <verbatim|parent.signatures/> and at every level of <verbatim|parent.chain/> (section 6.5), since a key log checks itself from its owner name, and a copy kept as content would be frozen and repeated in every branch; a branch copied without one of them is unconfirmed, not inconsistent; owner objects are kept through takedowns of the lines they sign, and taken down only for themselves, at the owner's request or by law, leaving the signatures that need them unconfirmed (section 11.2).

    <item><strong|0.1 (draft), 17 November 2026, proposal revised after a fifth audit:> retiring and revoking keys (section 6.5), at the request of the editor, in place of the rule that left unconfirmed a signature naming an older key-log version once its key was removed or the threshold raised: a signature counts when it is valid under the key-log version it names, and keeps counting, so that retiring a key, raising a threshold or changing extension data never undoes what was signed and nothing is signed again; <verbatim|revoked> added to <verbatim|keys.json> for keys that may have been exposed, whose signatures are all unconfirmed unless an extension dates them before the revocation, a revoked key never being listed again; versions of the key log follow the same rule, so a change of keys no longer unconfirms itself; invalid, valid, unconfirmed and unsigned defined in section 13.2, a missing key log making signatures unconfirmed, missing or invalid signatures of a parent making a branch point inconsistent; "signatures hold" defined as signed, and unconfirmed versions never make a fork, never take a line's place and are not copied into mirrors; forks of key logs: their damage stated, more than two sides, a threshold of 2 or more recommended, an archive keeping the side it holds; owner objects taken down are exempt from the rule that copies carry key logs, and may return; the key logs of third parties' witnesses are optional; owner objects may be copied on their own and may have <verbatim|extensions>, and have no <verbatim|datacite.json> (section 8); members' pinned versions checked for signatures; keys of the first version compared as a set; drafts stay with their archive when it moves; an example of revocation in appendix E.

    <item><strong|0.1 (draft), 17 November 2026, proposal revised after a sixth audit:> a signed version confirms what it extends: a version of a line signed with a key revoked later is confirmed by any later signed version of the line, and a branch point by a later signed version of its parent's line, so that revocation no longer erases a past the owner continues; mirrors copy unconfirmed versions with their status, and take a signed history in place of unconfirmed versions it departs from; the exemption of the key log up to the revoking version stated in sections 13.2 and 14; revocations listed only on a side of a fork that is not resolved do not apply, so that a thief cannot unconfirm the owner's past, and the cost stated; a key log is forked by any valid next version, a line only by signed ones; a threshold binds only the signatures naming its version, so raising it or retiring keys does not shut out earlier keys; <verbatim|revoked> entries are objects with <verbatim|key> and an optional <verbatim|since>, the owner's estimate of the exposure, which the timestamps extension uses; an archive keeps the first differing version of each other side of a fork of a key log as evidence (<verbatim|extensions/opensheaf-witnesses/fork/>); unverifiable signatures (naming a key-log version the key log does not reach) and versions, never shown as versions of a line; a signature is verified against its key first; owners may add signatures to a version; the takedown of an owner object by a stolen key; the three open questions on merging between lines point to #57.

    <item><strong|0.1 (draft), 17 November 2026, proposal simplified after a seventh audit:> the statuses of signatures and versions defined once, in section 13.2 (a version is signed, unconfirmed, or not a version, with its reason); a signed version confirms every version it extends; no archive drops a version because of a fork, and both forks of lines and of key logs are recorded as evidence in <verbatim|extensions/opensheaf-witnesses/fork/>, with timestamp files; an archive adds a version to a line only after checking it against the key log; a key-log version beyond the latest known leaves signatures unconfirmed, a known number with another digest unverifiable; during a fork of a key log, the keys of the fork point keep counting, and keys added or revoked on the sides are ignored; owner tools show unconfirmed versions before extending them; thresholds presented as a choice between surviving loss (1, with a spare) and theft (2 of 3); the timestamps declaration is <verbatim|true>; resolving a fork applies the owner's side's revocations, the one exception of section 4; a host can plant a junk signature file (section 15).

    <item><strong|0.1 (draft), 17 November 2026, proposal (loose ends of the seventh audit):> setting aside a version found to be not a version of the line, after it was added, defined as a truncation of the object, the first version set aside kept as evidence under <verbatim|extensions/opensheaf-witnesses/fork/> (section 6.5).

    <item><strong|0.1 (draft), 17 November 2026, proposal revised after an eighth audit:> "unverifiable" and "key log not available" merged into one reason, the key-log version not found, which leaves a signature unconfirmed; a version is not a version only when unsigned or invalid; versions that rely on a key-log version not found are never added, and may be set aside like versions that are not versions, with the witness folders of every version set aside, and verifiers report an improper removal; files of a witness folder that are not witnesses (malformed, or signatures that do not verify under their own key) may be removed; a fork of a key log defined by versions signed by the keys of the version before on each side, judged by the fork rule alone, and, once resolved, signatures naming a losing side judged as naming the fork point; a signed version confirms the earlier versions of its line only; in the core alone, whoever holds revoked keys can fork the key log at a version listing them and suspend the revocation, stated with its defences (the timestamps extension from the first version, a threshold of 2); the example key log adopts the extension in its first version; a takedown statement during a fork is signed by the keys of the fork point; mirrors may set aside and record evidence; the junk-file limit removed from section 15.

    <item><strong|0.1 (draft), 17 November 2026, proposal revised after a ninth audit:> nothing that a host or a thief can produce leads to removing anything: setting aside versions (truncating an object) and removing files that are not witnesses are withdrawn; a version added unchecked that is not a version stays, reported and never shown as one; signature files are named <verbatim|\<less\>version\<gtr\>/signature-\<less\>k\<gtr\>-\<less\>d\<gtr\>.json>, <verbatim|\<less\>d\<gtr\>> from the digest of the file itself, so that a planted file never takes the place of a real signature; after a fork of a key log is resolved, a signature naming a losing side whose key is not listed at the fork point is unconfirmed, not invalid; the evidence of forks is recorded for key logs only; a key-log version not found excludes the sides of a known fork; during an unresolved fork of its key log, an owner object is taken down only through its keeper or by law.

    <item><strong|0.1 (draft), 17 November 2026, proposal revised after a tenth audit:> archives add to a line only versions signed under the core (a version extended by a later signed version in the same copy included), never versions that only an extension lets count, so that no thief's or junk version blocks a line; a mirror lags at the last signed version; a version that is not a version is a failure of section 14; owner tools never extend a version that is not a version; a key-log version is on a known side of a fork when reached from the fork point through versions held, each signed by the version before; files that are not witnesses are invalid signature files, malformed or stray files, and copies may leave them out; an owner object whose key log has any known fork is taken down only through its keeper or by law; a fork of a line is reported, never recorded.

    <item><strong|0.1 (draft), 17 November 2026, lines read from their signed head (PR #30, after an eleventh review):> a copy of a line is read from its signed head, its latest version signed with good signatures, which puts in the line every version before it; the versions after it are the tail, kept and shown, never relied on; signatures are good, revoked, unchecked or invalid, and versions in the line, in the tail or not a version (section 13.2), replacing the per-version statuses and the word unconfirmed; a revoked key's line comes back with one good signature, added to its current version or on a later one; archives add a version only if the core alone puts it in the line, and while a fork of a key log is not resolved a key revoked on any side counts as revoked for adding, so that a thief cannot take a version number; a version that is not a version, held by an archive, is reported as a breach, not a failure of verification; mirrors copy up to the signed head, and key logs up to their latest signed version; an owner whose good keys all came after a fork point needs a new owner, with or without the timestamps extension; branch points and members are confirmed or pending; signature files are again <verbatim|signature-\<less\>k\<gtr\>.json>, one for each key, so that readers over plain HTTP can find them; the rationale of the signed head added.

    <item><strong|0.1 (draft), 17 November 2026, an exposed key ends the owner (PR #30, after a twelfth review, the editor's decision):> the core no longer tries to tell a leaked key's earlier signatures from later ones: <verbatim|revoked> and <verbatim|since> are removed, with the tail, the signed head, the rules on forks for adding and their resolution; a signature that verifies against the key-log version it names is good for ever, and a version is signed by its own signatures or by a later signed version that extends it; an owner whose key may have been exposed ends, by a last key-log version with <verbatim|ended> and an optional <verbatim|successor>, and a fork of a key log has the same effect from the fork point: its signatures stay good, archives add nothing more to its lines, readers trust its history as far as other evidence goes, and its work continues under the successor by branches; a signature file is invalid when its <verbatim|object>, <verbatim|version> or inventory digest are not those of its folder, or its <verbatim|signer> not the line's owner; readers, presentations and followed catalogues use the latest signed version; timestamps are evidence only (the timestamps extension changes no status).

    <item><strong|0.1 (draft), 17 November 2026, wording (PR #30):> "Ending an owner" split into the end, forks of a key log, and what follows them; a version of a line is signed directly or vouched for by a later version signed directly.

    <item><strong|0.1 (draft), 17 November 2026, after a thirteenth review (PR #30):> the key log of an ended or forked owner is always copied, up to and including the end, and its lines may be copied up to their latest signed version; only extending them is frozen; the ending version only ends, and no signature of a line may name it; <verbatim|successor> differs from the owner, is never followed automatically, and is confirmed by the keeper's <verbatim|.well-known/opensheaf>; an owner ended by someone else answers with a competing version, a fork; branch points and members unchecked rather than pending; section 15 shortened; the timestamps declaration is only <verbatim|timestampAuthorities>.

    <item><strong|0.1 (draft), 18 November 2026, after a fourteenth review (PR #30):> at a fork of a key log, the versions each side holds stay versions and signatures naming them stay good, while no archive that knows the fork adds a version after the fork point; the answer to a thief who ends first is a competing ending version; the evidence of forks keeps <verbatim|keys.json> and timestamp files; the lines of an ended or forked owner are taken only from copies, up to the latest signed version of a copy that agrees, also to extend a line held; keepers confirm successors in <verbatim|successors>; resolvers and gateways report ended and forked owners; a successor differs from its owner; repetitions cut (sections 4, 13.2, 15).
  </itemize>

  <section*|Appendix A. Zenodo binding (normative for archives declaring the profile <verbatim|zenodo>)><label|appendix-a-zenodo-binding-normative-for-archives-declaring-the-profile-zenodo>

  Zenodo issues DataCite DOIs (prefix <verbatim|10.5281>) and keeps files permanently. Under this binding:

  <\itemize>
    <item><strong|Records.> Each document is one Zenodo record with versions: the concept DOI stands for the document, and each document version is one record version with its own DOI, of Zenodo resource type <verbatim|publication-preprint> (or the type matching <verbatim|resourceTypeGeneral>). Description-only versions are metadata edits of the existing record version, not new record versions; files they add (such as notices) are not uploaded, since the files of a published record version are fixed.

    <item><strong|Versions out of order.> Zenodo orders the versions of a record by publication, and its concept DOI resolves to the latest. A document version deposited out of order (section 7.3) is therefore not deposited as a new version of the record; it MAY be deposited as a separate record, with <verbatim|IsVersionOf> the concept DOI of the document.

    <item><strong|Files.> The record version holds the content files of the object version as deposited. Zenodo records have no folders: if the sources have sub-folders, or the record would exceed Zenodo's file count, the sources are uploaded as one archive <verbatim|sources.zip>, built reproducibly (entries in byte order of their names, fixed timestamps, no extra attributes), whose digests are recorded in <verbatim|object.json> under <verbatim|external>, in the entry of the deposit (<verbatim|role> <verbatim|deposit>). Inventories MUST record MD5 digests in <verbatim|fixity>, so that the checksums reported by Zenodo can be compared directly.

    <item><strong|Order of operations.> (1) Create a draft, or a new version of the record (a new version inherits the files of the previous one, which are deleted). (2) Reserve its DOI (Zenodo reserves one with each draft; its sandbox reserves DOIs with the prefix <verbatim|10.5281> but publishes them with the test prefix <verbatim|10.5072>). (3) Write <verbatim|datacite.json> with that DOI and build the object version in a staging area. (4) Upload the files and compare the MD5 checksums reported by Zenodo with the fixity block. (5) Publish. (6) Commit the object version and update the discovery document. If a step fails before publication, the draft is discarded. If publication succeeds and the commit fails, the tool MUST complete the object version from the staging area before any other deposit of that document; it SHOULD hold a lock per document during a deposit, since Zenodo allows one unpublished version per record.

    <item><strong|Corrections.> Zenodo allows the files of a published version to be changed within 30 days. Archives following this binding MUST NOT use this: a correction is a new document version.

    <item><strong|Metadata differences.> Zenodo generates its own DataCite record for the DOI: its <verbatim|url> is the Zenodo landing page, its <verbatim|publisher> is Zenodo, and it adds relations of its own (such as <verbatim|IsVersionOf> the concept DOI). <verbatim|datacite.json> remains authoritative; verifiers tolerate exactly these differences.

    <item><strong|Collections.> A collection MAY be deposited when it is explicitly released (not at every change), as a record of type <verbatim|other>, with <verbatim|members.json> among its files. A Zenodo community MAY group an archive's records for browsing; it is not authoritative.
  </itemize>

  <section*|Appendix B. TeXmacs profile (normative for archives declaring the profile <verbatim|texmacs>)><label|appendix-b-texmacs-profile-normative-for-archives-declaring-the-profile-texmacs>

  <\itemize>
    <item>The main source is a TeXmacs document; <verbatim|sourceFormat> is <verbatim|application/x-texmacs> (not a registered media type; it is the type TeXmacs uses).

    <item><verbatim|toolchain> records the TeXmacs version and the style packages and plugins used that are not part of the TeXmacs distribution; such packages that belong to the document are deposited with the sources.

    <item>Renditions are produced without regenerating bibliographies or tables of contents, so that the deposited sources, with their stored references, reproduce them even if a bibliography database is not deposited; deposits SHOULD nevertheless include the databases used.

    <item>The title and abstract in <verbatim|datacite.json> are converted from the TeXmacs document to plain text, with mathematics in LaTeX as in section 8.

    <item>HTML versions are exported by TeXmacs from a copy of the sources with presentation packages added to its style; the deposited sources are not modified.

    <item>An archive whose files are kept inside a website built with TeXmacs' website converter SHOULD place an empty file <verbatim|.texmacs-noconvert> at its top (honoured by the <verbatim|max-html> plugin), so that the converter never rewrites deposited files.
  </itemize>

  <section*|Appendix C. Website profile (normative for archives declaring the profile <verbatim|website>)><label|appendix-c-website-profile-normative-for-archives-declaring-the-profile-website>

  <\itemize>
    <item><strong|Index.> The website has an index page generated from the head version of the main collection. It MAY be split into several pages. A flattened, non-authoritative list for programs that do not read OCFL MAY be published as <verbatim|catalog.json>.

    <item><strong|Landing pages.> Each document has one landing page, for its current version (section 7.3), with links to every version in the order of the history, each with its external labels, stage, change note and the notices about it, its renditions and sources, its DOI, and the withdrawal notice if any.

    <item><strong|Search engines.> Landing pages MUST carry the meta tags read by Google Scholar: <verbatim|citation_title>, <verbatim|citation_author> (one per author), <verbatim|citation_publication_date> (the <verbatim|Issued> date, or else the <verbatim|Available> date of the current version), and <verbatim|citation_pdf_url> on the same host as the PDF; and SHOULD carry schema.org <verbatim|ScholarlyArticle> JSON-LD and FAIR Signposting links (<verbatim|cite-as>, <verbatim|describedby>, <verbatim|item>, <verbatim|license>).

    <item><strong|Feeds.> A feed (section 6.1) lists object versions by their <verbatim|created> date in the inventory: what is new in the archive.

    <item><strong|Harvesters.> The website SHOULD publish a <verbatim|sitemap.xml>, and MAY publish an OAI-PMH static repository file or a ResourceSync description.

    <item><strong|Citations.> Landing pages SHOULD offer BibTeX and CSL-JSON entries generated from <verbatim|datacite.json>.

    <item><strong|Separation.> Presentation files are regenerated from the archive and never edited by hand; they do not embed other archives' HTML.
  </itemize>

  <section*|Appendix D. JSON Schemas (normative)><label|appendix-d-json-schemas-normative>

  The schemas (JSON Schema draft 2020-12) are published with this specification and dedicated to the public domain under CC0 1.0, so that they can be embedded in any software:

  <\itemize>
    <item><hlink|opensheaf-archive-0.1.schema.json|https://opensheaf.org/schemas/opensheaf-archive-0.1.schema.json> for <verbatim|opensheaf.json>;

    <item><hlink|opensheaf-object-0.1.schema.json|https://opensheaf.org/schemas/opensheaf-object-0.1.schema.json> for <verbatim|object.json>;

    <item><hlink|opensheaf-collection-0.1.schema.json|https://opensheaf.org/schemas/opensheaf-collection-0.1.schema.json> for <verbatim|members.json>;

    <item><hlink|opensheaf-genesis-0.1.schema.json|https://opensheaf.org/schemas/opensheaf-genesis-0.1.schema.json> for <verbatim|genesis.json> (proposal, section 6.5);

    <item><hlink|opensheaf-keys-0.1.schema.json|https://opensheaf.org/schemas/opensheaf-keys-0.1.schema.json> for <verbatim|keys.json> (proposal, section 6.5);

    <item><hlink|opensheaf-signature-0.1.schema.json|https://opensheaf.org/schemas/opensheaf-signature-0.1.schema.json> for signature files (proposal, section 13.2);

    <item><hlink|opensheaf-index-0.1.schema.json|https://opensheaf.org/schemas/opensheaf-index-0.1.schema.json> for the index files (proposal, section 6.6).
  </itemize>

  The schema of the <hlink|timestamps extension|opensheaf-timestamps-0.1.tm>, <hlink|opensheaf-timestamps-0.1.schema.json|https://opensheaf.org/schemas/opensheaf-timestamps-0.1.schema.json>, is published with that extension, which is not part of this specification.

  DataCite publishes its schema as an XML Schema only. <verbatim|datacite.json> is validated by converting it to DataCite XML (following DataCite's mapping between the REST API's JSON and XML) and validating the result against the DataCite 4.7 XML Schema, together with the requirements of section 8.

  <section*|Appendix E. Examples (non-normative)><label|appendix-e-examples-non-normative>

  The values below come from the first archive, except the names, owners, keys and signatures added by the proposal of section 6.5, which are placeholders, except the names of the authors' owner and paper, which are the real digests of the genesis records shown. Digests and signatures are shortened, and the DOIs and ORCID iDs are placeholders (with valid check digits).

  A discovery document. The archive hosts one owner, whose owner object holds its key log, and the owner's document and catalogue; the labels give the website readable URLs:

  <\html-div-class|language-json>
  <\verbatim-code>
    {

    \ \ "format": "opensheaf-archive/0.1",

    \ \ "specification": "0.1",

    \ \ "name": "Papers of Massimiliano Gubinelli",

    \ \ "contact": "https://orcid.org/0000-0000-0000-0001",

    \ \ "storageRoot": "ocfl/",

    \ \ "storageLayout": "opensheaf-owner-name-storage-layout",

    \ \ "mainCollection": "sheaf:fm4ddd465aicnysuetzldaep3xiiv3ls43umjofzcgjityhq6ota:zgjup5lqdg4kec2lyvdq2f3d55b6wyouvji5wwbregthijfnsu3a",

    \ \ "profiles": ["zenodo", "texmacs", "website"],

    \ \ "owners": ["zgjup5lqdg4kec2lyvdq2f3d55b6wyouvji5wwbregthijfnsu3a"],

    \ \ "objects": [

    \ \ \ \ { "id": "sheaf:zgjup5lqdg4kec2lyvdq2f3d55b6wyouvji5wwbregthijfnsu3a:zgjup5lqdg4kec2lyvdq2f3d55b6wyouvji5wwbregthijfnsu3a", "kind": "owner", "head": "v1",

    \ \ \ \ \ \ "inventorySha512": "e3b7...", "status": "active",

    \ \ \ \ \ \ "name": "zgjup5lqdg4kec2lyvdq2f3d55b6wyouvji5wwbregthijfnsu3a", "owner": "zgjup5lqdg4kec2lyvdq2f3d55b6wyouvji5wwbregthijfnsu3a" },

    \ \ \ \ { "id": "sheaf:72kqjazmz3pvvf4a2t4wzefimdzwrkxwum2ta4b73ikqude7dljq:zgjup5lqdg4kec2lyvdq2f3d55b6wyouvji5wwbregthijfnsu3a", "kind": "document", "head": "v1",

    \ \ \ \ \ \ "inventorySha512": "9a0c...", "status": "active",

    \ \ \ \ \ \ "name": "72kqjazmz3pvvf4a2t4wzefimdzwrkxwum2ta4b73ikqude7dljq", "owner": "zgjup5lqdg4kec2lyvdq2f3d55b6wyouvji5wwbregthijfnsu3a",

    \ \ \ \ \ \ "label": "fractional-phi42-mass-gap" },

    \ \ \ \ { "id": "sheaf:fm4ddd465aicnysuetzldaep3xiiv3ls43umjofzcgjityhq6ota:zgjup5lqdg4kec2lyvdq2f3d55b6wyouvji5wwbregthijfnsu3a", "kind": "collection", "head": "v1",

    \ \ \ \ \ \ "inventorySha512": "51be...", "status": "active",

    \ \ \ \ \ \ "name": "fm4ddd465aicnysuetzldaep3xiiv3ls43umjofzcgjityhq6ota", "owner": "zgjup5lqdg4kec2lyvdq2f3d55b6wyouvji5wwbregthijfnsu3a",

    \ \ \ \ \ \ "label": "papers" }

    \ \ ]

    }
  </verbatim-code>
  </html-div-class>

  The storage root of this archive, in the owner-name layout (section 5):

  <\verbatim-code>
    ocfl/

    \ \ 0=ocfl_1.1

    \ \ ocfl_layout.json

    \ \ zgjup5lqdg4kec2lyvdq2f3d55b6wyouvji5wwbregthijfnsu3a/

    \ \ \ \ zgjup5lqdg4kec2lyvdq2f3d55b6wyouvji5wwbregthijfnsu3a/ \ \ \ the owner object: its key log

    \ \ \ \ 72kqjazmz3pvvf4a2t4wzefimdzwrkxwum2ta4b73ikqude7dljq/ \ \ \ the document

    \ \ \ \ fm4ddd465aicnysuetzldaep3xiiv3ls43umjofzcgjityhq6ota/ \ \ \ the catalogue
  </verbatim-code>

  An <verbatim|object.json> of a document version (its content also holds <verbatim|genesis.json>, section 6.5, and its extension folder the owner's signature files, section 13.2):

  <\html-div-class|language-json>
  <\verbatim-code>
    {

    \ \ "format": "opensheaf-object/0.1",

    \ \ "specification": "0.1",

    \ \ "kind": "document",

    \ \ "name": "72kqjazmz3pvvf4a2t4wzefimdzwrkxwum2ta4b73ikqude7dljq",

    \ \ "owner": "zgjup5lqdg4kec2lyvdq2f3d55b6wyouvji5wwbregthijfnsu3a",

    \ \ "documentVersion": 1,

    \ \ "mainSource": "fractional-phi42-mass-gap.tm",

    \ \ "sourceFormat": "application/x-texmacs",

    \ \ "renditions": [ { "path": "paper.pdf", "mediaType": "application/pdf" } ],

    \ \ "toolchain": [ { "name": "TeXmacs", "version": "2.1.5" } ],

    \ \ "stage": { "scheme": "NISO-JAV", "value": "AO" },

    \ \ "agreement": { "by": ["P. Duch", "M. Gubinelli"], "date": "2026-11-12", "method": "by e-mail" },

    \ \ "external": [ { "role": "deposit", "service": "Zenodo", "record": "https://zenodo.org/records/1234567",

    \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ "doi": "10.5281/zenodo.1234567" } ],

    \ \ "status": "active"

    }
  </verbatim-code>
  </html-div-class>

  The <verbatim|datacite.json> of the same version, which has a Zenodo DOI, so that Zenodo is its <verbatim|publisher> (the case of appendix A; otherwise it is the line's owner or the body behind it, section 8):

  <\html-div-class|language-json>
  <\verbatim-code>
    {

    \ \ "doi": "10.5281/zenodo.1234567",

    \ \ "url": "https://mgubi.org/papers/site/fractional-phi42-mass-gap/fractional-phi42-mass-gap.html",

    \ \ "version": "1",

    \ \ "types": { "resourceTypeGeneral": "Preprint" },

    \ \ "titles": [ { "title": "Mass gap for the fractional Phi^4_2 model" } ],

    \ \ "creators": [

    \ \ \ \ { "name": "Duch, P.", "nameType": "Personal", "givenName": "P.", "familyName": "Duch",

    \ \ \ \ \ \ "affiliation": [ { "name": "Institute of Mathematics, Polish Academy of Sciences" } ] },

    \ \ \ \ { "name": "Gubinelli, M.", "nameType": "Personal", "givenName": "M.", "familyName": "Gubinelli",

    \ \ \ \ \ \ "affiliation": [ { "name": "Mathematical Institute, University of Oxford" } ] } ],

    \ \ "publisher": { "name": "Zenodo" },

    \ \ "publicationYear": 2026,

    \ \ "dates": [ { "date": "2026-11-12", "dateType": "Issued" },

    \ \ \ \ \ \ \ \ \ \ \ \ \ { "date": "2026-11-12", "dateType": "Available" } ],

    \ \ "rightsList": [ { "rights": "Creative Commons Attribution 4.0 International",

    \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ "rightsUri": "https://creativecommons.org/licenses/by/4.0/",

    \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ "rightsIdentifier": "cc-by-4.0", "rightsIdentifierScheme": "SPDX" } ],

    \ \ "descriptions": [ { "description": "We present a new, simple ...", "descriptionType": "Abstract" } ],

    \ \ "formats": [ "application/x-texmacs", "application/pdf" ],

    \ \ "relatedIdentifiers": [

    \ \ \ \ { "relatedIdentifier": "10.5281/zenodo.1234566", "relatedIdentifierType": "DOI", "relationType": "IsVersionOf" } ]

    }
  </verbatim-code>
  </html-div-class>

  The <verbatim|object.json> of a later version of a document whose arXiv version 2 was found and deposited after version 4 (document versions 1, 2, 3 for arXiv's v1, v3, v4, then 4 for arXiv's v2, placed between 1 and 2 in the history), with a notice about version 2 (arXiv's v3):

  <\html-div-class|language-json>
  <\verbatim-code>
    {

    \ \ "format": "opensheaf-object/0.1",

    \ \ ...

    \ \ "documentVersion": 3,

    \ \ "changes": { "text": "Corrected the proof of Lemma 2; 32 pages." },

    \ \ "stage": { "scheme": "NISO-JAV", "value": "AM" },

    \ \ "history": [ "v1", "v4", "v2", "v5" ],

    \ \ "notices": [ { "documentVersion": 2, "date": "2026-12-01",

    \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ "text": "Theorem 3 is wrong as stated; corrected in version 3.",

    \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ "path": "notices/erratum-v2.pdf", "mediaType": "application/pdf" } ],

    \ \ "external": [ { "role": "source", "service": "arXiv", "record": "https://arxiv.org/abs/2303.18112v4",

    \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ "doi": "10.48550/arXiv.2303.18112", "label": "v4" } ],

    \ \ "status": "active"

    }
  </verbatim-code>
  </html-div-class>

  Object versions <verbatim|v1> to <verbatim|v3> deposited document versions 1 to 3; <verbatim|v4> deposited document version 4 (arXiv's v2) and wrote the history <verbatim|["v1", "v4", "v2", "v3"]>, so that the current version stayed document version 3 although the head held version 4; <verbatim|v5>, shown here, is a description-only version adding the notice, which holds the current version again. The current version is document version 3, the last in the history.

  A <verbatim|members.json> of a catalogue: the main collection of an archive, following its documents whole:

  <\html-div-class|language-json>
  <\verbatim-code>
    {

    \ \ "format": "opensheaf-collection/0.1",

    \ \ "type": "catalogue",

    \ \ "order": "issued-desc",

    \ \ "members": [

    \ \ \ \ { "kind": "document",

    \ \ \ \ \ \ "name": "72kqjazmz3pvvf4a2t4wzefimdzwrkxwum2ta4b73ikqude7dljq",

    \ \ \ \ \ \ "owner": "zgjup5lqdg4kec2lyvdq2f3d55b6wyouvji5wwbregthijfnsu3a",

    \ \ \ \ \ \ "at": [ "https://mgubi.org/papers/" ],

    \ \ \ \ \ \ "version": "v1",

    \ \ \ \ \ \ "inventorySha512": "9a0c...",

    \ \ \ \ \ \ "follow": "latest",

    \ \ \ \ \ \ "cite": { "title": "Mass gap for the fractional $\\\\Phi^4_2$ model",

    \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ "creators": ["P. Duch", "M. Gubinelli"], "year": 2026, "issued": "2026-11-12" } }

    \ \ ]

    }
  </verbatim-code>
  </html-div-class>

  A <verbatim|members.json> of a selection: an issue of a journal, with a paper vetted in its version 2 and, after a correction accepted by the editors, its version 3; and a member that is itself a collection, vetted in one version (the seminar's names are illustrative):

  <\html-div-class|language-json>
  <\verbatim-code>
    {

    \ \ "format": "opensheaf-collection/0.1",

    \ \ "type": "selection",

    \ \ "members": [

    \ \ \ \ { "kind": "document",

    \ \ \ \ \ \ "name": "lvfmiq2zpc7wqv7yv4idzsnrc7aiil4od442w3qj4nxl2h6vbr4q",

    \ \ \ \ \ \ "owner": "unt5dq6qcfvpkn7xewskmh7s7iuzxoubbcqrf3odk57sk6xoap7q",

    \ \ \ \ \ \ "at": [ "https://authors.example.org/", "https://mirror.example.net/authors/" ],

    \ \ \ \ \ \ "revisions": [

    \ \ \ \ \ \ \ \ { "documentVersion": 2, "version": "v2", "inventorySha512": "4f1e..." },

    \ \ \ \ \ \ \ \ { "documentVersion": 3, "version": "v4", "inventorySha512": "c07a..." } ],

    \ \ \ \ \ \ "cite": { "title": "Quantum network discrimination", "creators": ["C. Hirche"], "year": 2021 } },

    \ \ \ \ { "kind": "collection",

    \ \ \ \ \ \ "name": "seminarcollectionaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",

    \ \ \ \ \ \ "owner": "seminarownerccccccccccccccccccccccccccccccccccccccca",

    \ \ \ \ \ \ "at": [ "https://seminar.example.org/" ],

    \ \ \ \ \ \ "revisions": [ { "documentVersion": 3, "version": "v3", "inventorySha512": "7d21..." } ] }

    \ \ ]

    }
  </verbatim-code>
  </html-div-class>

  The genesis record of the authors' owner (proposal, section 6.5), which lists its first key, so that the first <verbatim|keys.json> of its key log must list the same; its name, the owner name, is <verbatim|unt5dq6qcfvpkn7xewskmh7s7iuzxoubbcqrf3odk57sk6xoap7q>:

  <\html-div-class|language-json>
  <\verbatim-code>
    {

    \ \ "format": "opensheaf-genesis/0.1",

    \ \ "kind": "owner",

    \ \ "created": "2026-03-01T17:40:00Z",

    \ \ "nonce": "a41d07c3e9b25f8d61c0e4b7f2a39d58",

    \ \ "keys": [ "did:key:z6MkhaXgBZDvotDkL5257faiztiGiC2QtKLGpbnnEGta2doK" ],

    \ \ "threshold": 1

    }
  </verbatim-code>
  </html-div-class>

  The <verbatim|keys.json> of the first version of that owner's key log repeats the <verbatim|keys> and <verbatim|threshold> of the genesis record, and adopts the <hlink|timestamps extension|opensheaf-timestamps-0.1.tm> from the start, listing one RFC 3161 authority it trusts (a placeholder fingerprint), so that, if the owner ever ends, readers can tell which versions were signed before a key was exposed (section 6.5); it is signed by its own key:

  <\html-div-class|language-json>
  <\verbatim-code>
    {

    \ \ "format": "opensheaf-keys/0.1",

    \ \ "keys": [ "did:key:z6MkhaXgBZDvotDkL5257faiztiGiC2QtKLGpbnnEGta2doK" ],

    \ \ "threshold": 1,

    \ \ "extensions": {

    \ \ \ \ "https://opensheaf.org/opensheaf-timestamps-0.1": {

    \ \ \ \ \ \ "timestampAuthorities": [ "5b4e3f0c9d2a7e18c6f4b0a39d7e2c51f8a6b3d09e4c7a12f5b8d6e3a0c9f147" ]

    \ \ \ \ }

    \ \ }

    }
  </verbatim-code>
  </html-div-class>

  The <verbatim|keys.json> of the second version, which added a spare key, names the keeper and keeps the declaration; it is signed by the key of the first version:

  <\html-div-class|language-json>
  <\verbatim-code>
    {

    \ \ "format": "opensheaf-keys/0.1",

    \ \ "keys": [ "did:key:z6MkhaXgBZDvotDkL5257faiztiGiC2QtKLGpbnnEGta2doK",

    \ \ \ \ \ \ \ \ \ \ \ \ "did:key:z6MkpTHR8VNsBxYAAWHut2Geadd9jSwuBV8xRoAnwWsdvktH" ],

    \ \ "threshold": 1,

    \ \ "keeper": [ "https://orcid.org/0000-0002-1234-5677" ],

    \ \ "extensions": {

    \ \ \ \ "https://opensheaf.org/opensheaf-timestamps-0.1": {}

    \ \ }

    }
  </verbatim-code>
  </html-div-class>

  The <verbatim|keys.json> of the third and last version of that key log, after the laptop holding the first key was stolen: the owner ends, naming as successor a new owner it has created with new keys (a placeholder name), which continues its work by branches; it is signed by the spare key, listed in the second version, and no signature of a line may name it. The signatures the owner made stay good; readers trust its versions as far as other evidence goes, such as the timestamps of their signatures and the journal's pin of the authors' <verbatim|v4> below:

  <\html-div-class|language-json>
  <\verbatim-code>
    {

    \ \ "format": "opensheaf-keys/0.1",

    \ \ "keys": [ "did:key:z6MkhaXgBZDvotDkL5257faiztiGiC2QtKLGpbnnEGta2doK",

    \ \ \ \ \ \ \ \ \ \ \ \ "did:key:z6MkpTHR8VNsBxYAAWHut2Geadd9jSwuBV8xRoAnwWsdvktH" ],

    \ \ "threshold": 1,

    \ \ "keeper": [ "https://orcid.org/0000-0002-1234-5677" ],

    \ \ "extensions": {

    \ \ \ \ "https://opensheaf.org/opensheaf-timestamps-0.1": {}

    \ \ },

    \ \ "ended": true,

    \ \ "successor": "successorownerddddddddddddddddddddddddddddddddddddda"

    }
  </verbatim-code>
  </html-div-class>

  The genesis record of the authors' paper, written when it was sealed; its name is <verbatim|lvfmiq2zpc7wqv7yv4idzsnrc7aiil4od442w3qj4nxl2h6vbr4q> (the SHA-256 of <verbatim|opensheaf-name-0>, a line feed and the bytes as shown, with a final line feed); a branch named by algorithm 1 after a clash (section 6.5) would be <verbatim|tafstt7lc4s5ui6lfi7mj52vhdp3kbv5djqfaxprvlkyd57utnvb>:

  <\html-div-class|language-json>
  <\verbatim-code>
    {

    \ \ "format": "opensheaf-genesis/0.1",

    \ \ "kind": "document",

    \ \ "created": "2026-03-02T09:14:00Z",

    \ \ "originator": "unt5dq6qcfvpkn7xewskmh7s7iuzxoubbcqrf3odk57sk6xoap7q",

    \ \ "nonce": "5f2c8e1a9b7d4036c2e1f08a7b6d5c43"

    }
  </verbatim-code>
  </html-div-class>

  The signature file <verbatim|v4/signature-qvi7ibhm7zsahqx6.json> of the authors' object version <verbatim|v4> (its name from the digest of the key), which the journal vetted, in the extension folder <verbatim|extensions/opensheaf-witnesses/> of the paper (section 13.2):

  <\html-div-class|language-json>
  <\verbatim-code>
    {

    \ \ "format": "opensheaf-signature/0.1",

    \ \ "object": "sheaf:lvfmiq2zpc7wqv7yv4idzsnrc7aiil4od442w3qj4nxl2h6vbr4q:unt5dq6qcfvpkn7xewskmh7s7iuzxoubbcqrf3odk57sk6xoap7q",

    \ \ "version": "v4",

    \ \ "inventorySha512": "c07a...",

    \ \ "signer": "unt5dq6qcfvpkn7xewskmh7s7iuzxoubbcqrf3odk57sk6xoap7q",

    \ \ "key": "did:key:z6MkhaXgBZDvotDkL5257faiztiGiC2QtKLGpbnnEGta2doK",

    \ \ "keyLog": "sheaf:unt5dq6qcfvpkn7xewskmh7s7iuzxoubbcqrf3odk57sk6xoap7q/v2?sha512=8b3d...",

    \ \ "signature": "q4T0...=="

    }
  </verbatim-code>
  </html-div-class>

  The <verbatim|object.json> of the first version of the journal's accepted copy of that paper, a branch from the authors' document version 3, the corrected version the editors accepted (proposal, section 10.5; with the selection above, the journal would rather start from version 2 and move its branch point to version 3). The journal's owner name is <verbatim|iztwg6bj7mu3lkq7frglicixkesrrj5um7c5tyquzazw4vs2fv4a>. With the proposal, the selection lists this accepted copy as its member and MAY keep the authors' revision set as well. Its content also holds <verbatim|genesis.json> and the evidence of the authors' version: <verbatim|parent.inventory.json>, <verbatim|parent.object.json> and <verbatim|parent.signatures/> (the authors' signature files of their <verbatim|v4>); its extension folder holds the journal's signature files of <verbatim|v1>, and the journal's storage root keeps the journal's key log and the authors' key log, up to the latest version the journal knows, as owner objects (sections 6.5, 10.5 and 13.2):

  <\html-div-class|language-json>
  <\verbatim-code>
    {

    \ \ "format": "opensheaf-object/0.1",

    \ \ "specification": "0.1",

    \ \ "kind": "document",

    \ \ "name": "lvfmiq2zpc7wqv7yv4idzsnrc7aiil4od442w3qj4nxl2h6vbr4q",

    \ \ "owner": "iztwg6bj7mu3lkq7frglicixkesrrj5um7c5tyquzazw4vs2fv4a",

    \ \ "parent": {

    \ \ \ \ "owner": "unt5dq6qcfvpkn7xewskmh7s7iuzxoubbcqrf3odk57sk6xoap7q",

    \ \ \ \ "name": "lvfmiq2zpc7wqv7yv4idzsnrc7aiil4od442w3qj4nxl2h6vbr4q",

    \ \ \ \ "objectVersion": "v4",

    \ \ \ \ "documentVersion": 3,

    \ \ \ \ "inventorySha512": "c07a...",

    \ \ \ \ "url": "https://authors.example.org/ocfl/unt5dq6qcfvpkn7xewskmh7s7iuzxoubbcqrf3odk57sk6xoap7q/lvfmiq2zpc7wqv7yv4idzsnrc7aiil4od442w3qj4nxl2h6vbr4q/v4/"

    \ \ },

    \ \ "documentVersion": 3,

    \ \ "mainSource": "paper.tex",

    \ \ "sourceFormat": "application/x-tex",

    \ \ "renditions": [ { "path": "paper.pdf", "mediaType": "application/pdf" } ],

    \ \ "stage": { "scheme": "NISO-JAV", "value": "AM" },

    \ \ "status": "active"

    }
  </verbatim-code>
  </html-div-class>

  URIs of this paper (proposal, section 6.6). The authors' owner is the originator:

  <\verbatim-code>
    sheaf:lvfmiq2zpc7wqv7yv4idzsnrc7aiil4od442w3qj4nxl2h6vbr4q/v3

    \ \ \ \ document version 3 of the authors' line

    sheaf:lvfmiq2zpc7wqv7yv4idzsnrc7aiil4od442w3qj4nxl2h6vbr4q/v3?sha512=c07a...

    \ \ \ \ the authors' object version v4, which the journal vetted

    sheaf:lvfmiq2zpc7wqv7yv4idzsnrc7aiil4od442w3qj4nxl2h6vbr4q:iztwg6bj7mu3lkq7frglicixkesrrj5um7c5tyquzazw4vs2fv4a/v3

    \ \ \ \ document version 3 of the journal's line, its accepted copy

    sheaf:lvfmiq2z/v3

    sheaf:lvfmiq2z:iztwg6bj/v3

    \ \ \ \ the same two, in short form

    sheaf:lvfmiq2zpc7wqv7yv4idzsnrc7aiil4od442w3qj4nxl2h6vbr4q:*

    \ \ \ \ the paper as a whole: the authors' line, the journal's and any other

    sheaf:unt5dq6qcfvpkn7xewskmh7s7iuzxoubbcqrf3odk57sk6xoap7q

    \ \ \ \ the authors' owner, its key log

    https://opensheaf.org/sheaf:lvfmiq2z/v3

    \ \ \ \ the short form of the first, through a gateway (provisional domain)
  </verbatim-code>

  The entry of the journal's archive for this object, in its index <verbatim|names/lv.json> (its archive declares prefixes of 2 characters):

  <\html-div-class|language-json>
  <\verbatim-code>
    {

    \ \ "format": "opensheaf-index/0.1",

    \ \ "index": "names",

    \ \ "entries": [

    \ \ \ \ { "name": "lvfmiq2zpc7wqv7yv4idzsnrc7aiil4od442w3qj4nxl2h6vbr4q",

    \ \ \ \ \ \ "originator": "unt5dq6qcfvpkn7xewskmh7s7iuzxoubbcqrf3odk57sk6xoap7q",

    \ \ \ \ \ \ "owner": "iztwg6bj7mu3lkq7frglicixkesrrj5um7c5tyquzazw4vs2fv4a",

    \ \ \ \ \ \ "id": "sheaf:lvfmiq2zpc7wqv7yv4idzsnrc7aiil4od442w3qj4nxl2h6vbr4q:iztwg6bj7mu3lkq7frglicixkesrrj5um7c5tyquzazw4vs2fv4a",

    \ \ \ \ \ \ "status": "active",

    \ \ \ \ \ \ "genesis": "{\\n \ \\"format\\": \\"opensheaf-genesis/0.1\\",\\n \ \\"kind\\": \\"document\\",\\n \ \\"created\\": \\"2026-03-02T09:14:00Z\\",\\n \ \\"originator\\": \\"unt5dq6qcfvpkn7xewskmh7s7iuzxoubbcqrf3odk57sk6xoap7q\\",\\n \ \\"nonce\\": \\"5f2c8e1a9b7d4036c2e1f08a7b6d5c43\\"\\n}\\n" }

    \ \ ]

    }
  </verbatim-code>
  </html-div-class>

  <section*|Appendix F. Rationale (non-normative)><label|appendix-f-rationale-non-normative>

  <\itemize>
    <item><strong|Why OCFL.> It is a published, versioned specification for exactly this problem (versioned objects as plain files with digests), with independent validators, used by research libraries. OpenSheaf adds only discovery and collections.

    <item><strong|Why identifiers from lines, an owner-name layout, and a hashed layout for large archives (proposal).> Identifiers chosen by each archive clash as soon as one archive keeps copies of another's objects; identifiers made from lines, (name, owner), never clash, so one storage root holds the lines its owners write and copies of others' side by side (#52). The owner-name layout keeps paths resolvable by rule over plain HTTP, and gives each owner one folder, with its key log, so that an owner moves, or is mirrored, by copying a folder; the cost is that paths and identifiers are no longer readable, so readable names become labels, which are not permanent. One folder holding every owner, or every line of one owner, becomes impractical at large sizes, mostly in git, where every deposit rewrites a tree listing every entry, and in the web views of forges, which show at most about a thousand entries of a folder; object storage, which has no real folders, gains nothing. So a large archive may spread its objects over folders named by the hash of their identifiers (<verbatim|0003-hash-and-id-n-tuple-storage-layout>), a registered OCFL extension that keeps paths computable from the identifier.

    <item><strong|Why a discovery document.> Static web servers cannot list folders; one small file makes an archive discoverable, and its statements are checked against the storage root.

    <item><strong|Why pins by inventory digest.> One digest fixes a whole object version, so collections become hash trees across archives, and any matching copy will do.

    <item><strong|Why catalogues and selections.> Keeping and vetting are different acts. An archive (an author's, an institution's, a storage site) keeps what its members deposit, every version, without judging them: following an object as it grows is its job. A selection (a journal, a digest, a review journal) attests particular revisions: a later version by the authors has not been vetted, so it cannot enter the selection by itself, and a change of what is vetted is an editorial act that the selection's own history records. Pinning whole objects in one case and revision sets in the other makes the difference explicit and checkable.

    <item><strong|Why mirrors and accepted copies differ.> A mirror copies a whole line and stays the same line, signed by its owner, so it can only grow by the owner's versions. An accepted copy takes one vetted revision into a line of the selection's owner, where it continues under the selection's responsibility (corrections, notices, withdrawal); OCFL cannot hold part of an object, so a copy of one revision is another object: with the proposal of section 6.5, a branch of the same name.

    <item><strong|Why the owner is part of the identity (proposal).> A name alone cannot say whose history is the right one: anyone may copy a genesis record. With (name, owner), copying is no forgery: a copy under another owner is a branch, declared as such, and each owner answers for its own lines. Location stays out of the identity, so a line can be kept anywhere.

    <item><strong|Why owners are keyed identities with key logs (proposal).> An owner asserted by a name (an ORCID iD, an archive's identifier) cannot prevent others from writing under it, only be confirmed through the archive that serves it; an owner that signs makes every version checkable anywhere, also after its archives have gone, and makes it impossible for an archive to modify another owner's line, since a version it makes is its own branch (#55). A key alone cannot change, so an owner is named by a genesis record and keeps its keys in a log, each version signed by the keys of the one before, as Radicle's identity documents and The Update Framework do: keys are added, retired and shared with a threshold, while the owner name stays. One threshold governs both the key log and the owner's lines, as in Radicle. Who answers for an owner is a separate, optional link, confirmed by the keeper (#41).

    <item><strong|Why archives have no identity (proposal).> Once owners sign their lines, an archive only hosts them: a name for it would identify no authority, and would tie lines to places. An archive is found at its base URL, and every location is a hint, since what is found there is checked by pins and signatures (#52).

    <item><strong|Why owner names fix the first keys, and signatures bind the key log (proposal).> If an owner's genesis record held only a nonce, anyone could write a first key-log version of their own under a published owner name; listing the first keys in the record makes the name a commitment to them, as Radicle's repository identifier commits to its first delegates. A signature of a checksum file alone could be paired with any key-log version; signing a message that names the object, the version, the inventory and the key-log version closes that. A signature is then judged against the version it names alone, so that retiring keys never undoes what was signed: an owner cannot find every copy of its lines to sign them again, and need not. A branch carries the chain of its parents' evidence, because a check one level deep lets a chain of branches pass a reused genesis record.

    <item><strong|Why an exposed key ends the owner (proposal).> Signatures carry no time, so after a key leaks nothing tells the signatures made with it before from those its new holder makes after, naming an older version of the key log. Earlier drafts revoked such keys, and then had to decide, version by version, which signatures still counted, through forks of the key log, mirrors and branches; every rule moved the problem without solving it, since only trusted time can date a signature (<verbatim|drafts/keys-and-forks.md> on <verbatim|main> tells the story). OpenSheaf takes Radicle's answer, where a compromised key means a new identity (section 6.5). A version signed by its owner vouches for every version before it, since its inventory fixes them, as Radicle's canonical head vouches for the commits it reaches.

    <item><strong|Why timestamps are an extension (proposal).> A single researcher needs no timestamp: signatures stay good, and retiring keys changes nothing. A journal or an institution may want every signature dated, by a provider it can name, so that if an owner ends, readers can tell which versions came before a key was exposed. The <hlink|timestamps extension|opensheaf-timestamps-0.1.tm> adds that evidence for the owners who declare it, and keeps the trade-offs of its kinds (an RFC 3161 authority's clock and keys, or OpenTimestamps' pending period and Bitcoin) out of the core; it changes no status.

    <item><strong|Why every branch is a new object (proposal).> A journal needs only the version it vetted, and may not be allowed to copy the others; a co-author continuing the work may want its whole past. Both are served by one kind of branch: a new object holding the branch point with its evidence (the parent's inventory, <verbatim|object.json> and signatures, as content files, with the parent owner's key log beside it as an owner object), and, where wanted, a copy of the parent's line beside it. A branch that continued the parent's object would hold inventories naming the parent's identifier, fixed by pins and signatures, so it would be another owner's line inside an object that says it is the parent's, and would collide with a copy of the parent's line in the same storage root. Keeping the two apart costs nothing in git, which shares the branch point's files, and is how Radicle keeps forks beside the namespaces they come from. Who answers for an owner is said by its optional keeper link (section 6.5, #41).

    <item><strong|Why separate document and object versions.> Readers and DOI services see versions of the work; the storage keeps every change, including corrections of the description.

    <item><strong|Why the owner of a line numbers its document versions itself.> External numberings have gaps (versions an external service no longer serves) and do not cover versions that were never public there. The owner's own numbers have no gaps; external labels are recorded beside them.

    <item><strong|Why an explicit history, and why it lists object versions.> Dates may be approximate or unknown, so they cannot order versions, and pointers from each version to the previous one cannot be corrected when a version is inserted later, since earlier versions are fixed. A list kept in each object version, with the head's list authoritative, can be corrected by a new version and keeps a record of what was known before. Its entries name object versions, which are exact and resolved directly through the inventory, and name the last object version of each document version, which carries its most complete description. Digests could not be used: an object version cannot contain the digest of its own inventory.

    <item><strong|Why the deposit is read from the inventory.> OCFL already records when and by whom each object version was made; repeating it in <verbatim|object.json> would allow the two to disagree.

    <item><strong|Why notices are not new document versions.> A notice about a version is a later statement about it, not a change of the work. The exact state a reader saw, with or without a notice, is identified by the object version and its pin.

    <item><strong|Where witnesses live.> A witness of an object version can only be made after the version is committed, so it cannot be part of it (a signature of an inventory cannot be listed in that inventory). Putting each signature or timestamp in a new version would mix evidence with changes of the work, and every completion of a timestamp proof would be a version. OCFL closes the object folder to anything it does not define, and its <verbatim|logs/> folder is meant for unstructured records of actions and is not covered by digests. Object extension folders are the place OCFL provides for data that is not part of any version (the registered mutable-head extension keeps its data there), so witnesses go in <verbatim|extensions/opensheaf-witnesses/> and travel with the object.

    <item><strong|Why no HTML in deposits.> Presentations improve; deposits must not change.

    <item><strong|Why a minimal core, and extensions.> The core defines only what every archive and collection needs to be kept, cited, composed and verified. Richer structures among documents (a short account of a proof and its detailed argument, a talk and its paper, a dataset and the analyses built on it, a knowledge base linking results across papers) are built on top of it: by links inside the documents and DataCite relations, which need nothing more, or by extensions that record them with pins, so that tools follow them when they copy, verify or present documents. Keeping them out of the core leaves room for designs not yet imagined, while the pins, which fix extension data with the rest of each version, keep whatever is built checkable.

    <item><strong|Why DataCite.> It is the metadata of DOIs for repositories, with relations for versions, preprints and collections, and it maps directly to Zenodo.
  </itemize>

  <section*|Appendix G. References><label|appendix-g-references>

  <\itemize>
    <item><hlink|OCFL 1.1 specification|https://ocfl.io/1.1/spec/> and <hlink|OCFL extensions|https://ocfl.github.io/extensions/>

    <item><hlink|DataCite Metadata Schema 4.7|https://schema.datacite.org/>, <hlink|DataCite guidance on preprints|https://support.datacite.org/docs/preprints-post-prints-and-author-manuscripts> and <hlink|the REST API change for publisher and affiliation|https://support.datacite.org/docs/datacite-rest-api-affiliation-and-publisher-default-change>

    <item><hlink|RFC 2119|https://www.rfc-editor.org/rfc/rfc2119>, <hlink|RFC 8174|https://www.rfc-editor.org/rfc/rfc8174>, <hlink|RFC 8259|https://www.rfc-editor.org/rfc/rfc8259>, <hlink|RFC 3339|https://www.rfc-editor.org/rfc/rfc3339>, <hlink|RFC 3161|https://www.rfc-editor.org/rfc/rfc3161>, <hlink|RFC 4648|https://www.rfc-editor.org/rfc/rfc4648>, <hlink|RFC 8032|https://www.rfc-editor.org/rfc/rfc8032> and <hlink|RFC 7595|https://www.rfc-editor.org/rfc/rfc7595>

    <item><hlink|The did:key method|https://w3c-ccg.github.io/did-method-key/> (W3C Credentials Community Group)

    <item><hlink|JSON Schema 2020-12|https://json-schema.org/draft/2020-12>

    <item><hlink|Zenodo developer documentation|https://developers.zenodo.org/>, <hlink|InvenioRDM records API|https://inveniordm.docs.cern.ch/reference/rest_api_drafts_records/>, <hlink|Zenodo on folders|https://support.zenodo.org/help/en-gb/1-upload-deposit/74-can-i-upload-folders-directories>, <hlink|managing files|https://help.zenodo.org/docs/deposit/manage-files/>, <hlink|resource types|https://zenodo.org/api/vocabularies/resourcetypes> and <hlink|versioning|https://zenodo.org/help/versioning>

    <item><hlink|Google Scholar inclusion guidelines|https://scholar.google.com/intl/en/scholar/inclusion.html>, <hlink|FAIR Signposting|https://signposting.org/>, <hlink|OAI-PMH static repositories|https://www.openarchives.org/OAI/2.0/guidelines-static-repository.htm> and <hlink|ResourceSync|https://www.openarchives.org/rs/toc>

    <item><hlink|OpenTimestamps|https://opentimestamps.org/> and <hlink|Software Heritage identifiers|https://docs.softwareheritage.org/devel/swh-model/persistent-identifiers.html>
  </itemize>

</body>

<\initial>
  <\collection>
    <associate|page-medium|paper>
  </collection>
</initial>
