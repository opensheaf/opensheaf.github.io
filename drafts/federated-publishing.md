# Federated publishing: proposals and systems compared with OpenSheaf

*Working paper, draft of 22 November 2026. Non-normative: ideas and
positions, not decisions. For twenty years, scholars and engineers have
proposed to publish research without a central publisher: on peer-to-peer
networks, on blockchains, as linked data on personal servers, as signed
records replicated between servers, or as overlays on a federation of
repositories. This paper reports a search for such proposals and systems,
describes some thirty of them from their own sources, with their status as
of today, and sets each against OpenSheaf: how it fixes content, names it,
decides who may write, makes and checks copies, establishes identity, and
treats versions, withdrawal, rights and preservation. It goes beyond the
comparisons of [positioning.md](positioning.md), which it does not repeat.
Its main findings: content addressing, signed versions and overlays that
cite versions are not new, and three recent designs (Document Succession
Identifiers, the nanopublication network and the Underlay protocol) are
close to OpenSheaf in parts; the projects that failed did so for lack of
funding or of a steward, of adoption, or by depending on a token, a chain
or a service run by someone else, while others were overtaken by other
services; OpenSheaf shares the first two risks and avoids the third; and
what is new in it is the combination of a name of the work shared by
the lines of several owners, apart from hosts and keys, owners with key
logs, and collections that pin versions of other parties' documents. It
ends with proposals, experiments and open questions.*

> [!NOTE]
> The facts in this paper were read on 22 November 2026 from the
> sources listed with each system and in the references. Statuses are
> as of 22 November 2026, with the evidence and its date. Claims that could
> not be checked in a primary source are marked **unverified**. Section
> numbers of the specification are those of
> [version 0.2](../opensheaf-specification-0.2.md); where this paper and the
> specification differ, the specification holds. A section number with a
> decimal point (6.6), or marked as the specification's, is a section of the
> specification; a whole number alone is a section of this paper, and so is
> a section with a decimal point marked "above" or "below".

## 1. The question

The [positioning paper](positioning.md) separates the functions of
scholarly communication (record, preserve, announce, filter, distribute,
assign merit), recalls the case for separating them (Smith 1999, Van de
Sompel and others 2004, Priem and Hemminger 2012), and compares OpenSheaf
with the infrastructure of repositories and harvesting (COAR Next
Generation Repositories, Pubfair, COAR Notify, LOCKSS and CLOCKSS,
OAI-PMH, institutional repositories, SciPost and overlay journals) and with
general federated systems (ActivityPub, the AT Protocol, Nostr, IPFS,
distributed hash tables, git and Software Heritage). That ground is not
covered again here.

This paper asks a narrower question. Many have proposed to publish
scholarly work in a federated, decentralised or distributed way, and some
built it. What did they propose, what became of it, and how does OpenSheaf
differ? Two practical questions follow: what can OpenSheaf take from them,
and which of the risks that ended them does it share?

## 2. Method

