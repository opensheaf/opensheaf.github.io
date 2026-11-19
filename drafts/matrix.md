# Matrix and OpenSheaf

*Working paper, draft of 19 November 2026. Non-normative: ideas and positions,
not decisions. Matrix is an open standard for federated, real-time
communication: rooms whose histories are copied between servers, signed by
the servers that send them. This paper describes how Matrix establishes
identity and shares files, what it guarantees and for how long, and why it
cannot hold an OpenSheaf archive or replace its owners and keys. It then goes
through the uses it can have beside an archive: announcing new versions,
carrying notices with pins, discussion and review, signing in to services,
coordinating the signers of a group owner, evidence of which version of a key
log was known first, and passing files to referees. It ends with what the
specification might say, experiments and open questions. It continues the
notes on notification protocols and federated systems in
[positioning.md](positioning.md) (sections 4 and 5) and section 4.2 of
[federated-identity.md](federated-identity.md). The facts on Matrix were
checked against version 1.19 of the Matrix specification (8 July 2026) and
the status of its proposals on 19 November 2026.*

## 1. The question

OpenSheaf archives are static files. They can be read, but they cannot
receive anything, run anything or tell anyone that something changed. Every
function that needs a running party (announcing, notifying, discussing,
signing in, collecting signatures) falls on services built beside the
archives (positioning.md, section 3). The question is whether Matrix, an
open, federated protocol with institutional deployments, can be one of those
services, and in which roles.

The answer, stated first:

- Matrix cannot be the **storage** of an archive: its files are not fixed by
  any digest a reader can check, need an account to download, and last only
  as long as the server that holds them keeps them (section 4).
- Matrix cannot be the **identity** of an owner: a Matrix identity is rooted
  in a server, which can speak for its users, and the proposals that would
  root it in keys are not merged (section 3). An OpenSheaf owner is rooted in
  its own key log, checkable without any server.
- Matrix can be a **channel**: for announcements, notices with pins,
  discussion, sign-in to services, and the coordination of signers. In each
  of these roles what Matrix carries points to the archive, by a pin, and is
  checked there; Matrix only transports, orders and keeps a conversation
  about it (section 6).

## 2. Matrix in brief

Matrix is specified by the Matrix.org Foundation, a UK community interest
company with an elected governing board and a Spec Core Team that accepts
changes as numbered proposals (MSCs). The specification is published under
the Apache License 2.0 at <https://spec.matrix.org/>; the latest version is
1.19, of 8 July 2026. Its main parts are the client-server API (what a
client asks of its server), the server-server API (federation), the
application service API (bridges and bots) and the room versions (the
algorithms of a room).

**Homeservers and users.** A user has an account on one homeserver and an ID
of the form `@alice:example.org`. The client talks only to its own server;
servers talk to each other.

**Rooms and events.** Everything happens in rooms. A room is a history of
**events**, each a JSON object with a `type` (`m.room.message`,
`m.room.member`, or a custom type named in Java package style, such as
`org.opensheaf.notice`), a `sender`, a `content` and an `origin_server_ts`.
**State events** also have a `state_key`; the latest state event for each
`(type, state_key)` makes up the room's state: its name, its members, its
power levels, its rules for joining and for reading history.

**Federation and the event graph.** Each event names the events it follows
(`prev_events`) and those that authorise it (`auth_events`). The events form
a directed acyclic graph, a partial order, copied to the servers with
members in the room, each holding what it received since it joined; when
servers send events concurrently, the graph branches, and an algorithm
(state resolution) decides the room's state. A room has no home: it exists
as long as some server keeps it. In room version 12, which specification
1.16 (September 2025) made the default, though servers SHOULD keep using
version 11 for a while, a room ID is the hash of the room's creation event
and no longer contains a server name.

**Event IDs.** Since room version 3, an event ID is a hash of the event in
its redacted form (its reference hash), and since version 4 it is written in
URL-safe base64. Every event also carries a SHA-256 hash of the whole event
as sent (`hashes.sha256`, computed without its signatures) and the signature
of the server that sent it.

