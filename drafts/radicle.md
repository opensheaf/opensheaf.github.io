# Radicle and OpenSheaf

*Working paper, draft of 17 November 2026. Non-normative: ideas and positions,
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
designs, and proposes experiments. Several of these designs were adopted in
the proposal of [PR #56](https://github.com/opensheaf/opensheaf.github.io/pull/56) (issues
[#55](https://github.com/opensheaf/opensheaf.github.io/issues/55) and
[#52](https://github.com/opensheaf/opensheaf.github.io/issues/52)): owners as
keyed identities with key logs, archives as hosts, storage keyed by lines,
and branches as new objects.*

## 1. The question

The [git paper](git-as-implementation.md) asks whether git's own structures
could carry OpenSheaf. Radicle asks the next question: what git needs to
become a network without a central host. Its answers are names derived from a
digest, keys as identities, one writer per branch, signed references, and
nodes that replicate by policy. Several of them are the answers that PR #30
proposes for OpenSheaf, reached independently, and Radicle has run them since
2024 on a public network.

The comparison has since shaped the proposal. [PR #56](https://github.com/opensheaf/opensheaf.github.io/pull/56), which revises PR
#30 and, like it, is not agreed, makes an owner a keyed identity with a key
log, as a Radicle node is an identity made of a key; makes archives hosts with
no identity of their own, as Radicle's identity document says who and never
where; stores each line at `<owner>/<name>/`, as Radicle stores a repository
by its RID with a namespace per peer; and makes every branch a new object, as
a Radicle fork is a namespace of its own. Where this paper says "the
proposal", it means PR #30 as revised by PR #56.

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

The key is made by `rad auth`, which asks for a passphrase and stores the
pair in the OpenSSH format under `~/.radicle/keys/` (`radicle`, the secret
key encrypted with the passphrase, and `radicle.pub`); the alias goes in the
configuration file. For daily use the key is loaded into `ssh-agent`, through
which Radicle signs everything (signed references, changes of collaborative
objects, announcements), or the passphrase is given in the environment
variable `RAD_PASSPHRASE` (source: `commands/auth.rs`, `ssh/keystore.rs`,
`profile.rs` of Heartwood, section 2.9).

Other nodes learn of a node from its signed node announcements, and keep its
addresses and alias. A connection was meant to be authenticated by the key
(section 2.6), which the disclosure of September 2026 found broken (section
2.7). Nothing ties a key to a person: no name, ORCID iD or e-mail address is
attached, and readers trust a key they got from a source they trust. A person
with several machines either copies the secret key between them, or appears
as several identities. Radicle shows that an identity made of a key alone
works in daily use, with `ssh-agent` doing the signing; it does not answer
rotation, several keys or the tie to a person. The proposal answers them with
the key log of an owner (rotation, several keys, a threshold; #55, question 1)
and an optional two-way link between an owner and its keeper, confirmed on the
keeper's ORCID record or web domain (#55, question 5; issue
[#41](https://github.com/opensheaf/opensheaf.github.io/issues/41)).

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

### 2.9 Names and collisions

The documentation does not say what happens when two repositories share a
name or a RID; the following is read from the source of Heartwood (the GitHub
mirror `radicle-dev/heartwood`, commit `8b053320dc3d` of 6 November 2026,
files `crates/radicle/src/rad.rs`, `identity/doc.rs`, `storage/git.rs`).

**Names.** The name in the payload is description only: nothing checks it,
and there is no registry. Any number of repositories may be called
`heartwood`; they are told apart by their RIDs and their delegates. A
repository with the name and description of a well-known project is easy to
make, and only the RID protects readers: they must get it from a source they
trust.

**How the RID is made.** `rad init` builds the first identity document from
exactly five things: the format version, the payload (`name`, `description`,
`defaultBranch`), the creator's key as sole delegate, a threshold of 1, and
the visibility. It encodes the document as canonical JSON and takes its git
blob digest, SHA-1, as the RID. There is no nonce and no date. Hence:

- two people creating repositories with the same name get different RIDs,
  since their keys differ;
- one person creating two repositories with the same name, description,
  default branch and visibility gets the same RID twice. On one node the
  second `rad init` fails, because the storage folder of that RID already
  exists (the code carries a note to give a better error). On two machines
  sharing the same key, both succeed, and once the nodes meet, the two
  projects are one repository with one namespace for their owner: their
  default branches overwrite each other.

**Two repositories with one RID.** For Radicle a RID is one repository:
nodes store one git repository per RID and announce RIDs, so the copies of two
repositories with one RID would be fetched into the same storage, and nodes
could hold different first identity documents for it, and disagree about its
delegates. Nothing in the protocol detects or resolves this; Radicle relies
on the digest never repeating. A stranger cannot make a document with an
existing RID, which would need a second preimage of SHA-1. But SHA-1
collisions can be made (SHAttered, 2017; a chosen-prefix collision,
"Shambles", 2020): someone could craft two different first documents, both
their own, with one RID, and show different repositories to different
people. The digest is computed with libgit2, whose SHA-1 detects the known
collision attacks by default; that is the only defence.

## 3. How the concepts meet

The middle column uses the terms of the specification, and of the proposal
(PR #30 as revised by PR #56) where marked; the proposal is not agreed.

| Radicle | OpenSheaf | Remarks |
|---|---|---|
| Node ID, an Ed25519 key as `did:key` | owner: a keyed identity named by the digest of its genesis record, whose key log lists `did:key:` Ed25519 keys (proposal) | the key is not the owner: keys change in the key log, the owner's name stays; Radicle has no rotation |
| repository, named by its RID | work, with a self-certifying name; each line (name, owner) an object (proposal) | RID: SHA-1 of the first identity document; name: SHA-256 of a seed and `genesis.json` |
| first identity document | genesis record `genesis.json` of a work, and of an owner (proposal) | both fix the name; Radicle's document then changes, signed by the delegates, as an owner's key log does |
| `payload` of the identity document | `datacite.json`, `object.json` | Radicle's description is minimal (name, description, default branch) |
| delegates and threshold | `keys` and `threshold` of an owner's key log (proposal) | one threshold governs both key changes and every version of the owner's lines, as Radicle's governs delegates and the canonical branch |
| peer namespace, "sole owner and writer" | line (name, owner), single writer, stored at `<owner>/<name>/` (proposal) | the closest match of all |
| fork of a peer, then a patch | branch: a new object starting at the parent's version, with its evidence; the parent's history, if kept, a copy of its line beside it (proposal) | a fork is a namespace of its own, the parent's replicated beside it; merging into the canonical branch is the delegates' act |
| canonical default branch, by threshold | the origin line, the originator's (proposal) | OpenSheaf has one origin, no vote |
| commit on a branch | object version | a commit fixes its history byte for byte; a pin fixes it through inventories (issue [#46](https://github.com/opensheaf/opensheaf.github.io/issues/46)) |
| tags (not canonical yet) | document versions, numbered | Radicle has no notion of a version of the work |
| signed references `rad/sigrefs` | a signature file for every object version, naming the key-log version it relies on (proposal) | Radicle signs a state of all branches; OpenSheaf signs each version |
| collaborative objects (issues, patches) | none in the core; comments and reviews are objects of their own, companion documents (issue [#28](https://github.com/opensheaf/opensheaf.github.io/issues/28)) | Radicle keeps the discussion inside the repository; OpenSheaf keeps statements in their authors' objects |
| seed node | mirror: a copy of a line with its owner's key log (proposal); custodian (issues #13, #39) | a seed keeps every namespace of a repository; a mirror keeps one line |
| seeding policy (`allow`, `block`) | the decision to mirror, limited by licences; custody policies (issue [#54](https://github.com/opensheaf/opensheaf.github.io/issues/54)) | a seed needs no licence check; a mirror needs every version's licence to allow redistribution |
| inventory announcement | `objects` of the discovery document `opensheaf.json` | pushed by gossip in Radicle; read by pull in OpenSheaf |
| refs announcement | the feed of an archive (`feed`) | announcement is a function OpenSheaf leaves to others ([positioning](positioning.md)) |
| routing table | indexes `names/`, `owners/`, resolvers, gateways (proposal, issue [#20](https://github.com/opensheaf/opensheaf.github.io/issues/20)) | Radicle's is built by every node from gossip |
| `radicle-httpd` and the web interface | the archive itself, static files | OpenSheaf is read with nothing but HTTP |
| private repository, allow list | private archives (issue #29) | both rest on not giving the files away; neither encrypts |
| deletion: stop seeding, delete the repository | withdrawal (a new version), takedown and tombstone (section 11) | Radicle records no withdrawal and keeps no tombstone |
| none | catalogue, selection, pin, accepted copy | Radicle has no collections across repositories |

The match is close where both systems answer the same question: who may
write what, and how a reader knows it. A Radicle peer namespace is a line of
the proposal: one writer, an identity made of keys, under a name that does not
depend on where the copy is kept, and copies that agree or fork. The RID is a
self-certifying name derived from a first record, as the name of a work is
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

### Owners and archives

A Radicle node is an identity, a key, and a repository is stored by its RID
with a namespace per peer; nothing in a repository says where it is kept. The
proposal took the same separation.

**Today** (section 6.2 of the specification), an archive is named by an
archive identifier, a URI that does not change when the archive moves. It
SHOULD be a `tag:` URI (RFC 4151), built from a domain or e-mail address the
owner controlled at the time, a date and a name, such as
`tag:opensheaf.org,2026:mgubi`; a DOI or another persistent URI MAY be used
instead. Uniqueness is a rule ("Two different archives MUST NOT use the same
archive identifier") that nothing checks: anyone can claim any `tag:`. The
archive is also the writer of its objects.

**In the proposal** (#55, #52, PR #56):

- an **owner** is a keyed identity (a person, a group, an institution), named
  by the digest of its own genesis record, whose versions are its **key log**:
  each version lists the owner's keys and a threshold, and is signed by the
  threshold of the keys before it, so keys rotate while the name stays;
- every version of an owner's lines is signed, and the key logs travel with
  the objects they sign, so any copy can be checked without its archive;
- an **archive** is a host, with no identity of its own: it keeps the lines of
  many owners, and copies of others, in one storage root at
  `<owner>/<name>/`, and is found at its base URL, a hint like every location;
- an owner that moves to another archive copies its key log there and
  continues its lines; only a change of owner makes a branch.

| | Radicle | OpenSheaf today | the proposal |
|---|---|---|---|
| who writes | a node, its key | the archive | an owner, its key log |
| name of the writer | the Node ID, the key itself | the archive identifier, a chosen `tag:` | the digest of the owner's genesis record |
| rotation of keys | none: a new key is a new identity | not applicable | a new version of the key log |
| several people | delegates and a threshold, per repository | the archive's own rules | the threshold of the owner's key log |
| storage | one repository per RID, a namespace per peer | one storage root per archive, chosen identifiers | one storage root per archive, `<owner>/<name>/` |
| where | announcements, never in the identity document | the base URL, and the archive identifier for the archive | locations are unsigned hints |
| uniqueness of names | no nonce (section 2.9) | a rule, not checked | a random nonce; signatures decide reuse |

What the proposal took from Radicle: the writer is an identity made of keys,
not a place; storage is keyed by digests, so copies from anywhere sit side by
side; the identity says who, never where; a fork is a namespace of its own.
What it does differently: keys rotate through a key log rather than being the
identity; names are SHA-256 digests of records with a nonce; and everything
is plain files on a static website.

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
    differ from those of the proposal, and an object could not move to a plain
    archive without a second name (the problem of issue #20, two names for
    one object).
  - The transport is being replaced by an incompatible one (section 2.7):
    building on it now means following a moving protocol.

This design is not recommended. It would trade the format's independence for
features that the proposal specifies in plain files.

### 4.3 Radicle as a source of designs

OpenSheaf keeps its files and its digests, and borrows designs that Radicle
has tested. Each is described in Radicle's terms, then in OpenSheaf's.

#### A namespace per owner

**In Radicle.** A project is one git repository. Inside it, each peer has a
namespace named by its key, and only that peer writes there: Alice's branches
are under `refs/namespaces/<alice>/`, Bob's under `refs/namespaces/<bob>/`.
The files are stored once and shared by all namespaces.

**In OpenSheaf.** Adopted by the proposal (#52, PR #56). The OCFL identifier
of an object is its line, (name, owner), and the default layout stores it at
`<owner>/<name>/`:

```
ocfl/
  <owner A>/
    <owner A>/      A's key log, the owner object
    <name 1>/       A's line of work 1
  <owner B>/
    <owner B>/
    <name 1>/       B's branch of work 1
```

Two lines never share an identifier, so an archive keeps its owners' lines and
the copies it holds in one storage root without clashes, as a Radicle
repository keeps every peer's namespace. One folder holds everything an owner
has in the archive, its key log included, so an owner moving to another
archive copies one folder. Large archives use the hashed layout instead.

The grouping is by owner rather than by work, as in Radicle by peer rather
than by branch. The saving of space needs nothing more where the archive is
kept in git, which stores each file once across the repository; on plain file
systems, files shared by a branch and its parent are stored twice.

Every branch is a new object (PR #56). A deep branch, holding the parent's
earlier versions byte for byte, would carry the parent's OCFL identifier in
those versions' inventories, and so could not be the branch owner's object;
keeping the parent's history means keeping a copy of the parent's line beside
the branch, as a Radicle fork keeps its own namespace and the parent's is
replicated beside it.

#### Delegates and a threshold

**In Radicle.** The identity document lists keys, the delegates, and a
threshold, for instance 2 of 3. The canonical state of the default branch is
the commit that at least 2 delegates have. A change of the document, adding
or removing a delegate, also needs the signatures of 2 current delegates. The
name of the repository is the digest of the first document, so it does not
change.

**In OpenSheaf.** Adopted by the proposal, one level up: the keys and the
threshold belong to an owner's key log, not to each line (#55, question 1;
issue [#53](https://github.com/opensheaf/opensheaf.github.io/issues/53),
closed). Co-authors who want to own their work together create one owner
whose key log lists their keys, with a threshold, for instance 2 of 3; every
version of their lines, and every change of their keys, then needs that many
signatures. Adding a co-author, or replacing a lost key, is a new version of
the key log. A person sets a threshold of 1, with a spare key kept apart.

The cost is that a verifier replays the owner's key log to check each
signature against the key-log version it names; the key log is small and
linear, and travels with the objects it signs.

#### Signed references: not needed

**In Radicle.** Each time a peer's branches change, its node signs the whole
list, each branch with its commit, as one statement. Whoever delivers a
copy, a reader can check that it is exactly what the peer published.

**In OpenSheaf.** The nearest counterpart would be a signed discovery
document, and it is not needed, because the history of an object is linear.
Radicle signs its references because git references are mutable: a branch
can be moved to any commit, rewritten or deleted, and a peer has many of
them, so only the peer's signature says which state is its own. An OpenSheaf
object only grows: each version's inventory fixes every version before it,
and a line has one writer (the proposal). Of two copies of an object, either one
is a prefix of the other, and the longer is simply more recent, or they
diverge, which is a fork and is detected without any signature. The
discovery document says nothing that cannot be checked: it is "a map, not a
witness" (section 6.1), and every head and digest it states is verified
against the storage root. Who made a version is answered for each version,
by its owner's signature in the proposal, or by witnesses (section 13.2), not by
signing the map.

What linearity does not give is freshness: a copy that stops at an older
version looks, by itself, like a complete one. A signed map does not give it
either, since an old map stays validly signed; a reader who needs the latest
version asks the archive itself, or compares copies and keeps the longest.

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

**In OpenSheaf.** Today a mirror is decided object by object.
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
specification. The question is open in issue
[#54](https://github.com/opensheaf/opensheaf.github.io/issues/54).

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
public network is evidence that the design of the proposal is practicable. It is
also evidence of the costs: a protocol whose nodes must run, a storage that
users must not touch, SHA-1, and a transport that had to be replaced after two
years.

On names, Radicle supports the choices of the proposal by what it lacks
(section 2.9). A RID made from a first document without a nonce repeats when
the same owner describes two repositories alike; a collision, accidental or
crafted, merges two repositories with nothing to detect it. The proposal draws
a random nonce for every genesis record, uses SHA-256, accepts a genesis
record already held only when the originator's signatures or a branch's
parent evidence hold, and keeps further names, by algorithm number, for a
clash (issue [#44](https://github.com/opensheaf/opensheaf.github.io/issues/44)).

On owners, the proposal follows Radicle where it works and departs from it
where it falls short (section 3, "Owners and archives"): an identity made of
keys, storage keyed by digests, identities that say who and never where, forks
as namespaces of their own; but keys that rotate through a key log, and plain
files on a static website.

OpenSheaf should not be built on Radicle (section 4.2). An archive kept in git
may be published on Radicle as one more copy (section 4.1). The designs of
section 4.3 have been weighed: a namespace per owner and delegates with a
threshold were adopted (PR #56); custody policies are issue #54, announcements
for indexes issue #20, encryption for private archives issue #29. One is not
needed: Radicle signs its references because they are mutable, while the
history of an OpenSheaf object is linear and checkable without them.

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
   inventories, and the names of the proposal.
4. **Key logs in practice.** Create an owner with two keys and a threshold
   of 1, sign versions, retire a key and end the owner with a successor,
   then verify every version from a copy of the archive without its site,
   and measure what a verifier replays.

## 7. Open questions

- Does Radicle's new transport (iroh) change what it offers to archives, for
  example reading over HTTP without a Radicle node?
- Will Radicle adopt SHA-256 repositories when git does?
- Should the deployment note recommend Radicle, or only mention it, as one
  way to keep copies of an archive in git?
- Is one threshold, for key changes and for publishing alike, enough, or will
  owners want a separate threshold for each (#55)?

## References

- Radicle: <https://radicle.xyz> (now also <https://radicle.dev>).
- The proposal: PR #30, as revised by PR #56; issues #52 and #55.
- Radicle Protocol Guide: <https://radicle.dev/guides/protocol>.
- Radicle Seeder Guide: <https://radicle.dev/guides/seeder>.
- Radicle 1.0.0, 10 September 2024:
  <https://radicle.dev/2024/09/10/radicle-1.0.0>.
- Disclosure of vulnerability in the network protocol, 23 September 2026:
  <https://radicle.dev/2026/09/23/disclosure-of-vulnerability-in-network-protocol.html>.
- Radicle at FOSDEM 2026:
  <https://fosdem.org/2026/schedule/event/TMQZTP-radicle>.
- Heartwood, the reference implementation (GitHub mirror):
  <https://github.com/radicle-dev/heartwood>.
- The Update Framework: <https://theupdateframework.io>.
- iroh: <https://www.iroh.computer>.
