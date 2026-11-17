<TeXmacs|2.1.5>

<style|<tuple|notes|notes-meta>>

<\body>
  <notes-header>

  <chapter*|OpenSheaf timestamps>

  <notes-abstract|Extension to the OpenSheaf specification 0.1. Version 0.1 (draft), 17 November 2026. How an owner dates its signatures with RFC 3161 tokens or OpenTimestamps proofs, declares that it does so in its key log, and so resolves forks of its key log by time and confirms the signatures that a key made before its owner revoked it. The extension is named by the URI <verbatim|https://opensheaf.org/opensheaf-timestamps-0.1>. The text is licensed under CC BY-SA 4.0; its JSON Schema is dedicated to the public domain under CC0 1.0.>

  <os-alert|warning|Warning.|<strong|Proposal.> This extension belongs to the identity proposal of the specification (owners, key logs and signatures, sections 6.5 and 13.2), on the branch <verbatim|proposal/identity> (PR #30), not yet agreed. It is discussed in <hlink|issue #55|https://github.com/opensheaf/opensheaf.github.io/issues/55>.>

  <section*|1. Introduction (non-normative)><label|1-introduction-non-normative>

  In the <hlink|OpenSheaf specification|opensheaf-specification-0.1.tm>, every version of a line is signed by its owner, under a version of the owner's key log that lists the keys allowed to sign (sections 6.5 and 13.2 of the specification). A signature counts when it is valid under the key-log version it names, and keeps counting: an owner retires keys and raises its threshold without undoing anything it signed. Signatures say who made a version; they say nothing of when. Two consequences follow in the core:

  <\itemize>
    <item><strong|Signatures of a revoked key are unconfirmed.> An owner revokes a key that may have been exposed. Since nothing dates a signature, the core cannot tell the signatures the owner made with that key before the revocation from those that whoever holds it makes afterwards, and leaves them unconfirmed, except where a later signed version of the same line confirms them.

    <item><strong|Forks of a key log are reported, not resolved.> Keys of a version, retired or revoked since, can still sign a different next version, and so fork the key log; nothing in the core says which side is the owner's, and a revocation made on one side does not apply until the fork is resolved.
  </itemize>

  Timestamps answer both, by showing that a signature existed by a date. A single researcher who never loses a key to others needs none of this. A journal, an institution, or anyone who wants a stolen key to cost little may want it, and may want it from a provider it can name. So timestamps are an extension, which an owner adopts by declaring it in its key log, and SHOULD adopt from the first version of its key log, with <verbatim|all>, so that every signature it makes is dated before any key may have to be revoked.

  <section*|2. Conventions><label|2-conventions>

  The key words MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, RECOMMENDED, NOT RECOMMENDED, MAY and OPTIONAL in this document are to be interpreted as described in BCP 14 (RFC 2119 and RFC 8174) when, and only when, they appear in all capitals. Terms are those of the specification: owner, key log, key-log version, signature file, witness, line, branch.

  This extension follows the extension mechanism of section 4 of the specification: it never changes the meaning of what the specification defines, nor relaxes its requirements; it adds evidence, and rules that use it. A reader that does not know it reads and verifies everything by the core rules, and ignores the files and data it defines.

  <section*|3. Timestamps><label|3-timestamps>

  A timestamp of a signature file shows that the file, and so the signature and the signed message it holds, existed by a date. It proves existence, nothing more. Two kinds are defined, which an owner MAY combine:

  <\itemize>
    <item><strong|RFC 3161 tokens>, from a time-stamping authority (a free public one, or a qualified provider under eIDAS): a file holding a DER-encoded <verbatim|TimeStampResp> whose message imprint is the SHA-512 digest of the bytes of the signature file, requested with the authority's certificates included (<verbatim|-cert> with <verbatim|openssl ts -query>), so that it can be checked with <verbatim|openssl ts -verify> without fetching them; its name ends in <verbatim|.tsr>.

    <item><strong|OpenTimestamps proofs> of the bytes of the same signature file; their names end in <verbatim|.ots>.
  </itemize>

  A timestamp file of the signature file <verbatim|\<less\>version\<gtr\>/signature-\<less\>k\<gtr\>.json>, in the object's extension folder <verbatim|extensions/opensheaf-witnesses/>, is <verbatim|\<less\>version\<gtr\>/signature-\<less\>k\<gtr\>.json.\<less\>d\<gtr\>.tsr> or <verbatim|\<less\>version\<gtr\>/signature-\<less\>k\<gtr\>.json.\<less\>d\<gtr\>.ots>, beside it, where <verbatim|\<less\>d\<gtr\>> is the first 16 characters of the lowercase base32 (RFC 4648, without padding) SHA-256 digest of the timestamp file's own bytes. Names made from the contents never collide: two copies that add timestamps independently can be merged by taking every file of both, and the same timestamp has the same name everywhere.

  Both kinds stamp the signature file as stored. Signature files and their timestamp files are never re-serialised, replaced or removed once made (section 13.2 of the specification): a timestamp stamps their bytes, and a copy may already hold them. A signature file MAY be stamped again later (re-stamping), by another authority or with an OpenTimestamps proof, so that the evidence outlives the certificates of the first. An OpenTimestamps proof is pending when made, and complete once a Bitcoin block attests it; the completed proof is a new file, named from its own bytes, beside the pending one, which stays unchanged.

  A timestamp of a version's checksum file MAY also be kept, as <verbatim|\<less\>version\<gtr\>/inventory.json.sha512.\<less\>d\<gtr\>.tsr> or <verbatim|.\<less\>d\<gtr\>.ots>; it dates the version, not a signature, and is not used by the rules below.

  <section*|4. The owner's declaration><label|4-the-owners-declaration>

  An owner adopts this extension in its key log: a version of the key log holds, in its <verbatim|keys.json>, under <verbatim|extensions> (section 6.5 of the specification), an entry keyed by <verbatim|https://opensheaf.org/opensheaf-timestamps-0.1>, an object with:

  <\itemize>
    <item><verbatim|timestamps>, REQUIRED: <verbatim|"keylog">, every version of the key log is timestamped, or <verbatim|"all">, every version of the key log and of the owner's lines is timestamped;

    <item><verbatim|timestampAuthorities>, OPTIONAL: the RFC 3161 time-stamping authorities the owner trusts, each the SHA-256 fingerprint (lowercase hexadecimal) of the authority's signing certificate or of the root certificate of its chain. Without any, only OpenTimestamps proofs are used.
  </itemize>

  The data of the declaration validates against the schema of appendix A; anything else in <verbatim|keys.json> (a top-level <verbatim|timestamps> field, for instance) is not a declaration. The declaration is part of the key-log version, so it is signed with it, and changed only by a new version.

  <verbatim|timestamps> says what the owner stamps, and what verifiers report as undated when a timestamp is missing (section 9). Only with <verbatim|all> can the signatures of a revoked key on the owner's lines be confirmed by this extension, since only then are they stamped; with <verbatim|keylog>, it resolves forks of the key log, and so lets the revocations of the owner's side take effect, and confirms nothing on the lines (the versions of the key log up to a revocation are never unconfirmed by it, section 6.5 of the specification).

  <strong|The declaration in force>, for every check of this extension, is that of the latest version of the key log known to the reader: an owner that adopts the extension, or changes its authorities, does so for everything checked afterwards. While the key log is forked, the declaration in force is that of the last version all sides share, for every check on any side, since the latest version known is not defined across a fork (section 7); once the fork is resolved, it is that of the latest version known on the owner's side. Changing the declaration never leaves unconfirmed a signature that the specification lets count (section 7).

  An owner MAY drop the declaration, by a later key-log version without it: since the declaration in force is that of the latest version, only the rules of the specification then apply, to everything: forks are reported, not resolved, and no signature of a revoked key is confirmed by this extension, whenever the key was revoked. An owner that has revoked a key SHOULD NOT drop the declaration.

  <section*|5. Checking a timestamp><label|5-checking-a-timestamp>

  A timestamp is <strong|valid> for a signature file when:

  <\itemize>
    <item>for an RFC 3161 token: its message imprint is the SHA-512 digest of the file's bytes; its signing certificate, or the root of the chain it carries, has a fingerprint listed in <verbatim|timestampAuthorities> of the declaration in force, or of an earlier declaration (below); the chain was valid at the token's <verbatim|genTime>, which means that every certificate from the signing certificate to the root was within its validity period at <verbatim|genTime>, that the signing certificate is for time stamping (RFC 3161, section 2.3), and that no revocation known to the reader dates from before <verbatim|genTime> (as <verbatim|openssl ts -verify> checks with <verbatim|-attime> set to <verbatim|genTime> and the root certificate whose fingerprint is listed, or that is the root of the listed signing certificate); and the token verifies. An authority that the owner stops trusting is removed from the list by a new key-log version: its tokens then count only if it was listed in a declaration of an earlier version, and their <verbatim|genTime> is earlier than the time of the version that removed it (section 6);

    <item>for an OpenTimestamps proof: it is complete, attested in a Bitcoin block; a pending proof counts for nothing, and its completed proof is a separate file (section 3).
  </itemize>

  The <strong|date> of a valid timestamp is the <verbatim|genTime> of an RFC 3161 token, or the time of the Bitcoin block an OpenTimestamps proof reaches. The earliest valid timestamp of a signature file is its date.

  <section*|6. The time of a version><label|6-the-time-of-a-version>

  The <strong|time> of a version (of a line or of a key log) is the <verbatim|threshold>-th earliest of the dates of its valid signature files from distinct keys naming one key-log version (section 6.5 of the specification), <verbatim|threshold> being that key-log version's. A version with fewer dated signatures has no time. A version without a time loses nothing that the specification gives it; it only cannot be used where this extension needs a time: a key-log version without a time cannot decide a fork, nor date a revocation (section 7). Owners therefore stamp each key-log version when they make it, with an RFC 3161 token where they cannot wait for an OpenTimestamps proof to complete.

  Two times are a <strong|tie> when they are equal, or when one of them is the time of a Bitcoin block and they are within two hours of each other, since block times are that uncertain. A tie is reported and decides nothing.

  <section*|7. What timestamps add to the core><label|7-what-timestamps-add-to-the-core>

  Under a declaration, the following rules apply in addition to those of the specification. They act only within the status of unconfirmed (sections 4 and 6.5 of the specification): they confirm what the core leaves unconfirmed, and resolve what it leaves unresolved; they never leave unconfirmed what the core lets count, never make valid what the core rejects, nor invalid what it accepts.

  <strong|Signatures of a revoked key.> A signature by a key that a version of the key log revokes, which the core leaves unconfirmed (section 6.5 of the specification), counts if it is unconfirmed for no other reason (it does not name, for instance, a key-log version after the fork point of a fork that is not resolved) and its date is earlier than the time of the first key-log version that lists the key in <verbatim|revoked> and, when that entry gives one, than its <verbatim|since>, the owner's estimate of when the key may have been exposed. Where that version has no time, no such signature is confirmed. The time of the revoking version dates the end of the owner's trust in a key, not its theft: without <verbatim|since>, signatures that a thief made, and stamped, between the theft and the revocation are confirmed too, so owners revoke a key as soon as they fear it exposed, and give <verbatim|since> when they can tell when the exposure began.

  <strong|Forks of a key log.> When valid versions of a key log with the same number fork it (section 6.5 of the specification), on two sides or more, and the declaration in force (that of the last version all sides share, section 4) is <verbatim|keylog> or <verbatim|all>, the timestamps of every side are checked against that declaration, never against a declaration of a side, so that a side cannot list an authority of its own. If the first differing version of every side has a time, and one of them is earlier than every other, and not in a tie with any, its side is the owner's, and the others are reported. Otherwise (a side without a time, or a tie for the earliest) the fork stays unresolved, as in the core: a side never wins because another's timestamps are missing, since a host can strip them from a copy. A fork within a side, after a fork that is resolved, is resolved in the same way, from the earliest fork point on. Once a fork is resolved, the revocations listed on the owner's side apply, as the specification lets them (its section 6.5), and those listed only on other sides are ignored.

  <strong|Missing timestamps.> A version without a time in a given copy is not unconfirmed for that reason: a host can strip timestamp files from a copy, and anyone can add one later. Missing timestamps only leave unresolved, or unconfirmed, what the core leaves so.

  <section*|8. Copies and branches><label|8-copies-and-branches>

  Timestamp files are witnesses, kept in the object's extension folder, and travel with the object as its signature files do (sections 6.5 and 13.2 of the specification). A copy keeps them; copies that added different timestamp files are merged by keeping every file (section 3).

  A branch keeps the evidence of its parent version as content (section 10.5 of the specification): <verbatim|parent.signatures/> holds the parent owner's signature files of the parent version with their timestamp files beside them, under the same file names, without the <verbatim|\<less\>version\<gtr\>/> folder (<verbatim|parent.signatures/signature-\<less\>k\<gtr\>.json.\<less\>d\<gtr\>.tsr>); the timestamp files of the parent owner's key log are in its owner object, which travels with the branch (section 6.5 of the specification). Under a declaration of the parent's owner, a branch MUST NOT be taken from a parent version whose timestamps are still pending, and its evidence carries complete proofs only, since the files of a version, once made, never change. A branch whose evidence carries a pending proof is reported: the pending proof counts for nothing, and the verdict of the branch point is the one that the rest of its evidence gives.

  <section*|9. Verification><label|9-verification>

  A verifier that knows this extension, in addition to the checks of section 14 of the specification:

  <\itemize>
    <item>validates each declaration against the schema of appendix A;

    <item>merges the timestamp files of every copy it sees of a signature file, of the object and of its owner objects, which the names of section 3 allow, before computing dates, so that a timestamp stripped from one copy is restored from another;

    <item>checks every timestamp file it finds against the signature file it stamps (section 5), and that its name matches the digest of its bytes (section 3), reporting each as valid, invalid, pending, or from an authority not listed;

    <item>computes the time of each key-log version and of each version a declaration covers, and reports those without a time as undated, a warning;

    <item>confirms signatures of revoked keys, and resolves forks of key logs, as section 7 says, reporting ties;

    <item>checks the timestamp files inside <verbatim|parent.signatures/> and at every level of <verbatim|parent.chain/> of every branch, and reports those that are pending (section 8).
  </itemize>

  <section*|10. Guidance for tools><label|10-guidance-for-tools>

  <\itemize>
    <item>Tools that create an owner SHOULD offer to adopt this extension in the first version of its key log, with <verbatim|timestamps> <verbatim|all>: without it, the signatures of a key the owner has to revoke cannot be confirmed, and a fork of the key log cannot be resolved.

    <item>Tools SHOULD timestamp each signature when they make it, under a declaration, and before a version leaves its owner's hands.

    <item>Tools SHOULD let an owner choose its authorities, and SHOULD keep an OpenTimestamps proof beside an RFC 3161 token where an owner wants evidence that rests on no authority.

    <item>Tools SHOULD re-stamp RFC 3161 tokens whose certificates near their end.
  </itemize>

  <section*|11. Security considerations><label|11-security-considerations>

  <\itemize>
    <item><strong|Trust.> An RFC 3161 token is immediate and checkable with common tools, but rests on the authority's clock and keys: an authority that misdates, or whose key is stolen, can date a signature falsely. Listing the authorities in the key log keeps anyone else from dating with an authority of their own. Its limits: removing an authority does not protect against one already compromised, since tokens it backdates before the version that removes it still count; and listing a root certificate trusts every authority that root certifies, now and later, so an owner that wants a single authority lists the fingerprint of its signing certificate, and lists the new one by a new key-log version when it is renewed. An OpenTimestamps proof rests on no authority, only on Bitcoin, but is complete only after a pending period of hours, and its date is uncertain by about as long.

    <item><strong|Stripping.> A host can remove timestamp files from a copy; the signatures they confirmed are then unconfirmed again, and a fork unresolved, until a copy with the files restores them. Nothing that the core lets count is lost. Since a signature file may be stamped again later (section 3), a host can also remove the earliest timestamps of a revoking key-log version and keep its later ones: the version's time then moves later, and more of a thief's signatures are confirmed. <verbatim|since>, signed by the owner in the revoking version, bounds this: no signature dated after it is confirmed, whatever the version's time; and readers merge the timestamp files of every copy they see (section 9).

    <item><strong|Freshness.> A copy that withholds later versions of a key log also withholds later declarations and revocations; the declaration in force is only as recent as the key log a reader has seen.

    <item><strong|Forks.> A side of a fork cannot bring its own authorities, nor win by stripping the other sides' timestamps (section 7); a fork is resolved only when every side is dated. But time decides for whoever stamps first: a thief who holds <verbatim|threshold> keys, forks the key log at once and stamps the fork, before the owner revokes the keys in a version of its own, wins the fork, even if it publishes the fork later. Owners who want to resist the theft of one key use a threshold of 2 or more, with keys kept apart, from the first version of their key log, so that one stolen key cannot fork the key log at all: a threshold binds only the signatures naming its version (section 6.5 of the specification), so a key listed earlier under a threshold of 1 can still fork the key log at that version, whatever the threshold later.

    <item><strong|Revocation.> Revocation confirms the stamped signatures made before it, a thief's included (section 7); the time between a theft and its revocation is the owner's exposure.
  </itemize>

  <section*|Appendix A. JSON Schema (normative)><label|appendix-a-json-schema-normative>

  The data of the declaration, the value of <verbatim|extensions["https://opensheaf.org/opensheaf-timestamps-0.1"]> in <verbatim|keys.json>, validates against <hlink|opensheaf-timestamps-0.1.schema.json|https://opensheaf.org/schemas/opensheaf-timestamps-0.1.schema.json> (JSON Schema 2020-12, CC0 1.0).

  <section*|Appendix B. Example (non-normative)><label|appendix-b-example-non-normative>

  The <verbatim|keys.json> of the first version of an owner's key log, adopting the extension from the start with <verbatim|all> (section 1), with one RFC 3161 authority (a placeholder fingerprint) and OpenTimestamps; its genesis record lists the same <verbatim|keys> and <verbatim|threshold>:

  <\html-div-class|language-json>
  <\verbatim-code>
    {

    \ \ "format": "opensheaf-keys/0.1",

    \ \ "keys": [ "did:key:z6MkhaXgBZDvotDkL5257faiztiGiC2QtKLGpbnnEGta2doK",

    \ \ \ \ \ \ \ \ \ \ \ \ "did:key:z6MkpTHR8VNsBxYAAWHut2Geadd9jSwuBV8xRoAnwWsdvktH" ],

    \ \ "threshold": 1,

    \ \ "extensions": {

    \ \ \ \ "https://opensheaf.org/opensheaf-timestamps-0.1": {

    \ \ \ \ \ \ "timestamps": "all",

    \ \ \ \ \ \ "timestampAuthorities": [ "5b4e3f0c9d2a7e18c6f4b0a39d7e2c51f8a6b3d09e4c7a12f5b8d6e3a0c9f147" ]

    \ \ \ \ }

    \ \ }

    }
  </verbatim-code>
  </html-div-class>

  The files of one signature of that version, in the owner object's extension folder: an RFC 3161 token, a pending OpenTimestamps proof, and the completed proof written beside it later, each named from the digest of its own bytes (placeholder digests):

  <\verbatim-code>
    extensions/opensheaf-witnesses/v1/signature-qvi7ibhm7zsahqx6.json

    extensions/opensheaf-witnesses/v1/signature-qvi7ibhm7zsahqx6.json.q7swxsz56bfiyotn.tsr

    extensions/opensheaf-witnesses/v1/signature-qvi7ibhm7zsahqx6.json.hm5uhlee72brbz64.ots

    extensions/opensheaf-witnesses/v1/signature-qvi7ibhm7zsahqx6.json.yq77barzw3gj7dbj.ots
  </verbatim-code>

  If the owner later revokes the first key, in version 3 of its key log, with <verbatim|since> the time it believes the key was exposed, the signatures of that key whose date is earlier than both the time of version 3 and <verbatim|since> count again for readers that know this extension; the others stay unconfirmed, unless a later signed version of the same line confirms them (section 6.5 of the specification).

  <section*|Appendix C. References><label|appendix-c-references>

  <\itemize>
    <item><hlink|OpenSheaf specification 0.1|opensheaf-specification-0.1.tm>, sections 4, 6.5, 10.5, 13.2 and 14

    <item><hlink|RFC 3161|https://www.rfc-editor.org/rfc/rfc3161>, Time-Stamp Protocol, and <hlink|RFC 5816|https://www.rfc-editor.org/rfc/rfc5816>, its update for other hash algorithms

    <item><hlink|OpenTimestamps|https://opentimestamps.org/>

    <item><hlink|RFC 2119|https://www.rfc-editor.org/rfc/rfc2119> and <hlink|RFC 8174|https://www.rfc-editor.org/rfc/rfc8174>
  </itemize>

  <section*|Changelog><label|changelog>

  <\itemize>
    <item><strong|0.1 (draft), 17 November 2026:> first draft, moving the timestamp rules out of the identity proposal of the specification: RFC 3161 tokens and OpenTimestamps proofs of signature files, the owner's declaration in <verbatim|keys.json> under <verbatim|extensions> (<verbatim|timestamps>, <verbatim|timestampAuthorities>), checking at <verbatim|genTime> with listed authorities and complete proofs only, re-stamping, the time of a version and ties, resolution of key-log forks by time, confirmation of signatures after changes of keys, missing timestamps as unconfirmed, branches with complete proofs, guidance and security considerations.

    <item><strong|0.1 (draft), 17 November 2026, revised after an audit:> completed OpenTimestamps proofs are new files (<verbatim|.\<less\>n\<gtr\>.ots>), never replacements; one definition of the declaration in force, that of the last shared version during a fork, against which both sides' timestamps are checked; a fork is resolved only when both sides are dated and not tied; a removed authority's earlier tokens are checked against the declaration that listed it; the validity of a chain at <verbatim|genTime> defined; the time of a version whose signatures name several key-log versions; the consequences of a key-log version without a time; the cost of adopting the extension late, and the example adopting it in the first version; dropping a declaration; the limits of removing authorities and of listing roots; the names in <verbatim|parent.signatures/>, and pending proofs in a branch's evidence reported.

    <item><strong|0.1 (draft), 17 November 2026, revised:> the timestamp files of a parent owner's key log are in its owner object, beside the branch, no longer in <verbatim|parent.keylog/>.

    <item><strong|0.1 (draft), 17 November 2026, revised after a fifth audit:> following the specification, which no longer leaves unconfirmed the signatures of a retired key or under a raised threshold, the extension confirms the signatures of revoked keys dated before the revocation, and resolves forks of key logs; the rules on later changes of keys, thresholds and declarations are gone, and changing or adopting a declaration late unconfirms nothing; missing timestamps no longer make a version unconfirmed, and undated versions are reported as a warning; timestamp files named by the digest of their own bytes, so that copies that add them independently merge; forks of more than two sides; <verbatim|all> recommended from the first version; the first-stamp advantage of a thief, and the exposure between a theft and its revocation, stated.

    <item><strong|0.1 (draft), 17 November 2026, revised after a sixth audit:> a revoked key's signature is confirmed only if dated before both the time of the revoking version and its <verbatim|since>, the owner's estimate of the exposure, which bounds what stripping the earliest timestamps of the revoking version can confirm; verifiers merge the timestamp files of every copy they see; once a fork is resolved, the declaration in force is the latest of the owner's side, and only that side's revocations apply; dropping the declaration ends every confirmation it gave; with <verbatim|keylog>, the extension confirms nothing on the lines; a threshold binds only the signatures naming its version, so a threshold of 2 or more is recommended from the first version.
  </itemize>

</body>

<\initial>
  <\collection>
    <associate|page-medium|paper>
  </collection>
</initial>
