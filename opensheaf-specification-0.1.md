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
- **owner tool**, a program that seals, signs or keeps an owner's key log: sections 5 to 7 and 10;
- **verifier:** sections 14 and 16 (as a reader), with the rules it checks;
- **resolver:** section 12, with sections 6 and 7 for checking signatures and key logs; a gateway also follows the rules on gateways of section 12.

**Profiles.** An archive MAY also follow the profiles of appendix A (Zenodo, TeXmacs, website), and MUST list in its discovery document those it follows.

**Extensions.** An extension is a specification published apart, named by a URI (RECOMMENDED: the `https` URL where it is published), that records what this specification leaves open, so that tools aware of it can act on it. Its data is kept under `extensions`, keyed by the extension's name: in `object.json` (section 4), where the inventory and the pins fix it, or in `keys.json` (section 6), where the owner's signatures fix it. An extension MUST NOT change the meaning of what this specification defines, nor relax its requirements: archives, objects and collections are read and verified without knowing any extension, and readers ignore extensions they do not know. The discovery document SHOULD list the extensions its objects use. The [timestamps extension](opensheaf-timestamps-0.1.md) is one.

**Schemas.** The JSON files defined here MUST validate against the JSON Schemas of appendix B for their declared format version.

## 3. Archives

An <dfn>archive</dfn> is a host of objects, served at a <dfn>base URL</dfn> ending with `/`. It holds the lines that owners write there (section 7) and copies of lines written elsewhere (section 11). It has no identity of its own and owns nothing by hosting: what is authentic is decided by the owners' signatures (section 7), and an archive decides only which owners it hosts and how they deposit (a university admitting its staff, a journal its editors). Its base URL is a location, not a name, and may change.

An archive consists of a **discovery document**, REQUIRED (section 3.1); a **storage root**, REQUIRED (section 3.2); **indexes**, RECOMMENDED (section 12); and **presentation files**, OPTIONAL: web pages and other files generated for readers, never authoritative, kept outside the storage root (appendix A).

**Serving.** The discovery document, the storage root and the indexes MUST be served byte for byte, as stored: no conversion of line endings or character sets, and no compression that changes the bytes delivered after decoding. Archives SHOULD be served over HTTPS, and SHOULD allow cross-origin requests to these files (`Access-Control-Allow-Origin: *`), so that tools in a browser can read them. Any static web server will do; an archive kept in git follows [OpenSheaf archives in git](opensheaf-git-0.1.md).

**Moving.** An archive moving to another site copies its files; nothing in them changes, so every pin, signature and witness stays valid. Its base URL, and every location of a copy given elsewhere (in collections, `sheaf:` URIs, discovery documents), is a hint that needs no signature: whatever is fetched from it is checked against pins and signatures, so a wrong or stale location gives a reader nothing, or an older valid copy, never a forged one.

### 3.1 The discovery document

The <dfn>discovery document</dfn> is the JSON file `opensheaf.json` at the base URL. Static web servers cannot list folders; this one file makes an archive's objects known. It MUST contain:

- `format`: `"opensheaf-archive/0.1"`, and `specification`: `"0.1"`;
- `name`: a readable name of the archive;
- `storageRoot`: the URL of the storage root, ending with `/` (it may be relative);
- `storageLayout`: its layout, `"opensheaf-owner-name-storage-layout"` or `"0003-hash-and-id-n-tuple-storage-layout"` (section 3.2);
- `profiles`: the profiles it follows, from `zenodo`, `texmacs`, `website` (appendix A), possibly none;
- `objects`: every object of the storage root except drafts, each with `id` (section 4), `kind`, `name` and `owner` (section 7), `head` (its OCFL head version), `inventorySha512` (the SHA-512 digest of the head inventory, as its checksum file states it) and `status` (`active` or `withdrawn`, section 13), and OPTIONALLY a `label`.

It SHOULD contain `mainCollection`, the identifier of the catalogue of the archive's documents (section 8); `contact`, a URI; and `extensions`, the names of the extensions its objects use (section 2). It MAY contain `owners`, the owner names of the owners it hosts (section 6); `drafts`, the drafts it chooses to show, with `id`, `kind` and `head`, as unfinished work on which nothing may rely (section 10); `replicas`, base URLs of complete copies of the whole archive (distinct from mirrors of lines, section 11); `tombstones` (section 13); `indexes` (section 12); and `feed`, the URL of an Atom feed of new object versions.

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

**Versions.** An <dfn>object version</dfn> is an OCFL version of an object (`v1`, `v2`, ...): every change of the object makes one, and none changes once made. A <dfn>document version</dfn> is a version of the work, a positive integer numbered by the owner of the line and recorded in `object.json` and `datacite.json`; it changes only when the document's own files change (section 4.2), so several object versions may hold one document version, with different descriptions or notices.

