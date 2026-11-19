# OpenSheaf: an open format for document archives and collections

*Specification, version 0.1 (draft), 19 November 2026. OpenSheaf is a common, open format for archives of scholarly documents and for collections of them, built on the Oxford Common File Layout (OCFL 1.1) and the DataCite Metadata Schema (4.7). The text is licensed under CC BY-SA 4.0; the JSON Schemas are dedicated to the public domain (CC0 1.0).*

> [!WARNING]
> **Draft.** Until version 1.0, any revision may change the format in incompatible ways. The text before its rebuild, with the changelog of every revision of the draft, is kept as the [reference text](reference/opensheaf-specification-0.1-full.md).

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

JSON means RFC 8259 JSON in UTF-8 without a byte order mark. URLs are absolute unless stated otherwise; a relative URL in a JSON file is resolved against the URL of that file. Digests are written in lowercase hexadecimal unless stated otherwise. DOIs are written bare (`10.5281/zenodo.123`), without a resolver prefix. Terms are defined where they are first introduced, written <dfn>thus</dfn>.

**Conformance classes.** An archive, an object or a program conforms to a class when it meets every MUST and MUST NOT of the sections listed for it:

- **archive:** sections 3 to 13 and 15;
- **collection:** section 8, with the rules on objects of sections 4 to 7;
- **owner tool**, a program that seals, signs or keeps an owner's key log: sections 5 to 7, 9, 10 and 15;
- **verifier:** sections 14, 15.2 (on untrusted input) and 16 (as a reader), with the rules it checks;
- **resolver:** sections 12 and 15.2 (on untrusted input), with sections 5, 6, 7 and 9.3 for checking names, signatures, key logs and branches; a gateway also follows the rules on gateways of section 12.

**Profiles.** An archive MAY also follow the profiles of appendix A (Zenodo, TeXmacs, website), and MUST list in its discovery document those it follows.

