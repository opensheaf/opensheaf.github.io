# Federated and decentralized identity, and the key logs of OpenSheaf

*Working paper, draft of 19 November 2026. Non-normative: ideas and positions,
not decisions. OpenSheaf owners are keyed identities whose key logs travel
beside what they sign, across archives that are only hosts, with no central
log and no clock. The rebuilt specification of [PR
#30](https://github.com/opensheaf/opensheaf.github.io/pull/30) records a fork
of a key log by an unsigned fork record that nullifies the keys involved, and
lets the owner heal; issue
[#58](https://github.com/opensheaf/opensheaf.github.io/issues/58) found that
healing need not converge, since any key listed in a key-log version can sign
a competing next version. This paper reviews how federated and decentralized
systems define an identity, rotate its keys, recover from theft and handle
forks: identities bound to a host (ActivityPub, Matrix, e-mail), identities
that are a key (Nostr, Secure Scuttlebutt, Hypercore), identities ordered by a
server or a log (Keybase, Bluesky's did:plc, Certificate Transparency,
Sigstore, key transparency), threshold logs (TUF, Radicle), pre-rotation with
witnesses (KERI), DID methods, OpenPGP, ORCID and DOIs. It ends with a
comparison, the lesson that recurs (no healing without an order, or without a
commitment made before the theft), and a sketch of pre-rotation in OpenSheaf
key logs. It continues [keys-and-forks.md](keys-and-forks.md) and
[radicle.md](radicle.md).*

## 1. The question

Every system in which people sign things under a lasting name has to say four
things: what the name is bound to, how the keys behind it change, what happens
when a key is lost or stolen, and what happens when two incompatible histories
of the name appear. The fourth question is the hard one, and it is the one
OpenSheaf is stuck on.

The [paper on keys and forks](keys-and-forks.md) records how the rules of PR
#30 reached their present form, and its section 6 sets them briefly beside
OpenPGP, git, Radicle, TUF, Sigstore and transparency logs. This paper goes
further: for each family of systems it asks how identity is defined, how keys
rotate, how an owner recovers, how forks (in KERI's word, duplicity) are
detected and resolved, which party or clock the answer leans on, and what
OpenSheaf can take or must avoid.

The answer, stated first: every system that recovers from the theft of a key
that is allowed to change the identity's keys relies either on an **order**
that the thief cannot rewrite (a server, a ledger, a log, a quorum of
witnesses that saw the owner's version first) or on a **commitment made before
the theft** (a key the thief does not have, named in advance as the only one
allowed to act next). Systems with neither do not heal; they end the identity,
as Secure Scuttlebutt and Hypercore in effect do, and as the earlier rule of
PR #30 did.

## 2. The OpenSheaf problem in brief

The rules are those of the rebuilt specification, sections 6 and 7
([opensheaf-specification-0.1.md on branch
proposal/identity](https://github.com/opensheaf/opensheaf.github.io/blob/proposal/identity/opensheaf-specification-0.1.md));
this section only recalls what the comparison needs.

**Owners.** An owner is a keyed identity: a person, a group or an institution.
Its owner name is the digest of a genesis record that fixes its first `keys`
(Ed25519 keys written as `did:key` URIs) and its `threshold`. The owner
object's versions are its key log: each version holds a `keys.json` with
`keys`, `threshold`, and optionally `extensions`, `keeper` (an ORCID iD or a
domain, who answers for the owner), `ended`, `successor` and `nullified`. Each
version vN+1 is signed by `threshold` keys of vN.

**Signatures.** Every sealed version of a line (a work as decided by one
owner) is signed by `threshold` keys of one key-log version, and each
signature file names that key-log version by a pin. A signature is judged
against the version it names alone, and once good it stays good for ever, so
that an owner never has to find every copy of its lines to sign them again.

**Hosts, not authorities.** Key logs travel beside the objects they sign, in
every storage root that holds a copy. There is no central log, no registry and
no trusted clock; a key log checks itself from its owner name.

**Forks.** Two different versions of a key log with the same number, each
signed by `threshold` keys of the version before, are a fork. The format
cannot tell which side is the owner's. An archive that meets the other side
replaces its copy from the fork point by an unsigned **fork record** carrying
both sides; the keys that signed them are **nullified**, and versions that
need a nullified key are taken only from copies. A key log ending in a fork
record is tainted, treated as an end, but the owner may **heal** by a version
signed with keys that took no part (section 6.3, provisional).

**The open problem.** Issue
[#58](https://github.com/opensheaf/opensheaf.github.io/issues/58) records it.
Any key listed in vN can sign a vN+1. With a threshold of 1 and two spare
keys, as the specification's example recommends, a thief holding the working
key can sign a vN+1 that lists the owner's spare keys in `nullified`. The
owner's healing version, signed by a spare, and the thief's version each
nullify the keys that signed the other; neither supersedes. Healing does not
converge: the result is a fork record, that is, an end, and what an archive
keeps depends on the order in which it met the versions.

Three options are on the table in #58:

1. **A fork ends the owner** (as in Secure Scuttlebutt): simple and
   convergent; the owner moves to a successor, and theft of any key costs the
   identity.
2. **Best-effort healing**: keep the present rules, accept that some forks do
   not heal, and rely on spare keys and on the thief's patience running out.
3. **KERI-style pre-rotation**: each key-log version commits to digests of the
   keys that alone may sign the next key-log version. A thief holding a
   working key cannot sign a key-log version at all. The residual risk is the
   theft of a rotation key, mitigated by one-time use and by archives keeping
   the version they saw first.

The rest of this paper is the background against which to weigh them.

## 3. A common frame

The comparison uses five terms:

- **root**: what the identity is bound to (a host, a key, the digest of a
  first record, a registry entry);
- **rotation authority**: who may change the keys (the host, the current keys,
  separate rotation keys, keys committed in advance);
- **recovery**: what an owner can do after a loss or a theft (start again, ask
  a host, use a stronger key within a window, rotate to committed keys);
- **duplicity**: two signed, incompatible histories of one identity, who
  detects it, and what follows;
- **order**: what tells which of two events came first (a server, a ledger, a
  log, timestamps, witnesses, or nothing).

The attackers are those of section 3.9 of the keys paper, refined: a
**forger** with no key and a **host** that changes or withholds data, against
whom every system below is strong; and a **thief** of a working key, of a
recovery key (a spare, a rotation key, a paper key), or of an old key, retired
but still able to sign in the name of the past, on whom they differ.

## 4. Identity bound to a host

In federated systems the root of identity is a server's domain name. Keys are
the server's, or tied to the account by its say-so. The server is the
authority and the orderer: one database, so never a fork, only a server that
lies.

### 4.1 ActivityPub and Mastodon

An ActivityPub actor is identified by an HTTPS URL. Its public key, used for
HTTP signatures, is published in the actor document and held by the server,
which can replace it at will; recovery after a stolen password is the server's
business.

Moving is Mastodon's only portability. The new account lists the old one in
`alsoKnownAs`, and the old account then sends a `Move` activity to its
followers' servers, which unfollow the old account and follow the new one
([Mastodon documentation, moving](https://docs.joinmastodon.org/user/moving/);
[FEP-7628, Move actor](https://fediverse.codeberg.page/fep/fep/7628/)). Only
followers move; posts and media stay on the old server, and other data must be
exported and imported by hand. The move needs the old server: if it is gone or
hostile, there is no move, and the identifiers of everything posted go with
it.

Proposals for portable identity exist. Zot, used by Hubzilla, offered "nomadic
identity", cloning an identity across servers. [FEP-ef61, Portable
Objects](https://fediverse.codeberg.page/fep/fep/ef61/), a draft by
silverpill, gives objects `ap://` identifiers with a DID as authority
(`did:key` among others), served through gateways and signed by integrity
proofs, so that the key and not the server is the root; Fedify, among others,
is implementing it. As far as we can tell from the draft, key rotation is not
settled; with `did:key` there is none.

`alsoKnownAs` in both directions is the same two-way link as OpenSheaf's
keeper confirmation (section 6.6 of the specification): a claim on one side, a
confirmation on the other, each in a place only its party controls.

### 4.2 Matrix

A Matrix user ID is `@alice:example.org`: a local part and a server name.
Every event a server sends is signed with the server's key, published by the
server and fetched through other servers or notaries; servers rotate their
keys and keep the old ones as `old_verify_keys` with an expiry time, so that
old events stay checkable. The server is the root of the user's identity, as
for ActivityPub.

End-to-end encryption added user-held keys. With **cross-signing**, a user has
a master key, which signs a self-signing key (that signs the user's own
devices) and a user-signing key (that signs other users' master keys after
verification) ([Matrix,
cross-signing](https://matrix.org/docs/older/e2ee-cross-signing/)). The role
separation is worth noticing: the master key is used rarely, the others daily.
But the root is still the server: a user who loses the master key resets
cross-signing, the server publishes the new one, and other users see a warning
and must verify again.

Several proposals would move identity from the server to keys:
[MSC1228](https://github.com/matrix-org/matrix-spec-proposals/pull/1228)
(removing user IDs from events) and its successor
[MSC2787](https://github.com/matrix-org/matrix-spec-proposals/pull/2787)
(portable identities),
[MSC4014](https://github.com/matrix-org/matrix-spec-proposals/pull/4014)
(pseudonymous identities: per-room keys as senders), and
[MSC4080](https://github.com/matrix-org/matrix-spec-proposals/pull/4080)
(cryptographic identities, held by the client, which says itself that it does
not yet give account portability). As far as we could check none is merged; we
have not verified their current status. None of them, in what we read, solves
rotation after theft without a server.

### 4.3 E-mail and DKIM

An e-mail address is a local part and a domain. DKIM ([RFC
6376](https://www.rfc-editor.org/rfc/rfc6376)) lets the sending domain sign
messages; the public key is a DNS TXT record under a selector
(`<selector>._domainkey.example.org`). Rotation is a new selector: publish the
new key, sign with it, remove the old record later. Keys belong to the domain,
not to the user, and DNS is the authority: whoever controls the zone controls
the keys.

DKIM signatures are meant to be checked soon after sending; once a selector is
removed, old signatures cannot be checked, and some have argued that domains
should publish old private keys so that old signatures prove nothing
(deniability). That is the opposite of OpenSheaf's need, signatures checkable
for decades. And there is no fork: DNS answers one thing at a time, and a
domain that changes its key changes history for every verifier.

### 4.4 What host-bound systems teach

Host-bound identity solves rotation and recovery by a party that can say "this
is now the key" and be believed, and it never meets a fork, because that party
can rewrite. OpenSheaf has removed that party on purpose. What remains useful
is the keeper (an ORCID iD or a domain that may confirm a successor when every
key is lost) and the two-way link: a host-bound identity kept as a last resort
beside a key-rooted one.

## 5. The key is the identity

In the opposite family the identity is a public key, and nothing else. There
is no authority, and so no rotation and no recovery: a lost or stolen key
means a new identity.

### 5.1 Nostr

A Nostr user is a secp256k1 public key; every event is signed by it, and
relays store and forward events without vouching for anything. NIP-05 maps a
name at a domain to a key, as a hint, much like OpenSheaf's keeper.

Nostr has repeatedly tried to add some form of rotation or recovery, and none
has stuck:

- [NIP-26](https://github.com/nostr-protocol/nips/blob/master/26.md),
  delegated event signing, let a root key, kept in cold storage, authorize
  another key to publish on its behalf. It is now marked "unrecommended: adds
  unnecessary burden for little gain".
- [PR #829](https://github.com/nostr-protocol/nips/pull/829) (NIP-41, "simple
  account recovery", opened in October 2023) proposed that a key whitelist a
  successor in advance (kind 1776) and that the successor later publish a
  migration (kind 1777), both timestamped with OpenTimestamps; the migration
  pointing to the oldest valid whitelist wins, with a window for competing
  migrations. It was never merged.
- [PR #2137](https://github.com/nostr-protocol/nips/pull/2137) (November 2025,
  also numbered NIP-41) has the current key publish a precommit naming a
  single-use intermediate migration key, timestamped with OpenTimestamps, and
  recommends splitting that key among trusted holders. Its own stated
  trade-off: if the attacker obtains key material before a precommit exists,
  it can migrate to its own key; if all key material is lost, there is no
  recovery. It is open, with competing proposals; a December 2025 post on the
  W3C Nostr list noted that none had converged.

Both NIP-41 proposals are, in our terms, a **commitment made before the
theft** (the successor or migration key named in advance) plus an **order**
(OpenTimestamps, anchored in Bitcoin) to decide between a committed migration
and an earlier one. They are close to KERI's pre-rotation, and their slow
adoption is instructive: a migration rule means something only if every client
applies it.

### 5.2 Secure Scuttlebutt

In Secure Scuttlebutt (SSB) an identity is an Ed25519 key pair, and its feed
is an append-only log of messages, each with a `sequence` number and the
identifier of the `previous` message, signed by the key ([Scuttlebutt Protocol
Guide](https://ssbc.github.io/scuttlebutt-protocol-guide/)). The guide says it
plainly: "If a user loses their secret key or has it stolen they will need to
generate a new identity."

A fork of a feed (two messages with the same sequence number) happens in
practice when a user restores an old backup of the secret key and posts from
it while a newer state exists elsewhere. Peers that hold one branch reject
messages that do not extend it, so the user's new messages stop propagating to
them. Community accounts describe forks as hard to notice; one user's report
([a Scuttlebutt post, "Diary of a
Fork"](https://viewer.scuttlebot.io/%25yZimmIftSQLo24Ggiluz2xlunZWLMuUTLp9NqwxvX%2Fo%3D.sha256),
as we read it) repaired one only by asking every peer that had the other
branch to delete the feed and fetch it again. The usual advice is a new
identity. There is no protocol rule for forks: the replication rule (accept
only what extends what you have) makes the first branch seen win locally, and
the identity dies globally.

Later work, the [fusion identity
specification](https://github.com/ssbc/fusion-identity-spec), lets several
devices, each with its own feed, form one identity. Its answer to removing a
device is telling: "there is no easy way to 'remove' a device from a fusion
identity. Our solution is to 'tombstone' identities and require that you mint
a new fusion identity with the devices you trust." Redirects from the old
identity to the new one were left out of scope of the first version.

SSB is option 1 of #58 in its purest form, reached not by design but by the
absence of any rule: a fork ends the identity, and the user starts again. This
works when identities are cheap and followers re-follow; less well for a name
cited in scholarly records.

### 5.3 Hypercore

A Hypercore is an append-only log, verified by a Merkle tree whose roots the
writer signs. In Hypercore 10 a core is named by the hash of a **manifest**
that lists its signers (one by default, or several with a `quorum`) and a
`prologue`; a manifest flag `allowPatch` governs whether the signers may
change ([Hypercore README](https://github.com/holepunchto/hypercore)).
Hypercore 10 added **truncation**: the writer may shorten the log, which
increments a `fork` counter, and the truncation is itself signed, so readers
can follow a writer that deliberately rewrote its tail ("the fork id should be
monotonely incrementing").

A fork that the writer did not announce is treated differently. In the current
source
([lib/core.js](https://github.com/holepunchto/hypercore/blob/main/lib/core.js),
function `checkConflict`), when a peer presents a validly signed tree for a
length the local copy has signed differently, with the same fork id, the core
is marked **frozen**, a `conflict` event is emitted, and every session is
closed with the error "Two conflicting signatures exist for length ...". This
is the SSB outcome written into code: a conflicting signed history ends the
core for that reader. Rotation is outside the core itself; multi-writer
applications (Autobase) build their own membership on top.

Hypercore thus separates a fork the writer announces and signs (truncation,
which readers follow) from one it did not (conflict, which ends the core).

### 5.4 What key-rooted systems teach

Where the key is the identity, a stolen key is a stolen identity, and a fork
is the end of it. None of these systems heals, and the attempts to add
rotation (NIP-26, NIP-41, fusion identities) either failed to be adopted or
ended in "make a new identity and redirect". The one design that comes close
to recovery, NIP-41, does so by a key named before the theft and an external
order, which is section 8's subject.

## 6. Central ordering and transparency

A third family keeps self-certifying signatures but adds a party that orders
events: a server, a ledger, a log. Forks are then not ambiguous: the order
says which came first, and rules can say what a later event may override.

### 6.1 Keybase

Each Keybase user has a public **sigchain**: a sequence of signed links, each
with a `seqno` that increases by exactly one and a `prev` hash of the link
before ([Keybase, sigchain V2](https://book.keybase.io/docs/teams/sigchain)).
The first link is signed by the eldest key; devices are added as sibling keys
signed by existing devices, and paper keys are backup device keys printed as
words. Any device can revoke another, which is how a lost laptop is handled:
the phone revokes it. If every device and paper key is lost, the account is
reset, which, as far as we know, starts a new chain from a new eldest key;
followers see the reset and must decide again whether to trust it.

The server holds every sigchain and could show different chains to different
users. So it signs and publishes the root of a global **Merkle tree** over all
sigchains, and clients check that the chain they were given is in it. Its
documentation states the consequence: a server that shows different roots to
different users "must maintain these forks permanently and can never merge",
and users comparing notes "immediately expose server duplicity" ([Keybase,
server security](https://book.keybase.io/docs/server)). To make that
comparison possible without trusting the server, Keybase wrote its Merkle root
into the Bitcoin blockchain from 16 June 2014 ([Keybase, Merkle root in
Bitcoin](https://book.keybase.io/docs/server/merkle-root-in-bitcoin-blockchain)),
and later into the Stellar blockchain about once an hour ([Keybase,
Stellar](https://book.keybase.io/docs/server/stellar)); we could not find when
the Bitcoin anchoring ended, nor whether the Stellar anchoring continues since
Keybase was acquired by Zoom in 2020.

Keybase has no user-side forks: the server orders sigchain links and refuses a
second link with the same `seqno`. It can refuse service or equivocate, not
forge, and the anchored root makes equivocation detectable. Recovery from a
stolen device is revocation by another device, ordered by the server: whoever
gets there first wins.

### 6.2 Bluesky's did:plc

Bluesky (the AT Protocol) names accounts mostly by `did:plc` DIDs ([did:plc
specification](https://web.plc.directory/spec/v0.1/did-plc)), each a digest of
its signed genesis operation. Each later operation names the previous one by
`prev` and is signed by a **rotation key**. Rotation keys are kept apart from
the signing key of the user's data repository, which the DID document lists
with the user's handle and data server (PDS).

There are one to five rotation keys, in **priority order**: earlier keys have
more authority, and any of them can sign an operation. The specification
describes a "72hr window during which a higher authority rotation key can
'rewrite' history": an operation signed by a higher-priority key, submitted
within 72 hours of an operation signed by a lower-priority key, nullifies it
and the operations after it. The window "may become configurable" in later
versions. A tombstone ends the DID, and can itself be nullified within the
window.

In practice the user's PDS holds a rotation key, used for routine changes, and
a user may add a self-held recovery key with a higher priority ([AT Protocol,
account recovery](https://atproto.com/guides/account-recovery)). A hostile or
compromised PDS can then be overruled within 72 hours.

None of this works without the **PLC directory** (`plc.directory`), which
validates each operation, stores it with its own timestamp, orders operations
by the recovery rules, and publishes an audit log, nullified operations
included. The specification says some trust in the server is required, since
it "could deny service or serve the wrong fork". The 72-hour window is
measured by the directory's clock: priority keys are a commitment made before
the theft (the user's key was listed before the PDS went bad), and the
directory is the order. Both are needed: priority alone would let two keys
nullify each other indefinitely, which is exactly OpenSheaf's #58.

On 19 September 2025 the AT Protocol team announced that an independent
organization, to be formed as a Swiss association, would operate the
directory, and added that "we do not expect a single global directory to be
the final technical architecture for the system" ([Creating an Independent PLC
Directory Organization](https://atproto.com/blog/plc-directory-org)).
Secondary reports say the association has since been registered; we have not
checked a primary source, nor any change to the directory's design. The
specification mentions snapshots, mirroring and third-party audits as
mitigations, without a timeline.

OpenSheaf can take the separation of rotation keys from signing keys, not the
directory; without it, priority needs another order (section 11).

### 6.3 Certificate Transparency

Certificate Transparency (CT, [RFC
6962](https://www.rfc-editor.org/rfc/rfc6962), revised as [RFC
9162](https://www.rfc-editor.org/rfc/rfc9162)) does not define identity; it
makes the issuance of certificates for domain names public. Certificate
authorities submit certificates to append-only Merkle-tree logs and receive
signed promises of inclusion, which browsers require. Monitors watch the logs
for their domains, and auditors check that a log's signed tree heads are
consistent, so that a log showing two histories (a split view) can be caught.
Gossip between clients for that purpose was never widely deployed; the newer
practice is **witnesses** that cosign tree heads they have checked, so that a
client can require several independent cosignatures.

CT does not prevent a bad certificate; it makes it visible to the party that
cares. Its lesson for OpenSheaf is the witness: a party that signs "I have
seen this head, and it extends what I saw before" adds an order without being
an authority.

### 6.4 Sigstore and Rekor

Sigstore avoids long-lived keys. A signer authenticates with an OpenID Connect
identity (an e-mail account, a CI workload), receives from Fulcio a
certificate binding a fresh key to that identity, valid for about ten minutes,
signs, and records the signature in **Rekor**, a transparency log whose
inclusion time serves as the trusted time of signing ([Sigstore
documentation](https://docs.sigstore.dev/)). A verifier checks that the
signature was logged while the certificate was valid. Key theft then matters
only within minutes, and identity is delegated to the OIDC provider.
Sigstore's own trust root (the keys of Fulcio and Rekor) is distributed with
TUF (section 7.1).

This solves backdating, which section 2 of the keys paper calls irreducible,
by moving time into the log, at the price of an identity provider, a
certificate authority and a log, all online. For a record checkable decades
later from copies, it is a model for an optional witness kept beside a
signature, not for the core.

### 6.5 Key transparency

Key transparency applies the idea to messaging directories.
[CONIKS](https://www.usenix.org/conference/usenixsecurity15/technical-sessions/presentation/melara)
(Melara and others, USENIX Security 2015) proposed that a provider commit at
each epoch to a privacy-preserving Merkle tree of name-to-key bindings, so
that users can check their own binding and that everyone sees the same tree.
WhatsApp deployed an auditable key directory, and since September 2024
Cloudflare acts as an external auditor that checks and cosigns each epoch
([Cloudflare, auditing key transparency for
WhatsApp](https://blog.cloudflare.com/key-transparency)); Meta extended the
scheme to Messenger in 2025 ([Meta
engineering](https://engineering.fb.com/2025/11/20/security/key-transparency-comes-to-messenger/)).
Apple's iMessage Contact Key Verification follows the same pattern.

The provider remains the authority for which key is current; transparency
makes it accountable, not unnecessary.

### 6.6 What ordering systems teach

With an order, forks are not a problem to heal but a race to win: the first
valid operation stands, and priority or recovery rules say what may override
it, within limits the orderer measures. The cost is an orderer: a server, a
log with witnesses, a provider with an auditor, each able to deny service,
each making equivocation detectable rather than impossible. OpenSheaf has
none; the keys paper (section 6) lists a transparency log of key-log versions
as an open idea, with its costs.

## 7. Thresholds that walk forward

### 7.1 TUF

The Update Framework ([TUF
specification](https://theupdateframework.github.io/specification/latest/))
protects software repositories with roles, each with keys and a threshold. The
root role delegates to the others, and its metadata is versioned. A client
that trusts root version N fetches N+1, and accepts it only if it is signed by
a threshold of the keys of version N **and** a threshold of the keys of
version N+1, and if its version number is exactly N+1; it repeats until no
later version exists. The second condition, signatures by the new keys, is a
check that the new keys are held by someone, which OpenSheaf's key logs do not
make.

TUF has no notion of a fork of the root: the repository serves one root
history, and clients walk it. If a threshold of old root keys is stolen, the
thief can sign a different N+1 and serve it to clients that fetch from it;
TUF's defences are the threshold, keys kept offline, and expiry dates on all
metadata, with a timestamp role re-signed often, which bound freeze and
rollback attacks. Expiry suits software updates, not a record meant to be
checked in fifty years.

### 7.2 Radicle

Radicle's identity documents follow the same pattern: a repository is named by
the digest of its first identity document, and each revision is signed by a
threshold of the delegates of the previous one. A node is a `did:key` and has
no rotation: a lost or compromised key means a new node identity. The [Radicle
paper](radicle.md) describes this; section 6 of the [keys
paper](keys-and-forks.md) notes that a leaked delegate key can sign under an
old revision. OpenSheaf's key logs took their shape from TUF and Radicle
(rationale D.3 of the specification), and inherit their blind spot: a
walk-forward chain, verified from its first record, has nothing to say when
two versions both walk forward from the same point.

## 8. Pre-rotation and witnesses: KERI

KERI, the Key Event Receipt Infrastructure, was designed by Samuel M. Smith
for exactly the problem OpenSheaf has: self-certifying identifiers that can
rotate keys and recover from compromise without a ledger. The sources are the
original paper ([arXiv:1907.02143](https://arxiv.org/abs/1907.02143)) and the
[KERI specification](https://trustoverip.github.io/kswg-keri-specification/)
of the Trust over IP Foundation, from which the quotations below are taken.

### 8.1 Identifiers and key event logs

A KERI identifier, an **AID** (autonomic identifier), is derived from its
inception event. A non-transferable AID is a public key and can never rotate,
like `did:key`. A transferable AID is a digest of its inception event and has
a **key event log** (KEL): an append-only, hash-chained sequence of signed
events. Each event has a sequence number `s` and the digest `p` of the event
before; the specification is firm that "there MUST be at most one valid KEL
for any identifier or none at all".

Establishment events change the key state: inception (`icp`), with the signing
keys `k` and threshold `kt`, the **digests of the next keys** `n` and their
threshold `nt`, and the witnesses `b` with their threshold `bt`; rotation
(`rot`); and their delegated forms (`dip`, `drt`), which a delegator must
approve in its own KEL. Interaction events (`ixn`) anchor data, such as a
document digest, to the current key state without changing it.

### 8.2 Pre-rotation

The central idea is that "control authority is split between keypairs that
hold signing authority and keypairs that hold rotation authority". Each
establishment event names the current signing keys in clear and the next
rotation keys only by digests. A rotation "MUST include a list of the set of
pre-rotated public keys (not their digests)": it reveals keys whose digests
the previous establishment event listed, is signed by a threshold of them, and
itself commits to digests of a new next set. The specification states the
purpose: "With key pre-rotation, control over the identifier can be
re-established by rotating to a one-time use set of unexposed but
pre-committed rotation keypairs."

Rotation keys are "first-time, one-time, and only-time": unused before the
rotation that reveals them, and no longer rotation keys after it (they may
become the new signing keys). A thief who steals the current signing keys can
sign interaction events, but not a rotation: the rotation authority has
already been transferred to keys the thief has never seen. Hidden behind
digests, the next keys also resist a cryptanalytic (or surprise quantum)
attack on public keys.

A **partial rotation** exposes only some pre-rotated keys and holds others
back; with weighted thresholds this gives **reserve rotation** (committed keys
kept in reserve for when the usual holders are unavailable: OpenSheaf's spare
keys, without exposing them) and **custodial rotation** (a custodian signs,
the controller alone can rotate it out). An **establishment-only**
configuration forbids interaction events, so that every signature is by a
one-time key.

### 8.3 Witnesses, receipts and KAWA

An AID's controller names its **witnesses** (backers) in the inception event
and changes them by rotations. A witness verifies each event, and if it is
"the first seen version of that event the witness has received", signs a
**receipt** and stores it in its key event receipt log (KERL); "all other
versions are discarded", except for superseding recoveries (below). The
witness threshold `bt` says how many receipts an event needs to be accepted by
validators who rely on witnesses.

KAWA, KERI's Algorithm for Witness Agreement, is not consensus in the usual
sense. Its observation is that "because the controller is the sole source of
truth for the creation of any and all key events, it alone, is sufficient to
order its own key events"; key events need consistency, not a global order, so
a single round of witness receipts suffices. The specification states that for
N witnesses there is a threshold M under which, with at most F faulty
witnesses, "at most one sufficient agreement occurs or none at all, despite a
dishonest controller". Witnesses are chosen and replaced by the controller: a
service, not an authority.

### 8.4 Watchers, first-seen and duplicity

Validators protect themselves with **watchers**, which keep copies of KELs as
first seen and compare them (with **jurors** and **judges** to record and
weigh duplicity). The rule every component follows is "first seen, always
seen, never unseen": once a version of an event at a location has been
accepted, it is kept, and a different version at the same location is
**duplicity**.

What happens on duplicity is left to the validator, which may stop trusting
the identifier or keep its own copy as authoritative; but "once duplicity is
detected, that identifier loses all its value to any detecting validator."
KERI does not try to make every copy agree on which side of an unauthorized
fork is right; it makes the fork evidence, and lets each party keep the
history it saw first.

### 8.5 Attacks, and recovery by superseding

The specification classifies attacks by the key state they target. A **dead
attack** uses keys of a stale establishment event, already rotated out: the
thief makes an alternative version of an old event and must deliver it to a
validator before the original. It fails against anyone who already holds the
original history: "any validator ... that has access to the original key event
history is protected from harm due to a later successful compromise of the
keys of any event already in that history." It succeeds only by an eclipse
(the validator sees only the attacker) or by deleting every copy of the
original history.

A **live attack** targets the current state. Against the current signing keys
(a non-establishment live attack), the thief can sign interaction events, if
the witnesses accept them; the controller then recovers by a **superseding
rotation**. Against the current next keys, before their first use (an
establishment live attack), there is no recovery: the thief rotates first, to
keys and witnesses of its own, and the controller's later rotation looks
duplicitous to everyone who saw the thief's first. "Protection from
establishment Live-attack exploits comes exclusively from the difficulty of
compromising a set of pre-rotated keys before or at the time of their first
use." Mitigations are a threshold of next keys held apart, and delegation.

Recovery is governed by explicit **superseding rules**, which say when a
different event at a location already first seen may replace it. For
non-delegated identifiers:

- "A0. Any rotation event may supersede an Interaction event at the same sn
  where that interaction event is not before any other rotation event."
- "A1. A non-delegated rotation may not supersede another rotation."
- "A2. An interaction event may not supersede any event."

Rules B and C let a delegated rotation supersede the latest-seen delegated
rotation when the delegator approved it later, recursively up the chain of
delegators. The superseded events are not deleted: they form a disputed
branch, kept and replayable, while the trunk continues from the superseding
event. "Notably, an event that may not supersede, according to the rules
below, another event at the same location cannot be first seen at all by that
KEL."

These rules are what make KERI converge. Only a rotation (signed with
pre-committed keys) can override, only interaction events (signed with exposed
current keys) can be overridden, and rotations never override each other.
There is no case of two events each claiming to override the other, which is
OpenSheaf's #58.

### 8.6 Delegation and recovery through a delegator

A delegated AID's establishment events are valid only if its delegator anchors
a seal of them in the delegator's own KEL. An attacker who steals a delegate's
next keys must also get the delegator to approve the rotation. And since the
delegator's anchoring event can itself be superseded, a delegator and delegate
together can recover even from an establishment live attack on the delegate,
which "is not possible with an establishment Live-attack on a non-delegated
event". The limit is stated: only the latest-seen delegated rotation can be
superseded, so once the attacker has had a second rotation approved, recovery
is lost.

Delegation brings back an authority, chosen by the delegate and checkable by
anyone; GLEIF's vLEI (below) is a tree of delegations. An OpenSheaf keeper
with keys of its own could play a delegator's role; today's keeper, an ORCID
iD or a domain, has none.

### 8.7 did:keri, did:webs and the vLEI

KERI identifiers have been written as DIDs in two ways. `did:keri` was an
early draft method, resolved from KELs held by witnesses and watchers; work
moved to **did:webs** ([did:webs
specification](https://trustoverip.github.io/kswg-did-method-webs-specification/),
a Trust over IP draft), which combines `did:web` with a KERI AID: the
identifier names a host and an AID, and the host serves `did.json` and the KEL
as `keri.cesr`. The resolver checks the KEL, so the web server is only a
transport: a domain that changes hands cannot change the keys, and the same
AID may be served from several domains. This is OpenSheaf's model of archives
as hosts, with the KEL in the role of the key log.

The best-known deployment is the **vLEI** of the Global Legal Entity
Identifier Foundation ([GLEIF, vLEI](https://gleif.org/en/vlei)): credentials
for legal entities and their officers, issued from a GLEIF root AID through
delegated AIDs to qualified issuers, with multi-signature controllers and
witnesses. As implementers describe it, the root AID never issues credentials
and stays offline. An institution with something to lose is closer to a
journal or a university as an OpenSheaf owner than any social network is.

### 8.8 What KERI teaches, and its costs

KERI is the only system reviewed here that recovers from theft of a working
key without a central order. It does so with three pieces: a commitment made
before the theft (pre-rotation), rules under which only committed keys may
override and nothing overrides them back (superseding), and copies that keep
the first version they saw (first-seen, with witnesses and watchers to spread
and compare). Its residual risks are stated: theft of next keys before their
first use is unrecoverable, and a dead attack succeeds only against a
validator who has never seen the original history.

Its costs are complexity (CESR encoding, weighted thresholds, delegation, a
vocabulary of its own), witnesses and watchers to extend first-seen beyond
one's own copies, and an ecosystem still young outside GLEIF. OpenSheaf does
not need most of it. It needs the split between signing and rotation
authority, the commitment, the superseding rule, and a first-seen policy for
archives.

## 9. DID methods compared

Decentralized identifiers ([W3C DID Core](https://www.w3.org/TR/did-core/))
are a common syntax over very different answers, spanning the families above.

- **did:key**: the identifier is a public key; the document is derived from
  it. No rotation, no recovery, no forks. OpenSheaf uses it to write keys, not
  owners.
- **did:peer**
  ([specification](https://identity.foundation/peer-did-method-spec/)):
  identifiers exchanged between parties, never published. Numalgo 0 is
  equivalent to `did:key`, 1 hashes a genesis document, 2 encodes several keys
  and services, 3 and 4 are short forms. The specification says "`peer` DIDs
  cannot be updated"; protocols such as DIDComm rotate by switching to a new
  DID. Rotation is pushed up into the protocol that uses them.
- **did:web**: the document is served at a well-known URL on a domain; whoever
  controls the domain and its TLS certificate controls the keys. Rotation is
  editing a file, recovery is regaining the domain, and there is no history: a
  verifier sees only the present document. Host-bound identity in DID syntax.
- **did:webs**: did:web with a KERI AID and its KEL (section 8.7); the domain
  is transport, the KEL is the root.
- **did:plc**: digest of a genesis operation; rotation keys in priority order;
  72-hour recovery window; the PLC directory as orderer (section 6.2).
- **did:keri**: a KERI AID resolved from witnesses and watchers; an early
  draft, from which work has largely moved to did:webs (as far as we can
  tell).
- **did:ion and Sidetree**: below.

### 9.1 Sidetree and did:ion

[Sidetree](https://identity.foundation/sidetree/spec/), a specification of the
Decentralized Identity Foundation, builds DIDs on a ledger used only as an
ordering oracle. Operations are batched into files on a content-addressed
store (IPFS for ION), and only a small anchor string, the address of the
batch's index file and its operation count, is written to the ledger.
`did:ion` is Sidetree on Bitcoin.

Sidetree uses **commit-reveal** for both update and recovery keys, which makes
it a pre-rotation scheme in all but name. At creation the DID commits to a
recovery key (`recoveryCommitment`) and an update key (`updateCommitment`),
each as a double hash of the public key. An **update** reveals the update key
whose commitment is current, is signed by it, and commits to the next update
key. A **recover** reveals the recovery key, is signed by it, and sets new
recovery and update commitments; a **deactivate** reveals the recovery key and
ends the DID. The specification requires that a key not be reused across
commitments ("Implementers MUST NOT re-use public key JWK payloads across
different commitment invocations"). A thief holding the update key can update
the document, but the owner, revealing the recovery key, takes it back with a
recover operation, which the thief cannot make; and since each key is revealed
once, a stolen revealed key is useless for the next step.

Forks are decided by the ledger. Sidetree calls the case where an operation
anchored in the past is revealed later **late publishing**, and resolves it
plainly: "the earliest operation in Anchor Time always wins", even if the
owner has since built on another branch. The specification warns owners to
keep the payloads they submit, since a different payload for the same
commitment "can put the DID at risk of late publish branching". Commit-reveal
plus a total order: the two ingredients of section 1, both present.

ION's practical history is a caution. Microsoft, its main sponsor, offered
did:ion in its Entra Verified ID service only in preview and ended that
support in December 2023, moving customers to did:web ([Entra Verified ID
FAQ](https://learn.microsoft.com/en-us/entra/verified-id/verifiable-credentials-faq)).
We have not checked how active the ION network is today; the need to run
Bitcoin and IPFS nodes to resolve a DID seems to have weighed against it.

## 10. OpenPGP, ORCID and DOIs

### 10.1 OpenPGP

An OpenPGP key is its own identity, certified by others in a web of trust.
Rotation is done with subkeys under a long-lived primary key that can stay
offline; replacing the primary key means a new identity, announced by signing
the new key with the old. Recovery after theft is a **revocation
certificate**, made in advance and stored apart, which the owner publishes
when the key is lost or stolen: a commitment made before the theft, of the
simplest kind, which can only end an identity, not move it. OpenPGP
distinguishes soft revocation reasons (superseded, retired), after which
signatures made earlier stay good, from hard ones (compromised), after which
none can be trusted, since signature dates are the signer's claim (keys paper,
section 6).

OpenPGP also had **designated revokers**: a key could name another key allowed
to revoke it. [RFC 9580](https://www.rfc-editor.org/rfc/rfc9580) (2024)
deprecated the mechanism ("Applications MUST NOT generate such a subpacket")
and points instead to escrowed revocation signatures. Forks do not arise,
since a key has no history of versions; but key distribution through
keyservers suffered from having no authority at all: the SKS keyserver network
was crippled in 2019 by certificate flooding, and keys.openpgp.org, which
verifies e-mail addresses and strips third-party signatures, is now the usual
alternative. OpenPGP shows both the value of a commitment prepared in advance
(the revocation certificate) and the limit of one that can only end.

### 10.2 ORCID and DOIs

ORCID iDs and DOIs are institutional identities: a registry assigns the name
and keeps what it means. An ORCID account is recovered through e-mail and
ORCID's support; a DOI's target is changed by whoever holds its prefix. There
are no user keys and no forks; the registry is the authority and the order.
OpenSheaf uses them as **keepers** (section 6.6), places where a link to an
owner and a successor can be confirmed: an institutional identity beside the
key-rooted one, not its root.

## 11. Synthesis

### 11.1 The comparison

The table summarizes. "Order" is what decides between two signed histories;
"fit" is what OpenSheaf can use.

| System | Identity | Rotation | Recovery after theft | Forks | Order or clock | Fit for OpenSheaf |
|---|---|---|---|---|---|---|
| ActivityPub / Mastodon | URL on a server | server's choice | server; `Move` to a new account | none (one server) | the server | `alsoKnownAs` as a two-way link, like the keeper |
| Matrix | `@user:server`; cross-signing keys | server keys; reset of cross-signing | reset and re-verify | none | the server | role separation (master vs daily keys) |
| E-mail / DKIM | address at a domain | new DNS selector | the domain owner | none | DNS | none; signatures meant to expire |
| Nostr | a key | none (NIP-26 unrecommended) | none; NIP-41 drafts: precommitted key plus OpenTimestamps | not handled | none (drafts: OpenTimestamps) | a key named in advance, plus timestamps |
| Secure Scuttlebutt | a key; a feed | none (fusion: tombstone and new identity) | new identity | fork kills the feed | none; local first-seen | option 1 |
| Hypercore 10 | hash of a manifest | `allowPatch`; truncation signed | outside the core | conflict freezes the core | none; local | signed rewrites vs unannounced forks |
| Keybase | account with sigchain | devices add and revoke devices | another device revokes; reset | server refuses | server, Merkle root anchored in a blockchain | detectability of equivocation |
| did:plc | digest of genesis op | rotation keys | higher-priority key within 72 h | priority rule within window | PLC directory | rotation keys apart from signing keys; priority |
| CT | (domain certificates) | n/a | n/a (revoke, monitor) | split views detected | logs and witnesses | witnesses that cosign heads |
| Sigstore | OIDC identity | a key per signature | n/a (keys live minutes) | n/a | Rekor log time | optional witness for dates |
| Key transparency | account at a provider | provider | provider | split views detected | provider plus auditor | auditor cosigning |
| TUF | root metadata | threshold of old and new keys | offline root keys | not handled | repository; expiry dates | signatures by the new keys too |
| Radicle | digest of first identity doc | threshold of delegates | new node identity | not handled | none | already taken (key logs) |
| KERI | digest of inception (AID) | pre-rotated keys | rotation with next keys; superseding | duplicity: first seen kept; rotation supersedes interaction | none global; witnesses' and watchers' first-seen | option 3 |
| Sidetree / did:ion | digest of create op | commit-reveal of update key | commit-reveal of recovery key | earliest anchor wins | Bitcoin ledger | commit-reveal, without the ledger |
| OpenPGP | primary key | subkeys | revocation certificate (ends) | n/a | none | commitments that only end |
| ORCID / DOI | registry entry | n/a | registry | none | registry | keeper |

### 11.2 The recurring lesson

Two forms of recovery work, and only two.

**An order the thief cannot rewrite.** Keybase, did:plc, Sidetree and key
transparency decide forks by an orderer: the first valid operation stands, and
recovery rules say what may override it within limits the orderer measures.
The thief can race but cannot reorder.

**A commitment made before the theft.** KERI, Sidetree and the NIP-41 drafts
name in advance the keys that alone may act next, and keep them unexposed
until then. A thief who steals what is exposed cannot act at the level that
matters, because the authority already lies elsewhere.

Where the commitment is a full one (only committed keys may sign the next
establishment event, and committed keys are used once), forks caused by theft
of exposed keys cannot happen at all, and a superseding rule (committed keys
override exposed ones, never the reverse) makes the remaining cases converge.
Where it is partial, as with did:plc's priority keys, the system still needs
an order to stop two keys from overriding each other in turn; did:plc's
72-hour window is that order, measured by the directory.

Systems with neither do not heal. SSB and Hypercore end the identity on a
conflict; Radicle and TUF do not handle forks; OpenPGP can only revoke.
OpenSheaf's current healing is the case the lesson predicts: spare keys and
working keys are listed side by side in `keys`, so the spare holds no
authority the thief's key lacks, and two versions can each nullify the other's
signers. There is no order to break the tie, and no prior commitment that
gives one side more authority.

A second lesson concerns what forks are evidence of. Hypercore follows a
rewrite the writer announces and stops at one it did not; KERI keeps both
sides of a duplicity and lets each validator keep what it saw first; Keybase
and CT make equivocation detectable and leave the response to people. None
tries to make every copy compute the same winner from the same evidence
without an order, which OpenSheaf's rule "when versions meet" attempts.

### 11.3 The options of #58 in this light

**Option 1, a fork ends the owner**, is SSB and Hypercore. It converges (every
copy that sees both sides agrees the owner is ended) and needs no order. Its
cost is that the theft of any key that can sign a key-log version ends the
identity, and with a threshold of 1 that is the working key; the owner
continues under a successor, by branches. For a person this is tolerable if
successors are well supported (the keeper confirming, tools redirecting, as
Mastodon's `Move` does and SSB's fusion redirects proposed). It is the
fallback for any residual case of the other options.

**Option 2, best-effort healing**, is what no system reviewed here does
without an order. did:plc's priority rule is the nearest analogue, and it
works only because the directory measures the window and orders operations.
Without one, the outcome depends on the order in which each archive met the
versions, which #58 already records as an open problem. We do not see how to
make it converge.

**Option 3, pre-rotation**, is KERI, and in part Sidetree. It converges for
the theft of working keys, which is the common case, without an order, and
reduces the residual to the theft of rotation keys. Section 11.4 sketches it
for key logs. It does not remove the need for option 1 in the residual case;
it makes that case rare.

There is also an **intermediate option**, which did:plc suggests: separate
rotation keys from signing keys, listed in clear, without digests or one-time
use. A thief holding a signing key could then sign lines but never a key-log
version, which removes the #58 race for the common case at once. It leaves the
theft of a rotation key (a spare) as before, where pre-rotation adds hiding
and one-time use. It is a smaller change, and a step towards option 3 rather
than an alternative to it.

These are proposals. Issue
[#58](https://github.com/opensheaf/opensheaf.github.io/issues/58) is where
they are decided.

### 11.4 Pre-rotation in key logs: a sketch

The sketch keeps the specification's names where it can; the new field names
are placeholders, like the others (#55).

**Fields.** A `keys.json`, and the genesis record of an owner, gain:

- `next`: digests of the next rotation keys, each the SHA-256 digest of a
  key's `did:key` URI, in the base32 form the specification uses elsewhere;
- `nextThreshold`: how many of them must sign the next key-log version.

`keys` and `threshold` keep their meaning for lines: they sign versions of
lines, and nothing else. The owner name, as the digest of the genesis record,
then commits to the first `next`, so that the first rotation is pre-committed
from birth, as KERI's inception is; the first version stays signed by its own
`keys`, as now.

**Signing a key-log version.** A version vN+1 is signed by at least
`nextThreshold` of vN's distinct rotation keys: keys whose digests vN lists in
`next`. vN+1 reveals them, in a field such as `rotatedBy` or simply by the
signature files, which name the key; a verifier checks each against a digest
in vN's `next`. vN+1 lists a fresh `next`, which MUST NOT contain any key
revealed so far (one-time use). Whether revealed rotation keys may become
signing keys of vN+1, as in KERI, is a choice: allowing it saves keys,
forbidding it keeps every key in one role. With the spare keys of today's
example (two hardware tokens), forbidding it seems simpler: the tokens rotate
and are replaced, the laptop signs.

**Theft of a working key.** The thief can sign versions of lines naming the
current key-log version; it cannot sign a key-log version, since it holds no
committed key. The owner answers with vN+1, signed by its rotation keys,
listing the stolen key in `nullified`. No competing version is possible, so
`nullified` is never contested: every copy that receives vN+1 nullifies the
key, and the rule of section 6.4 (versions that need a nullified key are taken
only from copies, never as new deposits) applies unchanged. No fork record, no
healing.

**Signatures still carry no time.** The thief can still sign versions of the
owner's lines naming vN, and nothing dates them: pre-rotation stops forks of
the key log, not backdating of lines. Readers still weigh versions that need a
nullified key by other evidence (section 6.4). What pre-rotation buys is that
the owner survives the theft and its nullification reaches every archive
without a race.

**Fork records.** Two different key-log versions with the same number, each
signed by committed keys of the version before, can now arise in only three
ways: the owner signed both (an error, or deliberate duplicity); someone stole
a rotation key after it was used (KERI's dead attack); or someone stole
unexposed rotation keys and used them first (KERI's establishment live
attack). The rule could then be:

- **First seen, kept.** An archive that holds a version of a key log at a
  given number keeps it, and does not replace it on meeting another. The other
  side is kept as evidence, in the witness folder or a fork record that
  carries both, but does not become the archive's key log. This is KERI's
  "first seen, always seen, never unseen", and it defeats the dead attack in
  every archive that held the owner's version before the thief's appeared,
  which, for a key log copied beside everything it signs, is most of them.
- **Duplicity reported.** Readers and verifiers that see both sides report the
  owner as duplicitous at that number, with both sides' evidence. Whether that
  ends the owner for everyone (option 1 for the residual) or only for archives
  that met the thief's side first is the question #58 would still have to
  settle. KERI leaves it to each validator; OpenSheaf, whose readers are
  people looking at archives, probably needs a single rule, and ending is the
  simple one.
- **No superseding among rotations.** As KERI's rule A1, a key-log version
  signed with committed keys never supersedes another signed with committed
  keys. The only superseding left is `nullified`, applied to signing keys and
  their lines, which only committed keys can make.

**The residual case.** An establishment live attack, the theft of unexposed
rotation keys before the owner uses them, is unrecoverable here as in KERI:
the thief rotates first, and its version is first seen. The mitigations are
those of KERI: rotation keys kept offline and apart, a `nextThreshold` of 2 or
more so that one stolen token is not enough, and few rotations (each exposure
is a chance). A dead attack (theft of used rotation keys) succeeds only
against a reader or archive that never saw the owner's history, which is an
eclipse. Witnesses would narrow both: the specification already allows other
owners' witness signatures on any version (section 7.2), so a few owners (an
institution, a journal, a custodian) could sign key-log versions on receipt,
as KERI's witnesses sign receipts, and a reader could require such receipts.
That is an extension to consider, not a requirement.

**What disappears.** Healing versions and the rule "when versions meet" lose
their purpose, and fork records remain only as evidence of duplicity. The
advice of section 6.2 changes: not a threshold of 1 with two spares (which #58
showed fragile) or of 2, but a threshold of 1 for daily signing and one or
several committed rotation keys.

**Costs.** Two fields and one rule. Owners must keep rotation keys that appear
in `keys.json` only as digests, and must not lose them all (that ends the
owner, as losing every key does today, and the keeper may name a successor);
tools must make the next keys at each rotation and store them apart. A
verifier needs the revealed keys to check a key-log version, and the signature
files already name them.

## 12. Open questions

- Whether OpenSheaf adopts pre-rotation, the intermediate role separation, or
  option 1 alone (#58).
- Whether revealed rotation keys may become signing keys, or whether the two
  roles stay disjoint.
- What an archive does on meeting duplicity at a key-log number below its own
  head (keep and report only, or end the owner), and whether readers need a
  single answer.
- Whether witness signatures on key-log versions, by other owners, should
  become an extension, and whether a reader may require them (#55).
- Whether the keeper should be able to hold keys, so that it can act as a KERI
  delegator, or stay a confirmation in ORCID or on a domain.
- How a successor is supported well enough that ending an owner is acceptable
  in practice (the redirects SSB never shipped, Mastodon's `Move`).

## References

- OpenSheaf: the rebuilt specification, sections 6 and 7, on branch
  `proposal/identity`:
  <https://github.com/opensheaf/opensheaf.github.io/blob/proposal/identity/opensheaf-specification-0.1.md>;
  [PR #30](https://github.com/opensheaf/opensheaf.github.io/pull/30); issues
  [#55](https://github.com/opensheaf/opensheaf.github.io/issues/55) and
  [#58](https://github.com/opensheaf/opensheaf.github.io/issues/58);
  [keys-and-forks.md](keys-and-forks.md); [radicle.md](radicle.md).
- ActivityPub and Mastodon: <https://docs.joinmastodon.org/user/moving/>;
  FEP-7628: <https://fediverse.codeberg.page/fep/fep/7628/>; FEP-ef61:
  <https://fediverse.codeberg.page/fep/fep/ef61/>.
- Matrix: cross-signing, <https://matrix.org/docs/older/e2ee-cross-signing/>;
  MSC1228, MSC2787, MSC4014, MSC4080 in
  <https://github.com/matrix-org/matrix-spec-proposals>.
- DKIM: RFC 6376, <https://www.rfc-editor.org/rfc/rfc6376>.
- Nostr: NIP-26, <https://github.com/nostr-protocol/nips/blob/master/26.md>;
  NIP-41 drafts, <https://github.com/nostr-protocol/nips/pull/829> and
  <https://github.com/nostr-protocol/nips/pull/2137>.
- Secure Scuttlebutt: Protocol Guide,
  <https://ssbc.github.io/scuttlebutt-protocol-guide/>; fusion identity,
  <https://github.com/ssbc/fusion-identity-spec>.
- Hypercore: <https://github.com/holepunchto/hypercore> (README,
  `lib/core.js`).
- Keybase: <https://book.keybase.io/docs/server>,
  <https://book.keybase.io/docs/teams/sigchain>,
  <https://book.keybase.io/docs/server/merkle-root-in-bitcoin-blockchain>,
  <https://book.keybase.io/docs/server/stellar>.
- did:plc: specification, <https://web.plc.directory/spec/v0.1/did-plc>;
  account recovery, <https://atproto.com/guides/account-recovery>; independent
  organization, <https://atproto.com/blog/plc-directory-org>.
- Certificate Transparency: RFC 6962,
  <https://www.rfc-editor.org/rfc/rfc6962>; RFC 9162,
  <https://www.rfc-editor.org/rfc/rfc9162>.
- Sigstore: <https://docs.sigstore.dev/>.
- Key transparency: CONIKS,
  <https://www.usenix.org/conference/usenixsecurity15/technical-sessions/presentation/melara>;
  Cloudflare, <https://blog.cloudflare.com/key-transparency>; Meta,
  <https://engineering.fb.com/2025/11/20/security/key-transparency-comes-to-messenger/>.
- TUF: <https://theupdateframework.github.io/specification/latest/>.
- KERI: S. M. Smith, Key Event Receipt Infrastructure,
  <https://arxiv.org/abs/1907.02143>; KERI specification,
  <https://trustoverip.github.io/kswg-keri-specification/>; did:webs,
  <https://trustoverip.github.io/kswg-did-method-webs-specification/>; GLEIF
  vLEI, <https://gleif.org/en/vlei>.
- DIDs: DID Core, <https://www.w3.org/TR/did-core/>; did:peer,
  <https://identity.foundation/peer-did-method-spec/>; Sidetree,
  <https://identity.foundation/sidetree/spec/>; Entra Verified ID FAQ,
  <https://learn.microsoft.com/en-us/entra/verified-id/verifiable-credentials-faq>.
- OpenPGP: RFC 9580, <https://www.rfc-editor.org/rfc/rfc9580>.