**What was searched.** Web searches, in November 2026, for academic papers
and for projects, on: decentralised, federated, distributed and
peer-to-peer scholarly publishing; decentralised science (DeSci); IPFS,
Dat and Hypercore for research; blockchains for publication, peer review
and timestamping; nanopublications and Trusty URIs; linked research,
dokieli and Solid for researchers; Research Objects and RO-Crate; intrinsic
identifiers; signing of papers, datasets and software; publish, review,
curate and overlay models; aggregation and federation of preprints. Each
lead was followed to its primary sources: papers by DOI (through Crossref
metadata when the publisher's page refused access), the projects' own
pages and documentation, their repositories (through the GitHub API, for
dates of commits and releases), and their announcements.

**Criteria for inclusion.** A system or proposal is included if it does at
least one of: publish or hold scholarly documents or statements without a
single publisher that must be trusted; fix versions by digests; sign
versions with keys held by authors; replicate a record between independent
servers; or refer, as an overlay, to versions held elsewhere. Systems that
are only named in the debate but are centralised (Octopus, ResearchHub) are
included briefly, because they are often cited as alternatives. General
networks without a scholarly purpose, and the systems already compared in
[positioning.md](positioning.md), are excluded, except where a new fact
bears on them.

**Status.** A project is **active** when its code, specification or
service changed in 2026, **dormant** when nothing has changed for more than
a year but the service or text remains, and **dead** when it is announced
closed or no longer reachable. The evidence and its date are given with
each.

**Limits.** The search was made in English, and through search engines and
the GitHub API; work published only in other languages, or behind
paywalls, is under-represented. Several sites refused automated access
(`peerj.com`, `ijdc.net`, `mdpi.com`, `biorxiv.org`, `blog.f1000.com`,
`docmaps.knowledgefutures.org`, article pages of `peercommunityin.org`, the
Wayback Machine, `rogue-scholar.org`, `libscie.org`, `ar.io`); they were not
retried, and other sources were used. Some facts on shadow libraries come
only from secondary sources (news and encyclopaedia articles), and are
said to.

**The questions asked of each.** For each system: what it is; its status;
how it **fixes** content; how it **names** it; **who can write**; how
**copies** are made and checked; how **identity** works; what it says
about **versions**, **withdrawal**, **rights** and **preservation**; what
OpenSheaf does differently; and what OpenSheaf could take from it.

**OpenSheaf in brief**, for the comparisons below. An archive is static
files: a discovery document and an OCFL storage root (specification,
section 3). Each object version is fixed by an inventory listing the
SHA-512 digest of every file, and a pin, the digest of that inventory,
fixes the version and all before it (specification, sections 4 and 4.3). A
work is named by the digest of its genesis record (specification, section
5), an owner by the digest of its own, and a line, the history of a work as
one owner decides it, by the pair (specification, section 7). Owners sign
each version with Ed25519 keys listed in a key log, whose versions are
signed by rotation keys committed in advance (specification, sections 6
and 7). Copies are checked by pins and signatures wherever they come from
(specification, sections 11 and 12.3). Collections are signed, versioned
objects that pin the versions of their members, in any archive: catalogues
keep whole objects, selections vet particular versions (specification,
section 8). Withdrawal is a signed version; takedown removes an object from
one archive and leaves a tombstone there (specification, section 13).

## 3. Content-addressed and signed records

### 3.1 Nanopublications and Trusty URIs

**What it is.** A nanopublication is a small unit of scholarly
publication: four RDF named graphs, a head, an assertion, its provenance and
information about the publication (Groth, Gibson and Velterop 2010; the
guidelines at <https://nanopub.net/guidelines/working_draft/>). Since 2014
each is named by a Trusty URI (Kuhn and Dumontier 2014), and since 2015
they have been replicated by a network of servers (Kuhn and others 2015,
2016). A second generation, the Nanopub Registry and Nanopub Query, built
by Knowledge Pixels, replaces the first (Kuhn and others 2026). Nanodash
is the tool for writing them.

**Status: active.** `knowledgepixels/nanopub-registry` released 1.14.2 on
6 November 2026 and was pushed on 22 November 2026; `nanopub-java` 1.97.1
was released on 20 November 2026 (GitHub). The first-generation server,
`tkuhn/nanopub-server`, was last pushed on 15 May 2024, and its author
wrote on 6 January 2025 that "the current nanopub servers will be replaced
soon by the Nanopub Registry"
(<https://groups.google.com/g/nanopub-users/c/InV-jFXvJhk>). A snapshot of
4 May 2026 counts 79,672 nanopublications by 616 signing agents (Kuhn and
others 2026).

**How it works.**

- **Fixity and names.** A Trusty URI ends with an artifact code: a module
  identifier of two characters and a SHA-256 digest in URL-safe base64.
  Module `FA` hashes the bytes of a file; modules `RA` and `RB` hash RDF
  graphs after normalisation (statements sorted, the URI's own code
  replaced by a blank, so that a nanopublication can name itself); blank
  nodes are not supported and must be skolemised beforehand
  (<https://github.com/trustyuri/trustyuri-spec>, version 1, 23 February
  2015). The name is the content: any change is a new name.
- **Who can write.** Anyone with a key. The Registry accepts only signed
  nanopublications, and gives each key a quota of publications derived from
  trust (below).
- **Signatures and identity.** The signature is in the publication-info
  graph: the algorithm (RSA in practice; `nanopub-java` supports RSA and
  DSA, not Ed25519), the public key itself, the signature, and the ORCID iD
  of the signer
  (<https://github.com/Nanopublication/nanopub-java>). The documentation
  says plainly that "a signature proves which key signed, not who owns the
  key" (<https://nanopub.net/docs/>). A declaration nanopublication binds an
  ORCID iD to a key, and endorsements by already trusted agents approve it;
  trust spreads from seed agents named in a setting nanopublication, a key
  claimed by one agent is approved and one claimed by several is contested,
  and quotas follow from trust (Kuhn and others 2026).
- **Copies.** Registries replicate along coverage axes (public key, type),
  comparing paged lists with checksums; each checks the Trusty URI and the
  signature of what it takes. Three public registries are listed
  (`registry.knowledgepixels.com`, `registry.nanodash.net`,
  `registry.petapico.org`) in the README of
  <https://github.com/knowledgepixels/nanopub-registry>.
- **Versions and withdrawal.** Nothing is deleted. A new version is a new
  nanopublication that `npx:supersedes` the old; a retraction is one that
  `npx:retracts` it (terms defined in `nanopub-java`). The documented query
  for invalidations (`npx:invalidates`, which covers both) matches only
  nanopublications signed with the same public key, so in practice a
  supersession counts only with the same key, though no rule says so
  (<https://nanopub.net/docs/>); a query for the latest version returns the
  same URI if it is the latest, nothing if it was retracted, and several
  URIs if the versions branched
  (<https://groups.google.com/g/nanopub-users/c/timA_pmETz0>).
- **Rights and preservation.** Not addressed in the sources read.

**What OpenSheaf does differently.** A nanopublication is a statement;
an OpenSheaf object version is a document with its sources and renditions.
A Trusty URI names one content, so a work has no name across its versions;
in OpenSheaf the genesis record names the work, the line names one owner's
history, and pins fix versions (specification, sections 5, 7 and 4).
Nanopublications carry their key in each record, and the documented
queries tie supersession to the same key, so a new key breaks the chain of
versions in those queries; an OpenSheaf owner keeps its name across new
keys through its key log, and answers a theft by exposing keys with
rotation keys committed in advance (specification, section 6). The
registries replicate what falls in their coverage, with quotas against
abuse; OpenSheaf archives copy what they choose (specification, section
11), and the format has no defence against volume, which is left to
whoever hosts.

**What OpenSheaf could take.**

- **Statements about versions.** Reviews, claims, endorsements and errata
  about a document version are exactly the small signed statements
  nanopublications are made for, and they can name a version by its
  `sheaf:` URI with its pin (section 12.1). References and applications
  are open ([#21](https://github.com/opensheaf/opensheaf.github.io/issues/21));
  nanopublications are a working form for them, with a network that
  already replicates them.
- **Trust for indexes.** Who keeps indexes of many archives, and how
  resolvers find them, is open
  ([#20](https://github.com/opensheaf/opensheaf.github.io/issues/20)). The
  Registry's approach, quotas derived from endorsements by trusted agents,
  is a tested answer to spam in an open network, and a model for an index
  that admits archives.
- **Owner proofs.** A declaration nanopublication binding an ORCID iD to a
  key is close to what
  [#41](https://github.com/opensheaf/opensheaf.github.io/issues/41)
  considers (attesters, ORCID tokens); an owner could declare its owner
  name in one.

### 3.2 Document Succession Identifiers and Baseprints

**What it is.** A proposal by E. Castedo Ellerman for a persistent
identifier for the series of versions of a document, a Document Succession
Identifier (DSI), stored in the Document Succession Git Layout (DSGL), and
used for Baseprints, documents built from Markdown or LaTeX sources with
GitHub actions and resolved at `perm.pub` (Ellerman 2024a, 2024b). Of all
the systems found, it is the closest to OpenSheaf in its premises.

**Status: active, a working draft.** DSGL is a "Living Technical
Specification", edition 1.1, of 20 February 2024 (Ellerman 2024b); its
working draft has moved on to edition 2.1, which limits edition numbers
and snapshot trees, and that of the DSI specification to edition 3.1
(<https://castedo.github.io/dsgl-spec/>,
<https://castedo.github.io/dsi-spec>). The repositories `castedo/dsi-spec`
and `castedo/dsgl-spec` were last pushed on 19 November 2025,
`castedo/pilot.perm.pub` on 4 November 2026, and the mirror of `epijats`,
its document tool, on 23 October 2026 (GitHub).

**How it works** (from the DSGL specification, edition 1.1, Ellerman
2024b).

- **Fixity and names.** A succession is a git history with a single
  initial commit. The base DSI is the base64url form of the 20-byte git
  hash of that commit. Each edition is a snapshot, a git blob or tree,
  stored at a path made from its edition number (edition 2.1 at
  `2/1/object`); the first snapshot committed at a path is the edition, and
  later ones do not change it. A snapshot can be named by its SWHID and
  archived in Software Heritage.
- **Who can write, and identity.** "[O]nly the authors can extend the
  document succession with new editions." Each commit holds a
  `signed_succession/allowed_signers` file, and every commit after the
  first is signed with an SSH key listed in the `allowed_signers` of all
  its parents; in an ungarbled succession, the history is linear, keys are
  `ssh-ed25519` and the initial commit is signed by a key of its own list.
  Authority rests on the keys, so a succession moves to any git host
  without changing who may extend it.
- **Versions.** Editions are numbered in several levels (`1.4`, `2.1`), as
  software versions are, and each path is written once.
- **Copies.** Any git host or Software Heritage; the resolver reads the
  history and checks it.
- **Withdrawal, rights, preservation.** Not specified, beyond archiving in
  Software Heritage; the specification itself is under CC BY 4.0.

**What OpenSheaf does differently.** The premises are the same: a name
computed from the first state, authority in authors' keys, any host, git
as a possible store. The differences are of structure. A DSI names one
succession, and its signers are listed inside it, so the list of keys is
per document and travels with it; in OpenSheaf keys belong to an owner,
whose key log is a separate object shared by all its lines (specification,
section 6), with rotation keys apart from the keys that sign (section
6.2). As read here, a key in `allowed_signers` can sign a commit that
changes the list, so a thief holding one key can extend the succession and
replace the list, and can contest the succession: the authors can still
extend it from the same parent, which makes it garbled, a contest that the
rules do not settle. OpenSheaf's pre-rotation exists to prevent exactly
that (appendix D.3), at the cost of more keys to keep. A DSI rests on
git's SHA-1 hash; OpenSheaf on SHA-512 inventories and SHA-256 names
(sections 4.1 and 5.2). DSGL has one line per document and no notion of
other owners' branches, collections or withdrawal; OpenSheaf has lines of
several owners for one work, branches and accepted copies (specification,
section 9), and collections (specification, section 8).

**What OpenSheaf could take.** The comparison belongs with
[git-as-implementation.md](git-as-implementation.md): DSGL shows that a
signed, intrinsic history of documents can live in git and be read from
Software Heritage, which is what that paper weighs. Its editions as paths
written once are a simple rule for fixity in git. And its author has
already compared his design with dPIDs (Ellerman 2024a); a conversation
with him would test OpenSheaf's choices against the closest independent
design.

### 3.3 The Underlay

**What it is.** A "versioned registry for knowledge" from Knowledge
Futures, the nonprofit behind PubPub, revived in 2026: collections of
records and files push snapshots, "Versions are immutable and sequential",
files are content-addressed, and "Knowledge Futures hosts the first
canonical instance. Others can self-host." (Knowledge Futures 2026a.)

**Status: active.** Announced on 27 April 2026; content-addressed records
on 8 June 2026; protocol v2 on 6 October 2026 (Knowledge Futures 2026a,
2026b, 2026c). Protocol v3, still a draft marked "Not stable", has been
used by the collections on `underlay.org` since 13 November 2026; its
version identifiers are `ul:ver:` followed by the hex digest (`ulv3:`
before 18 November), and authors may sign their changes and build commits,
which the collection's authority accepts and acknowledges by a receipt
(<https://underlay.org/docs/protocol>; `docs/protocol-v3.md`, sections 4.2,
4.6 and 4.7).

**How it works** (Knowledge Futures 2026b, 2026c, and the protocol
documents, <https://github.com/knowledgefutures/underlay>, `docs/`).

- **Fixity and names.** Every node is stored "under the SHA-256 hash of its
  contents", records being hashed over canonical JSON (RFC 8785, as
  OpenSheaf's computed key-log versions are, section 6.1). Records are
  grouped in a prolly tree up to a root, and a version hash, with the
  prefix `ulv2:`, fixes a version. "Versions are manifests, not copies."
  Collections are named on the server (`knowledgefutures/journal-archive`).
- **Who can write.** A collection has "a single authoritative server",
  with no consensus and no peer-to-peer discovery.
- **The log.** Each collection keeps an append-only log in which "every
  entry is signed and carries the hash of the entry before it", adapted
  from Certificate Transparency. The server signs each entry with Ed25519,
  over the entry in canonical JSON (protocol v2, section 11.1; v3, section
  4.2); how readers come to trust its key is not specified.
- **Copies.** Mirrors are complete repositories on S3-compatible storage,
  "readable from the bucket alone", filled from packs whose objects are
  checked against their hashes, so that any copy "can be verified
  independently against the original".
- **Private records** appear in a public version only as salted
  commitments.
- **Identity.** Accounts on the server; a bridge to the AT Protocol, with a
  `did:web` per account, is planned (Knowledge Futures 2026d).
- **Withdrawal and rights.** Not addressed in the posts read; the v3
  draft defines a takedown (its section 7).

**What OpenSheaf does differently.** Both fix versions by digests and let
mirrors be checked without trusting them. In the Underlay, authority is a
server: a collection has one, and the log is its record; in v3 authors sign
their changes, but one authority still numbers and accepts versions. In
OpenSheaf an archive decides nothing about authenticity (specification,
section 3); the owner signs, and a line may be continued in another
archive (section 6.5). The Underlay holds records (data); OpenSheaf holds
documents and statements about them.

**What OpenSheaf could take.**

- **Salted commitments.** Publishing that a private record exists, without
  showing it, is what blind review needs: anonymous referees and authors,
  with the record opened later, is open
  ([#63](https://github.com/opensheaf/opensheaf.github.io/issues/63)).
- **Packs.** Sending exactly the objects a receiver lacks, checked by hash
  before anything is written, is the transfer that bundles
  ([#74](https://github.com/opensheaf/opensheaf.github.io/issues/74)) and
  mirrors (section 11.1) need.
- **"The IR of the future is a reading list."** A Knowledge Futures post of
  27 April 2026 argues that an institutional repository should be "a
  reader, not a writer": a curated list of collections mirrored locally
  (Knowledge Futures 2026e). That is an archive of mirrors with a catalogue
  of copies (specification, sections 8.1 and 11), and an argument OpenSheaf
  can share.

### 3.4 Software Heritage identifiers

**What it is.** SWHIDs name source code by content:
`swh:1:<type>:<digest>`, for contents, directories, revisions, releases
and snapshots, each a digest over a typed serialisation, forming a Merkle
graph compatible with git's (Di Cosmo, Gruenpeter and Zacchiroli 2018,
2020; <https://www.swhid.org/specification/v1.2/5.Core_identifiers/>).

**Status: active.** Published as ISO/IEC 18670:2025 in April 2025
(<https://www.iso.org/standard/89985.html>); release v1.2 of the
specification was published on GitHub on 7 November 2025, and `swh-model`
was last committed on 28 October 2026 (GitHub). The hash is SHA-1,
defended as being "for identification, not for cryptographic security"
(<https://lists.reproducible-builds.org/pipermail/rb-general/2026-January/003996.html>);
a version 2 with SHA-256 is under discussion
(<https://groups.google.com/g/swhid-discuss/c/G4lKMtr-iLA/m/76__j-ZWBgAJ>).

**How it works.** Names are intrinsic: anyone can compute and check them,
and resolution is out of scope of the standard. There is no identity, no
signature and no notion of a work across versions; what Software Heritage
archives, it keeps, save for legal takedowns.

**What OpenSheaf does differently, and could take.** OpenSheaf already uses
SWHIDs: as relations of the sources (section 4.4), and snapshots as
witnesses (section 7.2); whether an external record could resolve a pin is
open ([#22](https://github.com/opensheaf/opensheaf.github.io/issues/22)). A
SWHID names content; a `sheaf:` URI names a work, a line and a version, and
a pin is close to a SWHID of an inventory. What SWHIDs show is the path of
an intrinsic identifier to a standard: a community specification, then
ISO. Registering `sheaf` with IANA
([#36](https://github.com/opensheaf/opensheaf.github.io/issues/36)) is the
first step on that path. They also show the cost of an early hash choice:
OpenSheaf chose SHA-512 and SHA-256, but its numbered name algorithms
(section 5.2) serve clashes, not a change of hash, which would need a new
version of the format.

### 3.5 Research Objects and RO-Crate

**What it is.** RO-Crate packages research artefacts (data, code,
workflows, papers) with a JSON-LD description, `ro-crate-metadata.json`,
based on schema.org (Soiland-Reyes and others 2022).

**Status: active.** Version 1.2 was published on 4 June 2025, version 1.3
on 22 June 2026
(<https://www.researchobject.org/ro-crate/blog/2026-06-23/announcing-ro-crate-1-3>),
and work on an RO-Crate 2 has begun (the milestone "RO-Crate 2.0",
<https://github.com/ResearchObject/ro-crate/milestones>); the
specification was last committed on 20 November 2026 (GitHub).

**How it works.** The description "is not necessarily an exhaustive
manifest or inventory", and fixity is left to the packaging: ZIP, BagIt,
OCFL or git
(<https://www.researchobject.org/ro-crate/specification/1.2/structure.html>).
The implementation notes advise SHA-512 manifests in BagIt, warn that they
guard against accidental damage but give no proof that a crate was not
deliberately tampered with, and suggest an optional detached GPG signature
of the tag manifest
(<https://www.researchobject.org/ro-crate/specification/1.2/appendix/implementation-notes.html>).
The root may be `./` or an absolute URI such as a DOI; a detached crate
describes files on the web, and "[a]s files on the web may change", the
date they were read is recorded
(<https://www.researchobject.org/ro-crate/specification/1.2/data-entities.html>).
There is no model of versions, identity, withdrawal or rights beyond
licences stated in the description.

**What OpenSheaf does differently, and could take.** RO-Crate describes;
OpenSheaf fixes and signs. They meet in OCFL, which RO-Crate names as a
packaging and OpenSheaf uses for every object (specification, section 4).
A document version can hold an `ro-crate-metadata.json` among its sources,
fixed and signed with them; a profile could say how, for datasets and
analyses linked to papers, which are open
([#21](https://github.com/opensheaf/opensheaf.github.io/issues/21)).

## 4. Peer-to-peer and blockchain publishing

### 4.1 DeSci Nodes, dPIDs and Codex

**What it is.** DeSci Labs, a company, runs DeSci Nodes, a service for
publishing research objects (a manuscript with its code and data), each
named by a dPID resolved at `dpid.org`; Codex is its newer protocol layer
(<https://github.com/desci-labs/nodes>,
<https://github.com/desci-labs/desci-codex>,
<https://codex.desci.com/llms-full.txt>).

**Status: active.** `desci-labs/nodes` was last pushed on 5 August 2026,
the resolver on 10 August 2026, `desci-codex` on 15 June 2026 (GitHub).

**How it works.**

- **Fixity.** A research object's manifest is a JSON file named by an IPFS
  content identifier (CID), pointing to a tree of files by CID. The
  object itself is a Ceramic stream, each update a commit appended as a
  new version; Ceramic anchors commits on Ethereum, "tens of hours" apart,
  through an anchor service that "is a centralized system at the time of
  writing" (Codex documentation).
- **Names.** A dPID is an integer, with paths
  `dpid.org/<root>/<version>/<component type>/<component name>`; the root
  "always points to the latest version"
  (<https://docs.desci.com/create-and-publish/share/persistent-identifier-dpid>).
  The registry is a smart contract mapping each dPID to a Codex stream. It
  replaced an earlier contract in May and June 2024, keeps the old
  histories in a legacy mapping, and is ownable, pausable and upgradeable;
  its owner "can bypass" the limits on upgrades
  (<https://github.com/desci-labs/nodes/blob/develop/desci-contracts/contracts/DpidAliasRegistry.sol>).
  Both its deployments "currently live on Optimism Sepolia"
  (<https://github.com/desci-labs/nodes/blob/develop/desci-contracts/scripts/alias-registry/README.md>),
  a test network. Anyone may run a resolver.
- **Who can write, and identity.** The controller of the stream, a DID such
  as `did:pkh` (an Ethereum account); profiles may carry an ORCID iD.
- **Copies.** DeSci Labs pins the data on IPFS; Codex nodes replicate
  metadata and optionally files, and replication by the community is
  "ongoing work" (Codex documentation).
- **Withdrawal.** "No content can ever be truly removed"; entities are
  updated, not deleted, and revocation is by flagging.
- **Rights and preservation.** The code is under MIT; no default licence
  for content was found. DeSci Labs registers DOIs itself, as Crossref
  member 49317 with the prefix 10.62891
  (<https://api.crossref.org/members/49317>).

**A dependency that moved.** On 17 April 2025 Ceramic's developers
deprecated `js-ceramic` and ComposeDB "effective immediately", and
announced the end of ComposeDB and of the anchor service after the launch
of another product
(<https://blog.ceramic.network/the-future-of-ceramic-focusing-on-recall/>).
The Codex roadmap planned the migration of DeSci Nodes to `rust-ceramic`
for the last quarter of 2025. Whether the anchor service has closed is
**unverified**. Recall itself, the product Ceramic turned to, is winding
down: according to news reports, its foundation announced on 30 October
2026 that it would liquidate, with the application read-only from 30
November 2026
(<https://crypto.news/recall-foundation-wind-down-recall-token-burn/>; the
announcement itself was not found, so this is **unverified**).

**What OpenSheaf does differently.** A dPID is an alias that needs a
registry, a chain and a stream service; a `sheaf:` name is a digest of a
file every copy carries, checked without any of them (specification,
section 5, appendix D.2). DeSci's history of versions is a Ceramic stream
anchored on a chain; OpenSheaf's is a chain of inventories signed by the
owner (specification, sections 4.3 and 7). Ellerman's comparison of dPIDs
with DSIs makes the same point from the other side (Ellerman 2024a).

**What OpenSheaf could take.** Paths to components in the identifier. A
`sheaf:` URI names a version, but not a file in it, and no fragment is
defined (section 12.1); readers who cite a dataset or a figure of a version
need a way to name one file under a pin. A proposal follows (section 11).

### 4.2 Dat and Hypercore: Liberate Science and Hypergraph

**What it is.** Chris Hartgerink proposed research communication as
modules (a text, code, data), each a Dat archive, linked from parent to
child into a provenance record and registered in researchers' profiles,
since Dat "provides a decentralized register that is immutable" (Hartgerink
2019; Hartgerink and van Zelst 2018). Liberate Science built it as the
`p2pcommons` library and the Hypergraph application.

**Status: dead; its successor is centralised.** Hypergraph's beta was
released in October 2020
(<https://www.software.ac.uk/news/beta-release-hypergraph-here>), with
monthly releases into 2021. A post of 10 September 2021, "Hypergraph
lessons and future" (DOI 10.59350/avc4x-cqw32, which redirects to a page
of `libscie.org` that has been removed), ended it; its text was read only
through search results, so its reasons are **unverified**. The last
release of `@p2pcommons/sdk-js`, 0.9.2, dates from 17 May 2021
(<https://registry.npmjs.org/@p2pcommons/sdk-js>), and the `p2pcommons`
organisation on GitHub no longer exists. Its successor, ResearchEquals, is
a conventional web service with a DOI for each version
(<https://researchequals.com/>,
<https://github.com/libscie/ResearchEquals.com>, last pushed 13 February
2026); its site says that it needs EUR 100k a year "to sustain
ResearchEquals beyond 2027", and a static archive rebuilt nightly is kept
so that "links + DOIs will keep working" if the service fails
(<https://github.com/libscie/archive.researchequals.com>).

**How it worked** (from the `p2pcommons` package).

- **Fixity and names.** A module is a Hypercore drive, named by its public
  key; a version is `hyper://<key>+<version>`, a position in the drive's
  signed log.
- **Who can write.** The holder of the drive's write key.
- **Identity.** Profiles are drives too; a module is registered in a
  profile. The verification rules were in a specification of `p2pcommons`,
  now gone (**unverified**).
- **Copies.** Peers seed the drives they hold; deleting a module stops
  seeding, but "that does not means that the content won't still be
  available".
- **Versions.** A reviewer of Hartgerink's paper noted that without
  consensus divergent histories are possible (read in the review report
  through search results, **unverified**).

**What OpenSheaf does differently.** A Dat name is a key: the identity of
the module and the authority to write it are one secret, and a lost or
stolen key loses the module. OpenSheaf separates the name of a work (a
digest), the owner (a key log) and the keys (specification, section 6).
Dat needs peers online to keep content available; an OpenSheaf archive is
static files on any web server (specification, section 3). A fork of a
Dat log is a known hazard; OpenSheaf states what a fork of a line is, and
that both sides were signed by the owner's keys (section 7.4).

**What OpenSheaf could take.** The lesson of the end, whatever its
reasons: a peer-to-peer application lasted about a year, and its successor
keeps a static archive as its safety net, which is where OpenSheaf
starts. The modular idea, a record of research as linked modules, is what
relations between documents would carry
([#21](https://github.com/opensheaf/opensheaf.github.io/issues/21)), and
companion documents
([#28](https://github.com/opensheaf/opensheaf.github.io/issues/28)) are
one kind of them.

### 4.3 Blockchains for science

**Ledger.** A journal of cryptocurrency research at the University of
Pittsburgh, open access under CC BY
(<https://ledger.pitt.edu/ojs/ledger/about>). Its call for papers of 12
September 2015 said that "Ledger timestamps all published articles in the
Bitcoin blockchain" and "encourages authors to digitally sign their
manuscripts" (<https://ledger.pitt.edu/ojs/ledger/announcement/view/4>).
Its current guidelines strongly encourage the corresponding author to sign
"the file hash of the final version", with a Bitcoin, Bitcoin Cash or
Ethereum address or with PGP; the editors verify the signature and publish
it with the article. **Status: active**; volume 11 appeared on 5 June
2026. Its policies are still headed "Digital signatures and blockchain time
stamps", but they describe only signatures, so whether it still timestamps
articles on Bitcoin is **unverified**.

**bloxberg.** A proof-of-authority chain run by a consortium of research
institutions under the Max Planck Digital Library, founded in 2019
(<https://www.mpg.de/13417668/bloxberg-first-international-blockchain-for-science>).
Only the SHA-256 digest of a file and metadata are written; the proof of
existence is the earliest transaction holding the digest, which anyone can
look up on the chain. In its integration with MATLAB, its authors accept
the certification service as "a trusted component", which "introduces a
single point of failure into the system" (Wittek and others 2020).
**Status: active**; its site states that "A Layer 2 evolution on Ethereum
is underway" (<https://bloxberg.org/>), and its GitHub organisation was
last pushed on 26 October 2026, by a repository for that layer 2
(`issuer_json_l2`).

**ARTiFACTS.** A platform for recording research findings on a chain, from
2018, with a version 2 in July 2020 that secured files or metadata on
bloxberg (Kochalko 2019;
<https://prnewswire.com/news-releases/version-2-of-artifactsai-groundbreaking-platform-accelerates-secure-disclosure-of-research-findings-301103570.html>).
**Status: dead**: `artifacts.ai` redirects, on 22 November 2026, to an
unrelated foundation; no notice of closure was found, and the date of its
end is **unverified**.

**Orvium and Pluto.** Both began in 2018 as blockchain platforms for
publishing, with tokens (Orvium:
<https://knowledge4policy.ec.europa.eu/foresight/tool/dlt4good/orvium_en>;
Pluto: its white paper of January 2018,
<https://knowen-production.s3.amazonaws.com/uploads/attachment/file/1659/Pluto_white_paper_v04_180108_2130_BSH.pdf>).
Both dropped the chain. Orvium now sells publishing and review software
with Crossref and DataCite DOIs and does not mention a blockchain
(<https://orvium.io/>); its contract repositories were last pushed in April
2022. Pluto Labs published "Blockchain is NOT a cure to Academia" in 2019
(<https://medium.com/pluto-inc/blockchain-is-not-a-cure-to-academia-ef352985526>)
and became Scinapse, a search service (<https://scinapse.io/>). **Status:
active, without blockchains.**

**Scienceroot.** A token sale on Waves in 2018 and a partnership with
ARTiFACTS
(<https://medium.com/artifacts/artifacts-and-scienceroot-collaborate-to-expand-use-of-blockchain-in-scientific-research-and-a089aa75378b>);
no activity was found after 2019. **Status: dormant or dead,
unverified.**

**Proposals.** Tenorio-Fornes and others (2019) proposed publication and
peer review on Ethereum and IPFS, with reviewers' reputation on the chain
(the abstract was read; the mechanics are **unverified**); Trovo and Massari
(2021) a protocol for paid, anonymous open reviews on Ethereum; and
Tenorio-Fornes, Tirador, Sanchez-Ruiz and Hassan (2021) an interoperable
ecosystem of open peer review built on blockchains (read only through
search results, **unverified**). Hoffman's doctoral thesis (2023) is
titled *Towards decentralised open science with blockchains*; it was not
read. Hamburg (2021) called for a decentralised science movement in
*Nature*, and Weidener and Spreckelsen (2024) define DeSci from a review of
31 sources and a survey of 39 experts.

**ResearchHub**, often cited in the same breath, is a centralised platform
for discussing and funding research, co-founded "to bring crypto to
science"; its token, ResearchCoin, is an ERC-20 on Ethereum, also deployed
on Base, and its journal publishes registered reports funded on the
platform, under CC BY 4.0 (<https://docs.researchhub.com/llms-full.txt>).
Papers are not hashed or stored on a chain; only the token is. **Status:
active** (its back end was pushed on 22 November 2026).

**What OpenSheaf does differently.** No chain and no token. Of everything
the chain did in these projects, the lasting part is a dated digest: proof
that a file existed by a time. OpenSheaf keeps that as an option, outside
the core: the timestamps extension adds RFC 3161 tokens and OpenTimestamps
proofs, which anchor in Bitcoin, as witnesses beside signatures, and they
change no status by themselves (section 7.2; appendix D.3). Ledger's
practice, an author signing the digest of the final version and a
timestamp beside it, is what an OpenSheaf version with a timestamped
signature file is, without the journal having to verify it by hand.

**What OpenSheaf could take.** Little in design; much in experience
(section 10.1 below). A bloxberg certificate is one more kind of dated
witness, and could be read as one if an extension defined it.

### 4.4 Octopus

**What it is.** "The primary research record", in eight linked types of
publication (a research problem, a rationale or hypothesis, a method,
results, an analysis, an interpretation, a real-world application, a peer
review), managed by Jisc and Octopus Publishing CIC
(<https://www.octopus.ac/faq>). It is often cited as an alternative to
journals, but it is one central service on Amazon's cloud
(<https://github.com/Jisc/octopus>).

**Status: active**; the repository was last pushed on 16 November 2026.

**How it works.** Accounts are linked to ORCID iDs, and "any logged-in user
can publish immediately". Each version gets a DataCite DOI with
`IsVersionOf` a canonical DOI that moves to the latest version (the
repository, `api/src/lib/doi.ts`). Nothing is hashed. A publication
"cannot be deleted unless there is a breach of our user terms"; readers can
raise red flags. Everything is under CC BY 4.0. No preservation partner is
named.

**What OpenSheaf could take.** Its eight types are a vocabulary for
relations between documents of one piece of research, which OpenSheaf does
not have
([#21](https://github.com/opensheaf/opensheaf.github.io/issues/21),
[#28](https://github.com/opensheaf/opensheaf.github.io/issues/28)).

## 5. Linked data and personal servers

### 5.1 dokieli and Linked Research

**What it is.** Sarven Capadisli's thesis, *Linked Research on the
Decentralised Web* (Bonn, 2020), argues that researchers should publish on
their own domains, as linked data, and exchange notifications; it
contributed Linked Data Notifications (LDN), a W3C Recommendation, and
dokieli, an editor for articles and annotations in the browser (Capadisli
2020; Capadisli and others 2017). The thesis itself is published that way,
in HTML with RDFa, with a TimeMap, snapshots and an inbox
(<https://csarven.ca/linked-research-decentralised-web>).

**Status: active.** `dokieli/dokieli` was last committed on 22 November
2026 (GitHub); its documentation was updated on 13 November 2026
(<https://dokie.li/docs>).

**How it works** (<https://dokie.li/docs> and the source).

- **Fixity and versions.** "Version" makes a mutable copy with provenance;
  "Immutable" makes a fixed Memento resource and updates a TimeMap;
  "Archive" sends the article to the Wayback Machine; "Robustify Links"
  adds snapshot URIs and dates to links. No digest of articles was found.
- **Names.** URLs on the author's server.
- **Who can write, and identity.** The holder of a WebID, signed in
  through Solid; the storage checks access.
- **Signing, new in 2026.** dokieli makes keys in the browser, stores them
  in the user's storage, and publishes the public key in the WebID profile;
  "keys are added, never replaced". It signs with RSA, "what the nanopub
  network verifies" (`src/crypto.js`), and publishes an introduction and
  annotations as signed nanopublications (`src/nanopub.js`,
  `src/nanopub-annotation.js`, first committed on 17 September 2026).
  Whether whole articles are signed was not found (**unverified**).
- **Rights.** Licences set per article and annotation; notifications
  default to CC0.
- **Copies and preservation.** Web archives, by request.

**What OpenSheaf does differently.** Linked Research fixes a version by a
Memento and an archive's snapshot, both held by a server; OpenSheaf by a
pin, checked in any copy (specification, section 4). Identity there is a
WebID, a URL on a domain; in OpenSheaf an owner is named by a digest, and
a domain can only be its keeper (section 6.6). dokieli's keys, never
replaced, cannot be rotated after a theft; OpenSheaf's key logs exist for
that (section 6.3).

**What OpenSheaf could take.** Robust Links, a link with a snapshot URI and
a date, is the same idea as a `sheaf:` URI with a pin and an `at` hint
(section 12.1), and a landing page could emit both. dokieli's move to sign
through nanopublications shows that the linked-data community is now
looking for signatures, and has chosen an existing network rather than
inventing one (section 3.1 above).

### 5.2 Solid, researcher pods and event notifications

**What it is.** Solid is a protocol for personal data stores (pods) with
WebID identities (<https://solidproject.org/TR/protocol>, version 0.11.0, a
draft report of the W3C Community Group, 12 May 2024); the W3C Linked Web
Storage Working Group is standardising work based on Solid, with working
drafts of 16 November 2026, among them an authentication by self-signed
identifiers with a key in a controller document
(<https://www.w3.org/groups/wg/lws/publications/>,
<https://www.w3.org/TR/lws10-authn-ssi-cid/>). For scholarly
communication, a project funded by the Andrew W. Mellon Foundation from
2020 (the "ResearcherPod" work of Ghent University, IDLab) put artefacts
in researchers' pods, with service nodes that add value, LDN inboxes, an
append-only log of the life cycle of each artefact, and an orchestrator
(<https://mellonscholarlycommunication.github.io/spec-overview>;
Hochstenbach and others 2022, 2023, 2025;
<https://www.eventnotifications.net/>).

**Status.** The Linked Web Storage group is **active**, its texts drafts.
The Mellon specifications are **dormant** (their last versions date from
2023), but the project's GitHub organisation is active in 2026 (a
repository for a "claims network" was pushed on 3 November 2026), with a
direction **unverified**.

**How it works.** The protocol has no versions, digests or signatures, only
optional strong entity tags; artefacts in pods are "black-boxes" to the
network; identity is a WebID with OpenID Connect.

**What OpenSheaf does differently.** A pod is a mutable store behind
access control; an archive is a set of fixed, signed versions anyone can
copy and check. The event log of the Mellon work records what happened to
an artefact (reviewed, archived, cited) as notifications kept by each
party; OpenSheaf records such events, where they matter, as signed
statements that pin versions: a selection's revision set (section 8.4), a
witness (section 7.2), a notice (section 4.2).

**What OpenSheaf could take.** The event log is a good list of what a
record of a version's life should hold; matching each kind of event to a
form in OpenSheaf (collection, witness, notice, or nothing) would show what
is missing. The positioning paper's proposal of notifications with pins
(its section 7) is the bridge.

## 6. Signing research outputs

**Sigstore and PyPI.** Since 14 November 2024 PyPI accepts digital
attestations (PEP 740): releases signed through Sigstore with short-lived
certificates bound to the identity of a trusted publishing workflow, and
recorded in a transparency log
(<https://blog.pypi.org/posts/2024-11-14-pypi-now-supports-digital-attestations/>,
<https://docs.pypi.org/attestations/>). The identity is a CI workflow, not
a person's key. Sigstore's model signing applies the same to machine
learning models (<https://next.redhat.com/2025/04/10/model-authenticity-and-transparency-with-sigstore/>).
**Active.**

**Signed web archives (WACZ).** Webrecorder's draft specification signs a
web archive: a SHA-256 digest of its package description, which lists the
digests of its files, signed with ECDSA either by an anonymous key or by
the key of the domain's TLS certificate, checked against the certificate
chain; an RFC 3161 timestamp must fall within ten minutes of creation
(<https://specs.webrecorder.net/wacz-auth/0.1.0/>). `authsign` 0.6.1 was
released on 10 September 2026. **Active.**

**Content credentials (C2PA).** The US Office of Research Integrity
presents C2PA as a tool for the provenance of research images, noting that
credentials can be stripped and need support from instruments to
publishers (<https://ori.hhs.gov/content-provenance>, undated). Camera
makers ship C2PA, but no publisher or scientific instrument maker adopting
it for research images was found. **Proposals only.**

**ClawXiv.** Kornai (2026) proposes an author-side workflow that turns
research done with AI assistants into "durable, signed, inspectable
research artifacts": a normalised project, then a signed bundle, then a
published artefact, with scripts on GitHub
(<https://github.com/kornai/clawxiv>). The repository signs with Ed25519
keys of the author, and with an Ed25519 key of the AI co-author derived
through GPG (`src/clawxiv.py`, `src/ai_keygen.sh`).
**Active**, by version 2 of the paper, of 5 June 2026; the repository was
last pushed on 11 April 2026.

**What was not found.** No evidence that arXiv or Zenodo sign deposits or
accept authors' signatures (search only, **unverified**); no issuing of
verifiable credentials by ORCID (its "trust markers" are validated data
added by member organisations, and in 2025 verified e-mail domains became
one, <https://info.orcid.org/2025-year-in-review/>).

**What OpenSheaf does differently.** These systems bind a signature to an
identity checked at signing time by a third party (an OpenID provider, a
certificate authority, a transparency log), and date it then. OpenSheaf
binds it to an owner's key log, which checks itself from its name, and
signatures carry no time (sections 6.4, 6.5 and 7.6; appendix D.3). The
trade is discussed in [keys-and-forks.md](keys-and-forks.md) and
[federated-identity.md](federated-identity.md).

**What OpenSheaf could take.** A Sigstore signature bound to an ORCID
login, kept as a witness beside a version (section 7.2), would say that the
holder of an ORCID iD approved that pin at a time, without any key for the
author to keep; it belongs with the owner proofs of
[#41](https://github.com/opensheaf/opensheaf.github.io/issues/41). WACZ's
use of a domain's TLS key is another way for a domain keeper (section 6.6)
to confirm an owner.

## 7. Overlays, platforms and aggregation

### 7.1 Publish, review, curate: eLife, Docmaps, Sciety, PCI, Episciences

Overlay models are discussed in [positioning.md](positioning.md); what
matters here is how they refer to the versions they review, held on other
servers.

**eLife.** Since its announcement of 20 October 2022, eLife no longer
accepts or rejects: reviewed papers appear as Reviewed Preprints with an
assessment and public reviews, and authors may ask for a version of record
(<https://elifesciences.org/inside-elife/54d63486/elife-s-new-model-changing-the-way-you-share-your-research>).
"The parent DOI and citation remain the same across different versions"
(<https://elifesciences.org/inside-elife/2b765a27/elife-s-new-model-your-questions-answered>).
In Crossref, each version has its own DOI (`10.7554/eLife.111393.1`,
`.2`), which is `is-version-of` the preprint's DOI on bioRxiv, without a
version (<https://api.crossref.org/works/10.7554/elife.111393.2>). eLife's
own docmap fixes each preprint version it reviewed (here `v1` and `v2`) by
its DOI, a `versionIdentifier`, a URL ending in the version, and MECA
packages, both in bioRxiv's storage and in eLife's own; public reviews are
Hypothesis annotations with DOIs
(<https://data-hub-api.elifesciences.org/enhanced-preprints/docmaps/v2/by-publisher/elife/get-by-manuscript-id?manuscript_id=111393>).
No digest. **Active**; submissions fell from 6,396 in 2024 to 2,853 in
2025, after Web of Science decided, in October and November 2024, to index
eLife only in part
(<https://elifesciences.org/inside-elife/7da92a51/the-elife-model-three-year-update>;
<https://retractionwatch.com/2024/11/13/elife-wont-get-an-impact-factor-says-clarivate/>).

**Docmaps** describe editorial events over research outputs in JSON-LD
(McDowell and others 2021; <https://github.com/Docmaps-Project/docmaps>).
The specification's main branch was last committed on 20 December 2023
(**dormant**), but the format is produced every day by Sciety, whose index
has entries of 21 November 2026 (<https://sciety.org/docmaps/v1/index>),
and is said to be read by Europe PMC (**unverified**). Sciety's docmaps
name inputs by DOI and URL only.

**Sciety**, run by eLife, aggregates evaluations of preprints by groups of
reviewers; in 2025 it began federating discussions of preprints over
ActivityPub, with a Bonfire server funded by NLnet
(<https://nlnet.nl/project/Sciety-ActivityPub/>,
<https://blog.sciety.org/weeknotes/sciety-product-news-18-10-2025>).
**Active** (its repository was pushed on 20 November 2026).

**Peer Community In** recommends "a particular version of the preprint",
cited as "ver. 4 peer-reviewed and recommended by", with the preprint's DOI
(<https://peercommunityin.org/faq/>). **Episciences** asks authors to give
the repository's identifier and to "specify the version of the document to
be submitted" (<https://doc.episciences.org/submission>); an article of
*Logical Methods in Computer Science* of 18 November 2026 links
`arxiv.org/abs/2410.13508v4` (<https://lmcs.episciences.org/20167>).
Preservation is by CINES (<https://www.episciences.org/publishing-model/>).
Neither publishes a digest. Both **active**.

**What OpenSheaf does differently.** Every one of these overlays fixes the
version it vetted by a version number or a versioned URL, valid while the
server keeps it and says the same; at best it keeps its own copy (eLife's
MECA packages, the copies Episciences journals deposit at CINES), but
publishes no digest that a third party can check. A selection pins the
revision it vetted by the digest of its inventory, checked in any copy
(section 8.4), and can keep its own accepted copy (section 9.6). The
[arXiv paper](arxiv.md) notes that arXiv publishes no digests, so an
overlay on arXiv cannot pin what it reviewed without computing one itself.

**What OpenSheaf could take.** Docmaps are the format overlays already
exchange. A selection's history (revisions added, decisions, reviews) maps
naturally to docmaps, and a docmap could carry a pin. Both directions are
proposals (section 11).

### 7.2 Portals and platforms: Open Research Central, Coko, PubPub, OJS

**Open Research Central** was launched by F1000 in July 2017 as a portal to
submit research to its open research platforms (F1000Research, Wellcome
Open Research, Gates Open Research and others), with a promise to transfer
it to a board of the research community (F1000 blog, read only through
search results, **unverified**). **Dead**: on 22 November 2026
`openresearchcentral.org` and `www.openresearchcentral.org` do not resolve
(DNS queries for this paper), although the domain is registered until
2027. Whether the board was formed is **unverified**.

**Coko**, the Collaborative Knowledge Foundation, made PubSweet and Kotahi,
software for submission, review and publication, much of it funded by
eLife (<https://elifesciences.org/for-the-press/a587f01b>). Nothing in it is
federated. An eLife post of 15 June 2026 says that "following the Coko
Foundation's sunset at the start of this year", eLife Pathways stewards
Kotahi (read only in an aggregator's copy, so **unverified** in its
primary source); `kotahi.community` does not resolve on 22 November 2026.

**PubPub**, of Knowledge Futures, lost a funder in 2025, announced the
closure of its hosted platform for the end of 2025
(<https://www.knowledgefutures.org/updates/2025-06-update/>), and reversed
it on 12 January 2026: PubPub continues, can be self-hosted, and a planned
consortium might "potentially host mirrors"
(<https://www.knowledgefutures.org/updates/2026-01-update>). **Active.**
Its organisation's new work is the Underlay (section 3.3 above).

**Open Journal Systems**, of the Public Knowledge Project, runs tens of
thousands of independent journals, federated only by OAI-PMH harvesting:
over 58,000 journals used it in 2025
(<https://pkp.sfu.ca/2026/05/14/pkp-2025-annual-report/>). The PKP Index,
which aggregated them, was retired on 1 January 2022, others having done
its work (<https://pkp.sfu.ca/?p=4263>). The PKP Preservation Network
keeps a dark archive of journals that opt in, with LOCKSS, released if a
journal disappears (<https://pkp.sfu.ca/pkp-preservation/>, updated 16
March 2026); users reported deposits stuck from September 2025 to March 2026
(<https://forum.pkp.sfu.ca/t/archiving-pkp-preservation/97646>). No plugin
or proposal to federate OJS installations over ActivityPub or otherwise was
found. **Active.**

**What they show.** None of these platforms fixes versions by digest or
names them apart from a host; their relevance is institutional. A portal
that promised community governance disappeared; a foundation that built
shared software reportedly closed; a nonprofit platform nearly closed when
one funder left. The
software of a federation needs a durable owner, or must be unnecessary.

### 7.3 Aggregating preprints

**The ASAPbio Central Service.** In February 2017 ASAPbio, with funders
among them NIH, Wellcome and HHMI, called for a central service that would
aggregate preprints from all servers
(<https://www.the-scientist.com/funders-back-centralized-bio-preprint-server-32033>).
Two of the proposals were public: the Center for Open Science's "Commons",
to "connect preprint services in a community-based model"
(<https://www.cos.io/blog/building-a-central-service-for-preprints>, 30
April 2017), and a consortium led by EMBL-EBI, which runs Europe PMC, with
Coko, the Barcelona Supercomputing Center, eLife and EMBO, to ingest
preprints "from any source" into a community archive
(<https://elifesciences.org/inside-elife/3a527e1d/preprint-progress>, 12
May 2017). After the Chan Zuckerberg Initiative funded bioRxiv, ASAPbio
suspended the call on 10 May 2017, and it was not resumed (its page now
returns 404; read only through search results). **Dead.**

**Europe PMC** indexes the metadata of preprints from 32 servers, and the
full text of some (Levchenko and others 2024). Where a server gives each
version its own DOI, each version has a record; where versions share one
DOI, "a single PPRID" holds them, and the earlier version's record is
overwritten. A withdrawal is a new version. Links to journal articles come
from Crossref or from matching titles and authors, and about half are
missing from Crossref. **Active.**

**Crossref** links a preprint to its article (`isPreprintOf`, `hasPreprint`)
and, since schema 5.4.0, records a version and a status (withdrawn or
removed) of posted content; no checksums
(<https://www.crossref.org/documentation/schema-library/markup-guide-record-types/posted-content-includes-preprints/>).

**openRxiv**, a nonprofit launched on 11 March 2025, now runs bioRxiv and
medRxiv (<https://openrxiv.org/>); their new DOIs use the prefix 10.64898
(<https://api.crossref.org/prefixes/10.64898>). Its roadmap of 5 November
2026 plans a public corpus in the Open Exchange Architecture (OXA), with
APIs, in 2027, and says nothing of digests or mirrors
(<https://openrxiv.org/preprints-as-research-record-our-roadmap/>). bioRxiv
keeps one DOI for all versions, distinguished in the URL, and a withdrawal
"constitutes a new version"
(<https://connect.biorxiv.org/news/2023/08/15/preprint_withdrawals>).
**OSF Preprints** gives a DOI to each version since February 2025, so that
reviews can name one (<https://www.cos.io/blog/doi-versioning-and-metaror>),
and its generalist server stopped taking submissions in August 2025
(<https://www.cos.io/blog/update-on-future-of-osf-preprints>). arXiv
closed its network of mirrors on 15 September 2024
(<https://blog.arxiv.org/2024/09/13/attention-arxiv-users-arxiv-mirrors-to-shut-down-september-15th-2024>).

**What OpenSheaf does differently.** Aggregation by metadata loses versions
whenever a server does not name them, and the record of a version is
wherever its server says it is. OpenSheaf versions are named and fixed by
the archive's own files (specification, sections 4 and 12), so an
aggregator keeps every version it has seen, and checks that a copy is the
version it claims. OpenSheaf archives could be the community archive of
preprints from any source that the Europe PMC consortium proposed to build
for itself in 2017, but made by anyone, with copies anyone can check.

**What OpenSheaf could take.** Crossref's statuses of posted content
(withdrawn, removed) correspond to OpenSheaf's withdrawal and takedown
(specification, section 13). A withdrawal already gives a DataCite
`Withdrawn` date in `datacite.json` (section 13.1); Zenodo registers
DataCite DOIs, not Crossref ones (appendix A.1), and an archive registering
Crossref DOIs with its own prefix
([#8](https://github.com/opensheaf/opensheaf.github.io/issues/8)) would map
withdrawal and takedown to these statuses. Being indexed by Europe PMC
and the like needs, among other things, DOIs per version, which the Zenodo
profile gives.

## 8. Proposals for networks, and replication without permission

### 8.1 Proposals for a network of repositories

Brembs and others (2023a) propose replacing journals by a decentralised
network of substitutable services on top of institutional infrastructure;
Brembs and others (2023b), "Mastodon over Mammon", propose a federated,
redundant network of institutional repositories with layers for outputs,
narratives and communities. The second says nothing of versions,
signatures or preservation (read in its full text in PubMed Central,
PMC10688381). The book *Opening Science* (Bartling and Friesike 2014) has
no chapter on decentralised or peer-to-peer publishing by its title (its
chapter list in Crossref; the texts were not read, so whether one
discusses it is **unverified**); its chapters "Dynamic Publication Formats
and Collaborative Authoring" (Heller, The and Bartling) and "Unique
Identifiers for Researchers" (Fenner and Haak) are the nearest.

These proposals say what a federation should do, not in what form its
parties exchange what they hold. OpenSheaf is an answer to that second
question, which [positioning.md](positioning.md) calls the missing common
form.

### 8.2 Shadow libraries

Sci-Hub and Library Genesis, and since 2022 Anna's Archive, are the largest
replicated archives of scholarly papers, and they are illegal in most
countries. The facts here come from secondary sources. In May 2021
volunteers distributed Sci-Hub as 850 torrents of 100,000 articles each,
some 77 TB, so that it could not be taken down in one place (Vice, 20 May
2021,
<https://www.vice.com/en/article/activist-archivists-are-trying-to-save-the-pirate-bay-of-science>).
Copies of Library Genesis were distributed over IPFS from 2020, and it was
the object of a judgment in 2024
(<https://en.wikipedia.org/wiki/Library_Genesis>).
Anna's Archive distributes about 1.1 PB by torrent and lost several domains
in 2026, by suspension and then court orders
(<https://en.wikipedia.org/wiki/Anna%27s_Archive>,
<https://torrentfreak.com/annas-archive-loses-org-domain-after-surprise-suspension/>).
**Active, under legal pressure.**

**What they show.** Replication at scale works when files are named by
digest and anyone may hold a copy: the same property OpenSheaf's pins give
(specification, section 4). What it does not survive is the absence of
rights. OpenSheaf makes every archive answer for what it copies (section
11.2), and the metadata that checks copies is under CC0 so that it can
always be copied (section 15.6); a mirror of works under open licences has
what shadow libraries lack. They have no versions, no signatures and no
withdrawal.

## 9. Summary

| System | Unit | Fixed by | Named by | Who writes | Copies | Identity | Status (22 Nov 2026) |
|---|---|---|---|---|---|---|---|
| Nanopublications | RDF statement | SHA-256 Trusty URI | the content digest | any key, quota by trust | registries replicate, check hash and signature | RSA key, ORCID by declaration | active |
| DSI and DSGL | document succession | git hashes (SHA-1) | initial commit | SSH keys listed in the succession | any git host, Software Heritage | Ed25519 SSH keys | active, draft |
| Underlay | collection of records | SHA-256, prolly trees | server namespace, `ulv2:` versions, now `ul:ver:` (v3) | the collection's authority (a server); in v3 authors sign changes | S3 mirrors checked by hash | accounts, author keys (v3); `did:web` planned | active |
| SWHID | source code | SHA-1 Merkle graph | the content digest | anyone | Software Heritage | none | active, ISO |
| RO-Crate | package | left to BagIt, OCFL, git | `./` or a URI | anyone | none specified | none | active |
| DeSci Nodes, dPID | research object | IPFS CIDs, Ceramic stream | integer in a contract | stream controller (wallet DID) | IPFS pinning, Codex nodes | `did:pkh`, ORCID in profile | active |
| Hypergraph (Dat) | module | Hypercore signed log | public key and version | holder of the write key | peers seed | key; profiles | dead (2021) |
| Ledger | article | signed digest (Bitcoin timestamp, unverified) | DOI | journal | journal | PGP or crypto address | active |
| bloxberg | digest of a file | proof of existence on chain | transaction | consortium members | chain nodes | institutional validators | active |
| ARTiFACTS, Orvium, Pluto, Scienceroot | record, article | chain | various | platform | platform | wallets, ORCID | dead or no chain |
| ResearchHub | registered report, discussion | none (token on chain only) | DOI | platform accounts | one service | accounts | active, central |
| Octopus | eight types | none | DataCite DOI per version | ORCID accounts | one service | ORCID | active, central |
| dokieli, Linked Research | article, annotation | Memento, web archive | URL | WebID holder | web archives | WebID; RSA keys since 2026 | active |
| Solid, ResearcherPod | artefact in a pod | none | URL | pod owner | none | WebID | drafts; dormant |
| Sigstore, WACZ, C2PA | release, web archive, image | digest and signature | package or file | OIDC identity, domain | registries | OIDC, TLS certificate | active; C2PA proposed |
| ClawXiv | signed research bundle | digests, Ed25519 signatures | arXiv identifier, repository | author and AI co-author keys | GitHub, arXiv | Ed25519 keys | active |
| eLife, Docmaps, PCI, Episciences | review of a preprint version | none (DOI, version number, URL) | DOI | journal, group | none | accounts, ORCID | active (Docmaps spec dormant) |
| Europe PMC, Crossref, openRxiv | preprint metadata | none | DOI, PPRID | servers | none | servers | active |
| ORC, Coko, ASAPbio central service | portal, software, aggregator | none | DOI | platform | none | accounts | dead (Coko reportedly) |
| PubPub | publication platform | none | DOI, URL | platform accounts | self-hosting; mirrors considered | accounts | active |
| OJS, PKP Preservation Network | journal | none | DOI, URL | each journal | LOCKSS dark archive, opt-in | accounts | active |
| Shadow libraries | file | digests (torrents, IPFS) | digest | uploaders | anyone seeds | none | active, illegal |
| OpenSheaf | object version of a document or collection | SHA-512 inventories, pins | genesis digest, owner name | the owner of the line | any archive, checked by pin and signature | owner key log, Ed25519, pre-rotation | draft 0.2 |

## 10. Evaluation

### 10.1 What failed before, and why

- **Dependence on a token or a chain.** Every platform found that made a
  chain or a token the basis of publishing, except DeSci Nodes, has closed
  or dropped the chain: ARTiFACTS, Orvium, Pluto and, apparently,
  Scienceroot. A post of Pluto Labs said so in its title (section 4.3
  above). What survives besides DeSci Nodes uses a chain only for dated
  digests (bloxberg, Ledger), which needs no token. ResearchHub keeps a
  token for payments, not for the record.
- **Dependence on someone else's infrastructure.** DeSci's dPIDs rest on a
  registry that its owner can change, deployed on a test network, and on
  Ceramic, whose developers deprecated the software DeSci used within a
  few years (section 4.1 above). The Underlay's collections each have one
  authoritative server. A decentralised design with one indispensable
  party is as fragile as that party.
- **Availability by peers.** Hypergraph, which needed peers online to keep
  content available, lasted about a year (its reasons were not read), and
  was replaced by a central service that keeps a static archive as its
  safety net (section 4.2 above).
- **Funding and stewards.** Coko sought a new steward and, reportedly,
  closed; PubPub nearly closed when one funder left; ResearchEquals says it
  needs EUR 100k a year to sustain it beyond 2027; why Open Research
  Central disappeared was not found. Shared infrastructure for scholarly
  communication is funded by a few foundations, and ends when they leave.
  Other services ended for other reasons: the PKP Index because others did
  its work, the ASAPbio call when the Chan Zuckerberg Initiative funded
  bioRxiv, OSF's generalist server over research integrity and duplicated
  infrastructure.
- **Adoption and incentives.** Nanopublications are the most successful
  decentralised design found, after more than fifteen years: some 80,000
  records by some 600 signers in May 2026. Researchers publish where
  evaluation counts: eLife's submissions fell by more than half after its
  indexing changed (section 7.1 above). A system outside the indexes is
  outside the incentives.
- **Law.** The archives that replicate best, shadow libraries, are pursued
  in court, because they replicate without rights.

### 10.2 Which of these risks OpenSheaf shares

- **Adoption: shared, fully.** OpenSheaf has one real archive. Its value,
  checkable records exchanged between parties, appears only when several
  parties use it.
- **Incentives: shared.** An OpenSheaf archive is not indexed by Web of
  Science or Scopus, and counts for nothing in evaluation by itself. It
  reaches the indexes only through DOIs (appendix A.1;
  [#8](https://github.com/opensheaf/opensheaf.github.io/issues/8)) and
  Google Scholar through landing pages (appendix A.3), and through overlays
  that do count.
- **Funding: shared for the tools, not for the archives.** The reference
  tools, the Explorer and any gateway
  ([#35](https://github.com/opensheaf/opensheaf.github.io/issues/35)) need
  maintainers. But an archive needs only a static web server, and its
  files stay valid and readable if every OpenSheaf tool stops: this is the
  position ResearchEquals reached after its peer-to-peer phase, taken from
  the start.
- **Key management: shared, and heavier.** Authors must keep keys, and
  rotation keys apart from them (section 6.2). dokieli chose keys that are
  never replaced; DSGL lists keys in each document; nanopublications put
  one key in each record. OpenSheaf asks more of its users than any of
  them, for a better answer to theft. Whether authors will bear it is
  untested.
- **Availability: partly shared.** Content stays available only while
  someone serves it. Mirrors and custodians make that independent of the
  author (specification, section 11), but what a custodian promises is
  open
  ([#54](https://github.com/opensheaf/opensheaf.github.io/issues/54),
  [#39](https://github.com/opensheaf/opensheaf.github.io/issues/39)).
- **Discovery: shared.** Without indexes of many archives
  ([#20](https://github.com/opensheaf/opensheaf.github.io/issues/20)), a
  line whose archives have gone is hard to find, however checkable its
  copies.
- **Not shared.** No token, no chain, no registry of names, no running
  node, no stream service and no authoritative server. Nothing OpenSheaf
  needs is a service run by another project; the texts it builds on are
  fixed (OCFL 1.1, DataCite 4.7, and a `did:key` encoding the specification
  states itself, section 6.1). And every archive answers for the rights of
  what it copies (section 11.2).

### 10.3 Where OpenSheaf is new, and where it is not

**Not new.**

- Naming content by its digest: Trusty URIs (2014), SWHIDs (2018), IPFS.
- Versions signed by their authors' keys, authority in the keys and not
  in the host: DSGL (2024), Hartgerink's Dat modules (2019), Ledger's
  signed digests (2015), nanopublications.
- A name computed from the first state of a history: DSIs, from the
  initial commit.
- Supersession and retraction as new signed records, nothing deleted:
  nanopublications.
- Replication between servers checked by digest: the nanopublication
  registries, the Underlay's mirrors, LOCKSS (Maniatis and others 2003).
- Append-only signed logs: the Underlay, after Certificate Transparency.
- Dated digests as evidence: bloxberg, Ledger, OpenTimestamps.
- Overlays that vet particular versions held elsewhere: PCI, Episciences,
  eLife, all since before OpenSheaf.
- Packaging with digests: BagIt, OCFL, RO-Crate.
- Static files, or a git host, as the whole requirement: DSGL, BagIt and
  OCFL, ResearchEquals' static archive.

**New, as far as this search found.**

- **A name of the work shared by the lines of several owners, apart from
  hosts and keys.** A genesis digest names the work in every archive; the
  owner is named apart, by its own genesis record; and several owners may
  hold lines of one work, as branches and accepted copies (specification,
  sections 5, 7 and 9). A DSI is also apart from hosts and keys, but names
  one succession; nanopublications name one content, dPIDs a registry
  entry.
- **Owners with key logs and pre-rotation**, for scholarly documents:
  pre-rotation after KERI (appendix D.3) applied to authors.
  Nanopublications let an ORCID iD declare a new key, and DSGL lets a
  listed key change the list, but a thief can do either as well; none of
  the scholarly systems found answers a theft with keys committed before
  it.
- **Collections that pin other parties' versions** as signed, versioned
  objects of the same format, with the distinction between keeping whole
  objects (catalogues) and vetting particular versions (selections),
  across archives (specification, section 8). Overlays vet versions, but
  by a number or a URL; the Underlay and IPFS fix trees, but of one
  party's content.
- **Explicit rules for withdrawal, takedown, tombstones and rights of
  copies**, written for a federation in which no archive binds another
  (specification, sections 11.2, 13 and 15.6).
- **Static files as the whole requirement, together with signed owners
  and collections**: no node, protocol or service to run for any of it.

None of these is new in isolation in computing; their combination, for
scholarly documents, was not found. The closest designs each have parts
OpenSheaf lacks: nanopublications a working network with trust and
quotas; the Underlay salted commitments and packs; DSGL the simplicity of
one git history per document.

## 11. Proposals

These are ideas for discussion, not decisions; each would go through an
issue before anything changes.

- **Talk to the closest designs.** Write to the authors of DSIs, of the
  nanopublication network and of the Underlay, with this paper: to test
  OpenSheaf's choices against theirs, and to find where records could pass
  between them (a Baseprint succession imported as a line; a statement about
  an OpenSheaf version published as a nanopublication).
- **Statements about versions as nanopublications.** Define how a
  nanopublication names an OpenSheaf version (its `sheaf:` URI with a pin)
  and how an archive or an Explorer reads such statements, as one answer
  to [#21](https://github.com/opensheaf/opensheaf.github.io/issues/21).
- **A file in a version.** Open an issue on naming one file of a version
  in a `sheaf:` URI (a path after the version, or a parameter), resolved
  through the inventory, as dPIDs name components (section 4.1 above).
  Section 12.1 of the specification defines no fragment and no path today.
- **Docmaps from selections.** Export the history of a selection
  (revisions added, with the curator's messages) as docmaps, so that Sciety
  and Europe PMC can read OpenSheaf overlays; and suggest to the Docmaps
  project a field for the digest of the version reviewed.
- **A suggestion to overlays.** Episciences, Peer Community In and eLife
  could record, at the decision, the SHA-512 digest of each file of the
  version they vetted; with the [arXiv paper](arxiv.md)'s proposal of
  witnessed digests, that is the first step towards pins.
- **Salted commitments for blind review.** Study the Underlay's commitments
  to private records for
  [#63](https://github.com/opensheaf/opensheaf.github.io/issues/63):
  a selection could commit to a review or a referee's name and open it
  later.
- **Trust for indexes.** Take the nanopublication registry's quotas from
  endorsements as a model for indexes of many archives
  ([#20](https://github.com/opensheaf/opensheaf.github.io/issues/20)).
- **Sigstore witnesses.** Define, as an extension, a witness made by
  Sigstore with an ORCID login over a pin, for
  [#41](https://github.com/opensheaf/opensheaf.github.io/issues/41).
- **RO-Crate in a version.** A short profile or use case for a dataset
  version holding `ro-crate-metadata.json` among its sources.
- **Say what happens if the project stops.** A short statement on the site
  that archives remain valid, readable and checkable with any OCFL tool and
  the specification, if every OpenSheaf tool and service ends: the answer
  to the commonest failure of section 10.1 above.

## 12. Experiments

- Import a Baseprint document succession into a test archive as a line:
  map editions to document versions, check the SSH signatures, and record
  the DSI and the SWHIDs of snapshots; see what does not map.
- Publish, with Nanodash or `nanopub-java`, a nanopublication stating a
  review of a pinned OpenSheaf version, and query it back from a registry
  by the `sheaf:` URI.
- Take a recent Episciences article and a Peer Community In recommendation,
  fetch the version they name, compute its digests, and write a selection
  pinning an imported copy of it; measure what the overlay would have to
  do to make the pin itself.
- Mirror the first archive into an S3 bucket in the layout of the Underlay,
  or the reverse, to compare the two designs of mirrors in practice.
- Ask a handful of authors to create an owner with rotation keys and sign
  a version, and record where they stop.

## 13. Open questions

- Is a per-owner key log worth its cost against DSGL's keys listed in each
  document, for authors who will never meet a theft?
- Should OpenSheaf join an existing network for statements (the
  nanopublication registries) rather than define its own forms for reviews
  and claims?
- What would make an institution keep a federation's software running for
  twenty years, given that several shared services of section 7.2 above
  lost their funder or their steward?
- Can a federation of archives reach the indexes that count in evaluation
  without a publisher in front of it?
- SHA-1 still names most of git and every SWHID: should OpenSheaf say how
  it treats evidence built on SHA-1 (a SWHID witness, a git snapshot)?

## 14. Conclusion

Decentralised scholarly publishing has been proposed many times, and its
pieces exist: names from digests, signatures by authors, replication
checked by hash, overlays over versions held elsewhere. What failed was
rarely the cryptography. Projects ended when their funders or stewards
left, when no one adopted them, or when the chain, token or service they
relied on moved; others were overtaken by other services. OpenSheaf avoids
the last of these risks by requiring nothing but static files, and shares
the first two. Its new contribution is the combination: works whose name,
apart from hosts and keys, is shared by the lines of several owners,
owners who can change keys and keep their names, and collections that pin
other parties' versions. The closest neighbours, Document Succession
Identifiers, nanopublications and the Underlay, are each worth a direct
conversation, and each has something OpenSheaf lacks.

## References

**Papers and books.**

- Bartling, S. and Friesike, S. (eds.), *Opening Science: The Evolving
  Guide on How the Internet is Changing Research, Collaboration and
  Scholarly Publishing*, Springer, 2014, open access,
  doi:10.1007/978-3-319-00026-8.
- Brembs, B. and others, *Replacing academic journals*, Royal Society Open
  Science 10 (7), 230206, 2023, doi:10.1098/rsos.230206 (Brembs and others
  2023a).
- Brembs, B., Lenardic, A., Murray-Rust, P., Chan, L. and Irawan, D. E.,
  *Mastodon over Mammon: towards publicly owned scholarly knowledge*, Royal
  Society Open Science 10 (7), 230207, 2023, doi:10.1098/rsos.230207
  (Brembs and others 2023b).
- Capadisli, S., *Linked Research on the Decentralised Web*, doctoral
  thesis, University of Bonn, 2020,
  <https://bonndoc.ulb.uni-bonn.de/xmlui/handle/20.500.11811/8352>;
  <https://csarven.ca/linked-research-decentralised-web>.
- Capadisli, S., Guy, A., Verborgh, R., Lange, C., Auer, S. and
  Berners-Lee, T., *Decentralised authoring, annotations and notifications
  for a read-write web with dokieli*, ICWE 2017, LNCS, pp. 469-481,
  doi:10.1007/978-3-319-60131-1_33.
- Di Cosmo, R., Gruenpeter, M. and Zacchiroli, S., *Identifiers for digital
  objects: the case of software source code preservation*, iPRES 2018,
  doi:10.17605/OSF.IO/KDE56.
- Di Cosmo, R., Gruenpeter, M. and Zacchiroli, S., *Referencing source code
  artifacts: a separate concern in software citation*, Computing in Science
  and Engineering 22 (2), 33-43, 2020, doi:10.1109/MCSE.2019.2963148.
- Groth, P., Gibson, A. and Velterop, J., *The anatomy of a
  nanopublication*, Information Services and Use 30 (1-2), 51-56, 2010,
  doi:10.3233/ISU-2010-0613.
- Hamburg, S., *Call to join the decentralized science movement*, Nature
  600, 221, 2021, doi:10.1038/d41586-021-03642-9.
- Hartgerink, C. H. J., *Verified, shared, modular, and provenance based
  research communication with the Dat protocol*, Publications 7 (2), 40,
  2019, doi:10.3390/publications7020040.
- Hartgerink, C. H. J. and van Zelst, M., *"As-you-go" instead of
  "after-the-fact": a network approach to scholarly communication and
  evaluation*, Publications 6 (2), 21, 2018,
  doi:10.3390/publications6020021.
- Hochstenbach, P., Van de Sompel, H., Vander Sande, M., Dedecker, R. and
  Verborgh, R., *Event notifications in value-adding networks*, TPDL 2022,
  LNCS 13541, pp. 133-146, doi:10.1007/978-3-031-16802-4_11.
- Hochstenbach, P., Verborgh, R. and Van de Sompel, H., *Using event
  notifications, Solid and orchestration for decentralizing and decoupling
  scholarly communication*, Code4Lib Journal 58, 2023,
  <https://journal.code4lib.org/articles/17823>.
- Hochstenbach, P., Verborgh, R. and Van de Sompel, H., *Event
  notifications and event logs: transparent sharing of artifact life cycle
  data*, International Journal of Digital Curation 19 (1), 2025,
  doi:10.2218/ijdc.v19i1.920.
- Hoffman, M. R., *Towards decentralised open science with blockchains*,
  doctoral thesis, University of Southampton, 2023,
  <https://eprints.soton.ac.uk/478122/>.
- Kochalko, D., *Making the unconventional conventional: how blockchain
  contributes to reshaping scholarly communications*, Information Services
  and Use 39, 199-204, 2019, doi:10.3233/ISU-190053.
- Kornai, A., *ClawXiv: a signed archival workflow and distributed
  publication architecture for human-AI collaborative research*,
  arXiv:2604.16476, 2026.
- Kuhn, T. and Dumontier, M., *Trusty URIs: verifiable, immutable, and
  permanent digital artifacts for linked data*, ESWC 2014, LNCS 8465, pp.
  395-410, doi:10.1007/978-3-319-07443-6_27.
- Kuhn, T., Chichester, C., Krauthammer, M. and Dumontier, M., *Publishing
  without publishers: a decentralized approach to dissemination, retrieval,
  and archiving of data*, ISWC 2015, LNCS 9366, pp. 656-672,
  doi:10.1007/978-3-319-25007-6_38.
- Kuhn, T. and others, *Decentralized provenance-aware publishing with
  nanopublications*, PeerJ Computer Science 2, e78, 2016,
  doi:10.7717/peerj-cs.78.
- Kuhn, T., Balseiro, V., Caselli, A., Plutschow, Z., Sowinski, P. and
  Danilenka, A., *A robust decentralized infrastructure for trust-aware
  open knowledge sharing*, ISWC 2026, LNCS, pp. 152-170,
  doi:10.1007/978-3-032-42015-2_8.
- Levchenko, M., Parkin, M., McEntyre, J. and Harrison, M., *Enabling
  preprint discovery, evaluation, and analysis with Europe PMC*, PLoS ONE
  19 (9), e0303005, 2024, doi:10.1371/journal.pone.0303005.
- Maniatis, P., Rosenthal, D. S. H., Roussopoulos, M., Baker, M., Giuli,
  T. J. and Muliadi, Y., *Preserving peer replicas by rate-limited sampled
  voting*, SOSP 2003, pp. 44-59, doi:10.1145/945445.945451.
- McDowell, G. S., Polka, J. K., Ross-Hellauer, T. and Stein, G., *The
  DocMaps framework for representing assertions on research products in an
  extensible, machine-readable, and discoverable format*, bioRxiv, 2021,
  doi:10.1101/2021.07.13.452204.
- Priem, J. and Hemminger, B. M., *Decoupling the scholarly journal*,
  Frontiers in Computational Neuroscience 6, 2012.
- Smith, J. W. T., *The deconstructed journal: a new model for academic
  publishing*, Learned Publishing 12 (2), 1999.
- Soiland-Reyes, S. and others, *Packaging research artefacts with
  RO-Crate*, Data Science 5 (2), 97-138, 2022, doi:10.3233/DS-210053.
- Tenorio-Fornes, A., Jacynycz, V., Llop-Vila, D., Sanchez-Ruiz, A. and
  Hassan, S., *Towards a decentralized process for scientific publication
  and peer review using blockchain and IPFS*, HICSS 2019, pp. 4635-4644,
  doi:10.24251/HICSS.2019.560.
- Tenorio-Fornes, A., Tirador, E. P., Sanchez-Ruiz, A. A. and Hassan, S.,
  *Decentralizing science: towards an interoperable open peer review
  ecosystem using blockchain*, Information Processing and Management 58
  (6), 102724, 2021, doi:10.1016/j.ipm.2021.102724.
- Trovo, B. and Massari, N., *Ants-Review: a privacy-oriented protocol for
  incentivized open peer reviews on Ethereum*, Euro-Par 2020 workshops,
  LNCS, 2021, pp. 18-29, doi:10.1007/978-3-030-71593-9_2.
- Van de Sompel, H., Payette, S., Erickson, J., Lagoze, C. and Warner, S.,
  *Rethinking scholarly communication: building the system that scholars
  deserve*, D-Lib Magazine 10 (9), September 2004,
  <https://dlib.org/dlib/september04/vandesompel/09vandesompel.html>.
- Weidener, L. and Spreckelsen, C., *Decentralized science (DeSci):
  definition, shared values, and guiding principles*, Frontiers in
  Blockchain 7, 2024, doi:10.3389/fbloc.2024.1375763.
- Wittek, K., Krakau, D., Wittek, N., Lawton, J. and Pohlmann, N.,
  *Integrating bloxberg's proof of existence service with MATLAB*,
  Frontiers in Blockchain 3, 2020, doi:10.3389/fbloc.2020.546264.

**Specifications, documentation and posts.**

- Ellerman, E. C., *DeSci dPID vs Document Succession Identifier*, 3 April
  2024, <https://castedo.github.io/dpid-vs-dsi> (Ellerman 2024a).
- Ellerman, E. C., *Document Succession Git Layout*, edition 1.1, 20
  February 2024, <https://pilot.perm.pub/VGajCjaNP1Ugz58Khn1JWOEdMZ8/>;
  <https://castedo.github.io/dsi-spec>,
  <https://castedo.github.io/dsgl-spec/> (Ellerman 2024b).
- Knowledge Futures, *Underlay, revived*, 27 April 2026,
  <https://www.knowledgefutures.org/updates/2026-04-27-underlay-revived>
  (2026a); *Content-addressed records*, 8 June 2026,
  <https://www.knowledgefutures.org/updates/2026-06-08-content-addressed-records>
  (2026b); *Underlay moves to protocol v2*, 6 October 2026,
  <https://www.knowledgefutures.org/updates/2026-10-06-underlay-protocol-v2>
  (2026c); *Underlay meets AT Protocol*, 28 April 2026,
  <https://www.knowledgefutures.org/updates/2026-04-28-atproto-integration>
  (2026d); *The IR of the future is a reading list*, 27 April 2026,
  <https://www.knowledgefutures.org/updates/2026-04-27-institutional-repositories>
  (2026e); the Underlay protocol, <https://underlay.org/docs/protocol>,
  and its documents, <https://github.com/knowledgefutures/underlay>.
- Nanopublications: guidelines, <https://nanopub.net/guidelines/working_draft/>;
  documentation, <https://nanopub.net/docs/>; Trusty URI specification,
  <https://github.com/trustyuri/trustyuri-spec>; Nanopub Registry,
  <https://github.com/knowledgepixels/nanopub-registry>.
- DeSci Labs: <https://github.com/desci-labs/nodes>,
  <https://github.com/desci-labs/desci-codex>,
  <https://codex.desci.com/llms-full.txt>,
  <https://docs.desci.com/create-and-publish/share/persistent-identifier-dpid>;
  Ceramic, *The future of Ceramic*, 17 April 2025,
  <https://blog.ceramic.network/the-future-of-ceramic-focusing-on-recall/>.
- dokieli: <https://dokie.li/docs>, <https://github.com/dokieli/dokieli>.
- Solid Protocol 0.11.0, <https://solidproject.org/TR/protocol>; W3C
  Linked Web Storage Working Group, <https://www.w3.org/groups/wg/lws/>;
  Mellon scholarly communication specifications,
  <https://mellonscholarlycommunication.github.io/spec-overview>; Event
  Notifications in Value-Adding Networks,
  <https://www.eventnotifications.net/>.
- RO-Crate 1.2, <https://www.researchobject.org/ro-crate/specification/1.2/>,
  its data entities,
  <https://www.researchobject.org/ro-crate/specification/1.2/data-entities.html>,
  and implementation notes,
  <https://www.researchobject.org/ro-crate/specification/1.2/appendix/implementation-notes.html>;
  RO-Crate 1.3,
  <https://www.researchobject.org/ro-crate/blog/2026-06-23/announcing-ro-crate-1-3>;
  the RO-Crate 2.0 milestone,
  <https://github.com/ResearchObject/ro-crate/milestones>.
- SWHID specification 1.2, <https://www.swhid.org/specification/v1.2/>;
  ISO/IEC 18670:2025, <https://www.iso.org/standard/89985.html>.
- PEP 740, <https://peps.python.org/pep-0740>; PyPI attestations,
  <https://docs.pypi.org/attestations/>; WACZ signing and verification
  0.1.0, <https://specs.webrecorder.net/wacz-auth/0.1.0/>; Office of
  Research Integrity, content provenance,
  <https://ori.hhs.gov/content-provenance>.
- Ledger, <https://ledger.pitt.edu/ojs/ledger/about>; bloxberg,
  <https://bloxberg.org/>; Octopus, <https://www.octopus.ac/faq>,
  <https://github.com/Jisc/octopus>; ResearchHub,
  <https://docs.researchhub.com/llms-full.txt>; ResearchEquals,
  <https://researchequals.com/>.
- eLife's model,
  <https://elifesciences.org/inside-elife/2b765a27/elife-s-new-model-your-questions-answered>,
  and its three-year update, 17 March 2026,
  <https://elifesciences.org/inside-elife/7da92a51/the-elife-model-three-year-update>;
  Docmaps, <https://github.com/Docmaps-Project/docmaps>; Sciety,
  <https://sciety.org/about>; Peer Community In,
  <https://peercommunityin.org/faq/>; Episciences,
  <https://www.episciences.org/publishing-model/>.
- Knowledge Futures on PubPub, <https://www.knowledgefutures.org/updates/2026-01-update>;
  PKP Preservation Network, <https://pkp.sfu.ca/pkp-preservation/>.
- Crossref, posted content,
  <https://www.crossref.org/documentation/schema-library/markup-guide-record-types/posted-content-includes-preprints/>;
  openRxiv, <https://openrxiv.org/>; bioRxiv on withdrawals,
  <https://connect.biorxiv.org/news/2023/08/15/preprint_withdrawals>; OSF
  on DOIs for versions, <https://www.cos.io/blog/doi-versioning-and-metaror>.
- The OpenSheaf [specification](../opensheaf-specification-0.2.md), the
  [timestamps extension](../opensheaf-timestamps-0.2.md), and the working
  papers [positioning.md](positioning.md),
  [git-as-implementation.md](git-as-implementation.md),
  [keys-and-forks.md](keys-and-forks.md),
  [federated-identity.md](federated-identity.md) and
  [arxiv.md](arxiv.md).
