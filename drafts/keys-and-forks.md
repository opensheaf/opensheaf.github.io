# Keys, revocation and forks: what went wrong on the way

*Working paper, draft of 17 November 2026. Non-normative: an account of the
difficulties met while writing the rules on owners, keys, signatures,
revocation and forks of the proposal of
[PR #30](https://github.com/opensheaf/opensheaf.github.io/pull/30) (merged
from [PR #56](https://github.com/opensheaf/opensheaf.github.io/pull/56);
discussed in issue
[#55](https://github.com/opensheaf/opensheaf.github.io/issues/55)). Between
the fourth and the ninth review of the proposal these rules were rewritten
several times; each version closed the holes found in the one before and
opened others. This paper records the attempts, the attacks that defeated
them, and the principles that came out of it, so that the next change of
these rules does not repeat them. Where it describes the rules, it describes
those of PR #30 after the commit that removes setting aside and the removal of
files (section 3.5); the specification is right where they differ.*

## 1. What keys are for

An owner, in the proposal, is a keyed identity: a person, a group or an
institution whose name is the digest of a genesis record that fixes its first
keys and a `threshold`. Its key log is the sequence of versions of its owner
object, each `keys.json` listing the current keys and signed by `threshold`
keys of the version before. Every sealed version of a line `(name, owner)` is
signed by the owner, and each signature names the key-log version it was made
under.

The intent of the editor, restated at every turn, is narrow:

- keys exist so that no one can create or extend the lines of another owner;
- a signature, once made, stays valid: the past is not reopened;
- an owner cannot enumerate its objects. Its lines are copied, mirrored and
  branched into archives it does not know, and their evidence (a branch's
  `parent.signatures/`) is frozen content. No rule may therefore require an
  owner to sign anything again, or to find all its objects.

Everything below is the conflict between these three points and one fact.

## 2. The core difficulty: signatures carry no time

A signature says who signed, not when. A signature file names a key-log
version, but anyone who holds a key listed in an old version can name that
old version today. So, once a key has leaked, nothing in the signature
distinguishes:

- a signature the owner made years ago, under key-log version v2, while the
  key was safe; from
- a signature the thief makes now, also naming v2, to extend one of the
  owner's lines or to fork its key log.

This is backdating, and it cannot be solved by the signatures alone. Every
rule we tried either ignored it (and left the thief free) or acted on it by
reaching into the past (and broke the second and third points of section 1).
The only ways out are outside the signatures: a trusted time (timestamps), a
public order (a log), or several keys so that one leak is not enough (a
threshold).

## 3. The attempts

### 3.1 Decision B: old signatures expire with their keys

The first rule, adopted early in issue #55 and called "decision B" in the
discussion, said: a signature naming an older key-log version vk counts only
while its key is still listed in the latest version, no later version has
raised the threshold, and (later) no later version has changed extension data
that governs signatures; otherwise it is unconfirmed. Removing a key thus
shuts out the thief, at the price of the owner's own past.

The audits found what that price was:

- **Every routine change cascaded.** A key-log version that rotates a key,
  raises the threshold or adopts the timestamps extension names the version
  before it, which is older; its own signatures fell under the rule, so the
  new version was unconfirmed, and with it every later key-log version and
  everything signed under them (fourth and fifth reviews). A special case for
  key-log versions fixed that, but not the rest.
- **Frozen evidence decayed.** A branch carries its parent owner's signatures
  in `parent.signatures/`, unchanged until the branch point moves. When the
  authors replaced a laptop key, every journal's accepted copy of their papers
  became unconfirmed, for good.
- **Re-signing was the only cure, and it is impossible.** The obvious repair,
  "sign again before removing a key", requires the owner to find every copy of
  every version it ever signed. It cannot, by design.
- **Groups could not sign.** With threshold 2, a signature naming v3 and
  another naming v4 (after a member was added) never added up to two
  signatures of one key-log version.

The rule treated every key removal as a theft. Almost none are.

### 3.2 Retire and revoke

The replacement separates the two cases, as OpenPGP does with its soft and
hard revocation reasons (section 6):

- **retiring** a key (leaving it out of `keys`) changes only what can be
  signed from then on; past signatures stay valid forever;
- **revoking** a key (listing it in `revoked`) says it may be in other hands.
  Since signatures are undated, every signature by that key becomes
  unconfirmed, whenever it was made, unless something dates it.

This fixed rotation, but moved the problem into revocation, which still
reached backwards without limit:

- revoking a key that had signed earlier key-log versions unconfirmed the key
  log itself, and with it everything after (sixth review);
- every version of every line that the key had signed became unconfirmed,
  including the early versions of a line whose later versions were signed by
  a good key;
- every branch whose `parent.signatures/` used the key was downgraded.

Two repairs followed. Revocation does not touch the key log up to and
including the revoking version, since the owner's current keys sign that
version and so vouch for the history it extends. And, for lines, **a signed
version confirms what it extends**: if v7, signed by a key that counts,
extends v1 to v6, then v1 to v6 are confirmed, whoever signed them. An owner
that keeps publishing confirms its past without knowing where its copies are.
At first this was limited to versions unconfirmed "only because a key was
revoked later", which left holes (a stripped signature file made a gap that
v7 could not close); it now applies to every version a signed version
extends, and to lines only, the key log having its own rule.

A residual cost is stated in the text: a key that may have been exposed must
be revoked, not merely retired, or its holder can keep making signatures that
count by naming an old version.

### 3.3 Forks of the key log

Whoever holds `threshold` keys of any past key-log version, retired or not,
can make a different version after it: a fork of the owner. Each round of
rules met this differently:

- **Revocations on a thief's side.** If revocations count "on any side", the
  thief's side can list every key the owner ever used in `revoked`, and every
  signature the owner ever made becomes unconfirmed. So revocations made after
  the fork point now wait until the fork is resolved. The cost runs the other
  way: the owner's own revocations after the fork point also wait.
- **Keys added on a side.** If keys added after the fork point count, the
  thief gives itself fresh keys and signs with them forever. So they are
  unconfirmed while the fork lasts.
- **Everything after the fork point.** A first version made every signature
  naming a post-fork key-log version unconfirmed, on both sides. One old
  retired key at threshold 1 could then unconfirm years of the owner's
  work, which broke "signatures stay valid". The rule now is narrower: keys
  listed at the fork point keep counting, whatever side they name; only keys
  added after it are unconfirmed.
- **Thresholds.** The text had said that raising the threshold to 2 protects
  against a single stolen key. It does not: a threshold binds only signatures
  naming its own version, and a key listed under an earlier threshold of 1
  can still sign alone by naming that version. Only a threshold of 2 or more
  from the first version, or revocation, protects.

The core never resolves a fork; it reports it. An owner that cannot resolve
one replaces its identity by a new owner, announced through its keeper.

### 3.4 Unconfirmed, invalid, and what is mirrored

The word "unconfirmed" appeared before it was defined. For several rounds
the core knew only "signed" and "not signed, invalid", so an unconfirmed
version was in practice rejected, and an extension that "confirmed" it
turned a rejection into an acceptance, which the rules on extensions forbid.
It is now one status among three for versions (signed, unconfirmed, not a
version), defined once in section 13.2 and referred to elsewhere: kept,
shown and copied, but not relied on for pins, resolution, collection members
or branch points.

Three statuses were also too many for the reasons behind them. A missing key
log, a key-log version known with another digest, and a version beyond the
known head were at one point "unconfirmed", "unverifiable" and "unverifiable"
respectively, so a host that stripped more files got a milder verdict than one
that stripped fewer, and a forger naming a made-up key-log version got a
version shown as "unconfirmed". They were merged into one reason, "key-log
version not found", and archives refuse to add versions that rely on it. The
merger then lost the exemption for the sides of a known fork, so that an
archive holding the thief's side of the key log would refuse the owner's
versions (ninth review). Restored, the exemption still reached only the first
differing version of the other side, which is all the evidence of forks keeps
(tenth review); it was completed by counting as on a known side any key-log
version the reader reaches from the fork point through versions it holds, each
signed by the version before. Each simplification has to be checked against
every case the old wording covered.

One attempt, in the sixth round, said that unconfirmed versions are not
copied into mirrors until confirmed. Since OCFL cannot skip a version, a
line whose early versions were signed by a key later revoked could then not
be mirrored at all.

### 3.5 Removing things

Four rules, added at different times for good reasons, removed something:

- **mirrors dropped** unconfirmed versions when a signed history departed from
  them (sixth round). A thief with an old retired key signed a v6' of the
  owner's line; every mirror dropped the owner's v6 and v7 and took the
  thief's;
- **archives set aside** (truncated) versions found not to be versions of the
  line, keeping the first one as evidence. The check that the removed version
  really was not a version was missing; when added, it could not be made,
  because only the first removed inventory was kept and a later removed
  version might have been signed and confirmed it;
- **archives removed signature files** that did not verify under their own
  key, so that planted junk could not block a key's real signature (files are
  named by key and never replaced). A host could then remove a valid file
  claiming it did not verify, and set aside the versions it left unsigned;
  and "stray" files, never defined, could include the timestamp files of an
  extension the archive did not know;
- **fork resolution** judged signatures naming the losing side as if they
  named the fork point, which made the owner's signatures by keys added after
  the fork point invalid, not unconfirmed, in any copy that resolved the fork
  the wrong way (section 3.6), and so open to setting aside.

Each was an attack surface for the same reason: the condition that triggered
the removal could be produced or faked by someone other than the owner. After
the ninth review the three removals were withdrawn, and fork resolution was
changed rather than removed: signatures naming a losing side whose key is not
listed at the fork point are unconfirmed, never invalid. Nothing is dropped,
set aside or deleted on the strength of signatures; a version that slipped in
unchecked is reported and never shown as a version, but stays. Signature files
are named by key and by a digest of their own content, so a junk file sits
beside the real one and is reported, and nothing ever needs removing. A wrong
resolution in one copy is reversed by merging copies.

**Keeping everything moved the problem to the door.** Once nothing is removed,
whatever enters an object stays, and OCFL cannot skip a version: a version at
v5 that is not the owner's holds that number for good, and the owner's real v5
can never be added to that archive (tenth review). The rules still let such
versions in. A thief holding a revoked key could sign a new v5, which was
merely unconfirmed, and archives were allowed to add unconfirmed versions. In
an archive kept in git, a pull request adding an unsigned v5 passed the
append-only check, which looked only at what changed, not at who signed; once
a maintainer merged it, by mistake or automatically, it could not be undone.
And an owner's tool could sign v6 on top of such a v5, making its content part
of the owner's signed history.

The answer was to guard the door instead of cleaning up afterwards: **archives
add only versions signed under the core**, a version counting as signed when a
later signed version in the same copy extends it, and nothing that only an
extension decides (a fork resolved by time) lets a version in. A mirror whose
source ends in unconfirmed versions copies up to the last signed one and
waits: it lags, it is not blocked. Adding anything else fails verification, so
in git the pull request goes red before anyone can merge it, and owner tools
never build on a version that is not a version. A version that gets in against
the rule anyway makes that archive's copy one side of a fork of the line, kept
and reported; the owner continues elsewhere.

### 3.6 Timestamps

The timestamps extension (`opensheaf-timestamps-0.1.md`) adds the missing
time: RFC 3161 tokens from listed authorities and OpenTimestamps proofs, kept
beside signature files. It met its own difficulties:

- **An upper bound used as a cutoff.** A token proves that a file existed by
  a time, not that it was made then. The extension confirmed a revoked key's
  signatures dated before the time of the revoking version; re-stamping gave
  that version several times, a host stripped the earliest, and the cutoff
  moved later, confirming more of the thief's signatures. The owner now
  states `since`, its own estimate of when the key may have been exposed,
  and only signatures dated before both `since` and the revocation count;
  verifiers merge the timestamp files of every copy they see.
- **Stripping decides forks.** Forks are resolved by the earliest side. A host
  that strips the owner's stamps makes the thief's side the only dated one. So
  a fork is resolved only when every side is dated and the times are not
  tied. The ninth review found the converse: an honest tool told to stamp an
  undated side on discovery would date the owner's stripped side late and
  hand the fork to the thief. That advice was dropped; the text says that a
  stripped copy can resolve a fork wrongly for readers who see only it.
- **The declaration in force.** Which authorities and which policy apply
  during a fork? Read from the latest key-log version, the thief's side could
  list an authority it controls. A fork is now judged under the declaration of
  its fork point.
- **Authorities.** Removing an authority from the list cannot undo the tokens
  it already issued, and a compromised authority can backdate. The list is
  now cumulative, and the text says plainly that the only remedy for a
  compromised authority is a new owner.
- **Adopting late.** An owner that adopts the extension at key-log v5 can
  never resolve a fork at v1 to v4. The examples now adopt it at v1.
- **Completing proofs.** OpenTimestamps proofs are completed later; replacing
  the pending file contradicted "witnesses are never replaced", so completed
  proofs are new files.

The extension shrank in the end to two jobs: confirming signatures of a
revoked key that are dated before the revocation, and resolving key-log forks
by time. It may confirm what the core leaves unconfirmed; it never takes away
what the core lets count, except that resolving a fork applies the owner's
side's revocations, as the core would without a fork.

### 3.7 Key logs inside branches

Branches first carried their parent owner's key log in their content
(`parent.keylog/`), at every level of `parent.chain/`. That copy added no
trust (a key log checks itself from its owner name), was frozen at branching
time while the rules want the latest known version (to see a later
revocation), and was duplicated in every branch. Key logs now travel beside
objects as owner objects in the same storage root, one per owner, kept
through takedowns of the lines they sign. The cost is a dependency: an archive
that keeps a branch must keep the owner objects of its whole chain, and a
missing one leaves the signatures that need it unconfirmed.

## 4. What we learnt

### 4.1 Never remove on evidence an attacker can shape

Every destructive rule (section 3.5) was triggered by a condition someone
else could produce: a status that depends on which files a host serves, a
fork a thief can make, a signature file a host can plant or delete. The rule
that survived is to keep everything, report it with its status, and let
readers merge copies. Removal is left to takedowns, which are decided by
people and the law, not by signatures. Its corollary: since nothing leaves,
guard the door, and add only what is signed under the core.

### 4.2 Resolution confirms or unconfirms; it never destroys

A wrong resolution of a fork in one copy, caused by stripped stamps, must be
reversible by a copy that has them. So resolution may only move things
between "counts" and "unconfirmed", never to "invalid" or "removed".

### 4.3 Define statuses once

Patching a rule in one section while three others restated it produced most
of the contradictions of the fourth to sixth reviews. Statuses are now
defined in one place, section 13.2, and every other section refers to it.

### 4.4 A rule binds only what names it

Thresholds, revocations and declarations apply from the key-log version that
states them. Any rule that reached backwards (decision B, revocation without
limit, a threshold "governing" earlier keys) produced cascades.

### 4.5 The irreducible limit

Without time or a public order, whoever holds `threshold` keys of an old
key-log version can fork the owner's key log at that version, and suspend
revocations made after it. The core can only limit the damage: the past is
never erased, keys added on a side do not count, and the fork is reported.
The defences are outside the core's signatures: the timestamps extension
adopted from the first key-log version, or a threshold of 2 or more from the
first version (1 with a spare key protects against loss; 2 of 3 also against
theft). When a fork cannot be resolved, or a listed timestamp authority is
compromised, the owner replaces its identity by a new one. The specification
now says this plainly instead of implying more.

### 4.6 Rewrite, do not patch

Rounds four to six patched each finding with an exception, and the text
grew; each exception interacted with the others. The seventh round rewrote
sections 6.5, 13.2, 14 and 15 around the statuses and cut about 14 per cent of
their words; the ninth removed four mechanisms outright. The audits found
fewer and subtler problems after each rewrite, and more after each patch.

## 5. The rules as they stand

After the commit that follows the tenth review, the rules of PR #30 are, in
short:

- a signature counts if it verifies under the key-log version it names, the
  key being listed there; later key-log versions never take it away;
- a retired key changes nothing in the past; a revoked key's signatures are
  unconfirmed, except in the key log up to the revoking version, in versions
  of a line that a later signed version extends, and where the timestamps
  extension dates them before `since` and the revocation;
- versions are signed, unconfirmed or not a version (section 13.2);
  unconfirmed versions are kept, shown and mirrored, not relied on;
- the core never resolves a key-log fork: keys of the fork point keep
  counting, keys added after it are unconfirmed, revocations after it wait;
- archives add only versions signed under the core, so a mirror lags at the
  last signed version; nothing is dropped, set aside or deleted on the
  strength of signatures; signature files are named by key
  and their own digest, so planted files sit beside real ones;
- the timestamps extension, declared from the first key-log version, confirms
  dated signatures of revoked keys and resolves forks by time, without ever
  destroying anything; anyone may stamp any signature file, and the earliest
  stamp wins.

## 6. How others handle it

Each of these meets the same problem; the notes are brief, and points we are
less sure of are marked.

- **OpenPGP** distinguishes revocation reasons: a key "superseded" or
  "retired" is a soft revocation, and implementations generally keep valid
  the signatures dated before it; a key "compromised" (or without a reason)
  is a hard revocation, and its signatures are distrusted whatever their
  date, since the date in a signature is the signer's claim. Our retire and
  revoke are the same split, for the same reason.
- **Git** signs commits and tags with OpenPGP, SSH or X.509 keys. With SSH
  keys, the verifier's `allowed_signers` file can bound a key with
  `valid-after` and `valid-before`, checked against the commit's own time,
  which its author sets: backdating is not prevented. Trust is local to each
  verifier.
- **Radicle** gives each repository an identity document listing delegates
  and a threshold, and each change of it is signed by a threshold of the
  delegates of the previous one, as our key logs are (see
  [radicle.md](radicle.md)). As far as we know it has no time source and no
  revocation of a node key beyond leaving it out of the delegates, so a
  leaked delegate key can sign under an old identity revision; we have not
  checked how its tooling reports such divergence (uncertain).
- **TUF** (The Update Framework) uses roles with keys and thresholds; a new
  root metadata version is signed by a threshold of both the old and the new
  root keys. It relies on expiry dates and a timestamp role to stop freeze and
  rollback attacks: metadata is valid only for a while, which suits software
  updates but not a scholarly record meant to be checkable decades later.
- **Sigstore** avoids long-lived keys: a signer gets a certificate valid for
  minutes, and the signature is entered in a transparency log (Rekor), whose
  inclusion time is the trusted time of signing. Key compromise then matters
  only within that short window.
- **Certificate Transparency** and similar logs are append-only, publicly
  audited, and watched by monitors and witnesses who compare what the log
  shows to different readers, so that a log showing two histories (a split
  view) is detected.

**What a log would add.** The two missing things in section 2 are time and
order. Timestamps give time per file, but can be stripped and only bound
times from above. A transparency log of key-log versions (and perhaps of
signatures), cosigned by independent witnesses, would give a public order:
a fork would be visible to anyone the moment its second side was logged, the
first logged side would be the owner's by default, and stripping would not
help, since the log is not served by the host. The costs are an operator,
a dependency the specification has avoided so far, and a privacy question
(owner names are pseudonyms, but a log of everything an owner signs is a
profile). This is an open idea, to be discussed in issue
[#55](https://github.com/opensheaf/opensheaf.github.io/issues/55), not a
proposal.

## 7. Open questions

- Whether owners should be encouraged, or required for some uses (a journal,
  a repository), to adopt the timestamps extension from the first key-log
  version or a threshold of 2 or more (#55).
- Whether a witness or transparency log should become an extension, beside
  timestamps (#55).
- How a new owner that replaces a forked one is announced and recognised,
  beyond "through its keeper" (#55).
- How the branch rules meet merging between lines: numbering on branches,
  moving a branch point while keeping a branch's own files, and how the
  originator takes in another line's work
  ([#57](https://github.com/opensheaf/opensheaf.github.io/issues/57)).
- Whether core-only verifiers, which cannot resolve forks, should report a
  forked owner more prominently than other unconfirmed states.

## 8. Pointers

- [PR #30](https://github.com/opensheaf/opensheaf.github.io/pull/30), branch
  `proposal/identity`: the specification, sections 6.5 (owners, key logs,
  signing, retiring and revoking, forks), 13.2 (signatures and statuses), 14
  (verification) and 15 (security), and its changelog, which records each
  round; `opensheaf-timestamps-0.1.md`, the timestamps extension;
  `opensheaf-git-0.1.md`, section 5.1, the append-only rules in git.
- Issues [#55](https://github.com/opensheaf/opensheaf.github.io/issues/55)
  (owners and archives) and
  [#57](https://github.com/opensheaf/opensheaf.github.io/issues/57) (merging
  between lines).
- [radicle.md](radicle.md), for delegates, thresholds and identity documents.