**Sizes.** An event, signatures included, is at most 65536 bytes in its
canonical JSON form; its `type` and `state_key` at most 255 bytes each.
Larger content (files, images) goes in the content repository (section 4).

**Visibility.** A room's `history_visibility` is `world_readable`, `shared`,
`invited` or `joined`. A `world_readable` room can be read without joining by
any authenticated user, guests included, but only through a server that
already takes part in the room: Matrix has no reading over federation
(peeking over federation is MSC2444, open). A guest needs a server that
offers guest accounts, and can join only a room whose `m.room.guest_access`
is `can_join`. Nothing in a room is readable without some account. The list
of a server's public rooms can be read without one, and since 1.15 a server
MAY answer a request for a room's summary without one.

**Spaces.** A space (since 1.2) is a room of type `m.space` whose state lists
other rooms (`m.space.child`), forming a hierarchy that clients show as a
directory.

**Bots and bridges.** An ordinary account can be driven by a program. An
**application service** goes further: registered with a server, it receives
the events of the rooms and users in its namespaces, may claim a namespace of
user IDs exclusively, and may set the timestamp of the events it sends.
Bridges to other networks are built this way.

**Links.** The `matrix:` URI scheme (since 1.2, registered with IANA as
provisional) names rooms, users and events, with their IDs written without
the sigil (`!`, `$`, `@`, `#`): `matrix:r/room:example.org` for a room
alias, `matrix:roomid/<id>?via=example.org` for a room ID, with `/e/<event
id>` for an event, `matrix:u/alice:example.org` for a user. Since a room ID
of version 12 has no server part, `via` is the only hint of where to ask,
and is needed in practice.

**Deployments.** Matrix is used by governments and public bodies (France's
Tchap; the German armed forces' BwMessenger; the TI-Messenger standard of
gematik, for German healthcare) and by universities, among them TU Dresden,
KIT and the University of Innsbruck, which run servers for their members. A
researcher at such a university may have a Matrix ID on a server run by the
institution, which matters for sign-in (section 6.4).

## 3. Identity in Matrix

Matrix has two layers of identity: one rooted in the server, used for
everything, and one rooted in user-held keys, used only for end-to-end
encryption.

### 3.1 The server speaks for its users

A user proves who they are only to their own server: with a password, single
sign-on, or, since specification 1.15 (June 2025), the OAuth 2.0 API of
MSC3861. Other servers never see these credentials. What they see is events
that the user's server sends in the user's name, signed by the server.

Each server has Ed25519 signing keys, published at
`/_matrix/key/v2/server` with a `valid_until_ts`, and fetched by other
servers directly or through notary servers (`/_matrix/key/v2/query`). A
server that replaces a key keeps the old one in `old_verify_keys` with an
`expired_ts`, valid only for checking events signed before. The server's
name is bound to DNS and TLS: whoever controls the domain controls the
server and its keys.

A receiving server checks every event: the origin server's signature, the
hash, and the room's authorisation rules (is the sender a member; do the
power levels allow this event). What it can conclude is: *this server
signed this event, and says this user sent it*. The server can send events
in the name of any of its users, and a user whose server lapses or is
seized loses their identity with it. There is no user signature on ordinary
events.

### 3.2 Device keys and cross-signing

