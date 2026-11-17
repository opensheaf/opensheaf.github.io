# OpenSheaf timestamps

*Extension to the OpenSheaf specification 0.1. Version 0.1 (draft), 17 November 2026. How an owner dates its signatures with RFC 3161 tokens or OpenTimestamps proofs, declares that it does so in its key log, and so resolves forks of its key log by time and confirms the signatures that a key made before its owner revoked it. The extension is named by the URI `https://opensheaf.org/opensheaf-timestamps-0.1`. The text is licensed under CC BY-SA 4.0; its JSON Schema is dedicated to the public domain under CC0 1.0.*

> [!WARNING]
> **Proposal.** This extension belongs to the identity proposal of the specification (owners, key logs and signatures, sections 6.5 and 13.2), on the branch `proposal/identity` (PR #30), not yet agreed. It is discussed in [issue #55](https://github.com/opensheaf/opensheaf.github.io/issues/55).

## 1. Introduction (non-normative)

In the [OpenSheaf specification](opensheaf-specification-0.1.md), every version of a line is signed by its owner, under a version of the owner's key log that lists the keys allowed to sign (sections 6.5 and 13.2 of the specification). A signature counts when it is valid under the key-log version it names, and keeps counting: an owner retires keys and raises its threshold without undoing anything it signed. Signatures say who made a version; they say nothing of when. Two consequences follow in the core:

- **Signatures of a revoked key are unconfirmed.** An owner revokes a key that may have been exposed. Since nothing dates a signature, the core cannot tell the signatures the owner made with that key before the revocation from those that whoever holds it makes afterwards, and leaves them all unconfirmed.
- **Forks of a key log are reported, not resolved.** Keys of a version, retired or revoked since, can still sign a different next version, and so fork the key log; nothing in the core says which side is the owner's.

Timestamps answer both, by showing that a signature existed by a date. A single researcher who never loses a key to others needs none of this. A journal, an institution, or anyone who wants a stolen key to cost little may want it, and may want it from a provider it can name. So timestamps are an extension, which an owner adopts by declaring it in its key log, and SHOULD adopt from the first version of its key log, with `all`, so that every signature it makes is dated before any key may have to be revoked.

## 2. Conventions

The key words MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, RECOMMENDED, NOT RECOMMENDED, MAY and OPTIONAL in this document are to be interpreted as described in BCP 14 (RFC 2119 and RFC 8174) when, and only when, they appear in all capitals. Terms are those of the specification: owner, key log, key-log version, signature file, witness, line, branch.

This extension follows the extension mechanism of section 4 of the specification: it never changes the meaning of what the specification defines, nor relaxes its requirements; it adds evidence, and rules that use it. A reader that does not know it reads and verifies everything by the core rules, and ignores the files and data it defines.

## 3. Timestamps

A timestamp of a signature file shows that the file, and so the signature and the signed message it holds, existed by a date. It proves existence, nothing more. Two kinds are defined, which an owner MAY combine:

- **RFC 3161 tokens**, from a time-stamping authority (a free public one, or a qualified provider under eIDAS): a file holding a DER-encoded `TimeStampResp` whose message imprint is the SHA-512 digest of the bytes of the signature file, requested with the authority's certificates included (`-cert` with `openssl ts -query`), so that it can be checked with `openssl ts -verify` without fetching them; its name ends in `.tsr`.
- **OpenTimestamps proofs** of the bytes of the same signature file; their names end in `.ots`.

A timestamp file of the signature file `<version>/signature-<k>.json`, in the object's extension folder `extensions/opensheaf-witnesses/`, is `<version>/signature-<k>.json.<d>.tsr` or `<version>/signature-<k>.json.<d>.ots`, beside it, where `<d>` is the first 16 characters of the lowercase base32 (RFC 4648, without padding) SHA-256 digest of the timestamp file's own bytes. Names made from the contents never collide: two copies that add timestamps independently can be merged by taking every file of both, and the same timestamp has the same name everywhere.

Both kinds stamp the signature file as stored. Signature files and their timestamp files are never re-serialised, replaced or removed once made (section 13.2 of the specification): a timestamp stamps their bytes, and a copy may already hold them. A signature file MAY be stamped again later (re-stamping), by another authority or with an OpenTimestamps proof, so that the evidence outlives the certificates of the first. An OpenTimestamps proof is pending when made, and complete once a Bitcoin block attests it; the completed proof is a new file, named from its own bytes, beside the pending one, which stays unchanged.

A timestamp of a version's checksum file MAY also be kept, as `<version>/inventory.json.sha512.<d>.tsr` or `.<d>.ots`; it dates the version, not a signature, and is not used by the rules below.

## 4. The owner's declaration

An owner adopts this extension in its key log: a version of the key log holds, in its `keys.json`, under `extensions` (section 6.5 of the specification), an entry keyed by `https://opensheaf.org/opensheaf-timestamps-0.1`, an object with:

- `timestamps`, REQUIRED: `"keylog"`, every version of the key log is timestamped, or `"all"`, every version of the key log and of the owner's lines is timestamped;
- `timestampAuthorities`, OPTIONAL: the RFC 3161 time-stamping authorities the owner trusts, each the SHA-256 fingerprint (lowercase hexadecimal) of the authority's signing certificate or of the root certificate of its chain. Without any, only OpenTimestamps proofs are used.

The data of the declaration validates against the schema of appendix A; anything else in `keys.json` (a top-level `timestamps` field, for instance) is not a declaration. The declaration is part of the key-log version, so it is signed with it, and changed only by a new version.

`timestamps` says what the owner stamps, and what verifiers report as undated when a timestamp is missing (section 9). Only with `all` can the signatures of a revoked key on the owner's lines be confirmed, since only then are they stamped; with `keylog`, the declaration resolves forks, and confirms only the signatures of the key log itself.

**The declaration in force**, for every check of this extension, is that of the latest version of the key log known to the reader: an owner that adopts the extension, or changes its authorities, does so for everything checked afterwards. While the key log is forked, the declaration in force is that of the last version all sides share, for every check on any side, since the latest version known is not defined across a fork (section 7). Changing the declaration never leaves unconfirmed a signature that the specification lets count (section 7).

An owner MAY drop the declaration, by a later key-log version without it: afterwards only the rules of the specification apply, so later forks are reported, not resolved, and signatures of keys revoked later are not confirmed.

## 5. Checking a timestamp

A timestamp is **valid** for a signature file when:

- for an RFC 3161 token: its message imprint is the SHA-512 digest of the file's bytes; its signing certificate, or the root of the chain it carries, has a fingerprint listed in `timestampAuthorities` of the declaration in force, or of an earlier declaration (below); the chain was valid at the token's `genTime`, which means that every certificate from the signing certificate to the root was within its validity period at `genTime`, that the signing certificate is for time stamping (RFC 3161, section 2.3), and that no revocation known to the reader dates from before `genTime` (as `openssl ts -verify` checks with `-attime` set to `genTime` and the root certificate whose fingerprint is listed, or that is the root of the listed signing certificate); and the token verifies. An authority that the owner stops trusting is removed from the list by a new key-log version: its tokens then count only if it was listed in a declaration of an earlier version, and their `genTime` is earlier than the time of the version that removed it (section 6);
- for an OpenTimestamps proof: it is complete, attested in a Bitcoin block; a pending proof counts for nothing, and its completed proof is a separate file (section 3).

The **date** of a valid timestamp is the `genTime` of an RFC 3161 token, or the time of the Bitcoin block an OpenTimestamps proof reaches. The earliest valid timestamp of a signature file is its date.

## 6. The time of a version

The **time** of a version (of a line or of a key log) is the `threshold`-th earliest of the dates of its valid signature files from distinct keys naming one key-log version (section 6.5 of the specification), `threshold` being that key-log version's. A version with fewer dated signatures has no time. A version without a time loses nothing that the specification gives it; it only cannot be used where this extension needs a time: a key-log version without a time cannot decide a fork, nor date a revocation (section 7). Owners therefore stamp each key-log version when they make it, with an RFC 3161 token where they cannot wait for an OpenTimestamps proof to complete.

Two times are a **tie** when they are equal, or when one of them is the time of a Bitcoin block and they are within two hours of each other, since block times are that uncertain. A tie is reported and decides nothing.

## 7. What timestamps add to the core

Under a declaration, the following rules apply in addition to those of the specification. They act only within the status of unconfirmed (sections 4 and 6.5 of the specification): they confirm what the core leaves unconfirmed, and resolve what it leaves unresolved; they never leave unconfirmed what the core lets count, never make valid what the core rejects, nor invalid what it accepts.

**Signatures of a revoked key.** A signature by a key that a version of the key log revokes, which the core leaves unconfirmed (section 6.5 of the specification), counts if it is otherwise valid and its date is earlier than the time of the first key-log version that lists the key in `revoked`. Where that version has no time, no such signature is confirmed. Revocation dates the end of the owner's trust in a key, not its theft: signatures that a thief made, and stamped, between the theft and the revocation are confirmed too, so owners revoke a key as soon as they fear it exposed.

**Forks of a key log.** When valid versions of a key log with the same number fork it (section 6.5 of the specification), on two sides or more, and the declaration in force (that of the last version all sides share, section 4) is `keylog` or `all`, the timestamps of every side are checked against that declaration, never against a declaration of a side, so that a side cannot list an authority of its own. If the first differing version of every side has a time, and one of them is earlier than every other, and not in a tie with any, its side is the owner's, and the others are reported. Otherwise (a side without a time, or a tie for the earliest) the fork stays unresolved, as in the core: a side never wins because another's timestamps are missing, since a host can strip them from a copy. A fork within a side, after a fork that is resolved, is resolved in the same way, from the earliest fork point on.

**Missing timestamps.** A version without a time in a given copy is not unconfirmed for that reason: a host can strip timestamp files from a copy, and anyone can add one later. Missing timestamps only leave unresolved, or unconfirmed, what the core leaves so.

## 8. Copies and branches

Timestamp files are witnesses, kept in the object's extension folder, and travel with the object as its signature files do (sections 6.5 and 13.2 of the specification). A copy keeps them; copies that added different timestamp files are merged by keeping every file (section 3).

A branch keeps the evidence of its parent version as content (section 10.5 of the specification): `parent.signatures/` holds the parent owner's signature files of the parent version with their timestamp files beside them, under the same file names, without the `<version>/` folder (`parent.signatures/signature-<k>.json.<d>.tsr`); the timestamp files of the parent owner's key log are in its owner object, which travels with the branch (section 6.5 of the specification). Under a declaration of the parent's owner, a branch MUST NOT be taken from a parent version whose timestamps are still pending, and its evidence carries complete proofs only, since the files of a version, once made, never change. A branch whose evidence carries a pending proof is reported: the pending proof counts for nothing, and the verdict of the branch point is the one that the rest of its evidence gives.

## 9. Verification

A verifier that knows this extension, in addition to the checks of section 14 of the specification:

- validates each declaration against the schema of appendix A;
- checks every timestamp file it finds against the signature file it stamps (section 5), and that its name matches the digest of its bytes (section 3), reporting each as valid, invalid, pending, or from an authority not listed;
- computes the time of each key-log version and of each version a declaration covers, and reports those without a time as undated, a warning;
- confirms signatures of revoked keys, and resolves forks of key logs, as section 7 says, reporting ties;
- checks the timestamp files inside `parent.signatures/` and at every level of `parent.chain/` of every branch, and reports those that are pending (section 8).

## 10. Guidance for tools

- Tools that create an owner SHOULD offer to adopt this extension in the first version of its key log, with `timestamps` `all`: without it, the signatures of a key the owner has to revoke cannot be confirmed, and a fork of the key log cannot be resolved.
- Tools SHOULD timestamp each signature when they make it, under a declaration, and before a version leaves its owner's hands.
- Tools SHOULD let an owner choose its authorities, and SHOULD keep an OpenTimestamps proof beside an RFC 3161 token where an owner wants evidence that rests on no authority.
- Tools SHOULD re-stamp RFC 3161 tokens whose certificates near their end.

## 11. Security considerations

- **Trust.** An RFC 3161 token is immediate and checkable with common tools, but rests on the authority's clock and keys: an authority that misdates, or whose key is stolen, can date a signature falsely. Listing the authorities in the key log keeps anyone else from dating with an authority of their own. Its limits: removing an authority does not protect against one already compromised, since tokens it backdates before the version that removes it still count; and listing a root certificate trusts every authority that root certifies, now and later, so an owner that wants a single authority lists the fingerprint of its signing certificate, and lists the new one by a new key-log version when it is renewed. An OpenTimestamps proof rests on no authority, only on Bitcoin, but is complete only after a pending period of hours, and its date is uncertain by about as long.
- **Stripping.** A host can remove timestamp files from a copy; the signatures they confirmed are then unconfirmed again, and a fork unresolved, until a copy with the files restores them. Nothing that the core lets count is lost.
- **Freshness.** A copy that withholds later versions of a key log also withholds later declarations and revocations; the declaration in force is only as recent as the key log a reader has seen.
- **Forks.** A side of a fork cannot bring its own authorities, nor win by stripping the other sides' timestamps (section 7); a fork is resolved only when every side is dated. But time decides for whoever stamps first: a thief who holds `threshold` keys, forks the key log at once and stamps the fork, before the owner revokes the keys in a version of its own, wins the fork, even if it publishes the fork later. Owners who want to resist the theft of one key use a threshold of 2 or more, with keys kept apart, so that one stolen key cannot fork the key log at all.
- **Revocation.** Revocation confirms the stamped signatures made before it, a thief's included (section 7); the time between a theft and its revocation is the owner's exposure.

## Appendix A. JSON Schema (normative)

The data of the declaration, the value of `extensions["https://opensheaf.org/opensheaf-timestamps-0.1"]` in `keys.json`, validates against [opensheaf-timestamps-0.1.schema.json](https://opensheaf.org/schemas/opensheaf-timestamps-0.1.schema.json) (JSON Schema 2020-12, CC0 1.0).

## Appendix B. Example (non-normative)

The `keys.json` of the first version of an owner's key log, adopting the extension from the start with `all` (section 1), with one RFC 3161 authority (a placeholder fingerprint) and OpenTimestamps; its genesis record lists the same `keys` and `threshold`:

```json
{
  "format": "opensheaf-keys/0.1",
  "keys": [ "did:key:z6MkhaXgBZDvotDkL5257faiztiGiC2QtKLGpbnnEGta2doK",
            "did:key:z6MkpTHR8VNsBxYAAWHut2Geadd9jSwuBV8xRoAnwWsdvktH" ],
  "threshold": 1,
  "extensions": {
    "https://opensheaf.org/opensheaf-timestamps-0.1": {
      "timestamps": "all",
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

If the owner later revokes the first key, in version 3 of its key log, the signatures of that key whose date is earlier than the time of version 3 count again for readers that know this extension; the others stay unconfirmed.

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
