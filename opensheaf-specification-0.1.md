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

## Plan of the rebuilt text

Each part is rebuilt in turn, from the reference text and an audit of the concept, and agreed before the next. Sections 1 to 3 are rebuilt; the others are planned as follows, and read meanwhile in the reference text.

4. Objects: OCFL rules, documents and document versions, `object.json`, `datacite.json`.
5. Names: genesis records and names.
6. Owners: key logs, retiring keys, ending, forks.
7. Lines and signatures: signing, statuses, adding versions.
8. Collections: catalogues, selections, members.
9. Branches and accepted copies.
10. Drafts and sealing.
11. Copies, mirrors and moving.
12. Identifiers: `sheaf:` URIs, resolution, indexes.
13. Withdrawal, takedown and tombstones.
14. Verification.
15. Security, privacy and rights.
16. Versioning of this specification, and changelog.

Appendices: A. profiles (Zenodo, TeXmacs, website); B. JSON Schemas; C. examples; D. rationale; E. references.
