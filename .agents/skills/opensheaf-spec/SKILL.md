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
  proposal, the writer of a line is its owner, and the archive keeps it).
- **Discovery document** `opensheaf.json` (6.1): a mutable map, never a
  witness: format, archive identifier, name, storage root, layout
  (`0002-flat-direct-storage-layout`), `objects` (each with `id`, `kind`,
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
  never a mirror. In the proposal, a shallow branch kept by the selection
  (below); still never a mirror.
- **Withdrawal** (11.1): a description-only version with `status`
  `withdrawn`; the content stays. **Takedown** (11.2): the object is deleted
  and a **tombstone** stays in the discovery document (11.3).
- **Witnesses** (13.2): signatures and OpenTimestamps proofs of inventory
  checksum files, in `extensions/opensheaf-witnesses/` of the object; not
  part of any version. (Proposal) `<v>.inventory.json.sha512.sig` is the
  line owner's signature (required for keyed owners); third parties sign
  as `.<label>.sig` with a `.<label>.json` sidecar naming the signer; a
  branch keeps its parent's witnesses in `parent/<w>/`.
- **Profiles** (4, appendices A-C): `zenodo` (DOIs from Zenodo), `texmacs`,
  `website`; declared in `profiles`.
- **Extensions** (4): specifications published separately, named by a URI,
  whose data goes under `extensions` in `object.json`; they never change the
  core, and readers ignore those they do not know.

## The identity proposal (branch `proposal/identity`, PR #30)

- **Genesis record and name** (6.5): `genesis.json` (`format`, `kind`,
  `created`, `originator`, `nonce`), written when the object is sealed and
  kept byte for byte in every later version and branch, never
  re-serialised. The **name** is the SHA-256 of the seed
  `opensheaf-name-<k>` and a line feed, then the record, in lowercase
  base32: 52 characters, `^[a-z2-7]{52}$`; the last character's 4 spare
  bits hold k, from 0 to 15 (0, the default, gives `a` or `q`).
- **Clashes** (6.5): an archive keeps at most one object per line (owner,
  name), and a line stays taken after a takedown (tombstones keep the name,
  owner identifier and `sealed`; the owner's URI may be erased). Sealing
  draws a new nonce if the line is taken, so an originator's line is named
  by algorithm 0; the originator never branches its own work (open). A
  branch takes `parent.name`, unless that line is taken in its archive or
  among its owner's confirmed lines elsewhere (unconfirmed ones never cause
  a rename); if the taken line is the owner's own branch (signed, or
  accepted by its keeping archive under that line's authority) of the same
  parent line and the new branch point is later, the branch point is moved
  there, in the archive that keeps it; otherwise the branch takes the
  smallest free algorithm number above the parent's (a number not above it
  fails verification; other unjustified renames are warnings), and is
  refused if none up to 15 is free. A mirror whose line is taken cannot be
  kept. Every line records `sealed` (the originator's sealing version:
  `archiveId`, `objectId`, `objectVersion`), copied by branches; an archive
  refuses a genesis record reused for another work (a different `sealed`)
  and an owner identifier equal to another owner's at its heads; reuse is
  also refused against tombstones (one of the 16 names equals a
  tombstone's). A work is searched for under all 16 names of its genesis
  record, keeping entries whose record is byte-identical (`names/` entries
  carry `genesis` and `sealed`) and grouping them by `sealed`. Aliases are
  open (#44). A deep branch's first own version that adds files of the
  document's own takes the number after the highest in the object and goes
  last in `history`. A move on a deep branch also takes the number after the
  highest. `mirrorOf` is never the archive itself, and an archive's lines
  name its own `archiveId`, except mirrors and copied versions.
- **Draft and sealing** (6.5): a draft is an object without a genesis
  record; no pin may name its versions. Sealing adds the genesis record,
  at the owner's request, before a version first leaves the owner's hands.
  Every sealed object has a genesis record (archives made earlier are
  rebuilt).
- **Owner** (6.5): a URI in `object.json`; **named** (archive identifier,
  ORCID iD, web address: asserted only) or **keyed** (`did:key:` Ed25519,
  `openpgp4fpr:`: every version signed). Compared as exact strings in
  canonical forms. The **originator** (in the genesis record) owns the first
  line, the only one with no parent.
- **Line** (6.5): (owner, name), one writer, one archive identifier and one
  object identifier in all its copies. An archive with several depositors
  binds each named owner URI of its lines to depositors it has checked
  (not keyed lines, not mirrors). Copies agree when their version
  inventories are byte-identical; otherwise it is a **fork**.
- **Branches** (10.5): lines of other owners with the same genesis record,
  declaring `parent`. **Deep**: copies the earlier versions and continues
  them (a co-author). **Shallow**: holds only the branch point plus
  `parent.inventory.json` and `parent.object.json` as evidence (a journal).
  The branch point moves only forward, to a version later in the parent
  line's history, taking the branch's next document version; how a move
  keeps the branch's own files is open (probably a merge). Accepted copies
  are shallow branches, one owner per selection; the version of record is a
  later version of the branch; derived works are new objects. Numbering on
  branches: option (a), provisional.
- **Verdicts** (14): for each branch point, inconsistent, confirmed,
  attested or unconfirmed; the branch takes the weakest. Confirmed: the
  parent resolved through its archive at a base URL known independently of
  the branch, or a keyed parent's signature. Attested: a timestamp, a
  signature of a signer the user trusts, an external record from a trusted
  depositor or reached independently. Confirmation confirms the archive,
  not the person (owner proofs are discussed in #41).
- **`sheaf:` URIs** (6.6): `sheaf:<name>` (the originator's line),
  `sheaf:<name>:<owner id>` (another owner's line), `sheaf:<name>:*` (all
  lines; no version, no `sha512`), `/v<n>` (a document version),
  `sha512=<digest>` (a pin), `at=<archive URL>` (a hint, not identity), the
  parameters in a query after `?`, `sha512` first. The **owner identifier**
  is made like a name (k = 0) over the owner's URI. The canonical form
  omits the originator's owner part and `at`.
- **Resolution** (6.6): without a digest, copies are confirmed only when
  reached through the archive named by their `archiveId`, known
  independently, or signed by a keyed owner; heads, forks and short-form
  order are decided among confirmed copies, and unconfirmed ones are
  warnings. With no confirmed copy, the latest head among agreeing
  unconfirmed copies is used, marked unconfirmed. Confirmed copies of one
  line in different archives are a conflict, not a choice. **Short
  forms**: prefixes of at least 8 characters (16 when printed); a single
  unconfirmed candidate is resolved, marked unconfirmed; confirmed
  candidates are ordered within one owner (for a named owner, within one
  archive), otherwise ambiguous.
- **Indexes** (6.6): `names/<p>.json`, `owners/<p>.json`,
  `sha512/<p>.json`, with prefixes of 2 to 4 characters declared in
  `indexes` (or `indexes.json` for an index of many archives); maps, never
  witnesses. **Gateways**: `https://<base>/sheaf:...`, real HTTP statuses,
  never serving archives' files; the project's gateway and its domain are
  open (#35), and registering `sheaf` with IANA is #36.
- **Open questions**: listed at the end of section 6.5; do not settle them
  in the text without agreement.

## The files of an object version

- **Document**: sources (the main source and what it needs), renditions (a
  PDF, recommended), files of notes, `datacite.json`, `object.json`. No HTML
  or other presentation files.
- **Collection**: `datacite.json`, `object.json`, `members.json`.
- (Proposal) identity files: `genesis.json` in every sealed version, and
  `parent.inventory.json` and `parent.object.json` in every version of a
  shallow branch, and of a deep branch from a version that moves its
  branch point; these names are reserved.
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
  `extensions`; (proposal) `name`, `owner` and `sealed` from the first
  version of its line, and `parent` in a branch.
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
proposal, `opensheaf-genesis-0.1.schema.json` (`genesis.json`) and
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
  global names, #19 scale, #20 self-certifying names, #21 references and
  applications, #22 external copies and pins, #28 companion documents (an
  extension), #29 private archives, draft/private/public states, review
  processes and anonymous referees, #33 takedowns and copies, #34 mirrors
  and licences, #37 and #38 resolution and pins through mirrors, #35 a
  gateway for `sheaf:` URIs, #36 registering `sheaf` with IANA, #42 an
  inconsistency in the appendix E examples, #44 name collisions and
  aliases. PR #30 holds the identity
  proposal. Read the relevant issue before touching its topic.

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
- (Proposal) Copies prove their consistency, not their author: a copy is
  confirmed only through the archive that keeps its line or the owner's
  key, and an unconfirmed copy never overrides a confirmed one.
- A minimal core: richer relations (summaries and detailed proofs, reviews,
  data and analyses) are built on top, by links, DataCite relations or
  extensions, never by growing the core.
