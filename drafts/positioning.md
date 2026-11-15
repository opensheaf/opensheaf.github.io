# OpenSheaf as a transport layer for scholarly communication

*Working paper, draft of 15 November 2026. Non-normative: ideas and
positions, not decisions. Scholarly communication bundles several
functions: archiving, announcing, filtering, distributing and assigning
merit. Preprint servers and publishers each hold a bundle of them, and the
function that authors cannot do without tends to bring the others with it.
This paper separates
the functions, shows which of them OpenSheaf carries and which it leaves to
others, and argues that OpenSheaf is best understood as a transport layer:
a common way to fix, name, keep and point at scholarly documents, on which
announcement, filtering and evaluation can be built by anyone, separately,
and composed; preservation too, by federations of institutions that keep
copies of the archives at the edge. It then compares OpenSheaf with
federated and distributed systems (Mastodon and ActivityPub, Bluesky and
the AT Protocol, Nostr, IPFS, distributed hash tables, git, OAI-PMH,
LOCKSS, notification protocols such as COAR Notify, COAR's Pubfair,
DOI registries), weighs what unbundling costs (money, abuse, rights,
anonymity), and lists ideas and open questions.*

## 1. The functions

A classic analysis of scientific communication (Roosendaal and Geurts,
1997) distinguishes registration, awareness, certification and archiving;
Van de Sompel and others (2004) add rewarding. We use a slightly different
division, closer to what the actors of today actually do:

- <dfn>Archive</dfn>. Keep the work, every version of it, unchanged, for a
  long time; give it a stable name, so that it can be cited; record when it
  appeared, which also establishes priority.
- <dfn>Announce</dfn>. Tell the community that something new exists. For
  many mathematicians, the daily listings of arXiv are the main source of
  scientific news: one reads the new submissions in one's subjects every
  morning, as one would read a newspaper. Mailing lists, seminars and, more
  and more, social networks play the same part.
- <dfn>Filter</dfn>. Select, out of everything announced, what deserves
  attention, and vouch for it: refereeing, editorial choice, reviews,
  reading lists. Journals are filters and aggregators: by gathering papers
  under a name and a standard, they focus the attention of a community on
  a manageable set of works.
- <dfn>Distribute</dfn>. Deliver the files to readers, in usable forms,
  and make them findable: hosting, mirrors, indexes, search, formats.
- <dfn>Assign merit</dfn>. Turn the record into credit for its authors:
  where a paper was published, who reviewed it and what they said, who
  cites it. Hiring, promotion and funding rely on these signals, mostly on
  the name of the journal.

Announcing and distributing both bring documents to readers, but at
different moments: announcing reaches readers when something appears,
distributing serves them when they look for it.

The functions are distinct. Archiving needs permanence and fixity;
announcing needs speed; filtering needs judgement and a community that
trusts it; distributing needs bandwidth and formats; assigning merit needs
evidence that others can check. They have different costs, different
time scales and different people doing them.

## 2. How the functions are bundled today

The actors of scholarly communication each carry a bundle of functions:

| Actor | Archive | Announce | Filter | Distribute | Merit |
|---|---|---|---|---|---|
| arXiv | yes, with a date that establishes priority | yes, the daily listings | moderation only | yes | little |
| A journal and its publisher | the version of record | weak (tables of contents, alerts) | yes, refereeing | yes, often behind a paywall | yes, the main signal |
| An overlay journal (Discrete Analysis, the journals of Episciences) | relies on arXiv | weak | yes | relies on arXiv | yes |
| Peer Community In | relies on preprint servers | weak | yes, recommendations | relies on preprint servers | some |
| An institutional repository | yes | no | no | yes | reporting to the institution |
| Zenodo | yes, with DOIs | no | no | yes | citations through DOIs |
| zbMATH Open, Mathematical Reviews | no | partly | reviews | indexes | yes |
| Google Scholar | no | alerts | ranking | search | citation counts |

Three things follow from the table.

**Bundling gives control.** A publisher that holds the filter, which
authors need for merit, also obtains the archive and the distribution: the
transfer of copyright, or the exclusive licence, that often comes with
acceptance moves the version of record behind its platform. The function
that authors cannot do without carries the others with it.

**The unbundled actors already exist.** Overlay journals and Peer
Community In show that filtering can live apart from archiving and
distribution: they vet documents that stay where their authors put them.
Their weak point is that they rest on someone else's archive, arXiv or a
preprint server, which they do not control and which does not know about
them: a selection of arXiv papers is a list of links, not a verifiable
record of which version was vetted.

