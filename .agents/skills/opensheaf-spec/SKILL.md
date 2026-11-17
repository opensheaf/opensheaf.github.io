---
name: opensheaf-spec
description: The concepts of the OpenSheaf specification (archives, objects, document and object versions, catalogues and selections, pins, mirrors, accepted copies, withdrawal, extensions; on the branch proposal/identity also names, owners, lines, drafts and sealing, branches and sheaf: URIs) and how to change the specification, its schemas, the FAQ and the use cases. Use before editing any of them, or answering questions about the format.
---

# The OpenSheaf specification

The source is `opensheaf-specification-0.1.md` (one line per paragraph). This
is a map of it; the text is authoritative. Section numbers below are those of
the text.

This map describes the branch `proposal/identity` (PR #30, not yet agreed),
whose text is the identity proposal throughout: owners with keys and key logs,
lines, archives as hosts, identifiers from lines (sections 5, 6, 10.5, 13.2
and changes everywhere). On `main` the earlier model still holds (archive
identifiers as `tag:` URIs, short chosen object identifiers, the flat-direct
layout, `mirrorOf`, `keys` in the discovery document); statements about `main`
below are labelled so.

## What it is

A format for archives of scholarly documents, as plain files served as a
static website, and for collections of them across archives. It defines only
what its two standards leave open:

- **OCFL 1.1** for storage: objects, versions, inventories, SHA-512 digests;
- **DataCite 4.7** for description (`datacite.json`, in the form of the
  DataCite REST API attributes);
- OpenSheaf itself: discovery, collections, provenance (`object.json`),
  withdrawal, profiles and extensions.

## Concepts

- **Archive** (sections 5, 6): a host: one storage root and one discovery
  document `opensheaf.json` at its base URL, holding the lines of any number
  of owners and copies of lines kept elsewhere. It has no identity of its own
  (6.2): it is found at its base URL, a hint, and owns nothing by hosting. An
  archive that makes collections does so as an owner.
- **Discovery document** `opensheaf.json` (6.1): a mutable map, never a
  witness: format, specification, name, storage root, layout
  (`opensheaf-owner-name-storage-layout`, or
  `0003-hash-and-id-n-tuple-storage-layout` for large archives, section 5,
  also in `ocfl_layout.json`), `objects` (each with `id`, `kind`, `head`,
  `inventorySha512`, `status`, `name`, `owner`, optional `label`; drafts
  excluded), `profiles`; SHOULD `mainCollection`, `contact`, `extensions`; MAY
  `drafts`, `owners`, `mirrors`, `tombstones`, `indexes`, `feed`. Everything
  it says is checked against the storage root; it is a list, not a guarantee
  that an owner has no lines elsewhere.
- **Object** (3, 7): an OCFL object, of kind `document`, `collection` or
  `owner`. Its identifier is its line, `sheaf:<name>:<owner>` (6.3), never
  reused once sealed; a draft's is `sheaf:draft:<id>`. Readable names are
  `label`s in the discovery document, not permanent.
- **Object version** (`v1`, `v2`, ...): an OCFL version; changes at every
  change of the object. Every version folder holds its inventory and checksum
  (7.1). The inventory records who deposited a version and when; the owner's
  signatures say whose it is.
- **Document version** (7.3): the version of the work, numbered by the owner
  of the line from 1 without gaps; changes exactly when the document's own
  files change. External labels (arXiv `v3`) go in `external`.
- **Description-only version** (7.3): an object version that keeps the files
  of an existing document version and changes only the description, the state
  or the notices (a DOI, a stage, a notice, a withdrawal).
- **History** (7.3): the order of the document versions in the work; by
  number, unless `history` in `object.json` lists object versions (needed when
  a version is deposited out of order). **Current version**: the last entry of
  the history of the head; dates never order versions.
- **Notices** (7.3, 9): statements about a version (an erratum), added by
  description-only versions, never removed.
- **Note** (9): a short `text`, or a file (`path`, `mediaType`), or both; used
  for change notes, notices, withdrawals, `sourcesMissing`.
- **Collection** (7.4, 10): an object whose versions hold `members.json`. Two
  kinds (`type` in `members.json`):
  - **catalogue**: keeps objects whole and is impartial about their versions;
    each member pins an object up to a version (`version`, `inventorySha512`)
    and MAY `follow: "latest"`. An archive's main collection is a catalogue of
    its documents, kept by the archive acting as an owner. Members name their
    line (`name`, `owner`) and give `at`, a list of base URLs, all equal
    hints.
  - **selection**: vets particular revisions; each member pins a **revision
    set** (`revisions`: `documentVersion`, `version`, `inventorySha512`); it
    changes only by an act of its curator, a new version of the selection.

  Collections are objects, so they nest and cross archives.
- **Pin** (3, 10.2): (object version, SHA-512 of that version's inventory). It
  fixes every byte of the version and of the versions before it, so
  collections are hash trees across archives; any copy whose bytes match a pin
  is as good as the original (6.4).
- **Mirror** (10.4): a byte-for-byte copy of a whole line kept elsewhere, with
  the key logs of its signers, the same line (no `mirrorOf`), updated only by
  copying the owner's versions; allowed only if the licences of all versions
  allow redistribution (copying by agreement is open, #39).
- **Accepted copy** (10.5): a branch kept by a selection's owner from a vetted
  revision; never a mirror.
- **Withdrawal** (11.1): a description-only version with `status` `withdrawn`;
  the content stays. **Takedown** (11.2): the object is deleted and a
  **tombstone** stays in the discovery document (11.3); owner objects that
  kept objects need stay, and an owner object is taken down only for itself,
  leaving the signatures that need it unconfirmed (11.2).
- **Witnesses** (13.2): in `extensions/opensheaf-witnesses/` of the object,
  not part of any version: the owner's signature files (required for every
  sealed version), others' `witness-<label>.json`, and timestamp proofs of
  signature files as the timestamps extension defines them.
- **Profiles** (4, appendices A-C): `zenodo` (DOIs from Zenodo), `texmacs`,
  `website`; declared in `profiles`.
- **Extensions** (4): specifications published separately, named by a URI,
  whose data goes under `extensions` in `object.json` (or, for the key log,
  in `keys.json`, as the timestamps extension does); they never change the
  core, and readers ignore those they do not know.

## Names, owners and lines (6.5, 6.6, 10.5)

The model follows #55 and #52 (and their comments), and the audit fixes of 17
November 2026; read them before touching any of this.

- **Genesis record and name** (6.5): `genesis.json` (`format`, `kind`,
  `created`, `originator`, `nonce`; an owner's has `kind` `owner` and no
  `originator`), written when a work is sealed or an owner created, kept byte
  for byte in every later version and branch, never re-serialised. The
  **name** is the SHA-256 of the seed `opensheaf-name-<k>` and a line feed,
  then the record, in lowercase base32: 52 characters, `^[a-z2-7]{52}$`; the
  last character's 4 spare bits hold k, from 0 to 15 (0, the default, gives
  `a` or `q`).
- **Owner** (6.5, 7.5): a keyed identity (person, group, institution); an
  object of kind `owner`, named by its genesis record, which lists its first
  `keys` and `threshold` (the **owner name**, recorded in `originator`,
  `owner`, `parent.owner`, `sheaf:` URIs); an owner object is its own
  originator, always `active`, never withdrawn or branched; copied with the
  lines it signs, and MAY be copied or mirrored on its own (moving, fresher
  key logs); MAY have `extensions`; no `datacite.json`. Its versions are its
  **key log**: `keys.json` (`format`, `keys` as Ed25519 `did:key`, `threshold`
  at most the number of keys; optional `keeper`, `https` URLs; `extensions`,
  the data of extensions concerning the key log, keyed by URI, such as the
  timestamps declaration); optional `revoked`, entries `{key, since?}` for
  keys that may have been exposed, `since` the owner's estimate of the
  exposure, never listed in `keys` again and kept in `revoked` by every later
  version, with the same or an earlier `since`). A key is **retired** by
  leaving it out of `keys` (its signatures keep counting) and **revoked** by
  listing it in `revoked` (its signatures unconfirmed, unless a later signed
  version of the same line extends the version, or the timestamps extension
  dates them before the revocation and `since`); a possibly exposed key MUST
  be revoked, not retired. The first `keys.json` repeats the genesis record's
  keys (as a set) and threshold and is signed by them (`keyLog` naming
  itself); vN+1 is signed by `threshold` keys of vN (`keyLog` naming vN). One
  `threshold` governs the key log and the lines (as in Radicle); a threshold
  binds only the signatures naming its version, so raising it or retiring keys
  does not shut out earlier keys: revoke them, or use threshold 2+ from v1.
  The optional **keeper** link (ORCID iD, domain) is confirmed by the keeper
  (ORCID record, `/.well-known/opensheaf`). No named owners, no owner
  identifiers. Anonymous owners (16): an owner made for the purpose,
  without `keeper`.
