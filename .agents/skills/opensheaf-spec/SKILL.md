---
name: opensheaf-spec
description: The concepts of the OpenSheaf specification (archives, objects, document and object versions, catalogues and selections, pins, mirrors, accepted copies, withdrawal, extensions; on the branch proposal/identity also names, owners, lines, drafts and sealing, branches and sheaf: URIs) and how to change the specification, its schemas, the FAQ and the use cases. Use before editing any of them, or answering questions about the format.
---

# The OpenSheaf specification

The source is `opensheaf-specification-0.1.md` (one line per paragraph).
This is a map of it; the text is authoritative. Section numbers below are
those of the text.

On the branch `proposal/identity` (PR #30, not yet agreed) the text also
holds the identity proposal (sections 6.5 and 6.6, a rewritten 10.5, and
changes throughout). The section "The identity proposal" below maps it;
marked "(proposal)" elsewhere. On `main` those parts do not exist yet.

## What it is

A format for archives of scholarly documents, as plain files served as a
static website, and for collections of them across archives. It defines
only what its two standards leave open:

- **OCFL 1.1** for storage: objects, versions, inventories, SHA-512 digests;
- **DataCite 4.7** for description (`datacite.json`, in the form of the
  DataCite REST API attributes);
- OpenSheaf itself: discovery, collections, provenance (`object.json`),
  withdrawal, profiles and extensions.

## Concepts

- **Archive** (sections 5, 6): one owner's objects, with one storage root
  and one discovery document `opensheaf.json` at its base URL. Named by an
  **archive identifier** (a `tag:` URI, section 6.2) that does not change
  when the archive moves. An archive is not an object and has no versions;
  it is custody and naming, and the single writer of its objects (in the
  proposal, an archive is a host with no identity, and the writer of a line
  is its owner, who signs it).
- **Discovery document** `opensheaf.json` (6.1): a mutable map, never a
  witness: format, archive identifier, name, storage root, layout
  (`0002-flat-direct-storage-layout`, or
  `0003-hash-and-id-n-tuple-storage-layout` for large archives, section 5,
  also in `ocfl_layout.json`), `objects` (each with `id`, `kind`,
  `head`, `inventorySha512`, `status`, and `mirrorOf` for mirrors),
  `profiles`; SHOULD `mainCollection`, `contact`, `extensions`; MAY
  `mirrors`, `tombstones`, `keys`, `feed`; (proposal) `name` and `owner`
  of each object with a genesis record, and `indexes`. Everything it says
  is checked against the storage root.
- **Object** (3, 7): an OCFL object, of kind `document` or `collection`.
  Its identifier is a short chosen name (6.3: `^[a-z0-9]+(-[a-z0-9]+)*$`,
  at most 64 characters), never reused. Globally, an object is the pair
  (archive identifier, object identifier); (proposal) its line is also
  the pair (owner, name), independent of any archive, written as a
  `sheaf:` URI.
- **Object version** (`v1`, `v2`, ...): an OCFL version; changes at every
  change of the object. Every version folder holds its inventory and
  checksum (7.1). The inventory records who deposited a version and when.
- **Document version** (7.3): the version of the work, numbered by the
  archive (proposal: by the owner of the line) from 1 without gaps;
  changes exactly when the document's own files change. External labels
  (arXiv `v3`) go in `external`.
- **Description-only version** (7.3): an object version that keeps the files
  of an existing document version and changes only the description, the
  state or the notices (a DOI, a stage, a notice, a withdrawal).
- **History** (7.3): the order of the document versions in the work; by
  number, unless `history` in `object.json` lists object versions (needed
  when a version is deposited out of order). **Current version**: the last
  entry of the history of the head; dates never order versions.
- **Notices** (7.3, 9): statements about a version (an erratum), added by
  description-only versions, never removed.
- **Note** (9): a short `text`, or a file (`path`, `mediaType`), or both;
  used for change notes, notices, withdrawals, `sourcesMissing`.
- **Collection** (7.4, 10): an object whose versions hold `members.json`.
  Two kinds (`type` in `members.json`):
  - **catalogue**: keeps objects whole and is impartial about their
    versions; each member pins an object up to a version (`version`,
    `inventorySha512`) and MAY `follow: "latest"`. An archive's main
    collection is a catalogue of its own documents.
  - **selection**: vets particular revisions; each member pins a
    **revision set** (`revisions`: `documentVersion`, `version`,
    `inventorySha512`); it changes only by an act of its curator, a new
    version of the selection.
  Collections are objects, so they nest and cross archives.
- **Pin** (3, 10.2): (object version, SHA-512 of that version's inventory).
  It fixes every byte of the version and of the versions before it, so
  collections are hash trees across archives; any copy whose bytes match a
  pin is as good as the original (6.4).
- **Mirror** (10.4): a byte-for-byte copy of a whole object of another
  archive, the same object (`mirrorOf`), updated only by copying the
  original's versions; allowed only if the licences of all versions allow
  redistribution.
- **Accepted copy** (10.5): on `main`, a selection's own document holding
  exactly the files of one vetted revision (not `datacite.json` and
  `object.json`), with the source and its pin in `external`; a new object,
  never a mirror. In the proposal, a branch kept by the selection
  (below); still never a mirror.
- **Withdrawal** (11.1): a description-only version with `status`
  `withdrawn`; the content stays. **Takedown** (11.2): the object is deleted
  and a **tombstone** stays in the discovery document (11.3).
- **Witnesses** (13.2): signatures and OpenTimestamps proofs of inventory
  checksum files, in `extensions/opensheaf-witnesses/` of the object; not
  part of any version. (Proposal) signature files of the line's owner,
  required for every sealed version (below); a branch keeps its parent's
  in `parent/<w>/`.
- **Profiles** (4, appendices A-C): `zenodo` (DOIs from Zenodo), `texmacs`,
  `website`; declared in `profiles`.
- **Extensions** (4): specifications published separately, named by a URI,
  whose data goes under `extensions` in `object.json`; they never change the
  core, and readers ignore those they do not know.

## The identity proposal (branches `proposal/identity`, PR #30, and `proposal/owners`)

`proposal/owners` revises PR #30 after #55 and #52: owners are keyed
identities with key logs, archives only host lines. Read #55 and #52 (and
their revision comments) before touching any of this.

- **Genesis record and name** (6.5): `genesis.json` (`format`, `kind`,
  `created`, `originator`, `nonce`; an owner's has `kind` `owner` and no
  `originator`), written when a work is sealed or an owner created, kept
  byte for byte in every later version and branch, never re-serialised. The
  **name** is the SHA-256 of the seed `opensheaf-name-<k>` and a line feed,
  then the record, in lowercase base32: 52 characters, `^[a-z2-7]{52}$`;
  the last character's 4 spare bits hold k, from 0 to 15 (0, the default,
  gives `a` or `q`).