End-to-end encryption brought keys held by users. Each device has its own
keys; encrypted messages are tied to the device that sent them. With
**cross-signing**, a user has three Ed25519 key pairs: a master key, which
signs a self-signing key (which signs the user's devices) and a user-signing
key (which signs other users' master keys once verified). Users verify each
other by comparing short strings of emoji or numbers (SAS) or by scanning a
QR code, in person or over another channel. Secret storage keeps the
cross-signing private keys on the server, encrypted by a recovery key, and
they are shared with the user's verified devices; server-side key backup
keeps, likewise encrypted, the keys of encrypted messages.

This is a real separation of roles, rarely used master key and daily keys,
which federated-identity.md (section 4.2) notes as worth noticing. But:

- it covers encrypted messages only, not the events of a public room;
- the server publishes the keys, and trust begins on first use, unless users
  verify by hand;
- a user who loses the master key resets cross-signing, and every contact
  sees a warning and must verify again: recovery goes through the server;
- the signatures are not meant to be checked by third parties, years later,
  without the server.

### 3.3 Portable and cryptographic identities

Several proposals would root a Matrix identity in keys rather than in a
server: MSC1228 (removing user IDs from events), MSC2787 (portable
identities), MSC4014 (pseudonymous identities, per-room keys as senders) and
MSC4080 (cryptographic identities held by the client). On 19 November 2026
all four are open; MSC4014 and MSC4080 need a new room version. None, in
what was read for federated-identity.md, solves rotation after theft without
a server.

### 3.4 What a third party can check, and for how long

| | Server layer | Cross-signing layer |
|---|---|---|
| Who vouches | the user's server | the user's master key, published by the server |
| What is signed | every event, by the server | devices and verified users; encrypted messages, by devices |
| Checkable by an outsider | yes, with the server's key, while it can be fetched (directly or from a notary) | only by the parties of an encrypted conversation |
| After the server goes | old keys may still be cached by notaries and other servers, but nothing guarantees it | keys are lost unless recovered from backup, through a server |
| Theft or loss | the server resets the password | reset and verify again |

An OpenSheaf owner (PR #30, section 6) is the opposite design: its name is
the digest of a genesis record, its keys are in a key log that travels with
the objects it signs, every signature names the key-log version it is
checked against, and none of this needs a server. The keeper, an ORCID iD or
a domain, is the only host-bound part, and it answers for the owner without
owning its lines.

## 4. Sharing files in Matrix

### 4.1 The content repository

A client uploads a file to its own server's content repository and receives
an `mxc://` URI: `mxc://example.org/<media id>`. It then sends an event
(`m.file`, `m.image`, `m.video`) whose `url` is that URI, with `info` giving
the type and size. Other servers fetch the file from the origin server when
one of their users asks for it, through
`/_matrix/federation/v1/media/download/<media id>`, and cache it. Each
server sets its own maximum upload size (`m.upload.size`, read from
`/_matrix/client/v1/media/config`).

The file is not part of the room. The event is copied to every server in
the room; the file is fetched on demand, and stays at its origin and in
whatever caches requested it.

### 4.2 Authenticated media

Since specification 1.11 (June 2024, MSC3916), downloads go through
`/_matrix/client/v1/media/download/<server>/<media id>`, which needs an
access token; servers SHOULD have frozen the old, unauthenticated endpoints
from 1.12, so that new media is served only to authenticated users. Any
logged-in user may fetch any media they know the URI of: there is no check
of membership of the room in which the file was shared. Linking media to
events, so that access can follow the room, is MSC3911, still open.

So a Matrix file is not a web resource that a plain HTTP client, a
harvester or a browser without an account can read.

### 4.3 Encrypted attachments

In an encrypted room the client encrypts the file before uploading it, with a
random AES-256 key in counter mode, and sends in the event an `EncryptedFile`
object: the `url`, the key (as a JSON Web Key), the initialisation vector,
and `hashes.sha256`, the SHA-256 digest of the encrypted file. The
specification says clients MUST verify the hash before using the file's
contents. A plain `m.file` has no hash.

### 4.4 What is guaranteed

| | Plain file | Encrypted file | OpenSheaf |
|---|---|---|---|
| What fixes the bytes | nothing: `mxc://` is a name chosen by the server | SHA-256 of the ciphertext, in the event | SHA-512 of every file in the inventory, the inventory fixed by a pin |
| Who can read | any logged-in user who knows the URI | members of the room holding the key | anyone, by plain HTTP |
| Where it lives | the origin server, and caches | the same | static files, any number of mirrors and copies |
| How long | the server's choice; admins can purge, retention is not standardised (MSC1763 is open) | the same | append-only versions; takedowns recorded |
| Independent copies | none, beyond caches | none | mirrors, accepted copies, external deposits |

A Matrix file is shared, not published. It reaches the people in a room for
as long as the servers cooperate.

## 5. Why Matrix cannot hold an archive

Taken together:

1. **No static reading.** OpenSheaf is read by plain HTTP, from any host that
   serves files (deployment.md). Matrix needs an account and a running
   server for every read, and its files need authenticated requests.
2. **No fixed bytes.** An OpenSheaf reader checks every file against a digest
   it already holds. A plain Matrix file has no digest, and an encrypted one
   only a digest of the ciphertext, valid inside the room.
3. **No durable history.** A room lives as long as some server keeps it; a
   server may purge history and media, and once all servers leave, the room
   is gone. Redaction (section 6.1) strips content on every server that
   follows the protocol.
4. **Server-rooted identity.** What a third party can check is the server's
   signature, not the author's.
5. **Size.** An event holds at most 64 KiB, enough for metadata, a pin or a
   signature file, not for a document.

None of this is a defect of Matrix, which is designed for conversation, not
for records. It does mean that whatever Matrix carries about OpenSheaf must
point back to the archive.

## 6. Possible uses

Each use below follows one rule: **Matrix carries pins, the archive is
checked**. A message about a document version carries the version's pin
(`sheaf:<name>:<owner>/v<n>?sha512=<digest>`, PR #30, section 12; on `main`,
the archive identifier, object identifier, version and inventory digest),
and a reader who wants to rely on it fetches the version from an archive and
checks it against the pin. Where a message must count as evidence of who
said something, what it says is itself in an archive, as a document or a
witness signed with an owner's keys (PR #30, section 7), and the message
carries its pin; the server's signature only shows which server sent the
message.

### 6.1 Announcing new versions

An archive, or an announcement service (positioning.md, section 3), has a
public room, `world_readable`, in which a bot posts each new document
version: the title, the authors, a link and the pin. The bot reads the
archive's Atom feed (`feed` in the discovery document, which is optional)
or, failing that, compares `objects` in the discovery document with what it
saw before; it needs nothing from the archive itself, which stays static.
Readers follow by joining the room from their own server, or read it as
guests through a server that takes part in the room, where the room and the
server allow guests (section 2).

The message can be an ordinary `m.room.message` with `msgtype` `m.notice`,
whose `body` is readable text, and an additional namespaced key holding the
data for tools, as bridges do:

```
{
  "msgtype": "m.notice",
  "body": "New version: On sheaves of documents, v3 -- https://...",
  "org.opensheaf.version": {
    "pin": "sheaf:<name>:<owner>/v3?sha512=<digest>&at=https%3A%2F%2Fauthors.example.org%2F",
    "title": "On sheaves of documents",
    "kind": "document"
  }
}
```

The `at` parameter of the `sheaf:` URI (PR #30, section 12.1) gives the
archive where a copy is expected. Every client shows the message; tools
read the key. A curated announcement service (daily listings by subject) is
a room per listing, and a **space** groups them: a space for a subject,
rooms for its listings, the hierarchy browsable in any client.

Compared with the ActivityPub bridge of positioning.md (section 5), a Matrix
room is copied to the servers with members in it, so the announcements can
outlive the server of the bot, for as long as those servers keep them.
Compared with WebSub, the reader needs no server of their own, only an
account. The announcement is not a record: if it is redacted, its content is
stripped by every server that follows the protocol (Synapse, by default,
keeps the original for seven days), while the envelope remains with the
event's hash and its server's signature, so that whoever kept the original
can show that it was sent. Nothing is lost either way, since the version is
in the archive.

### 6.2 Notices with pins

A static archive cannot run the inbox that Linked Data Notifications or COAR
Notify need (positioning.md, section 4). A room can be that inbox, run by a
service rather than by the archive. A selection that includes a document, a
reviewer who reviews it, a paper that cites it, posts a notice in the room
named by the document's archive; the archive's tools read the room and build
the reverse index (which selections include this document, who reviewed it)
that a document cannot hold about itself.

The notice is a custom event, for instance `org.opensheaf.notice`, whose
content can be a COAR Notify message (an ActivityStreams 2.0 object:
*Announce Review*, *Announce Endorsement*, *Announce Relationship*) with
pins as the objects, as positioning.md proposes, so that the patterns
already implemented by repositories and review services are reused, not
reinvented. Custom event types federate and are stored like any other
event; a notice of a few kilobytes is far within the 64 KiB limit.

What Matrix adds over an LDN inbox:

- the notices are copied to the servers in the room, not held by one
  endpoint;
- each event names the events it follows, and its ID is its hash, so the
  notices are in a partial order, the same for honest servers that hold the
  same events (a server can still withhold or purge events, and concurrent
  events have no order between them);
- who may post is set by the room's power levels and, against abusive
  servers, by server access control lists (`m.room.server_acl`).

What it does not add: the notice says what its sender's server says. What
must stand as evidence is not the notice but what it points to. A review is
an OpenSheaf document of its own, in the reviewer's or the journal's
archive, signed by the owner of its line (PR #30, section 7.1); the notice
carries the pin of the review and the pin of the reviewed version, and both
are checked in their archives. An endorsement of a version by someone other
than its owner can be a witness on that version (PR #30, section 7.2), held
with the object and checked there. COAR Notify itself identifies resources
by URI, without digests; carrying pins is the integrity positioning.md
proposes to add, and it is independent of the transport.

COAR Notify runs over HTTP between repositories and services, and those
already implementing it (DSpace, EPrints, HAL, Peer Community In,
Episciences, PREreview, Sciety) will not move to Matrix. A Matrix room is at
most a second transport, useful where the parties are people and small
services rather than repository platforms.

### 6.3 Discussion and review

A room per document, or a thread per version in an archive's room, gives
readers a place to discuss what was announced. As with ActivityPub, the
conversation stays in Matrix, and what deserves to be kept becomes an
OpenSheaf document of its own (a comment, a review), with its own pins
(issue #21).

For review (issue #29), Matrix offers more than a public network:

- **Private rooms** for an editor and referees, encrypted, invitation only.
- **Pseudonymous referees**: a referee can join with an account created for
  the review, on the journal's server; the journal knows who it is, the
  authors do not. MSC4014 would make per-room identities part of the
  protocol, but it is open.
- **Files for referees** (section 6.8).
- **The record**: the review sent to the authors, and published if the
  journal publishes reviews, is a document in an archive, on a line of the
  journal or of the referee, signed by its owner; the room is the working
  space, not the record.

### 6.4 Signing in to services

Matrix has a standard way for a third party to check a user's Matrix ID. The
client asks its server for a token
(`POST /_matrix/client/v3/user/<user id>/openid/request_token`), which
answers with an `access_token`, the `matrix_server_name` and an expiry; the
client hands the token and the server name to the service, which asks that
server (`GET /_matrix/federation/v1/openid/userinfo?access_token=...`) and
receives `{"sub": "@alice:example.org"}`. The token proves nothing else and
expires.

Services that OpenSheaf leaves to others need accounts: a custodian that
keeps mirrors or indexes (PR #30, section 11), a service that accepts
deposits on behalf of authors, a selection or journal whose editors approve
members, a gateway or index that takes corrections, an announcement service
with moderators. Any of them can accept a Matrix ID as a login, alongside
ORCID or an institutional login, through this exchange.

A service doing so must take care:

- **The server.** The server name comes from the client. The service finds
  the server by Matrix's server discovery, and MUST check, as the
  specification says, that the user ID returned is on the server it called;
  otherwise any server could vouch for any user.
- **Replay.** The token is a bearer token with no audience and is not
  single-use: a service that receives one can present it to another service
  until it expires (an hour, in the specification's example). A service
  should accept a token only once, within a login it started (bound by a
  nonce to the session), and should prefer the server's OAuth 2.0 provider
  (specification 1.15) where there is one, since it names the client and its
  redirect addresses.
- **Fetching.** The service connects to a host the client names, so it
  limits where it connects (public addresses only, with limits on time and
  size), as PR #30 (section 12.6) asks of gateways.

What this gives is the server's say-so, as section 3.1 explains, and its
value is in the server:

- a Matrix ID on a university's server (`@alice:tu-dresden.de`) shows that
  the institution's server has an account for this person; it says less
  than an institutional login through eduGAIN, which can carry attributes
  such as affiliation, and university servers may also hold accounts of
  alumni or guests;
- a Matrix ID on a public server shows only that someone controls an account
  there.

This is sign-in to a service, not authorship and not ownership. What a
service lets a signed-in user do ends in an act made with an owner's keys:
signing a version of a document, of a selection or of a review. **Matrix
authenticates the session; the key log authenticates the record.**

### 6.5 Matrix and owners

Several closer ties between Matrix identities and OpenSheaf owners can be
imagined. None is recommended.

- **A Matrix ID as keeper.** The keeper of an owner (PR #30, section 6.6) is
  an ORCID iD or a domain, confirmed in a place only the keeper controls (the
  ORCID record, or `https://<domain>/.well-known/opensheaf`). A Matrix ID
  would add a third kind, confirmed by a state event in a room the user
  controls; but the user's server can send that event in the user's name, so
  the confirmation is only as strong as the server; it could be read only
  with a Matrix account, where the other two are public web pages; and an
  institution that runs a Matrix server already controls its domain, which
  is a keeper today. Nothing is gained.
- **A Matrix ID as a claim of identity.** An owner's key log, or a document's
  `creators`, may say that a Matrix ID belongs to the same person; the user
  may confirm it from their account. This is a claim, as weak as the server,
  and the question of tying owners to people is issue #41. It could at most
  be an extension.
- **Matrix keys as owner keys.** Cross-signing keys are Ed25519 and could be
  written as `did:key` URIs. They do not fit the rules for owners' keys (PR
  #30, section 6.2): Matrix keeps the master private key on the server, in
  secret storage, and copies it to every verified device, where an owner's
  current keys are never copied to another device; the master key would
  have to serve as a rotation key, used rarely, where Matrix uses it for
  routine verification; and a cross-signing reset, authorised by the
  account's password, discards the key that a key log names. Owner keys stay
  owner keys.

### 6.6 Coordinating the signers of a group

A group owner, a journal's editorial board or a project, has several keys
and a threshold (PR #30, section 6.1). Signing a version needs `threshold`
signature files, made by different people on different machines. Today they
would exchange them by e-mail or through a shared folder.

A room for the group serves well:

- a bot posts the version to be signed, with the digest of its inventory;
- each signer checks the version and posts their signature file, a small
  JSON object, as a custom event (`org.opensheaf.signature`);
- once `threshold` signatures are in, a bot or any member writes them to the
  witness folder and publishes the version.

The power levels of the room can mirror who is expected to sign; but what
decides is the signatures themselves, checked against the key log, never
the room's state. The same works for rotating the keys of a group, where a
new key-log version needs the signatures of the rotation keys (PR #30,
section 6.1), and for signing a selection's new version.

### 6.7 Which version was known first

Under PR #30 (sections 6.3 and 6.4) a fork of a key log ends the owner,
whatever the order in which its sides appeared. Which side was known first
still matters to what an archive keeps and to how far evidence can date
signatures, and both are open: issue #58 discusses them, and the open
questions of PR #30, section 6.6, list witnesses that record which version
of a key log they saw first, as an extension. Section 11.4 of
federated-identity.md sketches pre-rotation in this light.

A room is a replicated, hash-linked record shared by many servers.
Archives and custodians could post, in a common room, the pin of every
key-log version they meet. What the event graph supports is only a lower
bound by ancestry: if a post of version 5 with digest B descends from an
event that itself descends from a post of version 5 with digest A, then A
was known in the room before B was posted. Nothing more can be concluded:

- the graph is a partial order; posts made concurrently have no order
  between them, and the absence of a reference to a post proves nothing,
  since each server chooses the events its own events follow;
- a hostile server can attach a new event to old events, making it look
  concurrent with, or as early as, events it never saw before;
- `origin_server_ts` is the sending server's claim, covered by its
  signature but checked by no one, and an application service can set it;
- a room's history can be purged by each server for itself, and the room
  ends when all leave;
- there are no consistency proofs: a server could show a client a partial
  history.

It could still be one source of evidence among others (timestamps by
OpenTimestamps, deposits, archives' own records), reported by a verifier
and never decisive. It is an option to weigh in #58, not a proposal.

### 6.8 Passing files to referees and collaborators

Where files must go to a few people and not be published, such as a
submission under review (issue #29), an encrypted room carries them, with a
hash of the ciphertext checked by every client. Under PR #30 (section 10.2)
a work is sealed before it is shared privately, so what is sent is a signed
version, and the recipients check the files against its pin, which is the
check that counts. Whether drafts may be shared before sealing is open
(#29). Upload limits are set by each server, often tens of megabytes (50
MB by default in Synapse), which suits papers but not large datasets.

## 7. Matrix compared with other channels

For the announcing and notifying roles of section 6, with the caveat that
these are summaries and the details are in the references:

| | Reader needs | History kept by | Order | Author's signature | Deletion |
|---|---|---|---|---|---|
| Atom feed and WebSub | an HTTP client (and a server, to be pushed) | the archive | the feed's | none | the archive rewrites the feed |
| ActivityPub (Mastodon) | an HTTP client for public posts; an account to follow | the author's server, copies at followers' servers | per server | none (actor keys held by the server) | the author can delete; copies receive a deletion |
| Matrix | an account, a guest's at least, on a server in the room | each server in the room, from when it joined, until it purges | event graph, hash-linked (a partial order) | none for public events (server keys) | redaction strips content on servers that follow the protocol |
| AT Protocol (Bluesky) | an HTTP client, for public data | the user's PDS; relays and AppViews hold copies or indexes | per repository | the account's key in its DID document, usually held by the PDS | the user can delete |
| Nostr | a client and some relays | the relays the author chose | timestamps claimed by authors | yes, the author's key | requests only |
| COAR Notify (LDN) | the inbox's endpoint | the receiving inbox | per inbox | none | the inbox's choice |

Matrix's distinctive properties are the copy of a room at the participating
servers and the hash-linked partial order. Its weaknesses for OpenSheaf are
those of every federated system: the identity and the signatures are the
server's. In every case the pins in the message, and owners' signatures in
the archive on what they point to, make the transport irrelevant to what
can be checked.

## 8. What the specification and the notes might say

The specification needs no change. OpenSheaf archives remain static, and
nothing in the format depends on a channel.

If channels are to be found from an archive, an extension could let the
discovery document name them, by URI, beside `feed`:

```
"channels": [
  {"role": "announce", "uri": "matrix:r/papers-announce:example.org"},
  {"role": "inbox", "uri": "https://notify.example.org/inbox/papers"},
  {"role": "inbox", "uri": "matrix:roomid/<id>?via=example.org"}
]
```

This generalises the inbox proposed in positioning.md (section 7) to
several protocols, Matrix being one. The roles, the names and whether this
belongs in the discovery document at all are open.

Three conventions would be needed if Matrix is used, all outside the
specification, in a note or an extension:

1. the key `org.opensheaf.version` in announcements (section 6.1), holding a
   pin;
2. the event type `org.opensheaf.notice` (section 6.2), holding a COAR
   Notify message whose objects are pins: of the version concerned and, for
   a review or a comment, of the document that holds it;
3. the event type `org.opensheaf.signature` (section 6.6), holding a
   signature file unchanged.

The deployment note (deployment.md) might add a line: an archive can be
announced in a Matrix room by a bot reading its feed, with no change to the
archive.

## 9. Experiments

1. **A feed bot.** A bot, as an ordinary account driven by a short script
   (for instance with the Python library `matrix-nio`), reads the Atom feed
   of [mgubi/papers](https://github.com/mgubi/papers) and posts each new
   document version to a world-readable room, with the key of section 6.1.
   Check how the messages look in several clients, and whether and how a
   guest can read the room.
2. **Pins round trip.** `osheaf` (or the Explorer) reads the room, takes the
   pins, fetches the versions and checks them; it reports a pin whose version
   cannot be found or does not match.
3. **Notices.** Post an `org.opensheaf.notice` carrying a COAR Notify
   *Announce Review*, with the pins of a signed review document and of the
   reviewed version, from a second server; check that it federates, that the
   archive's tools find it and verify both pins, and what remains after a
   redaction.
4. **Sign-in.** A small service accepting Matrix IDs through the OpenID
   exchange of section 6.4, with the checks listed there, tried with accounts
   on a public server and, if available, a university server.
5. **Co-signing.** A test group owner with threshold 2: two signers on two
   servers post signature files in a room; a bot assembles the witness folder
   and the verifier accepts the version.
6. **Order.** Two servers post conflicting pins of a key-log version,
   concurrently and one after the other; look at what the event graph lets a
   reader conclude, and what a server that misbehaves can make it show
   (section 6.7).

## 10. Open questions

- Whether channels (announcement rooms, inboxes) should be named in the
  discovery document, by an extension, or found only through catalogues and
  registries.
- Whether OpenSheaf notices should be COAR Notify messages in every
  transport, so that one format serves HTTP inboxes and Matrix rooms, and
  how pins are written in them (positioning.md, section 4).
- Whether a Matrix ID, or any login, should ever be recorded in an owner's
  key log or a document, and how that relates to tying owners to people
  (#41).
- Whether a replicated room is worth anything as evidence of which version
  of a key log was known first, beside other witnesses (#58; PR #30, section
  6.6).
- Whether review in Matrix rooms fits the review processes and anonymity of
  #29, whether drafts may be passed to referees before sealing, and what of
  a review becomes a document.
- Whether the project should run an announcement room or space for archives,
  as a demonstration, and who would moderate it.

## References

- Matrix specification, version 1.19:
  <https://spec.matrix.org/latest/>; changelog,
  <https://spec.matrix.org/latest/changelog/v1.19/>.
- Client-server API (rooms, events, size limits, content repository,
  encrypted attachments, cross-signing, OpenID, history visibility, guest
  access, spaces): <https://spec.matrix.org/latest/client-server-api/>.
- Server-server API (server keys, notaries, signing and hashing, media
  download, OpenID userinfo):
  <https://spec.matrix.org/latest/server-server-api/>.
- Application service API:
  <https://spec.matrix.org/latest/application-service-api/>.
- Room versions; redaction in version 11, room IDs in version 12:
  <https://spec.matrix.org/latest/rooms/>,
  <https://spec.matrix.org/latest/rooms/v11/>,
  <https://spec.matrix.org/latest/rooms/v12/>.
- The `matrix:` URI scheme: <https://spec.matrix.org/latest/appendices/>;
  IANA, <https://www.iana.org/assignments/uri-schemes/prov/matrix>.
- Proposals: MSC3916 (authenticated media), MSC3911 (linking media to
  events), MSC3861 (OAuth 2.0 API), MSC1763 (retention), MSC2444 (peeking
  over federation), MSC1228, MSC2787, MSC4014, MSC4080 (identity):
  <https://github.com/matrix-org/matrix-spec-proposals>.
- Synapse configuration (`max_upload_size`, `redaction_retention_period`):
  <https://element-hq.github.io/synapse/latest/usage/configuration/config_documentation.html>.
- The Matrix.org Foundation: <https://matrix.org/foundation/about/>.
- Deployments: Bundeswehr,
  <https://element.io/case-studies/bundeswehr>; gematik,
  <https://matrix.org/blog/2021/07/21/germany-s-national-healthcare-system-adopts-matrix/>;
  TU Dresden, <https://doc.matrix.tu-dresden.de/en/why/>; KIT,
  <https://docs.matrix.kit.edu/en/why/index.html>; universities,
  <https://element.io/matrix-in-germany/projects/universities>.
- COAR Notify: <https://coar-notify.net/>.
