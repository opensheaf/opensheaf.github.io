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

## Plan of the rebuilt text

Each part is rebuilt in turn, from the reference text and an audit of the concept, and agreed before the next. Sections 1 and 2 are rebuilt; the others are planned as follows, and read meanwhile in the reference text.

3. Archives: the discovery document, addresses, the layout of the storage root.
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