**Extensions.** An extension is a specification published apart, named by a URI (RECOMMENDED: the `https` URL where it is published), that records what this specification leaves open, so that tools aware of it can act on it. Its data is kept under `extensions`, keyed by the extension's name: in `object.json` (section 4), where the inventory and the pins fix it, or in `keys.json` (section 6), where the owner's signatures fix it, and for the first version of a key log in the genesis record of the owner, which its owner name fixes (section 5.1). An extension MUST NOT change the meaning of what this specification defines, nor relax its requirements: archives, objects and collections are read and verified without knowing any extension, and readers ignore extensions they do not know. The discovery document lists the extensions its objects use (section 3.1). The [timestamps extension](opensheaf-timestamps-0.1.md) is one.

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
- `objects`: every object of the storage root except drafts, each with `id` (section 4), `kind`, `name` and `owner` (sections 5 and 6), `head` (its OCFL head version), `inventorySha512` (the SHA-512 digest of the head inventory, as its checksum file states it) and `status` (`active` or `withdrawn`, the line's status, section 13.1), and OPTIONALLY a `label`.

It SHOULD contain `mainCollection`, the identifier of the catalogue of the archive's documents (section 8); `contact`, a URI; and `extensions`, the names of the extensions its objects use (section 2). It MAY contain `owners`, the owner names of the owners it hosts (section 6); `drafts`, the drafts it chooses to show, with `id`, `kind` and `head`, as unfinished work on which nothing may rely (section 10); `indexes`, which maps each index kept to the length of the prefixes of its files (section 12.5); and `feed`, the URL of an Atom feed of new object versions. It MUST contain `tombstones` once an object has been taken down (section 13.3).

The discovery document is rewritten whenever an object is added or changed. It is a map, not a witness: everything it states about objects MUST agree with the storage root, which verifiers check (section 14), and it lists what the archive holds, not every line an owner has elsewhere.

**Labels.** A <dfn>label</dfn> is a short readable name an archive MAY give a line it holds, for readable URLs on its website: it matches `^[a-z0-9]+(-[a-z0-9]+)*$`, has at most 64 characters, and is unique in the discovery document. It is the archive's choice, may change, and is not an identifier; permanent links use `sheaf:` URIs (section 12). Labels SHOULD be chosen by the depositor, not derived from the title.

### 3.2 The storage root

The <dfn>storage root</dfn> is an OCFL 1.1 storage root at the URL `storageRoot`, holding the archive's objects (section 4). Since OCFL allows in it only the folders that lead to objects, and extensions, it SHOULD be a dedicated folder (by convention `ocfl/`), and presentation files MUST NOT be placed in it. It MAY contain, as loose files, copies of the OCFL specification and of this one. Its storage layout is the one `storageLayout` names in the discovery document, which is authoritative. OCFL's `ocfl_layout.json`, OPTIONAL in OCFL, may name only a layout registered as an OCFL extension (OCFL 1.1, section 4.1), and is therefore present for the hashed layout only:

- **The owner-name layout**, `opensheaf-owner-name-storage-layout`, the default, defined here, and not registered as an OCFL extension. The object whose identifier is `sheaf:<name>:<owner>` (section 4) is at `<owner>/<name>/`, and a draft `sheaf:draft:<id>` at `draft/<id>/`; any other identifier is an error. An owner's object is thus at `<owner>/<owner>/`, and the folder of an owner holds its key log and every line of it in the archive, so that an owner moving elsewhere copies one folder. The layout has no parameters. The storage root MUST NOT contain `ocfl_layout.json`, whose `extension` would not be a registered extension name; it SHOULD contain instead the plain text file `opensheaf-owner-name-storage-layout.md`, which describes the layout, for instance as `Lines at <owner>/<name>/, drafts at draft/<id>/: the owner-name layout of the OpenSheaf specification 0.1, section 3.2`, as OCFL allows for documenting local extensions (OCFL 1.1, sections 4.1 and 4.5).
- **The hashed layout**, for large archives: OCFL's `0003-hash-and-id-n-tuple-storage-layout` with its default parameters (`sha256`, tuples of 3 characters, 3 tuples), which a configuration file, if present, MUST NOT change; the storage root MUST contain `ocfl_layout.json`, with `extension` `0003-hash-and-id-n-tuple-storage-layout` and a `description`. An object is at `<t1>/<t2>/<t3>/<encoded id>/`, where `<t1>`, `<t2>`, `<t3>` are the first three groups of three characters of the hexadecimal SHA-256 digest of its identifier, and `<encoded id>` is the identifier percent-encoded as the extension says (every character but `A-Z`, `a-z`, `0-9`, `-` and `_`, in lowercase hexadecimal, `%3a`), shortened, when longer than 100 characters, to its first 100 characters, `-` and the full digest; identifiers of lines are always shortened so (appendix C). Readers compute the path; they never decode it.

Archives SHOULD use the owner-name layout, unless one folder per owner or per name becomes impractical (tens of thousands of lines, fewer in a git repository). The layout is chosen when the archive is created and SHOULD NOT be changed: pins stay valid, since readers compute paths from `storageLayout`, but every URL into the storage root changes.

**Open question.** Registering the owner-name layout as an OCFL community extension, so that `ocfl_layout.json` can name it (#59).

## 4. Objects

An <dfn>object</dfn> is an OCFL 1.1 object in a storage root. Its <dfn>kind</dfn>, given by its `object.json` and never by its identifier, is `document`, one work (an article, notes, a thesis, a book) with its sources and renditions; `collection`, a list of members (section 8); or `owner`, the key log of an owner (section 6).

**Identifier.** The <dfn>identifier</dfn> of an object, its OCFL `id`, is `sheaf:<name>:<owner>`, the name of the work (section 5) and the owner name of its line's owner (section 6), which `object.json` records as `name` and `owner`. It names the line (section 7), in every archive. A branch is a new object with its own identifier (section 9); a draft is `sheaf:draft:<id>` (section 10). The identifier MUST be unique in the storage root, and that of a sealed object MUST NOT be reused there, also after a takedown (section 13).

**Versions.** An <dfn>object version</dfn> is an OCFL version of an object (`v1`, `v2`, ...): every change of the object makes one. Once made, no object version, and no file of the object's witness folder (section 7.2), is changed or removed, except: in a draft, which may be rewritten or deleted (section 10); and by a takedown, which deletes the whole object (section 13.2). A <dfn>document version</dfn> is a version of the work, a positive integer numbered by the owner of the line and recorded in `object.json` and `datacite.json`; it changes only when the document's own files change (section 4.2), so several object versions may hold one document version, with different descriptions or notices.

**Pins.** A <dfn>pin</dfn> is the pair (object version, SHA-512 digest of that version's inventory file, as its checksum file states it). An inventory records the digests of the files of its version and of every earlier one, and the `object.json` of every sealed version after the first records the digest of the inventory file of the version before (`previous`, section 4.3), so a pin fixes the object up to that version, the bytes of every earlier inventory included, in any copy. Collections (section 8), branches (section 9) and `sheaf:` URIs (section 12) refer to object versions by pins, and pin only signed versions (section 7).

### 4.1 Common rules

Every object MUST be a valid OCFL 1.1 object, and:

- its inventories MUST use the digest algorithm `sha512`; they MAY also record MD5 and SHA-256 digests in `fixity` (the Zenodo profile requires MD5, appendix A);
- every version directory MUST contain the inventory as of that version, with its checksum file, so that each version can be pinned and fetched on its own;
- version directories MUST NOT be zero-padded (`v1`, not `v001`);
- logical paths MUST be in UTF-8 and Unicode normalisation form C, and MUST NOT begin or end with `/`, or contain empty, `.` or `..` segments, or `\`.

**Deposits.** Each version in the inventory MUST have a `user` with a `name`, SHOULD give its `address` (an ORCID iD, a `mailto:` URI or another URI identifying the depositor), and MUST have a `message` describing the change, except the first version of a key log, which has neither (section 6.1). The `created` date and `user` of an object version record its <dfn>deposit</dfn>, not repeated in `object.json`; the deposit of a document version is that of the first object version holding it.

**Content.** Every object version MUST contain, at the top level of its content, `object.json` (section 4.3); `datacite.json` (section 4.4), except in an owner object; and the genesis record `genesis.json` (section 5), except in a draft. Every version of a branch also holds the evidence of its branch point: `parent.inventory.json`, `parent.object.json`, `parent.signatures/` and, for a branch of a branch, `parent.chain/` (section 9). The genesis record and this evidence are the <dfn>identity files</dfn> of the object, never files of the document's own. The names of every file this specification defines at the top level of the content (`object.json`, `datacite.json`, `genesis.json`, `members.json`, `keys.json`, `forked`, `parent.inventory.json`, `parent.object.json`, `parent.signatures`, `parent.chain`) are reserved for those files. A collection version also holds `members.json` (section 8). An owner object holds `genesis.json` and `keys.json` (section 6), a fork record `forked/` instead of `keys.json` (section 6.3), and no `datacite.json`; it has no document versions, and is never withdrawn or branched. Signatures and other witnesses are kept outside every version, in the object's extension folder `extensions/opensheaf-witnesses/` (section 7).

### 4.2 Documents and document versions

A document version holds, at the top level of its content, besides the files of section 4.1:

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
- in every version of a line, `name` and `owner` (sections 5 and 6), and in a branch `parent`, its branch point (section 9); a draft has none of them;
- in every version of a line after the first, `previous`: the SHA-512 digest of the inventory file of the version before, in lowercase hexadecimal, as its checksum file states it, the digest of its pin (section 4), whatever the version changes (a description-only version, a withdrawal, a fork record of a key log, sections 4.2, 13.1 and 6.3). A first version has none, since sealing starts a new line (section 10.2), and neither has the computed first version of a key log (section 6.1), the first version of a branch (section 9.2) or a draft, whose versions may be rewritten (section 10.1).

**The inventory chain.** Signing a version fixes, through `previous`, the bytes of the inventory file of every version before it, not only the files they record: a version vouched for by a later signed version (section 7.3) is fixed byte for byte, and its pin is as reliable as that of a version signed directly (#46). Two versions of one number with the same `previous` share their history; with different ones, they differ in an earlier version too.

An owner object has only these fields, `previous` included, and MAY have `extensions` (below), though data concerning its key log goes in `keys.json` or, for the first version, the owner's genesis record (sections 5.1 and 6.1).

A <dfn>note</dfn> is an object with `text`, a short plain text, or `path` and `mediaType`, a file of the content of the same object version, or both.

A document MUST have `mainSource` (a logical path) and `sourceFormat` (its media type), and SHOULD have `renditions`, a list of `path` (a logical path) and `mediaType`, and `toolchain`, a list of tools with `name`, `version` and, OPTIONALLY, `packages`, enough to reproduce the renditions. A document version without its sources has instead `sourcesMissing`, a note saying why ("arXiv keeps only the PDF of this version"), and at least one rendition; a rendition is never presented as a source. A document MAY have:

- `changes`: a note saying what changed in this document version, deposited with it (like arXiv's comments);
- `stage`: the stage of this document version, with `scheme` and `value`; for articles the RECOMMENDED scheme is `NISO-JAV` (NISO Journal Article Versions: `AO`, `SMUR`, `AM`, `P`, `VoR`, `CVoR`, `EVoR`), and other content uses other schemes (editions, software releases), named by the archive;
- `history` and `notices` (section 4.2), each notice a note with the `documentVersion` it is about and a `date`;
- `licence`: a note with the full text or terms of the licence (for licences without an SPDX identifier); `rightsList` in `datacite.json` remains the description for readers.

A collection has none of these fields of a document, and its notes are text only (section 8.2). A document or a collection MAY have:

- `agreement`: a minimal record that the authors agreed to the deposit and the licence: `by` (names only), `date` and `method` ("by e-mail"), all REQUIRED. It MUST NOT contain e-mail addresses, correspondence or signatures of persons;
- `external`: the external records of this version, each with `role` (`deposit` for a deposit of this version made under a profile, appendix A; `source` for the record it was imported from), `service` (its name) and `record` (its URL), all REQUIRED, and OPTIONALLY `doi`, `label` (the service's label for the version, such as `v3`) and `files`, the files kept there but not in the content (a deposit's source archive) or received from there, as received, each with `name` and `sha512` (REQUIRED), `md5` and `bytes`;
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
- for an owner, instead, `keys` and `threshold`, its first current keys and how many must sign, and `next` and `nextThreshold`, the digests of its first rotation keys and how many must sign the second version of its key log, from which the first version of its key log is computed (section 6.1); and, OPTIONALLY, `keeper`, a list of one URI, the person or institution who answers for the owner, fixed with its owner name (section 6.6), and `extensions`, the data of extensions concerning its key log as of the first version (section 6.1).

The genesis record MUST be part of every object version of the object and of its branches (section 9), byte for byte. It MUST be in UTF-8 without a byte order mark, and SHOULD have LF line ends. Since the name is the digest of its bytes as stored, tools MUST NOT rewrite or re-serialise it. A tool MUST NOT copy a genesis record into an object that is not a copy or a branch of the work it was written for, nor reuse a nonce.

### 5.2 Computing a name

Algorithm k, for k from 0 to 15, takes the SHA-256 digest of the seed `opensheaf-name-<k>` (ASCII, k in decimal, followed by a line feed) followed by the bytes of `genesis.json`, and writes it in lowercase base32 (RFC 4648, without padding): 52 characters, the last of which holds the last bit of the digest and four zero bits, which are set to k. A name thus matches `^[a-z2-7]{52}$`, and its last character gives its algorithm (`a` or `q` for algorithm 0), so names made by different algorithms never coincide. Names are compared as strings, never decoded: a name of algorithm 1 to 15 sets bits that RFC 4648 requires to be zero, so it is not canonical base32, and a strict decoder may reject it. `object.json` records a line's name as `name`; appendix C gives examples.

A genesis record thus has 16 names of one work (section 12 searches for a work by all of them). Its <dfn>genesis name</dfn>, made by algorithm 0, is the same for every line of the work. Every line is named by its genesis name, except a branch renamed after a clash, and branches named after it (section 5.3).

### 5.3 Origin and clashes

**Origin.** The <dfn>originator</dfn> of a work is the owner its genesis record names in `originator`; an owner is its own originator. The originator's line is the origin of the name: it has no parent, and its first version MUST be signed by the originator (section 7), except the first version of a key log, which is computed from the genesis record (section 6.1). Every other line of the genesis record is a branch and MUST declare its parent (section 9); a line of another owner that declares none is not a valid line of the name. A tool refuses a branch owned by the originator (how the originator takes in another line's work is open, #57).

**Clashes.** An owner has one line of each name, and no two objects of a storage root have the same line (section 4). A clash can arise only when a line is made, and the tool that makes it resolves it against the archive where it writes and the lines of the same owner it knows elsewhere that are signed (section 7):

- **Sealing.** If the line is taken, the tool draws a new nonce, so that an originator's line is always named by algorithm 0. A work sealed elsewhere that meets, when deposited, a taken line with another genesis record (a collision) is refused, and its owner seals it anew; with the same genesis record, it is a copy (below), or a reused record (section 5.4).
- **Branches.** A branch is named by `parent.name`, unless its line is taken by another line of its owner, in which case it is named by the smallest algorithm number greater than that of `parent.name` that gives a line free for its owner, and `parent` keeps the parent's name; if none up to 15 is free, the branch is refused. When the line taken is the owner's own branch of the same parent line, section 9 says when the owner moves that branch's branch point instead.
- **Copies.** A copy whose line is taken in a storage root by a different history of it is a fork of the line (section 7.4).
- **Takedowns.** A line stays taken in an archive after a takedown (section 13.3).

Lines of different owners never clash. A branch is always written with its owner part (section 12.1).

### 5.4 Reused genesis records

A genesis record reused for another work gives no valid line: the originator's line needs the originator's signature, and every other line needs a chain of signed parents back to it (section 9). A second history that the originator signs under its own record is a fork of its line (section 7).

When an object is created or deposited, an archive that holds an object or a tombstone with the same genesis record, compared by genesis name (`genesisName` of a tombstone, section 13), MUST refuse it unless it is signed by the originator (the originator's line) or is a branch whose branch points are confirmed back to the originator's line (section 9.3).

**Open question.** Whether aliases, new genesis records wrapping an old one, are needed if refusing reused genesis records proves too strict (#44).

## 6. Owners

An <dfn>owner</dfn> is a keyed identity: a person, a group or an institution that decides the versions of its lines and signs them (section 7), wherever they are stored. It is an object of kind `owner` (section 4), named by its genesis record (section 5): its <dfn>owner name</dfn> is the name of that record, the name that genesis records (`originator`), `object.json` (`owner`, and `owner` in `parent`) and `sheaf:` URIs (section 12) record. The owner object is the owner's own line, `(owner name, owner name)`, at `<owner>/<owner>/` in the owner-name layout (section 3.2). Its object versions are the owner's <dfn>key log</dfn>.

### 6.1 The key log

Every version of the key log, except a fork record (section 6.3), holds, besides the files of section 4.1, the file `keys.json`, with:

- `format`: `"opensheaf-keys/0.1"`;
- `keys`, except in an ending version (section 6.3): the owner's <dfn>current keys</dfn>, which sign the versions of its lines (section 7), at least one, each distinct, each an Ed25519 key written as a `did:key` URI (W3C CCG; multibase base58btc, multicodec `ed25519-pub`, code `0xed`, written as the varint bytes `0xed 0x01`);
- `threshold`, with `keys`: the number of distinct current keys that must sign a version of a line, a positive integer;
- `next`, except in an ending version (section 6.3): the digests of the <dfn>rotation keys</dfn> that sign the next version of the key log, at least one, each distinct, each the lowercase base32 (RFC 4648, without padding) SHA-256 digest of a `did:key` URI, as UTF-8, of 52 characters;
- `nextThreshold`, with `next`: the number of distinct rotation keys that must sign the next version, a positive integer;
- `extensions`, OPTIONAL, never in the first version, whose data of extensions is in the genesis record (section 5.1): the data of extensions concerning the key log in force as of this version, keyed by their names (section 2), each an object, which replaces that of the version before: each version states the extensions in force, so data that continues is repeated, and a version without `extensions` has none; for instance the declaration of the [timestamps extension](opensheaf-timestamps-0.1.md);
- `ended`, OPTIONAL: `true` in the last version of the key log of an owner that ends (section 6.3);
- `successor`, OPTIONAL, only with `ended`: the owner name of the owner that continues its work (section 6.3);
- `exposed`, OPTIONAL: keys listed in `keys` of earlier versions of this key log that this version declares exposed (section 6.3), each a `did:key` URI.

A rotation key is <dfn>revealed</dfn> once it has signed a version of the key log. In the genesis record of an owner and in every `keys.json`, earlier versions being those before it on its side of a fork (section 6.3):

1. `threshold` MUST NOT exceed the number of `keys`, nor `nextThreshold` that of `next`;
2. `keys` MUST NOT list a key that this version or an earlier one exposes, nor a rotation key, revealed or not (a key whose digest `next` of this version or an earlier one holds);
3. `next` MUST NOT hold the digest of a current key of this version or an earlier one, nor a digest that `next` of an earlier version holds, so that each rotation key is committed in one version only;
4. `exposed` MUST list only keys that `keys` of an earlier version lists.

Key-log versions are the OCFL versions of the owner object (`v1`, `v2`, ...); an owner object has no document versions. **The first version is computed** from the genesis record, and is never signed. It MUST hold exactly three files, whose bytes are fixed: `genesis.json`, the genesis record; `object.json`, the JCS form (RFC 8785, the JSON Canonicalization Scheme, without a final line feed) of an object with `format`, `specification`, `kind` `owner`, `status` `active`, and `name` and `owner`, both the owner name (section 4.3); and `keys.json`, the JCS form of an object with `format` and the `keys`, `threshold`, `next` and `nextThreshold` of the genesis record. Its inventory file MUST be the JCS form of the OCFL 1.1 inventory of these files, with nothing else: `digestAlgorithm` `sha512`; `head` `v1`; `id` the identifier of the owner object, `sheaf:<owner>:<owner>`; `type` `https://ocfl.io/1.1/spec/#inventory`; `manifest`, mapping the SHA-512 digest of each file, in lowercase hexadecimal, to a list of its content path, `v1/content/` followed by its name; and `versions`, holding only `v1`, with `created`, the `created` of the genesis record, and `state`, mapping the same digests to lists of the names of the files; no `contentDirectory`, `fixity`, `message` or `user`. Its checksum file states the SHA-512 digest of that inventory file, as OCFL requires. These files, and so the digest of the inventory file, are thus the same in every copy, and any reader can rebuild them from the genesis record; a signature naming the first version pins them. A first version with other files or other bytes is invalid, an error (section 14.3), never a fork (section 6.3). No owner tool writes a signature file for it. The keeper and the data of extensions as of the first version are those of the genesis record (section 5.1).

The versions after the first are signed by rotation keys:

1. every later version vN+1, except a fork record (section 6.3), MUST be signed by at least `nextThreshold` distinct <dfn>rotation keys of vN</dfn>, the keys whose digests `next` of vN holds, `nextThreshold` being that of vN (for v2, those of the genesis record);
2. its signature files name these keys, and so reveal them (section 7.2);
3. current keys never sign a version of the key log, and rotation keys sign nothing else.

From the second version on, `object.json` has `previous` (section 4.3), and a version MAY also hold files that this specification does not define (a display name, for instance), signed with it. Signature files, and when a signature is good, are defined in section 7.

A current key is added, retired or exposed, a threshold or the data of an extension changed, or the owner ended, by a new version of the key log, which also commits the next rotation keys; the owner name never changes, nor does the keeper, which the genesis record fixes: another keeper means another owner (section 6.6). Changing the current keys or `threshold` affects only signatures naming the new version or a later one: signatures naming earlier versions stay good (section 7.1).

### 6.2 Creating an owner and choosing its keys

An owner tool creates an owner by making its first current keys and rotation keys, writing its genesis record, with `kind` `owner`, `keys`, `threshold`, `next` and `nextThreshold`, and OPTIONALLY `keeper` and `extensions` (section 5.1), and the first version of its key log, computed as section 6.1 says. An owner is its own originator, and its owner object has no parent, so its owner name is made by algorithm 0 (section 5.2). If the owner name is taken, in the archive where the tool writes or among the owners it knows elsewhere, the tool draws a new nonce (section 5.3).

**Current keys.** Current keys are in daily use: one on each device the owner signs from (a laptop, a desktop), made there and never copied to another device. A person usually has a `threshold` of 1; a group or an institution MAY require the keys of several members, by a `threshold` of 2 or more, so that a thief holding one of them signs nothing alone.

**Rotation keys.** Rotation keys are kept apart from the current keys and from each other (on hardware tokens, for instance), and used only to sign the next version of the key log. Owner tools SHOULD offer three, with a `nextThreshold` of 2, which survive the loss of one or the theft of one. The minimal setup, which owner tools MAY offer, is a `nextThreshold` of 1 with at least one rotation key kept offline (printed, or on a USB key kept apart); its risk MUST then be stated: the loss of that key leaves the owner unable to change its keys or end, and its theft lets the thief take the owner over (section 15.1). A rotation key is used once, and committed in the `next` of one version only (section 6.1): once the next version is signed, the rotation keys of the version before, whether they signed or not, are never used again, and the owner SHOULD destroy them. Owner tools MUST warn that an owner left with fewer than `nextThreshold` rotation keys of the latest version of its key log can never change its keys or end.

**Retiring a key.** An owner retires a current key it no longer uses (a replaced laptop, a member who leaves the group) by leaving it out of `keys` in a new version of its key log. Signatures made with it stay good, and a retired key in someone else's hands still makes good signatures naming the versions that list it; section 6.3 says when to expose it instead.

### 6.3 Ending, exposed keys and forks

**Ending.** An owner ends by signing, as usual, a last version of its key log with `ended` `true`, without `keys`, `threshold`, `next` and `nextThreshold`, and, OPTIONALLY, `successor`, the owner name of a new owner that continues its work, which MUST differ from its own owner name. The ending version only ends: it has no keys, so nothing is signed against it, and signatures made before it name earlier versions, and stay good. Owner tools MUST NOT sign anything for an ended owner. A successor is a hint, never followed automatically, and is accepted only as section 6.6 says. An owner is <dfn>ended</dfn> when its key log has an ending version or a fork record (below).

**Exposed keys.** A current key is <dfn>exposed</dfn> when a version of the key log lists it in `exposed`: a key listed in `keys` of an earlier version of the same key log, retired or not. An exposure counts in any version of the key log, on either side of a fork (below), in a version a fork record carries included: a thief that forks the key log may thus expose the owner's earlier keys, which makes contested what they signed (section 7.3), but never makes a version signed. Exposed keys concern only the versions of the owner's lines (section 7.3), never those of its key log (section 6.1). An owner whose current keys may have been exposed (stolen, leaked, copied), and could together reach the `threshold` of some version of its key log that lists them, MUST at once sign a version of its key log that exposes them, or end; otherwise retiring them is enough. Only rotation keys sign that version, so whoever holds the current keys can neither prevent nor contest it.

**Forks of a key log.** Two signed versions of a key log with the same number whose inventory files differ are a <dfn>fork of the key log</dfn>; the first number at which two copies hold such versions is its <dfn>fork point</dfn>. The first version is computed, the same in every copy (section 6.1), so a key log never forks there; only `nextThreshold` rotation keys of the version before can make a fork: rotation keys stolen before use, or kept after it. The format cannot tell which side is the owner's, so a fork ends the owner, at the fork point, and freezes it (section 7.5); no version of either side from the fork point on names a successor that is accepted (section 6.6). An owner that finds a version of its key log it did not make, and still holds `nextThreshold` rotation keys of the version before, MAY sign another version of that number, which ends it (section 7.4).

**Fork records.** An archive keeps the versions of a key log it holds, the side it saw first (when it meets both sides at once, either one, since each ends the owner), and never replaces or removes one but by a takedown (section 4). When it meets, directly or carried by a fork record of another copy, a signed version of the key log whose inventory file differs from that of the version of that number it holds, after versions with the same inventory files as its own, it MUST append a <dfn>fork record</dfn>: a version of the key log after the latest it holds, made by the archive (its deposit, section 4.1), and not signed. A fork record:

1. holds `genesis.json`, that of the first version byte for byte; `object.json`, with the fields of that of the first version and `previous` (section 4.3); no `keys.json`; and the versions of the other side it met, from the fork point to the latest signed version of that side, each under `forked/<d>/`, where `<d>` is the first 16 characters of the lowercase base32 (RFC 4648, without padding) SHA-256 digest of its inventory file: that inventory file as `inventory.json`, its checksum file as `inventory.json.sha512`, its `keys.json`, and its signature files `signature-<k>.json` with the witnesses beside them (section 7.2), byte for byte. These versions are <dfn>carried</dfn>, and each carried inventory has the `id` of the owner object;
2. is valid only when it holds nothing but these files; the first version it carries is signed (section 7.3) against the version before it held below the fork record, and its inventory file differs from that of the version of its number held below it; and every later version it carries is signed against the version before it on its side. Otherwise it is not a version of the key log;
3. has as its fork point the number of the first version it carries;
4. is never a side of a fork: copies of a key log are compared up to the version before their fork records, and a version held in one copy at the number of a fork record of another, or after it, is no fork;
5. is copied with the key log like any version, so that every copy shows the fork; copies of a key log may differ after the fork point, each archive keeping the side it saw first.

**The end of a key log.** No version of the key log follows a valid fork record, and none follows an ending version but a fork record, which carries the other side from the fork point on: any other version held after either is not a version of the key log, and a fork met once the key log has a fork record is reported, not recorded.

### 6.4 After an end or an exposure

The signatures of an ended owner, and those made with exposed keys, stay good, since the format does not date signatures; but readers cannot tell them from a thief's, and trust them only as far as other evidence goes: copies held before, the pins of collections (section 8), timestamps (the [timestamps extension](opensheaf-timestamps-0.1.md)). A version of a line that needs an exposed key, or whose signatures name a version of its owner's key log from a fork point on, is contested, unless other evidence dates its signatures before (section 7.3). While it is not ended, the owner MAY sign again, with current keys not exposed, versions it knows it made that are contested by an exposed key (section 7.1); owner tools sign nothing for an ended owner (section 6.3), and after a fork nothing is added without evidence (section 7.5).

**Ended owners.** An archive that knows an owner is ended adds that owner's key log up to the ending version, with the fork record that may follow it, or up to the fork record, also as a new deposit, and that owner's other lines only as section 7.5 says, a fork freezing the owner. The work of an ended owner continues only under its successor, by branches of its versions (section 9). Resolvers and verifiers report ended owners, by an ending version or by a fork with its fork point, exposed keys, and successors, accepted or claimed (sections 6.6, 12 and 14).

### 6.5 Key logs travel with the objects they sign

A key log checks itself from its owner name: its first version is computed from the genesis record, which lists the first current keys and the digests of the first rotation keys, and each later version is signed by the rotation keys that the one before commits to. A copy from any source is therefore as good as the original, and a line can be checked without trusting any host, also after the archives that served it have gone.

Every copy of an object, in any archive, MUST hold beside it, as owner objects in the same storage root at their paths (section 3.2), the key logs of the owner of its line and, for a branch, of the owner of each parent whose signatures its evidence holds, in `parent.signatures/` and at every level of `parent.chain/` (section 9). Each is copied up to the latest version that whoever makes the copy knows, and at least up to the versions its signatures name, or up to a fork record that carries them (section 6.3). The key logs of third parties whose witnesses a copy holds (section 7) MAY be copied too. Key logs are never copied into an object's content. An archive MUST keep an owner object as long as it keeps an object whose signatures need it, unless the owner object is itself taken down; a tombstone then stands in for it, and a takedown of a line leaves its owner objects in place (section 13). An owner object MAY also be copied on its own, to keep a fresher copy of its key log.

Of two copies of a key log, compared up to their fork records (section 6.3), either one extends the other, and readers use the longer, or they differ from a fork point, as section 6.3 says. No one can prove offline that a key log is complete: a copy that stops early may hide that the owner has ended.

**Moving.** An owner moving to another archive copies its owner object there, with the lines it wants to keep there, and continues its lines in the new archive: the same owner and the same lines, not branches. The old copies stay valid where they are, as older copies of the same lines (section 7). In the owner-name layout this is one folder (section 3.2).

### 6.6 Keepers

An owner MAY name, in `keeper` of its genesis record (section 5.1), a single person or institution who answers for it, as a list of one URI: an ORCID iD (`https://orcid.org/...`), whose last character is a check digit (ISO 7064 MOD 11-2) that verifiers check (section 14.3), since no schema pattern can, or a domain written as `https://<domain>/`. The keeper is fixed by the owner name: no version of the key log names or changes it, and another keeper means another owner. The keeper MAY confirm it, in a place only the keeper controls: a link naming the owner in its ORCID record, or the file `https://<domain>/.well-known/opensheaf` on its domain, a JSON object with `format` `"opensheaf-keeper/0.1"`, `owners`, the owner names it answers for, and OPTIONALLY `successors`, an object mapping owner names it answers for to their successors (on ORCID, a link naming both).

**Successors.** An owner has at most one <dfn>accepted successor</dfn>: the one named by an ending version of its key log before any fork point (section 6.3); failing that, the one its keeper names in the place it controls, as above. The keeper MAY name one for an owner that can no longer change its key log (fewer than `nextThreshold` rotation keys left), that a fork has ended, or that ended without naming one; that successor is reported as named by the keeper, and does not by itself end the owner. Any other successor, named in a version of either side of a fork from the fork point on, or by the keeper when an ending version before any fork point names another, is reported as a claim.

When a keeper is named, a verifier MAY check both directions, and reports the link as confirmed, claimed only (the keeper does not confirm it) or absent. A confirmation is read as it is now: a keeper who withdraws it ends the link, and what the owner signed stays authentic. The link says who answers for an owner, not who owns its lines, which only its keys decide, nor who wrote its documents, which `creators` in `datacite.json` say (#41). The keeper's other roles, in takedowns and for privacy, are in sections 13 and 15.

**Open questions.**

- The field names of `keys.json`, among them `next`, `nextThreshold` and `exposed` (#55).
- Pre-rotation, provisional (#58; `drafts/keys-and-forks.md` and `drafts/federated-identity.md` on `main`): weighted thresholds for groups, as KERI's; witnesses that record which version of a key log they saw first, as an extension; and what a reader holding only one side of a fork can know.
- Whether exposing keys from when an archive learns of it, rather than dating signatures (revocation dated by trusted time, transparency logs), is enough against backdating (#55, #58).
- The form of a keeper's confirmation on ORCID, which depends on an `https` form of `sheaf:<owner>`, and so on the gateway (section 12; #13, #35).

## 7. Lines and signatures

A <dfn>line</dfn> is the history of a work as decided by one owner, identified by the pair (name, owner) and so by the identifier `sheaf:<name>:<owner>` (section 4). Its object versions form a single sequence, each signed by its owner, except the first version of a key log, which is computed (section 6.1). **A line is its signed versions, wherever they are stored**: in an archive where its owner writes, or in a mirror (section 11). Lines of other owners with the same genesis record are branches (section 9). An owner's key log is the line of its owner object (section 6).

### 7.1 Signing

Every sealed object version of a line MUST be signed by its owner when it is made, except the first version of a key log, which is computed (section 6.1): by at least `threshold` distinct current keys of one version of the owner's key log, `threshold` being that version's, each key signing in its own signature file (section 7.2), which names that key-log version. The key-log version named SHOULD be the latest its signer knows. A signature is judged against the key-log version it names alone (section 6.1), and no signature is ever replaced. An owner MAY add signatures to a version later, with current keys that have not signed it, only to a version it knows it made, and only while it is not ended (section 6.3): so it signs again, with keys not exposed, a version contested by an exposed key (section 7.3), or one it has not yet added when a key that signed it was exposed (appendix A.1). Versions of a key log are signed as section 6.1 says.

### 7.2 Witnesses and signature files

A <dfn>witness</dfn> is evidence about an object version made after it: a signature, a timestamp, an external deposit (appendix A), a software archive snapshot. The witnesses kept with an object are in its <dfn>witness folder</dfn>, the OCFL object extension folder `extensions/opensheaf-witnesses/` (not yet registered with OCFL, so validators may warn), which is part of no version, is not covered by the inventory digests, and travels with the object. Witnesses MAY be added at any time, by the owner of the line or by others; they are kept, never re-serialised or replaced once made, since some (timestamps) are made of their bytes, and MUST NOT be removed except as section 4 says.

**Signature files.** A <dfn>signature file</dfn> holds one signature of an object version by the owner of its line. The signature of version `<version>` by a key is the JSON file `<version>/signature-<k>.json` in the witness folder, where `<k>` is the first 16 characters of the lowercase base32 (RFC 4648, without padding) SHA-256 digest of the key's `did:key` URI, as UTF-8, so that a reader that knows the keys builds every name without listing the folder. It has:

- `format`: `"opensheaf-signature/0.1"`;
- `object`: the identifier of the object, `sheaf:<name>:<owner>`;
- `version`: the object version signed, `<version>`;
- `inventorySha512`: the SHA-512 digest of that version's inventory file, as its checksum file states it;
- `signer`: the owner name of the signer, which MUST be the owner part of `object`;
- `key`: the `did:key` URI of the key that signs: one of the `keys` of the key-log version named or, for a signature of a key-log version, a rotation key of the version named (section 6.1);
- `keyLog`: that key-log version, as a pin of the owner object written as a `sheaf:` URI, `sheaf:<owner>/v<n>?sha512=<digest>` (section 12), whose owner MUST be `signer`; for a signature of a key-log version vN+1 it names vN;
- `signature`: the Ed25519 signature (RFC 8032) of the signed message, 64 bytes in base64 (RFC 4648, with padding).

**The signed message.** What is signed is not a file but the message made of these five lines, each ended by a line feed (LF, `0x0A`), in UTF-8, with no other characters, spaces or blank lines:

```
opensheaf-signature/0.1
object <the value of object>
version <the value of version>
inventory <the value of inventorySha512>
keylog <the value of keyLog>
```

The first line keeps these signatures apart from any other use of the key; the others bind the signature to one object version, its inventory and one key-log version. A verifier rebuilds the message from the fields of the signature file and verifies the signature as RFC 8032 (section 5.1.7) says, without the cofactor, and MUST reject it when its `S` is not less than the group order L, or when the key is not the canonical encoding of a point or is a point of small order, or `R` is a point of small order; tools make keys as RFC 8032 (section 5.1.5) says.

**Others' witnesses.** A signature by someone other than the owner of the line, attesting a version, is a witness, not a signature of the line, and never a signature file: it is `<version>/witness-<label>.json`, where `<label>` is chosen by whoever adds it and matches `^[a-z0-9]+(-[a-z0-9]+)*$`. It has the fields and the signed message of a signature file, with `signer` and `keyLog` naming the signer's own owner object, which MUST NOT be the line's owner; its key log MAY be copied beside the object (section 6.5).

**Other witnesses.** The [timestamps extension](opensheaf-timestamps-0.1.md) keeps timestamps of signature files beside them, dates that readers may weigh; timestamps change no status by themselves, and section 7.3 admits trusted dates as evidence against `contested`. The parent signatures a branch carries are in its content (section 9).

**Files that are not witnesses.** A file of the witness folder that is not a witness (a stray file, a malformed or invalid signature file) is ignored, reported, never fatal, and kept; a file a reader does not recognise, stray or of an extension it does not know, is reported as an unknown file, not as an error: a host cannot break a version by adding a file. A copy MAY leave such files out (section 11).

### 7.3 Statuses

A signature file is <dfn>invalid</dfn> when:

1. it is malformed, or its name does not match the digest of its key;
2. its signature does not verify;
3. its `object`, `version` and `inventorySha512` are not those of the version whose folder holds it (the digest also as its checksum file states it; in `parent.signatures/`, those of the parent version, section 9; in `forked/<d>/`, those of the version carried, section 6.3);
4. its `signer` is not the line's owner;
5. the reader reaches the key-log version named, with that digest (also as carried by a fork record, section 6.3), and the key is not in its `keys` (for a signature of a key-log version, is not one of its rotation keys, section 6.1);
6. the version named is not a version of the key log, or is a fork record; or
7. for a signature of a key-log version, it signs the first version, or its `keyLog` names another number than that of the version before it (section 6.1).

A signature file that is not invalid is <dfn>unchecked</dfn> when the reader cannot reach the key-log version it names, with that digest (the key log is absent, taken down, or shorter, or the reader holds another version of that number, which verifiers report: a fork of the key log once the version named is found signed, section 6.3); a key-log version that the reader's copy neither holds nor carries, also after its fork record, is reached in a copy that holds it, and the signature is judged against that copy; nothing is added on unchecked signatures (section 7.5). Otherwise it is <dfn>good</dfn>, for ever: later versions of the key log, an end or a fork never change it.

A version of a key log is signed when it is signed as section 6.1 says, with good signature files; its first version is never signed, and counts as signed when it is the version section 6.1 computes. Key logs are read version by version from the first, and are never vouched for (below): each version is checked against the one before, and a fork record is a version when it is valid, though not signed (section 6.3).

A version of a line is:

- <dfn>signed</dfn> when it is <dfn>signed directly</dfn>, by at least `threshold` distinct current keys of one key-log version, `threshold` being that version's, with good signature files naming that version; or <dfn>vouched for</dfn>, when a later version of the same line signed directly extends it;
- unchecked when it is not signed, but would be if its unchecked signatures were good;
- otherwise <dfn>not a version</dfn> of the line, wherever it is found, and never shown as one: reported as invalid if at least one signature file of the owner is invalid, and otherwise as <dfn>unsigned</dfn>.

**Contested versions.** A signed version of a line is <dfn>contested</dfn> when it would not be signed if these good signature files of its owner, its own or those of the versions that vouch for it, were left out:

1. those made with a key that its owner's key log exposes, in any version, on either side of a fork (section 6.3);
2. those naming a version of its owner's key log from a fork point on, of either side.

Such signature files count nonetheless when other evidence that the reader trusts (a timestamp of these signature files, with the [timestamps extension](opensheaf-timestamps-0.1.md)) shows them made before the version of the key log that exposes the key, or before the fork. A key that another owner's key log exposes, shared between owners (section 15.5), counts only for that owner's lines. Only versions of lines are contested, never versions of key logs (section 6.1). A contested version is reported with its status (for archives, section 7.5); it is never the latest signed version (below), nor a confirmed branch point (section 9.3) or a verified member (section 8.5).

**A signed version vouches for its past.** The inventory of a version records the digests of every file of every version before it, and its `object.json` the digest of the inventory file of the version before (`previous`, section 4.3), so a version signed directly vouches for every version it extends, byte for byte, inventories included, whatever their own signatures; a version vouched for needs no signatures of its own, and its pin is as reliable as that of a version signed directly.

**Readers use the latest signed version.** The <dfn>latest signed version</dfn> of a copy of a line, its latest version that is signed and not contested, gives the line's history, current version and status (section 4.2). Nothing relies on a version that is not signed: not a pin, a resolution, a collection member or a branch point. An unchecked version is shown with its status until the key log is found, a contested one with its status.

**Owner tools MUST show the owner**, before signing a new version, the versions it would extend that are not signed or that need an exposed key, whatever evidence dates them, so that an owner never takes a thief's version into its line unknowingly.

### 7.4 One writer per line, and forks

An owner MUST NOT sign two different object versions with the same number for the same line, except as section 6.3 allows. Since every version directory keeps the inventory as of that version (section 4.1), two copies of a line whose heads are `vk` and `vm`, with k not greater than m, <dfn>agree</dfn> when `vk/inventory.json` is the same file, byte for byte, in both. A copy that stops earlier is older: readers use the latest signed version among the copies that agree. Two copies that do not agree are a <dfn>fork of the line</dfn>, reported with the status of each side, and never recorded (an archive keeps the side it holds, section 5.3), except that a fork of a key log ends the owner and is recorded (section 6.3); a fork whose sides are both signed was made with keys of the owner, and is attributable to whoever holds them.

### 7.5 Adding versions

An archive adds a version to a line only if, once added, it is signed and not contested (section 7.3) against the key log the archive holds: signed directly by its owner, or vouched for by a version signed directly that is added with it from the same copy. Tools SHOULD fetch the latest version of the key log they can find before adding. An archive adds no invalid signature file. An archive that continues another owner's line makes a branch, under its own owner (section 9).

**Ended owners.** For an owner whose key log has an ending version (section 6.3), an archive takes versions of its other lines only from copies found elsewhere, never as new deposits, and of copies that fork, only the versions they share.

**A fork freezes the owner.** Once an archive knows of a fork of an owner's key log (section 6.3), it adds no version of that owner's other lines, from a copy or as a deposit, unless other evidence it trusts (a timestamp, with the [timestamps extension](opensheaf-timestamps-0.1.md)) dates signature files enough to make the version signed before any version of the key log at the fork point was signed.

**Versions held stay.** Nothing that a host or a thief can produce leads to removing a version an archive holds, except as section 4 says. A version let in against this section that is not signed is reported, and never shown as a version of the line. Since OCFL versions cannot be skipped, the owner's own version of that number can then never be added there: that archive's copy is one side of a fork of the line, and the owner continues the line in another archive.

### 7.6 Integrity

Integrity rests on OCFL digests: every file is fixed by its SHA-512 digest in the inventory, every inventory by its checksum file, and every member of a collection by a pin (sections 4 and 8). Digests show that files were not changed, signatures which owner's keys signed them; neither shows who wrote them or when (sections 7.2 and 15.1).

**Open questions.**

- The field names and the format of signature files (#55).
- Exposed keys and fork records, provisional (sections 6.3 and 6.4; #58).

## 8. Collections

A <dfn>collection</dfn> is an object of kind `collection` (section 4) whose versions hold a list of members, `members.json`. Each <dfn>member</dfn> is a line (section 7) of a document or of another collection, in any archive, pinned (section 4). A collection is a line like any other, signed by its owner (section 7), its <dfn>curator</dfn>; what it contains changes only by a new version.

### 8.1 Catalogues and selections

Collections are of two types, which treat the versions of their members differently; `type` in `members.json` states which.

- A <dfn>catalogue</dfn> keeps objects whole and is impartial about their versions. Each member pins an object with all its versions up to the pin, and the catalogue may follow it as it grows (section 8.3): the owner of each member decides what its versions are.
- A <dfn>selection</dfn> vets particular versions: a journal the version it accepted, a digest or a review journal the version it reviewed, a reading list the version it recommends. Each member pins a revision set (section 8.4); earlier and later versions of the same member are not part of the selection unless its curator adds them, by a new version of the selection.

Both types may have collections as members (an archive of archives, a selection of issues).

**An archive's collections.** An archive that makes collections does so as an owner, with a key log like any other (section 6). Its <dfn>main catalogue</dfn>, named by `mainCollection` in its discovery document (section 3.1), is a catalogue of the documents of the lines its owners write in the archive, not of the copies it holds; its owners are those that `owners` of the discovery document lists, and when it lists none, which lines are the archive's own is not checked (section 14.6). It MAY also keep a catalogue of the lines it holds as copies (section 11). A selection is kept by the owner of the body that vets (a journal, a review journal), which also owns the accepted copies the selection keeps (section 9).

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

A member MAY have `follow`, `"latest"`: a setting of the curator, not a floating reference. A followed member pins the latest signed version of its line (section 7.3) when the collection version was made; a member without `follow` keeps the version its curator pinned, which MAY be earlier, until the curator changes it. A tool maintaining the catalogue reads the member's archive (its discovery document or feed) and, when a followed line has a new signed version, writes a new collection version pinning it, whatever that version holds (a new document version, a description, a notice, a withdrawal): a catalogue does not judge the versions of its members, but never follows to a contested version, which is not the latest signed version (section 7.3), nor, once it knows the owner's key log forks, to a version that an archive would not add (section 7.5). A tool follows only a signed version that extends the version pinned; a copy that does not is a fork of the line (section 7.4), which it reports, keeping the pin.

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

- **verified**, when a copy of the version pinned is found, matches the pin, and is signed and not contested (section 7.3);
- **contested**, when a copy of the version pinned is found, matches the pin, and is contested (section 7.3);
- **mismatch**, when a copy is found and does not match the pin;
- **unchecked**, when the version pinned is unchecked (section 7.3), shown with its status until the key log is found;
- **not a version** (section 7.3): the collection pinned what it MUST NOT;
- **unavailable**, when no copy is found;
- **removed**, when no copy is found and an archive holds a tombstone of the line (section 13.3).

### 8.6 Description and rights

**Description.** A collection version's `datacite.json` (section 4.4) has `resourceTypeGeneral` `Collection`, and MUST have in `relatedIdentifiers` a `HasPart` relation to the version DOI of each member of a catalogue (its `doi`) and of each revision of a selection (the revision's `doi`) that has one; members without a DOI are listed only in `members.json`. Its document versions and the fields of its `object.json` are as sections 4.2 and 4.3 say.

**Rights.** A collection version holds only metadata, placed under CC0 (section 15.6), and its `rightsList` SHOULD say so. The licence of a collection never extends to its members.

**Open questions.**

- Whether `follow` applies to every object version of a catalogue or only to its document versions, so that a catalogue with followed members can still have description-only versions and a withdrawal (#45).
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
- **the pin:** the SHA-512 digest of `parent.inventory.json` is `parent.inventorySha512`, its `head` is `parent.objectVersion`, and `parent.object.json` has the digest it records for `object.json` in its head state;
- **the files:** every file of the head state of `parent.inventory.json`, `genesis.json` included, except `datacite.json`, `object.json` and the parent's evidence, is present at the same logical path with the same digest; no other file is present besides the branch's `datacite.json`, `object.json` and evidence;
- **the parent:** `parent.owner`, `parent.name` and `parent.documentVersion` are those of `parent.object.json`; the branch's owner is neither the parent's owner nor the originator; and either the parent's owner is the originator and `parent.object.json` has no `parent`, or it has one;
- **the signatures:** the parent version is signed (section 7.3), by the signature files of `parent.signatures/` against the parent owner's key log kept beside the branch, or vouched for by a signed version of the parent's line that the verifier finds; or it is unchecked;
- **the chain:** when `parent.object.json` has a `parent`, `parent.chain/` holds that evidence, each file with the digest `parent.inventory.json` records for it, and it passes these checks in turn, level by level, up to the originator's line, except the files, checked at the first level only (a parent version may be a later version of its own branch).

A chain is finite, since each level is fixed by a digest in the level below. Verifiers MAY bound the depth they follow, and report where they stop; a branch point checked only down to that bound is unchecked.

**Verdicts.** A branch point is, in this order:

- <dfn>inconsistent</dfn> when a check fails, a parent version is not a version (section 7.3), or the parent version, resolved, does not match the pin;
- <dfn>confirmed</dfn> when the parent version, at every level, is signed and not contested;
- otherwise unchecked: consistent, but a parent version is unchecked or contested (section 7.3).

The verdict of a branch is the weakest of those of its branch points. Verifiers report apart whether the parent's line is found, unavailable or removed (section 13), and whether it is withdrawn.

**Ended owners.** A branch point stays confirmed when its parent's owner ends, also by a fork, or exposes keys afterwards, as long as the parent version is not contested (section 7.3), since signatures stay good; readers weigh it as they weigh that owner's history (section 6.4).

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

**Rights.** A branch needs only the right to redistribute its parent versions (section 15.6); a copy of the parent's line beside it follows section 11.2. The evidence is metadata, under CC0 (section 15.6).

**Open questions.**

- The numbering of document versions on a branch: continued from the branch point (provisional), or numbered from it (3.1, 3.2), which makes `documentVersion` more than an integer; `/v<n>` of a `sheaf:` URI follows it (#57).
- Moving a branch point when the branch has files of its own (of its notes, a withdrawal, a version of record): probably a merge keeping both, with evidence that tells them apart (#57).
- The field and folder names of the evidence (#55).

## 10. Drafts and sealing

A <dfn>draft</dfn> is a sandbox for a work not yet sealed, on which nothing may rely. <dfn>Sealing</dfn> makes from a work, under a new genesis record (section 5), the first version of its originator's line (section 7); the work's other lines are branches (section 9).

### 10.1 Drafts

**Identifier.** A draft belongs to the reserved owner `draft`, never a name or an owner name (52 characters, section 5.2). Its identifier is `sheaf:draft:<id>`, where `<id>` is chosen by the archive, MUST match `^[a-z0-9]+(-[a-z0-9]+)*$`, and MUST have at most 64 characters (76 for the identifier). It MUST NOT be reused in the archive while the draft exists, and MAY be once the draft is gone. It is local, never resolved. A draft is at the path its identifier gives (`draft/<id>/` in the owner-name layout, section 3.2).

**Format.** A draft is a `document` or a `collection`, in the format of any object of its kind (section 4). It has no genesis record and no other identity files (section 4.1), and its `object.json` has no `name`, `owner` or `parent` (section 4.3). Its document versions are numbered by whoever keeps it, by the rules of section 4.2.

**A draft is its archive's alone.** A draft is never signed (section 7), pinned (sections 8, 9 and 12), copied out of its archive (section 11), indexed or named by a `sheaf:` URI (section 12). The discovery document does not list drafts in `objects`; it MAY list them apart, in `drafts`, as unfinished work on which nothing may rely, or not at all (section 3.1).

**A draft may change.** A draft is the only object that MAY be rewritten or deleted: the rule that object versions never change (section 4) does not apply to it, and a draft deleted leaves no tombstone (section 13). OCFL 1.1 expects the contents of a version directory to be immutable once created (OCFL 1.1, section 3.3), and its extension `0005-mutable-head` keeps a mutable version outside the version directories, which a draft does not: a draft is an OCFL object as it stands, but outside OCFL's guarantees, and verifiers check it only as it stands, never against an earlier state (section 14.4).

**Content.** A tool MAY read any object and recreate its files in a draft, as far as their licences allow.

### 10.2 Sealing

**When.** A work is sealed before a version of it first leaves its owner's hands: shared privately (submitted to a journal, sent to a co-author) or published. Tools SHOULD seal only at the owner's request, never as a side effect of another operation.

**What.** An owner tool seals a work by writing its genesis record (section 5.1), with the owner as `originator`, and making a new object: the line `sheaf:<name>:<owner>`, at its path in the storage layout (section 3.2), whose first version holds the genesis record and the work as document version 1 (section 4.2), and is signed by the owner (section 7.1). If the line is taken, the tool draws a new nonce (section 5.3).

**Drafts stay outside the line.** A work may be sealed from a draft or from files outside any archive. The versions of a draft are never part of the line sealed from it, and nothing in the line refers to them.

**Open question.** Whether and how drafts are shared before sealing (among co-authors, with a journal under review), and how an archive serves them, which bears on when a work must be sealed (#29).

## 11. Copies and mirrors

A <dfn>copy</dfn> of a line is its object as held in one storage root; a <dfn>mirror</dfn> is a copy kept in an archive where the owner of the line does not write, which is the archive's policy (section 3). Nothing marks a mirror: it is listed in `objects` like any line (section 3.1), and the rules of every copy apply to it. Whoever keeps mirrors of other owners' lines, or indexes of them (section 12), is a <dfn>custodian</dfn>.

### 11.1 Mirrors

**What a mirror holds.** An archive MAY keep a mirror of a line written elsewhere: the object's versions up to the latest signed version of the copy it copies (section 7.3), with their inventories, files and the witnesses it can find (over HTTP, only those whose names it can compute, section 14.1), byte for byte, at the path its layout gives the line's identifier (section 3.2), and beside it the key logs its signatures need (section 6.5). Files of the witness folder that are not witnesses need not be copied (section 7.2): not copying them is not removing them. When a copy holds, under the same name, a witness file other than the mirror's, the mirror keeps its own and reports the other.

**How a mirror grows.** A mirror is the same line, signed by its owner, never a new one. It MUST NOT be changed except by adding the owner's signed versions as section 7.5 allows, from a copy that agrees with it (section 7.4); by adding witnesses (section 7.2); or as section 4 says. A copy that does not agree with it is a fork of the line (section 7.4).

**Elsewhere.** A mirror may be listed in a catalogue of copies, never in the main catalogue (section 8.1), and located by the `at` of collection members (section 8.2). A copy of a parent's line kept beside a branch is a mirror (section 9.5); an accepted copy is a branch, not a mirror (section 9.6). Drafts are never mirrored (section 10.1).

### 11.2 Rights

An archive MUST NOT keep a mirror unless the licences of every object version it copies (`rightsList`, section 4.4, which a description-only version may change) allow redistribution. Key logs, inventories, signature files and the other metadata are under CC0 (section 15.6), and are copied freely; a reference needs no permission (section 8.5).

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

**Canonical form.** The canonical form has complete parts (section 12.2), lowercase where case is folded, no owner part when the owner is the originator, the genesis name (section 5.2) with `:*`, and no `at` or unknown parameters. Two URIs name the same thing when their canonical forms are equal byte for byte, which may need a copy of the genesis record to decide. Files record `sheaf:` URIs in canonical form (`keyLog`, section 7.2; relations, section 4.4), except identifiers (section 4), which always have the owner part.

### 12.2 Short forms

For people, the name and the owner name MAY be shortened to a prefix of at least 8 characters (`sheaf:lvfmiq2z:iztwg6bj/v3`); a part of 52 characters is complete. A resolver expands a short form among the lines it knows that pass the checks of section 12.3. The candidates are the lines whose name and owner name start with the parts given (without an owner part, the originators' lines; with `:*`, every name starting with the name part, whose work is then searched for, section 12.4). If exactly one line (with `:*`, one genesis record) is a candidate, the short form names it; otherwise it is ambiguous, and the resolver MUST NOT choose but lists the candidates with their full forms and originators.

Expansions may differ between resolvers and over time, so every file defined by this specification MUST use complete parts. A resolver SHOULD show the full form of what it resolved; landing pages and citation metadata SHOULD give the full form, and MAY add a short one. A short form printed where it cannot be corrected (a paper, a slide) SHOULD have at least 16 characters in each part.

### 12.3 Resolution

**Where to look.** A resolver tries, in any order, the locations it has: the URI's `at` first, the `at` of a collection member (section 8.2), a branch's `parent.url` (section 9.1), the indexes it knows (section 12.5), its user's configuration. At an archive it reads the discovery document, finds the line in the indexes or in `objects`, and fetches `<storageRoot><path>/<version>/inventory.json`, `<path>` being given by the archive's layout (section 3.2); a key-log version carried by a fork record is found under `forked/` in the fork record, whose inventory lists it (section 6.3). The parent version of a branch is fetched at `parent.url` and otherwise found as any version of `sheaf:<parent.name>:<parent.owner>`.

**Checks.** Every copy found is checked: the URI's name is a name of its `genesis.json` (section 5.2); its `object.json` has that `name` and the line's owner (the owner part, or the originator); its versions are signed (section 7.3), against the key log kept beside it (section 6.5) or a longer copy found elsewhere. For a pin, the inventory file has the digest and the version holds document version n (for a key log, is object version n, or is carried with that number by a fork record, section 6.3); a copy that does not match is reported as a mismatch (section 8.5). A copy that passes is a copy of the line, wherever found. Unchecked versions and versions that are not versions (section 7.3) are reported with their status and location, and never resolved to; a contested version is resolved to only by a pin naming it, and reported as contested.

**Copies, forks and ended owners.** Since a copy that stops early looks complete, a resolver uses the latest signed version among the copies it found that agree (section 7.4), and says where it found them. A fork of the line (section 7.4) is reported with the status of each side; the resolver uses only signed versions and does not choose between signed sides. A fork of a key log is not one of a line: it ends and freezes the owner (sections 6.3 and 7.5), and signatures naming versions of either side are checked against them, wherever held, the versions they sign being contested from the fork point on (section 7.3). A resolver reports an owner that has ended, by an ending version or a fork, or has exposed keys (section 6.3), with any successor, its own or named by its keeper (section 6.6), and never follows a successor by itself.

**Tombstones.** A tombstone (section 13) is not signed: a resolver that meets one keeps looking, and when it finds a copy that passes the checks, reports the copy and the tombstone.

**External records.** A deposit with an external service (`external`, section 4.3; appendix A) or a software archive snapshot is a witness (section 7.2), not a copy: it holds no inventory, so it is never checked against a pin and resolves nothing; a resolver MAY report it as a place where the files may be found. A snapshot holding an archive's storage root (an archive kept in git) is read as that archive.

### 12.4 Searching for a work

Resolving one line needs no search (the originator's line is always named by algorithm 0). But the lines of a work may carry any of the 16 names of its genesis record (section 5.2). To find them all (for `:*`, or a search by work), a resolver obtains the genesis record from any copy or index entry found under the name, checked against it; computes its 16 names and looks each up in the indexes it knows; keeps only the entries whose genesis record is byte for byte the one obtained, discarding others as collisions (removed entries without a genesis record are listed apart, as removed lines of those names, and removed entries that kept it are marked removed); and keeps only the lines that pass the checks of section 12.3 and hold back to the origin: the originator's line signed by its originator, and branches whose branch points are confirmed (section 9.3). A reused genesis record thus yields no line (section 5.4), and no hash is assumed free of collisions. If several genesis records have the URI's name, the URI is ambiguous: the resolver lists them with their originators.

### 12.5 Indexes

An archive SHOULD keep three <dfn>indexes</dfn> of its objects, by name, by owner and by inventory digest, next to its discovery document, declared in its `indexes` (section 3.1). A custodian (section 11) or a resolver MAY keep them for many archives at a base URL of its own, declared in `indexes.json` there. Indexes are maps, not witnesses: what they lead to is checked (section 12.3).

**Files.** An index is a folder of files `<p>.json`, where `<p>` is a prefix of the key, each a JSON object with `format`, `"opensheaf-index/0.1"`; `index`, its folder; and `entries`, every key starting with `<p>`. A file without entries is omitted, so a missing file means no entry. The declaration (`indexes` in the discovery document, or `indexes.json`, with `format` and `indexes`) maps each index kept to the length of its `<p>`, from 2 to 4 characters.

- `names/`, by name: for each object with a genesis record, `name`, `owner`, `id` (section 4), `status`, `originator` (for an owner object, itself), `genesis` (the text of `genesis.json`, whose UTF-8 encoding is exactly its bytes, so that works are searched for from indexes alone) and, if any, `label` (section 3.1);
- `owners/`, by owner name: for each owner with lines in the storage root, `owner` and `names`, the names of those lines, its key log among them when kept there (section 6.5);
- `sha512/`, by inventory digest: for each sealed object version, and each key-log version carried by a fork record (section 6.3), `inventorySha512`, `id`, `version` and `status`, a carried version having the `id` of its key log and its own number.

**Content.** An archive's indexes list every object with a genesis record and every sealed version of it, carried key-log versions included, never drafts. `status` is the object's, `active` or `withdrawn`, or `removed` after a takedown (section 13): a tombstoned object keeps its entries in `names/` and `sha512/`, of which those in `names/` MAY drop `originator` and `genesis`, while a takedown removes the name from `owners/`, and the entry once it lists none. In indexes kept for several archives, every entry has `at`, a list of base URLs of the archive serving the copy, equal hints (section 3), and `owners/` has an entry for each owner and archive.

**Lookups.** A resolver looks a line up in `names/`, starting from `at`, keeping the entries whose `owner` matches the owner part, or without one, whose `owner` is their `originator`; a removed entry without `originator` is matched against the originator of any copy of the genesis record, or reported as a removed line of that name, originator unknown. It looks a pin up in `sha512/` and an owner's lines in `owners/`. At an archive without indexes, it MAY read `objects` of the discovery document and fetch `genesis.json` and `object.json` from the objects.

### 12.6 Gateways

A gateway serves a URI at its base URL followed by the URI unchanged (`https://opensheaf.org/sheaf:<name>/v3`, provisionally, #35); gateway links are written in full, since a relative link starting with `sheaf:` is read as a URI. A gateway:

- MUST answer with a page (200) showing what it resolved, or a temporary redirect (302, 303 or 307) only to a copy it has checked (section 12.3); it MUST NOT redirect permanently (301, 308), and MAY cache its result only for a URI with a digest;
- MUST show where what it resolved was found, that a URI without a digest resolves to the latest copy it found, not necessarily the owner's latest, and when the owner has ended, by an ending version or a fork, or has exposed keys, with any successor;
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

A document or a collection is <dfn>withdrawn</dfn> by a description-only version (section 4.2) whose `object.json` has `status` `withdrawn` and `withdrawal` (section 4.3), and whose `datacite.json` has `withdrawal.date` as `Withdrawn` (section 4.4). The status is the line's, read, as its history is, from its latest signed version (section 7.3), whatever document version that holds; a copy without a signed version has no status as a line, and its discovery document gives that of its head (section 3.1); a single document version is retracted by a notice (section 4.2). A branch or an accepted copy is withdrawn only by its own owner (section 9).

A withdrawn line keeps every version, signed, pinned and copied as before. Presentations showing a version of a line they know to be withdrawn MUST show the withdrawal, also when the version shown is earlier.

### 13.2 Takedown

A <dfn>takedown</dfn> deletes a sealed object, witness folder included, from an archive's storage root (with the folders the deletion leaves empty) and from its presentation files, and adds a tombstone (section 13.3). An archive removes what it holds only as section 4 says, and every removal of a sealed object is a takedown, whatever its reason: content that must not be served (by law, for a breach of rights, to erase personal data, section 15.5), or a line the archive stops keeping. It removes one object: others holding the same files, such as a branch holding its parent version (section 9), are taken down on their own.

**Owner objects.** A takedown of a line leaves in place the owner objects its copy carries (section 6.5). An owner object that an object of the archive needs is taken down only for itself, and only by law or at its keeper's request (section 6.6); never at a request signed by the owner's keys, which a thief may hold. The owner's signatures in what the archive keeps are then unchecked there (section 7.3), and the tombstone stands in for the owner object in the rule of section 6.5.

**Returning.** A line taken down (an owner object found elsewhere, for instance) MAY return to the archive only from a copy holding the version its tombstone pins or, when that version is not signed (a fork record counts as signed here), the latest signed version before it, added as section 7.5 says: it is the same line, not a reuse of its identifier (section 4), and its tombstone is dropped.

### 13.3 Tombstones

A <dfn>tombstone</dfn> is an entry of `tombstones` in the discovery document (section 3.1), one for each object taken down, with:

- `id`, `kind`, `name` and `owner`: those of the object (section 4.3);
- `genesisName`: the genesis name of its genesis record (sections 5.2 and 5.4);
- `lastVersion` and `inventorySha512`: its head when taken down, and the SHA-512 digest of that version's inventory file, a pin (section 4);
- `date`: the date of the takedown;
- `reason`: a plain text, which SHOULD NOT repeat what was taken down.

A tombstone is never removed, except when its line returns: it keeps the line taken (section 5.3), and `objects` never lists its `id`. It is not signed (section 12.3). A line, or a version of it no later than `lastVersion`, of which no copy is found but a tombstone is, is reported as removed (sections 8.5 and 9.3).

**Open questions.**

- Whether a tombstone in one archive stops resolution at copies elsewhere, and whether mirrors, branches holding the version taken down, indexes kept by others and gateways follow a takedown (#33, #39).
- The form of an owner's signed request for a takedown, and of a keeper's (#33).
- Whether a tombstone lists the inventory digests of every version taken down, so that a pin of a removed version is told from a pin that never named one; meanwhile the archive's `sha512/` index keeps them (section 12.5; #33).
- Whether a withdrawn line takes new document versions; whether and how it is reinstated; whether `withdrawal` stays in later versions; what a verifier reports for a pin of an earlier version of a withdrawn line; and how the line of an ended owner, which signs nothing, is withdrawn (#25).
- A retraction by a collection (a journal) of one of its members, distinct from a withdrawal by the member's owner (#40).
- Takedowns of single files or versions, should a later OCFL provide them (#32).

## 14. Verification

A <dfn>verifier</dfn> is a program that checks an archive, or an object with the key logs kept beside it, against this specification. It checks every requirement of sections 3 to 13 that the files decide, in the order of sections 14.2 to 14.6, each step using the results of those before; the rules are those of the sections cited. The discovery document, the indexes and presentation files are maps: a verifier checks them against the storage root, and never takes them as authoritative (section 3.1). Rules on what an archive received or saw, rather than on what it holds, are not checked from the files: that an archive takes the lines of an ended owner only from copies, never as new deposits (section 7.5), and keeps the side of a fork of a key log it saw first (section 6.3).

### 14.1 Findings

A verifier reports every finding with its place (the archive, an object, a version, a file), and does not stop at the first. A finding is:

- an <dfn>error</dfn>: a breach of a MUST or MUST NOT, except where this section makes it a warning. An archive or an object without errors <dfn>passes</dfn> verification;
- a <dfn>warning</dfn>: a breach of a SHOULD; a breach that the archive cannot repair, where this section says so; a check not made or not completed;
- a <dfn>result</dfn>, neither: the statuses of signature files, versions and members (sections 7.3 and 8.5), the verdicts of branches (section 9.3), forks of lines and of key logs (sections 6.3 and 7.4), ended owners (by an ending version or a fork), exposed keys, contested versions (section 7.3), and successors, accepted or claimed (sections 6.3 and 6.6), withdrawals (section 13.1) and removals (section 13.3).

**Checks not made.** A verifier reading an archive over HTTP cannot list folders: it checks the objects the discovery document lists, and warns that it has not checked that the storage root holds no others, nor the files of witness folders whose names it cannot compute; one with access to the files checks them. A verifier MAY bound the depth of the chains and collections it follows (section 9.3), SHOULD bound the size of what it fetches (section 15.2), and warns where it stops.

### 14.2 Files and storage

The verifier checks:

- every JSON file this specification defines against its schema (section 2), formats (dates, URIs) included as assertions, which JSON Schema 2020-12 leaves optional: the discovery document, the files of every object version (`parent.object.json` and the files of `parent.chain/` included), the files of witness folders, the indexes, and a keeper's file when it reads one; a malformed file of a witness folder is a warning (section 7.2);
- that the storage root and every object are valid OCFL 1.1, with an OCFL validator or equivalent checks, leaving out the warnings validators give on witness folders (section 7.2); a draft is checked as it stands (section 10.1);
- the layout that `storageLayout` names (section 3.2): for the hashed layout, that `ocfl_layout.json` names it with its parameters; for the owner-name layout, that the storage root has no `ocfl_layout.json`, and, a breach being a warning, that it holds `opensheaf-owner-name-storage-layout.md`; and that every object is at the path its identifier gives in that layout;
- the rules of section 4.1 in every object version, and that the inventory of each version folder is the inventory as of that version: its `head` is that version, and its `versions` are those of the head inventory up to it, equal as JSON values;
- the inventory chain (section 4.3): that the `object.json` of every sealed version after the first has `previous`, equal to the SHA-512 digest of the inventory file of the version before, as held in its version folder, and that a first version and a draft have none; a missing or differing `previous` is an error.

### 14.3 Key logs

The verifier checks the owner objects first, each from its first version (section 6):

1. its genesis record (section 5.1), and that its first version is the one section 6.1 computes, by computing `object.json`, `keys.json` and the inventory file from the genesis record and comparing them with those held, byte for byte, with no other file (a signature file of the first version is invalid, section 7.3, and a warning, as any invalid file of a witness folder, section 7.2);
2. when a keeper is named by an ORCID iD, its check digit (section 6.6);
3. that every later version but a fork record holds `keys.json`, and that each later version is signed (section 7.3);
4. that no version is held after a fork record, nor after an ending version but a fork record (section 6.3), a breach of these two being a warning, as for lines (section 14.4);
5. that an ending version has no `keys`, `threshold`, `next` or `nextThreshold`, that `successor` is not the owner itself, and whether it is accepted or claimed (sections 6.3 and 6.6);
6. the thresholds, and the rules of section 6.1 on `keys`, `next` and `exposed`, among them that no digest is in the `next` of two versions;
7. each fork record (section 6.3): that it is valid, holding the `genesis.json` of the first version, byte for byte, an `object.json` with the fields of that of the first version and `previous`, no `keys.json`, and nothing else but the versions it carries, each under the name its inventory digest gives, with the owner object's `id` in its inventory, its `keys.json` and checksum file against its inventory, and its signatures against the version before, the first differing from the version of its number held.

It reports as results the latest version of each key log, the exposed keys, on either side of a fork, and ended owners, by an ending version or by a fork with its fork point, with their successors, accepted or claimed; when a keeper is named, it MAY check the link (section 6.6).

### 14.4 Objects

For every other object, the verifier checks:

- **its records:** the rules of sections 4.2 to 4.4 in every version and between versions (numbering, new versions, completion, `history`, notices), as far as the files decide them;
- **its identity:** the genesis record, the name and the identifier in every version (sections 4 and 5), and that the objects and tombstones of the archive with the same genesis name are its originator's line and branches of it (section 5.4);
- **its signatures:** the status of every signature file and version, and the latest signed version (section 7.3), against key logs kept beside it as section 6.5 asks. A key log missing is an error; one taken down (section 13.2), or not reaching the versions its signatures name (section 7.3), a warning; the signatures that need it are unchecked. A version that is not a version of its line is a warning (section 7.5); a contested version is a result (section 7.3);
- **a branch:** the verdict of each branch point (section 9.3), at its first version and at every version that moves it, with the continuity of section 9.4, and that the identity files are unchanged between them. An inconsistent branch point is an error, an unchecked one a warning; the branch's verdict, and whether its parent's line is found, unavailable, removed or withdrawn, are results. A rename whose algorithm number is not greater than that of `parent.name` is an error (section 9.3); one that neither the objects nor the tombstones of the archive justify, or not by the smallest number free there, is a warning (section 5.3);
- **a draft:** the rules of section 10.1, as it stands, and that nothing in the archive pins it.

### 14.5 Collections

For each collection version, the verifier checks the rules of section 8 on `members.json` and its members. It resolves every member of the head version (every revision, in a selection) as a resolver does (section 12.3), and the members held in the archive in every earlier version; resolving the other members of earlier versions is OPTIONAL. The status of each member is a result (section 8.5). It also checks that no two selections of the archive with the same owner keep accepted copies of the same document (section 9.6). A member that is not a version is an error, and so is a mismatch of a copy held in the archive; any other status but verified, contested included, is a warning.

### 14.6 The archive as a whole

The verifier then checks, against the objects:

- **the discovery document** (section 3.1): that `objects` lists every object of the storage root except drafts, each entry with the values its object gives (`status` as section 13.1 says), with distinct labels; that `mainCollection` names a catalogue it lists and, a breach being a warning, when `owners` is present, that its members are lines of those owners (section 8.1); that `drafts` lists only drafts of the storage root, with their heads; and, a breach being a warning, that `owners` lists only owner objects it holds and `extensions` every extension its objects use;
- **the tombstones** (section 13.3): that each is well formed, with `id` the line of its `name` and `owner`; that no two have the same `id`; and that no object of the storage root, and no entry of `objects`, has the `id` of one; and, as a warning, that no tombstone stands for an owner object that objects of the archive need, which only the law or its keeper justifies (section 13.2);
- **the indexes** it declares (section 12.5): that every object with a genesis record and every sealed version, carried key-log versions included, has its entry, in the file of its prefix, with the values its object gives; that each tombstone has its entries in `names/` and `sha512/`, with `status` `removed`, and none in `owners/`; that no draft has one; and, with access to the files, that there are no other entries.

**Beyond the archive.** A verifier SHOULD check the copies it knows elsewhere (the sources of mirrors, members, parents, longer key logs): whether they agree (section 7.4), reporting a fork of a line with the status of each side and where each copy was found, a later version of a key log (section 6.5), and a fork of a key log between its copy and copies elsewhere, with its fork point (section 6.3). It SHOULD check the requirements of the profiles the archive declares (appendix A), the witnesses it finds and the extensions it knows, and warns of those it does not know (sections 2 and 7.2).

**Open questions.**

- Which status a member has when the checksum file of its inventory is missing or wrong (#48), and whether a mismatch at the member's archive falls through to mirrors (#37).
- Whether digests in OCFL files must be in lower case (#49).
- The parts of section 4.2 that the files do not decide: whether a version deposited out of order wrote `history` (#51), and when a document version is new (#23).
- How a verifier tells a licence from a rights statement in `rightsList` (#50), and which licences allow a mirror (#34), which is therefore not checked.
- What a verifier reports for a pin of an earlier version of a withdrawn line (#25).
- Fork records and exposed keys, provisional (sections 6.3 and 6.4; #58).

## 15. Security, privacy and rights

### 15.1 What the format protects

Pins and signatures make every copy checkable wherever it is fetched (sections 4 and 7); discovery documents, indexes, locations and tombstones are maps and hints (sections 3, 12.3 and 13.3). A host or a network therefore cannot forge a version, nor add one to another owner's line (section 7.5), nor make a valid line from a reused genesis record (section 5.4), nor take over a short form (section 12.2). It can withhold: serve an older copy, or a key log that stops before an end or a fork record, which looks complete (sections 6.5 and 12.3); and it can delete what it serves, never a copy held elsewhere (section 13).

Whoever holds `threshold` current keys of an owner signs versions of its lines as that owner until the owner exposes them, after which what those keys alone sign is contested, and archives aware of it never add it (sections 7.3 and 7.5), though readers still find its signatures good; it cannot change the key log, which only rotation keys sign. Whoever holds `nextThreshold` rotation keys of the latest version of a key log, not revealed, takes the owner over (with a `nextThreshold` of 1, a single key, section 6.2), without a fork, by signing the next version with keys of its own; the owner can then only end it, and only if it still holds copies of those keys itself, by signing another version of that number, a fork (section 6.3). Whoever holds `nextThreshold` rotation keys of an earlier version, kept after use, can fork the key log there, which ends the owner and freezes it (section 7.5). No one can fork a key log at its first version, which is computed from the genesis record (section 6.1). The format cannot tell what was signed before an exposure from what was signed after (section 6.4).

**The keeper.** The keeper an owner names, at most one, fixed by its owner name, names the accepted successor when no ending version before any fork point names one, and may have the owner object taken down from an archive that keeps it (sections 6.6 and 13.2). Whoever controls the keeper's ORCID record or domain holds these powers, also after a domain lapses and is registered by someone else, or an account is taken over; an owner whose keeper may lapse is better named with an institution's domain, or with no keeper.

**Residual risks.** The format leaves these to readers and to other evidence:

- a host can withhold an exposure or a fork record, serving a key log that stops before it, so that its readers find signed and uncontested what is contested elsewhere, and an archive it serves does not yet freeze the owner (sections 6.5 and 7.5);
- archives that see one side of a fork and not yet the other show different views of the owner until a copy holding both reaches them (section 6.3);
- whoever holds the old current keys of an owner that ended honestly signs versions of its lines naming key-log versions before the end, which are signed and not contested unless those keys were exposed; archives take them only from copies (section 7.5), which the holder can make;
- a thief gains no forgery by forking a key log, since the fork freezes the owner and what it signs is contested; but on its side it may expose the owner's earlier keys, which makes the owner's own versions signed with them contested unless trusted evidence dates them (sections 6.3 and 7.3): this harms trust in the owner's past, and never lets a forgery pass; and an owner whose rotation keys are stolen can add nothing more under that identity, and continues under a successor (sections 6.6 and 7.5);
- a timestamp dates what a thief signs between a theft and its exposure as well as what the owner signed, so evidence that dates a version before the exposure admits both (section 7.3);
- a retired key never exposed still makes good, uncontested signatures naming the versions that list it (section 6.2); an owner unsure that a retired key is destroyed exposes it;
- the keeper, as above.

**Forks of a line.** A fork of a line whose sides are both signed (section 7.4) ends nothing by itself; whether to end is the owner's call. If the owner did not make both sides, its current keys may have been exposed, and section 6.3 applies; if it did (two tools, a version made again), it continues from one side, and archives holding the other keep it (section 7.5).

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
- **Owners.** An owner name is the digest of a record with a random nonce, and identifies no one. An owner is tied to a person only by what its versions say (`creators`, `user`, `agreement`), by keys it shares with another owner, and by its keeper, who alone confirms that link and can withdraw the confirmation (section 6.6), though `keeper` stays in the genesis record. An owner that must stay anonymous (a referee) SHOULD have its own keys and no `keeper`, and its versions SHOULD NOT identify the person.
- **Erasure.** Personal data is erased by a takedown (section 13.2), from that archive and its indexes only. The tombstone and index entries keep only names, owner names and digests, which identify no one (section 13.3); an archive kept in git also rewrites its history ([OpenSheaf archives in git](opensheaf-git-0.1.md), section 9).

### 15.6 Rights

**Metadata.** The JSON files this specification defines, inventories with their checksum files, fork records and the evidence of branches are metadata, texts of notes and abstracts included. Whoever writes them dedicates them to the public domain under CC0 1.0, so that they can be harvested and copied freely; an archive admits only owners that accept this. Files of notes (section 4.3) are content.

**Content.** The files of a document version are under the licence its owner states (sections 4.3 and 4.4); "All rights reserved" is allowed, since depositing grants readers access, not reuse. Copies and branches keep the licences of what they copy, and need the right to redistribute it (sections 9.7 and 11.2).

**Open questions.**

- Which licences allow a mirror, and how a verifier tells a licence from a rights statement (#34, #50); copying by the agreement of the rights holders (#39).
- Whether a takedown reaches mirrors, branches holding the files, indexes kept by others and gateways (#33).
- Private archives and drafts, anonymous referees and the secrets of a review (#29).
- Tying owners to ORCID iDs and domains beyond the keeper (#41).

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
- **0.1 (draft), 19 November 2026 (PR #30):** the rebuilt text completed and audited. Appendices A (profiles), B (JSON Schemas) and C (examples, computed and checked against the schemas) rebuilt; DOIs written bare; conformance classes; one status rule for lines, read from the latest signed version (section 13.1); signature files closed to other properties, and owner names, `did:key` URIs and ORCID check digits checked exactly (appendix B, sections 6.6 and 14.3). Key logs, provisional (#58), replacing the fork records that nullified keys and the healing of the rebuilt text: pre-rotation, as in KERI, current keys (`keys`, `threshold`) signing lines, and each version committing in `next` and `nextThreshold` to the digests of the rotation keys that alone sign the next one, each committed in one version only and never made current, with three rotation keys and a threshold of 2 recommended and one offline key with a threshold of 1 allowed, its risk stated (sections 6.1 and 6.2); the first version of a key log computed from the owner's genesis record, byte for byte, and never signed (section 6.1); the keeper, at most one, and the data of extensions of the first version fixed in that genesis record (sections 5.1 and 6.6); `exposed`, in a version that whoever holds current keys cannot contest, an exposure counting in any version, on either side of a fork (section 6.3); an ending version without keys, and at most one accepted successor (sections 6.3 and 6.6); a fork of a key log ends the owner, the archive keeping the side it saw first and appending a fork record that carries the other, and freezes it, nothing more being added unless trusted evidence dates it before the fork (sections 6.3 and 7.5); one status, contested, for versions of lines that need an exposed key or name a key-log version from a fork point on, which owner tools show before extending them, and which an owner not ended may sign again (sections 6.4, 7.1 and 7.3); owner objects taken down only by law or at the keeper's request (section 13.2); strict Ed25519 verification (section 7.2). The inventory chain: every sealed version after the first has `previous` in `object.json`, the digest of the inventory file before it, so that signing a version fixes the bytes of every earlier inventory, and pins of versions vouched for are as reliable as those of versions signed directly (sections 4, 4.3, 7.3 and 14.2; #46). The owner-name layout is described by the plain text file `opensheaf-owner-name-storage-layout.md` in the storage root instead of `ocfl_layout.json`, which names only registered OCFL extensions, the discovery document being authoritative (sections 3.2 and 14.2). Readability: the rules of sections 6.1, 6.3, 7.3 and 14.3 numbered, a walkthrough of the common path at the head of appendix C, and clarifications on names of algorithms 1 to 15 (section 5.2), the owners of the main catalogue (section 8.1), drafts and OCFL (section 10.1), rules not checked from the files (section 14) and the validation of `datacite.json` (appendix B); rules stated once; the checks of section 14 and the risks of section 15.1 completed.

## Appendix A. Profiles (normative for archives declaring them)

A <dfn>profile</dfn> is a set of rules for an external service or a tool, normative for an archive that lists it in `profiles` (sections 2 and 3.1), and checked by verifiers (section 14.6). A profile only adds rules. They apply to the versions that owners make in the archive, never to copies of lines made elsewhere (section 11); only sealed, signed versions are deposited (sections 7.3 and 10.1).

### A.1 Zenodo (`zenodo`)

Zenodo registers DataCite DOIs (prefix `10.5281`) and keeps files permanently. A record is a witness of the versions it holds, not a copy (section 12.3).

- **Records.** Each line of a document is one record, whose concept DOI stands for the line. Each document version is one version of the record, with its own DOI, the document version as Zenodo's version, and the Zenodo type `publication-preprint` or the one matching `resourceTypeGeneral`. A branch is a record of its own, and deposits a version holding the files of its branch point only when the parent version has no DOI (section 9.7).
- **Fixed files.** A description-only version (section 4.2) edits the metadata of the record version of the document version it holds; the files it adds, and the sources added by a completion (section 4.2), are not uploaded, since the files of a published record version are fixed. Archives MUST NOT use Zenodo's 30-day window for changing them: a correction is a new document version.
- **Versions out of order.** Zenodo orders the versions of a record by publication, and its concept DOI leads to the latest. A document version deposited out of order (section 4.2) MAY be deposited only as a record of its own, with `IsVersionOf` the concept DOI.
- **Files.** The record version holds the content files of the object version. Records have no folders and a limited number of files: sources with sub-folders, or too many, are uploaded as one file `sources.zip`, at their logical paths, its entries in the byte order of their names, dated 1980-01-01 00:00:00, without extra fields. The inventories of the line MUST record in `fixity` the MD5 digest of every content file (section 4.1), to be compared with the checksums Zenodo reports.
- **The deposit recorded.** The object version deposited has its DOI in `datacite.json` and, in `external` of `object.json` (section 4.3), an entry with `role` `deposit`, `service` `Zenodo`, `record` the URL of the record version, `doi` and, for `sources.zip`, `files`, with its `md5`.
- **Order of operations.** (1) Create an unpublished version of the record (a new version inherits the files of the previous one, which are deleted). (2) Reserve its DOI. (3) Build the object version in a staging area, with that DOI, and have its owner sign it (section 7.1). (4) Upload the files, and compare their MD5 checksums with the fixity block, and that of `sources.zip` with its `md5` in `external`. (5) Publish. (6) Add the object version with its signature files (section 7.5), and update the discovery document. If a step fails before publication, the unpublished version is discarded; if step 6 fails after it, the tool MUST complete step 6 from the staging area before any other deposit of the line, signing the version again with current keys not exposed (section 7.1) if a key that signed it was exposed meanwhile. A tool SHOULD hold a lock per line during a deposit, since Zenodo allows one unpublished version per record. DOIs of Zenodo's sandbox are not registered, and MUST NOT be recorded in an archive.
- **Metadata.** Zenodo's DataCite record of a DOI has Zenodo's landing page as `url`, Zenodo as `publisher` (which `datacite.json` MAY also name, section 4.4), relations of its own, and only the properties Zenodo keeps. `datacite.json` stays authoritative; verifiers compare the DOI, `titles`, `creators`, `publicationYear` and `version` of the two, a difference being a warning.
- **Collections.** A collection MAY be deposited when its curator releases it, not at every change, as a record of type `other` whose files include `members.json`. A Zenodo community MAY group an archive's records for browsing; it is not authoritative.

### A.2 TeXmacs (`texmacs`)

For a document whose main source is a TeXmacs document:

- `sourceFormat` is `application/x-texmacs` (not a registered media type; the type TeXmacs uses);
- `toolchain` has an entry for TeXmacs with its version, whose `packages` list the style packages and plugins used that are not part of the TeXmacs distribution;
- renditions are produced without regenerating bibliographies or tables of contents, so that the sources, with the references stored in them, reproduce the renditions; the sources SHOULD nevertheless include the bibliography databases used;
- HTML presentation files are exported from a copy of the sources, with presentation packages added to its style, and the deposited sources are never changed.

An archive kept inside a website built with the TeXmacs website converter SHOULD place an empty file `.texmacs-noconvert` at its top (honoured by the `max-html` plugin), so that the converter never rewrites its files.

### A.3 Website (`website`)

Presentation files (section 3) are generated from the storage root, never edited by hand, and regenerated after every change, a takedown included (section 13.2). Under this profile:

- **Index.** An index page presents the latest signed version (section 7.3) of the main catalogue (section 8.1), in its order, possibly over several pages; other collections MAY have pages of their own. A flattened list, not authoritative, for programs that do not read OCFL MAY be published as `catalog.json`.
- **Landing pages.** Each line of the main catalogue has one landing page, for its current version (section 4.2), giving the full `sheaf:` URI of the line (section 12.2) and every signed document version in the order of the history, each with its external labels, stage, change note, notices, renditions, sources and DOI, and the withdrawal if any (sections 4.2, 4.3 and 13.1).
- **Search engines.** Landing pages MUST carry the meta tags read by Google Scholar: `citation_title`, `citation_author` (one per creator), `citation_publication_date` (the `Issued` date, or else the `Available` date of the current version) and `citation_pdf_url`, a PDF on the landing page's host (served with `Content-Security-Policy: sandbox`, section 15.3). They SHOULD carry schema.org `ScholarlyArticle` JSON-LD and FAIR Signposting links (`cite-as`, `describedby`, `item`, `license`), and offer BibTeX and CSL-JSON entries made from `datacite.json`.
- **Feed and harvesters.** The feed (`feed`, section 3.1) lists the signed object versions the archive holds, by the `created` date of their inventories. The website SHOULD publish a `sitemap.xml`, and MAY publish an OAI-PMH static repository or a ResourceSync description.

## Appendix B. JSON Schemas (normative)

The schemas are written in JSON Schema 2020-12, published at `https://opensheaf.org/schemas/<file>`, their `$id`, and dedicated to the public domain under CC0 1.0 (section 15.6). They validate:

- `opensheaf-archive-0.1.schema.json`: `opensheaf.json` (section 3.1);
- `opensheaf-object-0.1.schema.json`: `object.json`, also as `parent.object.json` and in `parent.chain/` (sections 4.3 and 9.2);
- `opensheaf-collection-0.1.schema.json`: `members.json` (section 8.2);
- `opensheaf-genesis-0.1.schema.json`: `genesis.json` (section 5.1);
- `opensheaf-keys-0.1.schema.json`: `keys.json`, also as carried by fork records (section 6);
- `opensheaf-signature-0.1.schema.json`: signature files, wherever kept or carried, and others' `witness-<label>.json` (sections 7.2 and 9.2);
- `opensheaf-keeper-0.1.schema.json`: `/.well-known/opensheaf` (section 6.6);
- `opensheaf-index-0.1.schema.json`: index files and `indexes.json` (section 12.5).

**Validation.** A file is valid when it validates against its schema with `format` asserted (section 14.2). The schemas of `genesis.json`, `keys.json`, signature files and the keeper's file allow no other properties; the others do, and such properties carry no meaning here (the data of extensions goes under `extensions`, section 2). Where a schema and the text disagree, the text prevails.

**Other files.** `datacite.json` is validated by converting it to XML against the DataCite 4.7 XML Schema, with the requirements of section 4.4. The conversion follows the correspondence between the attributes of a DOI in DataCite's REST API and the elements of DataCite XML that DataCite documents (its "DataCite XML to JSON Mapping", appendix E), property by property, for the properties of schema 4.7; a verifier without such a converter checks at least the requirements of section 4.4, and warns that the rest was not checked (section 14.1). Inventories, their checksum files and `ocfl_layout.json` are OCFL's (section 14.2). The schema of the [timestamps extension](opensheaf-timestamps-0.1.md) is published with it.

**Beyond the schemas.** A schema checks one file alone; whatever relates it to another file, its place, a digest or a key (names and identifiers, `documentVersion` and `datacite.json`, thresholds, signatures, fork records, uniqueness across entries, index prefixes) is checked by verifiers (section 14).

**Open questions.**

- Registering DOIs with an archive's own DataCite prefix (a `datacite` profile), and documents that already have a DOI elsewhere (#8).
- Whether a Zenodo record version also uploads the version's inventory file, its checksum file and its signature files, so that it can be checked against a pin (#22; section 12.6).
- Whether a takedown reaches the records of external services (#33).
- The field names of `keys.json`, signature files and the evidence of branches, which the schemas follow (#55); `next`, `nextThreshold`, `exposed` and the files of fork records, provisional (#58).
- Which converter is the reference for validating `datacite.json` through XML, since DataCite documents the correspondence but specifies no converter for it (#60).

## Appendix C. Examples (non-normative)

The examples follow one paper of the first archive (section 1) through an illustrative history: its owner is created, the paper is sealed and revised, kept in the archive's main catalogue, and accepted by a journal, which keeps an accepted copy and lists it in an issue. The title and the authors are those of the archive; the dates, the journal and its domain are invented, and the DOIs (with Zenodo's prefix) and the ORCID iD (with a valid check digit) are placeholders. Every name, owner name, `did:key`, file name derived from a key or a digest, and signature is computed: names from the genesis records shown (section 5.2), keys from private keys made for these examples, signatures over the messages shown (section 7.2), and inventory digests from inventories that are not shown. The exceptions are the names of the timestamp files of section C.6, which stand for tokens that are not shown, and the fingerprint of the timestamp authority, a placeholder. Every JSON file shown validates against its schema (appendix B).

**The common path.** In brief, what an owner does in the common case; the sections cited give the rules, and the examples below show the files.

1. **Create an owner** (sections 5.1, 6.1 and 6.2). The owner tool makes a current key on each device the owner signs from, and rotation keys kept offline, apart from those devices and from each other: three hardware tokens with a `nextThreshold` of 2, or at least a single key, printed or on a USB key, with a `nextThreshold` of 1. It writes the owner's genesis record, with the current keys, the digests of the rotation keys and, if wanted, a keeper. The owner name is the digest of that record, and the first version of the key log is computed from it (section C.1). The rotation keys are then put away: they are used only to change keys.
2. **Deposit a paper** (sections 4, 7.1 and 10.2). When the paper first leaves the owner's hands, the tool seals it: it writes a genesis record naming the owner as `originator`, makes the object `sheaf:<name>:<owner>` at `<owner>/<name>/`, whose version `v1` holds the sources, a PDF, `genesis.json`, `object.json` and `datacite.json`, and signs it with a current key, naming the latest version of the key log (sections C.2 and C.3). The owner object goes beside it in the storage root, and the discovery document lists both (section 6.5, section C.6).
3. **Make a new version** (sections 4.2, 4.3 and 7.1). A corrected paper is a new object version, `v2`, holding document version 2. Its `object.json` has `previous`, the digest of the inventory file of `v1`, and it is signed like the first; signing it fixes `v1` too, byte for byte, so a pin of either is reliable (section C.2).
4. **Follow it in a catalogue** (sections 8.1 to 8.3). The archive's main catalogue, a collection of the same owner, pins each paper by its object version and inventory digest; with `follow` `latest`, its tool writes a new version of the catalogue pinning `v2` once `v2` is signed (section C.4). A journal that accepts the paper keeps an accepted copy, a branch of its own, and lists it in a selection (sections C.4 and C.5).

A new device, or a lost one, is a new version of the key log, signed by the rotation keys (section C.1); a stolen key is exposed the same way (section C.8).

### C.1 An owner and its key log

The genesis record of the authors' owner, which follows section 6.2: one current key, made on the laptop the authors sign from, with a `threshold` of 1, and the digests of three rotation keys, each on a hardware token of its own kept apart, with a `nextThreshold` of 2; the keeper, an ORCID iD, fixed with the owner name (section 6.6); and the [timestamps extension](opensheaf-timestamps-0.1.md), adopted with one RFC 3161 authority (a placeholder fingerprint):

```json
{
  "format": "opensheaf-genesis/0.1",
  "kind": "owner",
  "created": "2026-03-01T17:40:00Z",
  "nonce": "1b4d9964664d9825076eb8558af61162",
  "keys": [
    "did:key:z6MksKLDefPeXwhL6SJCLqpW1dGZcvBjfsv9mxGCFpMkMuVW"
  ],
  "threshold": 1,
  "next": [
    "oxthfb6b4q3sqathmcpnciqggfxlr3aekgfg2tpm2lgrm2qnalha",
    "h6k4k6c5u4dusj4szwimmaa5cozrwu4jo45xa6erpjggpyvla6vq",
    "lnaifwjnrmhyjj3x7uikmzxznxfbgydi25iftupd2ktobmnpaklq"
  ],
  "nextThreshold": 2,
  "keeper": [
    "https://orcid.org/0000-0002-1234-5677"
  ],
  "extensions": {
    "https://opensheaf.org/opensheaf-timestamps-0.1": {
      "timestampAuthorities": [
        "5b4e3f0c9d2a7e18c6f4b0a39d7e2c51f8a6b3d09e4c7a12f5b8d6e3a0c9f147"
      ]
    }
  }
}
```

Its name, the owner name, is `wmkg2sy2xl2z5xcthvxuyhconwpus4pojadq65yrjnla75ydrzhq`: the SHA-256 digest of `opensheaf-name-0`, a line feed and the bytes shown, with a final line feed, in base32 (section 5.2). The owner object is at `wmkg2sy2xl2z5xcthvxuyhconwpus4pojadq65yrjnla75ydrzhq/wmkg2sy2xl2z5xcthvxuyhconwpus4pojadq65yrjnla75ydrzhq/` in the owner-name layout (section 3.2). The first version of its key log is computed from the genesis record, and holds nothing else (section 6.1): `genesis.json`, the bytes shown; `object.json`, whose fields every later version repeats, adding `previous` (below); and `keys.json`, which holds only the `keys`, `threshold`, `next` and `nextThreshold` of the genesis record. Both are the JCS form (RFC 8785) of their fields, without a final line feed:

```json
{"format":"opensheaf-object/0.1","kind":"owner","name":"wmkg2sy2xl2z5xcthvxuyhconwpus4pojadq65yrjnla75ydrzhq","owner":"wmkg2sy2xl2z5xcthvxuyhconwpus4pojadq65yrjnla75ydrzhq","specification":"0.1","status":"active"}
```

```json
{"format":"opensheaf-keys/0.1","keys":["did:key:z6MksKLDefPeXwhL6SJCLqpW1dGZcvBjfsv9mxGCFpMkMuVW"],"next":["oxthfb6b4q3sqathmcpnciqggfxlr3aekgfg2tpm2lgrm2qnalha","h6k4k6c5u4dusj4szwimmaa5cozrwu4jo45xa6erpjggpyvla6vq","lnaifwjnrmhyjj3x7uikmzxznxfbgydi25iftupd2ktobmnpaklq"],"nextThreshold":2,"threshold":1}
```

The inventory of the first version is the JCS form of the following JSON value, shown here indented: the digests are those of the three files, `created` is that of the genesis record, and there is no `message` or `user`. Its SHA-512 digest is `05823c3e4bc200eb136103d10001074a9eb8732ac1e44907ed4ed29ff480fa10d4adbb88a8c686d003d7e0feab6a678b6bc7b853fc1d9b2f1f91ea66e40d94c4`, so this version is pinned by `sheaf:wmkg2sy2xl2z5xcthvxuyhconwpus4pojadq65yrjnla75ydrzhq/v1?sha512=05823c3e4bc200eb136103d10001074a9eb8732ac1e44907ed4ed29ff480fa10d4adbb88a8c686d003d7e0feab6a678b6bc7b853fc1d9b2f1f91ea66e40d94c4` (section 12.1). It is not signed, and the owner object's witness folder holds no signature file for it:

```json
{
  "digestAlgorithm": "sha512",
  "head": "v1",
  "id": "sheaf:wmkg2sy2xl2z5xcthvxuyhconwpus4pojadq65yrjnla75ydrzhq:wmkg2sy2xl2z5xcthvxuyhconwpus4pojadq65yrjnla75ydrzhq",
  "manifest": {
    "697f383656ecfa2fec1e3e47faeed0abd5e31e495c8201a0ce90ab888e9fe302aeba0dedba8e5a65a59cb9e37fb9c3c761c2bc12bb12fc3a866abf37c66a1efb": [
      "v1/content/genesis.json"
    ],
    "b8ae4e8fe94c0cd4710b6c4d4f50d4eb7eb6124ef0057275fbf03e475858d68150659b4e442b59c2699b6671f5fbe6ffa1d1dd3e05beafe23f33f66cd8df3c19": [
      "v1/content/object.json"
    ],
    "d990e7ade9da464a1c1928ad3c762dfd7ab17cdc4ceb7a06046b5836f5d95f00257aa7fbccd3d7864206527f6485661075c9dc76a14146aa77fb4ef339022077": [
      "v1/content/keys.json"
    ]
  },
  "type": "https://ocfl.io/1.1/spec/#inventory",
  "versions": {
    "v1": {
      "created": "2026-03-01T17:40:00Z",
      "state": {
        "697f383656ecfa2fec1e3e47faeed0abd5e31e495c8201a0ce90ab888e9fe302aeba0dedba8e5a65a59cb9e37fb9c3c761c2bc12bb12fc3a866abf37c66a1efb": [
          "genesis.json"
        ],
        "b8ae4e8fe94c0cd4710b6c4d4f50d4eb7eb6124ef0057275fbf03e475858d68150659b4e442b59c2699b6671f5fbe6ffa1d1dd3e05beafe23f33f66cd8df3c19": [
          "object.json"
        ],
        "d990e7ade9da464a1c1928ad3c762dfd7ab17cdc4ceb7a06046b5836f5d95f00257aa7fbccd3d7864206527f6485661075c9dc76a14146aa77fb4ef339022077": [
          "keys.json"
        ]
      }
    }
  }
}
```

When the laptop is replaced, the second version lists the new laptop's key and retires the old one (section 6.2). It is signed by two of the three tokens, in `v2/signature-oxthfb6b4q3sqath.json` and `v2/signature-h6k4k6c5u4dusj4s.json` of the owner object's witness folder, each naming the first version by its pin; `oxthfb6b4q3sqath` and `h6k4k6c5u4dusj4s` begin two digests of `next` in the first version, whose keys the signature files reveal. The first of them:

```json
{
  "format": "opensheaf-signature/0.1",
  "object": "sheaf:wmkg2sy2xl2z5xcthvxuyhconwpus4pojadq65yrjnla75ydrzhq:wmkg2sy2xl2z5xcthvxuyhconwpus4pojadq65yrjnla75ydrzhq",
  "version": "v2",
  "inventorySha512": "7fdfdda7962ba1056084741253ca508cce2b3fa07953e6c377c53bcf54864304e38fa0fed7182f73426dd2d35c77623296e64ddeea89964eccc56f070d1bfffb",
  "signer": "wmkg2sy2xl2z5xcthvxuyhconwpus4pojadq65yrjnla75ydrzhq",
  "key": "did:key:z6Mkh5i2epG9LsWNnYbBHG7ctEiNLZPjsBNXxNUcsaYgEtNm",
  "keyLog": "sheaf:wmkg2sy2xl2z5xcthvxuyhconwpus4pojadq65yrjnla75ydrzhq/v1?sha512=05823c3e4bc200eb136103d10001074a9eb8732ac1e44907ed4ed29ff480fa10d4adbb88a8c686d003d7e0feab6a678b6bc7b853fc1d9b2f1f91ea66e40d94c4",
  "signature": "GY9+I1T2O5vELZxuJD/WO//Kd5VLxyZlF7fEJoLOm1ju/Lmxhrlgv7HR9iXXPeTTryL/bs3PalyM3/7atY8/AQ=="
}
```

Every token of the first version, the third, which did not sign, included, is then destroyed, and `next` commits three new ones, since a rotation key is committed in one version only (section 6.1); the data of the timestamps extension, declared in the genesis record, is repeated:

```json
{
  "format": "opensheaf-keys/0.1",
  "keys": [
    "did:key:z6MkugKqPPkysjyartSzszBbMh8fVhENmqGXvddtD8DDvThn"
  ],
  "threshold": 1,
  "next": [
    "j77iavvdclktxkwmwefs7lw6fisdi7lqphwe33g4nboea35t2zga",
    "nzvwkea25p62akdygzheep4qgoo3fw7ryimwytckea4njabtlfzq",
    "fhujijfn3zmvteieps5l6raae73kndteaoju5js3ja33l2wvrqmq"
  ],
  "nextThreshold": 2,
  "extensions": {
    "https://opensheaf.org/opensheaf-timestamps-0.1": {
      "timestampAuthorities": [
        "5b4e3f0c9d2a7e18c6f4b0a39d7e2c51f8a6b3d09e4c7a12f5b8d6e3a0c9f147"
      ]
    }
  }
}
```

Its `object.json` repeats the fields of that of the first version, and adds `previous`, the digest of the inventory file of the first version, which fixes the bytes of that inventory (section 4.3):

```json
{"format":"opensheaf-object/0.1","kind":"owner","name":"wmkg2sy2xl2z5xcthvxuyhconwpus4pojadq65yrjnla75ydrzhq","owner":"wmkg2sy2xl2z5xcthvxuyhconwpus4pojadq65yrjnla75ydrzhq","previous":"05823c3e4bc200eb136103d10001074a9eb8732ac1e44907ed4ed29ff480fa10d4adbb88a8c686d003d7e0feab6a678b6bc7b853fc1d9b2f1f91ea66e40d94c4","specification":"0.1","status":"active"}
```

The journal's owner, `a3fh2fbfja6kewlsvd466qc4jzj63cextra2h74rfff5p5tcfjwa`, is a group: three current keys, one for each of its editors, with a `threshold` of 2, so that every version it makes carries two signature files, and three rotation keys with a `nextThreshold` of 2; its genesis record names its domain, `https://journal.example.org/`, as keeper.

### C.2 A document version

The genesis record of the paper, written when the owner sealed it (section 10.2):

```json
{
  "format": "opensheaf-genesis/0.1",
  "kind": "document",
  "created": "2026-03-02T09:14:00Z",
  "originator": "wmkg2sy2xl2z5xcthvxuyhconwpus4pojadq65yrjnla75ydrzhq",
  "nonce": "6f65cd32058c16d6d78b05011772ff1d"
}
```

Its genesis name is `7zorzcm4euymqzldcvzyyg46w7z2admlgmn5lz7rosperrskp7ua`; by algorithm 1 its name is `raezw7zvgrh6ysti3pp2srz5gfadjziojvlrikl2egbxu5iny5qb`, which a branch renamed after a clash would take (section 5.3). The line is `sheaf:7zorzcm4euymqzldcvzyyg46w7z2admlgmn5lz7rosperrskp7ua:wmkg2sy2xl2z5xcthvxuyhconwpus4pojadq65yrjnla75ydrzhq`. The `object.json` of its first version (section 4.3), which was deposited with Zenodo (appendix A.1):

```json
{
  "format": "opensheaf-object/0.1",
  "specification": "0.1",
  "kind": "document",
  "name": "7zorzcm4euymqzldcvzyyg46w7z2admlgmn5lz7rosperrskp7ua",
  "owner": "wmkg2sy2xl2z5xcthvxuyhconwpus4pojadq65yrjnla75ydrzhq",
  "documentVersion": 1,
  "mainSource": "fractional-phi42-mass-gap.tm",
  "sourceFormat": "application/x-texmacs",
  "renditions": [ { "path": "fractional-phi42-mass-gap.pdf", "mediaType": "application/pdf" } ],
  "toolchain": [ { "name": "TeXmacs", "version": "2.1.5" } ],
  "stage": { "scheme": "NISO-JAV", "value": "AO" },
  "agreement": { "by": [ "P. Duch", "M. Gubinelli" ], "date": "2026-03-01", "method": "by e-mail" },
  "external": [ { "role": "deposit", "service": "Zenodo",
                  "record": "https://zenodo.org/records/1234567", "doi": "10.5281/zenodo.1234567" } ],
  "status": "active"
}
```

The `datacite.json` of the same version (section 4.4). The version has a Zenodo DOI, so Zenodo is its `publisher`, and `url` (section 4.4) is the version's landing page on the archive's website (appendix A.3), while Zenodo's own record of the DOI has Zenodo's (appendix A.1):

```json
{
  "doi": "10.5281/zenodo.1234567",
  "url": "https://mgubi.org/papers/fractional-phi42-mass-gap/",
  "version": "1",
  "types": { "resourceTypeGeneral": "Preprint" },
  "titles": [ { "title": "Mass gap for the fractional $\\Phi^4_2$ model" } ],
  "creators": [
    { "name": "Duch, P.", "nameType": "Personal", "givenName": "P.", "familyName": "Duch" },
    { "name": "Gubinelli, M.", "nameType": "Personal", "givenName": "M.", "familyName": "Gubinelli",
      "nameIdentifiers": [ { "nameIdentifier": "https://orcid.org/0000-0002-1234-5677",
                             "nameIdentifierScheme": "ORCID" } ] } ],
  "publisher": { "name": "Zenodo" },
  "publicationYear": 2026,
  "dates": [ { "date": "2026-03-02", "dateType": "Issued" },
             { "date": "2026-03-02", "dateType": "Available" } ],
  "rightsList": [ { "rights": "Creative Commons Attribution 4.0 International",
                    "rightsUri": "https://creativecommons.org/licenses/by/4.0/",
                    "rightsIdentifier": "cc-by-4.0", "rightsIdentifierScheme": "SPDX" } ],
  "descriptions": [ { "description": "We present a new, simple ...",
                      "descriptionType": "Abstract" } ],
  "formats": [ "application/x-texmacs", "application/pdf" ],
  "relatedIdentifiers": [ { "relatedIdentifier": "10.5281/zenodo.1234566",
                            "relatedIdentifierType": "DOI", "relationType": "IsVersionOf" } ]
}
```

The second object version holds document version 2 (section 4.2), corrected after the referee's report and accepted by the journal: its `object.json` has `previous`, the digest of the inventory file of the first version (section 4.3), `documentVersion` 2, `changes`, `stage` `AM` and the DOI `10.5281/zenodo.1234568`, and its `datacite.json` has `version` `"2"` and `IsNewVersionOf` the DOI of version 1.

### C.3 A signature

The signature of that version by the new laptop's key, `extensions/opensheaf-witnesses/v2/signature-4hz7zgsiazl6hx7i.json` in the paper's object, `4hz7zgsiazl6hx7i` being the first 16 characters of the base32 SHA-256 digest of the `did:key` (section 7.2); it names version 2 of the key log, which lists the key:

```json
{
  "format": "opensheaf-signature/0.1",
  "object": "sheaf:7zorzcm4euymqzldcvzyyg46w7z2admlgmn5lz7rosperrskp7ua:wmkg2sy2xl2z5xcthvxuyhconwpus4pojadq65yrjnla75ydrzhq",
  "version": "v2",
  "inventorySha512": "a269c26a28cb2a0b2d3e3a41c73d463f2d37e80e6c8ca2ff07b3ca8481be1b233e23cae5055ebb372cd786e95947cf20f128ca385993d488f99726a72503de7a",
  "signer": "wmkg2sy2xl2z5xcthvxuyhconwpus4pojadq65yrjnla75ydrzhq",
  "key": "did:key:z6MkugKqPPkysjyartSzszBbMh8fVhENmqGXvddtD8DDvThn",
  "keyLog": "sheaf:wmkg2sy2xl2z5xcthvxuyhconwpus4pojadq65yrjnla75ydrzhq/v2?sha512=7fdfdda7962ba1056084741253ca508cce2b3fa07953e6c377c53bcf54864304e38fa0fed7182f73426dd2d35c77623296e64ddeea89964eccc56f070d1bfffb",
  "signature": "RgA4ue6yWUrcrjWDOwOuyEqSMUZwN00eVkjjtZzLBRzgpOiBjVtxWBsbizhs5SuDdaUuSiOMPoKNnwAmbfF7BQ=="
}
```

The message it signs, each line ended by a line feed (section 7.2):

```
opensheaf-signature/0.1
object sheaf:7zorzcm4euymqzldcvzyyg46w7z2admlgmn5lz7rosperrskp7ua:wmkg2sy2xl2z5xcthvxuyhconwpus4pojadq65yrjnla75ydrzhq
version v2
inventory a269c26a28cb2a0b2d3e3a41c73d463f2d37e80e6c8ca2ff07b3ca8481be1b233e23cae5055ebb372cd786e95947cf20f128ca385993d488f99726a72503de7a
keylog sheaf:wmkg2sy2xl2z5xcthvxuyhconwpus4pojadq65yrjnla75ydrzhq/v2?sha512=7fdfdda7962ba1056084741253ca508cce2b3fa07953e6c377c53bcf54864304e38fa0fed7182f73426dd2d35c77623296e64ddeea89964eccc56f070d1bfffb
```

With a threshold of 1, this one good signature makes the version signed (section 7.3).

### C.4 Collections

The `members.json` of the second version of the archive's main catalogue (section 8.3), owned by the authors' owner. The member is followed, so that when version 2 of the paper was signed, the catalogue's tool wrote this version, pinning it in place of version 1:

```json
{
  "format": "opensheaf-collection/0.1",
  "type": "catalogue",
  "order": "issued-desc",
  "members": [
    { "kind": "document",
      "name": "7zorzcm4euymqzldcvzyyg46w7z2admlgmn5lz7rosperrskp7ua",
      "owner": "wmkg2sy2xl2z5xcthvxuyhconwpus4pojadq65yrjnla75ydrzhq",
      "at": [ "https://mgubi.org/papers/" ],
      "version": "v2",
      "inventorySha512": "a269c26a28cb2a0b2d3e3a41c73d463f2d37e80e6c8ca2ff07b3ca8481be1b233e23cae5055ebb372cd786e95947cf20f128ca385993d488f99726a72503de7a",
      "follow": "latest",
      "doi": "10.5281/zenodo.1234568",
      "conceptDoi": "10.5281/zenodo.1234566",
      "cite": { "title": "Mass gap for the fractional $\\Phi^4_2$ model",
                "creators": [ "P. Duch", "M. Gubinelli" ], "year": 2026, "issued": "2026-03-02" } }
  ]
}
```

The `members.json` of an issue of the journal, a selection owned by the journal's owner (section 8.4). Its first member is the journal's accepted copy (section C.5); its second, the original revision set, which a selection MAY also list (section 9.6):

```json
{
  "format": "opensheaf-collection/0.1",
  "type": "selection",
  "members": [
    { "kind": "document",
      "name": "7zorzcm4euymqzldcvzyyg46w7z2admlgmn5lz7rosperrskp7ua",
      "owner": "a3fh2fbfja6kewlsvd466qc4jzj63cextra2h74rfff5p5tcfjwa",
      "at": [ "https://journal.example.org/" ],
      "revisions": [ { "documentVersion": 2, "version": "v1",
                       "inventorySha512": "61cdcc9a63a1058652f14d9391b4aa9edb5f90a4c18ab5c75012950b99549e84f94390fb194181d429ec3bdc49271c635f5469255521bb84f07044963152081d" } ],
      "cite": { "title": "Mass gap for the fractional $\\Phi^4_2$ model",
                "creators": [ "P. Duch", "M. Gubinelli" ], "year": 2026, "issued": "2026-03-02" } },
    { "kind": "document",
      "name": "7zorzcm4euymqzldcvzyyg46w7z2admlgmn5lz7rosperrskp7ua",
      "owner": "wmkg2sy2xl2z5xcthvxuyhconwpus4pojadq65yrjnla75ydrzhq",
      "at": [ "https://mgubi.org/papers/" ],
      "revisions": [ { "documentVersion": 2, "version": "v2",
                       "inventorySha512": "a269c26a28cb2a0b2d3e3a41c73d463f2d37e80e6c8ca2ff07b3ca8481be1b233e23cae5055ebb372cd786e95947cf20f128ca385993d488f99726a72503de7a",
                       "doi": "10.5281/zenodo.1234568" } ] }
  ]
}
```

### C.5 A branch: an accepted copy

The `object.json` of the first version of the journal's accepted copy, a branch of the authors' line at their object version `v2` (sections 9.1 and 9.6). No line of that name is the journal's, so the branch takes the genesis name, and its line is `sheaf:7zorzcm4euymqzldcvzyyg46w7z2admlgmn5lz7rosperrskp7ua:a3fh2fbfja6kewlsvd466qc4jzj63cextra2h74rfff5p5tcfjwa`. The first version of a line, it has no `previous`:

```json
{
  "format": "opensheaf-object/0.1",
  "specification": "0.1",
  "kind": "document",
  "name": "7zorzcm4euymqzldcvzyyg46w7z2admlgmn5lz7rosperrskp7ua",
  "owner": "a3fh2fbfja6kewlsvd466qc4jzj63cextra2h74rfff5p5tcfjwa",
  "parent": {
    "owner": "wmkg2sy2xl2z5xcthvxuyhconwpus4pojadq65yrjnla75ydrzhq",
    "name": "7zorzcm4euymqzldcvzyyg46w7z2admlgmn5lz7rosperrskp7ua",
    "objectVersion": "v2",
    "documentVersion": 2,
    "inventorySha512": "a269c26a28cb2a0b2d3e3a41c73d463f2d37e80e6c8ca2ff07b3ca8481be1b233e23cae5055ebb372cd786e95947cf20f128ca385993d488f99726a72503de7a",
    "url": "https://mgubi.org/papers/ocfl/wmkg2sy2xl2z5xcthvxuyhconwpus4pojadq65yrjnla75ydrzhq/7zorzcm4euymqzldcvzyyg46w7z2admlgmn5lz7rosperrskp7ua/v2/"
  },
  "documentVersion": 2,
  "mainSource": "fractional-phi42-mass-gap.tm",
  "sourceFormat": "application/x-texmacs",
  "renditions": [ { "path": "fractional-phi42-mass-gap.pdf", "mediaType": "application/pdf" } ],
  "stage": { "scheme": "NISO-JAV", "value": "AM" },
  "status": "active"
}
```

Its content holds the files of the parent version except `datacite.json` and `object.json` (`genesis.json`, the source and the PDF), its own `datacite.json` and `object.json`, and the evidence (section 9.2): `parent.inventory.json`, the authors' `v2/inventory.json`; `parent.object.json`, their `object.json` of that version; and `parent.signatures/signature-4hz7zgsiazl6hx7i.json`, the file of section C.3, byte for byte. Its witness folder holds two signature files of the journal's keys, naming the first version of the journal's key log. The journal's storage root keeps beside it the owner objects of the journal and of the authors (section 6.5).

### C.6 The archive

The storage root of the authors' archive in the owner-name layout (section 3.2), with the plain text file that describes that layout in place of OCFL's `ocfl_layout.json`, which names only registered layouts, and showing the paper's witness folder, with an RFC 3161 token of each signature (timestamps extension; the tokens are not shown):

```
ocfl/
  0=ocfl_1.1
  opensheaf-owner-name-storage-layout.md
  wmkg2sy2xl2z5xcthvxuyhconwpus4pojadq65yrjnla75ydrzhq/
    wmkg2sy2xl2z5xcthvxuyhconwpus4pojadq65yrjnla75ydrzhq/      the key log
    7zorzcm4euymqzldcvzyyg46w7z2admlgmn5lz7rosperrskp7ua/      the paper
      0=ocfl_object_1.1
      inventory.json
      inventory.json.sha512
      v1/
      v2/
      extensions/opensheaf-witnesses/
        v1/signature-w7htq42yt7tllefi.json
        v1/signature-w7htq42yt7tllefi.json.3mpvi64zr26ezfvh.tsr
        v2/signature-4hz7zgsiazl6hx7i.json
        v2/signature-4hz7zgsiazl6hx7i.json.5xjh5tk24wrufjrz.tsr
    sdjhoc72tckc7pou5xjfledh7xqfu7kafb7oqe4nwwyln3y4h6la/      the main catalogue
```

In the hashed layout, the paper would be at `d63/47a/a8c/sheaf%3a7zorzcm4euymqzldcvzyyg46w7z2admlgmn5lz7rosperrskp7ua%3awmkg2sy2xl2z5xcthvxuyhconwpus4pojadq6-d6347aa8c8d5a335a8f61736b94aca7b4a3639d1a68a3ea04399e99ce73640ef/`: its identifier of 111 characters encodes to 115, each `:` becoming `%3a`, and is shortened (section 3.2).

The discovery document (section 3.1). The archive hosts one owner, whose key log, paper and catalogue it lists, with labels for the website; a second paper of the owner was taken down, and its tombstone (section 13.3) keeps its line taken:

```json
{
  "format": "opensheaf-archive/0.1",
  "specification": "0.1",
  "name": "Papers of Massimiliano Gubinelli",
  "contact": "https://orcid.org/0000-0002-1234-5677",
  "storageRoot": "ocfl/",
  "storageLayout": "opensheaf-owner-name-storage-layout",
  "mainCollection": "sheaf:sdjhoc72tckc7pou5xjfledh7xqfu7kafb7oqe4nwwyln3y4h6la:wmkg2sy2xl2z5xcthvxuyhconwpus4pojadq65yrjnla75ydrzhq",
  "profiles": [ "zenodo", "texmacs", "website" ],
  "extensions": [ "https://opensheaf.org/opensheaf-timestamps-0.1" ],
  "owners": [ "wmkg2sy2xl2z5xcthvxuyhconwpus4pojadq65yrjnla75ydrzhq" ],
  "indexes": { "names": 2, "owners": 2, "sha512": 2 },
  "objects": [
    { "id": "sheaf:wmkg2sy2xl2z5xcthvxuyhconwpus4pojadq65yrjnla75ydrzhq:wmkg2sy2xl2z5xcthvxuyhconwpus4pojadq65yrjnla75ydrzhq",
      "kind": "owner", "name": "wmkg2sy2xl2z5xcthvxuyhconwpus4pojadq65yrjnla75ydrzhq", "owner": "wmkg2sy2xl2z5xcthvxuyhconwpus4pojadq65yrjnla75ydrzhq",
      "head": "v2", "inventorySha512": "7fdfdda7962ba1056084741253ca508cce2b3fa07953e6c377c53bcf54864304e38fa0fed7182f73426dd2d35c77623296e64ddeea89964eccc56f070d1bfffb",
      "status": "active" },
    { "id": "sheaf:7zorzcm4euymqzldcvzyyg46w7z2admlgmn5lz7rosperrskp7ua:wmkg2sy2xl2z5xcthvxuyhconwpus4pojadq65yrjnla75ydrzhq",
      "kind": "document", "name": "7zorzcm4euymqzldcvzyyg46w7z2admlgmn5lz7rosperrskp7ua", "owner": "wmkg2sy2xl2z5xcthvxuyhconwpus4pojadq65yrjnla75ydrzhq",
      "head": "v2", "inventorySha512": "a269c26a28cb2a0b2d3e3a41c73d463f2d37e80e6c8ca2ff07b3ca8481be1b233e23cae5055ebb372cd786e95947cf20f128ca385993d488f99726a72503de7a",
      "status": "active", "label": "fractional-phi42-mass-gap" },
    { "id": "sheaf:sdjhoc72tckc7pou5xjfledh7xqfu7kafb7oqe4nwwyln3y4h6la:wmkg2sy2xl2z5xcthvxuyhconwpus4pojadq65yrjnla75ydrzhq",
      "kind": "collection", "name": "sdjhoc72tckc7pou5xjfledh7xqfu7kafb7oqe4nwwyln3y4h6la", "owner": "wmkg2sy2xl2z5xcthvxuyhconwpus4pojadq65yrjnla75ydrzhq",
      "head": "v2", "inventorySha512": "0a64a3bd1761a9304b2ca02a40aeacc4c0393ef29a9692485639b9db984b9f051c5e9f1e85e2e2f01a2cc8e3826e497669484bd57fb2a549d25f0d2e9ee23b58",
      "status": "active", "label": "papers" }
  ],
  "tombstones": [
    { "id": "sheaf:qfdlpon4baezuictf4tzxzsrwknccpxtepori243pc7lbsospsfa:wmkg2sy2xl2z5xcthvxuyhconwpus4pojadq65yrjnla75ydrzhq",
      "kind": "document", "name": "qfdlpon4baezuictf4tzxzsrwknccpxtepori243pc7lbsospsfa", "owner": "wmkg2sy2xl2z5xcthvxuyhconwpus4pojadq65yrjnla75ydrzhq",
      "genesisName": "qfdlpon4baezuictf4tzxzsrwknccpxtepori243pc7lbsospsfa",
      "lastVersion": "v1", "inventorySha512": "95430aace90933293f3df0942d49be0fc5e5803dbe38849babf88b8a3a71688af50302c7c4f6bf085fd61c089ce49b3795b4a7de2799ed7f42e94ef9a88968d5",
      "date": "2026-05-04", "reason": "Taken down at the request of the holder of the rights." }
  ]
}
```

### C.7 sheaf: URIs

URIs of the paper, of the accepted copy and of the authors' owner (section 12):

```
sheaf:7zorzcm4euymqzldcvzyyg46w7z2admlgmn5lz7rosperrskp7ua
    the authors' line (its owner is the originator)
sheaf:7zorzcm4euymqzldcvzyyg46w7z2admlgmn5lz7rosperrskp7ua/v2
    document version 2 of the authors' line
sheaf:7zorzcm4euymqzldcvzyyg46w7z2admlgmn5lz7rosperrskp7ua/v2?sha512=a269c26a28cb2a0b2d3e3a41c73d463f2d37e80e6c8ca2ff07b3ca8481be1b233e23cae5055ebb372cd786e95947cf20f128ca385993d488f99726a72503de7a
    the authors' object version v2, which the journal vetted
sheaf:7zorzcm4euymqzldcvzyyg46w7z2admlgmn5lz7rosperrskp7ua/v2?sha512=a269c26a28cb2a0b2d3e3a41c73d463f2d37e80e6c8ca2ff07b3ca8481be1b233e23cae5055ebb372cd786e95947cf20f128ca385993d488f99726a72503de7a&at=https%3A%2F%2Fmgubi.org%2Fpapers%2F
    the same, with a hint
sheaf:7zorzcm4euymqzldcvzyyg46w7z2admlgmn5lz7rosperrskp7ua:a3fh2fbfja6kewlsvd466qc4jzj63cextra2h74rfff5p5tcfjwa/v2
    document version 2 of the journal's line, its accepted copy
sheaf:7zorzcm4euymqzldcvzyyg46w7z2admlgmn5lz7rosperrskp7ua:*
    the work: the authors' line, the journal's and any other
sheaf:wmkg2sy2xl2z5xcthvxuyhconwpus4pojadq65yrjnla75ydrzhq
    the authors' owner: its key log
sheaf:wmkg2sy2xl2z5xcthvxuyhconwpus4pojadq65yrjnla75ydrzhq/v2?sha512=7fdfdda7962ba1056084741253ca508cce2b3fa07953e6c377c53bcf54864304e38fa0fed7182f73426dd2d35c77623296e64ddeea89964eccc56f070d1bfffb
    version 2 of its key log, as keyLog names it
sheaf:7zorzcm4/v2
sheaf:7zorzcm4:a3fh2fbf/v2
    short forms of the second and fifth (section 12.2)
https://opensheaf.org/sheaf:7zorzcm4euymqzldcvzyyg46w7z2admlgmn5lz7rosperrskp7ua/v2
    the second, through a gateway (provisional, #35)
```

### C.8 An exposed key and a fork of a key log (provisional, #58)

Later, the new laptop is stolen. The owner signs with two tokens of the second version a version 3 of its key log, in `v3/signature-j77iavvdclktxkwm.json` and `v3/signature-nzvwkea25p62akdy.json`, naming version 2. It lists a new current key, made on another laptop, the stolen key in `exposed`, and the digests of three new tokens in `next`:

```json
{
  "format": "opensheaf-keys/0.1",
  "keys": [
    "did:key:z6MkteCfnkhWgCnLtR7Wdzi81tk4FDb9Juk5CxgjqCRo4UHJ"
  ],
  "threshold": 1,
  "next": [
    "lnk5erp4kdue5zo5g6tryoy5jvxhjxzquopufqu7cfqaase5kdhq",
    "uilj7nmkhupsxi2isidszwwexj5w5ffieqxq27hhhlbpomh22ioa",
    "ibqesflkpunkv7w75elkgmbflw62jwi3uecj5hngyn6eq6ps475a"
  ],
  "nextThreshold": 2,
  "extensions": {
    "https://opensheaf.org/opensheaf-timestamps-0.1": {
      "timestampAuthorities": [
        "5b4e3f0c9d2a7e18c6f4b0a39d7e2c51f8a6b3d09e4c7a12f5b8d6e3a0c9f147"
      ]
    }
  },
  "exposed": [
    "did:key:z6MkugKqPPkysjyartSzszBbMh8fVhENmqGXvddtD8DDvThn"
  ]
}
```

The first of its signature files:

```json
{
  "format": "opensheaf-signature/0.1",
  "object": "sheaf:wmkg2sy2xl2z5xcthvxuyhconwpus4pojadq65yrjnla75ydrzhq:wmkg2sy2xl2z5xcthvxuyhconwpus4pojadq65yrjnla75ydrzhq",
  "version": "v3",
  "inventorySha512": "69ec2e6265ba049796d0b4f962ca1ddbcb489886e6780d5eece489b25cf6dc988ad653ebec46e9f5063f182da90b2ee0146bc6d1faf8ff7189e75bc739a71c9a",
  "signer": "wmkg2sy2xl2z5xcthvxuyhconwpus4pojadq65yrjnla75ydrzhq",
  "key": "did:key:z6MksaMy3cmXbnUKqzGv18xhbBreY6berNYVtTZyDrYRb1Hn",
  "keyLog": "sheaf:wmkg2sy2xl2z5xcthvxuyhconwpus4pojadq65yrjnla75ydrzhq/v2?sha512=7fdfdda7962ba1056084741253ca508cce2b3fa07953e6c377c53bcf54864304e38fa0fed7182f73426dd2d35c77623296e64ddeea89964eccc56f070d1bfffb",
  "signature": "+ieqNbLZiuBp+Es5jFGJLHYE5z/adk9E00Q/1UTRX9lmiC37UKjuc0KbQHyrYfz8B9/mPPpWoNJqEAOEhJEoDw=="
}
```

The thief, holding the stolen key, can sign versions of the owner's lines naming version 2; their signatures stay good, but these versions need a key that version 3 exposes, so they are contested, and archives that know version 3 never add them (sections 7.3 and 7.5). It can sign no version of the key log, which only rotation keys sign (section 6.1). The paper's version 2, signed only with the stolen key (section C.3), is contested too, though the owner made it: the owner signs it again with the new key, naming version 3 (section 7.1), and its RFC 3161 token, dated before version 3, is evidence a reader may trust (section 7.3).

Had the thief also copied, before the owner used them, the tokens whose digests begin `nzvwkea25p62akdy` and `fhujijfn3zmvteie` in `next` of the second version, it could sign another version 3, against version 2, listing a key of its own: a fork of the key log, which ends the owner (section 6.3). An archive holding the owner's versions 1 to 3 that meets the thief's version 3 keeps its own, and appends a fork record as version 4, which carries the other version 3:

```
wmkg2sy2xl2z5xcthvxuyhconwpus4pojadq65yrjnla75ydrzhq/wmkg2sy2xl2z5xcthvxuyhconwpus4pojadq65yrjnla75ydrzhq/
  inventory.json
  inventory.json.sha512
  v1/ v2/ v3/                        the archive's own versions
  v4/                                the fork record
    inventory.json
    inventory.json.sha512
    content/forked/42whcj2qbhdeh7nx/          the other version 3
      inventory.json
      inventory.json.sha512
      keys.json
      signature-nzvwkea25p62akdy.json
      signature-fhujijfn3zmvteie.json
```

The fork record's `genesis.json` is that of `v1`, byte for byte, and its `object.json` has the fields of that of `v1` and `previous`, the digest of the inventory file of the owner's version 3 (section 4.3); it has no `keys.json`. The inventory carried has the owner object's `id`, and `42whcj2qbhdeh7nx` begins the base32 SHA-256 digest of its bytes. Readers report the owner ended at version 3, its fork point, and the fork freezes it: an archive that knows of the fork adds no version of its lines, from a copy or as a deposit, unless evidence it trusts shows it signed before either version 3 (section 7.5). The exposure in the owner's version 3 still counts, as an exposure does on either side of a fork (section 6.3), so the versions the thief signs with the stolen key naming version 2 stay contested; and versions of lines whose signatures name version 3, of either side, are contested too, the owner's new signature of the paper's version 2 included, so that the paper's version 2 is contested. Had the thief's version 3 also exposed the first laptop's key, the paper's version 1, signed with it, would be contested as well, though the owner made it. Archives holding the paper's versions keep them; others add them only if they trust their RFC 3161 tokens to date them before the fork, and readers weigh them by such evidence (section 6.4). The keeper may name a successor (section 6.6), under which the authors continue their papers as branches. An archive that met the thief's version 3 first keeps that one, and appends a fork record carrying the owner's.

## Appendix D. Rationale (non-normative)

The reasons for the main choices, in the order of the sections.

### D.1 Archives and objects

- **Why OCFL and DataCite.** OCFL is a published specification for versioned objects as plain files with digests, with independent validators; DataCite is the metadata of DOIs, with relations for versions and collections, and its REST API form lets `datacite.json` be sent to a DOI service as it is.
- **Why a minimal core.** Richer structures (a proof and its detailed argument, a dataset and its analyses) are built on top, by links, DataCite relations or extensions, whose data the pins and signatures fix with each version (section 2), leaving room for designs not yet imagined.
- **Why archives are hosts.** Once owners sign their lines, a name for an archive identifies no authority and ties lines to places (#52, #55); every location is a hint, checked by pins and signatures. `replicas` was dropped for that reason, and because it is read from the very site that may be gone.
- **Why identifiers from lines, and two layouts.** Identifiers chosen by archives clash once an archive keeps copies of another's objects; lines never clash (#52). The owner-name layout keeps each owner in one folder, which moves by copying; the hashed layout serves archives too large for that, mostly in git.
- **Why no `ocfl_layout.json` for the owner-name layout.** OCFL allows in it only the name of a registered extension (OCFL 1.1, section 4.1), which the owner-name layout is not; OCFL lets a plain text file in the storage root document a local arrangement (section 4.5), and the discovery document names the layout for readers, who compute paths from it.
- **Why document and object versions.** Readers and DOI services see versions of the work; the storage keeps every change, a corrected description or a notice included, each fixed by its pin.
- **Why the owner numbers its document versions.** External numberings have gaps and miss versions never public there; external labels are kept beside the owner's numbers.
- **Why an explicit history.** Dates may be approximate or unknown, and fixed versions cannot correct pointers to their predecessors when a version is found later. A list of object versions, read from the latest signed version, can be corrected; it cannot list digests, since a version cannot contain the digest of its own inventory.
- **Why the deposit is read from the inventory.** OCFL already records it; repeating it in `object.json` would let the two disagree.

### D.2 Names

- **Why names from genesis records.** A digest of a file every copy carries is checked by anyone, needs no registry and names no archive; its nonce makes it unique in practice, and taking the bytes as stored needs no canonical form of JSON.
- **Why algorithm numbers.** Clashes are resolved where lines are made, and a branch, sharing its parent's record, is renamed by another algorithm. The number fills the four bits that RFC 4648 leaves zero, so names of algorithm 0 are plain digests and algorithms never coincide.
- **Why signatures decide reused genesis records.** Only the originator signs the originator's line, and every other line carries signed parents back to it, the whole chain, since one level would let a chain of branches pass. A reused record is useless to anyone else, and no archive keeps a first-come register of names (section 5.4).

### D.3 Owners

- **Why keyed owners with key logs.** An owner asserted by a name (an ORCID iD, an archive's identifier) cannot stop others writing under it; signatures make every version checkable anywhere, also after its archives have gone (#55). A key cannot change, so the owner keeps its keys in a log, each version signed by the rotation keys committed by the one before, as Radicle's identity documents and The Update Framework do.
- **Why the owner name fixes the first keys.** Otherwise anyone could write a first key-log version under a published owner name; as Radicle's repository identifier commits to its first delegates, and KERI's identifier to its first keys, the name commits to the first current keys and to the digests of the first rotation keys, from which the first version of the key log is computed.
- **Why the first version of a key log is computed.** As KERI's inception event is fixed by its identifier, the first version of a key log is fixed by the owner name: every byte of it, its inventory included, is computed from the genesis record in canonical JSON (JCS), so every copy holds the same version, a signature can pin it, and no key log forks there. No key that might later be stolen ever signed it, so current keys sign no version of a key log at all, and versions of one number with different inventories are simply a fork, with no notion of equivalent versions.
- **Why pre-rotation.** As in KERI, each version of the key log commits to the digests of the keys that may sign the next one, kept apart and used once. The roles are separate: current keys, in daily use and the likeliest to be stolen, sign lines and never the key log, so a thief holding them cannot change it, and the owner answers the theft by one version the thief cannot contest. The commitment is made before any theft, and a digest shows nothing of a key before its use. Earlier drafts let the same keys sign lines and the key log, so a thief could contest the owner's answer, and settling the contest needed fork records that nullified keys and healing that did not converge against a thief holding several keys ([keys and forks](https://github.com/opensheaf/opensheaf.github.io/blob/main/drafts/keys-and-forks.md); [federated identity](https://github.com/opensheaf/opensheaf.github.io/blob/main/drafts/federated-identity.md)).
- **Why a rotation key is committed once.** A key committed in the `next` of two versions could sign both, so whoever stole it could fork the key log at either; committed once, the rotation keys of each version are fresh, a stolen one that did not sign is useless once the next version is signed, and whether a key is revealed is read from one version.
- **Why revealed rotation keys do not become current keys.** KERI makes them current, and detects a thief's competing versions by witnesses and watchers, which OpenSheaf does not have. A rotation key that became current would be in daily use, so its theft would again let a thief contest the key log.
- **Why the first seen is kept.** Without witnesses, an archive cannot tell which side of a fork came first elsewhere; it keeps what it holds, which no one can then remove, and appends a fork record carrying the other side, so that nothing a signature names is dropped and every copy shows the fork. Meeting both sides at once, it may keep either: each ends the owner.
- **Why a fork freezes the owner.** Only rotation keys, kept apart and used once, can fork a key log, so a fork is rare and shows that they were exposed; the format cannot tell the owner's side, and healing, tried before, did not settle against a thief ([keys and forks](https://github.com/opensheaf/opensheaf.github.io/blob/main/drafts/keys-and-forks.md)). Without a clock, no rule can tell what the owner signed before the fork from what a thief signs after it, also with old current keys naming earlier versions of the key log, and each attempt to salvage part of it (taking a forked owner's versions only from copies, for instance) made new edge cases. So a fork ends the owner and freezes it: archives keep what they hold, signatures stay good, nothing more is added unless evidence dates it before the fork, and, as in Radicle, where a compromised key means a new identity, the work continues under a successor.
- **Why exposed keys are exposed, never revoked.** Signatures carry no time, so nothing tells what a key signed before it leaked from what a thief signs after; revocation would need trusted time to decide which signatures count. So no signature is undone: the owner exposes the keys, what needs them is contested, never added to an archive unless other evidence dates it before the exposure, and readers weigh the past by other evidence (section 6.4).
- **Why one status, contested.** An exposed key and a fork of a key log raise one question, whether a good signature may be a thief's, so one status answers both, once, for archives (never added), readers (never the latest signed version), branches and collections, and the same evidence lifts it. An exposure counts in any version, on either side of a fork: the format cannot tell which side is the owner's, and an exposure only makes versions contested, never signed, so counting a thief's costs trust in the owner's past at most, while ignoring the owner's would let what the thief signs with a stolen key pass. Versions of key logs are never contested: current keys never sign them.
- **Why key logs travel beside objects.** A key log checks itself from its owner name, so any copy will do; as an owner object it is copied once per storage root and grows without changing the lines it signs.
- **Why timestamps are an extension.** A single researcher needs none, since signatures stay good; an institution may want signatures dated by a provider it names, to tell what came before an exposure. The extension keeps the trade-offs of RFC 3161 authorities and OpenTimestamps out of the core; timestamps change no status by themselves, and section 7.3 admits trusted dates as evidence against `contested`.
- **Why the keeper is in the genesis record.** A keeper named in the key log could be changed by whoever holds rotation keys, a thief included, and after a fork by either side. Fixed by the owner name, the keeper answers for the owner from outside its keys, and a successor named after a fork counts only when the keeper names it. There is at most one keeper, so that at most one successor is accepted.
- **Why keepers confirm.** A genesis record could name anyone as keeper; the keeper confirms the link where only it can, and can withdraw it without touching anything signed (#41).

### D.4 Lines and signatures

- **Why signatures name the key-log version.** A signature of a checksum file alone could be paired with any key-log version. Judged against the version it names, a signature survives retired keys: an owner cannot find every copy of its lines to sign them again.
- **Why a signed version vouches for its past.** An inventory fixes every earlier version, so one signature covers them all, as Radicle's canonical head vouches for the commits it reaches.
- **Why `previous` chains inventories.** As a git commit names its parents by digest, each version names the digest of the inventory file before it. OCFL chains content, not inventories: an inventory records the digests of earlier versions' files, and earlier inventories need only state the same versions as JSON values (OCFL 1.1, section 3.7). A pin is the digest of an inventory's bytes, so without the chain a version vouched for would be fixed in its files but not in the bytes its pin names, and its pin would be less reliable than that of a version signed directly (#46).
- **Where witnesses live.** A witness follows its version, so it cannot be in it, and a new version for each would mix evidence with the work. OCFL closes the object folder, and its `logs/` are not covered by digests; extension folders hold data outside every version, as the mutable-head extension does.
- **Why no list of an owner's lines.** Copies are compared through the inventories they share, so a copy that stops early is only older.
- **Why versions held are never removed.** If a host or a thief could cause a removal, it could remove the owner's own versions; keeping everything costs at most one blocked version number in one archive.

### D.5 Collections

- **Why pins by inventory digest.** One digest fixes a whole object version, so collections are hash trees across archives, any matching copy will do, and locations are equal hints.
- **Why catalogues and selections.** Keeping and vetting are different acts. A catalogue keeps every version without judging it; a selection attests particular revisions, so a later version cannot enter by itself, and a change of what is vetted is an editorial act in the selection's history.
- **Why `follow` is a setting.** A collection version states exactly what it contains; a floating "latest" would change its meaning over time.

### D.6 Branches and accepted copies

- **Why every branch is a new object.** A journal needs only the version it vetted, a co-author perhaps the whole past, which a copy of the parent's line beside the branch gives. A branch continuing the parent's object would hold inventories naming the parent's identifier, and collide with that copy; Radicle likewise keeps forks beside their sources.
- **Why the evidence carries signatures and the whole chain.** Without the parent owner's signatures a branch shows only a parent inventory that agrees with itself; the chain lets a branch of a branch be checked back to the originator's line after its parents' archives have gone (#22).
- **Why accepted copies are branches, not mirrors.** A mirror grows only by its owner's versions; an accepted copy continues one revision under the selection's responsibility, and OCFL cannot hold part of an object.

### D.7 Drafts and sealing

- **Why drafts.** A version that has left its owner's hands may be cited, pinned or copied, and must stay fixed and signed; a draft keeps unfinished work in the usual format, marked, outside its content, as something on which nothing may rely.
- **Why sealing makes a new object.** Continuing the draft would start the line with unsigned history that may have changed; a new object starts it at its first signed version.
- **Why only at the owner's request.** Sealing fixes a name and signs for ever; a tool sealing as a side effect would make the owner answer for a version it did not choose to share.

### D.8 Copies and mirrors

- **Why a mirror is not marked.** It is the same line, checked by its owner's signatures, so a mark would add nothing a reader could rely on; identifiers from lines made the earlier `mirrorOf` unnecessary (#52).
- **Why mirrors grow only by the owner's versions.** Like catalogues they are impartial; and OCFL objects only grow, so a copy that departs from a mirror is a fork, never a correction.

### D.9 Identifiers

- **Why `sheaf:` URIs.** Earlier global names built on an archive's identifier (`tag:` or ARK URIs) tied lines to places (#14, #52). One scheme writes lines, versions, pins and owners, and signatures name key-log versions with it.
- **Why the owner part defaults to the originator.** The genesis record every copy carries names the originator, so the URI is fixed by the work; "the latest" line would depend on what a resolver knows.
- **Why `/v<n>` is a document version.** Readers cite versions of the work; object versions change at every notice, and a citation that must not move carries the digest.
- **Why short forms are only for people.** Eight characters are 40 bits: another owner can make a short form ambiguous, never take it over, and resolvers may know different lines.
- **Why gateways redirect only temporarily, and only to checked copies.** Copies move and are taken down, so a permanent redirect would fix a stale location in browsers' caches; a gateway that serves only what it checked cannot send readers to a forged copy.
- **Why external records do not resolve pins.** A deposit or a snapshot keeps a version's files but not its inventory or signatures, so nothing ties them to the pin or the owner (#22).

### D.10 Withdrawal, takedown and tombstones

- **Why a withdrawal keeps the content.** A retracted paper stays part of the record, cited and collected; deleting it would break every pin and signature that includes it.
- **Why a takedown deletes the whole object.** OCFL 1.1 cannot remove a file without changing the inventories, and so every pin and signature; deleting the object leaves all else valid, which is also why erasure is a takedown. Every removal is one, so nothing leaves an archive silently.
- **Why a tombstone is not signed.** Takedowns are often made against the owner's will, and a host can add a tombstone falsely; it speaks for one archive only.
- **Why a tombstone keeps the genesis name.** A work taken down cannot then return there under a reused record (section 5.4).
- **Why owner objects outlive takedowns of lines.** Every other line, branch and copy the owner signed needs the key log; and since a thief may hold current keys, or rotation keys, a takedown of an owner object needs the law or the keeper, never the owner's keys.

### D.11 Verification

- **Why errors, warnings and results.** An error is a breach the archive can repair; what it cannot repair (a version let in against section 7.5, another archive's copy), and states of the world (an end, a fork, a withdrawal), would make it fail for ever.

### D.12 Security, privacy and rights

- **Why one's own storage root is untrusted.** An archive checks signatures, not intentions: a path or a text is as dangerous in a signed version as in a forged one.
- **Why object files never run in an archive's origin.** A script served from an origin acts as that site: it reads what its pages store, and presents forged pages under a trusted address.
- **Why owners are pseudonymous.** Owner names, key logs and signatures travel with every copy and can never be removed; if they named persons, no takedown could erase them.
- **Why metadata is under CC0.** Pins, signatures and key logs are checked only where they can be copied; a licence would make every copy, index and reference a question of rights.

### D.13 Versioning

- **Why MAJOR.MINOR in files.** A patch changes no requirement; recording it would make equal files differ.
- **Why unknown properties are ignored only from 1.0.** Before 1.0 a minor version may change the meaning of what a reader knows.

### D.14 Profiles and schemas

- **Why profiles.** Services and tools differ between archives, and the core needs none; a profile states what an archive using one promises, so that it can be checked.
- **Why a Zenodo deposit is signed before publication.** The reserved DOI is then under the owner's signature, and no record is published for a version the line cannot take.
- **Why Zenodo files never change.** The archive keeps each version fixed, so the 30-day window is not used, and description-only versions edit metadata, keeping one DOI per document version. MD5 is recorded because Zenodo reports only MD5.
- **Why some schemas are closed.** Genesis records, key logs and keeper files decide names and keys, and a signature file holds exactly what it signs; an extra property there would seem committed to.
- **Why `datacite.json` is validated through XML.** It keeps the form of the REST API, and DataCite publishes no JSON Schema.

## Appendix E. References

- [RFC 2119](https://www.rfc-editor.org/rfc/rfc2119) and [RFC 8174](https://www.rfc-editor.org/rfc/rfc8174), together [BCP 14](https://www.rfc-editor.org/info/bcp14): key words
- [RFC 8259](https://www.rfc-editor.org/rfc/rfc8259): JSON; [RFC 3629](https://www.rfc-editor.org/rfc/rfc3629): UTF-8; [Unicode Standard Annex #15](https://www.unicode.org/reports/tr15/): normalisation form C
- [RFC 3339](https://www.rfc-editor.org/rfc/rfc3339): dates and times (the `date-time` format of JSON Schema)
- [RFC 3986](https://www.rfc-editor.org/rfc/rfc3986): URIs and percent-encoding; [RFC 7595](https://www.rfc-editor.org/rfc/rfc7595) and the [IANA registry of URI schemes](https://www.iana.org/assignments/uri-schemes/uri-schemes.xhtml): registering `sheaf`
- [RFC 4648](https://www.rfc-editor.org/rfc/rfc4648): base32 and base64
- [FIPS 180-4](https://csrc.nist.gov/pubs/fips/180-4/upd1/final): SHA-256, SHA-512 and SHA-1; [RFC 1321](https://www.rfc-editor.org/rfc/rfc1321): MD5
- [RFC 8032](https://www.rfc-editor.org/rfc/rfc8032): Ed25519
- [The did:key method](https://w3c-ccg.github.io/did-key-spec/) (W3C Credentials Community Group), with [multibase](https://github.com/multiformats/multibase) and [multicodec](https://github.com/multiformats/multicodec)
- [RFC 3161](https://www.rfc-editor.org/rfc/rfc3161): time-stamp protocol; [OpenTimestamps](https://opentimestamps.org/)
- [RFC 9110](https://www.rfc-editor.org/rfc/rfc9110): HTTP semantics, redirects; [RFC 8615](https://www.rfc-editor.org/rfc/rfc8615): well-known URIs; [Fetch](https://fetch.spec.whatwg.org/): cross-origin requests; [Content Security Policy Level 3](https://www.w3.org/TR/CSP3/): `sandbox`
- [OCFL 1.1 specification](https://ocfl.io/1.1/spec/) and [OCFL extensions](https://ocfl.github.io/extensions/), among them [0003-hash-and-id-n-tuple-storage-layout](https://ocfl.github.io/extensions/0003-hash-and-id-n-tuple-storage-layout.html) and [0005-mutable-head](https://ocfl.github.io/extensions/0005-mutable-head.html)
- [DataCite Metadata Schema 4.7](https://schema.datacite.org/meta/kernel-4.7/), [DataCite REST API](https://support.datacite.org/docs/api), [its mapping between JSON and XML](https://support.datacite.org/docs/datacite-xml-to-json-mapping), [the change for publisher and affiliation](https://support.datacite.org/docs/datacite-rest-api-affiliation-and-publisher-default-change) and [guidance on preprints](https://support.datacite.org/docs/preprints-post-prints-and-author-manuscripts)
- [JSON Schema 2020-12](https://json-schema.org/draft/2020-12)
- [ORCID](https://orcid.org/), [ROR](https://ror.org/), [SPDX License List](https://spdx.org/licenses/), [MSC2020](https://msc2020.org/), [NISO Journal Article Versions (NISO RP-8-2008)](https://www.niso.org/publications/niso-rp-8-2008-jav), [Software Heritage identifiers (SWHID)](https://docs.softwareheritage.org/devel/swh-model/persistent-identifiers.html)
- [CC0 1.0](https://creativecommons.org/publicdomain/zero/1.0/) and [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/)
- [arXiv](https://arxiv.org/) and its [default licence](https://arxiv.org/licenses/nonexclusive-distrib/1.0/)
- [amsmath](https://ctan.org/pkg/amsmath) and [amssymb](https://ctan.org/pkg/amsfonts) (CTAN); [TeXmacs](https://www.texmacs.org/)
- [Zenodo developer documentation](https://developers.zenodo.org/), [InvenioRDM records API](https://inveniordm.docs.cern.ch/reference/rest_api_drafts_records/), [Zenodo on folders](https://support.zenodo.org/help/en-gb/1-upload-deposit/74-can-i-upload-folders-directories), [managing files](https://help.zenodo.org/docs/deposit/manage-files/), [resource types](https://zenodo.org/api/vocabularies/resourcetypes), [versioning](https://zenodo.org/help/versioning) and [the sandbox](https://sandbox.zenodo.org/)
- [Google Scholar inclusion guidelines](https://scholar.google.com/intl/en/scholar/inclusion.html), [schema.org ScholarlyArticle](https://schema.org/ScholarlyArticle), [JSON-LD 1.1](https://www.w3.org/TR/json-ld11/), [FAIR Signposting](https://signposting.org/FAIR/), [BibTeX](https://www.bibtex.org/), [CSL-JSON](https://github.com/citation-style-language/schema), [Atom (RFC 4287)](https://www.rfc-editor.org/rfc/rfc4287), [Sitemaps](https://www.sitemaps.org/protocol.html), [OAI-PMH static repositories](https://www.openarchives.org/OAI/2.0/guidelines-static-repository.htm) and [ResourceSync](https://www.openarchives.org/rs/toc)
- [Radicle protocol guide](https://radicle.xyz/guides/protocol) and [The Update Framework](https://theupdateframework.io/): identities and key logs compared in appendix D
- [KERI specification](https://trustoverip.github.io/tswg-keri-specification/) (Trust over IP Foundation) and [the KERI white paper](https://arxiv.org/abs/1907.02143) (S. M. Smith): pre-rotation of keys; [Sidetree](https://identity.foundation/sidetree/spec/) (Decentralized Identity Foundation): commitments to the next update keys

**Companion documents.** [OpenSheaf archives in git](opensheaf-git-0.1.md), for archives kept in git repositories, and the [timestamps extension](opensheaf-timestamps-0.1.md), for dating signatures with RFC 3161 tokens and OpenTimestamps proofs.