**Pins.** A <dfn>pin</dfn> is the pair (object version, SHA-512 digest of that version's inventory file, as its checksum file states it). An inventory records the digests of the files of its version and of every earlier one, so a pin fixes the object up to that version, in any copy. Collections (section 8), branches (section 9) and `sheaf:` URIs (section 12) refer to object versions by pins, and pin only signed versions (section 7).

### 4.1 Common rules

Every object MUST be a valid OCFL 1.1 object, and:

- its inventories MUST use the digest algorithm `sha512`; they MAY also record MD5 and SHA-256 digests in `fixity` (the Zenodo profile requires MD5, appendix A);
- every version directory MUST contain the inventory as of that version, with its checksum file, so that each version can be pinned and fetched on its own;
- version directories MUST NOT be zero-padded (`v1`, not `v001`);
- logical paths MUST be in UTF-8 and Unicode normalisation form C, and MUST NOT begin with `/` or contain `.` or `..` segments.

**Deposits.** Each version in the inventory MUST have a `user` with a `name`, SHOULD give its `address` (an ORCID iD, a `mailto:` URI or another URI identifying the depositor), and MUST have a `message` describing the change. The `created` date and `user` of an object version record its <dfn>deposit</dfn>, not repeated in `object.json`; the deposit of a document version is that of the first object version holding it.

**Content.** Every object version MUST contain, at the top level of its content, `object.json` (section 4.3); `datacite.json` (section 4.4), except in an owner object; and the genesis record `genesis.json` (section 5), except in a draft. Every version of a branch also holds the evidence of its branch point: `parent.inventory.json`, `parent.object.json`, `parent.signatures/` and, for a branch of a branch, `parent.chain/` (section 9). The genesis record and this evidence are the <dfn>identity files</dfn> of the object, never files of the document's own. The names of every file this specification defines at the top level of the content (`object.json`, `datacite.json`, `genesis.json`, `members.json`, `keys.json`, `parent.inventory.json`, `parent.object.json`, `parent.signatures`, `parent.chain`) are reserved for those files. A collection version also holds `members.json` (section 8). An owner object holds `genesis.json` and `keys.json` (section 6) and no `datacite.json`; it has no document versions, and is never withdrawn or branched. Signatures and other witnesses are kept outside every version, in the object's extension folder `extensions/opensheaf-witnesses/` (section 7).

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
- `status`: `active` or `withdrawn` (section 13), always `active` for an owner;
- `documentVersion`, for a document or a collection: equal to `version` in `datacite.json`;
- in every version of a line, `name` and `owner` (sections 5 and 6), and in a branch `parent`, its branch point (section 9); a draft has none of them.

An owner object has only these fields, and MAY have `extensions` (below), though data concerning its key log goes in `keys.json` (section 6).

A <dfn>note</dfn> is an object with `text`, a short plain text, or `path` and `mediaType`, a file of the content of the same object version, or both.

A document MUST have `mainSource` (a logical path) and `sourceFormat` (its media type), and SHOULD have `renditions`, a list of `path` (a logical path) and `mediaType`, and `toolchain`, a list of tools with `name`, `version` and, OPTIONALLY, `packages`, enough to reproduce the renditions. A document version without its sources has instead `sourcesMissing`, a note saying why ("arXiv keeps only the PDF of this version"), and at least one rendition; a rendition is never presented as a source. A document MAY have:

- `changes`: a note saying what changed in this document version, deposited with it (like arXiv's comments);
- `stage`: the stage of this document version, with `scheme` and `value`; for articles the RECOMMENDED scheme is `NISO-JAV` (NISO Journal Article Versions: `AO`, `SMUR`, `AM`, `P`, `VoR`, `CVoR`, `EVoR`), and other content uses other schemes (editions, software releases), named by the archive;
- `history` and `notices` (section 4.2), each notice a note with the `documentVersion` it is about and a `date`.

A collection has none of these fields of a document. A document or a collection MAY have:

- `licence`: a note with the full text or terms of the licence (for licences without an SPDX identifier); `rightsList` in `datacite.json` remains the description for readers;
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
- `Available`, SHOULD be present: when this document version first became public, anywhere (its date on the service it was imported from, or its deposit, section 4.1, if this archive made it public);
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

## Plan of the rebuilt text

Each part is rebuilt in turn, from the reference text and an audit of the concept, and agreed before the next. Sections 1 to 4 are rebuilt; the others are planned as follows, and read meanwhile in the reference text.

5. Names: genesis records and names.
6. Owners: key logs, retiring keys, ending, forks.
7. Lines and signatures: signing, statuses, adding versions.
8. Collections: catalogues, selections, members (with `HasPart` in `datacite.json`, moved from section 4).
9. Branches and accepted copies.
10. Drafts and sealing.
11. Copies, mirrors and moving.
12. Identifiers: `sheaf:` URIs, resolution, indexes.
13. Withdrawal, takedown and tombstones.
14. Verification.
15. Security, privacy and rights.
16. Versioning of this specification, and changelog.

Appendices: A. profiles (Zenodo, TeXmacs, website); B. JSON Schemas; C. examples; D. rationale; E. references.