- **Signing** (6.5, 13.2): every sealed version of a line is signed by its
  owner: at least `threshold` signature files of the owner that count (valid,
  not unconfirmed), from distinct keys, naming one key-log version; other
  files (stray, other key-log versions, other owners) are ignored and
  reported, never fatal. Files
  `extensions/opensheaf-witnesses/<v>/signature-<k>.json` (`<k>` the first 16
  base32 characters of the SHA-256 of the `did:key`; fields `object`,
  `version`, `inventorySha512`, `signer` and the owner of `keyLog`, both the
  line's owner, `key`, `keyLog` as a pin `sheaf:<owner>/v<n>?sha512=...`,
  `signature`), signing a defined five-line message binding object, version,
  inventory and key-log version. A key signs a version at most once; signature
  files, and witnesses beside them, are never re-serialised. **A signature
  counts when it is valid under the key-log version it names** (section 6.5,
  Signing; replacing an earlier rule that left unconfirmed a signature whose
  key was later removed or whose threshold was raised), and keeps counting:
  retiring a key, raising the threshold or changing extension data never
  undoes a signature, and nothing need be signed again (owners MAY add
  signatures); key-log versions follow the same rule (vN+1 checked against
  vN). Exceptions, all **unconfirmed**: a key revoked in a known version (not
  for key-log versions up to and including the revoking one, on its side; not
  for a revocation only on a side of an unresolved fork), a key-log version
  after the point of an unresolved fork (on any side), a key log not available
  (absent or taken down). **A signed version confirms what it extends**: a
  line version unconfirmed only by a later revocation is confirmed by any
  later signed version of the line that extends it, and a branch point by a
  later signed version of the parent's line; so revocation erases only what
  the owner does not continue. **Unverifiable**: a key log that is available
  but does not reach the named version (a made-up version); never a version of
  the line. A key log is forked by any valid next version (a line only by
  signed ones); an archive keeping one side keeps the first differing version
  of each other side under `extensions/opensheaf-witnesses/fork/<n>/<d>/`.
  **Unconfirmed is not invalid** (6.5, 13.2, terminology): an unconfirmed
  signature or version is kept, copied (mirrors copy it with its status) and
  shown, but not relied on (pins, resolution, members, branch points, later
  key-log versions) until confirmed; it never makes a fork of a line and never
  takes a line's place: a signed history departing from it replaces it. States
  of a signature (13.2): invalid (checked against `key` first), valid
  (counts), unconfirmed, unverifiable; of a version: signed (= "signatures
  hold"), unconfirmed, unsigned, unverifiable, invalid. An extension acts on
  signatures only within that status (section 4). Witnesses are never
  replaced: a completed timestamp proof is a new file. Third parties:
  `witness-<label>.json`, another owner's `keyLog`.
- **Timestamps: an extension, not the core.** The core (6.5, 13.2) defines no
  timestamps: a fork of a key log is reported, not resolved, and signatures
  naming key-log versions after the fork point are unconfirmed; signatures of
  a revoked key are unconfirmed unless a later signed version confirms them;
  revocations on one side of a fork apply only once it is resolved. Timestamp
  proofs MAY sit beside signature files as witnesses; the core verifier
  ignores what it does not know. Everything else is in
  `opensheaf-timestamps-0.1.md` (URI
  `https://opensheaf.org/opensheaf-timestamps-0.1`): RFC 3161 `.tsr` and
  OpenTimestamps `.ots` files beside signature files, named
  `signature-<k>.json.<d>.tsr|.ots` with `<d>` the first 16 base32 characters
  of the SHA-256 of the timestamp file's own bytes (copies merge), the owner's
  declaration in `keys.json` under `extensions` (`timestamps`: `keylog`/`all`,
  `all` needed to date line signatures; `timestampAuthorities`: SHA-256
  fingerprints), checks at `genTime`, complete proofs only (a completed proof
  is a new file), re-stamping, the declaration in force (latest known key-log
  version; during a fork, the last version all sides share; after it is
  resolved, the latest of the owner's side), a removed authority's earlier
  tokens, dropping a declaration (ends every confirmation it gave), the time
  of a version (`threshold`-th earliest date) and ties (two hours for Bitcoin
  times); it confirms signatures of a revoked key dated before both the time
  of the revoking key-log version and its `since` (which bounds stripping of
  early stamps), verifiers merging the timestamp files of every copy, and
  resolves forks (any number of sides) by the strictly earliest time only when
  every side is dated; missing stamps never unconfirm anything (undated
  versions are a warning); branches with complete proofs; owners SHOULD adopt
  it from their first key-log version, with `all`. Its schema is
  `schemas/opensheaf-timestamps-0.1.schema.json`.
- **Key logs travel with the objects they sign** (6.5): a copy keeps the owner
  objects of its line's owner and of its parents' owners in its storage root
  (third parties' key logs MAY be kept; a tombstone stands in for an owner
  object taken down), up to the latest key-log version its maker knows;
  readers use the longest of copies that extend one another, never across a
  fork; freshness cannot be proved offline. A line is its signed versions,
  wherever stored; an archive MUST NOT add to a line a version its owner did
  not sign. No signed list of an owner's lines exists (lines are linear).
- **Archives** (6.1 to 6.4): hosts with no identity, found at their base URL;
  every location (`at` of members, a list of base URLs; `mirrors` of a
  discovery document; `at` of URIs) is a hint. They choose which owners they
  host (`owners` in the discovery document). An owner moving to another
  archive copies its key log and continues its lines (not a branch); a branch
  happens only when the owner changes.
- **Identifiers and labels** (6.3, 5): an object's OCFL `id` is its line,
  `sheaf:<name>:<owner>`, for branches too (a draft is `sheaf:draft:<id>`,
  `<id>` a label of at most 64 characters, chosen locally, not reused while
  the draft exists); default layout `opensheaf-owner-name-storage-layout`
  (`<owner>/<name>/`, drafts in `draft/<id>/`; the key log at
  `<owner>/<owner>/`), or `0003` for large archives, where line identifiers
  (111 characters) are always shortened to 100 encoded characters plus the
  digest; an identifier of neither form is an error, and the owner-name layout
  has no configuration. Readable `label`s in the discovery document, not
  permanent.
- **Clashes** (6.5): one object per line in a storage root; sealing draws a
  new nonce if the owner's line is taken; a branch takes `parent.name`, moves
  its branch point onto the owner's own earlier branch of the same parent line
  when the new branch point is later in the parent line's history, or takes
  the smallest free algorithm number above the parent's (refused if none up to
  15); lines stay taken after a takedown. No `sealed`: an archive accepts an
  object whose genesis record it holds only if it is signed by the record's
  originator (the same line) or carries a chain of parent evidence
  (`parent.chain/`) back to the originator's line (a branch), compared by the
  algorithm-0 name, also against tombstones' `genesisName`. A work is searched
  for under all 16 names, keeping byte-identical records and lines whose
  signatures hold. A tool never reuses a nonce nor copies a genesis record
  into anything but a copy or branch of its work. Aliases open (#44).
- **Draft and sealing** (6.5): drafts are a sandbox owner `draft`, at
  `draft/<id>/`: never signed, pinned or copied out of their archive, the only
  objects that may be rewritten or deleted, listed apart or not at all.
  Sealing, at the owner's request before the work first leaves the owner's
  hands, makes a new object (the line); draft versions are not part of it.
- **Branches** (10.5): lines of other owners with the same genesis record,
  declaring `parent` (`owner`, `name`, `objectVersion`, `documentVersion`,
  `inventorySha512`, `url`). No deep branches: a branch is a new object
  holding the branch point plus, as content, `parent.inventory.json`,
  `parent.object.json`, `parent.signatures/` and, for a branch of a branch,
  `parent.chain/` (the parent's own evidence, nested one level per generation,
  back to the originator's line; finite, depth may be bounded), so its
  evidence is complete with the parents' owners' key logs, which travel beside
  it as owner objects (never as content); the parent's history, if wanted, is
  a copy of the parent's line beside it (OCFL inventories fix their object's
  id). Branch points move only forward; accepted copies are branches of the
  selection's owner. Verdicts: inconsistent (a failed check, missing or
  invalid parent signatures), unconfirmed (the parent version unconfirmed, or
  its owner's key log missing), confirmed.
- **`sheaf:` URIs** (6.6): `sheaf:<name>`, `sheaf:<name>:<owner>`,
  `sheaf:<name>:*`, `/v<n>`, `?sha512=` (a pin), `at=` (a hint),
  `sheaf:<owner>` (a key log; `sha512` after its object version). Copies count
  only if signatures hold; a resolver uses the latest head among valid copies,
  and keeps looking past a tombstone (hosts can add unsigned ones), reporting
  both; short forms of at least 8 characters (16 printed), ambiguous across
  owners. **Resolvers** are a conformance class (4).
- **Indexes** (6.6): `names/`, `owners/`, `sha512/` with prefixes of 2 to 4
  characters (`names/` entries carry `name`, `originator` (for an owner
  object, its own name), `owner`, `id`, `label`, `genesis` (the exact text of
  `genesis.json`), `status`; no `ownerId`, `archiveId`); maps, never
  witnesses. **Gateways**: domain open (#35); registering `sheaf` is #36; the
  format's name, and so the gateway and the `opensheaf-` strings, may change.
- **Open questions**: listed at the end of section 6.5; do not settle them in
  the text without agreement.

## The files of an object version

- **Document**: sources (the main source and what it needs), renditions (a
  PDF, recommended), files of notes, `datacite.json`, `object.json`. No HTML
  or other presentation files.
- **Collection**: `datacite.json`, `object.json`, `members.json`.
- **Owner object**: `genesis.json`, `keys.json`, `object.json` (no
  `datacite.json`).
- **Identity files**: `genesis.json` in every sealed version, and
  `parent.inventory.json`, `parent.object.json`, `parent.signatures/` and,
  for a branch of a branch, `parent.chain/` in every
  version of a branch; these names are reserved.
- `datacite.json` (8): MUST `titles`, `creators`, `publicationYear`, `types`,
  `version` (the document version as a string), `publisher`; SHOULD abstract,
  subjects, dates, `rightsList`, `relatedIdentifiers`. Dates: `Issued` (first
  public appearance, anywhere), `Available` (this version first public),
  `Updated`, `Created`, `Submitted`, `Accepted`, `Withdrawn`. Mathematics in
  titles and abstracts as `$...$` LaTeX. Relations (8.1): `IsVersionOf` the
  concept DOI, `IsNewVersionOf`, `IsIdenticalTo` / `IsVariantFormOf` for the
  same work elsewhere, `HasPart` for collection members with DOIs; a document
  never states the collections that include it.
- `object.json` (9): MUST `format`, `specification`, `kind`, `documentVersion`
  (not for owner objects), `status`, and `name` and `owner` (an owner name) in
  every version of a line; `parent` in a branch; no `archiveId`, `objectId` or
  `sealed`; documents also `mainSource` and `sourceFormat` (or
  `sourcesMissing`), SHOULD `renditions`, `toolchain`; MAY `changes`, `stage`
  (NISO JAV: `AO`, `SMUR`, `AM`, `P`, `VoR`, ...), `history`, `notices`,
  `licence`, `agreement`, `external`, `withdrawal`, `extensions`.
- Metadata files (`datacite.json`, `object.json`, `members.json`, inventories,
  the discovery document, `genesis.json`, `keys.json`, signature files, the
  `parent.*` files and the index files) are CC0 (16).

## Verification (14)

A verifier validates the JSON files against the schemas (formats as
assertions), the storage root and objects against OCFL, the discovery document
against the storage root, the rules of sections 7 to 11 on every object
version (document version numbering, `history`, notices kept), and resolves
and checks the pins of the head of every collection, reporting each member as
verified, mismatch, unconfirmed, unsigned, unavailable or removed. Over HTTP
it cannot list folders, so completeness is checked only with the files. It
also checks genesis records and names, key logs and every signature (the
signed message, `threshold` signatures that count naming one key-log version,
revoked keys (unless a later signed version confirms them), unresolved forks
and missing key logs making signatures unconfirmed, made-up key-log versions
making them unverifiable, fork evidence, stray files reported), owners and
lines, that no pin names a draft, the evidence, chain and verdict of every
branch point, agreement among copies of a line, and the indexes the archive
declares.

## Schemas

`schemas/opensheaf-archive-0.1.schema.json` (`opensheaf.json`),
`opensheaf-object-0.1.schema.json` (`object.json`),
`opensheaf-collection-0.1.schema.json` (`members.json`),
`opensheaf-genesis-0.1.schema.json` (`genesis.json`),
`opensheaf-keys-0.1.schema.json` (`keys.json`),
`opensheaf-signature-0.1.schema.json` (signature files),
`opensheaf-index-0.1.schema.json` (index files and `indexes.json`) and, for
the timestamps extension, `opensheaf-timestamps-0.1.schema.json` (its
declaration in `keys.json`, under `extensions`); JSON Schema 2020-12, CC0.
They do not forbid additional properties (section 12). A change of a field in
the text needs the same change in its schema, and the other way round.

## Changing the specification

- 0.1 is a draft: changes go into 0.1 itself, with a dated changelog entry
  (17) and the date in the heading updated; no compatibility rules for draft
  names. The timestamps extension (`opensheaf-timestamps-0.1.md`) and the git
  companion (`opensheaf-git-0.1.md`) have their own changelogs and dates,
  updated when they change.
- A new field: in the text (where its file is defined), in the schema, in the
  verification rules (14) if it can be checked, in an example (appendix E) if
  it is common, and in the rationale (appendix F) if the choice is not
  obvious.
- A renamed concept: every file of the repository (specification, timestamps
  extension, git companion, schemas, FAQ, use cases, README, AGENTS.md, this
  skill), including words split across wrapped lines; then the tools and
  templates in other repositories follow.
- After a change, check the use cases and the FAQ against it: they are
  non-normative but must agree, and the "What happens when ..." table of the
  use cases summarises behaviour.
- Open questions go to issues on `opensheaf/opensheaf.github.io`. Ongoing
  designs (as of November 2026): #13 decentralised holding and keys (split
  into #39 custodians' copies, #40 statements by collections about their
  members, #41 owner proofs), #14 global names (closed: `sheaf:` URIs), #19
  scale, #20 self-certifying names, #21 references and applications, #22
  external copies and pins, #28 companion documents (an extension), #29
  private archives, draft/private/public states, review processes and
  anonymous referees, #33 takedowns and copies, #34 mirrors and licences, #37
  and #38 resolution and pins through mirrors, #35 a gateway for `sheaf:`
  URIs, #36 registering `sheaf` with IANA, #42 an inconsistency in the
  appendix E examples (fixed on this branch), #53 several owners of a line
  (closed: thresholds in key logs), #44 name collisions and aliases, #52
  archives as hosts, #54 custody policies, #55 owners as keyed identities. PR
  #30 holds the identity proposal (with #56 merged into it). Read the relevant
  issue before touching its topic.

## Design principles to keep

- Standards first: use OCFL and DataCite as they are; invent only what they
  leave open.
- Fixed versions: nothing deposited ever changes; corrections, notices,
  descriptions and withdrawals are new object versions.
- Integrity comes from pins, not places: any matching copy is valid.
- Statements are made by their authors in their own objects: a document never
  states the collections or reviews about it.
- Keeping and vetting are different acts (catalogues and selections; mirrors
  and accepted copies).
- Owners sign, places host: a version is its owner's when its signatures hold,
  wherever it is found, and no archive can add to another owner's line;
  locations are hints.
- A minimal core: richer relations (summaries and detailed proofs, reviews,
  data and analyses) are built on top, by links, DataCite relations or
  extensions, never by growing the core.
