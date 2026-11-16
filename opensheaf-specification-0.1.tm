<TeXmacs|2.1.5>

<style|<tuple|notes|notes-meta>>

<\body>
  <notes-header>

  <chapter*|OpenSheaf: an open format for document archives and collections>

  <notes-abstract|Specification, version 0.1 (draft), 16 November 2026. OpenSheaf is a common, open format for archives of scholarly documents and for collections of them, built on the Oxford Common File Layout (OCFL 1.1) and the DataCite Metadata Schema (4.7). This version is experimental and may change in incompatible ways before version 1.0. The text is licensed under CC BY-SA 4.0; the JSON Schemas are dedicated to the public domain under CC0 1.0.>

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
    <item><dfn|Archive>: a set of objects kept by one archive owner (a person, group or institution), with one storage root and one discovery document, identified by an archive identifier.

    <item><dfn|Archive identifier>: a URI naming the archive independently of where it is served (section 6).

    <item><dfn|Base URL>: the URL at which an archive is currently served, ending with <verbatim|/>; its discovery document is at <verbatim|\<less\>base URL\<gtr\>opensheaf.json>.

    <item><dfn|Storage root>: an OCFL 1.1 storage root holding the objects of the archive.

    <item><dfn|Object>: an OCFL object. Its <dfn|kind> is <verbatim|document> or <verbatim|collection>.

    <item><dfn|Document>: an object holding one scholarly work (an article, notes, a thesis, a book) with its sources and renditions.

    <item><dfn|Collection>: an object holding a list of members. A collection is a catalogue or a selection (section 10.1).

    <item><dfn|Catalogue>: a collection that keeps objects whole, impartial about their versions: each member pins an object with all its versions, and may follow it as it grows. An archive's main collection, and the list of objects an archive mirrors, are catalogues.

    <item><dfn|Selection>: a collection that vets particular revisions of documents (a journal, a digest, a review journal, a reading list): each member pins a revision set, and earlier or later versions are not part of the selection unless its curator adds them, by a new version of the selection.

    <item><dfn|Revision>: a document version, as vetted by a selection, pinned by the object version that held it when it was vetted.

    <item><dfn|Revision set>: the revisions of one document vetted by a selection (usually one; more after a correction).

    <item><dfn|Mirror>: a copy, in an archive's storage root, of another archive's object, whole and byte for byte (section 10.4).

    <item><dfn|Accepted copy>: a shallow branch kept by a selection, starting from a revision it vetted from another archive (section 10.5).

    <item><dfn|Draft>: an object without a genesis record, not yet sealed; no pin may name its versions (section 6.5).

    <item><dfn|Sealing>: the object version that adds the genesis record, made at the owner's request before a version first leaves the owner's hands (section 6.5).

    <item><dfn|Genesis record>: the file <verbatim|genesis.json>, written when an object is sealed and kept unchanged in all its later versions and in its branches; its seeded digest is the object's name (section 6.5).

    <item><dfn|Name>: 52 characters of base32 from the digest of the genesis record, the same for the object in every archive, copy and branch, except a branch renamed after a clash, which takes another name of the same genesis record (section 6.5).

    <item><dfn|Owner>: whoever decides the versions of a line (a person, group, institution or key holder), identified by a URI: none for a draft, a named owner (an archive identifier, an ORCID iD, a web address) or a keyed owner (a public key) (section 6.5).

    <item><dfn|Owner identifier>: 52 characters of base32 from the digest of an owner's URI, which names the owner in a <verbatim|sheaf:> URI (section 6.6).

    <item><dfn|Originator>: the owner named in the genesis record, whose line is the origin of the name and has no parent (section 6.5).

    <item><dfn|Line>: the history of an object as decided by one owner, identified by the pair (owner, name); its object versions form a single sequence (section 6.5).

    <item><dfn|Branch>: a line of another owner continuing an object from one of its versions, the branch point: deep when it holds the earlier versions too, shallow when it holds only the branch point and its own versions (section 10.5).

    <item><dfn|Object version>: an OCFL version of an object (<verbatim|v1>, <verbatim|v2>, ...). It changes at every change of the object.

    <item><dfn|Document version>: the version of the work, a positive integer numbered by the owner of the line (for a draft, or an archive's own documents, the archive), in <verbatim|object.json> and <verbatim|datacite.json>. It changes exactly when the document's own files change (section 7.3).

    <item><dfn|Description-only version>: an object version that holds an existing document version with its files unchanged, changing only the description, the state or the notices of the object (section 7.3).

    <item><dfn|History>: the order of a document's versions in the history of the work (section 7.3).

    <item><dfn|Current version>: the document version to which readers are directed: the last in the history.

    <item><dfn|Note>: a short text, a file of the content, or both, as used for change notes, notices and withdrawals (section 9).

    <item><dfn|Member>: an entry of a collection: an object (in a catalogue) or a revision set of a document (in a selection), of any archive.

    <item><dfn|Pin>: the pair (object version, SHA-512 digest of that version's inventory file).

    <item><dfn|Rendition>: a file produced from the sources and deposited with them (a PDF, an EPUB).

    <item><dfn|Presentation>: files generated from the archive for readers (web pages, indexes, HTML versions of documents). It is never authoritative.

    <item><dfn|Custodian>: anyone who keeps copies of other archives' objects, or indexes of them, apart from those archives (section 6.6, #39).

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

    <item><strong|OpenSheaf resolver> (proposal): section 6.6, and section 6.4 for fetching; a gateway also follows the requirements on gateways in section 6.6.

    <item><strong|Profiles>, optional: an archive MAY additionally conform to the Zenodo binding (appendix A), the TeXmacs profile (appendix B) and the website profile (appendix C). A conforming archive MUST state in its discovery document which profiles it follows.

    <item><strong|Extensions>, optional: an extension is a specification published separately from this one, named by a URI (RECOMMENDED: the <verbatim|https> URL at which it is published), that records in <verbatim|object.json> what this specification leaves open, so that tools aware of it can act on it (for instance relations between documents that tools must follow when they copy or verify them). An object version records the data of an extension under <verbatim|extensions> in its <verbatim|object.json> (section 9), keyed by the name of the extension; the discovery document SHOULD list the extensions its objects use (section 6.1). Extensions MUST NOT change the meaning of what this specification defines, nor relax its requirements: an archive is conforming, and its objects and collections are read and verified, without knowing any of its extensions. Readers ignore extensions they do not know, as they ignore unknown properties (section 12). The data of an extension is part of the object version, covered by its inventory like the rest of <verbatim|object.json>, so pins fix it too.
  </itemize>

  The JSON files defined here (<verbatim|opensheaf.json>, <verbatim|object.json>, <verbatim|members.json>, <verbatim|genesis.json>, the index files and <verbatim|indexes.json> of section 6.6) MUST validate against the JSON Schemas of appendix D for their declared format version.

  <section*|5. Layout><label|5-layout>

  An archive consists of:

  <\itemize>
    <item><strong|A discovery document>, <verbatim|opensheaf.json>, at its base URL (section 6). It is REQUIRED.

    <item><strong|A storage root>, REQUIRED, conforming to OCFL 1.1, at a URL given by the discovery document. It MUST use the storage layout extension <verbatim|0002-flat-direct-storage-layout>, so that an object with identifier <verbatim|\<less\>id\<gtr\>> is at <verbatim|\<less\>storage root URL\<gtr\>\<less\>id\<gtr\>/>. It MAY contain, as loose files allowed by OCFL, a copy of the OCFL specification and of this specification.

    <item><strong|Witnesses>, OPTIONAL: signatures and timestamp proofs of object versions, in each object's extension folder <verbatim|extensions/opensheaf-witnesses/>, or under <verbatim|witnesses/> next to the discovery document (section 13.2).

    <item><strong|Indexes>, RECOMMENDED: <verbatim|names/>, <verbatim|owners/> and <verbatim|sha512/> next to the discovery document (section 6.6, proposal).

    <item><strong|Presentation files>, OPTIONAL, anywhere outside the storage root, <verbatim|witnesses/> and the indexes (appendix C).
  </itemize>

  Because OCFL does not allow directories other than objects and extensions inside a storage root, the storage root SHOULD be a dedicated folder (by convention <verbatim|ocfl/>), and presentation files MUST NOT be placed inside it.

  All files of the discovery document, the storage root, <verbatim|witnesses/> and the indexes (if used) MUST be served byte for byte, as stored: no conversion of line endings or character sets, no compression that changes the bytes delivered after decoding. Archives kept in git SHOULD mark these files as binary (for instance with <verbatim|.gitattributes> lines <verbatim|ocfl/** -text>, <verbatim|opensheaf.json -text> and, where used, <verbatim|witnesses/** -text>, <verbatim|names/** -text>, <verbatim|owners/** -text> and <verbatim|sha512/** -text>). Archives SHOULD be served over HTTPS and SHOULD allow cross-origin requests to these files (<verbatim|Access-Control-Allow-Origin: *>), so that tools running in a browser can resolve members.

  An archive MAY be kept in git and served by any static web server (GitHub Pages, object storage, a university server). A deployment guide, outside this specification, discusses hosting limits and practices.

  <section*|6. Discovery and identity><label|6-discovery-and-identity>

  <subsection*|6.1 The discovery document><label|61-the-discovery-document>

  The discovery document is the JSON file <verbatim|opensheaf.json> at the base URL of the archive. It MUST contain:

  <\itemize>
    <item><verbatim|format>: <verbatim|"opensheaf-archive/0.1">;

    <item><verbatim|specification>: the version of this specification the archive follows, <verbatim|"0.1">;

    <item><verbatim|archiveId>: the archive identifier (section 6.2);

    <item><verbatim|name>: a human-readable name;

    <item><verbatim|storageRoot>: the URL of the storage root, ending with <verbatim|/> (relative URLs are allowed);

    <item><verbatim|storageLayout>: <verbatim|"0002-flat-direct-storage-layout">;

    <item><verbatim|objects>: the list of all objects in the storage root, each with <verbatim|id>, <verbatim|kind>, <verbatim|head> (the head object version), <verbatim|inventorySha512> (the SHA-512 digest of the head inventory, as written in its checksum file) and <verbatim|status> (<verbatim|active> or <verbatim|withdrawn>, section 11); a mirror (section 10.4) also has <verbatim|mirrorOf>, the archive identifier of the archive whose object it copies; an object with a genesis record (section 6.5) also has its <verbatim|name> and <verbatim|owner>.
  </itemize>

  It MUST also contain <verbatim|profiles>, the list of profiles followed, from <verbatim|zenodo>, <verbatim|texmacs>, <verbatim|website> (an empty list if none). It SHOULD contain <verbatim|mainCollection> (the identifier of the collection that lists the archive's own documents), <verbatim|contact> (a URI) and, if its objects use extensions, <verbatim|extensions> (their names, section 4). It MAY contain <verbatim|mirrors> (base URLs of complete copies of the archive), <verbatim|tombstones> (section 11.3), <verbatim|indexes> (the indexes kept, each with the length of its prefix, section 6.6), <verbatim|keys> (section 13.2) and <verbatim|feed> (the URL of an Atom feed of new object versions).

  The discovery document is mutable: it is rewritten whenever an object is added or changed. It is a map, not a witness: what it states about objects (<verbatim|objects>: kinds, head versions, digests, status) MUST be verifiable from the storage root. Digests are written in lowercase hexadecimal, here and in every file defined by this specification.

  <subsection*|6.2 Archive identifiers><label|62-archive-identifiers>

  An archive identifier is a URI that does not change when the archive moves. It SHOULD be a <verbatim|tag:> URI (RFC 4151) built from a domain or e-mail address controlled by the archive owner at the time of creation and a date, for instance <verbatim|tag:opensheaf.org,2026:mgubi>. A DOI or another persistent URI MAY be used instead. Two different archives MUST NOT use the same archive identifier.

  <subsection*|6.3 Object identifiers><label|63-object-identifiers>

  An object identifier MUST match <verbatim|^[a-z0-9]+(-[a-z0-9]+)*$> and MUST be at most 64 characters long. It is the OCFL <verbatim|id> of the object and the name of its folder in the storage root. It MUST be unique in the archive and MUST NOT be reused, also after a takedown. Since it is permanent and appears in every URL of the object, it SHOULD be short (at most 32 characters), readable and chosen by the depositor, and SHOULD NOT be derived mechanically from the title, which may change between versions while the identifier cannot; tools importing documents propose identifiers and the depositor decides. Notwithstanding these recommendations, an archive MAY use the object's name (section 6.5), 52 characters, as its identifier, unless it keeps two objects of that name (lines of several owners). The kind of an object is given by its <verbatim|object.json>, never by its identifier. Outside the archive, an object is named by the pair (archive identifier, object identifier) of its <verbatim|object.json>, which a mirror keeps unchanged; with the proposal of section 6.5, its line is also named by the pair (owner, name), independently of any archive.

  <subsection*|6.4 Resolution><label|64-resolution>

  To fetch an object version of a member, a client:

  <\itemize>
    <item>reads the discovery document at the member's archive URL (section 10.2) and fetches <verbatim|\<less\>storageRoot\<gtr\>\<less\>id\<gtr\>/\<less\>version\<gtr\>/inventory.json>;

    <item>if this fails, tries the mirrors listed in the member, then those listed in the archive's discovery document;

    <item>if this fails, MAY use external copies: the files of an external record named in the version's <verbatim|object.json> (a DOI record), or a software archive snapshot (a SWHID).
  </itemize>

  To fetch the parent version of a branch (section 10.5, proposal), a client fetches <verbatim|inventory.json> at the <verbatim|url> of <verbatim|parent>; if this fails, or no <verbatim|url> is given, it tries the copies it knows of the parent's archive (a member or a mirror naming the same <verbatim|archiveId>, with its archive URL) and then external copies, as above. The <verbatim|url> is chosen by the branch, so a copy found only there shows that the parent can be fetched, not that it is the parent's own: a verifier counts a resolved parent as confirmation (section 14) only when it reached it at a base URL of the parent's archive known independently of the branch: the <verbatim|archiveUrl> of a member of a collection the verifier trusts (not a collection of the branch's own archive or owner, unless its user configured it), or a location configured by its user (and the mirrors listed in the discovery document found there). External copies (a DOI deposit) can attest the parent version, but do not resolve it, since they hold no inventory.

  Any copy whose bytes match the pinned digest is acceptable: integrity comes from the pin, not from the place.

  <subsection*|6.5 Names, owners and lines><label|65-names-owners-and-lines>

  <os-alert|note|Note.|<strong|Proposal.> This section, and the sections it changes (3 to 5, 6.1 to 6.4, 7, 8.1, 9, 10.2 to 10.6, 11.3, 13.2, 14 to 16 and appendices D to F, with the FAQ and the use cases), together with section 6.6, are a proposal on the branch <verbatim|proposal/identity>, not yet agreed. It builds on the discussions of self-certifying names (#20), decentralised holding and keys (#13), global names (#14), private and draft objects (#29) and the evidence of accepted copies (#22).>

  An object identifier names an object within its archive (section 6.3). An object also has a name, independent of any archive, and an owner. The pair (owner, name) identifies a line: the history of the object as decided by that owner. Copies of a line (mirrors, section 10.4) are the same line wherever they are kept; lines of other owners with the same genesis record are branches (section 10.5).

  <strong|Genesis record.> When an object is sealed, at its owner's request, before a version of it first leaves its owner's hands (shared privately, for instance submitted to a journal, or published; #29), its owner writes the genesis record, the JSON file <verbatim|genesis.json> at the root of the content, with <verbatim|format> (<verbatim|"opensheaf-genesis/0.1">), <verbatim|kind> (<verbatim|document> or <verbatim|collection>, the <verbatim|kind> of the object), <verbatim|created> (the date and time, in UTC), <verbatim|originator> (the owner of the first line, a URI) and <verbatim|nonce> (at least 128 bits from a cryptographically secure random generator, in lowercase hexadecimal). The genesis record MUST be part of every later object version of the object and of its branches, byte for byte. It contains neither the name nor the object identifier, so that the name does not depend on itself. It MUST be written in UTF-8 without a byte order mark (section 2), and SHOULD have LF line ends; since the name is the digest of its bytes as stored, tools MUST NOT rewrite or re-serialise it, and need no canonical form to check it.

  <strong|Name.> The name of the object is the SHA-256 digest of the seed <verbatim|opensheaf-name-0> (ASCII, followed by a line feed) followed by the bytes of <verbatim|genesis.json>, written in lowercase base32 (RFC 4648, without padding): 52 characters, a valid object identifier (section 6.3). The last character carries the last bit of the digest and, in its four remaining bits, the number k of the algorithm that made the name, from 0 to 15: algorithm k is the same with the seed <verbatim|opensheaf-name-\<less\>k\<gtr\>> (k in decimal), so that algorithm 0 gives a last character <verbatim|a> or <verbatim|q>. Names are made by algorithm 0, except a branch named by another algorithm to avoid a clash (below); names made by different algorithms never coincide. A later version of the genesis record MAY use another hash function. Since RFC 4648 sets the four bits to zero, names are compared as strings and never decoded. Anyone holding a copy can compute it; it is unique without a registry in practice, since the record holds a random nonce; since a name is used to refer to objects, clashes are resolved where objects are created (below). <verbatim|object.json> records it as <verbatim|name>. An archive MAY use the name as the object identifier.

  <strong|Owner.> The owner of a line is a URI, recorded in <verbatim|object.json> as <verbatim|owner> from the first version of its line. There are three cases:

  <\itemize>
    <item>a <strong|draft> has no owner and no genesis record yet; it receives both when it is sealed. The absence of a genesis record is what marks a draft: it is part of the content, so it travels with every copy, and no other mark is needed. An object version without a genesis record MUST NOT be named by a pin (in a collection, or as a parent). Whether a draft may be rewritten before sealing is open (#29, below);

    <item>a <strong|named owner> is a URI that the owner asserts: the archive identifier, an ORCID iD (<verbatim|https://orcid.org/...>), a web address the owner controls. It costs nothing, and proves no more than the archive that serves the line;

    <item>a <strong|keyed owner> is a public key written as a URI: <verbatim|did:key:> (the key itself) or <verbatim|openpgp4fpr:> followed by an OpenPGP fingerprint. Every object version of a keyed line (from its first sealed version, or for a branch after the branch point) MUST be signed with that key, and the key needed to check the signatures MUST travel with the object (section 13.2), so that the line can be checked without trusting any host, also after its archive has disappeared.
  </itemize>

  A named owner MAY sign its versions with keys of its own (<verbatim|keys> of the discovery document); its line is still identified by the named URI, and such signatures are witnesses, not proofs of ownership.

  <strong|Comparing owners.> Owners, originators and the owners in <verbatim|parent> are compared as strings, exactly. Tools MUST write them in these forms: an ORCID iD as <verbatim|https://orcid.org/> followed by the iD, without a trailing slash; <verbatim|openpgp4fpr:> followed by the fingerprint in lowercase hexadecimal; <verbatim|did:key:> as defined by the did:key method (W3C CCG), multibase base58btc, for an Ed25519 key (multicodec <verbatim|ed25519-pub>, code <verbatim|0xed>, written as the varint bytes <verbatim|0xed 0x01>); other URIs as the owner first wrote them.

  <strong|One writer per line.> The object versions of a line form a single sequence, each extending the one before, as OCFL objects do: an owner MUST NOT publish two different object versions with the same number for the same line, in one archive or in several. A line keeps one archive identifier and one object identifier in all its copies (a mirror keeps them unchanged, section 6.3); moving a line to another archive is open, with handing it over (below). Since every version directory keeps the inventory as of that version (section 7.1), two copies of a line can be compared from their inventories alone: two copies whose heads are <verbatim|vk> and <verbatim|vm>, with k not greater than m, agree when <verbatim|vk/inventory.json> is the same file, byte for byte, in both. Two copies that do not agree are a fork of the line. For a keyed owner the signatures show that the owner made both, and the fork is its error; for a named owner it shows only that two parties wrote under the same URI, since anyone can assert it. A fork is found only by someone who sees both copies.

  <strong|Depositors.> An archive that accepts deposits from more than one depositor MUST bind each named owner URI of the lines it keeps (those with its own <verbatim|archiveId>) to the depositors allowed to write under it, and MUST bind a URI only to a depositor it has checked can use it (for an ORCID iD, by an ORCID login; for a web address or an archive identifier, by control of it), so that no depositor continues another's line or opens a line under another's URI. Keyed lines need no binding, since their signatures decide, and mirrors are not bound, since they copy lines of other archives unchanged.

  <strong|Origin.> The line of the originator is the origin of the name, and has no parent. Every other line with the same genesis record MUST declare its parent (section 10.5); a line of another owner that declares none is not a valid line of the name.

  <strong|Sealing and transfer.> The object version that seals a draft adds the genesis record and makes its owner the first writer. The owner seals an object before first sharing or publishing a version of it, and tools SHOULD seal only at the owner's request, not as a side effect. A draft MAY be kept in an archive (served only to its owner, or listed in a public discovery document as work not yet shared, on which nothing may rely, #29), but cannot be pinned: a catalogue that follows it (section 10.2) pins it only once it is sealed. Versions made before sealing stay in the object's history, fixed by every later pin like any earlier version, but belong to no line and cannot be named by a pin or vetted (whether sealing may instead rewrite them is open, below). This proposal does not hand lines over (an open question, below): when another owner continues the work (an author leaving an institution's repository, when the line is the institution's; a journal handing a report to its referee; a line the author owns as originator is not branched by the author but moved, an open question below), the new owner makes a deep branch (section 10.5), and the previous owner MAY add a notice to its own line pointing to the branch.

  <strong|Clashes.> A name is used to refer to objects, so the format does not assume that two works never share one: in an archive, an object is identified by its line, and no two objects of an archive have the same owner and name (section 14). A clash can arise only when an object is created or deposited in an archive, and is resolved there, against the archive and the confirmed lines of the same owner elsewhere:

  <\itemize>
    <item>when sealing, a tool checks the line (owner, name) against the archive and, if it is taken, draws a new nonce, so that the originator's line is always named by algorithm 0; an object sealed outside the archive's storage root and shared before its deposit can still meet a taken line when it is deposited (only after a reused genesis record or a collision), and is then refused, its owner sealing it anew;

    <item>a branch is never owned by the originator, whose line is the origin and has no parent: how the originator takes in another line's work is open (below); a tool refuses such a branch;

    <item>a branch is named by <verbatim|parent.name>, unless its line (its owner, that name) is taken by another object, in its archive (any object there, or a tombstone) or among the other lines of its owner that the tool knows elsewhere and that are confirmed (section 6.6: reached through the archive named by their <verbatim|archiveId>, known independently, or signed by a keyed owner); a line known elsewhere only from index entries, without a confirmed copy, is reported and never causes a rename; if that object is the owner's own branch (one the owner made: for a keyed owner, its signatures hold; for a named owner, the archive that keeps it accepts the move under the same authority it requires for any new version of that line; any other object counts as another object; a mirror of the owner's own branch counts as that branch) of the same parent line and the new branch point is later in the parent line's history than that branch's current branch point, the owner moves its branch point instead (section 10.5), in the archive that keeps that branch, and a mirror of it is then brought up to date; a tool that cannot do so renames the new branch as below; otherwise (another genesis record, a mirror of anything else, another parent line, an earlier or equal branch point) the branch is named by the smallest algorithm number greater than that of <verbatim|parent.name> whose name, over the same genesis record, gives a line free in the archive and among the owner's known confirmed lines; <verbatim|parent> keeps the parent's name; if no number up to 15 is free, the branch is refused. An accepted copy of another selection is not renamed: owners differ between selections (section 10.5);

    <item>a mirror whose line is taken cannot be kept there;

    <item>a line stays taken after a takedown (section 11.3: the tombstone keeps the name and the owner identifier), like the object identifier, so that a removed line and a new one never share a URI in that archive.
  </itemize>

  Other owners' lines are different lines and never clash. A renamed branch is always written with its owner part (section 6.6), since a URI without an owner part names the originator's line, which is named by algorithm 0; a resolver given a renamed name without an owner part finds no originator's line, and reports it, pointing to the search for the work. Lines of one owner in archives the tool does not know may still duplicate each other; they are forks of the line, found by resolvers (section 6.6).

  <strong|Refusals.> One genesis record names one work, and one owner identifier one owner. Every line records, in <verbatim|sealed> of its <verbatim|object.json> (section 9), the version that sealed the work: the <verbatim|archiveId>, <verbatim|objectId> and <verbatim|objectVersion> of the originator's sealing version, which every branch copies unchanged from its parent. When an object is created or deposited, an archive refuses an object whose genesis record is that of an object it holds, or one of whose 16 names is the name of a tombstone it holds (section 11.3), but whose <verbatim|sealed> differs from that object's or tombstone's (a genesis record reused for another work: its owner seals the other work anew); and an object whose owner (at its head; for a mirror, the mirrored line's) has the owner identifier of another owner at the heads of the archive (another URI): it is kept only under another owner URI, and a mirror is then refused. A tool MUST NOT copy a genesis record into an object that is not a mirror or a branch of the work it was written for, nor reuse a nonce. What an archive cannot see (a clash with an object or an owner of another archive) is found by resolvers: the search for a work groups lines by <verbatim|sealed> and lists different groups as different works, and owner identifiers are compared through <verbatim|owners/> (section 6.6).

  <strong|Existing objects.> This draft assumes that every sealed object has a genesis record: archives made under earlier drafts are rebuilt, as the warning at the head of this specification allows before version 1.0.

  <strong|Open questions.>

  <\itemize>
    <item>Registering the scheme <verbatim|sheaf> with IANA, as a provisional scheme (RFC 7595), since section 6.6 uses it in place of the <verbatim|tag:> or ARK form chosen in #14 (#36); whether the pair (archive identifier, object identifier) keeps a URI form of its own beside <verbatim|sheaf:> URIs; the form of archive identifiers (<verbatim|tag:> or ARK) (#14).

    <item>Who keeps indexes of many archives, so that an object can be found once its archive has gone, how resolvers find them, and whether the project runs a shared resolver of <verbatim|sheaf:> URIs, a gateway (section 6.6): at <verbatim|https://opensheaf.org/sheaf:...>, as written provisionally, or on a domain used only for resolution, such as <verbatim|https://sheaf.pub/>, without <verbatim|sheaf:> in the path (#13, #20, #35).

    <item>How co-authors own a line: one owner, a group key, several controllers as #20 proposes, or a branch each; and how the originator takes in another line's work (a co-author's, a journal's corrections), since its line has no parent and it does not branch its own work.

    <item>Lines of one owner duplicated in archives that do not know of each other (two branches of one co-author, accepted copies of one journal in two archives): forks that only resolvers see.

    <item>The numbering of document versions on branches after the branch point (section 10.5), which <verbatim|/v\<less\>n\<gtr\>> in a <verbatim|sheaf:> URI follows (section 6.6).

    <item>Whether a line may be handed over to another owner, instead of being continued by a deep branch, or moved to another archive, under another archive identifier.

    <item>Moving a branch point when the branch has files of its own (the files of its notices, of a withdrawal, of its version of record): the moving version should probably be a merge keeping both, the new parent version's files and the branch's own, with evidence that tells them apart (section 10.5).

    <item>Keys: whether lines should require them (#20 proposes so); loss, compromise and rotation (<verbatim|did:key> cannot rotate, while <verbatim|did:web> or <verbatim|did:webvh> can); several keys per line, including a recovery key; tying a key to an identity such as an ORCID iD (#13, #41).

    <item>Whether a draft may be rewritten before it is sealed, against the rule that versions are fixed, and whether tools MUST seal only at the owner's request (#29).

    <item>Holding and copying among custodians, which this proposal leaves to #39: copies kept apart from the storage root, <verbatim|mirrors> as locations, mirrors made by agreement, and statements of custodians.

    <item>Takedowns: a branch keeps the parent version after the parent is taken down, and mirrors, indexes kept by others and gateways may go on serving a taken-down object (#33).

    <item>A deep branch whose parent's object identifier is already taken in the branch's archive.

    <item>Whether aliases (a new genesis record that wraps the old one) are needed, if refusing reused genesis records and colliding owner identifiers at creation (section 6.5) proves too strict, and whether a <verbatim|sheaf:> URI may write the owner itself instead of its identifier (#44).

    <item>The field names: <verbatim|name> also names the archive, in the discovery document.
  </itemize>

  <subsection*|6.6 Names as URIs and finding objects><label|66-names-as-uris-and-finding-objects>

  <os-alert|note|Note.|<strong|Proposal.> This section is part of the proposal of section 6.5 (branch <verbatim|proposal/identity>): writing lines, versions and pins as URIs, and finding objects by name (#14, #20). It replaces the decision recorded in #14 (global names as <verbatim|tag:> or ARK URIs built from the archive identifier, with <verbatim|sheaf:> kept in reserve): a line now has a name independent of any archive, and <verbatim|sheaf:> URIs write it; archive identifiers stay as section 6.2 says.>

  <strong|Owner identifier.> The owner identifier of an owner is computed as a name by algorithm 0 (section 6.5), over its URI as recorded (in the canonical form of section 6.5, where one is defined), encoded in UTF-8 without a line end, instead of <verbatim|genesis.json>: 52 characters. It names an owner inside a URI, where the owner's own URI, which holds <verbatim|:> and <verbatim|/>, cannot be written. <verbatim|genesis.json>, <verbatim|object.json>, <verbatim|parent> and the members of collections record the owner's URI, never its identifier; indexes record both (below), and tombstones the identifier, and the URI unless a takedown erases it (section 11.3).

  **The <verbatim|sheaf> URI.** A line, a document version of a line, one object version, or the object as a whole, is written as a URI of the scheme <verbatim|sheaf>:

  <\verbatim-code>
    sheaf:\<less\>name\<gtr\> \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ the line of the originator

    sheaf:\<less\>name\<gtr\>:\<less\>owner id\<gtr\> \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ the line of that owner

    sheaf:\<less\>name\<gtr\>:* \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ the object as a whole, all its lines

    sheaf:\<less\>name\<gtr\>/v\<less\>n\<gtr\> \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ document version n of the originator's line

    sheaf:\<less\>name\<gtr\>:\<less\>owner id\<gtr\>/v\<less\>n\<gtr\> \ \ \ \ \ \ \ \ \ \ \ document version n of that owner's line

    sheaf:\<less\>name\<gtr\>[:\<less\>owner id\<gtr\>]/v\<less\>n\<gtr\>?sha512=\<less\>digest\<gtr\> \ \ one object version holding it
  </verbatim-code>

  The parts are, in this order: <verbatim|sheaf:> and the name; optionally <verbatim|:> and an owner identifier, or <verbatim|:*>, which names all the lines and takes no document version and no <verbatim|sha512> (the owner part is <verbatim|:> and an owner identifier; <verbatim|:*> is not an owner part); optionally <verbatim|/v> and a document version, a positive integer without leading zeros; optionally <verbatim|?> and a query of parameters <verbatim|key=value> joined by <verbatim|&>, among them at most one <verbatim|sha512>, only after a document version, whose value is the SHA-512 digest of an inventory file, 128 lowercase hexadecimal digits, as in a pin (section 10.2), and at most one <verbatim|at>, after <verbatim|sha512> if both are present (below). A resolver ignores parameters it does not know; no part other than the value of <verbatim|at> is percent-encoded; this proposal defines no fragment. The scheme, the name, the owner identifier, <verbatim|v>, the digest and the parameter names are lowercase, and a resolver MAY fold uppercase letters in them; the value of <verbatim|at> is case-sensitive.

  <\itemize>
    <item><strong|The owner.> Without an owner part, a URI names the line of the originator, the owner named by <verbatim|originator> in the genesis record, which every copy of the object and of its branches carries. If a resolver finds several genesis records under one name (with the same originator or not), the URI is ambiguous: it lists them with their originators and does not choose. It does not mean the latest line or the most authoritative one: the versions of any other line, such as a journal's or a co-author's, are written with their owner, and if the originator stops and another owner continues the work in a deep branch, the URI still names the originator's line. <verbatim|sheaf:\<less\>name\<gtr\>:*> names the object as a whole, with all its lines: a resolver shows the lines it knows that pass the checks below, each marked confirmed or unconfirmed. A resolver rejects <verbatim|:*> with a document version or <verbatim|sha512>, since every line has its own document versions (section 10.5); <verbatim|at> is allowed with it.

    <item><strong|The version.> <verbatim|/v\<less\>n\<gtr\>> is a document version of the line (section 7.3, also on a branch), not an OCFL object version. It names only object versions of the line: sealed versions (with a genesis record) whose <verbatim|object.json> has the line's owner. The versions of a deep branch up to its branch point belong to its parent's line, and are named with the parent's owner; a document version held only by versions made before sealing (section 6.5) belongs to no line and has no <verbatim|sheaf:> URI. On a deep branch, a document version held only by its copied versions names nothing on the branch's line: a resolver points to the parent's URI. Several object versions of the line may hold document version n: without a digest, the URI names the one listed for n in the <verbatim|history> of the line's head, or, without <verbatim|history>, the last object version of the line holding n (section 7.3). What it names can then change as the line grows, by a description or a notice, and copies with different heads may answer differently: a resolver uses the latest head among the confirmed copies that agree (section 6.5, and below), and reports a later head found only in unconfirmed copies as an unconfirmed extension, without using it; with no confirmed copy, it uses the latest head among the unconfirmed copies that agree, and reports the result as unconfirmed; if some unconfirmed copies disagree with the others, it lists them all and does not choose.

    <item><strong|The pin.> With a digest, the URI names exactly the object version whose inventory file has that digest. A resolver MUST check that digest, and that the version holds a genesis record whose name, by the algorithm of the name's last character, is the name, has the URI's name as <verbatim|name> and the line's owner as <verbatim|owner> in its <verbatim|object.json> (the owner part, or the originator), and holds document version n; it reports a mismatch as section 14 does. Citations of a fixed version SHOULD carry the digest.

    <item><strong|The hint.> <verbatim|at> names an archive where a copy is expected, where a resolver looks first: its value is the archive's base URL, an <verbatim|https> URL ending with <verbatim|/>, percent-encoded in full (every character outside the unreserved characters of RFC 3986 is encoded, as <verbatim|encodeURIComponent> does) and decoded once: <verbatim|sheaf:\<less\>name\<gtr\>/v3?sha512=\<less\>digest\<gtr\>&at=https%3A%2F%2Fauthors.example.org%2F>. It is not part of the identity.

    <item><strong|Equality.> The canonical form of a <verbatim|sheaf:> URI has complete parts, lowercase where the case is folded, and, for <verbatim|:*>, the name made by algorithm 0, since all the names of a genesis record name the same work; it has no owner part when the owner is the originator (read from the genesis record, which any copy carries and the name certifies, section 6.5, so that deciding equality may need one copy of <verbatim|genesis.json>), and no <verbatim|at> and no unknown parameters. Two URIs name the same thing when their canonical forms are equal, byte for byte, and files that record a <verbatim|sheaf:> URI (for instance among the relations of <verbatim|datacite.json>) record its canonical form.
  </itemize>

  <strong|Checks and confirmation.> A resolver checks every copy it finds: the name is a name of its <verbatim|genesis.json>, by the algorithm of its last character, the <verbatim|name> and <verbatim|owner> in <verbatim|object.json> are the line's, and, with a digest, the rest of the checks of a pin. A copy that passes them is the object version named by a URI with a digest, wherever it was found, since the pin fixes it. Without a digest, a copy shows only that someone published versions under that owner and name, which a named owner cannot prevent (section 6.5): a resolver MUST report such a copy as confirmed only when it reached it at a base URL of the archive that keeps the line (the archive named by <verbatim|archiveId> in the copy's <verbatim|object.json>), known independently of the URI and of indexes kept by others, as section 6.4 says, or when the owner is keyed and its signatures hold; confirmation reads <verbatim|archiveId> from the copy's own <verbatim|object.json>, never from an index entry. This confirms the archive that keeps the line, not the person or body its owner names, which owner proofs would show (#41); it MUST report every other copy (one found through <verbatim|at>, or through an index kept by a custodian) as unconfirmed, with where it was found. When confirmed copies of a line disagree (for a keyed owner, copies whose signatures hold), they are a fork (section 6.5): the resolver reports it and does not choose. Confirmed copies of the same named owner and name whose <verbatim|archiveId> differ are a conflict about which archive keeps the line, since a line has one archive identifier (section 6.5): the resolver reports it with the archives, and does not choose. An unconfirmed copy that disagrees with a confirmed one is reported as a warning, and does not stop the resolution.

  <strong|Searching for a work.> A work is its genesis record, and its lines may be named by any of the 16 names the record gives (section 6.5: a branch is renamed after a clash). To find every line of a work (for <verbatim|sheaf:\<less\>name\<gtr\>:*>, or a search by work), a resolver: obtains the genesis record (from any entry or copy found under the name, checked against it); computes its 16 names, by every algorithm; looks each of them up in the indexes it knows; and keeps only the entries whose genesis record is, byte for byte, the one it obtained, discarding the others as collisions (removed entries without a genesis record are listed apart, as removed lines of those names; removed entries that kept it are grouped by the <verbatim|sealed> of the index, there being no copy, and marked removed); it groups the lines it keeps by their <verbatim|sealed>, read from the copies (<verbatim|object.json>), not from indexes kept by others, and lists different groups as different works (a genesis record reused in two archives), each marked confirmed or unconfirmed like lines, without choosing. The comparison is of bytes, so it does not rely on any hash being free of collisions. Resolving a line needs no search: <verbatim|sheaf:\<less\>name\<gtr\>> names the originator's line, always named by algorithm 0 (a clash when sealing draws a new nonce), and <verbatim|sheaf:\<less\>name\<gtr\>:\<less\>owner id\<gtr\>> names exactly that line.

  <strong|Short forms.> For people reading and typing them, the name and the owner identifier MAY be shortened to a prefix of at least 8 characters: <verbatim|sheaf:2kukpn74/v3>, <verbatim|sheaf:2kukpn74:xx2gb5hz/v3>. A part of 52 characters is complete; a shorter one is a prefix. A short name with <verbatim|:*> (<verbatim|sheaf:2kukpn74:*>) expands among names, whatever their owners, and is ambiguous when names of several genesis records match; once expanded, the work is searched for as above. A resolver expands a short form among the lines it knows of (from the indexes below, the archives and collections it reads, and its user's configuration), counting only the lines whose copies pass the checks above:

  <\itemize>
    <item>the candidates are the lines whose name starts with the name part and whose owner identifier starts with the owner part; without an owner part, the lines of the originators. Each is confirmed or unconfirmed, as above: confirmed when a copy was reached through the archive that keeps the line, at a location known independently, or is signed by its keyed owner;

    <item>if there are confirmed candidates, all of the same owner and, for a named owner, kept by the same archive (the same <verbatim|archiveId>), the short form names the first of them in that owner's order: the line whose first object version of that owner (for the originator, the version that sealed it; for a shallow branch, its first version; for a deep branch, its first version after the branch point) has the earliest <verbatim|created> in its inventory, compared as instants. The unconfirmed candidates MUST NOT win: the resolver shows them beside its answer, as warnings;

    <item>if there is no confirmed candidate and exactly one unconfirmed one, the short form names it, and the resolver reports it as unconfirmed;

    <item>otherwise (confirmed candidates of different owners, or of one named owner in different archives, two with the same <verbatim|created>, or several unconfirmed candidates and no confirmed one), the short form is ambiguous: the resolver MUST NOT choose one, and lists the candidates with their full forms, their originators and the archives that keep them.
  </itemize>

  The order of an owner's lines is trusted only within one archive that keeps them, or under the owner's key. Anyone can write a line under a named owner's URI, with any <verbatim|created>, and search for a name with a given prefix (8 characters are 40 bits); such a line is unconfirmed, unless its maker also runs an archive the resolver knows, and then it is confirmed in another archive than the owner's lines, so the short form becomes ambiguous: it is seen, and cannot take the short form over. Another owner, confirmed in an archive of its own, can likewise at most make a short form ambiguous. A resolver knows only the lines it has seen, and confirms only those whose archives it knows, so two resolvers may expand a short form differently, and a short form that is unique today may become ambiguous later, while a full form never changes. Short forms are therefore for people (text, citations, a lookup typed by hand): pins, <verbatim|parent>, <verbatim|members.json> and every other file defined by this specification MUST use complete parts, never prefixes, a resolver SHOULD show the full form of what it resolved, and landing pages and citation metadata SHOULD give the full form, and MAY add a short one. A short form printed or kept where it cannot be corrected (a paper, a slide) SHOULD have at least 16 characters in each part (80 bits), which cannot be searched for.

  <strong|Indexes.> To find objects by name, by owner or by inventory digest without knowing their archive, an archive SHOULD keep three indexes of its own objects next to its discovery document, declared there in <verbatim|indexes> (section 6.1), and a custodian or a resolver MAY keep the same files for the objects of many archives, at a base URL of its own, declared in <verbatim|\<less\>base URL\<gtr\>indexes.json>:

  <\itemize>
    <item><verbatim|names/\<less\>p\<gtr\>.json>, where <verbatim|\<less\>p\<gtr\>> is the first characters of a name: the objects whose names start with them, each entry with <verbatim|name>, <verbatim|originator> (from the genesis record), <verbatim|owner>, <verbatim|ownerId> and <verbatim|objectId>, and <verbatim|genesis>, the exact text of its <verbatim|genesis.json>, the string whose UTF-8 encoding is exactly the bytes of the file, so that a work can be searched for, and collisions removed, from the indexes alone (above); and <verbatim|sealed>, as in <verbatim|object.json>;

    <item><verbatim|owners/\<less\>p\<gtr\>.json>, where <verbatim|\<less\>p\<gtr\>> is the first characters of an owner identifier: the owners whose identifiers start with them, each entry with <verbatim|ownerId>, <verbatim|owner> and <verbatim|names>, the names of that owner's objects in the storage root, so that the lines of an owner can be listed (in an index kept for several archives, one entry for each owner and archive); a takedown removes the name, and the entry once it lists none;

    <item><verbatim|sha512/\<less\>p\<gtr\>.json>, where <verbatim|\<less\>p\<gtr\>> is the first hexadecimal digits of an inventory digest: the sealed object versions whose inventories have digests starting with them, each entry with <verbatim|inventorySha512>, <verbatim|objectId> and <verbatim|version> (the object version).
  </itemize>

  The length of <verbatim|\<less\>p\<gtr\>> is declared for each index, from 2 to 4 characters: 2 suits a small archive, while an archive of millions of versions declares 4, so that each file stays small. Each index file is a JSON object with <verbatim|format> (<verbatim|"opensheaf-index/0.1">), <verbatim|index> (<verbatim|names>, <verbatim|owners> or <verbatim|sha512>, the folder it is in) and <verbatim|entries>, every entry starting with the file's <verbatim|\<less\>p\<gtr\>>; the declaration (in <verbatim|indexes> of the discovery document, or in <verbatim|indexes.json>, a JSON object with <verbatim|format> and <verbatim|indexes>) maps each index kept to the length of its <verbatim|\<less\>p\<gtr\>>. An index kept for several archives adds to each entry <verbatim|archiveId> and <verbatim|archiveUrl>: the archive serving that copy and its base URL (for a mirror, the mirroring archive). An archive's indexes list every object of its storage root with a genesis record and every sealed version of it, each entry of <verbatim|names/> and <verbatim|sha512/> with <verbatim|status> (<verbatim|active> or <verbatim|withdrawn>); a tombstoned object keeps its entries with <verbatim|status> <verbatim|removed>, so that a resolver can report it as section 11.3 asks; a removed entry of <verbatim|names/> keeps <verbatim|name>, <verbatim|ownerId>, <verbatim|objectId>, <verbatim|status> and <verbatim|sealed>, and MAY drop <verbatim|owner>, <verbatim|originator> and <verbatim|genesis>, so that a takedown can erase them (section 16). A file with no entries is omitted, so that, where the indexes are declared, a missing file means no entry. A resolver looks up a URI in <verbatim|names/> at the archives and indexes it knows, starting from <verbatim|at>, keeping the entries whose <verbatim|ownerId> matches the owner part, or, without an owner part, those whose <verbatim|owner> is their <verbatim|originator> (for a removed entry without them, whose <verbatim|ownerId> is the owner identifier of the originator read from any copy of the genesis record; when no copy of the genesis record is found, it is reported as a removed line of that name, owner unknown), or, for <verbatim|:*>, every entry found by the search for the work (above), each line checked and confirmed separately, then reads the history of the object it finds; it looks up a pin in <verbatim|sha512/>, and an owner in <verbatim|owners/> (two different owner URIs under one owner identifier are a collision: the resolver lists them and does not choose); at an archive that keeps no indexes, it MAY read <verbatim|objects> of the discovery document instead, which gives each object's <verbatim|name> and <verbatim|owner>, and fetches <verbatim|genesis.json> and <verbatim|object.json> from the objects for the search. Like the discovery document, indexes are maps, not witnesses: they are rewritten when objects change, and a resolver checks what it finds as above.

  <strong|Gateways.> Browsers do not resolve <verbatim|sheaf:> URIs. A gateway is a web service that does it for them: it serves a URI at its base URL followed by the URI, unchanged, for instance <verbatim|https://opensheaf.org/sheaf:2kukpn74/v3?sha512=c07a...>, so that an absolute link and its URI are turned into each other by adding or removing the base URL (a relative link starting with <verbatim|sheaf:> is read as a <verbatim|sheaf:> URI, so gateway links are written in full). A gateway is a resolver like any other, and:

  <\itemize>
    <item>it MUST answer with a real HTTP status: a page (200) showing what it resolved, or a temporary redirect (302, 303 or 307) to a copy; it MUST NOT redirect permanently (301 or 308), since copies move and are taken down, and it MAY cache its own result for a URI with a digest, but not for one without; it MUST redirect only to a copy at a base URL of a confirmed archive, never to a location given only by <verbatim|at> or by an index kept by others, and otherwise answers with a page that links to the copy and marks it unconfirmed; <verbatim|sheaf:\<less\>name\<gtr\>:*> shows the lines it knows;

    <item>it MUST show whether what it resolved is confirmed or unconfirmed, and where it was found, and treats a copy found only through <verbatim|at>, for a URI without a digest, as unconfirmed;

    <item>it MUST NOT serve the files of an archive from its own origin, but redirects or links to the archive (section 15);

    <item>when it fetches on behalf of its users, it MUST fetch only <verbatim|https> URLs at public addresses, with limits on size and time.
  </itemize>

  Whether the project runs a gateway, on which domain, and whether a domain used only for resolution (such as <verbatim|sheaf.pub>) drops <verbatim|sheaf:> from the path, as <verbatim|https://doi.org/> drops <verbatim|doi:>, is still to be decided (section 6.5, #35).

  <section*|7. Objects><label|7-objects>

  <subsection*|7.1 Common rules><label|71-common-rules>

  Every object MUST be a valid OCFL 1.1 object. Its inventories MUST use <verbatim|sha512> as digest algorithm. Every object version MUST contain, in its content, the files <verbatim|object.json> and <verbatim|datacite.json> at the top level, and, from the version that seals the object, <verbatim|genesis.json> (section 6.5); every version of a shallow branch, and every version of a branch from the version that moves its branch point, also holds <verbatim|parent.inventory.json> and <verbatim|parent.object.json> (section 10.5), unchanged until the branch point moves again; a deep branch of such a branch copies them with the versions it copies, but its own versions do not hold them until its own branch point moves. These are the identity files of the object; they are not files of the document's own (section 7.3), and the names <verbatim|genesis.json>, <verbatim|parent.inventory.json> and <verbatim|parent.object.json> are reserved for them at the top level of the content. Every version directory MUST contain a copy of the inventory as of that version, with its checksum file (OCFL makes this a recommendation; OpenSheaf requires it, so that each version can be pinned and fetched on its own). Version directories MUST NOT be zero-padded (<verbatim|v1>, <verbatim|v2>, ..., not <verbatim|v001>), which OCFL allows. OCFL recommends that object identifiers be URIs; OpenSheaf identifiers are short names (section 6.3), so OCFL validators may warn about them.

  Each version in the inventory MUST have a <verbatim|user> with a <verbatim|name>, and SHOULD have an <verbatim|address> (an ORCID iD, a <verbatim|mailto:> URI or another URI identifying the depositor), and MUST have a <verbatim|message> describing the change. The inventory is the record of deposits: the <verbatim|created> date and the <verbatim|user> of an object version are when and by whom it was deposited, and the deposit of a document version is that of the first object version holding it. They are not repeated in <verbatim|object.json>.

  Logical paths MUST be encoded in UTF-8 in Unicode normalisation form C, MUST NOT begin with <verbatim|/>, and MUST NOT contain <verbatim|.> or <verbatim|..> segments.

  <subsection*|7.2 Documents><label|72-documents>

  A document version contains, at the top level of its content unless a profile says otherwise:

  <\itemize>
    <item>the <strong|sources>: the main source and every file needed to produce the renditions that is not part of the toolchain (images, bibliography databases, local style files). The main source is named in <verbatim|object.json>. Sources SHOULD be flat (no sub-folders) when possible. When the sources of a version are not available (for instance a version imported from a service that keeps only its PDF), the version has none, and <verbatim|object.json> says so (section 9);

    <item>the <strong|renditions>, OPTIONAL but RECOMMENDED: at least a PDF for documents meant to be read and cited, named in <verbatim|object.json>;

    <item>the files of notes, if any (the change note, notices, a withdrawal; section 9), named in <verbatim|object.json>;

    <item><verbatim|datacite.json> (section 8) and <verbatim|object.json> (section 9), and the identity files of section 7.1 (<verbatim|genesis.json>, and, where section 7.1 requires them, <verbatim|parent.inventory.json> and <verbatim|parent.object.json>).
  </itemize>

  HTML versions and other presentation files SHOULD NOT be deposited, since they depend on the presentation and are regenerated when it improves.

  <subsection*|7.3 Document versions><label|73-document-versions>

  <strong|Numbering.> Document versions are numbered by the owner of the line (for an archive's own documents, the archive), from 1, without gaps, independently of any external numbering: a work whose versions 1, 3 and 4 are available on arXiv has document versions 1, 2 and 3. A branch (section 10.5) starts from the document version of its first branch point (for a deep branch, an own version that adds no files of the document's own keeps the number it holds; its first own version that adds files of the document's own takes the number after the highest document version in the object, the copied versions included, and goes last in <verbatim|history>, so that the branch's own work is its current version, and its later versions follow the rules of this section; a branch does not complete the versions it copies from its parent), and continues without gaps from it (provisionally: option (a) of the open question of section 10.5); an object version that moves the branch point is the branch's next document version, and <verbatim|parent> keeps the parent's own number.

  <strong|Identity versions.> An object version that seals an existing draft without adding files of the document's own adds only identity files (section 7.1), which are not files of the document's own: it keeps the document version it holds, and is otherwise treated as a description-only version. An object sealed by a version that also adds files of its own (for instance an object sealed at its first version) takes a new document version, as any new version does. External labels (arXiv's <verbatim|v3>) are recorded in <verbatim|external> (section 9), and presentations SHOULD show them with the document version.

  <strong|New versions.> A new document version number is assigned exactly when files of the document's own (sources, renditions, change note) that were not deposited before are added, except when a version without sources is completed (below). An object version holding the same sources, renditions and change note as an earlier document version keeps its number.

  <strong|Description-only versions.> A description-only version holds an existing document version, with its files unchanged, and changes only its description (<verbatim|datacite.json>, such as a DOI, a stage or a link to the published article), the state of the object or its notices. It MAY hold any document version, not only the current one, so that an earlier version can be described after later versions exist; tools otherwise hold the current version. If the object has <verbatim|history>, its entry for that document version becomes the new object version.

  <strong|Completion.> A document version recorded without sources (section 9, <verbatim|sourcesMissing>) MAY be completed later, keeping its number: the completing object version adds the sources, and MAY add renditions produced from them (for instance a PDF typeset from the added sources, beside the one received), but changes or removes no file of the version; until the sources are complete it keeps <verbatim|sourcesMissing> and names no main source; the object version that completes them names the main source and removes <verbatim|sourcesMissing>, after which the version is fixed like any other.

  <strong|Other versions.> A version that was not public at the time, such as the manuscript submitted to a journal, deposited later, is a document version like any other. A version published by someone else, such as the journal's version of record, is not a document version of the author's object: it is linked by a relation (section 8.1). Conversely, a branch holds versions of its parent's owner only at its branch points (section 10.5).

  <strong|History.> The order of the document versions in the history of the work is the order of their numbers, unless <verbatim|object.json> has <verbatim|history> (section 9): the list, in the order of the work, of the last object version holding each document version. The last object version is used because it carries the most complete description of that document version (a DOI added later, a corrected stage). An object version that deposits a document version out of order (an earlier version found later) MUST write <verbatim|history>, and once an object version has <verbatim|history>, every later object version MUST have it. A version whose place in the history is unknown goes just before the current version, and its <verbatim|object.json> SHOULD say so in its change note. The history is read from the head version; earlier object versions keep the history as it was known when they were made.

  <strong|Current version.> The current version of a document is the last entry of the history of its head version (without <verbatim|history>: the highest document version). The head may hold another document version, after an earlier version is deposited out of order or described by a description-only version; the current version stays where it was. Landing pages, indexes and citations use the current version, not the head; selections vet revisions explicitly (section 10.2).

  <strong|Notices.> A notice about a document version (for instance that a theorem of version 2 is wrong as stated, and is corrected in version 3) is written after that version, which cannot change. Notices are added to <verbatim|notices> in <verbatim|object.json> (section 9) by description-only versions. A notice present in an object version is present, unchanged, in every later object version; a notice is corrected or withdrawn by a later notice that says so. Presentations showing a document version SHOULD show the current notices about it.

  Dates never order document versions and never decide the current version (section 8).

  <subsection*|7.4 Collections><label|74-collections>

  A collection version contains <verbatim|datacite.json>, <verbatim|object.json>, <verbatim|members.json> (section 10), which states whether the collection is a catalogue or a selection, and the identity files of section 7.1. Its <verbatim|object.json> declares <verbatim|kind> <verbatim|collection>; its document version counts the changes of the member list, and it has none of the fields specific to documents (<verbatim|mainSource>, <verbatim|sourceFormat>, <verbatim|sourcesMissing>, <verbatim|renditions>, <verbatim|toolchain>, <verbatim|changes>, <verbatim|stage>, <verbatim|history>, <verbatim|notices>).

  <section*|8. Description: datacite.json><label|8-description-datacitejson>

  Every object version MUST contain <verbatim|datacite.json>, a JSON object with the DataCite 4.7 properties in the form of the <verbatim|attributes> of a DOI in the DataCite REST API. It is the authoritative description of the object version. It MUST contain:

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

  <verbatim|publisher> is the archive's name, or the external service registering a DOI for the version (appendix A). <verbatim|publisher> and <verbatim|affiliation> SHOULD be written as objects (with <verbatim|name> and, where available, an identifier); readers MUST also accept plain strings.

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

    <item><verbatim|kind>: <verbatim|document> or <verbatim|collection>;

    <item><verbatim|archiveId> and <verbatim|objectId>;

    <item><verbatim|documentVersion>: a positive integer, equal to the <verbatim|version> of <verbatim|datacite.json>;

    <item><verbatim|status>: <verbatim|active> or <verbatim|withdrawn> (section 11).
  </itemize>

  From the first version of its line (section 6.5: the version that seals it, or for a branch the first version after the branch point), an object MUST also contain <verbatim|name>, <verbatim|owner> and <verbatim|sealed> (the originator's sealing version, with <verbatim|archiveId>, <verbatim|objectId> and <verbatim|objectVersion>, section 6.5), and a branch <verbatim|parent> (section 10.5). The versions of a deep branch up to its branch point are the parent's, and their <verbatim|object.json> files name the parent's archive and owner.

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
    <item>A <strong|catalogue> keeps objects whole and is impartial about their versions. Each member pins an object, with all its versions, and the collection may follow it as it grows, whoever adds the versions: the owner of the object decides what its versions are. An archive's main collection (its own documents) and the list of objects an archive mirrors (section 10.4) are catalogues.

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

  It MAY contain <verbatim|order>, the rule by which tools maintaining the collection place members: <verbatim|manual> (the default: tools append new members and never reorder), <verbatim|issued-desc> or <verbatim|issued-asc> (by the members' <verbatim|Issued> date, then their <verbatim|Available> date, members with neither last, ties broken by object identifier, so that the result is reproducible).

  Each member MUST have:

  <\itemize>
    <item><verbatim|kind>: <verbatim|document> or <verbatim|collection>;

    <item><verbatim|archive>: the archive identifier of the member's archive;

    <item><verbatim|archiveUrl>: the base URL of that archive when the collection version was made;

    <item><verbatim|id>: the object identifier.
  </itemize>

  Each member MAY have <verbatim|mirrors> (base URLs of archives holding a mirror of the object, section 10.4), <verbatim|name> and <verbatim|owner> (its line, section 6.5, so that copies of it can be recognised, and found by name (section 6.6), after its archive disappears), <verbatim|doi> (the version DOI), <verbatim|conceptDoi> and <verbatim|cite>, a cached citation (<verbatim|title>, <verbatim|creators> as a list of names, <verbatim|year>, and <verbatim|issued>, the member's <verbatim|Issued> date) so that the collection stays readable, and can be ordered, without resolving its members, also if they become unavailable. <verbatim|cite> is not authoritative.

  <strong|Members of a catalogue> MUST have <verbatim|version>, the pinned object version, and <verbatim|inventorySha512>, the SHA-512 digest of that version's inventory file. Since the inventory of an object version lists every earlier version, the pin fixes the object with all its versions up to it. A member MAY have <verbatim|follow>, <verbatim|"latest">: a curation setting, not a floating reference. A followed member pins the head of the object when the collection version was made; a member without <verbatim|follow> keeps the version its curator pinned, which MAY be earlier than the head, until the curator changes it. A tool maintaining the collection reads the member archive's discovery document (or its feed); when the followed object has a new head, the tool writes a new collection version pinning it, whatever the new head holds (a new document version, a description, a notice, a withdrawal): a catalogue does not judge the versions of its members. A withdrawn member stays, and presentations show the withdrawal. Presentations show the current version of each member, read from the history of the pinned version (section 7.3).

  <strong|Members of a selection> MUST have <verbatim|revisions>: a non-empty list of the revisions vetted, in the order of the document's history, each with <verbatim|documentVersion>, <verbatim|version> (the object version vetted, which holds that document version: when several do, the last of them when the revision was vetted, which is its entry in the history, section 7.3) and <verbatim|inventorySha512> (the digest of its inventory file). They MUST NOT have <verbatim|version>, <verbatim|inventorySha512> or <verbatim|follow> themselves. The revision presented as the selection's is the last of the list. A revision pins the object version that was vetted: descriptions and notices added later by the document's archive are not vetted by the selection, and presentations that show them SHOULD say where they come from; a revision keeps its pin in later versions of the selection. If the document is withdrawn in its archive, the revisions stay vetted, and presentations show the withdrawal as section 11.1 asks, saying that it comes from the member's archive. Tools MUST NOT change revision sets on their own: adding a revision (for instance a corrected version, accepted after review), removing one, or adding or removing a member is a new version of the selection, made by its curator, recorded in the inventory (who and when) with a message saying what was decided. A revision set MAY hold several revisions of the same document, for instance a version accepted and its later correction.

  Every member is pinned: a collection version states exactly which object versions it contains, whole objects up to a version in a catalogue, revisions in a selection. A collection version therefore fixes everything it contains, also across archives; since a pin fixes an inventory, which fixes all its files, collections are hash trees. Pins cannot form cycles.

  <subsection*|10.3 Members of other archives><label|103-members-of-other-archives>

  A member may belong to another archive. Nothing is copied: the member is resolved as in section 6.4. A reference (a pin without a copy) needs no permission. Copies are of two kinds: mirrors (section 10.4), which are the same line, and branches (section 10.5), which are lines of other owners; accepted copies are shallow branches.

  <subsection*|10.4 Mirrors><label|104-mirrors>

  An archive MAY mirror an object of another archive: copy the whole object, every version with its inventories and files, byte for byte, into its own storage root, under the same identifier (only if no object of its own has it). A mirror is the same object, not a new one: it also copies the object's witnesses (section 13.2), and its <verbatim|object.json> files keep naming the original archive, and the discovery document lists it with <verbatim|mirrorOf>, the identifier of the original archive (section 6.1). A mirror is brought up to date only by copying the new versions of the original, which is possible because OCFL objects only grow; it MUST NOT be changed otherwise. Mirroring is allowed only if the licences of all the versions copied allow redistribution. A catalogue MAY list a mirror of a member in the member's <verbatim|mirrors>. An archive that mirrors another archive entirely SHOULD be listed in the <verbatim|mirrors> of that archive's discovery document, with the agreement of its owner.

  Mirrors serve preservation and access (an institution keeping copies of its members' archives, an independent storage site): they are impartial, like catalogues, and carry every version.

  <subsection*|10.5 Branches and accepted copies><label|105-branches-and-accepted-copies>

  A branch is a line of another owner continuing an object from one of its versions, the branch point: a co-author carrying the work on, a journal keeping the version it vetted and correcting it afterwards. Its genesis record is the object's, so it has the parent's name (section 6.5), or, after a clash, another name of the same genesis record; it copies <verbatim|sealed> from its parent. From its first version after the branch point, its <verbatim|object.json> records its own <verbatim|owner> and <verbatim|parent>: the <verbatim|owner>, <verbatim|name>, <verbatim|archiveId>, <verbatim|objectId>, <verbatim|objectVersion> (the branch point), <verbatim|documentVersion> and <verbatim|inventorySha512> of the parent version, and SHOULD record the <verbatim|url> of that object version, an absolute URL (<verbatim|\<less\>storage root URL\<gtr\>\<less\>object id\<gtr\>/\<less\>version\<gtr\>/>), so that it can be resolved (section 6.4). Its <verbatim|datacite.json> describes it with the branch owner (for a selection, its archive) as <verbatim|publisher> and keeps the relations of the parent version; the first version of a shallow branch, and every version that moves its branch point, SHOULD link the parent version with <verbatim|IsIdenticalTo>: its DOI if it has one, otherwise a <verbatim|URL> (the <verbatim|url> of <verbatim|parent>). A branch is deep or shallow.

  <\itemize>
    <item>A <strong|deep branch> holds the parent's object versions up to the branch point, byte for byte, under the parent's object identifier (only if no object of its own archive has it), and continues them with versions of its own owner. Its common past with the parent is checked by the records of those versions in its inventories, which equal the parent's. It copies every earlier version, so it is allowed only if their licences allow redistribution, or with the agreement of their owners, recorded as <verbatim|agreement> in the <verbatim|object.json> of its first own version (section 9).

    <item>A <strong|shallow branch> holds only the branch point. Its first object version holds exactly the files of the parent version (every file except <verbatim|datacite.json>, <verbatim|object.json>, <verbatim|parent.inventory.json> and <verbatim|parent.object.json>, the genesis record included), byte for byte; <verbatim|parent.inventory.json>, a copy of the inventory of the parent version; and <verbatim|parent.object.json>, a copy of its <verbatim|object.json>. Its later versions are its owner's own, and keep <verbatim|genesis.json>, <verbatim|parent.inventory.json> and <verbatim|parent.object.json> unchanged. A shallow branch of a shallow branch names its grandparent through <verbatim|parent.object.json>. It needs the right to redistribute only the parent version. This is the evidence #22 proposes for accepted copies.
  </itemize>

  <strong|The evidence of a shallow branch.> Its first version shows, without access to the parent, that it is consistent:

  <\itemize>
    <item>the name: a name of <verbatim|genesis.json>, by the algorithm of its last character;

    <item>the parent pin: the digest of <verbatim|parent.inventory.json> equals <verbatim|inventorySha512> of <verbatim|parent>, its <verbatim|id> is the parent's <verbatim|objectId> and its <verbatim|head> the parent's <verbatim|objectVersion>;

    <item>the files: every file of the head state of that inventory, except <verbatim|datacite.json>, <verbatim|object.json>, <verbatim|parent.inventory.json> and <verbatim|parent.object.json>, is present at the same logical path with the same digest, no other file is present besides <verbatim|datacite.json>, <verbatim|object.json>, <verbatim|parent.inventory.json> and <verbatim|parent.object.json>, and <verbatim|parent.object.json> has the digest of <verbatim|object.json> in that state;

    <item>the parent: the fields of <verbatim|parent> equal the <verbatim|owner>, <verbatim|name>, <verbatim|archiveId>, <verbatim|objectId> and <verbatim|documentVersion> of <verbatim|parent.object.json>; <verbatim|parent.name> is a name of this genesis record, by the algorithm of its last character, and is the branch's own <verbatim|name> unless the branch was renamed after a clash (section 6.5), <verbatim|sealed> equals that of <verbatim|parent.object.json>, the branch's <verbatim|owner> differs from the parent's, and the parent's owner is the <verbatim|originator> of the genesis record, or <verbatim|parent.object.json> declares a <verbatim|parent> of its own (the parent is itself a branch);

    <item>the genesis record: <verbatim|genesis.json> is in the head state of that inventory with the same digest.
  </itemize>

  Consistency is all that these prove: anyone can make a parent inventory that agrees with itself. They do not prove that the parent version is the one its archive keeps. For that a verifier resolves the parent (section 6.4), which confirms the archive that keeps the parent's line, not the person or body its owner names (section 6.6); or, when the parent's owner is keyed, checks its signature of the parent version, which the branch SHOULD keep among its witnesses (section 13.2); or relies on other witnesses (timestamps, external records).

  <strong|Moving the branch point.> A branch MAY take a later version of its parent's line as a new branch point: a journal that vets the authors' corrected version. The new parent has the same <verbatim|owner>, <verbatim|name>, <verbatim|archiveId> and <verbatim|objectId> as the previous one, a higher object version, and a document version later than the previous branch point's in the history of the new parent version (its <verbatim|parent.object.json>, section 7.3; without <verbatim|history>, a higher number), not merely a higher number (a parent version that only changes the description, such as a DOI added, is not a new branch point); a branch point never moves back, and is never dropped. The object version that moves it is the one whose <verbatim|parent> differs from the previous version's; it holds exactly the files of the new parent version, as the first version of a shallow branch does, with new copies of <verbatim|parent.inventory.json> and <verbatim|parent.object.json>, and is checked like that first version (this drops the branch's own files, such as the files of its notices, which section 7.3 keeps in every later version: how a move keeps them is open, section 6.5), and also for continuity: the new parent inventory continues the previous one when both have the same <verbatim|id>, every entry of <verbatim|versions> in the previous one is equal, as a JSON value, to the entry of the same version in the new one, and every digest of those entries is in the manifest of the new one. This shows, from the branch alone, that the corrected version continues the version first vetted. A deep branch moves its branch point in the same way; the checks of a deep branch apply to its first branch point only, and for its first move the previous parent inventory is that of its first branch point, <verbatim|vk/inventory.json>. The branch stays one sequence of versions under one owner, numbered as section 7.3 says.

  <strong|Accepted copies.> An accepted copy is a shallow branch kept by a selection from a revision it vetted. Its owner is a URI, named or keyed, for the selection or the body behind it (a journal, a review journal), and MUST differ between selections that keep copies of the same document, also in one archive, and MUST NOT be the originator (section 6.5): two selections are two owners, hence two lines. Its later document versions are acts of the selection's curator (a corrected version accepted, a notice, a withdrawal); the authors' later versions change nothing in it. The selection lists the accepted copy as its member, a member of its own archive; it MAY list the original revision set as well. A branch is not a mirror: it is another line, with its own inventories, and its own versions cannot stand for the parent in the resolution of a pin (section 6.4; a deep branch's copied versions, byte for byte the parent's, are copies like any other), so it is never listed in <verbatim|mirrors>.

  A version that the selection makes itself, such as a journal's typeset version of record, is a later version of the selection's branch, with the selection as <verbatim|publisher>, the authors' agreement in <verbatim|object.json> (section 9), and relations to the authors' versions (sections 7.3 and 8.1). A branch carries versions of the same work: typesetting, copy-editing, corrections, notices. A derived work (a translation, an abridgement, a commentary or review, a collected edition) is a new object, with its own genesis record and a relation to its source (section 8.1).

  <strong|Open question: numbering on branches.> The branch point keeps its document version (version 3 stays version 3). Later versions of the branch either (a) continue the numbering within the branch (the journal's version 4, distinct from the authors' version 4, the owner telling them apart), or (b) are numbered from the branch point (3.1, 3.2), which reads more clearly but makes <verbatim|documentVersion> more than an integer.

  <subsection*|10.6 Rights><label|106-rights>

  The member list of a collection is placed under CC0. The licence of a collection never extends to its members. Mirrors and branches keep the licences of what they copy.

  <section*|11. Withdrawal and takedown><label|11-withdrawal-and-takedown>

  <subsection*|11.1 Withdrawal><label|111-withdrawal>

  A document or collection is withdrawn (for instance retracted by its authors) by a description-only version whose <verbatim|object.json> has <verbatim|status> <verbatim|withdrawn> and a <verbatim|withdrawal> object with a <verbatim|date> and a <verbatim|reason> (a note, section 9), and whose <verbatim|datacite.json> has the same date as <verbatim|Withdrawn>. The status belongs to the object, whatever document version its head holds. Its content is kept, its history remains verifiable, and the discovery document lists it with <verbatim|status> <verbatim|withdrawn>. Presentations MUST show the withdrawal notice with the document.

  <subsection*|11.2 Takedown><label|112-takedown>

  When content must be removed (by law, or for a breach of rights), the object is deleted from the storage root and a tombstone MUST be added to the discovery document.

  <subsection*|11.3 Tombstones><label|113-tombstones>

  A tombstone records <verbatim|id>, <verbatim|kind>, <verbatim|lastVersion>, <verbatim|inventorySha512> of that version, <verbatim|date> and <verbatim|reason> (plain text, since the discovery document has no content files), and, for an object with a genesis record, its <verbatim|name>, <verbatim|ownerId> (section 6.6) and <verbatim|sealed>, which it MUST record, so that its line stays taken and its genesis record cannot be reused for another work (section 6.5); it MAY also record <verbatim|owner>, unless the takedown erases it (section 16). Identifiers of tombstoned objects MUST NOT be reused. Verifiers report a pin to a tombstoned object as "removed", not as a corruption. External copies (DOI records, snapshots) follow the rules of their services.

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

  Digests show that files were not changed; they do not show who made them or when. An archive MAY provide, for each object version:

  <\itemize>
    <item><verbatim|\<less\>version\<gtr\>.inventory.json.sha512.sig>: a detached signature of the inventory checksum file of that version (<verbatim|\<less\>version\<gtr\>/inventory.json.sha512>), made with a key listed in <verbatim|keys> of the discovery document (each key with a <verbatim|type>, such as <verbatim|openpgp> or <verbatim|ssh>, and a <verbatim|url> or <verbatim|fingerprint>), or, for a line whose owner is keyed, with the owner's key (below);

    <item><verbatim|\<less\>version\<gtr\>.inventory.json.sha512.ots>: an OpenTimestamps proof of the same file.
  </itemize>

  These witness files SHOULD be kept in the object's extension folder <verbatim|extensions/opensheaf-witnesses/>, so that they travel with the object when it is copied or mirrored. OCFL allows object extension folders, which are not part of any version; the extension name <verbatim|opensheaf-witnesses> is not yet registered with OCFL, so validators may warn about it. An archive that does not modify object folders after a version is committed MAY instead keep them under <verbatim|witnesses/\<less\>object id\<gtr\>/>, next to the discovery document. Witnesses can be added later, by the owner of the line or by others, and replaced when a proof is upgraded (an OpenTimestamps proof is completed once its attestation is confirmed); they are not covered by the inventory digests, and need not be, since each one is checked directly against the checksum file it names, which the pins fix.

  The versions of a line whose owner is keyed (section 6.5) MUST carry this signature, made with the owner's key, and its witnesses MUST be kept in the object's extension folder, so that they travel with the object:

  <\itemize>
    <item>for a <verbatim|did:key> owner, the key MUST be an Ed25519 key, and the signature file holds the 64 bytes of the Ed25519 signature (RFC 8032) of the bytes of the checksum file;

    <item>for an <verbatim|openpgp4fpr:> owner, the signature file is an OpenPGP detached signature (RFC 9580) of the same bytes, and the public key MUST be kept in the extension folder as <verbatim|keys/\<less\>fingerprint\<gtr\>.asc>, the fingerprint in lowercase hexadecimal.
  </itemize>

  Witness files are named as follows, all in the extension folder (or, except for keyed lines, under <verbatim|witnesses/\<less\>object id\<gtr\>/>):

  <\itemize>
    <item><verbatim|\<less\>version\<gtr\>.inventory.json.sha512.sig> is the signature by the owner of the line to which that object version belongs; in a deep branch, the versions up to the branch point belong to the parent's line, and the branch copies their witnesses with them;

    <item><verbatim|keys/\<less\>fingerprint\<gtr\>.asc> is the OpenPGP public key of an <verbatim|openpgp4fpr:> owner;

    <item>a signature by someone else (a third party vouching for a version) is <verbatim|\<less\>version\<gtr\>.inventory.json.sha512.\<less\>label\<gtr\>.sig>, where <verbatim|\<less\>label\<gtr\>> is chosen by whoever adds it and matches <verbatim|^[a-z0-9]+(-[a-z0-9]+)*$>, with <verbatim|\<less\>version\<gtr\>.inventory.json.sha512.\<less\>label\<gtr\>.json>, a JSON object with <verbatim|signer> (a URI) and, unless <verbatim|signer> is a <verbatim|did:key>, <verbatim|key> (an OpenPGP public key, ASCII-armoured); the signature has the form of an owner's: Ed25519 for a <verbatim|did:key> signer, OpenPGP otherwise;

    <item>a branch keeps the witnesses of each of its branch points in the folder <verbatim|parent/\<less\>w\<gtr\>/> (except the first branch point of a deep branch, whose witnesses it copies with the parent's versions, as above), where <verbatim|\<less\>w\<gtr\>> is its own object version that took that branch point (the first version after it, or the version that moved it): the parent's checksum file <verbatim|\<less\>v\<gtr\>.inventory.json.sha512> (where <verbatim|\<less\>v\<gtr\>> is <verbatim|objectVersion> of that <verbatim|parent>), checked against <verbatim|parent.inventory.json> of <verbatim|\<less\>w\<gtr\>>; when the parent's owner is keyed, its signature <verbatim|\<less\>v\<gtr\>.inventory.json.sha512.sig> and, for an OpenPGP key, <verbatim|keys/\<less\>fingerprint\<gtr\>.asc>; and any other witness of the parent version, named as above (<verbatim|\<less\>v\<gtr\>.inventory.json.sha512.ots>, <verbatim|\<less\>v\<gtr\>.inventory.json.sha512.\<less\>label\<gtr\>.sig> with its <verbatim|.json>).
  </itemize>

  An OpenPGP signature MAY be made by a signing subkey bound to the key of the fingerprint in the key file kept.

  External deposits (appendix A) and software archive snapshots are further witnesses. Archives kept in git MAY also sign their commits or tags, but git hashes are not part of the integrity chain of this specification.

  <section*|14. Verification><label|14-verification>

  A verifier checking an archive MUST:

  <\itemize>
    <item>validate the discovery document, and every <verbatim|object.json>, <verbatim|members.json> and <verbatim|genesis.json>, against the schemas of their declared versions (and the index files of section 6.6, if present), checking formats (dates, URIs) as assertions, which JSON Schema 2020-12 leaves optional;

    <item>validate the storage root and every object against OCFL 1.1 (with a standard OCFL validator or equivalent checks);

    <item>check that the discovery document lists the objects of the storage root with their kinds, head versions, inventory digests and status as their head versions state them, and that no listed object has the identifier of a tombstone; a verifier reading the archive over HTTP cannot list folders, so it checks the listed objects and reports that completeness was not checked, while a verifier with access to the files also checks that no object is missing;

    <item>check the requirements of sections 7 to 11 on every object version, including that <verbatim|datacite.json> and <verbatim|object.json> agree on the document version and on the date of a withdrawal, and that <verbatim|Available>, for a version first made public by the archive, is the date of its deposit (section 7.1);

    <item>check the document versions of each document (section 7.3): object versions with the same document version have the same sources, renditions and change note, except that a version with <verbatim|sourcesMissing> may be completed by adding files (section 7.3); new numbers follow the rule of new versions, without gaps (for a branch, from the document version of its first branch point; for a deep branch, its first own version that adds files of the document's own taking the number after the highest document version in the object, last in <verbatim|history>; a version that moves the branch point taking the next number); <verbatim|history>, when present, lists distinct document versions, covers all of them, each entry being the last object version holding its document version; no object version after the first one with <verbatim|history> lacks it; every notice is kept unchanged in every later object version;

    <item>check that each <verbatim|members.json> has a <verbatim|type>, that the members of a catalogue have <verbatim|version> and <verbatim|inventorySha512>, and that the members of a selection have <verbatim|revisions> and none of <verbatim|version>, <verbatim|inventorySha512> or <verbatim|follow>, with distinct document versions;

    <item>for the head of each collection, resolve each member (each revision, in a selection) as in section 6.4 and check its pin, and for earlier collection versions check the pins of members of the archive itself (resolving the members of other archives for every earlier collection version is OPTIONAL); for a revision, check that the pinned object version holds the stated document version; for a member with <verbatim|name> and <verbatim|owner>, check them against the <verbatim|object.json> of the pinned version; check that no pin names an object version without a genesis record (section 6.5); report each as verified, mismatch (a copy was found and does not match), unavailable (no copy found) or removed (tombstoned);

    <item>for each mirror (<verbatim|mirrorOf>), check that the <verbatim|object.json> files of the versions of the mirrored line name that archive (for a mirror of a deep branch, the versions after its branch point; those before name the parent's archive);

    <item>for each object with a genesis record (section 6.5): that <verbatim|genesis.json> is the same in every object version from the first that holds it, that <verbatim|name> is its digest by the algorithm named in its last character, that its <verbatim|kind> is the <verbatim|kind> of <verbatim|object.json>, that <verbatim|owner>, <verbatim|name>, <verbatim|sealed>, <verbatim|archiveId> and <verbatim|objectId> do not change from the first version of the line, that no two objects of the archive (mirrors included), nor an object and a tombstone, have the same <verbatim|name> and owner (owner identifier, for a tombstone) at their heads, that objects with the same genesis record have the same <verbatim|sealed>, and that an object one of whose names is a tombstone's name has the tombstone's <verbatim|sealed>, that a line without <verbatim|parent> is named by algorithm 0 and its <verbatim|sealed> names its own sealing version, that no two owners at the heads of the archive have the same owner identifier, that owners are written in the forms of section 6.5, that the discovery document lists the head's <verbatim|name> and <verbatim|owner>, that a line whose owner is not the originator declares a parent and that the originator's line declares none, and, for a keyed owner, the signature of every object version of the line;

    <item>for each branch (section 10.5): for a deep branch, with first branch point <verbatim|vk>, that its own versions hold no <verbatim|parent.inventory.json> or <verbatim|parent.object.json> until one moves its branch point, that <verbatim|objectVersion> of its first <verbatim|parent> is <verbatim|vk>, that the inventory of <verbatim|vk> has the digest <verbatim|inventorySha512> of <verbatim|parent>, that <verbatim|owner>, <verbatim|name>, <verbatim|archiveId>, <verbatim|objectId> and <verbatim|documentVersion> of <verbatim|parent> equal those of the <verbatim|object.json> of <verbatim|vk>, that <verbatim|vk> holds the genesis record, and that this <verbatim|parent> first appears in <verbatim|v(k+1)>; for a shallow branch, the evidence of its first version, and that its later versions keep the identity files unchanged until a version that moves the branch point; for every branch, that its <verbatim|owner> differs from the <verbatim|owner> of <verbatim|parent>, that <verbatim|parent.name> is a name of its genesis record and its own <verbatim|name> unless it was renamed after a clash, that a renamed branch has an algorithm number greater than that of <verbatim|parent.name> (a failure otherwise), and that its owner is not the originator; reporting as a warning, not a failure, a rename that neither the objects nor the tombstones of the archive justify, or a number that is not the smallest free one, since the line that caused it may be kept elsewhere; that <verbatim|sealed> equals the parent's, and that the parent's owner is the <verbatim|originator> of the genesis record or the parent version's <verbatim|object.json> (<verbatim|parent.object.json>, or, for the first branch point <verbatim|vk> of a deep branch, <verbatim|vk/object.json>) declares a <verbatim|parent> of its own, and declares none when the parent's owner is the originator; for every version that moves the branch point, the same evidence, that the new parent has the same <verbatim|owner>, <verbatim|name>, <verbatim|archiveId> and <verbatim|objectId> as the previous one and a higher object version holding a document version later than the previous branch point's in the history of the new parent version, and the continuity of the two parent inventories (section 10.5); for each branch point, report the first of these verdicts that applies: inconsistent (a check fails, or the parent was resolved and does not match), confirmed (the parent was resolved, through a location known independently of the branch (section 6.4), and matches; or, for a keyed parent owner, its signature of the branch point holds), attested (one of these witnesses of the parent version holds: an OpenTimestamps proof of its checksum file, kept in <verbatim|parent/\<less\>w\<gtr\>/> (or, for the first branch point of a deep branch, with the copied versions), which proves only that the parent version existed by the date of the proof, reported with that date; a third party's signature with its sidecar, when the verifier's user trusts the signer (a signature by any other key is reported, and leaves the verdict unconfirmed, since the branch's owner can make keys of its own); an external record, such as a DOI deposit, whose files match the parent version, when the verifier's user trusts its depositor or the verifier reached it independently of the branch (others are reported, and leave the verdict unconfirmed); the signature of the branch's own owner does not count), unconfirmed (consistent, with nothing outside the branch); report as the branch's verdict the weakest of those of its branch points (inconsistent, unconfirmed, attested, confirmed, from the weakest); and report separately whether the parent was found, unavailable or removed (tombstoned), and whether it is withdrawn;

    <item>where several copies of a line are known (mirrors, members, branches' parents), that they agree (section 6.5); two that do not are a fork of the line, reported with the owner's signatures when it is keyed, and with whether each copy is confirmed and by which archive (section 6.6).
  </itemize>

  A verifier SHOULD check the witnesses it finds, the indexes the archive declares (section 6.6: every entry agrees with the objects and starts with its file's prefix, every object with a genesis record and every sealed version is listed, and tombstoned objects are listed as <verbatim|removed>), the requirements of the profiles the archive declares, and those of the extensions it knows; it SHOULD report the extensions it does not know, which do not make an archive fail verification. It MUST NOT treat the presentation as authoritative. It SHOULD limit the depth and size of the collections it follows, and report when it stops.

  <section*|15. Security considerations><label|15-security-considerations>

  <\itemize>
    <item><strong|Untrusted inventories.> Inventories, logical paths and member lists from other archives are untrusted input. Verifiers MUST reject logical paths that break the rules of section 7.1 (absolute, with <verbatim|.> or <verbatim|..> segments, not in Unicode normalisation form C), and SHOULD limit the size of the files they fetch.

    <item><strong|Archives of sources.> Tools unpacking source archives (appendix A) MUST guard against paths leaving the target folder and against archives that expand to excessive sizes.

    <item><strong|Presentation.> A website MUST NOT embed HTML of other archives in its own pages; it links to them. Documents' HTML versions are generated by the archive's own tools.

    <item><strong|Subdomains.> A domain that offers subdomains to archives (as <verbatim|opensheaf.org> does) MUST remove the DNS records of abandoned archives, to prevent takeover by others.

    <item><strong|Weak hashes.> SHA-1 (as in most git repositories) and MD5 are not used for integrity: MD5 appears only for comparison with external services.

    <item><strong|Branches and owners (proposal).> The evidence a shallow branch carries can be forged consistently: only a resolved parent, a keyed parent owner's signature or other witnesses show that the parent existed. <verbatim|parent.inventory.json> and <verbatim|parent.object.json> are untrusted input, checked like inventories from other archives. A named owner is only asserted: anyone can write a line under someone's ORCID iD, and only the archive serving it, or keys, distinguish the two. A compromised key lets its holder write forks of a keyed line; rotation and revocation are open (section 6.5, #13).

    <item><strong|First deposit wins (proposal).> An archive refuses a mirror whose line is taken, an object sealed outside it whose line is taken when it is deposited, an object whose genesis record it holds with another <verbatim|sealed>, and an owner whose identifier is another owner's (section 6.5), so a forged copy deposited first gets the genuine one refused. A branch whose line is taken is renamed instead: for any object or tombstone in its archive, confirmed or not, and for the owner's confirmed lines elsewhere, never for index entries alone, so forged index entries cannot force renames. A branch point is moved onto an existing branch only under the conditions of section 6.5 (the owner's own branch of the same parent line, a later branch point, in the archive that keeps it), so that a forged branch is never continued as the owner's line; for a named owner, an archive that accepts deposits from more than one depositor binds each named owner URI of the lines it keeps to the depositors it has checked can use it (section 6.5), so that no depositor continues another's genuine line or opens one under another's URI. Archives that accept objects of others (custodians, repositories with many depositors) SHOULD check that a copy is confirmed (section 6.6) before depositing it, and resolve a refusal by checking which copy is (#39).

    <item><strong|Short forms (proposal).> Anyone can publish a line under a named owner's URI whose name starts with a given short form, dated as they like; resolvers therefore order only confirmed lines, reached through the archive that keeps them or signed by the owner's key, and show unconfirmed ones as warnings (section 6.6). Another owner can make a short form ambiguous, but not take it over; files record only complete names, and printed short forms are long enough (16 characters) not to be searched for.

    <item><strong|Resolving without a digest (proposal).> A named owner's line can be forked by anyone, so a copy found through an <verbatim|at> hint, an index kept by others or a gateway is only a copy: resolvers and gateways report it as unconfirmed unless it was reached through the archive that keeps the line or is signed by a keyed owner (section 6.6). With no confirmed copy, the latest head among agreeing unconfirmed copies is used, so a party that copies a line and adds versions (a false notice or withdrawal) is shown, marked unconfirmed, until a confirmed copy is found. A gateway that fetches URLs given in links guards against requests to private addresses and against large responses, does not serve archives' files from its own origin, and redirects only, and only temporarily, to confirmed archives, so that a link through it cannot send readers to a location of an attacker's choice.

    <item><strong|Mutable maps.> The discovery document, the indexes and presentation files can be changed by whoever controls the server; their statements are only trusted after checking them against the storage root and the pins.
  </itemize>

  <section*|16. Privacy and rights><label|16-privacy-and-rights>

  <\itemize>
    <item><strong|Documents.> Each document carries the licence chosen by its authors in <verbatim|rightsList>. "All rights reserved" is allowed: deposit grants readers access, not reuse.

    <item><strong|Metadata.> <verbatim|datacite.json>, <verbatim|object.json>, <verbatim|members.json>, inventories and the discovery document (and, with the proposal of section 6.5, <verbatim|genesis.json>, <verbatim|parent.inventory.json>, <verbatim|parent.object.json> and the index files) are placed under CC0, so that they can be harvested and mirrored freely.

    <item><strong|Personal data.> Archives record only the personal data needed to describe and cite the work (names, identifiers, affiliations) and the depositor of each version. The depositor is recorded in the inventory (section 7.1). Agreement records are minimal (section 9). A request to erase personal data from an immutable history is handled by a takedown (section 11.2); with the proposal of section 6.5, the tombstone and the indexes then keep only the name, the owner identifier and <verbatim|sealed>, not the owner's URI. An owner identifier is a digest of a URI that can often be guessed (an ORCID iD), so it is a pseudonym, not an erasure.

    <item><strong|Owners (proposal).> The <verbatim|originator> of a genesis record, and the <verbatim|owner> and <verbatim|parent> of every version, are copied into every mirror and branch and can never be removed from them. An owner who must stay anonymous, such as the referee of a report (#29), SHOULD be named by a URI that does not identify them, for instance a <verbatim|did:key> made for that purpose; the <verbatim|user> of the inventory and <verbatim|by> of an <verbatim|agreement> MUST then not identify them either, since they are copied too.
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

    <item><hlink|opensheaf-index-0.1.schema.json|https://opensheaf.org/schemas/opensheaf-index-0.1.schema.json> for the index files (proposal, section 6.6).
  </itemize>

  DataCite publishes its schema as an XML Schema only. <verbatim|datacite.json> is validated by converting it to DataCite XML (following DataCite's mapping between the REST API's JSON and XML) and validating the result against the DataCite 4.7 XML Schema, together with the requirements of section 8.

  <section*|Appendix E. Examples (non-normative)><label|appendix-e-examples-non-normative>

  The values below come from the first archive, except the names and owners added by the proposal of section 6.5, which are placeholders. Digests are shortened, and the DOIs and ORCID iDs are placeholders (with valid check digits).

  A discovery document:

  <\html-div-class|language-json>
  <\verbatim-code>
    {

    \ \ "format": "opensheaf-archive/0.1",

    \ \ "specification": "0.1",

    \ \ "archiveId": "tag:opensheaf.org,2026:mgubi",

    \ \ "name": "Papers of Massimiliano Gubinelli",

    \ \ "contact": "https://orcid.org/0000-0000-0000-0001",

    \ \ "storageRoot": "ocfl/",

    \ \ "storageLayout": "0002-flat-direct-storage-layout",

    \ \ "mainCollection": "collection-papers",

    \ \ "profiles": ["zenodo", "texmacs", "website"],

    \ \ "objects": [

    \ \ \ \ { "id": "fractional-phi42-mass-gap", "kind": "document", "head": "v1",

    \ \ \ \ \ \ "inventorySha512": "9a0c...", "status": "active",

    \ \ \ \ \ \ "name": "jkh5ucuizmlf7syxkcmuapddpay35v7my27yyb2tkksao22mr4ja", "owner": "tag:opensheaf.org,2026:mgubi" },

    \ \ \ \ { "id": "collection-papers", "kind": "collection", "head": "v1",

    \ \ \ \ \ \ "inventorySha512": "51be...", "status": "active",

    \ \ \ \ \ \ "name": "ubbut3szmkugays3x25opjxhare2ts3nw6bp6oa7cbbcevsckg7a", "owner": "tag:opensheaf.org,2026:mgubi" }

    \ \ ]

    }
  </verbatim-code>
  </html-div-class>

  An <verbatim|object.json> of a document version (its content also holds <verbatim|genesis.json>, section 6.5):

  <\html-div-class|language-json>
  <\verbatim-code>
    {

    \ \ "format": "opensheaf-object/0.1",

    \ \ "specification": "0.1",

    \ \ "kind": "document",

    \ \ "archiveId": "tag:opensheaf.org,2026:mgubi",

    \ \ "objectId": "fractional-phi42-mass-gap",

    \ \ "name": "jkh5ucuizmlf7syxkcmuapddpay35v7my27yyb2tkksao22mr4ja",

    \ \ "owner": "tag:opensheaf.org,2026:mgubi",

    \ \ "sealed": { "archiveId": "tag:opensheaf.org,2026:mgubi", "objectId": "fractional-phi42-mass-gap", "objectVersion": "v1" },

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

  The <verbatim|datacite.json> of the same version:

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

    \ \ \ \ \ \ "archive": "tag:opensheaf.org,2026:mgubi",

    \ \ \ \ \ \ "archiveUrl": "https://mgubi.org/papers/",

    \ \ \ \ \ \ "id": "fractional-phi42-mass-gap",

    \ \ \ \ \ \ "version": "v3",

    \ \ \ \ \ \ "inventorySha512": "9a0c...",

    \ \ \ \ \ \ "follow": "latest",

    \ \ \ \ \ \ "cite": { "title": "Mass gap for the fractional $\\\\Phi^4_2$ model",

    \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ "creators": ["P. Duch", "M. Gubinelli"], "year": 2026, "issued": "2026-11-12" } }

    \ \ ]

    }
  </verbatim-code>
  </html-div-class>

  A <verbatim|members.json> of a selection: an issue of a journal, with a paper vetted in its version 2 and, after a correction accepted by the editors, its version 3; and a member that is itself a collection, vetted in one version:

  <\html-div-class|language-json>
  <\verbatim-code>
    {

    \ \ "format": "opensheaf-collection/0.1",

    \ \ "type": "selection",

    \ \ "members": [

    \ \ \ \ { "kind": "document",

    \ \ \ \ \ \ "archive": "tag:example.org,2026:authors",

    \ \ \ \ \ \ "archiveUrl": "https://authors.example.org/",

    \ \ \ \ \ \ "id": "network-discrimination",

    \ \ \ \ \ \ "revisions": [

    \ \ \ \ \ \ \ \ { "documentVersion": 2, "version": "v2", "inventorySha512": "4f1e..." },

    \ \ \ \ \ \ \ \ { "documentVersion": 3, "version": "v4", "inventorySha512": "c07a..." } ],

    \ \ \ \ \ \ "cite": { "title": "Quantum network discrimination", "creators": ["C. Hirche"], "year": 2021 } },

    \ \ \ \ { "kind": "collection",

    \ \ \ \ \ \ "archive": "tag:example.org,2026:seminar",

    \ \ \ \ \ \ "archiveUrl": "https://seminar.example.org/",

    \ \ \ \ \ \ "id": "collection-seminar-2026",

    \ \ \ \ \ \ "revisions": [ { "documentVersion": 3, "version": "v3", "inventorySha512": "7d21..." } ] }

    \ \ ]

    }
  </verbatim-code>
  </html-div-class>

  A genesis record (proposal, section 6.5), written when the authors' paper was sealed; its name is <verbatim|2kukpn74khhbxkdxxtbcbrtnuwhhssdbjezh5r4ggnyesxwn5pqq> (the SHA-256 of <verbatim|opensheaf-name-0>, a line feed and the bytes as shown, with a final line feed); a branch named by algorithm 1 after a clash (section 6.5) would be <verbatim|74xzytlubklklsrjlmnermj4iixalc7665dcot3vbjmuqqxv2tib>:

  <\html-div-class|language-json>
  <\verbatim-code>
    {

    \ \ "format": "opensheaf-genesis/0.1",

    \ \ "kind": "document",

    \ \ "created": "2026-03-02T09:14:00Z",

    \ \ "originator": "https://orcid.org/0000-0002-1234-5677",

    \ \ "nonce": "5f2c8e1a9b7d4036c2e1f08a7b6d5c43"

    }
  </verbatim-code>
  </html-div-class>

  The <verbatim|object.json> of the first version of the journal's accepted copy of that paper, a shallow branch from the authors' document version 3, the corrected version the editors accepted (proposal, section 10.5; with the selection above, the journal would rather start from version 2 and move its branch point to version 3). With the proposal, the selection lists this accepted copy as its member, a member of its own archive, and MAY keep the authors' revision set as well. Its content also holds <verbatim|genesis.json>, <verbatim|parent.inventory.json> and <verbatim|parent.object.json>; since its owner is keyed, its extension folder holds the signature <verbatim|v1.inventory.json.sha512.sig>, made with that key (section 13.2):

  <\html-div-class|language-json>
  <\verbatim-code>
    {

    \ \ "format": "opensheaf-object/0.1",

    \ \ "specification": "0.1",

    \ \ "kind": "document",

    \ \ "archiveId": "tag:example.org,2026:journal",

    \ \ "objectId": "network-discrimination",

    \ \ "name": "2kukpn74khhbxkdxxtbcbrtnuwhhssdbjezh5r4ggnyesxwn5pqq",

    \ \ "owner": "did:key:z6MkhaXgBZDvotDkL5257faiztiGiC2QtKLGpbnnEGta2doK",

    \ \ "sealed": { "archiveId": "tag:example.org,2026:authors", "objectId": "network-discrimination", "objectVersion": "v1" },

    \ \ "parent": {

    \ \ \ \ "owner": "https://orcid.org/0000-0002-1234-5677",

    \ \ \ \ "name": "2kukpn74khhbxkdxxtbcbrtnuwhhssdbjezh5r4ggnyesxwn5pqq",

    \ \ \ \ "archiveId": "tag:example.org,2026:authors",

    \ \ \ \ "objectId": "network-discrimination",

    \ \ \ \ "objectVersion": "v4",

    \ \ \ \ "documentVersion": 3,

    \ \ \ \ "inventorySha512": "c07a...",

    \ \ \ \ "url": "https://authors.example.org/ocfl/network-discrimination/v4/"

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

  URIs of this paper (proposal, section 6.6). The authors' ORCID iD is the originator, and the journal's owner identifier, the digest of its <verbatim|did:key> URI, is <verbatim|xx2gb5hzspt376vk22zvn2eyim6neidybevwgceje76333ifsxda>:

  <\verbatim-code>
    sheaf:2kukpn74khhbxkdxxtbcbrtnuwhhssdbjezh5r4ggnyesxwn5pqq/v3

    \ \ \ \ document version 3 of the authors' line

    sheaf:2kukpn74khhbxkdxxtbcbrtnuwhhssdbjezh5r4ggnyesxwn5pqq/v3?sha512=c07a...

    \ \ \ \ the authors' object version v4, which the journal vetted

    sheaf:2kukpn74khhbxkdxxtbcbrtnuwhhssdbjezh5r4ggnyesxwn5pqq:xx2gb5hzspt376vk22zvn2eyim6neidybevwgceje76333ifsxda/v3

    \ \ \ \ document version 3 of the journal's line, its accepted copy

    sheaf:2kukpn74/v3

    sheaf:2kukpn74:xx2gb5hz/v3

    \ \ \ \ the same two, in short form

    sheaf:2kukpn74khhbxkdxxtbcbrtnuwhhssdbjezh5r4ggnyesxwn5pqq:*

    \ \ \ \ the paper as a whole: the authors' line, the journal's and any other

    https://opensheaf.org/sheaf:2kukpn74/v3

    \ \ \ \ the short form of the first, through a gateway
  </verbatim-code>

  The entry of the journal's archive for this object, in its index <verbatim|names/2k.json> (its archive declares prefixes of 2 characters):

  <\html-div-class|language-json>
  <\verbatim-code>
    {

    \ \ "format": "opensheaf-index/0.1",

    \ \ "index": "names",

    \ \ "entries": [

    \ \ \ \ { "name": "2kukpn74khhbxkdxxtbcbrtnuwhhssdbjezh5r4ggnyesxwn5pqq",

    \ \ \ \ \ \ "originator": "https://orcid.org/0000-0002-1234-5677",

    \ \ \ \ \ \ "owner": "did:key:z6MkhaXgBZDvotDkL5257faiztiGiC2QtKLGpbnnEGta2doK",

    \ \ \ \ \ \ "ownerId": "xx2gb5hzspt376vk22zvn2eyim6neidybevwgceje76333ifsxda",

    \ \ \ \ \ \ "objectId": "network-discrimination", "status": "active",

    \ \ \ \ \ \ "sealed": { "archiveId": "tag:example.org,2026:authors", "objectId": "network-discrimination", "objectVersion": "v1" },

    \ \ \ \ \ \ "genesis": "{\\n \ \\"format\\": \\"opensheaf-genesis/0.1\\",\\n \ \\"kind\\": \\"document\\",\\n \ \\"created\\": \\"2026-03-02T09:14:00Z\\",\\n \ \\"originator\\": \\"https://orcid.org/0000-0002-1234-5677\\",\\n \ \\"nonce\\": \\"5f2c8e1a9b7d4036c2e1f08a7b6d5c43\\"\\n}\\n" }

    \ \ ]

    }
  </verbatim-code>
  </html-div-class>

  <section*|Appendix F. Rationale (non-normative)><label|appendix-f-rationale-non-normative>

  <\itemize>
    <item><strong|Why OCFL.> It is a published, versioned specification for exactly this problem (versioned objects as plain files with digests), with independent validators, used by research libraries. OpenSheaf adds only discovery and collections.

    <item><strong|Why the flat-direct layout.> Paths stay readable and resolvable by rule over plain HTTP; the cost is short identifiers without <verbatim|/>.

    <item><strong|Why a discovery document.> Static web servers cannot list folders; one small file makes an archive discoverable, and its statements are checked against the storage root.

    <item><strong|Why pins by inventory digest.> One digest fixes a whole object version, so collections become hash trees across archives, and any matching copy will do.

    <item><strong|Why catalogues and selections.> Keeping and vetting are different acts. An archive (an author's, an institution's, a storage site) keeps what its members deposit, every version, without judging them: following an object as it grows is its job. A selection (a journal, a digest, a review journal) vouches for particular revisions: a later version by the authors has not been vetted, so it cannot enter the selection by itself, and a change of what is vetted is an editorial act that the selection's own history records. Pinning whole objects in one case and revision sets in the other makes the difference explicit and checkable.

    <item><strong|Why mirrors and accepted copies differ.> A mirror copies a whole object and stays the same object, owned by its original archive, so it can only grow by the original's versions. An accepted copy takes one vetted revision into the selection's own archive, where it continues under the selection's responsibility (corrections, notices, withdrawal); OCFL cannot hold part of an object, so a copy of one revision is another object: with the proposal of section 6.5, a shallow branch of the same name.

    <item><strong|Why the owner is part of the identity (proposal).> A name alone cannot say whose history is the right one: anyone may copy a genesis record. With (owner, name), copying is no forgery: a copy under another owner is a branch, declared as such, and each owner answers for one line only. Location stays out of the identity, so an object can be kept anywhere.

    <item><strong|Why deep and shallow branches (proposal).> A co-author continuing the work needs its whole past, and can check it by digests; a journal needs only the version it vetted, and may not be allowed to copy the others. A shallow branch carries the parent's inventory and <verbatim|object.json>, so that its consistency can be checked after the parent has gone; that the parent version is the one its archive keeps needs the parent, reached through that archive, its owner's signature or other witnesses; that the owner named is the person it claims needs owner proofs (#41).

    <item><strong|Why separate document and object versions.> Readers and DOI services see versions of the work; the storage keeps every change, including corrections of the description.

    <item><strong|Why the archive numbers document versions itself.> External numberings have gaps (versions an external service no longer serves) and do not cover versions that were never public there. The archive's own numbers have no gaps; external labels are recorded beside them.

    <item><strong|Why an explicit history, and why it lists object versions.> Dates may be approximate or unknown, so they cannot order versions, and pointers from each version to the previous one cannot be corrected when a version is inserted later, since earlier versions are fixed. A list kept in each object version, with the head's list authoritative, can be corrected by a new version and keeps a record of what was known before. Its entries name object versions, which are exact and resolved directly through the inventory, and name the last object version of each document version, which carries its most complete description. Digests could not be used: an object version cannot contain the digest of its own inventory.

    <item><strong|Why the deposit is read from the inventory.> OCFL already records when and by whom each object version was made; repeating it in <verbatim|object.json> would allow the two to disagree.

    <item><strong|Why notices are not new document versions.> A notice about a version is a later statement about it, not a change of the work. The exact state a reader saw, with or without a notice, is identified by the object version and its pin.

    <item><strong|Where witnesses live.> A witness of an object version can only be made after the version is committed, so it cannot be part of it (a signature of an inventory cannot be listed in that inventory). Putting each signature or timestamp in a new version would mix evidence with changes of the work, and every upgrade of a timestamp proof would be a version. OCFL closes the object folder to anything it does not define, and its <verbatim|logs/> folder is meant for unstructured records of actions and is not covered by digests. Object extension folders are the place OCFL provides for data that is not part of any version (the registered mutable-head extension keeps its data there), so witnesses go in <verbatim|extensions/opensheaf-witnesses/> and travel with the object; <verbatim|witnesses/> outside the storage root remains for archives that never touch object folders after commit.

    <item><strong|Why no HTML in deposits.> Presentations improve; deposits must not change.

    <item><strong|Why a minimal core, and extensions.> The core defines only what every archive and collection needs to be kept, cited, composed and verified. Richer structures among documents (a short account of a proof and its detailed argument, a talk and its paper, a dataset and the analyses built on it, a knowledge base linking results across papers) are built on top of it: by links inside the documents and DataCite relations, which need nothing more, or by extensions that record them with pins, so that tools follow them when they copy, verify or present documents. Keeping them out of the core leaves room for designs not yet imagined, while the pins, which fix extension data with the rest of each version, keep whatever is built checkable.

    <item><strong|Why DataCite.> It is the metadata of DOIs for repositories, with relations for versions, preprints and collections, and it maps directly to Zenodo.
  </itemize>

  <section*|Appendix G. References><label|appendix-g-references>

  <\itemize>
    <item><hlink|OCFL 1.1 specification|https://ocfl.io/1.1/spec/> and <hlink|OCFL extensions|https://ocfl.github.io/extensions/>

    <item><hlink|DataCite Metadata Schema 4.7|https://schema.datacite.org/>, <hlink|DataCite guidance on preprints|https://support.datacite.org/docs/preprints-post-prints-and-author-manuscripts> and <hlink|the REST API change for publisher and affiliation|https://support.datacite.org/docs/datacite-rest-api-affiliation-and-publisher-default-change>

    <item><hlink|RFC 2119|https://www.rfc-editor.org/rfc/rfc2119>, <hlink|RFC 8174|https://www.rfc-editor.org/rfc/rfc8174>, <hlink|RFC 8259|https://www.rfc-editor.org/rfc/rfc8259>, <hlink|RFC 4151|https://www.rfc-editor.org/rfc/rfc4151> and <hlink|RFC 3339|https://www.rfc-editor.org/rfc/rfc3339>

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
