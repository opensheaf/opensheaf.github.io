# OpenSheaf: an open format for document archives and collections

*Specification, version 0.1 (draft), 18 November 2026. OpenSheaf is a common, open format for archives of scholarly documents and for collections of them, built on the Oxford Common File Layout (OCFL 1.1) and the DataCite Metadata Schema (4.7). The text is licensed under CC BY-SA 4.0; the JSON Schemas are dedicated to the public domain (CC0 1.0).*

> [!WARNING]
> **Draft, being rebuilt.** This text is being rebuilt, concept by concept, from the [reference text](reference/opensheaf-specification-0.1-full.md) of PR #30, into a shorter and coherent whole. A concept not yet rebuilt is read in the reference text. Until version 1.0, any revision may change the format in incompatible ways.

## Plan of the rebuilt text

Each part is rebuilt in turn, from the reference text and an audit of the concept, and agreed before the next.

1. Introduction and conventions, with the terms defined where they are introduced.
2. Archives: the discovery document, addresses, the layout of the storage root.
3. Objects: OCFL rules, documents and document versions, `object.json`, `datacite.json`.
4. Names: genesis records and names.
5. Owners: key logs, retiring keys, ending, forks.
6. Lines and signatures: signing, statuses, adding versions, copies.
7. Collections: catalogues, selections, members.
8. Branches and accepted copies.
9. Drafts.
10. Copies, mirrors and moving.
11. Identifiers: `sheaf:` URIs, resolution, indexes.
12. Withdrawal, takedown and tombstones.
13. Verification.
14. Security, privacy and rights.
15. Versioning of this specification, and changelog.

Appendices: profiles (Zenodo, TeXmacs, website), JSON Schemas, examples, rationale, references.
