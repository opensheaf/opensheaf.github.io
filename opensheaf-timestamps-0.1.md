# OpenSheaf timestamps

*Extension to the OpenSheaf specification 0.1. Version 0.1 (draft), 17 November 2026. How an owner dates its signatures with RFC 3161 tokens or OpenTimestamps proofs, declares that it does so in its key log, and so confirms the signatures that a key made before its owner revoked it, and resolves forks of its key log by time. The extension is named by the URI `https://opensheaf.org/opensheaf-timestamps-0.1`. The text is licensed under CC BY-SA 4.0; its JSON Schema is dedicated to the public domain under CC0 1.0.*

> [!WARNING]
> **Proposal.** This extension belongs to the identity proposal of the specification (owners, key logs and signatures, sections 6.5 and 13.2), on the branch `proposal/identity` (PR #30), not yet agreed. It is discussed in [issue #55](https://github.com/opensheaf/opensheaf.github.io/issues/55).

## 1. Introduction (non-normative)

In the [OpenSheaf specification](opensheaf-specification-0.1.md), every version of a line is signed by its owner, under a version of the owner's key log, and a signature counts when it is valid under the key-log version it names, and keeps counting (sections 6.5 and 13.2 of the specification). Signatures say who made a version, not when. Two consequences follow in the core:

- **Signatures of a revoked key are unconfirmed**, since nothing tells those the owner made before the revocation from those a thief makes after, except where a later signed version of the same line confirms them.
- **Forks of a key log are reported, never resolved**, and the owner's revocations made after the fork point wait until it is.

Timestamps answer both, by showing that a signature existed by a date. A single researcher who never loses a key to others needs none of this. A journal, an institution, or anyone who wants a stolen key to cost little adopts this extension in its key log, from its first version, so that every signature it makes is dated before any key may have to be revoked.

## 2. Conventions

The key words MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, RECOMMENDED, NOT RECOMMENDED, MAY and OPTIONAL in this document are to be interpreted as described in BCP 14 (RFC 2119 and RFC 8174) when, and only when, they appear in all capitals. Terms are those of the specification: owner, key log, key-log version, signature file, witness, line, branch.

This extension follows the extension mechanism of section 4 of the specification: it never changes the meaning of what the specification defines, nor relaxes its requirements; it adds evidence, and rules that use it. A reader that does not know it reads and verifies everything by the core rules, and ignores the files and data it defines.

## 3. Timestamps

A timestamp of a signature file shows that the file, and so the signature and the signed message it holds, existed by a date. It proves existence, nothing more. Two kinds are defined, which an owner MAY combine:

- **RFC 3161 tokens**, from a time-stamping authority (a free public one, or a qualified provider under eIDAS): a file holding a DER-encoded `TimeStampResp` whose message imprint is the SHA-512 digest of the bytes of the signature file, requested with the authority's certificates included (`-cert` with `openssl ts -query`), so that it can be checked with `openssl ts -verify` without fetching them; its name ends in `.tsr`.
- **OpenTimestamps proofs** of the bytes of the same signature file; their names end in `.ots`.

A timestamp file of the signature file `<version>/signature-<k>.json`, in the object's extension folder `extensions/opensheaf-witnesses/`, is `<version>/signature-<k>.json.<d>.tsr` or `<version>/signature-<k>.json.<d>.ots`, beside it, where `<d>` is the first 16 characters of the lowercase base32 (RFC 4648, without padding) SHA-256 digest of the timestamp file's own bytes. Names made from the contents never collide: two copies that add timestamps independently can be merged by taking every file of both, and the same timestamp has the same name everywhere.

Both kinds stamp the signature file as stored. Signature files and their timestamp files are never re-serialised, replaced or removed once made (section 13.2 of the specification): a timestamp stamps their bytes, and a copy may already hold them. An OpenTimestamps proof is pending when made, and complete once a Bitcoin block attests it; the completed proof is a new file, named from its own bytes, beside the pending one, which stays unchanged. A signature file MAY be stamped again later, by anyone holding a copy, when an algorithm that its timestamps rely on weakens.

A timestamp of a version's checksum file MAY also be kept, as `<version>/inventory.json.sha512.<d>.tsr` or `.<d>.ots`; it dates the version, not a signature, and is not used by the rules below.

## 4. The owner's declaration

An owner adopts this extension in its key log: a version of the key log holds, in its `keys.json`, under `extensions` (section 6.5 of the specification), an entry keyed by `https://opensheaf.org/opensheaf-timestamps-0.1`, an object with:

- `timestamps`, REQUIRED: `true`: the owner timestamps every signature it makes, of its key log and of its lines;
- `timestampAuthorities`, OPTIONAL: the RFC 3161 time-stamping authorities the owner trusts, each the SHA-256 fingerprint (lowercase hexadecimal) of the authority's signing certificate or of the root certificate of its chain. Without any, only OpenTimestamps proofs are used.

The declaration validates against the schema of appendix A; anything else in `keys.json` is not a declaration. It is part of the key-log version, signed with it, and changed only by a new version.

**The declaration in force** is that of the latest version of the key log known to the reader, except for a fork, which is always judged under the declaration of the last version all sides share (section 7), whatever is declared after it. The rules of section 7 apply only under a declaration in force. An owner MAY drop the declaration by a later key-log version without it: the rules of the specification alone then apply, to everything, and no signature is confirmed by this extension; an owner that has revoked a key SHOULD NOT drop it.

## 5. Checking a timestamp

A timestamp is **valid** for a signature file when:

- for an RFC 3161 token: its message imprint is the SHA-512 digest of the file's bytes; its signing certificate, or the root of the chain it carries, has a fingerprint listed in `timestampAuthorities` of the declaration in force or of an earlier version of the key log; the chain was valid at the token's `genTime`, which means that every certificate from the signing certificate to the root was within its validity period at `genTime`, that the signing certificate is for time stamping (RFC 3161, section 2.3), and that no revocation known to the reader dates from before `genTime` (as `openssl ts -verify` checks with `-attime` set to `genTime` and the root certificate whose fingerprint is listed, or that is the root of the listed signing certificate); and the token verifies;
- for an OpenTimestamps proof: it is complete, attested in a Bitcoin block; a pending proof counts for nothing, and its completed proof is a separate file (section 3).

The **date** of a valid timestamp is the `genTime` of an RFC 3161 token, or the time of the Bitcoin block an OpenTimestamps proof reaches. The earliest valid timestamp of a signature file is its date.

## 6. The time of a version

The **time** of a version (of a line or of a key log) is the `threshold`-th earliest of the dates of its valid signature files from distinct keys naming one key-log version, `threshold` being that key-log version's. A version with fewer dated signatures has no time, and cannot decide a fork nor date a revocation (section 7); owners therefore stamp each key-log version when they make it, with an RFC 3161 token where they cannot wait for an OpenTimestamps proof to complete.

Two times are a **tie** when they are equal, or when one of them is the time of a Bitcoin block and they are within two hours of each other, since block times are that uncertain. A tie is reported and decides nothing.

## 7. What timestamps add to the core

Under a declaration in force, these rules add to those of the specification. They only confirm what the core leaves unconfirmed, and resolve what it leaves unresolved; resolving a fork applies the revocations of the owner's side, as the core does where there is no fork, which is the one exception that section 4 of the specification allows. They never make valid what the core rejects, nor invalid what it accepts.

**Signatures of a revoked key.** A signature that the core leaves unconfirmed only because its key is revoked counts if its date is earlier than the time of the first key-log version that lists the key in `revoked`, and than the earliest `since` given for that key on the owner's side. If that version has no time, none is confirmed. The time of the revoking version dates the end of the owner's trust in a key, not its theft: without `since`, signatures that a thief made and stamped before the revocation are confirmed too, so owners revoke a key as soon as they fear it exposed, and give `since` when they can tell when the exposure began.

**Forks of a key log.** A fork (section 6.5 of the specification), of two sides or more, is judged under the declaration of the last version all sides share, never under one of a side, so that a side cannot bring an authority of its own. If the first differing version of every side has a time, and one is earlier than every other and in a tie with none, its side is the owner's, and the others are reported; otherwise the fork stays unresolved, as in the core: a side never wins because another's timestamps are missing, since a host can strip them from a copy. A fork within a side is resolved in the same way. Once a fork is resolved, the owner's side is the key log: the keys it adds count, its revocations apply, and those listed only on other sides are ignored. A fork at a version before the owner adopted the extension is never resolved by it.

**Missing timestamps** never make anything unconfirmed: they only leave unresolved, or unconfirmed, what the core leaves so.

## 8. Copies and branches

Timestamp files are witnesses, kept in the object's extension folder, and travel with the object as its signature files do (sections 6.5 and 13.2 of the specification), also in the evidence of forks. Copies that added different timestamp files are merged by keeping every file (section 3).

A branch keeps the evidence of its parent version as content (section 10.5 of the specification): `parent.signatures/` holds the parent owner's signature files of the parent version with their timestamp files beside them, under the same file names, without the `<version>/` folder (`parent.signatures/signature-<k>.json.<d>.tsr`); the timestamp files of the parent owner's key log are in its owner object, which travels with the branch (section 6.5 of the specification). Under a declaration of the parent's owner, a branch MUST NOT be taken from a parent version whose timestamps are still pending, and its evidence carries complete proofs only, since the files of a version, once made, never change. A branch whose evidence carries a pending proof is reported: the pending proof counts for nothing, and the verdict of the branch point is the one that the rest of its evidence gives.

## 9. Verification

A verifier that knows this extension, in addition to the checks of section 14 of the specification:

- validates each declaration against the schema of appendix A;
- merges the timestamp files of every copy it sees of a signature file, of the object and of its owner objects, which the names of section 3 allow, before computing dates, so that a timestamp stripped from one copy is restored from another;
- checks every timestamp file it finds against the signature file it stamps (section 5), and that its name matches the digest of its bytes (section 3), reporting each as valid, invalid, pending, or from an authority not listed;
- computes the time of each key-log version and of each version signed under a declaration, and reports those without a time as undated, a warning;
- confirms signatures of revoked keys, and resolves forks of key logs, as section 7 says, reporting ties;
- checks the timestamp files inside `parent.signatures/` and at every level of `parent.chain/` of every branch, and reports those that are pending (section 8).

## 10. Guidance for tools

- Tools that create an owner SHOULD offer to adopt this extension in the first version of its key log: without it, the signatures of a key the owner has to revoke cannot be confirmed by their dates, and a fork of the key log cannot be resolved.
- Tools SHOULD timestamp each signature when they make it, under a declaration, and before a version leaves its owner's hands.
- Tools SHOULD let an owner choose its authorities, and SHOULD keep an OpenTimestamps proof beside an RFC 3161 token where an owner wants evidence that rests on no authority.
- Tools MAY stamp signature files again when an algorithm that their timestamps rely on weakens; anyone holding a copy can.

## 11. Security considerations

- **Trust.** An RFC 3161 token is immediate and checkable with common tools, but rests on the authority's clock and keys: an authority that misdates, or whose key is stolen, can date a signature falsely. Listing the authorities in the key log keeps anyone else from dating with an authority of their own. An authority once listed stays trusted for its tokens, since a compromised one can backdate them anyway; and listing a root certificate trusts every authority that root certifies, so an owner that wants a single authority lists the fingerprint of its signing certificate. An OpenTimestamps proof rests on no authority, only on Bitcoin, but is complete only after a pending period of hours, and its date is uncertain by about as long.
- **Stripping.** A host can remove timestamp files from a copy; the signatures they confirmed are then unconfirmed again, and a fork unresolved, until a copy with the files restores them, and nothing that the core lets count is lost. A host that removes the earliest timestamps of a revoking key-log version and keeps later ones moves its time later; `since`, signed by the owner, bounds what this can confirm, and readers merge the timestamp files of every copy they see (section 9).
- **Freshness.** A copy that withholds later versions of a key log also withholds later declarations and revocations; the declaration in force is only as recent as the key log a reader has seen.
- **Forks.** A side of a fork cannot bring its own authorities, nor win by stripping the other sides' timestamps (section 7). But time decides for whoever stamps first: a thief who holds `threshold` keys of a version, forks the key log there and stamps the fork before the owner's next version, wins it, even if it publishes the fork later. Owners who want to resist the theft of one key use a threshold of 2 with three keys kept apart, from the first version of their key log (section 6.5 of the specification). An owner that adopts the extension late cannot have forks at earlier versions resolved.
- **Revocation.** Revocation confirms the stamped signatures made before it, a thief's included (section 7); the time between a theft and its revocation is the owner's exposure.

## Appendix A. JSON Schema (normative)

The data of the declaration, the value of `extensions["https://opensheaf.org/opensheaf-timestamps-0.1"]` in `keys.json`, validates against [opensheaf-timestamps-0.1.schema.json](https://opensheaf.org/schemas/opensheaf-timestamps-0.1.schema.json) (JSON Schema 2020-12, CC0 1.0).

## Appendix B. Example (non-normative)

The `keys.json` of the first version of an owner's key log, adopting the extension from the start (section 1), with one RFC 3161 authority (a placeholder fingerprint) and OpenTimestamps; its genesis record lists the same `keys` and `threshold`:

```json
{
  "format": "opensheaf-keys/0.1",
  "keys": [ "did:key:z6MkhaXgBZDvotDkL5257faiztiGiC2QtKLGpbnnEGta2doK",
            "did:key:z6MkpTHR8VNsBxYAAWHut2Geadd9jSwuBV8xRoAnwWsdvktH" ],
  "threshold": 1,
  "extensions": {
    "https://opensheaf.org/opensheaf-timestamps-0.1": {
      "timestamps": true,
      "timestampAuthorities": [ "5b4e3f0c9d2a7e18c6f4b0a39d7e2c51f8a6b3d09e4c7a12f5b8d6e3a0c9f147" ]
    }
  }
}
```

The files of one signature of that version, in the owner object's extension folder: an RFC 3161 token, a pending OpenTimestamps proof, and the completed proof written beside it later, each named from the digest of its own bytes (placeholder digests):

```
extensions/opensheaf-witnesses/v1/signature-qvi7ibhm7zsahqx6.json
extensions/opensheaf-witnesses/v1/signature-qvi7ibhm7zsahqx6.json.q7swxsz56bfiyotn.tsr
extensions/opensheaf-witnesses/v1/signature-qvi7ibhm7zsahqx6.json.hm5uhlee72brbz64.ots
extensions/opensheaf-witnesses/v1/signature-qvi7ibhm7zsahqx6.json.yq77barzw3gj7dbj.ots
```

If the owner later revokes the first key, in version 3 of its key log, with `since` the time it believes the key was exposed, the signatures of that key whose date is earlier than both the time of version 3 and `since` count again for readers that know this extension; the others stay unconfirmed, unless a later signed version of the same line confirms them (section 6.5 of the specification).

## Appendix C. References

- [OpenSheaf specification 0.1](opensheaf-specification-0.1.md), sections 4, 6.5, 10.5, 13.2 and 14
- [RFC 3161](https://www.rfc-editor.org/rfc/rfc3161), Time-Stamp Protocol, and [RFC 5816](https://www.rfc-editor.org/rfc/rfc5816), its update for other hash algorithms
- [OpenTimestamps](https://opentimestamps.org/)
- [RFC 2119](https://www.rfc-editor.org/rfc/rfc2119) and [RFC 8174](https://www.rfc-editor.org/rfc/rfc8174)

## Changelog

- **0.1 (draft), 17 November 2026:** first draft, moving the timestamp rules out of the identity proposal of the specification: RFC 3161 tokens and OpenTimestamps proofs of signature files, the owner's declaration in `keys.json` under `extensions` (`timestamps`, `timestampAuthorities`), checking at `genTime` with listed authorities and complete proofs only, re-stamping, the time of a version and ties, resolution of key-log forks by time, confirmation of signatures after changes of keys, missing timestamps as unconfirmed, branches with complete proofs, guidance and security considerations.
- **0.1 (draft), 17 November 2026, revised after an audit:** completed OpenTimestamps proofs are new files (`.<n>.ots`), never replacements; one definition of the declaration in force, that of the last shared version during a fork, against which both sides' timestamps are checked; a fork is resolved only when both sides are dated and not tied; a removed authority's earlier tokens are checked against the declaration that listed it; the validity of a chain at `genTime` defined; the time of a version whose signatures name several key-log versions; the consequences of a key-log version without a time; the cost of adopting the extension late, and the example adopting it in the first version; dropping a declaration; the limits of removing authorities and of listing roots; the names in `parent.signatures/`, and pending proofs in a branch's evidence reported.
- **0.1 (draft), 17 November 2026, revised:** the timestamp files of a parent owner's key log are in its owner object, beside the branch, no longer in `parent.keylog/`.
- **0.1 (draft), 17 November 2026, revised after a fifth audit:** following the specification, which no longer leaves unconfirmed the signatures of a retired key or under a raised threshold, the extension confirms the signatures of revoked keys dated before the revocation, and resolves forks of key logs; the rules on later changes of keys, thresholds and declarations are gone, and changing or adopting a declaration late unconfirms nothing; missing timestamps no longer make a version unconfirmed, and undated versions are reported as a warning; timestamp files named by the digest of their own bytes, so that copies that add them independently merge; forks of more than two sides; `all` recommended from the first version; the first-stamp advantage of a thief, and the exposure between a theft and its revocation, stated.
- **0.1 (draft), 17 November 2026, revised after a sixth audit:** a revoked key's signature is confirmed only if dated before both the time of the revoking version and its `since`, the owner's estimate of the exposure, which bounds what stripping the earliest timestamps of the revoking version can confirm; verifiers merge the timestamp files of every copy they see; once a fork is resolved, the declaration in force is the latest of the owner's side, and only that side's revocations apply; dropping the declaration ends every confirmation it gave; with `keylog`, the extension confirms nothing on the lines; a threshold binds only the signatures naming its version, so a threshold of 2 or more is recommended from the first version.

- **0.1 (draft), 17 November 2026, simplified after a seventh audit:** `timestamps` is `true` (no `keylog` or `all`); a fork is always judged under the declaration of the last version all sides share, and resolving it makes the owner's side the key log, its revocations applying, the one exception the specification allows; the earliest known `since` of a key on the owner's side applies; an authority once listed stays trusted for its tokens (no clause on removed authorities); re-stamping only when an algorithm weakens, by anyone holding a copy; timestamp files kept in the evidence of forks; adopting the extension late cannot resolve forks at earlier versions; sections 4, 7 and 11 shortened.
