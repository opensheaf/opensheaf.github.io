---
name: opensheaf-spec
description: The concepts of the OpenSheaf specification (archives, objects, document and object versions, names and genesis records, owners and key logs, forks of key logs and healing, lines and signatures, catalogues and selections, pins, branches and accepted copies, drafts and sealing, mirrors, sheaf: URIs, withdrawal and takedown, verification, profiles and extensions) and how to change the specification, its schemas, the FAQ and the use cases. Use before editing any of them, or answering questions about the format.
---

# The OpenSheaf specification

The source is `opensheaf-specification-0.1.md` (one line per paragraph). This
is a map of it; the text is authoritative. Section numbers below are those of
the text, rebuilt on 18 and 19 November 2026 (PR #30). The text before the
rebuild, with its own numbering and the changelog of every earlier revision,
is kept in `reference/opensheaf-specification-0.1-full.md`; never cite its
section numbers.

## What it is

A format for archives of scholarly documents, as plain files served as a
static website, and for collections of them across archives. It defines only
what its two standards leave open:

- **OCFL 1.1** for storage: objects, versions, inventories, SHA-512 digests;
- **DataCite 4.7** for description (`datacite.json`, in the form of the
  DataCite REST API attributes);
- OpenSheaf itself: discovery, names, owners and signatures, collections,
  branches, withdrawal and takedown, profiles and extensions.

## Map of the text

1 introduction; 2 conventions and conformance (classes archive, collection,
owner tool, verifier, resolver; profiles; extensions; schemas); 3 archives
(3.1 discovery document, 3.2 storage root and layouts); 4 objects (4.1 common
rules, 4.2 documents and document versions, 4.3 `object.json`, 4.4
`datacite.json`); 5 names (5.1 genesis record, 5.2 computing a name, 5.3
origin and clashes, 5.4 reused genesis records); 6 owners (6.1 key log, 6.2
creating an owner and choosing keys, 6.3 ending, forks and healing, 6.4 after
an end, a fork or healing, 6.5 key logs travel with the objects they sign,
6.6 keepers); 7 lines and signatures (7.1 signing, 7.2 witnesses and
signature files, 7.3 statuses, 7.4 one writer per line, 7.5 adding versions,
7.6 integrity); 8 collections (8.1 catalogues and selections, 8.2
`members.json`, 8.3 catalogue members, 8.4 selection members, 8.5 pins and
statuses of members, 8.6 description and rights); 9 branches and accepted
copies (9.1 `parent`, 9.2 first version and evidence, 9.3 checking, 9.4
moving the branch point, 9.5 continuing another owner's work, 9.6 accepted
copies, 9.7 description and rights); 10 drafts and sealing; 11 copies and
mirrors; 12 `sheaf:` URIs, resolution, indexes (12.1 URIs, 12.2 short forms,
12.3 resolution, 12.4 searching for a work, 12.5 indexes, 12.6 gateways); 13
withdrawal, takedown and tombstones; 14 verification (14.1 findings, 14.2 to
14.6 the checks in order); 15 security, privacy and rights; 16 versioning
(16.1 versions, **16.2 changelog**). Appendices: A profiles (A.1 Zenodo,
A.2 TeXmacs, A.3 website), B JSON Schemas, C examples (computed and
validated; C.8 a fork of a key log), D rationale, E references. Open
questions are listed at the end of the sections they concern.

## Concepts

- **Archive** (3): a host, named by no file: a discovery document
  `opensheaf.json` and a storage root at a base URL, a location that may
  change; its files may be served at several base URLs, each a location of
  the same archive. It holds the lines owners write there and copies of
  lines written elsewhere, and decides only which owners it hosts. No
  `mirrors` or `replicas` field: every location is a hint, checked by pins
  and signatures.
- **Discovery document** (3.1): a map, never a witness: `format`,
  `specification`, `name`, `storageRoot`, `storageLayout`, `profiles`,
  `objects` (`id`, `kind`, `name`, `owner`, `head`, `inventorySha512`,
  `status`, optional `label`; no drafts); SHOULD `mainCollection`,
  `contact`, `extensions`; MAY `owners`, `drafts`, `indexes`, `feed`; MUST
  `tombstones` once an object is taken down. **Labels**: readable, local,
  not identifiers.
- **Storage root and layouts** (3.2): the owner-name layout
  (`<owner>/<name>/`, drafts at `draft/<id>/`, the key log at
  `<owner>/<owner>/`), default; OCFL `0003` hashed layout with default
  parameters for large archives.
- **Object** (4): kind `document`, `collection` or `owner`; identifier
  `sheaf:<name>:<owner>` (a draft `sheaf:draft:<id>`), never reused once
  sealed. **Object version** (`v1`, ...) changes at every change and never
  changes once made, except in a draft and at a fork of a key log.
  **Document version** (4.2): numbered by the line's owner from 1 without
  gaps; new exactly when the document's own files change. **Pin** (4):
  (object version, SHA-512 of its inventory file). Identity files (4.1):
  `genesis.json` and a branch's `parent.*`; reserved top-level names.
- **Documents** (4.2): sources, renditions, notes; description-only
  versions, completion of `sourcesMissing`, `history`, current version,
  notices. `object.json` (4.3): `format`, `specification`, `kind`,
  `status`, `documentVersion`, `name`, `owner`, `parent`; documents
  `mainSource`, `sourceFormat`, `renditions`, `toolchain`, `changes`,
  `stage`, `history`, `notices`, `licence` (documents only); documents and
  collections `agreement`, `external` (deposit or source records),
  `withdrawal`, `extensions`. `datacite.json` (4.4): required and
  recommended properties, mathematics in `$...$`, dates, relations; DOIs
  written bare.
- **Names** (5): the name is the SHA-256 of `opensheaf-name-<k>\n` and the
  bytes of `genesis.json`, in base32, 52 characters, k (0 to 15) in the last
  4 bits; the genesis name is algorithm 0. Originator's line has no parent;
  every other line of the record is a branch. Clashes resolved where a line
  is made; reused genesis records are refused unless signed by the
  originator or a confirmed branch (5.4); aliases open (#44).
- **Owners and key logs** (6): an owner object, named by its genesis record
  (first `keys` and `threshold`); its versions are its key log, `keys.json`
  (`keys` as Ed25519 `did:key`, `threshold`, `extensions`, `keeper`,
  `ended`, `successor`). Each version vN+1 is signed by `threshold` keys of
  vN. Retiring a key: leaving it out. Thresholds: 1 with a spare key, or 2
  of 3 (6.2).
- **Ending** (6.3): a signed last version with `ended` (and optional
  `successor`, a hint); no line signature names it; an **ended** owner signs
  nothing.
- **Forks of a key log, fork records, nullified keys, tainted, healing** (6.3,
  provisional, #58): two different versions of one number, each signed
  against the version before, are a fork, at its fork point. An archive
  holding one side that meets the other replaces its version at the fork
  point by a **fork record**: an unsigned version made by that archive,
  holding `genesis.json`, `object.json` and the conflicting versions it
  carries under `forked/<d>/` (inventory, checksum, `keys.json`, signature
  files with their witnesses), and drops every later version. The keys that
  sign carried versions are **nullified**. A key log whose latest version is
  a fork record is **tainted**: only a **healing version** follows it (a
  version at the fork point carrying the forked versions, with no
  nullified key in its `keys.json`, signed by `threshold` keys of the
  version before, none nullified). Rules for versions that meet:
  supersede, or replace both by a fork record; witness files go with their
  versions. These are the only changes of object versions outside drafts.
  An exposed key that could reach a threshold: the owner ends, or nullifies
  the keys by a fork and heals; otherwise retiring is enough. There is no
  revocation and no "evidence of forks" folder.
- **After an end, a fork or healing** (6.4): signatures stay good; readers
  weigh them by other evidence (copies, pins, timestamps). No version is
  added that needs a nullified key. Lines of ended or tainted owners only
  from copies found elsewhere.
- **Key logs travel** (6.5) beside every copy, as owner objects in the same
  storage root (the line's owner and every parent owner); the longer copy
  wins; an owner moves by copying its folder. **Keepers** (6.6): ORCID iD
  or domain, confirmed by ORCID or `/.well-known/opensheaf`
  (`opensheaf-keeper/0.1`, `owners`, `successors`).
- **Lines and signatures** (7): a line is its signed versions, wherever
  stored. Signature files `extensions/opensheaf-witnesses/<v>/signature-<k>.json`
  (`object`, `version`, `inventorySha512`, `signer`, `key`, `keyLog` as a
  pin `sheaf:<owner>/v<n>?sha512=...`, `signature` over a five-line
  message); others' `witness-<label>.json`. Witnesses are never replaced or
  removed, except by a takedown or at a fork of a key log. **Statuses**
  (7.3): signature files invalid, unchecked or good (for ever); versions
  signed (directly or vouched for), unchecked, or not a version (invalid or
  unsigned). Readers use the latest signed version. Forks of a line (7.4)
  are reported, never recorded. Adding (7.5): only versions signed once
  added; versions held stay, but for takedowns and key-log forks.
- **Collections** (8): `members.json` with `type` `catalogue` (pins whole
  objects, MAY `follow` `"latest"`) or `selection` (revision sets of
  `documentVersion`, `version`, `inventorySha512`); members name `kind`,
  `name`, `owner`, `at` (equal hints); member statuses verified, mismatch,
  unchecked, not a version, unavailable, removed (8.5).
- **Branches** (9): a line of another owner from a signed parent version,
  declared in `parent`; evidence `parent.inventory.json`,
  `parent.object.json`, `parent.signatures/`, `parent.chain/`; verdicts
  inconsistent, confirmed, unchecked; the branch point only moves forward.
  **Accepted copy** (9.6): a branch kept by a selection's owner, never a
  mirror.
- **Drafts and sealing** (10): drafts belong to the reserved owner `draft`,
  never signed, pinned, copied or named by URIs; the only objects that may
  be rewritten or deleted (no tombstone). Sealing makes the originator's
  line, at the owner's request.
- **Copies and mirrors** (11): a mirror is a copy in an archive where the
  line's owner does not write, unmarked, grown only by the owner's signed
  versions; allowed only when licences allow redistribution (#39, #34).
- **`sheaf:` URIs, resolution, indexes, gateways** (12): forms of 12.1,
  canonical form, short forms of at least 8 characters; external records
  (Zenodo, Software Heritage) are witnesses, not copies, and resolve
  nothing; indexes `names/`, `owners/`, `sha512/`; gateways redirect only
  temporarily to checked copies.
- **Withdrawal, takedown, tombstones** (13): a withdrawal is a
  description-only version with `status` `withdrawn`; drafts are never
  withdrawn. Every removal of a sealed object is a **takedown**, which
  leaves a **tombstone** (`id`, `kind`, `name`, `owner`, `genesisName`,
  `lastVersion`, `inventorySha512`, `date`, `reason`); owner objects others
  need stay.
- **Verification** (14): findings are **errors** (breaches of MUST, an
  archive or object without errors passes), **warnings** (SHOULD, breaches
  the archive cannot repair, checks not made) and **results** (statuses,
  verdicts, forks, ended, tainted and healed owners, nullified keys,
  withdrawals, removals).
- **Security, privacy, rights** (15): untrusted input, serving, secrets,
  pseudonymous owners, metadata (fork records included) under CC0.
- **Profiles** (appendix A): `zenodo` (a record is a witness, not a copy),
  `texmacs`, `website`. **Extensions** (2): data under `extensions` in
  `object.json` or `keys.json`; never change the core.
- **Timestamps: an extension, not the core.** `opensheaf-timestamps-0.1.md`:
  `.tsr` and `.ots` files beside signature files, the owner's declaration
  in `keys.json`; evidence only, it changes no status.

## Schemas

`schemas/opensheaf-archive-0.1.schema.json` (`opensheaf.json`),
`opensheaf-object-0.1.schema.json` (`object.json`, also as
`parent.object.json`), `opensheaf-collection-0.1.schema.json`
(`members.json`), `opensheaf-genesis-0.1.schema.json` (`genesis.json`),
`opensheaf-keys-0.1.schema.json` (`keys.json`, also as carried by fork
records), `opensheaf-signature-0.1.schema.json` (signature files and
`witness-<label>.json`), `opensheaf-keeper-0.1.schema.json`
(`/.well-known/opensheaf`), `opensheaf-index-0.1.schema.json` (index files
and `indexes.json`) and, for the timestamps extension,
`opensheaf-timestamps-0.1.schema.json`; JSON Schema 2020-12, CC0 (appendix
B). The schemas of `genesis.json`, `keys.json`, signature files and the
keeper's file are closed (no other properties); the others allow other
properties, which carry no meaning. A change of a field in the text needs
the same change in its schema, and the other way round.

## Changing the specification

- 0.1 is a draft: changes go into 0.1 itself, with a dated changelog entry
  (section 16.2) and the date in the heading updated; no compatibility rules
  for draft names. The timestamps extension (`opensheaf-timestamps-0.1.md`)
  and the git companion (`opensheaf-git-0.1.md`) have their own changelogs
  and dates, updated when they change.
- A new field: in the text (where its file is defined), in the schema, in
  the verification rules (14) if it can be checked, in an example (appendix
  C) if it is common, and in the rationale (appendix D) if the choice is not
  obvious.
- A renamed concept: every file of the repository (specification, timestamps
  extension, git companion, schemas, FAQ, use cases, README, AGENTS.md, this
  skill), including words split across wrapped lines; then the tools and
  templates in other repositories follow.
- After a change, check the use cases, the FAQ and the companions against
  it: they must agree, and the "What happens when ..." table of the use
  cases summarises behaviour.
- Open questions go to issues on `opensheaf/opensheaf.github.io`, among
  them: #13 decentralised holding (split into #39 custodians' copies, #40
  statements by collections, #41 owner proofs), #19 scale, #22 external
  records and pins, #25 withdrawal details, #27 and #45 collections, #28
  companion documents, #29 private archives and drafts, #32 single-file
  takedowns, #33 takedowns and copies, #34 licences, #35 a gateway, #36
  registering `sheaf`, #37 resolution through mirrors, #44 aliases, #46,
  #48, #49, #50, #51 and #23 verification details, #54 custody policies, #55
  field names of owners and signatures, #57 branch numbering, #58 fork
  records and healing (provisional). Read the relevant issue before
  touching its topic; do not settle an open question without agreement.

## Design principles to keep

- Standards first: use OCFL and DataCite as they are; invent only what they
  leave open.
- Fixed versions: nothing deposited ever changes; corrections, notices,
  descriptions and withdrawals are new object versions. The one exception
  is the replacement of key-log versions at a fork.
- Integrity comes from pins, not places: any matching copy is valid.
- Statements are made by their authors in their own objects: a document
  never states the collections or reviews about it.
- Keeping and vetting are different acts (catalogues and selections; mirrors
  and accepted copies).
- Owners sign, places host: a version is its owner's when its signatures
  hold, wherever it is found, and no archive can add to another owner's
  line; locations are hints.
- A minimal core: richer relations are built on top, by links, DataCite
  relations or extensions, never by growing the core.