**Each function has a single place.** The arXiv listings are the
announcement channel of whole disciplines, and journals are the merit
system; arXiv is one organisation, and much of journal publishing is in
the hands of a few publishers. There is no common format in
which an announcement, a selection or a review could be made by someone
else, over the same documents, and checked by anyone.

## 3. OpenSheaf as a transport layer

In a network, the <dfn>transport layer</dfn> moves data between endpoints
with integrity, and says nothing about what the data means: mail, the web
and video calls are applications built on it, by different people,
competing and composing. OpenSheaf aims at the same position for
scholarly documents. It defines:

- how a version of a document is **fixed**: object versions in OCFL, every
  file covered by a SHA-512 inventory, nothing ever changed once
  deposited;
- how it is **named**: the pair (archive identifier, object identifier),
  and the document version, independent of where the files are served;
- how it is **found**: the discovery document of an archive, and its feed
  of new object versions;
- how it is **kept**: archives and mirrors, any copy being valid when its
  bytes match the pin;
- how statements about documents are **expressed**: collections, which
  are themselves versioned objects pinning their members by digest,
  across archives; catalogues that keep objects whole, and selections that
  vet particular revisions.

It does not define who announces, who filters, or how merit is counted.
These become applications on top of the layer: anyone can build them,
several can exist over the same documents, and each of their statements is
an object that can be cited and verified as it stood.

### Archive

