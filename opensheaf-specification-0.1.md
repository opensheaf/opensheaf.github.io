# OpenSheaf: an open format for document archives and collections

*Specification, version 0.1 (draft), 18 November 2026. OpenSheaf is a common, open format for archives of scholarly documents and for collections of them, built on the Oxford Common File Layout (OCFL 1.1) and the DataCite Metadata Schema (4.7). The text is licensed under CC BY-SA 4.0; the JSON Schemas are dedicated to the public domain (CC0 1.0).*

> [!WARNING]
> **Draft, being rebuilt.** This text is being rebuilt, concept by concept, from the [reference text](reference/opensheaf-specification-0.1-full.md) of PR #30, into a shorter and coherent whole. A concept not yet rebuilt is read in the reference text. Until version 1.0, any revision may change the format in incompatible ways.

## 1. Introduction (non-normative)

OpenSheaf is a lean alternative to arXiv and to the usual publication infrastructure. Any author, group or institution can keep an archive of its documents as plain files, served as a static website, checkable by anyone, and composable with other archives:

- **Sources, not only PDFs.** A deposit keeps the sources of a document with its renditions, so that the archive can be read as a website and in the authoring tool.
- **Fixed versions.** Every version is fixed by content digests and never changes once deposited. Corrections are new versions, and the history can be checked from the files alone.
- **Owners, not hosts.** Each history of a work belongs to an owner, a person, group or institution holding keys, who signs its versions. An archive only hosts what owners write there, and copies what others wrote elsewhere; it decides nothing about what is authentic.
- **Standards, not inventions.** Storage follows OCFL 1.1 and description follows DataCite 4.7. This specification defines only what they leave open: discovery, names, owners and signatures, collections, withdrawal, and profiles for external services and tools.
- **Composable collections.** A collection is itself a versioned object. It can include documents and collections of other archives, pinned by digest, so that selections (a seminar, an editorial board, a reading list) compose without copying.
- **External services are optional.** Archives may deposit their documents with a DOI service such as Zenodo, publish them as a website, and keep their files in git; the core requires none of these.

Two companion texts go with this specification: [OpenSheaf archives in git](opensheaf-git-0.1.md), for archives kept in git repositories, and the [timestamps extension](opensheaf-timestamps-0.1.md), for dating signatures. Questions about the design are answered in the [FAQ](FAQ.md), and the [use cases](USE-CASES.md) show the format at work.

The name: a sheaf is a bundle of papers and, in mathematics, the structure in which local pieces glue into a whole, as archives kept and checked separately compose into collections. The home of the format is `https://opensheaf.org/`; the first archive is `https://mgubi.org/papers/`, whose values appear in the examples.

## 2. Conventions and conformance

The key words MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, RECOMMENDED, NOT RECOMMENDED, MAY and OPTIONAL are to be interpreted as described in BCP 14 (RFC 2119 and RFC 8174) when, and only when, they appear in all capitals. Sections marked non-normative, examples and notes are informative.

JSON means RFC 8259 JSON in UTF-8 without a byte order mark. URLs are absolute unless stated otherwise; a relative URL in a JSON file is resolved against the URL of that file. Digests are written in lowercase hexadecimal unless stated otherwise. Terms are defined where they are first introduced, written <dfn>thus</dfn>.

**Conformance classes.** An archive, an object or a program conforms to a class when it meets every MUST and MUST NOT of the sections listed for it:

- **archive:** sections 3 to 13 and 15;
- **collection:** section 8, with the rules on objects of sections 4 to 7;
- **owner tool**, a program that seals, signs or keeps an owner's key log: sections 5 to 7, 10 and 15;
- **verifier:** sections 14, 15.2 (on untrusted input) and 16 (as a reader), with the rules it checks;
- **resolver:** sections 12 and 15.2 (on untrusted input), with sections 6 and 7 for checking signatures and key logs; a gateway also follows the rules on gateways of section 12.

**Profiles.** An archive MAY also follow the profiles of appendix A (Zenodo, TeXmacs, website), and MUST list in its discovery document those it follows.

**Extensions.** An extension is a specification published apart, named by a URI (RECOMMENDED: the `https` URL where it is published), that records what this specification leaves open, so that tools aware of it can act on it. Its data is kept under `extensions`, keyed by the extension's name: in `object.json` (section 4), where the inventory and the pins fix it, or in `keys.json` (section 6), where the owner's signatures fix it. An extension MUST NOT change the meaning of what this specification defines, nor relax its requirements: archives, objects and collections are read and verified without knowing any extension, and readers ignore extensions they do not know. The discovery document SHOULD list the extensions its objects use. The [timestamps extension](opensheaf-timestamps-0.1.md) is one.

**Schemas.** The JSON files defined here MUST validate against the JSON Schemas of appendix B for their declared format version.

## 3. Archives

An <dfn>archive</dfn> is a host of objects, served at a <dfn>base URL</dfn> ending with `/`. It holds the lines that owners write there (section 7) and copies of lines written elsewhere (section 11). No file of an object names the archive that holds it (section 4.3), and what is authentic is decided by pins and the owners' signatures (sections 4 and 7), never by where a file was fetched; an archive decides only which owners it hosts and how they deposit (a university admitting its staff, a journal its editors). Its base URL is a location, not a name, and may change; an archive's files MAY be served at several base URLs, each a location of the same archive.

An archive consists of a **discovery document**, REQUIRED (section 3.1); a **storage root**, REQUIRED (section 3.2); **indexes**, RECOMMENDED (section 12); and **presentation files**, OPTIONAL: web pages and other files generated for readers, never authoritative, kept outside the storage root (appendix A).

**Serving.** The discovery document, the storage root and the indexes MUST be served byte for byte, as stored: no conversion of line endings or character sets, and no compression that changes the bytes delivered after decoding. Archives SHOULD be served over HTTPS, and SHOULD allow cross-origin requests to these files (`Access-Control-Allow-Origin: *`), so that tools in a browser can read them. Any static web server will do; an archive kept in git follows [OpenSheaf archives in git](opensheaf-git-0.1.md).

**Moving.** An archive moving to another site, or served at another, copies its files unchanged, its drafts included (section 10); nothing in them changes, so every pin, signature and witness stays valid. Its base URL, and every location of a copy given elsewhere (in collections, `sheaf:` URIs, indexes), is a hint that needs no signature: whatever is fetched from it is checked against pins and signatures, so a wrong or stale location gives a reader nothing, or an older valid copy, never a forged one.

### 3.1 The discovery document

The <dfn>discovery document</dfn> is the JSON file `opensheaf.json` at the base URL. Static web servers cannot list folders; this one file makes an archive's objects known. It MUST contain:

- `format`: `"opensheaf-archive/0.1"`, and `specification`: `"0.1"`;
- `name`: a readable name of the archive;
- `storageRoot`: the URL of the storage root, ending with `/` (it may be relative);
- `storageLayout`: its layout, `"opensheaf-owner-name-storage-layout"` or `"0003-hash-and-id-n-tuple-storage-layout"` (section 3.2);
- `profiles`: the profiles it follows, from `zenodo`, `texmacs`, `website` (appendix A), possibly none;
- `objects`: every object of the storage root except drafts, each with `id` (section 4), `kind`, `name` and `owner` (section 7), `head` (its OCFL head version), `inventorySha512` (the SHA-512 digest of the head inventory, as its checksum file states it) and `status` (`active` or `withdrawn`, that of its latest version that is signed or unchecked, sections 7.3 and 13.1), and OPTIONALLY a `label`.

It SHOULD contain `mainCollection`, the identifier of the catalogue of the archive's documents (section 8); `contact`, a URI; and `extensions`, the names of the extensions its objects use (section 2). It MAY contain `owners`, the owner names of the owners it hosts (section 6); `drafts`, the drafts it chooses to show, with `id`, `kind` and `head`, as unfinished work on which nothing may rely (section 10); `indexes`, which maps each index kept to the length of the prefixes of its files (section 12.5); and `feed`, the URL of an Atom feed of new object versions. It MUST contain `tombstones` once an object has been taken down (section 13.3).

The discovery document is rewritten whenever an object is added or changed. It is a map, not a witness: everything it states about objects MUST agree with the storage root, which verifiers check (section 14), and it lists what the archive holds, not every line an owner has elsewhere.

**Labels.** A <dfn>label</dfn> is a short readable name an archive MAY give a line it holds, for readable URLs on its website: it matches `^[a-z0-9]+(-[a-z0-9]+)*$`, has at most 64 characters, and is unique in the discovery document. It is the archive's choice, may change, and is not an identifier; permanent links use `sheaf:` URIs (section 12). Labels SHOULD be chosen by the depositor, not derived from the title.

### 3.2 The storage root

The <dfn>storage root</dfn> is an OCFL 1.1 storage root at the URL `storageRoot`, holding the archive's objects (section 4). Since OCFL allows in it only the folders that lead to objects, and extensions, it SHOULD be a dedicated folder (by convention `ocfl/`), and presentation files MUST NOT be placed in it. It MAY contain, as loose files, copies of the OCFL specification and of this one. Its `ocfl_layout.json` names its storage layout, which MUST be the one given by `storageLayout`:

- **The owner-name layout**, `opensheaf-owner-name-storage-layout`, the default, defined here (not yet registered with OCFL, so validators may warn about it). The object whose identifier is `sheaf:<name>:<owner>` (section 4) is at `<owner>/<name>/`, and a draft `sheaf:draft:<id>` at `draft/<id>/`; any other identifier is an error. An owner's object is thus at `<owner>/<owner>/`, and the folder of an owner holds its key log and every line of it in the archive, so that an owner moving elsewhere copies one folder. The layout has no parameters; `ocfl_layout.json` describes it as `"Lines at <owner>/<name>, drafts at draft/<id>"`.
- **The hashed layout**, for large archives: OCFL's `0003-hash-and-id-n-tuple-storage-layout` with its default parameters (`sha256`, tuples of 3 characters, 3 tuples), which a configuration file, if present, MUST NOT change. An object is at `<t1>/<t2>/<t3>/<encoded id>/`, where `<t1>`, `<t2>`, `<t3>` are the first three groups of three characters of the hexadecimal SHA-256 digest of its identifier, and `<encoded id>` is the identifier percent-encoded as the extension says (every character but `A-Z`, `a-z`, `0-9`, `-` and `_`), shortened, when longer than 100 characters, to its first 100 characters, `-` and the full digest; identifiers of lines are always shortened so (appendix C). Readers compute the path; they never decode it.

Archives SHOULD use the owner-name layout, unless one folder per owner or per name becomes impractical (tens of thousands of lines, fewer in a git repository). The layout is chosen when the archive is created and SHOULD NOT be changed: pins stay valid, since readers compute paths from `storageLayout`, but every URL into the storage root changes.

## 4. Objects

An <dfn>object</dfn> is an OCFL 1.1 object in a storage root. Its <dfn>kind</dfn>, given by its `object.json` and never by its identifier, is `document`, one work (an article, notes, a thesis, a book) with its sources and renditions; `collection`, a list of members (section 8); or `owner`, the key log of an owner (section 6).

**Identifier.** The <dfn>identifier</dfn> of an object, its OCFL `id`, is `sheaf:<name>:<owner>`, the name of the work (section 5) and the owner name of its line's owner (section 6), which `object.json` records as `name` and `owner`. It names the line (section 7), in every archive. A branch is a new object with its own identifier (section 9); a draft is `sheaf:draft:<id>` (section 10). The identifier MUST be unique in the storage root, and that of a sealed object MUST NOT be reused there, also after a takedown (section 13).

**Versions.** An <dfn>object version</dfn> is an OCFL version of an object (`v1`, `v2`, ...): every change of the object makes one, and none changes once made, except in a draft (section 10) and at a fork of a key log (section 6.3). A <dfn>document version</dfn> is a version of the work, a positive integer numbered by the owner of the line and recorded in `object.json` and `datacite.json`; it changes only when the document's own files change (section 4.2), so several object versions may hold one document version, with different descriptions or notices.

