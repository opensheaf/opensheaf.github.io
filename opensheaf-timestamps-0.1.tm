<TeXmacs|2.1.5>

<style|<tuple|notes|notes-meta>>

<\body>
  <notes-header>

  <chapter*|OpenSheaf timestamps>

  <notes-abstract|Extension to the OpenSheaf specification 0.1. Version 0.1 (draft), 17 November 2026. How an owner dates its signatures with RFC 3161 tokens or OpenTimestamps proofs, declares that it does so in its key log, and so resolves forks of its key log by time and confirms signatures that the core leaves unconfirmed after a key is removed. The extension is named by the URI <verbatim|https://opensheaf.org/opensheaf-timestamps-0.1>. The text is licensed under CC BY-SA 4.0; its JSON Schema is dedicated to the public domain under CC0 1.0.>

  <os-alert|warning|Warning.|<strong|Proposal.> This extension belongs to the identity proposal of the specification (owners, key logs and signatures, sections 6.5 and 13.2), on the branch <verbatim|proposal/identity> (PR #30), not yet agreed. It is discussed in <hlink|issue #55|https://github.com/opensheaf/opensheaf.github.io/issues/55>.>

  <section*|1. Introduction (non-normative)><label|1-introduction-non-normative>

  In the <hlink|OpenSheaf specification|opensheaf-specification-0.1.tm>, every version of a line is signed by its owner, under a version of the owner's key log that lists the keys allowed to sign (sections 6.5 and 13.2 of the specification). Signatures say who made a version; they say nothing of when. Two consequences follow in the core:

  <\itemize>
    <item><strong|Forks of a key log are reported, not resolved.> A key removed from a key log can still sign a different version of an older key log, and so fork it; nothing in the core says which side is the owner's.

    <item><strong|Signatures after a change of keys are unconfirmed.> A signature naming an older key-log version counts in the core only while its key is still listed and the threshold has not been raised; otherwise the core cannot tell whether it was made before the change or after it.
  </itemize>

  Timestamps answer both, by showing that a signature existed by a date. A single researcher who never removes a key needs none of this. A journal, an institution, or anyone who rotates keys may want it, and may want it from a provider it can name. So timestamps are an extension, which an owner adopts by declaring it in its key log, and SHOULD adopt from the first version of its key log, before any key is ever removed: adopting it later leaves unconfirmed every earlier signature that has no timestamp (section 7).

  <section*|2. Conventions><label|2-conventions>

  The key words MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, RECOMMENDED, NOT RECOMMENDED, MAY and OPTIONAL in this document are to be interpreted as described in BCP 14 (RFC 2119 and RFC 8174) when, and only when, they appear in all capitals. Terms are those of the specification: owner, key log, key-log version, signature file, witness, line, branch.

  This extension follows the extension mechanism of section 4 of the specification: it never changes the meaning of what the specification defines, nor relaxes its requirements; it adds evidence, and rules that use it. A reader that does not know it reads and verifies everything by the core rules, and ignores the files and data it defines.

  <section*|3. Timestamps><label|3-timestamps>

  A timestamp of a signature file shows that the file, and so the signature and the signed message it holds, existed by a date. It proves existence, nothing more. Two kinds are defined, which an owner MAY combine:

  <\itemize>
    <item><strong|RFC 3161 tokens>, from a time-stamping authority (a free public one, or a qualified provider under eIDAS): <verbatim|\<less\>version\<gtr\>/signature-\<less\>k\<gtr\>.json.tsr>, beside the signature file <verbatim|\<less\>version\<gtr\>/signature-\<less\>k\<gtr\>.json> in the object's extension folder <verbatim|extensions/opensheaf-witnesses/>. The file holds a DER-encoded <verbatim|TimeStampResp> whose message imprint is the SHA-512 digest of the bytes of the signature file, requested with the authority's certificates included (<verbatim|-cert> with <verbatim|openssl ts -query>), so that it can be checked with <verbatim|openssl ts -verify> without fetching them.

    <item><strong|OpenTimestamps proofs> of the bytes of the same signature file: <verbatim|\<less\>version\<gtr\>/signature-\<less\>k\<gtr\>.json.ots>, beside it.
  </itemize>

  Both stamp the signature file as stored. Signature files and their timestamp files are never re-serialised, replaced or removed once made (section 13.2 of the specification): a timestamp stamps their bytes, and a copy may already hold them. A timestamp MAY be supplemented later by another one of the same file (re-stamping), with another authority or with an OpenTimestamps proof, so that the evidence outlives the certificates of the first; the files are then named <verbatim|\<less\>version\<gtr\>/signature-\<less\>k\<gtr\>.json.\<less\>n\<gtr\>.tsr> or <verbatim|.\<less\>n\<gtr\>.ots>, <verbatim|\<less\>n\<gtr\>> from 2, the smallest number not yet used for that kind. An OpenTimestamps proof is pending when made, and complete once a Bitcoin block attests it; the completed proof is written in the same way, as a new file <verbatim|\<less\>version\<gtr\>/signature-\<less\>k\<gtr\>.json.\<less\>n\<gtr\>.ots>, beside the pending one, which stays unchanged.

  A timestamp of a version's checksum file MAY also be kept, as <verbatim|\<less\>version\<gtr\>/inventory.json.sha512.tsr> or <verbatim|.ots>; it dates the version, not a signature, and is not used by the rules below.

  <section*|4. The owner's declaration><label|4-the-owners-declaration>

  An owner adopts this extension in its key log: a version of the key log holds, in its <verbatim|keys.json>, under <verbatim|extensions> (section 6.5 of the specification), an entry keyed by <verbatim|https://opensheaf.org/opensheaf-timestamps-0.1>, an object with:

  <\itemize>
    <item><verbatim|timestamps>, REQUIRED: <verbatim|"keylog">, every version of the key log is timestamped, or <verbatim|"all">, every version of the key log and of the owner's lines is timestamped;

    <item><verbatim|timestampAuthorities>, OPTIONAL: the RFC 3161 time-stamping authorities the owner trusts, each the SHA-256 fingerprint (lowercase hexadecimal) of the authority's signing certificate or of the root certificate of its chain. Without any, only OpenTimestamps proofs meet the policy.
  </itemize>

  The data of the declaration validates against the schema of appendix A; anything else in <verbatim|keys.json> (a top-level <verbatim|timestamps> field, for instance) is not a declaration. The declaration is part of the key-log version, so it is signed with it, and changed only by a new version.

  <strong|The declaration in force>, for every check of this extension, is that of the latest version of the key log known to the reader, not that of the version a signature names: an owner that adopts the extension, tightens its policy, or changes its authorities does so for everything checked afterwards. While the key log is forked, the declaration in force is that of the last version both sides share, for every check on either side, since the latest version known is not defined across a fork (section 7).

  An owner MAY drop the declaration, by a later key-log version without it. That is a change of the declaration like any other (section 7): signatures naming earlier key-log versions then need a date earlier than the time of the version that drops it, and afterwards only the rules of the specification apply, so later forks are reported, not resolved.

  <section*|5. Checking a timestamp><label|5-checking-a-timestamp>

  A timestamp is <strong|valid> for a signature file when:

  <\itemize>
    <item>for an RFC 3161 token: its message imprint is the SHA-512 digest of the file's bytes; its signing certificate, or the root of the chain it carries, has a fingerprint listed in <verbatim|timestampAuthorities> of the declaration in force, or of an earlier declaration (below); the chain was valid at the token's <verbatim|genTime>, which means that every certificate from the signing certificate to the root was within its validity period at <verbatim|genTime>, that the signing certificate is for time stamping (RFC 3161, section 2.3), and that no revocation known to the reader dates from before <verbatim|genTime> (as <verbatim|openssl ts -verify> checks with <verbatim|-attime> set to <verbatim|genTime> and the root certificate whose fingerprint is listed, or that is the root of the listed signing certificate); and the token verifies. An authority that the owner stops trusting is removed from the list by a new key-log version: its tokens then count only if it was listed in a declaration of an earlier version, and their <verbatim|genTime> is earlier than the time of the version that removed it (section 6);

    <item>for an OpenTimestamps proof: it is complete, attested in a Bitcoin block; a pending proof counts for nothing, and its completed proof is a separate file (section 3).
  </itemize>

  The <strong|date> of a valid timestamp is the <verbatim|genTime> of an RFC 3161 token, or the time of the Bitcoin block an OpenTimestamps proof reaches. The earliest valid timestamp of a signature file is its date.

  <section*|6. The time of a version><label|6-the-time-of-a-version>

  The <strong|time> of a version (of a line or of a key log) is the <verbatim|threshold>-th earliest of the dates of its valid signature files from distinct keys naming one key-log version (section 6.5 of the specification), <verbatim|threshold> being that key-log version's; when the signatures naming several key-log versions each reach their <verbatim|threshold>, the time is the earliest of the times so obtained. A version with fewer dated signatures has no time.

  Under a declaration that covers it, a version without a time is unconfirmed (section 7). For a key-log version, this has consequences beyond itself: it cannot decide a fork, a signature that needs a date earlier than its time cannot be confirmed, and, being unconfirmed, it is not relied on (section 6.5 of the specification), so signatures naming it are unconfirmed too, and so the versions of the owner's lines they sign, until a valid timestamp of it is added. Owners therefore stamp each key-log version when they make it, with an RFC 3161 token where they cannot wait for an OpenTimestamps proof to complete.

  Two times are a <strong|tie> when they are equal, or when one of them is the time of a Bitcoin block and they are within two hours of each other, since block times are that uncertain. A tie is reported and decides nothing.

  <section*|7. What timestamps add to the core><label|7-what-timestamps-add-to-the-core>

  Under a declaration, the following rules apply in addition to those of the specification. They act only within the status of unconfirmed (sections 4 and 6.5 of the specification): they confirm or resolve what the core leaves unconfirmed or unresolved, or leave unconfirmed what the core would let count; they never make valid what the core rejects, nor invalid what it accepts.

  <strong|Forks of a key log.> When two valid versions of a key log with the same number fork it (section 6.5 of the specification), and the declaration in force (that of the last version both sides share, section 4) is <verbatim|keylog> or <verbatim|all>, the timestamps of both sides are checked against that declaration, never against a declaration of either side, so that a side cannot list an authority of its own. If the first differing versions of both sides have a time, and the times are not a tie, the side whose first differing version has the earlier time is the owner's, and the other is reported. Otherwise (one side or both without a time, or a tie) the fork stays unresolved, as in the core: a side never wins because the other's timestamps are missing, since a host can strip them from a copy.

  <strong|Signatures after a change of keys.> A signature naming an older key-log version vk, which the core leaves unconfirmed because a later known version removed its key or raised the threshold, counts if its date is earlier than the time of the first key-log version after vk that made that change. The same holds for a key removed and later added again, for signatures made while it was absent. Since the declaration in force is that of the latest known version, a signature naming vk also needs such a date when a version after vk adopted the extension, tightened <verbatim|timestamps> or changed <verbatim|timestampAuthorities>. Where the version that made the change has no time, no such signature can be confirmed. So an owner that adopts the extension after its first key-log version leaves unconfirmed every signature naming an earlier version that has no timestamp dated before the adopting version's time; owners adopt it from the first version (section 1), or timestamp their existing signatures before they adopt it.

  <strong|Missing timestamps.> A version that the declaration in force covers, and that has no time in a given copy, is unconfirmed there, not invalid: a host can strip timestamp files from a copy, and anyone can add one later. A declaration decides forks and confirms signatures only through timestamps that are present and valid; with <verbatim|keylog>, the versions of the owner's lines need no time of their own, only the key-log versions their signatures name.

  <section*|8. Copies and branches><label|8-copies-and-branches>

  Timestamp files are witnesses, kept in the object's extension folder, and travel with the object as its signature files do (sections 6.5 and 13.2 of the specification). A copy keeps them.

  A branch keeps the evidence of its parent version as content (section 10.5 of the specification): <verbatim|parent.signatures/> holds the parent owner's signature files of the parent version with their timestamp files beside them, under the same file names, without the <verbatim|\<less\>version\<gtr\>/> folder (<verbatim|parent.signatures/signature-\<less\>k\<gtr\>.json.tsr>), and <verbatim|parent.keylog/> holds, for each version of the parent owner's key log, its signature files with their timestamp files. Under a declaration of the parent's owner, a branch MUST NOT be taken from a parent version whose timestamps are still pending, and its evidence carries complete proofs only, since the files of a version, once made, never change. A branch whose evidence carries a pending proof is reported: the pending proof counts for nothing, and the verdict of the branch point is the one that the rest of its evidence gives.

  <section*|9. Verification><label|9-verification>

  A verifier that knows this extension, in addition to the checks of section 14 of the specification:

  <\itemize>
    <item>validates each declaration against the schema of appendix A;

    <item>checks every timestamp file it finds against the signature file it stamps (section 5), reporting each as valid, invalid, pending, or from an authority not listed;

    <item>computes the time of each key-log version and of each version a declaration covers, and reports those without a time as unconfirmed;

    <item>resolves forks of key logs, and confirms signatures after changes of keys, as section 7 says, reporting ties;

    <item>checks the timestamp files inside <verbatim|parent.signatures/> and <verbatim|parent.keylog/> of every branch, and reports those that are pending (section 8).
  </itemize>

  <section*|10. Guidance for tools><label|10-guidance-for-tools>

  <\itemize>
    <item>Tools that create an owner SHOULD offer to adopt this extension in the first version of its key log, with <verbatim|timestamps> at least <verbatim|keylog>: without a declaration, a key once removed can fork the key log at any later time, and the fork cannot be resolved.

    <item>Tools SHOULD timestamp each signature when they make it, under a declaration, and before a version leaves its owner's hands.

    <item>Tools SHOULD let an owner choose its authorities, and SHOULD keep an OpenTimestamps proof beside an RFC 3161 token where an owner wants evidence that rests on no authority.

    <item>Tools SHOULD re-stamp RFC 3161 tokens whose certificates near their end.
  </itemize>

  <section*|11. Security considerations><label|11-security-considerations>

  <\itemize>
    <item><strong|Trust.> An RFC 3161 token is immediate and checkable with common tools, but rests on the authority's clock and keys: an authority that misdates, or whose key is stolen, can date a signature falsely. Listing the authorities in the key log keeps anyone else from dating with an authority of their own. Its limits: removing an authority does not protect against one already compromised, since tokens it backdates before the version that removes it still count; and listing a root certificate trusts every authority that root certifies, now and later, so an owner that wants a single authority lists the fingerprint of its signing certificate, and lists the new one by a new key-log version when it is renewed. An OpenTimestamps proof rests on no authority, only on Bitcoin, but is complete only after a pending period of hours, and its date is uncertain by about as long.

    <item><strong|Stripping.> A host can remove timestamp files from a copy; versions then become unconfirmed, not invalid, and a copy with the files restores them.

    <item><strong|Freshness.> A copy that withholds later versions of a key log also withholds later declarations; the declaration in force is only as recent as the key log a reader has seen.

    <item><strong|Forks.> A side of a fork cannot bring its own authorities, nor win by stripping the other side's timestamps (section 7); a fork is resolved only when both sides are dated.
  </itemize>

  <section*|Appendix A. JSON Schema (normative)><label|appendix-a-json-schema-normative>

  The data of the declaration, the value of <verbatim|extensions["https://opensheaf.org/opensheaf-timestamps-0.1"]> in <verbatim|keys.json>, validates against <hlink|opensheaf-timestamps-0.1.schema.json|https://opensheaf.org/schemas/opensheaf-timestamps-0.1.schema.json> (JSON Schema 2020-12, CC0 1.0).

  <section*|Appendix B. Example (non-normative)><label|appendix-b-example-non-normative>

  The <verbatim|keys.json> of the first version of an owner's key log, adopting the extension from the start (section 1), with one RFC 3161 authority (a placeholder fingerprint) and OpenTimestamps; its genesis record lists the same <verbatim|keys> and <verbatim|threshold>:

  <\html-div-class|language-json>
  <\verbatim-code>
    {

    \ \ "format": "opensheaf-keys/0.1",

    \ \ "keys": [ "did:key:z6MkhaXgBZDvotDkL5257faiztiGiC2QtKLGpbnnEGta2doK",

    \ \ \ \ \ \ \ \ \ \ \ \ "did:key:z6MkpTHR8VNsBxYAAWHut2Geadd9jSwuBV8xRoAnwWsdvktH" ],

    \ \ "threshold": 1,

    \ \ "extensions": {

    \ \ \ \ "https://opensheaf.org/opensheaf-timestamps-0.1": {

    \ \ \ \ \ \ "timestamps": "keylog",

    \ \ \ \ \ \ "timestampAuthorities": [ "5b4e3f0c9d2a7e18c6f4b0a39d7e2c51f8a6b3d09e4c7a12f5b8d6e3a0c9f147" ]

    \ \ \ \ }

    \ \ }

    }
  </verbatim-code>
  </html-div-class>

  The files of one signature of that version, in the owner object's extension folder: an RFC 3161 token, a pending OpenTimestamps proof, and the completed proof written beside it later:

  <\verbatim-code>
    extensions/opensheaf-witnesses/v1/signature-qvi7ibhm7zsahqx6.json

    extensions/opensheaf-witnesses/v1/signature-qvi7ibhm7zsahqx6.json.tsr

    extensions/opensheaf-witnesses/v1/signature-qvi7ibhm7zsahqx6.json.ots

    extensions/opensheaf-witnesses/v1/signature-qvi7ibhm7zsahqx6.json.2.ots
  </verbatim-code>

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
  </itemize>

</body>

<\initial>
  <\collection>
    <associate|page-medium|paper>
  </collection>
</initial>