This is what OpenSheaf carries most directly. An archive is kept by its
owner, as plain files on any static web server, in a layout used by
research libraries for long-term preservation (OCFL). Every version of
every document is fixed, with its sources (or a statement that they are
missing); corrections, notices and
withdrawals are new versions, and the history can be checked from the
files alone. Custody can be shared: mirrors keep byte-for-byte copies of
whole objects, and a pin says which copy is right. External deposits
(Zenodo) and software archives (Software Heritage) keep further copies, but
a Zenodo record holds the content files without the inventory, so it cannot
yet be checked against a pin (issue #22). What
OpenSheaf does not give is a guarantee that someone keeps the files: that
is a matter of institutions, and of the next layer.

### Preserve: federated archiving on top

Preservation can be built on the layer like the other functions:
<dfn>federated archiving</dfn>. Institutions (libraries, universities,
learned societies) run networks of archives, peer to peer, that keep
copies of what the leaves hold: the personal and group archives at the
edge of the network, which come and go. A federation is a consortium of
peers that trust one another, academic institutions or communities with
other means of establishing a minimum of real-world trust; joining it is
a social act, as in LOCKSS, not an open protocol. When a leaf disappears
(a domain lapses, an author dies, a hosting service closes), its objects
can still be resolved, from the copies the network holds, and the pins in
every collection still say which copies are right. Custody is shared
between the author, who keeps the archive and is its single writer, and
the federation, which keeps it alive.

The format already has most of the parts. A mirror is a byte-for-byte
copy of a whole object, updated only by copying the original's versions,
and an archive's list of mirrored objects is a catalogue; a preservation
node is an archive whose objects are mirrors. Resolution (section 6.4 of
the specification) tries the mirrors listed in a collection member, then
those listed in the archive's discovery document. Three things are
missing:

- **Finding the network when the leaf is gone.** The leaf's discovery
  document, with its list of mirrors, disappears with it; a member lists
  mirrors only if its curator recorded them. A federation needs its own
  way to be asked: a registry, a well-known address per network, or a DHT
  from archive identifiers and inventory digests to the copies it holds
  (section 4, and issues #14, #20).
- **What may be copied.** A mirror is allowed only if the licences of
  all the versions copied allow redistribution. Licences belong to
  versions, but pins and storage belong to histories (a pin fixes every
  earlier version, and later versions reuse the stored files of earlier
  ones), so an object whose versions have different licences is hard to
  copy. A simple rule for now is to mirror only objects with one
  standard licence: every version copied states the same licence, by its
  SPDX identifier, from a list of licences that allow verbatim
  redistribution (CC0 and the Creative Commons licences); a mirror stops
  at the last version that keeps the rule. It can be checked from the
  files, and needs no legal reading (issue #34). What may not be served
  can still be kept as a dark copy, under an agreement with the author,
  released only after a trigger such as the leaf being gone for good, as
  CLOCKSS does for journals; that is an agreement of the federation, not
  a state of the format (#13).
- **Takedowns.** When a leaf takes a document down for legal reasons, its
  copies in the federation must follow, or resolution falls through to
  them (#33).

Federated archiving keeps the rest of the design as it is: the leaves
stay static files, authors stay the single writers of their objects, and
any copy, from any node, is checked by the same pins. It is LOCKSS for
documents that are named and versioned at the edge.

### Resolution through the federation

The same network can resolve as well as keep. Nodes contact one another
for the objects they exchange, and can exchange resolution information
with them: which archives they know, where those archives are now, which
nodes hold which objects up to which version. A reader, or a verifier,
can then ask any node for an object whose archive is unreachable, and
the network answers with copies that the pins check.

Integrity is not the difficulty: a pin checks every byte, whichever node
supplied it. The difficulty is everything a pin does not fix: where
things are, what is current, what was removed, and who an archive is.
Content is self-certifying; state is not. In a federation of trusted
peers, false nodes are not a concern, but these remain:

- **Freshness.** Pinned members are safe, but whatever follows the latest
  version, and whoever asks for the current version, depends on the last
  discovery document a node has seen. A node with an old one hides newer
  versions, notices and withdrawals, and a withdrawal that never arrives
  looks like none. Inventories help in part: a newer inventory lists all
  earlier versions, so going back is visible once a newer one has been
  seen.
- **Removals spread badly.** Additions travel well between nodes;
  withdrawals, tombstones and takedowns must reach every node that holds
  a copy, or a node that missed one brings the object back (#33).
- **Authority after the leaf.** The archive is the single writer of its
  objects. If it is unreachable for a while, nodes may hold different
  heads; if it is gone, nobody may add versions; and if its author
  starts again elsewhere, or someone else claims the same archive
  identifier, nothing in today's `tag:` identifiers tells a continuation
  from an impostor (#13, #20).
- **Answers depend on the node.** Nodes keep different subsets, so
  "unavailable" may mean only "unknown to this node", and two verifiers
  may report the same collection differently, unless a report says where
  it was made, or the federation guarantees what each node holds.
- **Privacy.** Resolution queries tell nodes what is being read, and
  exchanging holdings tells the federation what each member keeps.
- **Browsers.** The Explorer and readers speak HTTP, not a peer-to-peer
  protocol, so HTTP gateways would become new central points, unless
  they are untrusted: they return records and pins that the client
  checks.
- **The protocol stays outside the core.** The nodes run software and
  speak a protocol, with its own specification and versions; the format
  must not come to depend on it, or OpenSheaf would need the network it
  was meant to do without.

Trust between institutions is not trust in their servers: a compromised
or misconfigured node of a trusted member still spreads stale or wrong
state. The common answer to all of this is that state be stated by the
archive itself: heads, moves and tombstones as records signed with keys
bound to the archive identifier, ordered by sequence numbers or
timestamps, and spread on purpose. In a trusted federation these
signatures guard against accidents and intrusions rather than enemies,
but they are what makes resolution through the network sound. They lead
back to the open questions of keys and self-certifying names (#13, #20)
before any federation protocol.

Keys need not wait for a new infrastructure of identity: researchers
already have one, ORCID, which the descriptions of documents name for
their authors (`creators` in `datacite.json`). ORCID holds no keys and
signs nothing for its users, but an author can publish a public key on
their own ORCID record, as one of the links they edit themselves (for
instance the key's address on a key server), and the key can name the
iD in return. A verifier then reads the public record, finds the key,
and checks the signatures of the object versions (the witnesses of the
specification) with it: the authors of a document, named by their iDs,
become the people who can be shown to have deposited it, wherever its
copies are. Two limits: the record shows the binding now, not at the
time of signing, so the first binding is best kept as a timestamped
snapshot of the record with the witnesses; and the link proves only what
the holder of the ORCID account published. ORCID's own signed login
tokens, which can carry the digest of an inventory, can witness that the
holder of an iD approved a deposit at a given time, without any key for
the author to manage; they rest on ORCID's signature and keys, which
must be kept to check them later (issue #13).

### Announce

The specification provides the raw material: each archive MAY publish a
feed of its new object versions, and a catalogue that follows its members
records, version by version, what was added. An announcement service is
then an aggregator of feeds: it reads the feeds of many archives, groups
the new document versions by subject (from the DataCite `subjects` of each
version, for instance the Mathematics Subject Classification), and
publishes daily listings, as arXiv does. Such a listing can itself be a
catalogue, and so a citable record of what was announced on a given day.

None of this needs a central archive. It needs feeds, a common way to state
subjects, and someone to run the aggregator, which can be run by several
communities, each with its own subjects and its own moderation. The scale
of an arXiv-sized aggregation is an open question (issue #19).

### Filter

Selections are filters. An overlay journal, a digest, a reading list, a
review journal or a seminar's programme is a selection: each member pins
the revision that was vetted, later versions by the authors are not part
of it, and any change of what is vetted is an act of the curator, recorded
as a new version of the selection. A selection that wants to keep the
files it vetted keeps an accepted copy; a journal that typesets and
publishes its own version deposits it as a document of its own archive,
related to the authors' version. The [use cases](../USE-CASES.md) describe
these in detail, including peer review from a private submission to a
published record (issue #29).

Because a selection pins by digest, it is not a list of links: it says
exactly which bytes were vetted, and anyone can check that they have not
changed. Because collections are objects, they nest: a catalogue of a
journal's issues, a catalogue of the overlay journals of a field.
(Selections, in the specification, vet revisions of documents; whether a
selection may vet another collection is not said.) Several filters can
work on the same documents without copying them, and without the authors'
archives knowing about them: a document never states the collections that
include it.

### Distribute

Archives are static websites: any web server distributes them, and any
mirror can stand in. The website profile gives every document a landing
page that search engines read (Google Scholar); the Zenodo profile gives
it a DOI; the OpenSheaf Explorer reads and verifies any archive in the
browser. Distribution is the function that needs least from OpenSheaf,
which only asks that files be served byte for byte and readable from other
sites. Search across archives is not part of the format; it is an
application, like announcement, and needs aggregation (section 6).

### Assign merit

OpenSheaf does not count anything. It makes the evidence on which merit is
assigned explicit and verifiable: who deposited which version and when
(the inventory); which selections vetted which revision, and when (the
versions of each selection); what the referees said, when reviews are
published as documents of their own (`PeerReview`); how documents relate,
through DataCite relations. A record of this kind can be checked by anyone
from the files, instead of being taken on the word of a platform.

Two cautions. First, the reverse question (which selections include a
given document?) cannot be answered from the document, which does not
state it: it needs an index over many archives, which is again an
aggregation service. Crossref's Event Data, which records where DOIs are
mentioned, is an example of such an index for another layer. Second,
making evidence easy to collect makes it easy to count; a format should
not invent metrics, and this one does not.

### What the layer leaves out

On purpose: search and ranking, the identity of persons (left to ORCID and
DataCite), moderation of announcement channels, payment, and the hosting
itself. Each of these is a service that can be run on the layer by
someone who takes responsibility for it.

## 4. Federated and distributed systems

OpenSheaf is one of many attempts to replace a central service by a
network of independent parties. The comparison shows what it borrows, what
it does differently, and what it might reuse.

### Mastodon and ActivityPub

Mastodon is a federation of servers speaking ActivityPub, a W3C
Recommendation (2018). Each user has an account on one server; servers
push activities (posts, replies, boosts) to the servers of the followers;
each server moderates its own users and chooses which servers it talks
to.

- **Similar.** No central service; anyone can run a node; communities set
  their own rules, as selections and announcement services would.
- **Different.** ActivityPub delivers by push and needs a running server
  for every node; an OpenSheaf archive is static files, read by pull, and
  needs no software to be served. A post can be edited or deleted and its
  author's identity is bound to the server's domain; an OpenSheaf version
  never changes, its integrity is checked by digest, and its archive
  identifier does not change when the archive moves.
- **To reuse.** ActivityPub is a good announcement channel, which OpenSheaf
  does not try to be. A bridge that turns an archive's feed into
  ActivityPub posts would let researchers follow archives, or announcement
  services, from the networks they already read.

### Bluesky and the AT Protocol

The AT Protocol separates roles that Mastodon keeps together: each user's
data is a signed repository of records, hosted by a server the user can
leave; relays crawl the repositories and produce a stream of everything;
application views and custom feeds build what readers see from that
stream. Identity is a decentralised identifier (DID), portable across
hosts.

- **Similar.** This is the closest analogue. A user's repository is an
  archive; a relay is an aggregator of feeds; a custom feed is a filter,
  built by anyone over the same data. The separation of keeping, relaying
  and presenting is the separation of archive, announce and filter argued
  for in section 3.
- **Different.** An AT repository is a mutable set of small records,
  signed as a whole at each change; an OpenSheaf archive holds large
  documents in append-only versions, each fixed by its own inventory.
  Portable, self-certifying identity is designed in from the start there,
  and still open here (issues #13, #20).
- **To reuse.** The role of the relay, and the idea that feeds are built by
  third parties over a shared stream, describe well the announcement and
  index services that OpenSheaf needs.

### Nostr

Nostr reduces federation to signed events and simple relays that store and
forward them; the client holds the user's key and chooses the relays.
Identity is the key itself. It shows how little a relay needs to know, and
how much robustness comes from signing at the source; OpenSheaf's
witnesses (signatures and timestamps of inventories) play that part for
documents, without making a key the identity of an archive.

### IPFS and content addressing

IPFS names content by its hash and fetches it from whoever has it. Pins
in OpenSheaf rest on the same idea, that the right copy is the one whose
digest matches, wherever it comes from. Two differences matter. A content
address fixes one file or tree; an OpenSheaf pin fixes an object version
and, through its inventory, all the versions before it, together with a
name and a history. And content addressing alone does not keep anything
available: someone must hold the bytes. The words collide too: to *pin* in
IPFS means to keep content available on a node, while a pin in OpenSheaf
is a reference fixed by a digest, and keeps nothing.

### Distributed hash tables

A distributed hash table (DHT), such as Kademlia in BitTorrent and IPFS,
is a lookup service run by peers: given a key, usually a hash, the network
routes the query to the nodes that hold the value or know who does. It
answers a question that OpenSheaf does not ask. A pin carries no address:
it says whether a copy is right, not where to find one. OpenSheaf finds
documents from a name and a location (the archive's address in a
collection member, its discovery document, its list of mirrors), and uses
the digest only to check what it found. A DHT is exactly the missing
"where".

The two also differ in custody. In a DHT, data stays reachable while some
peer chooses to serve it, and records expire unless they are published
again; in OpenSheaf an archive keeps its objects, and mirrors are kept by
named parties. A DHT needs nodes that are always online; an archive needs
only a static web server. Mutable data in a DHT are records signed with a
key (IPNS in IPFS, BEP 44 in BitTorrent); in OpenSheaf the mutable map is
the discovery document, served by the archive itself. A DHT has weak
points of its own: routing can be attacked by many fake nodes (Sybil and
eclipse attacks), which hashes do not prevent, and queries tell the
network what its users read.

A DHT could still serve OpenSheaf as an optional resolver, a further step
when an archive's own address fails, like the external copies of section
6.4 of the specification: from the digest of an inventory to the copies
that match it (issues #20, #22), and from an archive identifier to its
current base URL, as a record signed by the archive, so that an archive
can move without a registry (issues #13, #14). The format would stay as it
is; the pins would still check whatever the DHT returned, and custody
would still rest with archives and mirrors.

### Git, forges and Software Heritage

Git is the most successful distributed system for versioned work: every
clone is complete, commits are linked by hashes, and forges add
collaboration on top. Many archives will be kept in git, and Software
Heritage archives public repositories with intrinsic identifiers. But git
hashes are SHA-1 in most repositories and its layout is internal to git;
OpenSheaf uses git as a convenient store and transport, and keeps its
integrity in OCFL inventories (see the [FAQ](../FAQ.md)). A Software
Heritage snapshot of an archive is a further witness.

### OAI-PMH and harvesting

Institutional repositories already form a network: they expose their
metadata through OAI-PMH, and aggregators (BASE, CORE, OpenAIRE) harvest
it. The discovery document and the feed of an OpenSheaf archive play the
same part, with three additions: the content is fixed and verifiable, not
only the metadata; versions are explicit; and collections across archives
are part of the format, not a feature of an aggregator.

### LOCKSS

LOCKSS (Lots Of Copies Keep Stuff Safe) is a network of libraries that
keep copies of the same content and compare them to repair damage; CLOCKSS,
built on it, keeps dark copies of journals, released only when a publisher
stops providing them. It is the model for federated archiving on top of
OpenSheaf (section 3): mirrors are copies kept by other parties, and pins
let anyone tell a good copy from a damaged one, without the nodes having
to compare their copies with one another.

### Notification protocols

A family of web protocols carries messages between the parties that a
federation of documents needs, and their use falls on the services built
on the layer rather than on the archives: a static archive can be read,
but cannot receive anything.

- **Announcing.** WebSub (W3C, 2018) lets a hub push the updates of a
  feed to its subscribers: an archive stays static, names a hub in its
  Atom feed, and aggregators learn of new versions without polling.
  ActivityPub, as above, lets an archive or an announcement service be an
  actor that people follow.
- **Notices between parties.** Linked Data Notifications (W3C, 2017)
  define an inbox, declared by a resource, to which others post notices
  about it; Webmention does the same, more simply, for links between
  pages. They answer the reverse question that a document cannot answer
  about itself (which selections include it, who reviewed it) without
  breaking the rule that a document never states the collections that
  include it: the selection sends a notice to the document's archive, and
  the notices are kept outside the objects.
- **COAR Notify.** The Confederation of Open Access Repositories builds on
  Linked Data Notifications and the ActivityStreams 2.0 vocabulary a
  protocol (version 1.0.1) that connects repositories with the services
  that review and endorse what they hold. Its patterns are requests
  (*Request Review*, *Request Endorsement*), acknowledgements (accept,
  reject), and announcements (*Announce Review*, *Announce Endorsement*,
  *Announce Relationship*): a repository offers a preprint to a review
  service, and the service announces the review back, naming the
  reviewed resource in the notice's `context`. Repository platforms
  (DSpace, EPrints, Dataverse, HAL), preprint servers (bioRxiv,
  Preprints.org, SciELO Preprints) and review and overlay services (Peer
  Community In, Episciences, PREreview, Sciety) implement it. It is the
  unbundling of section 2, already at work between filters and archives,
  and the protocol to follow rather than to reinvent.

What OpenSheaf can add is integrity. A COAR Notify notice identifies
resources by URI (a landing page, a DOI as `cite-as`), with no digest and
no signature: it says that a review exists of "the resource at this
page", not of which bytes. With OpenSheaf, the object of a notice can be
a pin (the reviewed revision, and the version of the selection that
includes it), so that whoever receives the notice can check it against
the files, and the notice stops being only a claim. Two things would be
needed outside the core: a way for an archive to name its inbox (in the
discovery document, as it names a `contact`; the inbox can be run
elsewhere, since the archive itself is static), and a convention for
writing pins in COAR Notify payloads, which may wait for global names
(issue #14). WebFinger, which turns a handle such as
`@alice@example.org` into links, could give archives handles too, but
handles bound to a domain do not solve naming (#14).

### COAR's repository model: Pubfair

The closest relative of this paper's argument comes from the repository
community. COAR's Next Generation Repositories (2017) set out a vision of
repositories as a distributed network with services built on top, and
the white paper *Pubfair* (Ross-Hellauer, Fecher, Shearer and Rodrigues,
2019) made it a framework for open publishing: a modular, open-source
publishing layer over a distributed network of repositories, which hold
the research outputs while separate services review, curate and
disseminate them. It is the same unbundling as in section 2: archives
apart from filters, joined by protocols. Pubfair itself is a conceptual
model, not software; it is being carried out through COAR Notify (above),
launched in 2021 and developed since with dedicated funding, with working
implementations such as the review of HAL's preprints by Episciences
journals. The model is often called "publish, review, curate".

OpenSheaf agrees with this model and differs in what it assumes about
the archives:

- **Who keeps them.** Pubfair's archives are institutional repositories,
  running platforms such as DSpace or EPrints. OpenSheaf's can be kept by
  authors and groups themselves, as static files, with institutions as
  custodians and preservation nodes (section 3).
- **What is kept.** A repository holds deposits and their metadata, with
  versions as the platform allows. An OpenSheaf archive holds every
  version of a document, with its sources, fixed by digests and
  verifiable by anyone from the files.
- **What statements fix.** In Pubfair, a review or an endorsement refers
  to a resource by its address or DOI. In OpenSheaf, a selection pins the
  bytes it vetted, across archives, and is itself a versioned object.

The two fit together: an OpenSheaf archive can be a repository in COAR's
network, with an inbox run beside it, and COAR Notify can carry, with
pins, the notices between OpenSheaf archives and the services that
review and select. Repositories can also be the institutional custodians
of section 3. The repository community is where institutions and review
services already are, and joining its protocols is the way for OpenSheaf
to be adopted rather than to compete.

### DOI registries

Crossref and DataCite register DOIs: persistent names, resolved through
the Handle system to wherever the publisher or repository says the work
is, with metadata deposited by their members. They are central
registries, run by membership organisations, and they are what everyone
already cites. A DOI says where a work is and what it is called; it does
not fix the bytes, since it resolves to a landing page that may change.
OpenSheaf uses DataCite's metadata as its description, and a document may
receive a DOI (the Zenodo profile, and the open question of an archive's
own prefix, issue #8); the pin then says which bytes the DOI's work is.

### Summary

| System | Unit | Changes | Delivery | Needs a server | Integrity | Identity |
|---|---|---|---|---|---|---|
| ActivityPub (Mastodon) | post | editable, deletable | push | yes | the server's | account at a domain |
| AT Protocol (Bluesky) | record in a repository | mutable, signed | relays | yes (host, relay) | signed repository | DID, portable |
| Nostr | signed event | fixed, some kinds replaceable | relays | relays | signature | key |
| IPFS | file or tree | new address per change | peer to peer | a node | content address | the hash |
| DHT (Kademlia) | key and value | records expire unless republished | routed lookup | online peers | the key, when it is a hash | the key |
| Git | commit | append, history rewritable | clone, pull | no | SHA-1 or SHA-256 chain | none of its own |
| OAI-PMH | metadata record | updated in place | harvest | yes | none | repository identifiers |
| DOI registries | registered work | metadata updated, target may move | resolution | yes (registry, resolver) | none | DOI |
| OpenSheaf | object version | append-only | pull, static files | a static web server only | SHA-512 inventories, pins | archive identifier and object identifier |

What sets OpenSheaf apart is the combination: append-only versions of
large documents, fixed by digests; names that survive a move; static
files that need no running software; and statements (collections) that are
themselves versioned, pinned objects. What it lacks, compared with the
social systems, is everything about attention: pushing news to readers,
following, replying. That is deliberate, and it is where bridges to those
systems would help.

## 5. What unbundling costs

Separating the functions is not free. Each bundle today also answers
questions that a layer of documents leaves open.

### Who pays

Each function has its own costs: storage and bandwidth for archiving and
distribution, editors' and referees' time for filtering, running
aggregators for announcement and indexes. Today they are paid together,
by subscriptions, publication charges, institutions and grants, and
cross-subsidised within each bundle. OpenSheaf makes the cheapest part
very cheap: an archive is static files, which a university, a free
hosting service or a git forge can serve at little or no cost. The other
functions still need people and money. A separate function can be funded
separately (a society runs a journal as a selection, a library runs an
announcement service for its field), but whether it will be is a question
of institutions, not of format. A risk to name: services that are free
today (forges, hosting) may change their terms, which is one more reason
for mirrors.

### Abuse and noise

A central service can refuse a submission; an open network cannot stop
anyone from publishing an archive. Spam, plagiarism, generated papers and
fake archives created to inflate one another's records will appear as
soon as there is something to gain. The layer offers some defences: every
version is fixed and dated, so copying is visible and priority can be
checked; selections and moderated catalogues are acts of named curators,
who answer for what they admit; witnesses (signatures, timestamps) bind
deposits to keys. But filtering abuse is a function of its own, and falls
to announcement services and selections, which must moderate, as arXiv's
moderators and journals' editors do now. Evidence for merit drawn from an
open network is only as good as the curators it counts.

### Rights, licences and takedowns

Distribution depends on rights. A reference (a pin) needs no permission,
but a mirror is allowed only if the licences of all versions allow
redistribution, and an accepted copy needs a licence or the authors'
agreement. Documents under restrictive licences can be archived and
pinned, but only their own archive may serve them. Takedowns are harder
in a network than in one place: when a document must be removed for legal
reasons, its archive deletes it and leaves a tombstone, but mirrors and
external copies may keep serving it, and resolution may fall through to
them (issue #33).

### Anonymity and review

Merit rests in part on peer review, and peer review usually rests on
anonymity: referees are not named to authors, and submissions are not
public before acceptance. A network of public archives fits public
records better than confidential ones. Private archives, the states of a
submission before it is public, and anonymous referees whose reports are
nevertheless kept and verifiable are discussed in issue #29; until they
are settled, a journal can keep its review process where it is today and
publish its decisions as selections.

## 6. Ideas and open questions

These are ideas, not plans; each would need an issue and agreement before
anything enters the specification.

- **Announcement services.** Daily listings by subject, built from feeds,
  run by communities, each a catalogue of what it announced. Needs a common
  way to state subjects (DataCite `subjects` with a classification scheme),
  a way to find feeds (a registry, or a catalogue of archives), and an
  answer to scale (#19).
- **Bridges to social networks.** An archive's feed, or an announcement
  service, posted to ActivityPub or the AT Protocol, so that researchers
  can follow archives where they already read. Replies and discussions stay
  there; what deserves to be kept can become a document of its own.
- **Moderated subject catalogues.** A community curates the catalogue of
  its subject, admitting documents, or whole archives through their main
  collections, as arXiv moderators admit submissions:
  moderation becomes an act of a curator, recorded in the versions of the
  catalogue.
- **Overlay journals without an external archive.** Selections over
  authors' own archives, with accepted copies when the journal wants to
  keep the version it published; review records as documents (#29).
- **Notices with pins.** Selections and reviewers notify the archives of
  the documents they include or review, with COAR Notify, and give the
  pin of what they vetted, so that the notice can be checked; archives
  name an inbox, run elsewhere if they are static. This builds the
  reverse index from the edge (section 4).
- **Evidence for merit.** The main collection of an author's archive,
  together with the
  selections that include its documents, is a verifiable record of a
  career. The reverse index (which selections include this document?)
  needs an index service over many archives; references and applications
  in general are discussed in #21.
- **Federated archiving.** Consortia of trusted institutions run
  peer-to-peer networks of preservation nodes that mirror the leaves and
  resolve them, so that objects stay resolvable when a leaf disappears
  (section 3). Open: how a network is found once the leaf is gone (a
  registry, or a DHT), signed heads and tombstones (#13, #20), mirroring
  only objects with one standard licence (#34), dark copies by agreement,
  who commits to keep what, and takedowns across the network (#33).
- **Identity.** Names that do not depend on a domain, and objects whose
  name can be checked from their content (#14, #20); a DHT as an optional
  resolver from digests and archive identifiers to locations (section 4);
  authors' keys published on their ORCID records, so that signed versions
  can be traced to the people named as their creators (section 3, #13).
- **Adoption.** OpenSheaf works alongside existing services: a document can
  be on arXiv (`IsIdenticalTo`), have a DOI, and be found by Google
  Scholar; `osheaf arxiv import` brings an author's arXiv papers into an
  archive. The first step for an author costs little and changes nothing
  else.

Open questions for this paper:

- Is "transport layer" the right image, or does it undersell the
  collections, which already carry filtering?
- Which function should be demonstrated first beyond archiving:
  announcement (an aggregator of feeds) or filtering (an overlay journal on
  authors' archives)?
- How much of attention (following, notifications, discussion) should be
  left entirely to other networks, and how much should be bridged?

## References

- Roosendaal, H. E. and Geurts, P. A. Th. M., *Forces and functions in
  scientific communication: an analysis of their interplay*, internal
  paper, University of Twente, 1997.
- Van de Sompel, H., Payette, S., Erickson, J., Lagoze, C. and Warner, S.,
  *Rethinking scholarly communication: building the system that scholars
  deserve*, D-Lib Magazine 10 (9), September 2004:
  <https://dlib.org/dlib/september04/vandesompel/09vandesompel.html>.
- arXiv: <https://arxiv.org>.
- Discrete Analysis, an arXiv overlay journal:
  <https://discreteanalysisjournal.com>.
- Episciences, a platform of overlay journals:
  <https://www.episciences.org>.
- Peer Community In: <https://peercommunityin.org>.
- COAR Notify, version 1.0.1: <https://coar-notify.net>.
- Ross-Hellauer, T., Fecher, B., Shearer, K. and Rodrigues, E.,
  *Pubfair: a framework for sustainable, distributed, open science
  publishing services*, COAR, 2019 (second version, November 2019).
- Linked Data Notifications, W3C Recommendation, 2017:
  <https://www.w3.org/TR/ldn/>.
- WebSub, W3C Recommendation, 2018: <https://www.w3.org/TR/websub/>.
- ActivityPub, W3C Recommendation, 2018:
  <https://www.w3.org/TR/activitypub/>.
- AT Protocol: <https://atproto.com>.
- Nostr: <https://github.com/nostr-protocol/nips>.
- IPFS: <https://ipfs.tech>.
- Software Heritage: <https://www.softwareheritage.org>.
- OAI-PMH: <https://www.openarchives.org/pmh/>.
- LOCKSS: <https://www.lockss.org>.
- The OpenSheaf [specification](../opensheaf-specification-0.1.md),
  [FAQ](../FAQ.md) and [use cases](../USE-CASES.md).