**Pins.** A <dfn>pin</dfn> is the pair (object version, SHA-512 digest of that version's inventory file, as its checksum file states it). An inventory records the digests of the files of its version and of every earlier one, so a pin fixes the object up to that version, in any copy. Collections (section 8), branches (section 9) and `sheaf:` URIs (section 12) refer to object versions by pins, and pin only signed versions (section 7).

### 4.1 Common rules

Every object MUST be a valid OCFL 1.1 object, and:

- its inventories MUST use the digest algorithm `sha512`; they MAY also record MD5 and SHA-256 digests in `fixity` (the Zenodo profile requires MD5, appendix A);
- every version directory MUST contain the inventory as of that version, with its checksum file, so that each version can be pinned and fetched on its own;
- version directories MUST NOT be zero-padded (`v1`, not `v001`);
- logical paths MUST be in UTF-8 and Unicode normalisation form C, and MUST NOT begin or end with `/`, or contain empty, `.` or `..` segments, or `\`.

**Deposits.** Each version in the inventory MUST have a `user` with a `name`, SHOULD give its `address` (an ORCID iD, a `mailto:` URI or another URI identifying the depositor), and MUST have a `message` describing the change. The `created` date and `user` of an object version record its <dfn>deposit</dfn>, not repeated in `object.json`; the deposit of a document version is that of the first object version holding it.

**Content.** Every object version MUST contain, at the top level of its content, `object.json` (section 4.3); `datacite.json` (section 4.4), except in an owner object; and the genesis record `genesis.json` (section 5), except in a draft. Every version of a branch also holds the evidence of its branch point: `parent.inventory.json`, `parent.object.json`, `parent.signatures/` and, for a branch of a branch, `parent.chain/` (section 9). The genesis record and this evidence are the <dfn>identity files</dfn> of the object, never files of the document's own. The names of every file this specification defines at the top level of the content (`object.json`, `datacite.json`, `genesis.json`, `members.json`, `keys.json`, `forked`, `parent.inventory.json`, `parent.object.json`, `parent.signatures`, `parent.chain`) are reserved for those files. A collection version also holds `members.json` (section 8). An owner object holds `genesis.json` and `keys.json` (section 6), a fork record `forked/` instead of `keys.json` (section 6.3), and no `datacite.json`; it has no document versions, and is never withdrawn or branched. Signatures and other witnesses are kept outside every version, in the object's extension folder `extensions/opensheaf-witnesses/` (section 7).

### 4.2 Documents and document versions

A document version holds, at the top level of its content unless a profile says otherwise, besides the files of section 4.1:

- the <dfn>sources</dfn>: the main source and every file needed to produce the renditions that is not part of the toolchain (images, bibliography databases, local style files); they SHOULD be flat (no sub-folders) when possible;
- the <dfn>renditions</dfn>, files produced from the sources (a PDF, an EPUB): OPTIONAL, but RECOMMENDED, at least a PDF for a document meant to be read and cited;
- the files of its notes, if any (section 4.3).

The sources, the renditions and the change note (`changes`, section 4.3) are the document's own files. HTML versions and other presentation files SHOULD NOT be deposited.

**Numbering.** The owner of the line numbers document versions from 1, without gaps, independently of any external numbering: a work whose versions 1, 3 and 4 are on arXiv has document versions 1, 2 and 3. External labels (arXiv's `v3`) are recorded in `external` (section 4.3); presentations SHOULD show them with the document version. Branches number as section 9 says.

**New versions.** A new document version is made exactly when the document's own files change (a file added, changed or removed, the change note included), except when a version without sources is completed (below); an object version holding the same own files as an earlier document version keeps its number. A collection makes a new document version exactly when its member list changes (section 8). A version not public at the time (the manuscript submitted to a journal), deposited later, is a document version like any other; a version published by someone else (the journal's version of record) is not, and is linked by a relation (section 4.4).

**Description-only versions.** A <dfn>description-only version</dfn> holds an existing document version with its files unchanged, and changes only its description (`datacite.json`: a DOI, a link to the published article), its `stage`, the state of the object or its notices. It MAY hold any document version, so that an earlier one can be described; tools otherwise hold the current version. If the object has `history`, the entry of that document version becomes the new object version.

**Completion.** A document version deposited with `sourcesMissing` (section 4.3) MAY be completed, keeping its number, by object versions that add its sources, possibly with renditions made from them, and change or remove no file of the version. It keeps `sourcesMissing` until the sources are complete; the object version that completes them names the main source and drops `sourcesMissing`, and the version is then fixed like any other.

**History.** The <dfn>history</dfn> of a document is the order of its document versions in the history of the work: the order of their numbers, unless `object.json` has `history`, the list, in that order, of the last object version holding each document version. An object version that deposits a document version out of order (an earlier version found later) MUST write `history`, and every later object version MUST keep it. A version whose place is unknown goes just before the current version, and its change note SHOULD say so. The history is read from the latest signed version of the line (section 7); earlier object versions keep it as it was then known. Dates never order document versions.

**Current version.** The <dfn>current version</dfn> of a document is the last of its history. The latest signed version may hold another document version, deposited out of order or newly described; the current version stays where it was. Landing pages, indexes and citations use the current version.

**Notices.** A <dfn>notice</dfn> is a statement about a document version made after it, since the version cannot change (that a theorem of version 2 is wrong as stated, and corrected in version 3). Notices are added to `notices` by description-only versions, and stay, unchanged, in every later object version (for a branch whose branch point moves, see section 9); a notice is corrected or withdrawn only by a later notice. Presentations showing a document version SHOULD show the current notices about it.

### 4.3 The object record: object.json

Every object version MUST contain `object.json`, the record of the object's identity, content, versions and state; it names no archive. It MUST contain:

- `format`: `"opensheaf-object/0.1"`, and `specification`: `"0.1"`;
- `kind`: `document`, `collection` or `owner`;
- `status`: `active` or `withdrawn` (section 13.1), always `active` for an owner or a draft;
- `documentVersion`, for a document or a collection: equal to `version` in `datacite.json`;
- in every version of a line, `name` and `owner` (sections 5 and 6), and in a branch `parent`, its branch point (section 9); a draft has none of them.

An owner object has only these fields, and MAY have `extensions` (below), though data concerning its key log goes in `keys.json` (section 6).

A <dfn>note</dfn> is an object with `text`, a short plain text, or `path` and `mediaType`, a file of the content of the same object version, or both.

A document MUST have `mainSource` (a logical path) and `sourceFormat` (its media type), and SHOULD have `renditions`, a list of `path` (a logical path) and `mediaType`, and `toolchain`, a list of tools with `name`, `version` and, OPTIONALLY, `packages`, enough to reproduce the renditions. A document version without its sources has instead `sourcesMissing`, a note saying why ("arXiv keeps only the PDF of this version"), and at least one rendition; a rendition is never presented as a source. A document MAY have:

- `changes`: a note saying what changed in this document version, deposited with it (like arXiv's comments);
- `stage`: the stage of this document version, with `scheme` and `value`; for articles the RECOMMENDED scheme is `NISO-JAV` (NISO Journal Article Versions: `AO`, `SMUR`, `AM`, `P`, `VoR`, `CVoR`, `EVoR`), and other content uses other schemes (editions, software releases), named by the archive;
- `history` and `notices` (section 4.2), each notice a note with the `documentVersion` it is about and a `date`;
- `licence`: a note with the full text or terms of the licence (for licences without an SPDX identifier); `rightsList` in `datacite.json` remains the description for readers.

A collection has none of these fields of a document, and its notes are text only (section 8.2). A document or a collection MAY have:

- `agreement`: a minimal record that the authors agreed to the deposit and the licence: `by` (names only), `date` and `method` ("by e-mail"), all REQUIRED. It MUST NOT contain e-mail addresses, correspondence or signatures of persons;
- `external`: the external records of this version, each with `role` (`deposit` for a deposit by the archive, appendix A; `source` for the record it was imported from), `service` (its name) and `record` (its URL), all REQUIRED, and OPTIONALLY `doi`, `label` (the service's label for the version, such as `v3`) and `files`, the files kept there but not in the content (a deposit's source archive) or received from there, as received, each with `name` and `sha512` (REQUIRED), `md5` and `bytes`;
- `withdrawal`, REQUIRED when `status` is `withdrawn`: a `date` and a `reason`, a note (section 13);
- `extensions`: the data of extensions (section 2), keyed by the names of the extensions.

### 4.4 The description: datacite.json

Every object version except in an owner object MUST contain `datacite.json`, the DataCite 4.7 properties in the form of the `attributes` of a DOI in the DataCite REST API: the authoritative description of the object version. It MUST contain `titles`, `creators` (with `name` and `nameType`; personal names SHOULD also have `givenName` and `familyName`), `publicationYear`, `types` (with `resourceTypeGeneral`), `version` (the document version as a decimal string without leading zeros, `"3"`) and `publisher`. It SHOULD contain:

- `descriptions`, with an `Abstract`, and `subjects`, with a `subjectScheme` (MSC2020 is common in mathematics);
- `dates` (below);
- `rightsList`: for a licence with an SPDX identifier, that identifier in lower case and the licence URL; for one without, its name in `rights` and, REQUIRED then, the URL identifying it in `rightsUri` (for arXiv's default licence, `http://arxiv.org/licenses/nonexclusive-distrib/1.0/`); or a statement such as "All rights reserved", without URL;
- `language`, `formats` (the media types of sources and renditions) and `sizes`;
- identifiers of creators (ORCID) and affiliations (ROR), where they exist;
- `relatedIdentifiers` (below).

`publisher` is the owner of the line, the body behind it (a journal, an institution), or the service registering the version's DOI (appendix A). `publisher` and `affiliation` SHOULD be objects, with `name` and, where available, an identifier; readers MUST also accept strings. `doi` and `url` are present when the version has a DOI. `resourceTypeGeneral` is from DataCite's list (`Collection` for collections), with `resourceType` for detail ("Lecture notes"). An author's versions of a work not published elsewhere, the accepted manuscript included, are `Preprint`; `stage` in `object.json` gives their stage.

**Mathematics.** Titles and abstracts are plain text, in which mathematics MAY be written in LaTeX between single dollar signs (`$\Phi^4_3$`; a literal dollar is `\$`). It SHOULD use only the mathematical commands of LaTeX with `amsmath` and `amssymb`, which common renderers display without the document's preamble. Tools importing them SHOULD replace the authors' macros (`\R`) with standard LaTeX when their definitions are known, and otherwise keep them; they MUST NOT invent definitions.

**Dates.** Each date type has one meaning:

- `Issued`: the first public appearance of the work, anywhere, the same in every version; RECOMMENDED, and tools importing works published elsewhere SHOULD set it;
- `Available`, SHOULD be present: when this document version first became public, anywhere (its date on the service it was imported from, or its deposit, section 4.1, if it was first made public by its deposit);
- `Updated`: the date of the latest description-only version holding this document version, if any;
- `Created` (when a version not public at the time was written), `Submitted` and `Accepted`, OPTIONAL;
- `Withdrawn`: equal to `withdrawal.date` in `object.json`.

Dates MAY be approximate, as DataCite allows (`2019-03`, `2018/2019`), with `dateInformation` saying why; unknown dates are omitted.

**Relations.** In `relatedIdentifiers`:

- a document version with a DOI SHOULD have `IsVersionOf` the concept DOI of the document, and `IsNewVersionOf` the DOI of the version before it in the history, if it has one; after a version is deposited out of order, the relation of the version following it MAY be corrected by a description-only version;
- the same work published elsewhere SHOULD be linked with `IsIdenticalTo` (same content, such as an arXiv version) or `IsVariantFormOf` (different content or form);
- a preprint SHOULD be linked to its published article with `IsVersionOf` the article's DOI, as DataCite recommends, by a description-only version;
- the sources MAY be linked to a software archive snapshot (`SWHID`);
- a `sheaf:` URI (section 12) is recorded in its canonical form as a `URL`, provisionally, until the scheme is registered (#36);
- a document MUST NOT name the collections that include it: membership is stated only by collections, so that including a document never changes it.

## 5. Names

A work, and an owner, has a <dfn>name</dfn>: a digest of its genesis record, the same in every archive and copy, which anyone holding a copy can check. An owner's name is its owner name (section 6).

### 5.1 The genesis record

The <dfn>genesis record</dfn> is the JSON file `genesis.json` at the top level of the content, written when a work is sealed (section 10) or an owner created (section 6). It contains:

- `format`: `"opensheaf-genesis/0.1"`;
- `kind`: `document`, `collection` or `owner`, the `kind` of the object;
- `created`: the date and time it was written, in UTC (`2026-03-02T09:14:00Z`);
- `nonce`: at least 128 bits from a cryptographically secure random generator, in lowercase hexadecimal;
- for a document or a collection, `originator`: the owner name of the owner of the first line (section 5.3);
- for an owner, instead, `keys` and `threshold`: its first keys and how many must sign, which the first version of its key log repeats (section 6).

The genesis record MUST be part of every object version of the object and of its branches (section 9), byte for byte. It MUST be in UTF-8 without a byte order mark, and SHOULD have LF line ends. Since the name is the digest of its bytes as stored, tools MUST NOT rewrite or re-serialise it. A tool MUST NOT copy a genesis record into an object that is not a copy or a branch of the work it was written for, nor reuse a nonce.

### 5.2 Computing a name

Algorithm k, for k from 0 to 15, takes the SHA-256 digest of the seed `opensheaf-name-<k>` (ASCII, k in decimal, followed by a line feed) followed by the bytes of `genesis.json`, and writes it in lowercase base32 (RFC 4648, without padding): 52 characters, the last of which holds the last bit of the digest and four zero bits, which are set to k. A name thus matches `^[a-z2-7]{52}$`, and its last character gives its algorithm (`a` or `q` for algorithm 0), so names made by different algorithms never coincide. Names are compared as strings, never decoded. `object.json` records a line's name as `name`; appendix C gives examples.

A genesis record thus has 16 names of one work (section 12 searches for a work by all of them). Its <dfn>genesis name</dfn>, made by algorithm 0, is the same for every line of the work. Every line is named by its genesis name, except a branch renamed after a clash (section 5.3).

### 5.3 Origin and clashes

**Origin.** The <dfn>originator</dfn> of a work is the owner its genesis record names in `originator`; an owner is its own originator. The originator's line is the origin of the name: it has no parent, and its first version MUST be signed by the originator (section 7). Every other line of the genesis record is a branch and MUST declare its parent (section 9); a line of another owner that declares none is not a valid line of the name. A tool refuses a branch owned by the originator (how the originator takes in another line's work is open, #57).

**Clashes.** An owner has one line of each name, and no two objects of a storage root have the same line (section 4). A clash can arise only when a line is made, and the tool that makes it resolves it against the archive where it writes and the lines of the same owner it knows elsewhere that are signed (section 7):

- **Sealing.** If the line is taken, the tool draws a new nonce, so that an originator's line is always named by algorithm 0. A work sealed elsewhere that meets, when deposited, a taken line with another genesis record (a collision) is refused, and its owner seals it anew; with the same genesis record, it is a copy (below), or a reused record (section 5.4).
- **Branches.** A branch is named by `parent.name`, unless its line is taken by another line of its owner, in which case it is named by the smallest algorithm number greater than that of `parent.name` that gives a line free for its owner, and `parent` keeps the parent's name; if none up to 15 is free, the branch is refused. When the line taken is the owner's own branch of the same parent line, section 9 says when the owner moves that branch's branch point instead.
- **Copies.** A copy whose line is taken in a storage root by a different history of it is a fork of the line (section 7): the archive keeps the history it holds, and reports the other.
- **Takedowns.** A line stays taken in an archive after a takedown, since its tombstone keeps its identifier (section 13).

Lines of different owners never clash. A renamed branch is always written with its owner part, since a `sheaf:` URI without one names the originator's line (section 12).

### 5.4 Reused genesis records

A genesis record reused for another work gives no valid line: the originator's line needs the originator's signature, and every other line needs a chain of signed parents back to it (section 9). A second history that the originator signs under its own record is a fork of its line (section 7).

When an object is created or deposited, an archive that holds an object or a tombstone with the same genesis record, compared by genesis name (`genesisName` of a tombstone, section 13), MUST refuse it unless it is signed by the originator (the originator's line) or is a branch whose branch points are confirmed back to the originator's line (section 9.3).

**Open question.** Whether aliases, new genesis records wrapping an old one, are needed if refusing reused genesis records proves too strict (#44).

## 6. Owners

An <dfn>owner</dfn> is a keyed identity: a person, a group or an institution that decides the versions of its lines and signs them (section 7), wherever they are stored. It is an object of kind `owner` (section 4), named by its genesis record (section 5): its <dfn>owner name</dfn> is the name of that record, the name that genesis records (`originator`), `object.json` (`owner`, and `owner` in `parent`) and `sheaf:` URIs (section 12) record. The owner object is the owner's own line, `(owner name, owner name)`, at `<owner>/<owner>/` in the owner-name layout (section 3.2). Its object versions are the owner's <dfn>key log</dfn>.

### 6.1 The key log

Every version of the key log holds, besides the files of section 4.1, the file `keys.json`, with:

- `format`: `"opensheaf-keys/0.1"`;
- `keys`: the public keys of the owner, at least one, each distinct, each an Ed25519 key written as a `did:key` URI (W3C CCG; multibase base58btc, multicodec `ed25519-pub`, code `0xed`, written as the varint bytes `0xed 0x01`);
- `threshold`: the number of distinct keys of this version that must sign, a positive integer;
- `extensions`, OPTIONAL: the data of extensions concerning the key log, keyed by their names (section 2), each an object; for instance the declaration of the [timestamps extension](opensheaf-timestamps-0.1.md);
- `keeper`, OPTIONAL: `https` URLs of whoever answers for the owner (section 6.6);
- `ended`, OPTIONAL: `true` in the last version of the key log of an owner that ends (section 6.3);
- `successor`, OPTIONAL, only with `ended`: the owner name of the owner that continues its work (section 6.3).

In the genesis record of an owner and in every `keys.json`, `threshold` MUST NOT exceed the number of `keys`.

Key-log versions are the OCFL versions of the owner object (`v1`, `v2`, ...); an owner object has no document versions. The first version holds the genesis record and the first `keys.json`, whose `keys` (compared as a set) and `threshold` MUST be those of the genesis record; it MAY add `keeper` and `extensions`. Its authority comes from the genesis record: another first version under the same owner name would need other keys, and so another name. It is signed by `threshold` of its own keys. Every later version vN+1 MUST be signed by at least `threshold` distinct keys of vN, `threshold` being that of vN. Signature files, and when a signature is good, are defined in section 7.

A key is added or retired, the threshold or the data of an extension changed, a keeper named, or the owner ended, by a new version of the key log; the owner name never changes. Changing the keys or the threshold affects only signatures naming the new version or a later one: signatures naming earlier versions stay good (section 7), and nothing is signed again.

### 6.2 Creating an owner and choosing its keys

An owner tool creates an owner by writing its genesis record, with `kind` `owner` and the first `keys` and `threshold` (section 5.1), and the first version of its key log, signed as above. An owner is its own originator, and its owner object has no parent, so its owner name is made by algorithm 0 (section 5.2). If the owner name is taken, in the archive where the tool writes or among the owners it knows elsewhere, the tool draws a new nonce (section 5.3).

**Choosing a threshold.** One `threshold` governs the key log and every line of the owner. Owners choose between two risks: a threshold of 1 with a spare key kept apart (on a hardware token, for instance) survives the loss of a key but not its theft; a threshold of 2 with three keys kept apart, from the first version of the key log, survives the loss of one key and the theft of one. Owner tools SHOULD offer both, and SHOULD NOT create an owner with a single key, since an owner that loses every key of the latest version of its key log cannot recover.

**Retiring a key.** An owner retires a key it no longer uses (a replaced laptop, a member who leaves the group) by leaving it out of `keys` in a new version of its key log. Signatures made with it stay good, and a retired key in someone else's hands still makes good signatures naming the versions that list it; so retiring is enough after an exposure only when the exposed keys cannot reach a threshold (section 6.3).

### 6.3 Ending, forks and healing

**Ending.** An owner ends by signing, as usual, a last version of its key log with `ended` `true` and, OPTIONALLY, `successor`, the owner name of a new owner that continues its work, which MUST differ from its own owner name. The ending version only ends: a version after one with `ended` is not a version of the key log, and no signature of a line may name the ending version (section 7). Signatures made before it name earlier versions, and stay good. Owner tools MUST NOT sign anything for an ended owner. A successor is a hint, never followed automatically; its keeper MAY confirm it (section 6.6). An owner is <dfn>ended</dfn> when its key log has an ending version.

**Exposed keys.** An owner whose keys may have been exposed (stolen, leaked, copied), and could together reach the `threshold` of some version of its key log that lists them, MUST end, or nullify them by a fork of its key log and heal it (below); otherwise retiring them is enough (a threshold of 2 from the first version, and one key exposed).

**Forks of a key log.** Two different versions of a key log with the same number, each signed by `threshold` keys of the version before, are a <dfn>fork of the key log</dfn>; that number is the <dfn>fork point</dfn>. Whoever holds `threshold` keys of the version before can make one: a thief, or the owner itself, signing two versions with keys it wants nullified. The format cannot tell which side is the owner's, so it trusts neither: an archive that holds one side and meets the other replaces, in its copy, the version it holds at the fork point by a fork record, and drops every later version.

**Fork records.** A <dfn>fork record</dfn> is a version of the key log at the fork point, made by the archive that records the fork (its deposit, section 4.1), and not signed: besides `genesis.json` and `object.json`, it holds only the conflicting versions it <dfn>carries</dfn>, each under `forked/<d>/`, where `<d>` is the first 16 characters of the lowercase base32 (RFC 4648, without padding) SHA-256 digest of its inventory file: that inventory file, its checksum file, its `keys.json` and its signature files, byte for byte. It is valid when it carries at least two versions of its number, with different inventory files, each signed (section 7.3) against the version before it, which anyone checks from its content and that version; otherwise it is not a version of the key log. The keys that sign the versions a fork record or a healing version carries, and the keys those nullify, are <dfn>nullified</dfn>. A key log whose latest version is a fork record is <dfn>tainted</dfn>: no version follows a fork record but by healing, no signature names one, and owner tools sign nothing for a tainted owner but a healing version. Fork records are copied with the key log like any version, so that every copy shows the fork.

**Healing.** A <dfn>healing version</dfn> is a version of the key log at a fork point that carries, as a fork record does, one or more versions of its number, each signed against the version before; that holds a `keys.json` listing none of the keys it nullifies; and that is signed by `threshold` keys of the version before, none of them nullified by it. It is otherwise a version like any other, and the key log continues from it. The owner heals a tainted key log by a healing version carrying every version the fork record carries; it answers a thief directly by a healing version carrying the thief's version. An owner that cannot heal, having too few keys left, stays tainted, which is treated as an end (section 6.4); its keeper MAY name a successor (section 6.6). Owner tools SHOULD keep, besides the keys in daily use, at least `threshold` spare keys kept apart and used only to heal, and MUST show the owner a version of its key log that the owner did not make before signing anything.

**When versions meet.** When a reader or an archive holding a version of a key log meets a different version of the same number, after the same versions: a fork record or a healing version <dfn>supersedes</dfn> a version it carries, a version signed by a key it nullifies, and a fork record that carries no version it does not carry; the version superseded is replaced by the one that supersedes it. Otherwise the two are replaced by a fork record carrying every version they are or, for fork records and healing versions, carry. The versions after a version replaced are dropped; signatures naming them are unchecked there (section 7.3). These replacements are made only to key logs, and are the only changes of an object version outside drafts (section 4).

### 6.4 After an end, a fork or healing

The signatures of an ended or tainted owner, and the signatures made with nullified keys, stay good, since the format does not date signatures; but versions signed after a key was exposed cannot be told from a thief's, so readers trust them only as far as other evidence goes: copies held before, the pins of collections (section 8), timestamps (the [timestamps extension](opensheaf-timestamps-0.1.md)).

**Nullified keys.** An archive adds no version, of a line or of a key log, that is signed only thanks to a signature made with a nullified key or naming a version carried by a fork record or a healing version (section 7.5); the versions it holds stay. Since fork records and healing versions travel with key logs, every archive that receives one applies this rule from then on.

**Ended and tainted owners.** An archive that knows an owner is ended or tainted adds that owner's key log up to the ending version or the fork record, and takes that owner's lines only from copies found elsewhere, never as new deposits; section 7 gives the rule for adding their versions. The work of an ended owner continues under its successor, by branches of its versions (section 9); a healed owner continues its own lines. Resolvers and verifiers report ended, tainted and healed owners, and successors (sections 12 and 14).

### 6.5 Key logs travel with the objects they sign

A key log checks itself from its owner name: the genesis record of its first version lists the first keys, and each later version is signed by the keys of the one before. A copy from any source is therefore as good as the original, and a line can be checked without trusting any host, also after the archives that served it have gone.

Every copy of an object, in any archive, MUST hold beside it, as owner objects in the same storage root at their paths (section 3.2), the key logs of the owner of its line and, for a branch, of the owner of each parent whose signatures its evidence holds, in `parent.signatures/` and at every level of `parent.chain/` (section 9). Each is copied up to the latest version that whoever makes the copy knows, and at least up to the versions its signatures name. The key logs of third parties whose witnesses a copy holds (section 7) MAY be copied too. Key logs are never copied into an object's content. An archive MUST keep an owner object as long as it keeps an object whose signatures need it, unless the owner object is itself taken down; a tombstone then stands in for it, and a takedown of a line leaves its owner objects in place (section 13). An owner object MAY also be copied on its own, to keep a fresher copy of its key log.

Of two copies of a key log, either one extends the other, and readers use the longer, or they meet at a fork point, as section 6.3 says. No one can prove offline that a key log is complete: a copy that stops early may hide that the owner has ended.

**Moving.** An owner moving to another archive copies its owner object there, with the lines it wants to keep there, and continues its lines in the new archive: the same owner and the same lines, not branches. The old copies stay valid where they are, as older copies of the same lines (section 7). In the owner-name layout this is one folder (section 3.2).

### 6.6 Keepers

An owner MAY name, in `keeper` of its key log, the person or institution who answers for it: an ORCID iD (`https://orcid.org/...`) or a domain written as `https://<domain>/`. The keeper MAY confirm it, in a place only the keeper controls: a link naming the owner in its ORCID record, or the file `https://<domain>/.well-known/opensheaf` on its domain, a JSON object with `format` `"opensheaf-keeper/0.1"`, `owners`, the owner names it answers for, and OPTIONALLY `successors`, an object mapping owner names it answers for to their successors (on ORCID, a link naming both). A successor the keeper names confirms the owner's own `successor`; for an owner that cannot sign any more (every key lost), the keeper MAY name one alone, which is reported as named by the keeper, and does not end the owner.

When a keeper is named, a verifier MAY check both directions, and reports the link as confirmed, claimed only (the keeper does not confirm it) or absent. A confirmation is read as it is now: a keeper who withdraws it ends the link, and what the owner signed stays authentic. The link says who answers for an owner, not who owns its lines, which only its keys decide, nor who wrote its documents, which `creators` in `datacite.json` say (#41). The keeper's other roles, in takedowns and for privacy, are in sections 13 and 15.

**Open questions.**

- The field names of `keys.json` (#55).
- Fork records and healing, provisional: the rule for versions that meet, spare keys, and what a reader holding only one side can know (#58; `drafts/keys-and-forks.md` on `main`).
- Whether nullifying keys from when an archive learns of it, rather than dating signatures (revocation dated by trusted time, transparency logs), is enough against backdating (#55, #58).
- The form of a keeper's confirmation on ORCID, which depends on an `https` form of `sheaf:<owner>`, and so on the gateway (section 12; #13, #35).

## 7. Lines and signatures

A <dfn>line</dfn> is the history of a work as decided by one owner, identified by the pair (name, owner) and so by the identifier `sheaf:<name>:<owner>` (section 4). Its object versions form a single sequence, signed by its owner. **A line is its signed versions, wherever they are stored**: in an archive where its owner writes, or in a mirror (section 11). Lines of other owners with the same genesis record are branches (section 9). An owner's key log is the line of its owner object (section 6).

### 7.1 Signing

Every sealed object version of a line MUST be signed by its owner when it is made: by at least `threshold` distinct keys of one version of the owner's key log, `threshold` being that version's, each key signing in its own signature file (section 7.2), which names that key-log version. The key-log version named SHOULD be the latest its signer knows. A signature is judged against the key-log version it names alone (section 6.1), and nothing is ever signed again. An owner MAY add signatures to a version later, with keys that have not signed it. Versions of a key log are signed in the same way, by the keys of the version before, or for the first version by its own (section 6.1).

### 7.2 Witnesses and signature files

A <dfn>witness</dfn> is evidence about an object version made after it: a signature, a timestamp, an external deposit (appendix A), a software archive snapshot. The witnesses kept with an object are in its <dfn>witness folder</dfn>, the OCFL object extension folder `extensions/opensheaf-witnesses/` (not yet registered with OCFL, so validators may warn), which is part of no version, is not covered by the inventory digests, and travels with the object. Witnesses MAY be added at any time, by the owner of the line or by others; they are kept, never re-serialised or replaced once made, since some (timestamps) are made of their bytes, and MUST NOT be removed except by a takedown (section 13).

**Signature files.** A <dfn>signature file</dfn> holds one signature of an object version by the owner of its line. The signature of version `<version>` by a key is the JSON file `<version>/signature-<k>.json` in the witness folder, where `<k>` is the first 16 characters of the lowercase base32 (RFC 4648, without padding) SHA-256 digest of the key's `did:key` URI, as UTF-8, so that a reader that knows the keys builds every name without listing the folder. It has:

- `format`: `"opensheaf-signature/0.1"`;
- `object`: the identifier of the object, `sheaf:<name>:<owner>`;
- `version`: the object version signed, `<version>`;
- `inventorySha512`: the SHA-512 digest of that version's inventory file, as its checksum file states it;
- `signer`: the owner name of the signer, which MUST be the owner part of `object`;
- `key`: the `did:key` URI of the key that signs, one of the `keys` of the key-log version named;
- `keyLog`: that key-log version, as a pin of the owner object written as a `sheaf:` URI, `sheaf:<owner>/v<n>?sha512=<digest>` (section 12), whose owner MUST be `signer`; for a signature of a key-log version vN+1 it names vN, and for the first version the first version itself;
- `signature`: the Ed25519 signature (RFC 8032) of the signed message, 64 bytes in base64 (RFC 4648, with padding).

**The signed message.** What is signed is not a file but the message made of these five lines, each ended by a line feed (LF, `0x0A`), in UTF-8, with no other characters, spaces or blank lines:

```
opensheaf-signature/0.1
object <the value of object>
version <the value of version>
inventory <the value of inventorySha512>
keylog <the value of keyLog>
```

The first line keeps these signatures apart from any other use of the key; the others bind the signature to one object version, its inventory and one key-log version. A verifier rebuilds the message from the fields of the signature file and verifies the signature.

**Others' witnesses.** A signature by someone other than the owner of the line, attesting a version, is a witness, not a signature of the line, and never a signature file: it is `<version>/witness-<label>.json`, where `<label>` is chosen by whoever adds it and matches `^[a-z0-9]+(-[a-z0-9]+)*$`. It has the fields and the signed message of a signature file, with `signer` and `keyLog` naming the signer's own owner object, which MUST NOT be the line's owner; its key log MAY be copied beside the object (section 6.5).

**Other witnesses.** The [timestamps extension](opensheaf-timestamps-0.1.md) keeps timestamps of signature files beside them, dates that readers may weigh; it changes no status.  the parent signatures a branch carries are in its content (section 9).

**Files that are not witnesses.** A file of the witness folder that is not a witness (a stray file, a malformed or invalid signature file) is ignored, reported, never fatal, and kept; a file a reader does not recognise, stray or of an extension it does not know, is reported as an unknown file, not as an error: a host cannot break a version by adding a file. A copy MAY leave such files out (section 11).

### 7.3 Statuses

A signature file is:

- <dfn>invalid</dfn> when it is malformed; its name does not match the digest of its key; its signature does not verify; its `object`, `version` and `inventorySha512` are not those of the version whose folder holds it (the digest also as its checksum file states it; in `parent.signatures/`, those of the parent version, section 9); its `signer` is not the line's owner; the reader reaches the key-log version named, with that digest (also as carried by a fork record or a healing version, section 6.3), and the key is not in its `keys`; or the version named follows one with `ended`, or is a fork record, or, for a signature of a line, has `ended` itself (section 6.3);
- <dfn>unchecked</dfn> when it is not invalid but the reader cannot reach the key-log version it names, with that digest (the key log is absent, taken down, or shorter, or the reader holds another version of that number, which verifiers report as a sign of a fork of the key log, section 6.3); nothing is added on such signatures (section 7.5);
- otherwise <dfn>good</dfn>, for ever: later versions of the key log, an end or a fork never change it.

A version of a key log is <dfn>signed</dfn> when at least `threshold` distinct keys of the version before (for the first version, of itself), `threshold` being that version's, sign it with good signature files. Key logs are read version by version from the first, and are never vouched for (below): each version is checked with the keys of the one before; a version after one with `ended` is not a version of the key log; a fork record is a version when it is valid, though not signed, and a healing version is signed only when it is valid (section 6.3).

A version of a line is:

- <dfn>signed</dfn> when it is <dfn>signed directly</dfn>, by at least `threshold` distinct keys of one key-log version, `threshold` being that version's, with good signature files naming that version; or <dfn>vouched for</dfn>, when a later version of the same line signed directly extends it;
- <dfn>unchecked</dfn> when it is not signed, but would be if its unchecked signatures were good;
- otherwise <dfn>not a version</dfn> of the line, wherever it is found, and never shown as one: reported as invalid if at least one signature file of the owner is invalid, and otherwise as <dfn>unsigned</dfn>.

**A signed version vouches for its past.** The inventory of a version records the digests of every file of every version before it (section 4), so a version signed directly vouches for every version it extends, whatever their own signatures; a version vouched for needs no signatures of its own.

**Readers use the latest signed version.** The <dfn>latest signed version</dfn> of a copy of a line gives the line's history, current version and status (section 4.2). Nothing relies on a version that is not signed: not a pin, a resolution, a collection member or a branch point. An unchecked version is shown with its status until the key log is found.

**Owner tools MUST show the owner** a version that a new version would extend and that is not signed, before signing, so that an owner never takes a thief's version into its line unknowingly; for versions of its key log, see section 6.3.

### 7.4 One writer per line, and forks

An owner MUST NOT sign two different object versions with the same number for the same line. Since every version directory keeps the inventory as of that version (section 4.1), two copies of a line whose heads are `vk` and `vm`, with k not greater than m, <dfn>agree</dfn> when `vk/inventory.json` is the same file, byte for byte, in both. A copy that stops earlier is older: readers use the latest signed version among the copies that agree. Two copies that do not agree are a <dfn>fork of the line</dfn>, reported with the status of each side, and never recorded (an archive keeps the side it holds, section 5.3); a fork whose sides are both signed was made with keys of the owner, and is attributable to whoever holds them.

### 7.5 Adding versions

An archive adds a version to a line only if, once added, it is signed against the key log the archive holds: signed directly by its owner, or vouched for by a version signed directly that is added with it from the same copy. Tools SHOULD fetch the latest version of the key log they can find before adding. An archive adds no invalid signature file. An archive that continues another owner's line makes a branch, under its own owner (section 9).

**Ended and tainted owners.** For an owner that has ended or is tainted, as far as the archive knows (section 6.3), the archive takes its lines only from copies found elsewhere, never as new deposits: it MAY copy a line, or extend one it holds, up to the latest signed version of a copy that agrees with it, since holding earlier versions is no reason to trust later ones less or more; when the copies found fork, it takes only the versions they share, and reports the fork. Readers weigh these versions as they weigh that owner's history (section 6.4). The key log itself is added as section 6.4 says, and no version needing a nullified key is added (section 6.4).

**Versions held stay.** Nothing that a host or a thief can produce leads to removing a version an archive holds; only a takedown does (section 13), and, for a key log, a fork (section 6.3). A version let in against this section that is not signed is reported, and never shown as a version of the line. Since OCFL versions cannot be skipped, the owner's own version of that number can then never be added there: that archive's copy is one side of a fork of the line, and the owner continues the line in another archive.

### 7.6 Integrity

Integrity rests on OCFL digests: every file is fixed by its SHA-512 digest in the inventory, every inventory by its checksum file, and every member of a collection by a pin (sections 4 and 8). Digests show that files were not changed, signatures which owner's keys signed them; neither shows who wrote them or when (sections 7.2 and 15.1).

**Open questions.**

- The field names and the format of signature files (#55).
- Fork records, healing and nullified keys, provisional (section 6.3; #58).

## 8. Collections

A <dfn>collection</dfn> is an object of kind `collection` (section 4) whose versions hold a list of members, `members.json`. Each <dfn>member</dfn> is a line (section 7) of a document or of another collection, in any archive, pinned (section 4). A collection is a line like any other, signed by its owner (section 7), its <dfn>curator</dfn>; what it contains changes only by a new version.

### 8.1 Catalogues and selections

Collections are of two types, which treat the versions of their members differently; `type` in `members.json` states which.

- A <dfn>catalogue</dfn> keeps objects whole and is impartial about their versions. Each member pins an object with all its versions up to the pin, and the catalogue may follow it as it grows (section 8.3): the owner of each member decides what its versions are.
- A <dfn>selection</dfn> vets particular versions: a journal the version it accepted, a digest or a review journal the version it reviewed, a reading list the version it recommends. Each member pins a revision set (section 8.4); earlier and later versions of the same member are not part of the selection unless its curator adds them, by a new version of the selection.

Both types may have collections as members (an archive of archives, a selection of issues).

**An archive's collections.** An archive that makes collections does so as an owner, with a key log like any other (section 6). Its <dfn>main catalogue</dfn>, named by `mainCollection` in its discovery document (section 3.1), is a catalogue of the documents of the lines its owners write in the archive, not of the copies it holds. It MAY also keep a catalogue of the lines it holds as copies (section 11). A selection is kept by the owner of the body that vets (a journal, a review journal), which also owns the accepted copies the selection keeps (section 9).

### 8.2 The member list: members.json

Every collection version MUST contain, besides the files of section 4.1, `members.json`, and no other files of its own, with:

- `format`: `"opensheaf-collection/0.1"`;
- `type`: `catalogue` or `selection`;
- `members`: the list of members, in the order in which they are presented. This order is authoritative: presentations MUST present members in it.

It MAY contain `order`, the rule by which tools maintaining the collection place members: `manual`, the default (tools append new members and never reorder); `issued-desc` or `issued-asc`, by the members' `Issued` date (section 4.4), then their `Available` date, members with neither last, ties broken by `name` and then `owner`, so that the result is reproducible.

Each member MUST have:

- `kind`: `document` or `collection`;
- `name` and `owner`: its line (sections 5 and 6), by which copies are found (section 12) and checked against its owner's signatures; never a label (section 3.1) or a location;
- `at`: a non-empty list of base URLs where copies of the line may be found, also of one URL: equal hints, which need no signature (section 3), read as the `at` parameter of a `sheaf:` URI (section 12). They locate copies of the member's own line, mirrors included (section 11), never a branch of it (section 9).

Each member MAY have `doi`, the version DOI, and `conceptDoi`, the concept DOI, of the member; and `cite`, a cached citation, not authoritative, so that the collection can be read and ordered without resolving its members, also when they become unavailable: `title`, `creators` (a list of names), `year`, and `issued`, the member's `Issued` date.

### 8.3 Members of a catalogue

Each member of a catalogue MUST have `version`, the object version pinned, and `inventorySha512`, the SHA-512 digest of its inventory file: a pin (section 4), which fixes the object with all its versions up to that one. It MUST NOT have `revisions`.

A member MAY have `follow`, `"latest"`: a setting of the curator, not a floating reference. A followed member pins the latest signed version of its line (section 7.3) when the collection version was made; a member without `follow` keeps the version its curator pinned, which MAY be earlier, until the curator changes it. A tool maintaining the catalogue reads the member's archive (its discovery document or feed) and, when a followed line has a new signed version, writes a new collection version pinning it, whatever that version holds (a new document version, a description, a notice, a withdrawal): a catalogue does not judge the versions of its members. A tool follows only a signed version that extends the version pinned; a copy that does not is a fork of the line (section 7.4), which it reports, keeping the pin.

A withdrawn member stays, and presentations show its withdrawal (section 13.1), also one made after the version pinned. Presentations show the current version of each member as read from the history of the version pinned (section 4.2), not from later versions of its line: a pin that is not followed is the curator's choice.

### 8.4 Members of a selection

A <dfn>revision</dfn> is a document version of a member as a selection vetted it, pinned by the object version that held it when it was vetted. A <dfn>revision set</dfn> is the revisions of one member vetted by a selection: usually one, more after a correction is accepted.

Each member of a selection MUST have `revisions`, its revision set: a non-empty list, in the order of the member's history (section 4.2), no two revisions with the same `documentVersion`, each with:

- `documentVersion`: the document version vetted;
- `version`: the object version vetted, which holds that document version; when several do, the last of them when the revision was vetted, which is its entry in the history (section 4.2);
- `inventorySha512`: the SHA-512 digest of that version's inventory file;
- `doi`, OPTIONAL: the version DOI of that document version.

A member of a selection MUST NOT have `version`, `inventorySha512` or `follow`. The revision presented as the selection's is the last of the list.

A revision pins what was vetted, and keeps its pin in later versions of the selection. Descriptions and notices added later by the member's owner are not vetted by the selection, and presentations that show them SHOULD say where they come from. If the member's owner withdraws it, its revisions stay vetted, and presentations show the withdrawal as section 13 asks, saying that it comes from the member's owner.

Tools MUST NOT change revision sets on their own. Adding a revision (a corrected version accepted after review), removing one, or adding or removing a member is a new version of the selection, made by its curator, whose deposit (section 4.1) records who and when, with a message saying what was decided.

A selection MAY also keep its own copy of a revision it vetted, an accepted copy, which is a branch of the member's line under the selection's owner, and lists it as a member (section 9).

### 8.5 Pins and statuses of members

Every member is pinned: a collection version states exactly which object versions it contains, whole objects up to a version in a catalogue, revisions in a selection. Since a pin fixes an inventory, which fixes every file and earlier version, a collection version fixes everything it contains, also across archives: collections are hash trees, and pins cannot form cycles. A pin fixes one history: a fork of a member's line found later (section 7.4) does not change the member, and is reported.

A collection pins only signed versions (section 7.3), never a draft (section 10). The `kind`, `name` and `owner` of a member are those of the `object.json` of every version pinned, and the `documentVersion` of a revision is the one its pinned version holds.

**Members of other archives.** A member may be kept in another archive. Nothing is copied: it is resolved from its `at` as section 12 says, and any copy whose bytes match the pin will do. A reference, a pin without a copy, needs no permission. An archive that also keeps a copy keeps it as a mirror (section 11) or a branch (section 9).

**Statuses.** A member, or in a selection each revision, is, as read by a verifier (section 14):

- **verified**, when a copy of the version pinned is found, matches the pin, and is signed (section 7.3);
- **mismatch**, when a copy is found and does not match the pin;
- **unchecked**, when the version pinned is unchecked (section 7.3), shown with its status until the key log is found;
- **not a version** (section 7.3): the collection pinned what it MUST NOT;
- **unavailable**, when no copy is found;
- **removed**, when no copy is found and an archive holds a tombstone of the line (section 13.3).

### 8.6 Description and rights

**Description.** A collection version's `datacite.json` (section 4.4) has `resourceTypeGeneral` `Collection`, and MUST have in `relatedIdentifiers` a `HasPart` relation to the version DOI of each member of a catalogue (its `doi`) and of each revision of a selection (the revision's `doi`) that has one; members without a DOI are listed only in `members.json`. Members never name the collections that include them (section 4.4).

**Document versions.** A collection makes a new document version exactly when its member list changes (section 4.2); `object.json` of a collection has none of the fields of a document (section 4.3).

**Rights.** A collection version holds only metadata, placed under CC0 (section 15.6), and its `rightsList` SHOULD say so. The licence of a collection never extends to its members.

**Open questions.**

- Whether `follow` applies to every object version of a catalogue or only to its document versions, so that a catalogue with followed members can still have description-only versions, notices and a withdrawal (#45).
- What counts as a change of the member list: every change of `members.json` (`cite` and a reorder included), or of the members and pins only (#27).
- Ordering by `Available` without resolving members, which `cite` does not cache (#27).
- Which status a member has when the checksum file of its inventory is missing or wrong (#48).
- What a collection may state about its members (volume, acceptance, the journal's own DOI, a retraction by the journal) (#40).

## 9. Branches and accepted copies

A <dfn>branch</dfn> is a line of another owner that continues a work from a signed version of another line, its <dfn>branch point</dfn> or <dfn>parent version</dfn>: a co-author carrying the work on, the successor of an ended owner (section 6.4), a journal keeping the version it vetted. It has the work's genesis record, and so its name, or after a clash another name of the same record (section 5.3). It is a new object, with its own identifier `sheaf:<name>:<owner>` (section 4), holding the branch point and its own versions, never the parent's other versions. An originator never owns a branch of its own work (section 5.3).

### 9.1 The parent: parent in object.json

Every version of a branch MUST have in `object.json` (section 4.3) `parent`, its branch point, with:

- `owner` and `name`: the line of the parent version;
- `objectVersion` and `inventorySha512`: the parent version and the SHA-512 digest of its inventory file, a pin (section 4);
- `documentVersion`: the document version it holds;
- `url`, which it SHOULD have: the URL of that object version, `<storage root URL><path>/<version>/`, where `<path>` is the parent object's path in the layout of that storage root (section 3.2). It is a hint (section 3), used in resolution (section 12), and MAY point to a copy of the parent's line kept beside the branch (section 9.5).

The branch's `owner` MUST differ from `parent.owner`. Only a signed version is branched (section 7.3).

### 9.2 The first version and its evidence

The first object version of a branch holds exactly the files of the parent version, the genesis record included, except its `datacite.json`, its `object.json` and its own evidence; the branch's own `datacite.json` and `object.json`; and the <dfn>evidence</dfn> of the branch point, as files of its content:

- `parent.inventory.json`: the inventory of the parent version;
- `parent.object.json`: its `object.json`;
- `parent.signatures/`: the parent owner's signature files of the parent version, named as in its witness folder without the `<version>/` folder (`parent.signatures/signature-<k>.json`, section 7.2), with the witnesses kept beside them, if any (timestamps); other witnesses of the parent version (a third party's signature) MAY be kept with them;
- `parent.chain/`, when the parent is itself a branch: the parent version's own evidence, so that the grandparent's is at `parent.chain/parent.inventory.json`, the great-grandparent's at `parent.chain/parent.chain/parent.inventory.json`, and so on back to a version of the originator's line.

Every file copied is copied byte for byte, and never re-serialised or replaced. A branch MUST hold `parent.signatures/` at every branch point, and `parent.chain/` when its parent is a branch. The evidence is covered by the branch's own inventories and signatures; with the genesis record it forms the branch's identity files (section 4.1). The key logs that the evidence needs are kept beside every copy of the branch, never in it (section 6.5).

### 9.3 Checking a branch

The evidence shows, without access to the parent's line, that a branch point is the parent owner's. A branch point is consistent when:

- **the name:** the branch's `name` and `parent.name` are names of `genesis.json` (section 5.2), and the branch's `name` is `parent.name` unless it was renamed after a clash, by a greater algorithm number (section 5.3);
- **the pin:** the SHA-512 digest of `parent.inventory.json` is `parent.inventorySha512`, and its `head` is `parent.objectVersion`;
- **the files:** every file of the head state of `parent.inventory.json`, `genesis.json` included, except `datacite.json`, `object.json` and the parent's evidence, is present at the same logical path with the same digest; no other file is present besides the branch's `datacite.json`, `object.json` and evidence; and `parent.object.json` has the digest of `object.json` in that state;
- **the parent:** `parent.owner`, `parent.name` and `parent.documentVersion` are those of `parent.object.json`; the branch's owner is neither the parent's owner nor the originator; and either the parent's owner is the originator and `parent.object.json` has no `parent`, or it has one;
- **the signatures:** the parent version is signed (section 7.3), by the signature files of `parent.signatures/` against the parent owner's key log kept beside the branch, or vouched for by a signed version of the parent's line that the verifier finds; or it is unchecked;
- **the chain:** when `parent.object.json` has a `parent`, `parent.chain/` holds that evidence, each file with the digest `parent.inventory.json` records for it, and it passes these checks in turn, level by level, up to the originator's line.

A chain is finite, since each level is fixed by a digest in the level below. Verifiers MAY bound the depth they follow, and report where they stop; a branch point checked only down to that bound is unchecked.

**Verdicts.** A branch point is, in this order:

- <dfn>inconsistent</dfn> when a check fails, a parent version is not a version (section 7.3), or the parent version, resolved, does not match the pin;
- <dfn>confirmed</dfn> when the parent version, at every level, is signed;
- otherwise <dfn>unchecked</dfn>: consistent, but a parent version is unchecked.

The verdict of a branch is the weakest of those of its branch points. Verifiers report apart whether the parent's line is found, unavailable or removed (section 13), and whether it is withdrawn.

**Ended owners.** A branch point stays confirmed when its parent's owner ends, is tainted or heals afterwards, since signatures stay good; readers weigh it as they weigh that owner's history (section 6.4). A signature naming an ending version is invalid (section 7.3), and cannot sign a parent version.

### 9.4 Later versions and moving the branch point

The later versions of a branch are its owner's, signed like those of any line (section 7). They MUST keep the identity files unchanged, byte for byte, until a version that moves the branch point.

**Moving the branch point.** A branch MAY take as a new branch point a later version of the same parent line (a journal vetting the authors' corrected version): with the same `owner` and `name`, a higher object version, and a document version later than the previous branch point's in the history of the new parent version (section 4.2). A parent version holding the same document version (a DOI added) is not a new branch point; a branch point never moves back and is never dropped. The version whose `parent` differs from the one before holds exactly the files of the new parent version with new evidence, and is checked as a first version is (section 9.3), and also for continuity: the two parent inventories have the same `id`, every entry of `versions` of the previous one is equal, as a JSON value, to the entry of the same version in the new one, and every digest in those entries is in the manifest of the new one. The branch's own notes and notices then lose their files (#57).

**Numbering.** The first version of a branch holds the document version of its branch point. Provisionally, later versions continue from it without gaps (section 4.2), a version that moves the branch point taking the next number, while `parent.documentVersion` keeps the parent's (#57).

**Naming.** A branch is named as section 5.3 says. When the line it would take is its owner's branch of the same parent line, and the new branch point is later in that line's history than that branch's current one, the owner moves that branch's branch point instead; otherwise the new branch is renamed.

### 9.5 Continuing another owner's work

A line is not handed over. When another owner continues the work (an author leaving an institution whose line it was, a journal handing a report to its referee), the new owner makes a branch, and the previous owner MAY add a notice to its line pointing to it. An owner moving its lines to another archive hands nothing over: they stay its lines (section 6.5).

A branch holds none of the parent's earlier versions. An owner who wants them at hand keeps beside the branch a copy of the parent's line (section 11), at the parent's identifier, with its signatures and key log.

### 9.6 Accepted copies

An <dfn>accepted copy</dfn> is a branch kept by the owner of a selection (section 8.4) from a revision it vetted. Selections that keep copies of the same document MUST have different owners, also in one archive, so that their accepted copies are different lines, never renamed against each other. The later versions of an accepted copy are acts of the selection's curator (a corrected version accepted, by moving the branch point; a notice; a withdrawal); the authors' later versions change nothing in it.

The selection lists the accepted copy as a member; it MAY also list the original revision set. An accepted copy is not a mirror: a location holding only it is never given in `at` for the parent's line (section 8.2).

A version the selection makes itself, such as a typeset version of record, is a later version of its accepted copy, with the selection as `publisher`, the authors' `agreement` (section 4.3), and relations to the authors' versions (section 4.4). A branch carries versions of the same work; a derived work (a translation, a review, a collected edition) is a new object, with its own genesis record and a relation to its source.

### 9.7 Description and rights

**Description.** A branch's `datacite.json` has as `publisher` its owner, or for a selection the body behind it, and keeps the relations of the parent version. Its first version, and every version that moves its branch point, SHOULD link the parent version with `IsIdenticalTo`: its DOI if it has one, otherwise `parent.url` as a `URL`.

**Rights.** A branch needs only the right to redistribute its parent versions, and the files it copies keep their licence; a copy of the parent's line beside it needs the right to redistribute every version copied (section 11). The evidence is metadata, under CC0 (section 15.6).

**Open questions.**

- The numbering of document versions on a branch: continued from the branch point (provisional), or numbered from it (3.1, 3.2), which makes `documentVersion` more than an integer; `/v<n>` of a `sheaf:` URI follows it (#57).
- Moving a branch point when the branch has files of its own (of its notes, a withdrawal, a version of record): probably a merge keeping both, with evidence that tells them apart (#57).
- The field and folder names of the evidence (#55).

## 10. Drafts and sealing

A <dfn>draft</dfn> is a sandbox for a work not yet sealed, on which nothing may rely. <dfn>Sealing</dfn> makes from a work, under a new genesis record (section 5), the first version of its originator's line (section 7); the work's other lines are branches (section 9).

### 10.1 Drafts

**Identifier.** A draft belongs to the reserved owner `draft`, never a name or an owner name (52 characters, section 5.2). Its identifier is `sheaf:draft:<id>`, where `<id>` is chosen by the archive, MUST match `^[a-z0-9]+(-[a-z0-9]+)*$`, and MUST have at most 64 characters (76 for the identifier). It MUST NOT be reused in the archive while the draft exists, and MAY be once the draft is gone. It is local, never resolved. A draft is at the path its identifier gives (`draft/<id>/` in the owner-name layout, section 3.2).

**Format.** A draft is a `document` or a `collection`, in the format of any object of its kind (section 4). It has no genesis record and no other identity files (section 4.1), and its `object.json` has no `name`, `owner` or `parent` (section 4.3). Its document versions are numbered by whoever keeps it, by the rules of section 4.2.

**A draft is its archive's alone.** A draft is never signed (section 7), pinned (sections 8, 9 and 12), copied out of its archive (section 11), indexed or named by a `sheaf:` URI (section 12). The archive keeps its drafts when it moves to another site (section 3). The discovery document does not list drafts in `objects`; it MAY list them apart, in `drafts`, as unfinished work on which nothing may rely, or not at all (section 3.1).

**A draft may change.** A draft is the only object that MAY be rewritten or deleted: the rule that object versions never change (section 4) does not apply to it, and a draft deleted leaves no tombstone (section 13).

**Content.** A tool MAY read any object and recreate its files in a draft, as far as their licences allow.

### 10.2 Sealing

**When.** A work is sealed before a version of it first leaves its owner's hands: shared privately (submitted to a journal, sent to a co-author) or published. Sealing is done at the owner's request; tools SHOULD seal only at the owner's request, never as a side effect of another operation.

**What.** An owner tool seals a work by writing its genesis record (section 5.1), with the owner as `originator`, and making a new object: the line `sheaf:<name>:<owner>`, at its path in the storage layout (section 3.2), whose first version holds the genesis record and the work as document version 1 (section 4.2), and is signed by the owner (section 7.1). If the line is taken, the tool draws a new nonce (section 5.3).

**Drafts stay outside the line.** A work may be sealed from a draft or from files outside any archive. The versions of a draft are never part of the line sealed from it, and nothing in the line refers to them.

**Open question.** Whether and how drafts are shared before sealing (among co-authors, with a journal under review), and how an archive serves them, which bears on when a work must be sealed (#29).

## 11. Copies and mirrors

A <dfn>copy</dfn> of a line is its object as held in one storage root; a <dfn>mirror</dfn> is a copy kept in an archive where the owner of the line does not write, which is the archive's policy (section 3). Nothing marks a mirror: it is listed in `objects` like any line (section 3.1), and the rules of every copy apply to it. Whoever keeps mirrors of other owners' lines, or indexes of them (section 12), is a <dfn>custodian</dfn>.

### 11.1 Mirrors

**What a mirror holds.** An archive MAY keep a mirror of a line written elsewhere: the object's versions up to the latest signed version of the copy it copies (section 7.3), with their inventories, files and witnesses, byte for byte, at the path its layout gives the line's identifier (section 3.2), and beside it the key logs its signatures need (section 6.5). Files of the witness folder that are not witnesses need not be copied (section 7.2): not copying them is not removing them. When a copy holds, under the same name, a witness file other than the mirror's, the mirror keeps its own and reports the other.

**How a mirror grows.** A mirror is the same line, signed by its owner, never a new one. It MUST NOT be changed except by adding the owner's signed versions as section 7.5 allows, from a copy that agrees with it (section 7.4); by adding witnesses (section 7.2); for a key log, by the replacements at a fork (section 6.3); or by a takedown (section 13). It keeps every version it holds (section 7.5). A copy that does not agree with it is a fork of the line: the archive keeps the side it holds, and reports the other (sections 5.3 and 7.4). The lines of an ended owner are added only in this way, from copies found elsewhere (section 7.5).

**Elsewhere.** A mirror may be listed in a catalogue of copies, never in the main catalogue (section 8.1), and located by the `at` of collection members (section 8.2). A copy of a parent's line kept beside a branch is a mirror (section 9.5); an accepted copy is a branch, not a mirror (section 9.6). Drafts are never mirrored (section 10.1).

### 11.2 Rights

An archive MUST NOT keep a mirror unless the licences of every object version it copies (`rightsList`, section 4.4, which a description-only version may change) allow redistribution. A copy keeps the licences of what it copies. A copy of a parent's line beside a branch follows this rule for every version it copies (section 9.7). Key logs, inventories, signature files and the other metadata are under CC0 (section 15.6), and are copied freely; a reference, a pin without a copy, needs no permission (section 8.5).

**Open questions.**

- Whether a copy MAY stop before the latest signed version of the copy it copies, at a pinned version, so that a custodian keeps exactly what it pins or what the licences allow (#39).
- Copying by the agreement of the rights holders, besides the licences, recorded minimally (#39), and which licences allow redistribution (#34).
- What a custodian promises to keep (all the lines of an owner, the members of a collection, the revisions a selection vets), and where it says so (#54).
- Whether a custodian follows a takedown of a line it mirrors (section 13).

## 12. Identifiers: sheaf: URIs, resolution, indexes

Lines, versions, pins, works and owners are written as `sheaf:` URIs. A <dfn>resolver</dfn> is a program that finds and checks what a `sheaf:` URI names; a <dfn>gateway</dfn> is a resolver serving web links (section 12.6).

### 12.1 sheaf: URIs

Where `<name>` is a name (section 5) and `<owner>` an owner name (section 6):

```
sheaf:<name>                                  the originator's line
sheaf:<name>:<owner>                          the line of that owner
sheaf:<name>:*                                the work: all its lines
sheaf:<name>[:<owner>]/v<n>                   document version n of the line
sheaf:<name>[:<owner>]/v<n>?sha512=<digest>   one object version holding it
sheaf:<owner>                                 an owner: its key log
sheaf:<owner>/v<n>?sha512=<digest>            a version of its key log
```

**Syntax.** The parts are, in this order: `sheaf:` and the name; OPTIONALLY the <dfn>owner part</dfn>, `:` and an owner name, or instead `:*`; OPTIONALLY `/v` and a positive integer without leading zeros; OPTIONALLY `?` and parameters `key=value` joined by `&`, with at most one `sha512`, only after a version, whose value is an inventory digest as in a pin (section 4), 128 lowercase hexadecimal digits, and at most one `at`, after `sha512` if both are present. Only the value of `at` is percent-encoded; no fragment is defined. The scheme, the name, the owner name, `v`, the digest and the parameter names are lowercase, and a resolver MAY fold uppercase letters in them; the value of `at` is case-sensitive. A resolver ignores parameters it does not know.

**The owner.** Without an owner part, a URI names the originator's line (section 5.3), read from the genesis record every copy carries; never the latest or most authoritative line, so a branch is always written with its owner part. An owner is the originator of its own genesis record, so `sheaf:<owner>` names its key log.

**The work.** `sheaf:<name>:*` names every line of the work (section 12.4). It takes `at`, but a resolver rejects it with a version or `sha512`, since every line has its own document versions.

**The version.** `/v<n>` is a document version of the line (section 4.2, also on a branch), or for a key log an object version. It names only signed versions (section 7.3) whose `object.json` has the URI's name and the line's owner: a branch names only its own versions, from its branch point, and drafts are never named (section 10.1). Without a digest, it names the object version holding n that the history of the line's latest signed version lists (section 4.2), or without `history` the last signed one holding n; what it names may change as the line grows.

**The pin.** With a digest, the URI names exactly the object version whose inventory file has that digest. Citations of a fixed version SHOULD carry the digest.

**The hint.** `at` gives the base URL of an archive where a copy is expected, which a resolver tries first: an `https` URL ending with `/`, every character outside the unreserved characters of RFC 3986 percent-encoded, decoded once (`sheaf:<name>/v3?sha512=<digest>&at=https%3A%2F%2Fauthors.example.org%2F`). It is not part of what the URI names.

**Canonical form.** The canonical form has complete parts (section 12.2), lowercase where case is folded, no owner part when the owner is the originator, the genesis name (section 5.2) with `:*`, and no `at` or unknown parameters. Two URIs name the same thing when their canonical forms are equal byte for byte, which may need a copy of the genesis record to decide. Files record `sheaf:` URIs in canonical form (`keyLog`, section 7.2; relations, section 4.4).

### 12.2 Short forms

For people, the name and the owner name MAY be shortened to a prefix of at least 8 characters (`sheaf:lvfmiq2z:iztwg6bj/v3`); a part of 52 characters is complete. A resolver expands a short form among the lines it knows that pass the checks of section 12.3. The candidates are the lines whose name and owner name start with the parts given (without an owner part, the originators' lines; with `:*`, every name starting with the name part, whose work is then searched for, section 12.4). If they all have the same owner, the short form names the one whose first object version of that owner has the earliest `created` in its inventory, compared as instants; otherwise (several owners or genesis records, or a tie), it is ambiguous, and the resolver MUST NOT choose but lists the candidates with their full forms and originators.

Expansions may differ between resolvers and over time, so every file defined by this specification MUST use complete parts. A resolver SHOULD show the full form of what it resolved; landing pages and citation metadata SHOULD give the full form, and MAY add a short one. A short form printed where it cannot be corrected (a paper, a slide) SHOULD have at least 16 characters in each part.

### 12.3 Resolution

**Where to look.** A resolver tries, in any order, the locations it has: the URI's `at` first, the `at` of a collection member (section 8.2), a branch's `parent.url` (section 9.1), the indexes it knows (section 12.5), its user's configuration. At an archive it reads the discovery document, finds the line in the indexes or in `objects`, and fetches `<storageRoot><path>/<version>/inventory.json`, `<path>` being given by the archive's layout (section 3.2). The parent version of a branch is fetched at `parent.url` and otherwise found as any version of `sheaf:<parent.name>:<parent.owner>`.

**Checks.** Every copy found is checked: the URI's name is a name of its `genesis.json` (section 5.2); its `object.json` has that `name` and the line's owner (the owner part, or the originator); its versions are signed (section 7.3), against the key log kept beside it (section 6.5) or a longer copy found elsewhere. For a pin, the inventory file has the digest and the version holds document version n (for a key log, is object version n); a copy that does not match is reported as a mismatch (section 8.5). A copy that passes is a copy of the line, wherever found. Unchecked versions and versions that are not versions (section 7.3) are reported with their status and location, and never resolved to.

**Copies, forks and ended owners.** Since a copy that stops early looks complete, a resolver uses the latest signed version among the copies it found that agree (section 7.4), and says where it found them. A fork of the line (section 7.4) is reported with the status of each side; the resolver uses only signed versions and does not choose between signed sides. A resolver reports an owner that has ended, is tainted or has healed (section 6.3), with any successor, its own or named by its keeper (section 6.6), and never follows a successor by itself.

**Tombstones.** A tombstone (section 13) is not signed: a resolver that meets one keeps looking, and when it finds a copy that passes the checks, reports the copy and the tombstone.

**External records.** A deposit with an external service (`external`, section 4.3; appendix A) or a software archive snapshot is a witness (section 7.2), not a copy: it holds no inventory, so it is never checked against a pin and resolves nothing; a resolver MAY report it as a place where the files may be found. A snapshot holding an archive's storage root (an archive kept in git) is read as that archive.

### 12.4 Searching for a work

Resolving one line needs no search (the originator's line is always named by algorithm 0). But the lines of a work may carry any of the 16 names of its genesis record (section 5.2). To find them all (for `:*`, or a search by work), a resolver obtains the genesis record from any copy or index entry found under the name, checked against it; computes its 16 names and looks each up in the indexes it knows; keeps only the entries whose genesis record is byte for byte the one obtained, discarding others as collisions (removed entries without a genesis record are listed apart, as removed lines of those names, and removed entries that kept it are marked removed); and keeps only the lines that pass the checks of section 12.3 and hold back to the origin: the originator's line signed by its originator, and branches whose branch points are confirmed (section 9.3). A reused genesis record thus yields no line (section 5.4), and no hash is assumed free of collisions. If several genesis records have the URI's name, the URI is ambiguous: the resolver lists them with their originators.

### 12.5 Indexes

An archive SHOULD keep three <dfn>indexes</dfn> of its objects, by name, by owner and by inventory digest, next to its discovery document, declared in its `indexes` (section 3.1). A custodian (section 11) or a resolver MAY keep them for many archives at a base URL of its own, declared in `indexes.json` there. Indexes are maps, not witnesses: what they lead to is checked (section 12.3).

**Files.** An index is a folder of files `<p>.json`, where `<p>` is a prefix of the key, each a JSON object with `format`, `"opensheaf-index/0.1"`; `index`, its folder; and `entries`, every key starting with `<p>`. A file without entries is omitted, so a missing file means no entry. The declaration (`indexes` in the discovery document, or `indexes.json`, with `format` and `indexes`) maps each index kept to the length of its `<p>`, from 2 to 4 characters.

- `names/`, by name: for each object with a genesis record, `name`, `owner`, `id` (section 4), `status`, `originator` (for an owner object, itself), `genesis` (the text of `genesis.json`, whose UTF-8 encoding is exactly its bytes, so that works are searched for from indexes alone) and, if any, `label` (section 3.1);
- `owners/`, by owner name: for each owner with lines in the storage root, `owner` and `names`, the names of those lines, its key log among them when kept there (section 6.5);
- `sha512/`, by inventory digest: for each sealed object version, `inventorySha512`, `id`, `version` and `status`.

**Content.** An archive's indexes list every object with a genesis record and every sealed version of it, never drafts. `status` is the object's, `active` or `withdrawn`, or `removed` after a takedown (section 13): a tombstoned object keeps its entries in `names/` and `sha512/`, of which those in `names/` MAY drop `originator` and `genesis`, while a takedown removes the name from `owners/`, and the entry once it lists none. In indexes kept for several archives, every entry has `at`, the base URL of the archive serving the copy, and `owners/` has an entry for each owner and archive.

**Lookups.** A resolver looks a line up in `names/`, starting from `at`, keeping the entries whose `owner` matches the owner part, or without one, whose `owner` is their `originator`; a removed entry without `originator` is matched against the originator of any copy of the genesis record, or reported as a removed line of that name, originator unknown. It looks a pin up in `sha512/` and an owner's lines in `owners/`. At an archive without indexes, it MAY read `objects` of the discovery document and fetch `genesis.json` and `object.json` from the objects.

### 12.6 Gateways

A gateway serves a URI at its base URL followed by the URI unchanged (`https://opensheaf.org/sheaf:<name>/v3`, provisionally, #35); gateway links are written in full, since a relative link starting with `sheaf:` is read as a URI. A gateway:

- MUST answer with a page (200) showing what it resolved, or a temporary redirect (302, 303 or 307) only to a copy it has checked (section 12.3); it MUST NOT redirect permanently (301, 308), and MAY cache its result only for a URI with a digest;
- MUST show where what it resolved was found, that a URI without a digest resolves to the latest copy it found, not necessarily the owner's latest, and when the owner has ended, is tainted or has healed, with any successor;
- MUST NOT serve an archive's files from its own origin, but redirects or links to the archive (section 15.3);
- MUST fetch on its users' behalf only `https` URLs at public addresses, with limits on size and time.

**Open questions.**

- Registering the scheme `sheaf` with IANA, as a provisional scheme (RFC 7595), until which DataCite records `sheaf:` URIs as `URL` (section 4.4) (#36).
- Whether the project runs a gateway, on which domain, and whether a domain used only for resolution drops `sheaf:` from the path, as `https://doi.org/` drops `doi:` (#35).
- Who keeps indexes of many archives, so that a line can be found once its archives have gone, and how resolvers find them (#13, #20).
- Whether an external record can resolve a pin if it also holds the version's inventory file, its checksum file and its signature files (a Zenodo record version uploading them, a member's `swhid`) (#22).
- Whether a tombstone in one archive should stop resolution at copies elsewhere (section 13).
- The numbering of document versions on a branch, which `/v<n>` follows (section 9; #57).

## 13. Withdrawal, takedown and tombstones

An owner withdraws a line, which keeps its versions; an archive takes down an object, which leaves a tombstone. A draft is neither withdrawn nor taken down: it is deleted, and leaves no tombstone (section 10.1).

### 13.1 Withdrawal

A document or a collection is <dfn>withdrawn</dfn> by a description-only version (section 4.2) whose `object.json` has `status` `withdrawn` and `withdrawal` (section 4.3), and whose `datacite.json` has `withdrawal.date` as `Withdrawn` (section 4.4). The status is the line's, read from its latest signed version (section 7.3), whatever document version that holds; a single document version is retracted by a notice (section 4.2). A branch or an accepted copy is withdrawn only by its own owner (section 9).

A withdrawn line keeps every version, signed, pinned and copied as before. Presentations showing a version of a line they know to be withdrawn MUST show the withdrawal, also when the version shown is earlier.

### 13.2 Takedown

A <dfn>takedown</dfn> deletes a sealed object, witness folder included, from an archive's storage root (with the folders the deletion leaves empty) and from its presentation files, and adds a tombstone (section 13.3). It is the only way an archive removes what it holds, besides the replacements of key-log versions at a fork (sections 6.3, 7.2 and 7.5), and every removal of a sealed object is one, whatever its reason: content that must not be served (by law, for a breach of rights, to erase personal data, section 15.5), or a line the archive stops keeping. It removes one object: others holding the same files, such as a branch holding its parent version (section 9), are taken down on their own.

**Owner objects.** A takedown of a line leaves in place the owner objects its copy carries (section 6.5). An owner object that an object of the archive needs is taken down only for itself: at its owner's request, signed by `threshold` keys of the latest version of its key log that the archive holds, or by law; for an ended or tainted owner (section 6.3), only at its keeper's request (section 6.6) or by law. An archive SHOULD also hear the keeper, when one is named, before acting on a signed request, which a thief can make. The owner's signatures in what the archive keeps are then unchecked there (section 7.3), and the tombstone stands in for the owner object in the rule of section 6.5.

**Returning.** A line taken down (an owner object found elsewhere, for instance) MAY return to the archive only from a copy holding the version its tombstone pins or, when that version is not signed, the latest signed version before it, added as section 7.5 says: it is the same line, not a reuse of its identifier (section 4), and its tombstone is dropped.

### 13.3 Tombstones

A <dfn>tombstone</dfn> is an entry of `tombstones` in the discovery document (section 3.1), one for each object taken down, with:

- `id`, `kind`, `name` and `owner`: those of the object (section 4.3);
- `genesisName`: the genesis name of its genesis record (sections 5.2 and 5.4);
- `lastVersion` and `inventorySha512`: its head when taken down, and the SHA-512 digest of that version's inventory file, a pin (section 4);
- `date`: the date of the takedown;
- `reason`: a plain text, which SHOULD NOT repeat what was taken down.

A tombstone is never removed, except when its line returns: it keeps the line taken (section 5.3), and `objects` never lists its `id`. It is not signed: a resolver keeps looking past it (section 12.3). A line, or a version of it no later than `lastVersion`, of which no copy is found but a tombstone is, is reported as removed (sections 8.5 and 9.3).

**Open questions.**

- Whether a tombstone in one archive stops resolution at copies elsewhere, and whether mirrors, branches holding the version taken down, indexes kept by others and gateways follow a takedown (#33, #39).
- The form of an owner's signed request for a takedown, and of a keeper's (#33).
- Whether a tombstone lists the inventory digests of every version taken down, so that a pin of a removed version is told from a pin that never named one; meanwhile the archive's `sha512/` index keeps them (section 12.5; #33).
- Whether a withdrawn line takes new document versions; whether and how it is reinstated; whether `withdrawal` stays in later versions; what a verifier reports for a pin of an earlier version of a withdrawn line; and how the line of an ended owner, which signs nothing, is withdrawn (#25).
- A retraction by a collection (a journal) of one of its members, distinct from a withdrawal by the member's owner (#40).
- Takedowns of single files or versions, should a later OCFL provide them (#32).

## 14. Verification

A <dfn>verifier</dfn> is a program that checks an archive, or an object with the key logs kept beside it, against this specification. It checks every requirement of sections 3 to 13 that the files decide, in the order of sections 14.2 to 14.6, each step using the results of those before; the rules are those of the sections cited. The discovery document, the indexes and presentation files are maps: a verifier checks them against the storage root, and never takes them as authoritative (section 3.1).

### 14.1 Findings

A verifier reports every finding with its place (the archive, an object, a version, a file), and does not stop at the first. A finding is:

- an <dfn>error</dfn>: a breach of a MUST or MUST NOT, except where this section makes it a warning. An archive or an object without errors <dfn>passes</dfn> verification;
- a <dfn>warning</dfn>: a breach of a SHOULD; a breach that the archive cannot repair, where this section says so; a check not made or not completed;
- a <dfn>result</dfn>, neither: the statuses of signature files, versions and members (sections 7.3 and 8.5), the verdicts of branches (section 9.3), forks of lines and of key logs (sections 6.3 and 7.4), ended owners and their successors (sections 6.3 and 6.6), withdrawals (section 13.1) and removals (section 13.3).

**Checks not made.** A verifier reading an archive over HTTP cannot list folders: it checks the objects the discovery document lists, and warns that it has not checked that the storage root holds no others, nor the files of witness folders whose names it cannot compute; one with access to the files checks them. A verifier MAY bound the depth of the chains and collections it follows (section 9.3), SHOULD bound the size of what it fetches (section 15.2), and warns where it stops.

### 14.2 Files and storage

The verifier checks:

- every JSON file this specification defines against its schema (section 2), formats (dates, URIs) included as assertions, which JSON Schema 2020-12 leaves optional: the discovery document, the files of every object version (`parent.object.json` and the files of `parent.chain/` included), the files of witness folders, the indexes, and a keeper's file when it reads one; a malformed file of a witness folder is a warning (section 7.2);
- that the storage root and every object are valid OCFL 1.1, with an OCFL validator or equivalent checks, leaving out the warnings validators give on the owner-name layout and witness folders (sections 3.2 and 7.2);
- that `ocfl_layout.json` names `storageLayout` with the parameters of section 3.2, and that every object is at the path its identifier gives there;
- the rules of section 4.1 in every object version, and that the inventory of each version folder is the inventory as of that version: its `head` is that version, and its `versions` are those of the head inventory up to it, equal as JSON values.

### 14.3 Key logs

The verifier checks the owner objects first, each from its first version (section 6): its genesis record and first `keys.json` (sections 5.1 and 6.1); that each version is signed (section 7.3) and none follows an ending version or a fork record, a version held against either being a warning, as for lines (section 14.4); `ended` and `successor`; and each fork record and healing version (section 6.3): that it is valid, each version it carries under the name its inventory digest gives, with its `keys.json` and checksum file against its inventory and its signatures against the version before, and that no version it supersedes is held beside it. It reports as results the latest version of each key log, the nullified keys, and ended, tainted and healed owners with their successors; when a keeper is named, it MAY check the link (section 6.6).

### 14.4 Objects

For every other object, the verifier checks:

- **its records:** the rules of sections 4.2 to 4.4 in every version and between versions (numbering, new versions, completion, `history`, notices), as far as the files decide them;
- **its identity:** the genesis record, the name and the identifier in every version (sections 4 and 5), and that the objects and tombstones of the archive with the same genesis name are its originator's line and branches of it (section 5.4);
- **its signatures:** the status of every signature file and version, and the latest signed version (section 7.3), against key logs kept beside it as section 6.5 asks. A key log missing, or shorter than the versions its signatures name, is an error, one taken down a warning (section 13.2); the signatures that need it are unchecked. A version that is not a version of its line is a warning (section 7.5);
- **a branch:** the verdict of each branch point (section 9.3), at its first version and at every version that moves it, with the continuity of section 9.4, and that the identity files are unchanged between them. An inconsistent branch point is an error, an unchecked one a warning; the branch's verdict, and whether its parent's line is found, unavailable, removed or withdrawn, are results. A rename whose algorithm number is not greater than that of `parent.name` is an error (section 9.3); one that neither the objects nor the tombstones of the archive justify, or not by the smallest number free there, is a warning (section 5.3);
- **a draft:** the rules of section 10.1, and that nothing in the archive pins it.

### 14.5 Collections

For each collection version, the verifier checks the rules of section 8 on `members.json` and its members. It resolves every member of the head version (every revision, in a selection) as a resolver does (section 12.3), and the members held in the archive in every earlier version; resolving the other members of earlier versions is OPTIONAL. The status of each member is a result (section 8.5). A member that is not a version is an error, and so is a mismatch of a copy held in the archive; any other status but verified is a warning.

### 14.6 The archive as a whole

The verifier then checks, against the objects:

- **the discovery document** (section 3.1): that `objects` lists every object of the storage root except drafts, each entry with the values its object gives (`status` that of its latest version that is signed or unchecked, section 7.3), with distinct labels; that `mainCollection` names a catalogue it lists; that `drafts` lists only drafts of the storage root, with their heads; and, a breach being a warning, that `owners` lists only owner objects it holds and `extensions` every extension its objects use;
- **the tombstones** (section 13.3): that each is well formed, with `id` the line of its `name` and `owner`; that no two have the same `id`; and that no object of the storage root, and no entry of `objects`, has the `id` of one;
- **the indexes** it declares (section 12.5): that every object with a genesis record and every sealed version has its entry, in the file of its prefix, with the values its object gives; that each tombstone has its entries in `names/` and `sha512/`, with `status` `removed`, and none in `owners/`; that no draft has one; and, with access to the files, that there are no other entries.

**Beyond the archive.** A verifier SHOULD check the copies it knows elsewhere (the sources of mirrors, members, parents, longer key logs): whether they agree (section 7.4), reporting a fork of a line with the status of each side and where each copy was found, and a later version of a key log (section 6.5). It SHOULD check the requirements of the profiles the archive declares (appendix A), the witnesses it finds and the extensions it knows, and warns of those it does not know (sections 2 and 7.2).

**Open questions.**

- Which status a member has when the checksum file of its inventory is missing or wrong (#48), and whether a mismatch at the member's archive falls through to mirrors (#37).
- Whether a pin fixes the bytes of the inventories of earlier version folders, which are compared here as JSON values only (#46); whether digests in OCFL files must be in lower case (#49).
- The parts of section 4.2 that the files do not decide: whether a version deposited out of order wrote `history` (#51), and when a document version is new (#23).
- How a verifier tells a licence from a rights statement in `rightsList` (#50), and which licences allow a mirror (#34), which is therefore not checked.
- What a verifier reports for a pin of an earlier version of a withdrawn line (#25).
- Fork records and healing, provisional (section 6.3; #58).

## 15. Security, privacy and rights

### 15.1 What the format protects

Pins and signatures make every copy checkable wherever it is fetched (sections 4 and 7); discovery documents, indexes, locations and tombstones are maps and hints (sections 3, 12.3 and 13.3). A host or a network therefore cannot forge a version, nor add one to another owner's line (section 7.5), nor make a valid line from a reused genesis record (section 5.4), nor take over a short form (section 12.2). It can withhold: serve an older copy, or a key log that stops before an end or a fork record, which looks complete (sections 6.5 and 12.3); and it can delete what it serves, never a copy held elsewhere (section 13).

Whoever holds `threshold` keys of an owner acts as that owner until they are nullified or the owner ends (section 6.3), and the format cannot tell what was signed before an exposure from what was signed after (section 6.4).

**Forks of a line.** A fork of a line whose sides are both signed (section 7.4) ends nothing by itself; whether to end is the owner's call. If the owner did not make both sides, its keys may have been exposed, and section 6.3 applies; if it did (two tools, a version made again), it continues from one side, and archives holding the other keep it (section 7.5).

**What a signature shows.** A good signature shows that a key of the owner's key log signed one object version and one key-log version (section 7.2); not who wrote the document (section 4.4), who the owner is (section 6.6), when it was signed, or that no later version exists.

### 15.2 Untrusted input

Every file a program reads is untrusted until checked, also in its own storage root. A program reading files (a verifier, a resolver, an archive copying a line, a tool recreating files in a draft):

- MUST NOT read or write outside the object, or outside the folder it writes into, whatever path a file gives (logical and content paths, the `path` of notes and renditions, entries of an archive file such as `sources.zip`, appendix A), and MUST NOT follow symbolic links; a path that breaks section 4.1 is never followed;
- SHOULD bound the size of what it fetches or unpacks, the number of objects, versions, files and members, the depth of chains and collections (section 9.3) and its time, and reports where it stops (section 14.1);
- MUST show the texts of these files (titles, abstracts, notes, reasons) as text, never as HTML, and SHOULD render their mathematics (section 4.4) with a renderer that runs no scripts and follows no links;
- when it fetches URLs found in files on behalf of others (a custodian, an index service), follows the rule of section 12.6 for gateways.

Deposited sources are code: a tool building renditions from sources it did not write SHOULD run the toolchain isolated, without shell escapes. MD5 (section 4.1) and SHA-1 (git) serve only comparison with external services, never integrity (section 7.6).

### 15.3 Serving and presentation

An archive does not vouch for the files of its objects (section 3). Its presentation files MUST NOT include files of objects, or pages of other archives, as HTML or scripts; they link to them. An archive SHOULD serve its storage root so that its files run no scripts in the origin of its presentation files: from another origin, or with `Content-Security-Policy: sandbox`. A gateway serves no archive's files (section 12.6).

### 15.4 Keys and secrets

Private keys, and other secrets (tokens of external services, the secrets of a review), MUST NOT be stored in an archive: in an object, a witness folder, a draft, presentation files, or the repository of an archive kept in git. Whatever an archive holds is public and copied.

### 15.5 Privacy

What an archive serves is public, its drafts included (section 10.1); a sealed version, its witnesses and the key logs beside it travel with every copy and branch, and never change.

- **Personal data.** Archives record only the personal data needed to describe and cite a work (section 4.4) and the depositor of each version (section 4.1), whose `address` SHOULD be a public identifier (an ORCID iD) rather than a personal e-mail address.
- **Owners.** An owner name is the digest of a record with a random nonce, and identifies no one. An owner is tied to a person only by what its versions say (`creators`, `user`, `agreement`), by keys it shares with another owner, and by its keeper, who alone confirms that link and can withdraw the confirmation (section 6.6), though `keeper` stays in the key log. An owner that must stay anonymous (a referee) SHOULD have its own keys and no `keeper`, and its versions SHOULD NOT identify the person.
- **Erasure.** Personal data is erased by a takedown (section 13.2), from that archive and its indexes only. The tombstone and index entries keep only names, owner names and digests, which identify no one (section 13.3); an archive kept in git also rewrites its history ([OpenSheaf archives in git](opensheaf-git-0.1.md), section 9).

### 15.6 Rights

**Metadata.** The JSON files this specification defines, inventories with their checksum files, fork records and the evidence of branches are metadata, texts of notes and abstracts included. Whoever writes them dedicates them to the public domain under CC0 1.0, so that they can be harvested and copied freely; an archive admits only owners that accept this. Files of notes (section 4.3) are content.

**Content.** The files of a document version are under the licence its owner states (sections 4.3 and 4.4); "All rights reserved" is allowed, since depositing grants readers access, not reuse. Copies and branches keep the licences of what they copy, and need the right to redistribute it (sections 9.7 and 11.2).

**Open questions.**

- Which licences allow a mirror, and how a verifier tells a licence from a rights statement (#34, #50); copying by the agreement of the rights holders (#39).
- Whether a takedown reaches mirrors, branches holding the files, indexes kept by others and gateways (#33).
- Private archives and drafts, anonymous referees and the secrets of a review (#29).
- Tying owners to ORCID iDs and domains beyond the keeper (#41).
- What a reader holding only one side of a fork of a key log can know, and whether nullifying keys from when an archive learns of it is enough against backdating (#55, #58).

## 16. Versioning of this specification

### 16.1 Versions

This specification is versioned MAJOR.MINOR.PATCH:

- a **major** version (1.0, 2.0) MAY make incompatible changes;
- a **minor** version (1.1, 1.2) only adds: every file valid under 1.x stays valid under 1.y, for y greater than x, with the same meaning;
- a **patch** version (1.1.1) corrects or clarifies the text, and changes no requirement.

Before 1.0, every minor version MAY be incompatible. A draft MAY change in any way; archives made with a draft are rebuilt when its version is final. Drafts are told apart by the date in the heading and by the changelog (section 16.2).

**In files.** Files record the version as MAJOR.MINOR only, since a patch changes nothing that is valid: in the name of every format (`"opensheaf-object/0.1"`), and in `specification` of the discovery document and of every `object.json` (sections 3.1 and 4.3).

**Readers.** A reader that finds a major version it does not know, or before 1.0 a minor version it does not know, SHOULD report it, and MUST NOT treat the files as valid. From 1.0, a reader that finds a later minor version of a major version it knows reads the files as of that major version, ignores the properties it does not know, and SHOULD report the version; it does not validate such files against the schemas of its own version (section 2).

**Publication.** The text of each version is published at `https://opensheaf.org/opensheaf-specification-<MAJOR.MINOR>.md`, with its schemas (appendix B), and is not changed once final, except by patch versions, listed in its changelog.

### 16.2 Changelog

- **0.1 (draft), 13 November 2026:** first version.
- **0.1 (draft), 13 to 18 November 2026:** revisions, and the proposal of PR #30 (names from genesis records, owners and key logs, lines, branches, `sheaf:` URIs, signatures), each listed in the changelog of the [reference text](reference/opensheaf-specification-0.1-full.md).
- **0.1 (draft), 18 November 2026, rebuilt (PR #30):** the text rebuilt concept by concept into a shorter whole, from the reference text. Decided in the rebuild: archives are named by no file, and `replicas` is dropped (section 3); external records are witnesses, not copies (section 12.3); index declarations name only `names`, `owners` and `sha512` (section 12.5); every removal is a takedown, and tombstones are required once an object is taken down (section 13); drafts are never withdrawn; key-log forks are recorded by fork records, which nullify the keys involved, and healed by the owner, versions of key logs being replaced only there (section 6.3, provisional, #58); findings are errors, warnings or results (section 14.1); security, privacy and rights rewritten (section 15); `licence` for documents only; logical paths exclude empty segments, a final `/` and `\` (section 4.1).

## Plan of the rebuilt text

Each part is rebuilt in turn, from the reference text and an audit of the concept, and agreed before the next. Sections 1 to 16 are rebuilt; the others are planned as follows, and read meanwhile in the reference text.


Appendices (the worked key log of appendix C creates its owner with two keys from v1): A. profiles (Zenodo, TeXmacs, website); B. JSON Schemas (with the new keeper schema); C. examples; D. rationale; E. references.