- **Owner** (6.5, 7.5): a keyed identity (person, group, institution); an
  object of kind `owner`, named by its genesis record (the **owner name**,
  recorded in `originator`, `owner`, `parent.owner`, `sheaf:` URIs). Its
  versions are its **key log**: `keys.json` (`keys`, Ed25519 `did:key`;
  `threshold`; optional `revoked` and `keeper`); each version signed by
  `threshold` keys of the one before. No named owners, no owner
  identifiers. The optional **keeper** link (ORCID iD, domain) is confirmed
  by the keeper (ORCID record, `/.well-known/opensheaf`), never required.
- **Signing** (6.5, 13.2): every sealed version of a line is signed by its
  owner, `threshold` keys of the key-log version named, each in
  `extensions/opensheaf-witnesses/<v>/signature-<k>.json` (`signed`,
  `owner`, `key`, `keyLog` as a pin `sheaf:<owner>/v<n>?sha512=...`,
  `signature`), with OpenTimestamps proofs; a revoked key counts only with a
  timestamp before the revocation. Third parties: `witness-<label>.json`.
- **Key logs travel with the objects they sign** (6.5): a copy keeps the
  signers' owner objects in its storage root, up to the versions named. A
  line is its signed versions, wherever stored; an archive MUST NOT add to
  a line a version its owner did not sign. No signed list of an owner's
  lines exists (lines are linear).
- **Archives** (6.1 to 6.4): hosts with no identity, found at their base
  URL; every location (`archiveUrl`, `mirrors`, `at`) is a hint. They choose
  which owners they host (`owners` in the discovery document). An owner
  moving to another archive copies its key log and continues its lines (not
  a branch); a branch happens only when the owner changes.
