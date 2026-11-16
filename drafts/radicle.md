# Radicle and OpenSheaf

*Working paper, draft of 16 November 2026. Non-normative: ideas and positions,
not decisions. Radicle is a peer-to-peer network for collaboration on git
repositories: repositories named by a digest, peers named by keys, each peer
writing only its own branch of a repository, and seed nodes that replicate
what they choose. Many of its choices meet open questions of OpenSheaf:
self-certifying names, owners and lines (the proposal of [PR
#30](https://github.com/opensheaf/opensheaf.github.io/pull/30)), custodians
that keep copies (issue
[#13](https://github.com/opensheaf/opensheaf.github.io/issues/13)), indexes
of many archives, private archives (issue
[#29](https://github.com/opensheaf/opensheaf.github.io/issues/29)). This paper
describes Radicle, sets its concepts against those of OpenSheaf, describes
three ways to use it, from a transport for archives kept in git to a source of
designs, and proposes experiments.*

## 1. The question

The [git paper](git-as-implementation.md) asks whether git's own structures
could carry OpenSheaf. Radicle asks the next question: what git needs to
become a network without a central host. Its answers are names derived from a
digest, keys as identities, one writer per branch, signed references, and
nodes that replicate by policy. Several of them are the answers that PR #30
proposes for OpenSheaf, reached independently, and Radicle has run them since
2024 on a public network.

Two readings are possible. In the first, Radicle is a **transport**: an
archive kept in git ([OpenSheaf archives in git](../opensheaf-git-0.1.md)) is
also published as a Radicle repository, and seed nodes keep copies of it, as
mirrors would. In the second, Radicle is a **model**: its repository is an
OpenSheaf object with a self-certifying name, its peers are owners, its peer
branches are lines, its seeds are custodians. This paper takes both, and asks
what each would gain and cost.

## 2. Radicle in brief

The description follows Radicle's protocol guide, its seeder guide and its
announcement of version 1.0 (references at the end). The reference
implementation, called Heartwood, is written in Rust and released under the
MIT and Apache 2.0 licences. Version 1.0.0 was released on 10 September 2024,
with the promise that later changes of the protocol would be backwards
compatible; the disclosure of September 2026 (section 2.7) breaks that promise
for the transport.

### 2.1 Nodes and keys

Every participant runs a node. A node is named by its **Node ID** (NID), an
Ed25519 public key, written as a decentralised identifier with the `did:key`
method (`did:key:z6Mk...`). At the protocol level, nodes "are
indistinguishable from users": there is no account and no identity apart from
the key. A node may announce an alias, which is neither unique nor checked. A
lost or compromised key means a new identity; there is no rotation, and
several devices for one person are listed as future work.

### 2.2 Repositories and their identity

A repository is named by a **Repository ID** (RID), `rad:z3gqcJ...`: the git
SHA-1 digest of the repository's first **identity document**, in base 58. The
identity document is canonical JSON, kept in git under `refs/rad/id` and
managed as a collaborative object (section 2.5). It holds:

- `delegates`: the keys (DIDs) of the people, groups or bots who answer for
  the repository; a repository starts with one delegate, its creator, and may
  gain more;
- `threshold`: how many delegates must agree;
- `visibility`: public, or private with an allow list of keys;
- `payload`: the description, for a project `xyz.radicle.project` with
  `name`, `description` and `defaultBranch`.

Since the RID is the digest of the *first* identity document, the document
may change while the name stays; every change is signed by the delegates, and
anyone holding the first document can check the whole chain of changes
without a trusted third party. The model is taken from The Update Framework
(TUF).

### 2.3 Storage: one repository, a namespace per peer

A node keeps each repository as one bare git repository under its storage
folder, named by the RID. Each peer that has published to the repository has
its own git **namespace**, named by its NID
(`refs/namespaces/<nid>/refs/heads/...`), and is "the sole owner and writer"
of it; Radicle calls it a soft fork. Objects are stored once for all
namespaces. Git reaches a peer's branch as `rad://<rid>/<nid>`, and the
repository's canonical references as `rad://<rid>`. The storage is internal:
users are warned not to touch it.

### 2.4 Signed references and the canonical branch

Each time a peer's references change, its node signs all of them together and
stores the signature, with the list of references and their commits, under
`refs/rad/sigrefs` in the peer's namespace. A reader can thus check that
every branch of a peer is what the peer published, whichever node delivered
it.

There is no central branch. The **canonical** default branch is computed:
the commit that at least `threshold` delegates have on their own
`defaultBranch` is the canonical state. Only the default branch is computed
this way; other branches, and tags, are listed as future work.

### 2.5 Collaborative objects

Issues, patches (proposed changes) and the identity document itself are
**collaborative objects** (COBs), stored in the same repository under
`refs/cobs/<type>/<id>`, with types named in reverse DNS form
(`xyz.radicle.issue`, `xyz.radicle.patch`, `xyz.radicle.id`); anyone can
define a type of their own. Each change is a signed git commit; the commits
of all peers form a directed acyclic graph, and graphs received from
different peers are united, idempotently, and reduced in topological order,
ties broken by commit hash: a conflict-free replicated data type (CRDT). So
the discussion of a repository lives in the repository and travels with it.

### 2.6 The network

Nodes talk by **gossip**, with three signed messages:

- a *node announcement* (version, addresses, alias, a nonce against denial of
  service);
- an *inventory announcement*: the RIDs the node holds;
- a *refs announcement*: for one RID, the new heads of some namespaces.

Inventory announcements build a routing table of which nodes hold which
repositories; refs announcements tell nodes that something changed, and they
fetch it with git's own pack protocol, on the same connection as the gossip.
Messages are kept for a while and replayed to nodes that come back. Two
bootstrap nodes run by the project serve nodes that know no one.

Each node has a **seeding policy**: a default (`allow` or `block`) and
exceptions per repository (`rad seed`, `rad block`). A repository is
replicated by the nodes that seed it; it stays available while one of them is
online. A **seed node** is an always-on node: *fully replicating* if it seeds
everything it hears of, *selective* if its operator chooses. To read a
repository without cloning it, a node must also run `radicle-httpd`, a
read-only HTTP JSON API over its storage, behind which a web interface
browses repositories; without it "the repositories on your seed node cannot
be browsed or viewed without cloning them first".

### 2.7 Privacy, and the disclosure of September 2026

A private repository lists the keys allowed to see it; other nodes neither
see nor replicate it. Its data are "not encrypted at rest": privacy rests on
replicating only to the allowed nodes.

On 23 September 2026 the project disclosed two critical flaws, present in all
versions released until then: traffic between nodes was neither encrypted nor
authenticated, and the handshake allowed a node to present a Node ID not its
own. Together they let an attacker on the path read traffic and fetch private
repositories. The data model was not affected: signed references still
detect any change in transit, and no code or identity can be forged. The
project advised to stop using private repositories, and is replacing its
transport with iroh, in a new major version that will not talk to the old
one; the storage layout stays. At the time of writing no fixed release is
announced.

### 2.8 Digests

Radicle uses git as it is: SHA-1 object identifiers, and a RID that is a
SHA-1 digest. SHA-256 repositories are not mentioned.

## 3. How the concepts meet

The middle column uses the terms of the specification, and of the proposal of
PR #30 where marked; the proposal is not agreed.

| Radicle | OpenSheaf | Remarks |
|---|---|---|
| Node ID, an Ed25519 key as `did:key` | keyed owner, `did:key:` Ed25519 (PR #30) | a named owner (archive identifier, ORCID iD) has no counterpart in Radicle |
| repository, named by its RID | object, with a self-certifying name (PR #30) | RID: SHA-1 of the first identity document; name: SHA-256 of a seed and `genesis.json` |
| first identity document | genesis record `genesis.json` (PR #30) | both fix the name; Radicle's document then changes, signed by the delegates |
| `payload` of the identity document | `datacite.json`, `object.json` | Radicle's description is minimal (name, description, default branch) |
| delegates and threshold | owner of a line, single writer | several owners with a quorum: open, issue #53 |
| peer namespace, "sole owner and writer" | line (owner, name), single writer (PR #30) | the closest match of all |
| fork of a peer, then a patch | deep branch (PR #30) | in Radicle, merging into the canonical branch is the delegates' act |
| canonical default branch, by threshold | the origin line, the originator's (PR #30) | OpenSheaf has one origin, no vote |
| commit on a branch | object version | a commit fixes its history byte for byte; a pin fixes it through inventories (issue [#46](https://github.com/opensheaf/opensheaf.github.io/issues/46)) |
| tags (not canonical yet) | document versions, numbered | Radicle has no notion of a version of the work |
| signed references `rad/sigrefs` | witnesses: signatures of inventory checksum files (section 13.2); every version signed by a keyed owner (PR #30) | Radicle signs a state of all branches; OpenSheaf signs each version |
| collaborative objects (issues, patches) | none in the core; comments and reviews are objects of their own, companion documents (issue [#28](https://github.com/opensheaf/opensheaf.github.io/issues/28)) | Radicle keeps the discussion inside the repository; OpenSheaf keeps statements in their authors' objects |
| seed node | mirror (section 10.4), custodian (issue #13) | a seed keeps every namespace of a repository; a mirror keeps one object, the same object |
| seeding policy (`allow`, `block`) | the decision to mirror, limited by licences | a seed needs no licence check; a mirror needs every version's licence to allow redistribution |
| inventory announcement | `objects` of the discovery document `opensheaf.json` | pushed by gossip in Radicle; read by pull in OpenSheaf |
| refs announcement | the feed of an archive (`feed`) | announcement is a function OpenSheaf leaves to others ([positioning](positioning.md)) |
| routing table | indexes `names/`, `owners/`, resolvers, gateways (PR #30, issue [#20](https://github.com/opensheaf/opensheaf.github.io/issues/20)) | Radicle's is built by every node from gossip |
| `radicle-httpd` and the web interface | the archive itself, static files | OpenSheaf is read with nothing but HTTP |
| private repository, allow list | private archives (issue #29) | both rest on not giving the files away; neither encrypts |
| deletion: stop seeding, delete the repository | withdrawal (a new version), takedown and tombstone (section 11) | Radicle records no withdrawal and keeps no tombstone |
| none | catalogue, selection, pin, accepted copy | Radicle has no collections across repositories |

The match is close where both systems answer the same question: who may
write what, and how a reader knows it. A Radicle peer namespace is a line of
PR #30: one writer, named by a key, under a name that does not depend on
where the copy is kept, and copies that agree or fork. The RID is a
self-certifying name derived from a first record, as the name of PR #30 is
derived from `genesis.json`. Seeds are custodians.

The match breaks where OpenSheaf is about documents rather than code:

- **Versions of the work.** Radicle has commits and branches; OpenSheaf has
  document versions, numbered, with description-only versions, notices and
  withdrawals. Tags would be the nearest thing, and are not yet canonical.
- **Collections.** Nothing in Radicle states, about another repository, that
  this exact version was vetted. Catalogues and selections, made of pins
  across archives, have no counterpart; they would be repositories whose
  files name RIDs and commits, which Radicle would carry but not check.
- **Statements apart from their subject.** Radicle puts issues and reviews
  inside the repository they discuss, signed by their authors and merged as a
  CRDT. OpenSheaf keeps a document free of the statements about it: a review
  is its own object, kept by its author, and a selection names what it vetted.
  Radicle's choice gathers a work and its discussion in one place, which the
  [essay that motivated
  OpenSheaf](https://mgubi.org/docs/zettels/a-living-scientific-record.html) asks
  for; OpenSheaf's choice lets anyone answer for a statement without the
  author of the work holding it.
- **Reading.** A Radicle repository is read by a node, or through an HTTP
  API that a node serves; an OpenSheaf archive is a static website, read by a
  browser or a script, and verified with nothing else.
- **Digests and durability.** Radicle uses SHA-1 and git's internal storage;
  OpenSheaf uses SHA-512 and OCFL, plain files meant to be read in decades
  without the software that made them (requirements 9 and 10 of the [git
  paper](git-as-implementation.md#2-what-opensheaf-needs)).

## 4. Three ways to use Radicle

### 4.1 Radicle as a transport for archives in git

An archive kept in git, following [OpenSheaf archives in
git](../opensheaf-git-0.1.md), is published as a Radicle repository with
`rad init`; its keeper is the delegate; seed nodes keep copies. The archive
is still served over HTTP as a static website, from its git host or
elsewhere; Radicle adds copies that do not depend on GitHub or on any host,
and a way to fetch the whole archive from whoever has it.

- **Gains.** Copies kept by others, for free, with no account; the archive
  survives the loss of its host; the keeper's key signs every state of the
  archive's branches, a witness of the history of the discovery document.
- **Costs.** Nothing in the format changes, and nothing is checked by it:
  a seed holds a git repository, not a mirror in the sense of section 10.4,
  and readers still need the HTTP site. The unit is the whole archive, not an
  object, so a seed cannot keep one document. Seeds replicate without
  checking licences; an archive should be seeded only if its licences allow
  redistribution, as for mirrors. Private archives should not be published
  this way while the transport is being replaced (section 2.7).

This is a deployment choice, open to any keeper today. It belongs in the
[deployment note](deployment.md) rather than in the specification.

### 4.2 One Radicle repository per object

Each object is a Radicle repository, its RID the object's name; its owner is
the delegate; each object version is a commit on the default branch, holding
the files of the version, as in the designs of the [git
paper](git-as-implementation.md#5-three-designs); a co-author is a second
delegate or a peer with a fork; seeds are mirrors and custodians; a
collection is a repository whose `members.json` names RIDs and commits.

- **Gains.** Names, owners, lines, signatures, forks and replication all come
  ready, tested on a public network; an index of many archives is the
  routing table.
- **Costs.**
  - It makes OpenSheaf a convention on top of Radicle: an archive is no
    longer readable as static files, and verification needs Radicle's
    software, against requirement 9 of the git paper.
  - SHA-1 throughout, where OpenSheaf requires SHA-512.
  - Only the default branch is canonical; document versions would need
    tags, which are not.
  - The identity document is Radicle's, not `genesis.json`: the names would
    differ from those of PR #30, and an object could not move to a plain
    archive without a second name (the problem of issue #20, two names for
    one object).
  - The transport is being replaced by an incompatible one (section 2.7):
    building on it now means following a moving protocol.

This design is not recommended. It would trade the format's independence for
features that PR #30 already specifies in plain files.

### 4.3 Radicle as a source of designs

OpenSheaf keeps its files and its digests, and borrows designs that Radicle
has tested. Each is described in Radicle's terms, then in OpenSheaf's.

#### A namespace per owner

**In Radicle.** A project is one git repository. Inside it, each peer has a
namespace named by its key, and only that peer writes there: Alice's branches
are under `refs/namespaces/<alice>/`, Bob's under `refs/namespaces/<bob>/`.
The files are stored once and shared by all namespaces.

**In OpenSheaf.** PR #30 gives each line (owner, name) one writer. Take a
paper by A: co-author B continues it (a deep branch), and journal J keeps the
version it vetted (a shallow branch). Today these are three OCFL objects, and
an archive or a custodian keeping all three stores the same files three
times. Radicle suggests grouping the lines of one work, one folder per owner:

```
ocfl/<name>/<owner A>/v1, v2 ...
ocfl/<name>/<owner B>/v1, v2, v3 ...
ocfl/<name>/<owner J>/v1 ...
```

A reader then finds every line of a work in one place, and the forks are
visible. This bears on custodians holding many lines (issue
[#39](https://github.com/opensheaf/opensheaf.github.io/issues/39)).

The saving of space needs no new layout where the archive is kept in git:
git stores each file once, by its digest, across the whole repository, so
the three objects share their files already
([OpenSheaf archives in git](../opensheaf-git-0.1.md), and the [git
paper](git-as-implementation.md)). Only on plain file systems and static
hosts would the files be stored several times; there, OCFL objects are
self-contained and do not share files, so sharing would need an OCFL
extension. What remains of the idea is the grouping: a layout, or an index,
that places the lines of one name together.

#### Delegates and a threshold

**In Radicle.** The identity document lists keys, the delegates, and a
threshold, for instance 2 of 3. The canonical state of the default branch is
the commit that at least 2 delegates have. A change of the document, adding
or removing a delegate, also needs the signatures of 2 current delegates. The
name of the repository is the digest of the first document, so it does not
change.

**In OpenSheaf.** PR #30 gives each line a single owner, and leaves open how
several people answer for one line. With one owner, the other authors of a
paper keep branches of their own. With delegates, the line is owned by a
group: `genesis.json` lists the keys of A, B and C with a threshold of 2; a
version belongs to the line only if 2 of them signed it; adding D, or
replacing a lost key, is a signed change by 2 of the current owners.

The cost is that a verifier must replay every change of the owners since the
genesis record to know who may sign a given version, and that only keyed
owners can take part: an ORCID iD asserted as owner signs nothing. The
question is left for later, in issue
[#53](https://github.com/opensheaf/opensheaf.github.io/issues/53).

#### Signing the discovery document

**In Radicle.** Each time a peer's branches change, its node signs the whole
list, each branch with its commit, as one statement. Whoever delivers a
copy, a reader can check that it is exactly what the peer published.

**In OpenSheaf.** The discovery document `opensheaf.json` lists each object
with its head and the digest of its inventory. The specification calls it "a
map, not a witness" (section 6.1): it is checked against the storage root,
but nobody answers for it. Each version is protected by its pin; what is not
protected is which version is the latest. A copy of an archive kept
elsewhere, or an attacker on the way, could serve an older map, hiding a newer
version or a withdrawal.

The archive's key could sign each new `opensheaf.json`, with a sequence
number and a timestamp. A copy kept anywhere (a seed, a mirror, Software
Heritage) would then prove that on a given date the archive declared these
heads. An old map remains validly signed, so freshness needs the sequence
number and the timestamp; and the signature needs archive keys, which issue
#13 discusses.

#### Announcements

The inventory and refs announcements are what an index of many archives
needs to hear: which archive holds which objects, and which heads changed. A
feed of an archive, read by aggregators, plays that part; gossip is one way
to carry it (section 5 of the [positioning
paper](positioning.md#5-federated-and-distributed-systems)).

#### Seeding policies for custodians

**In Radicle.** Each node has a seeding policy: a default, keep everything
(`allow`) or nothing (`block`), and exceptions per repository. A public seed
node keeps everything it hears of; a selective one keeps what its operator
lists.

**In OpenSheaf.** Today a mirror is decided object by object (`mirrorOf`).
Custodians (issues #13 and #39) would be institutions that keep copies of
others' work. A custodian could publish its policy in its discovery document,
as standing rules:

- keep every object of an owner;
- keep every member of a collection, including those added later;
- keep every revision a selection vets;
- always within what the licences allow (section 10.4).

Readers and authors would then know what is promised: an author could see
which institutions will keep their work. And custody could be automatic:
when a journal's selection adds a paper, every custodian that follows the
selection mirrors it. This would be a new field; nothing like it is in the
specification.

#### Comments merged by many authors

**In Radicle.** An issue is a graph of small signed changes by different
people: open, comment, reply, edit, close. Each change names the changes it
follows, by their digests. Every node unites the graphs it receives and
computes the same state in a fixed order, so no server decides what the
discussion is, and any copy can be merged with any other.

**In OpenSheaf.** An object has one writer, but the discussion of a paper (an
objection, the author's reply, a correction, a referee's remark) has many.
Making each comment an object of its own is heavy. A discussion modelled on
Radicle's issues would be one object, separate from the paper, as the format
requires (a document never holds the statements about it), made of small
entries: each signed by its author, naming the document version it discusses
and the entries it answers, and fixed by its digest. Anyone may keep a copy;
copies merge by union. This keeps an objection, its correction and the reply
connected, as the [essay that motivated
OpenSheaf](https://mgubi.org/docs/zettels/a-living-scientific-record.html)
asks.

The costs: anyone can add entries, so each keeper chooses which to accept,
as a seed chooses what to keep; authors need keys to sign; and nothing is
deleted, only answered or retracted by a later entry. Such discussions are
companion documents in the sense of issue #28, or an extension.

And one warning. Radicle's privacy rested on replicating only to allowed
nodes, and failed with its transport. Private archives (issue #29) should not
rely on where files travel; files that must stay private should be encrypted
at rest, or never leave their keeper.

## 5. Assessment

Radicle is the nearest working system to what OpenSheaf proposes for names
and owners: a name derived from a first record, keys as owners, one writer
per line, signed states, copies kept by whoever chooses. That it works on a
public network is evidence that the design of PR #30 is practicable. It is
also evidence of the costs: a protocol whose nodes must run, a storage that
users must not touch, SHA-1, and a transport that had to be replaced after two
years.

OpenSheaf should not be built on Radicle (section 4.2). An archive kept in git
may be published on Radicle as one more copy (section 4.1). The designs of
section 4.3 deserve to be weighed in the discussions they touch: delegates
and thresholds in issue #53, signed discovery documents and custodians in
issue #13, announcements for indexes in issue #20, encryption for private archives
in issue #29.

## 6. Experiments

1. **An archive on Radicle.** Publish the git repository of
   [mgubi/papers](https://github.com/mgubi/papers) with `rad init`, seed it
   from a second node, delete the first, and check with `osheaf` that the
   archive cloned from the seed verifies, every pin matching.
2. **Serving through `radicle-httpd`.** Check whether its HTTP API delivers
   the files of a repository byte for byte, at paths a reader can compute; if
   so, a seed with `radicle-httpd` could serve an archive to the Explorer,
   behind a small proxy.
3. **One object as a repository.** Make one document a Radicle repository
   (section 4.2), one commit per object version, and measure what is lost:
   the document versions, the description-only versions, the SHA-512
   inventories, and the name of PR #30.
4. **Delegates for a line.** Write the rules of PR #30 for a line with two
   owners and a threshold, as Radicle's identity document does, and see what
   a verifier must replay.
5. **Signed discovery documents.** Sign each version of `opensheaf.json`
   with the archive's key, as signed references sign a peer's branches, and
   see what a reader of a copy gains.

## 7. Open questions

- Does Radicle's new transport (iroh) change what it offers to archives, for
  example reading over HTTP without a Radicle node?
- Will Radicle adopt SHA-256 repositories when git does?
- Should the deployment note recommend Radicle, or only mention it, as one
  way to keep copies of an archive in git?
- Is a quorum of keys the right model for co-authors in PR #30, or should a
  line keep one writer and co-authors keep lines of their own? (Issue #53.)
- Should an archive sign its discovery document, making it a witness of the
  map of the archive?

## References

- Radicle: <https://radicle.xyz> (now also <https://radicle.dev>).
- Radicle Protocol Guide: <https://radicle.dev/guides/protocol>.
- Radicle Seeder Guide: <https://radicle.dev/guides/seeder>.
- Radicle 1.0.0, 10 September 2024:
  <https://radicle.dev/2024/09/10/radicle-1.0.0>.
- Disclosure of vulnerability in the network protocol, 23 September 2026:
  <https://radicle.dev/2026/09/23/disclosure-of-vulnerability-in-network-protocol.html>.
- Radicle at FOSDEM 2026:
  <https://fosdem.org/2026/schedule/event/TMQZTP-radicle>.
- The Update Framework: <https://theupdateframework.io>.
- iroh: <https://www.iroh.computer>.