- **Identifiers and labels** (6.3, 5): an object's OCFL `id` is its first
  line, `sheaf:<name>:<owner>`, for branches too (a draft has a chosen
  short id); default layout
  `opensheaf-owner-name-storage-layout` (`<owner>/<name>/`, drafts in
  `drafts/<id>/`; the key log at `<owner>/<owner>/`), or `0003` for large
  archives. Readable `label`s in the discovery document, not permanent.
- **Clashes** (6.5): one object per line in a storage root; sealing draws a
  new nonce if the owner's line is taken; a branch takes `parent.name`,
  moves its branch point onto the owner's own earlier branch of the same
  parent line, or takes the smallest free algorithm number above the
  parent's (refused if none up to 15); lines stay taken after a takedown.
  `sealed` is a pin (`objectVersion`, `inventorySha512`) of the
  originator's sealing version; an archive refuses a genesis record reused
  for another work. A work is searched for under all 16 names, keeping
  byte-identical records, grouped by `sealed`. Aliases open (#44).
- **Draft and sealing** (6.5): a draft has no genesis record and no owner,
  is not signed, and cannot be pinned. Sealing is at the owner's request,
  before a version first leaves the owner's hands.
- **Branches** (10.5): lines of other owners with the same genesis record,
  declaring `parent` (`owner`, `name`, `objectVersion`, `documentVersion`,
  `inventorySha512`, `url`). No deep branches: a branch is a new object
  holding the branch point plus, as content, `parent.inventory.json`,
  `parent.object.json`, `parent.signatures/` and `parent.keylog/`
  (required), so its evidence is complete; the parent's history, if
  wanted, is a copy of the parent's line beside it (OCFL inventories fix
  their object's id). Branch points move only forward; accepted copies are
  branches of the selection's owner. Verdicts: inconsistent, unconfirmed, confirmed.
- **`sheaf:` URIs** (6.6): `sheaf:<name>`, `sheaf:<name>:<owner>`,
  `sheaf:<name>:*`, `/v<n>`, `?sha512=` (a pin), `at=` (a hint),
  `sheaf:<owner>` (a key log). Copies count only if signatures hold; a
  resolver uses the latest head among valid copies; short forms of at least
  8 characters (16 printed), ambiguous across owners.
- **Indexes** (6.6): `names/`, `owners/`, `sha512/` with prefixes of 2 to 4
  characters (entries name `owner`, `id`, `label`, no `ownerId`,
  `archiveId`); maps, never witnesses. **Gateways**: domain open (#35);
  registering `sheaf` is #36; the format's name, and so the gateway and
  the `opensheaf-` strings, may change.
- **Open questions**: listed at the end of section 6.5; do not settle them
  in the text without agreement.

## The files of an object version

- **Document**: sources (the main source and what it needs), renditions (a
  PDF, recommended), files of notes, `datacite.json`, `object.json`. No HTML
  or other presentation files.
- **Collection**: `datacite.json`, `object.json`, `members.json`.
- (Proposal) owner objects: `genesis.json`, `keys.json`, `object.json`
  (no `datacite.json`).
- (Proposal) identity files: `genesis.json` in every sealed version, and
  `parent.inventory.json`, `parent.object.json`, `parent.signatures/` and
  `parent.keylog/` in every version of a branch; these names are
  reserved.
- `datacite.json` (8): MUST `titles`, `creators`, `publicationYear`,
  `types`, `version` (the document version as a string), `publisher`;
  SHOULD abstract, subjects, dates, `rightsList`, `relatedIdentifiers`.
  Dates: `Issued` (first public appearance, anywhere), `Available` (this
  version first public), `Updated`, `Created`, `Submitted`, `Accepted`,
  `Withdrawn`. Mathematics in titles and abstracts as `$...$` LaTeX.
  Relations (8.1): `IsVersionOf` the concept DOI, `IsNewVersionOf`,
  `IsIdenticalTo` / `IsVariantFormOf` for the same work elsewhere,
  `HasPart` for collection members with DOIs; a document never states the
  collections that include it.
- `object.json` (9): MUST `format`, `specification`, `kind`, `archiveId`,
  `objectId`, `documentVersion`, `status`; documents also `mainSource` and
  `sourceFormat` (or `sourcesMissing`), SHOULD `renditions`, `toolchain`;
  MAY `changes`, `stage` (NISO JAV: `AO`, `SMUR`, `AM`, `P`, `VoR`, ...),
  `history`, `notices`, `licence`, `agreement`, `external`, `withdrawal`,
  `extensions`; (proposal) no `archiveId` or `objectId`, but `name`,
  `owner` (an owner name) and `sealed` (a pin) from the first version of
  its line, and `parent` in a branch.
- Metadata files (`datacite.json`, `object.json`, `members.json`,
  inventories, the discovery document; in the proposal also
  `genesis.json`, the `parent.*` files and the index files) are CC0 (16).

## Verification (14)

A verifier validates the JSON files against the schemas (formats as
assertions), the storage root and objects against OCFL, the discovery
document against the storage root, the rules of sections 7 to 11 on every
object version (document version numbering, `history`, notices kept), and
resolves and checks the pins of the head of every collection, reporting
each member as verified, mismatch, unavailable or removed. Over HTTP it
cannot list folders, so completeness is checked only with the files.
(Proposal) It also checks genesis records and names, owners and lines,
that no pin names a draft, the evidence and verdict of every branch point,
agreement among copies of a line, and the indexes the archive declares.

## Schemas

`schemas/opensheaf-archive-0.1.schema.json` (`opensheaf.json`),
`opensheaf-object-0.1.schema.json` (`object.json`),
`opensheaf-collection-0.1.schema.json` (`members.json`), and, in the
proposal, `opensheaf-genesis-0.1.schema.json` (`genesis.json`),
`opensheaf-keys-0.1.schema.json` (`keys.json`),
`opensheaf-signature-0.1.schema.json` (signature files) and
`opensheaf-index-0.1.schema.json` (index files and `indexes.json`); JSON
Schema 2020-12, CC0. They do not forbid additional properties (section 12). A
change of a field in the text needs the same change in its schema, and the
other way round.

## Changing the specification

- 0.1 is a draft: changes go into 0.1 itself, with a dated changelog entry
  (17) and the date in the heading updated; no compatibility rules for
  draft names.
- A new field: in the text (where its file is defined), in the schema, in
  the verification rules (14) if it can be checked, in an example
  (appendix E) if it is common, and in the rationale (appendix F) if the
  choice is not obvious.
- A renamed concept: every file of the repository (specification,
  schemas, FAQ, use cases, README), including words split across wrapped
  lines; then the tools and templates in other repositories follow.
- After a change, check the use cases and the FAQ against it: they are
  non-normative but must agree, and the "What happens when ..." table of
  the use cases summarises behaviour.
- Open questions go to issues on `opensheaf/opensheaf.github.io`. Ongoing
  designs (as of November 2026): #13 decentralised holding and keys (split
  into #39 custodians' copies, #40 statements by collections about their
  members, #41 owner proofs), #14
  global names (closed: `sheaf:` URIs), #19 scale, #20 self-certifying names, #21 references and
  applications, #22 external copies and pins, #28 companion documents (an
  extension), #29 private archives, draft/private/public states, review
  processes and anonymous referees, #33 takedowns and copies, #34 mirrors
  and licences, #37 and #38 resolution and pins through mirrors, #35 a
  gateway for `sheaf:` URIs, #36 registering `sheaf` with IANA, #42 an
  inconsistency in the appendix E examples, #44 name collisions and
  aliases, #52 archives as hosts, #54 custody policies, #55 owners as
  keyed identities. PR #30 holds the identity proposal, revised on
  `proposal/owners`. Read the relevant issue before touching its topic.

## Design principles to keep

- Standards first: use OCFL and DataCite as they are; invent only what they
  leave open.
- Fixed versions: nothing deposited ever changes; corrections, notices,
  descriptions and withdrawals are new object versions.
- Integrity comes from pins, not places: any matching copy is valid.
- Statements are made by their authors in their own objects: a document
  never states the collections or reviews about it.
- Keeping and vetting are different acts (catalogues and selections; mirrors
  and accepted copies).
- (Proposal) Owners sign, places host: a version is its owner's when its
  signatures hold, wherever it is found, and no archive can add to another
  owner's line; locations are hints.
- A minimal core: richer relations (summaries and detailed proofs, reviews,
  data and analyses) are built on top, by links, DataCite relations or
  extensions, never by growing the core.
