<TeXmacs|2.1.5>

<style|<tuple|notes|notes-meta>>

<\body>
  <notes-header>

  <chapter*|OpenSheaf timestamps>

  <notes-abstract|Extension to the OpenSheaf specification 0.1. Version 0.1 (draft), 19 November 2026. How an owner dates its signatures with RFC 3161 tokens or OpenTimestamps proofs, and declares in its key log that it does so, so that readers can tell which versions existed by a date, for instance before a key was exposed. The extension is named by the URI <verbatim|https://opensheaf.org/opensheaf-timestamps-0.1>. The text is licensed under CC BY-SA 4.0; its JSON Schema is dedicated to the public domain under CC0 1.0.>

  <os-alert|warning|Warning.|<strong|Draft.> This extension rests on the owners, key logs and signatures of the specification (sections 6 and 7), whose field names are open (<hlink|issue #55|https://github.com/opensheaf/opensheaf.github.io/issues/55>), and on its pre-rotation of key logs, exposed keys and fork records, provisional (<hlink|issue #58|https://github.com/opensheaf/opensheaf.github.io/issues/58>).>

  <section*|1. Introduction (non-normative)><label|1-introduction-non-normative>

  In the <hlink|OpenSheaf specification|opensheaf-specification-0.1.tm>, every version of a line is signed by its owner, under a version of the owner's key log, and a good signature stays good (sections 6 and 7 of the specification). Signatures say who made a version, not when. So when a key may have been exposed, the core cannot tell the signatures made with it before from those its new holder makes after: the owner exposes the keys in its key log, or ends (section 6.3 of the specification); its signatures stay good, and readers trust its history only as far as other evidence goes (section 6.4 of the specification).

  A timestamp is such evidence: it shows that a signature existed by a date. A single researcher needs none. A journal, an institution, or anyone who wants its history to be trusted after a key is lost to others adopts this extension in its key log, from its first version, so that every signature it makes is dated.

  <section*|2. Conventions><label|2-conventions>

  The key words MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, RECOMMENDED, NOT RECOMMENDED, MAY and OPTIONAL in this document are to be interpreted as described in BCP 14 (RFC 2119 and RFC 8174) when, and only when, they appear in all capitals. Terms are those of the specification: owner, key log, key-log version, signature file, witness, line, branch, ended owner, fork record, current key, rotation key, exposed key.

  This extension follows the extension mechanism of section 2 of the specification: it never changes the meaning of what the specification defines, nor relaxes its requirements, never changes the status of a signature or a version, never ends an owner or decides a fork, and never lets a version into an archive by itself: its dates are evidence that an archive MAY weigh where the specification allows it (section 6.4 of the specification). A reader that does not know it ignores the files and data it defines.

  <section*|3. Timestamps><label|3-timestamps>

  A timestamp of a signature file shows that the file, and so the signature and the signed message it holds, existed by a date. It proves existence, nothing more. Two kinds are defined, which an owner MAY combine:

  <\itemize>
    <item><strong|RFC 3161 tokens>, from a time-stamping authority (a free public one, or a qualified provider under eIDAS): a file holding a DER-encoded <verbatim|TimeStampResp> whose message imprint is the SHA-512 digest of the bytes of the signature file, requested with the authority's certificates included (<verbatim|-cert> with <verbatim|openssl ts -query>), so that it can be checked with <verbatim|openssl ts -verify> without fetching them; its name ends in <verbatim|.tsr>.

    <item><strong|OpenTimestamps proofs> of the bytes of the same signature file; their names end in <verbatim|.ots>.
  </itemize>

  A timestamp file of the signature file <verbatim|\<less\>version\<gtr\>/signature-\<less\>k\<gtr\>.json> (section 7.2 of the specification), in the object's extension folder <verbatim|extensions/opensheaf-witnesses/>, is <verbatim|\<less\>version\<gtr\>/signature-\<less\>k\<gtr\>.json.\<less\>e\<gtr\>.tsr> or <verbatim|\<less\>version\<gtr\>/signature-\<less\>k\<gtr\>.json.\<less\>e\<gtr\>.ots>, beside it, where <verbatim|\<less\>e\<gtr\>> is the first 16 characters of the lowercase base32 (RFC 4648, without padding) SHA-256 digest of the timestamp file's own bytes, so that copies that add timestamps independently merge by keeping every file. Timestamp files are witnesses, never re-serialised, replaced or removed once made. An OpenTimestamps proof is pending when made, and complete once a Bitcoin block attests it; the completed proof is a new file beside the pending one. <strong|Anyone holding a copy MAY timestamp any signature file at any time>: a later timestamp never harms, since the earliest one dates the file. Since their names cannot be computed, a reader over HTTP finds timestamp files only where folders can be listed, or in the content of a branch (section 6); elsewhere it reports that it has not looked (section 14.1 of the specification).

  <section*|4. The owner's declaration><label|4-the-owners-declaration>

  An owner adopts this extension in its key log: its genesis record, for the first version of the key log, or the <verbatim|keys.json> of a later version holds, under <verbatim|extensions> (sections 5.1 and 6.1 of the specification), an entry keyed by <verbatim|https://opensheaf.org/opensheaf-timestamps-0.1>, an object with:

  <\itemize>
    <item><verbatim|timestampAuthorities>, OPTIONAL: RFC 3161 time-stamping authorities the owner trusts, each the SHA-256 fingerprint (lowercase hexadecimal) of the authority's signing certificate or of the root certificate of its chain. The authorities trusted for a signature file are those listed in the key-log version its <verbatim|keyLog> names and in the versions before it (for the first version, in the genesis record), so that no one can add an authority later to date earlier signatures. Without any, only OpenTimestamps proofs are used.
  </itemize>

  The entry, even empty, declares that the owner timestamps every signature it makes, of its key log and of its lines.

  The declaration validates against the schema of appendix A, and is part of the genesis record, fixed by the owner name, or of the key-log version, signed with it.

  <section*|5. Checking a timestamp><label|5-checking-a-timestamp>

  A timestamp is <strong|valid> for a signature file when:

  <\itemize>
    <item>for an RFC 3161 token: its message imprint is the SHA-512 digest of the file's bytes; its signing certificate, or the root of the chain it carries, has a fingerprint listed for that signature file (section 4); every certificate of the chain was within its validity period at the token's <verbatim|genTime>, the signing certificate is for time stamping (RFC 3161, section 2.3), and no revocation known to the reader dates from before <verbatim|genTime> (as <verbatim|openssl ts -verify> checks with <verbatim|-attime> set to <verbatim|genTime>); and the token verifies;

    <item>for an OpenTimestamps proof: it is complete, attested in a Bitcoin block; a pending proof counts for nothing.
  </itemize>

  The <strong|date> of a valid timestamp is the <verbatim|genTime> of an RFC 3161 token, or the time of the Bitcoin block an OpenTimestamps proof reaches; the earliest valid timestamp of a signature file is its date. A date counts only if it is not earlier than the date of the key-log version that the signature file's <verbatim|keyLog> names, and a signature naming an undated key-log version has none (signatures naming the first version, computed from the genesis record and never signed, are bounded by nothing): an authority is trusted only from the key-log version that lists it, which is itself dated by authorities listed before it, so no one, a thief with rotation keys included, can list an authority of its own to date signatures before the listing. A version is <strong|dated> by the n-th earliest of the dates of its good signature files naming one key-log version, n being the number of signatures it needs (<verbatim|threshold> or, for a version of a key log, <verbatim|nextThreshold> of the version before; sections 6.1 and 7.3 of the specification); the first version of a key log, never signed, is not dated; a version vouched for (section 7.3 of the specification) existed by the date of the version that vouches for it. Dates within two hours of a Bitcoin block time are uncertain by that much.

  <section*|6. Use><label|6-use>

  Dates are evidence for readers; this extension draws no conclusion from them in the format. For an owner that has ended, and for exposed keys (sections 6.3 and 6.4 of the specification), a reader MAY trust the versions dated before the time it believes a key was exposed, and SHOULD say on what evidence. A version that needs an exposed key, or whose signatures name a version of a key log from a fork point on, is not contested for a reader, an archive included, that trusts dates showing those signatures made before the exposure, or before the fork (section 7.3 of the specification); an archive that adds such a version on dates SHOULD say so. The time of the version that ends the owner or exposes keys bounds when the owner knew, and the times of the versions a fork record carries, when the fork was made. A branch keeps the timestamp files of its parent's signatures beside them in <verbatim|parent.signatures/> (section 9.2 of the specification), without the <verbatim|\<less\>version\<gtr\>/> folder (<verbatim|parent.signatures/signature-\<less\>k\<gtr\>.json.\<less\>e\<gtr\>.tsr>); a pending proof kept there can never be completed, and counts for nothing (section 5); the timestamp files of key logs are in their owner objects.

  Tools that create an owner SHOULD offer to adopt this extension in its genesis record, and so from the first version of its key log, and SHOULD timestamp each signature when they make it, before a version leaves its owner's hands: with an RFC 3161 token where an owner cannot wait for an OpenTimestamps proof to complete, and with an OpenTimestamps proof beside it where an owner wants evidence that rests on no authority.

  <section*|7. Verification><label|7-verification>

  A verifier that knows this extension, in addition to the checks of section 14 of the specification, validates each declaration against the schema of appendix A, merges the timestamp files of every copy it sees, checks every timestamp file against the signature file it stamps (section 5) and its name against the digest of its bytes (section 3), reporting each as valid, invalid, pending, or from an authority not listed, and reports the date of each version.

  <section*|8. Security considerations><label|8-security-considerations>

  <\itemize>
    <item><strong|Trust.> An RFC 3161 token rests on the authority's clock and keys: an authority that misdates, or whose key is stolen, can date a signature falsely. An authority listed later cannot date a signature earlier than its listing (section 5), so a thief who lists its own dates nothing before the theft. Authorities are never delisted: if a listed one is compromised, the remedy is a new owner (section 6.3 of the specification). Listing a root certificate trusts every authority that root certifies, so an owner that wants a single authority lists its signing certificate. An OpenTimestamps proof rests on no authority, only on Bitcoin, but is complete only after hours.

    <item><strong|Stripping.> A host can remove timestamp files from a copy; readers merge the timestamp files of every copy they see. A date only shows that a signature existed by then: a thief who stamps what it signs with a stolen key gets dates too, so dates help only before the exposure.
  </itemize>

  <section*|Appendix A. JSON Schema (normative)><label|appendix-a-json-schema-normative>

  The data of the declaration, the value of <verbatim|extensions["https://opensheaf.org/opensheaf-timestamps-0.1"]> in the genesis record of an owner or in <verbatim|keys.json>, validates against <hlink|opensheaf-timestamps-0.1.schema.json|https://opensheaf.org/schemas/opensheaf-timestamps-0.1.schema.json> (JSON Schema 2020-12, CC0 1.0), which allows no other properties, like the schemas of the genesis records and <verbatim|keys.json> that hold it.

  <section*|Appendix B. Example (non-normative)><label|appendix-b-example-non-normative>

  The genesis record of an owner adopting the extension from the start, with one RFC 3161 authority (a placeholder fingerprint) and OpenTimestamps; two current keys, on the owner's laptop and desktop, and the digests of three rotation keys, two of which sign the next version; the first version of its key log is computed from it, and not signed (section 6.1 of the specification; placeholder nonce):

  <\html-div-class|language-json>
  <\verbatim-code>
    {

    \ \ "format": "opensheaf-genesis/0.1",

    \ \ "kind": "owner",

    \ \ "created": "2026-01-10T09:00:00Z",

    \ \ "nonce": "3f9c2a7d41e85b06c9d2f1a4e7b03c58",

    \ \ "keys": [ "did:key:z6MkhaXgBZDvotDkL5257faiztiGiC2QtKLGpbnnEGta2doK",

    \ \ \ \ \ \ \ \ \ \ \ \ "did:key:z6MkpTHR8VNsBxYAAWHut2Geadd9jSwuBV8xRoAnwWsdvktH" ],

    \ \ "threshold": 1,

    \ \ "next": [ "bla7pvxpfmk4o2z2btgp26zqmkpxfqutl5imae3eovmqg6labdba",

    \ \ \ \ \ \ \ \ \ \ \ \ "zaolbrk7wl6fjx7atv3bphi3fkg2oukrvwj75cxp6j5dnknfme3q",

    \ \ \ \ \ \ \ \ \ \ \ \ "twrtx2ec6pzozvgex4m6ndtokezgccn63kqpbl7z4bnedmxbdx2a" ],

    \ \ "nextThreshold": 2,

    \ \ "extensions": {

    \ \ \ \ "https://opensheaf.org/opensheaf-timestamps-0.1": {

    \ \ \ \ \ \ "timestampAuthorities": [ "5b4e3f0c9d2a7e18c6f4b0a39d7e2c51f8a6b3d09e4c7a12f5b8d6e3a0c9f147" ]

    \ \ \ \ }

    \ \ }

    }
  </verbatim-code>
  </html-div-class>

  The files of one signature of the second version of its key log, by a rotation key, in the owner object's extension folder: an RFC 3161 token, a pending OpenTimestamps proof, and the completed proof written beside it later (placeholder digests):

  <\verbatim-code>
    extensions/opensheaf-witnesses/v2/signature-qvi7ibhm7zsahqx6.json

    extensions/opensheaf-witnesses/v2/signature-qvi7ibhm7zsahqx6.json.q7swxsz56bfiyotn.tsr

    extensions/opensheaf-witnesses/v2/signature-qvi7ibhm7zsahqx6.json.hm5uhlee72brbz64.ots

    extensions/opensheaf-witnesses/v2/signature-qvi7ibhm7zsahqx6.json.yq77barzw3gj7dbj.ots
  </verbatim-code>

  <section*|Appendix C. References><label|appendix-c-references>

  <\itemize>
    <item><hlink|OpenSheaf specification 0.1|opensheaf-specification-0.1.tm>, sections 2, 6, 7, 9 and 14

    <item><hlink|RFC 3161|https://www.rfc-editor.org/rfc/rfc3161>, Time-Stamp Protocol, and <hlink|RFC 5816|https://www.rfc-editor.org/rfc/rfc5816>, its update for other hash algorithms

    <item><hlink|OpenTimestamps|https://opentimestamps.org/>

    <item><hlink|RFC 2119|https://www.rfc-editor.org/rfc/rfc2119> and <hlink|RFC 8174|https://www.rfc-editor.org/rfc/rfc8174>
  </itemize>

  <section*|Changelog><label|changelog>

  <\itemize>
    <item><strong|0.1 (draft), 17 November 2026:> first draft, moving the timestamp rules out of the identity proposal of the specification, then revised the same day with the reviews of PR #30: RFC 3161 tokens and OpenTimestamps proofs of signature files, named by the digest of their own bytes, completed proofs as new files, anyone may stamp; the owner's declaration in <verbatim|keys.json> under <verbatim|extensions>; checking at <verbatim|genTime> with listed authorities and complete proofs only; the date of a version. Finally, following the specification, where an exposed key ends its owner, the extension changes no status: it no longer confirms the signatures of revoked keys (there are none) nor resolves forks of key logs, and only gives dates that readers may weigh.

    <item><strong|0.1 (draft), 17 November 2026, after a thirteenth review of PR #30:> the declaration is the entry itself, with only <verbatim|timestampAuthorities>; the authorities trusted for a signature are those listed up to the key-log version it names, not later ones; guidance for tools merged into section 6.

    <item><strong|0.1 (draft), 18 November 2026, after a fourteenth review of PR #30:> a date counts only if not earlier than the date of the key-log version the signature names, so that an authority listed later dates nothing before its listing; a version vouched for existed by the date of the version that vouches for it; a compromised authority means a new owner; repetitions cut.

    <item><strong|0.1 (draft), 19 November 2026, for the rebuilt specification (PR #30):> section references updated (extensions are in section 2); an exposed key ends the owner or is nullified by a fork of its key log and healing, and dates help readers weigh the versions of ended and tainted owners and of nullified keys (section 6); after an audit, timestamp files found over HTTP only where folders can be listed (section 3), and pending proofs in a branch count for nothing (section 6); after a second audit, keys nullified by a version of the key log as well as at a fork (sections 1 and 6).

    <item><strong|0.1 (draft), 19 November 2026, after an audit of pre-rotation (PR #30):> following the specification, the declaration of the first version of a key log is in the owner's genesis record, fixed by the owner name (sections 4 and 6, appendices A and B); dates are evidence an archive may weigh to add a version that needs an exposed key, which it otherwise never adds (sections 2 and 6).

    <item><strong|0.1 (draft), 19 November 2026, pre-rotation (PR #30):> following the pre-rotation of key logs in the specification (#58): exposed keys in place of nullified keys, and no healing or tainted owners (sections 1 and 6); a version of a key log is dated by as many signatures as it needs, <verbatim|nextThreshold> of the version before (section 5); the example of appendix B commits to rotation keys in <verbatim|next>.

    <item><strong|0.1 (draft), 19 November 2026, the computed first version of key logs (PR #30):> following the specification (#58), the first version of a key log is computed and not signed, so it is not dated, and the example of appendix B stamps a signature of the second version (section 5, appendix B); versions that need an exposed key, or name a key-log version from a fork point on, are contested unless trusted dates show their signatures made before (section 6); the schema allows no other properties (appendix A).
  </itemize>

</body>

<\initial>
  <\collection>
    <associate|page-medium|paper>
  </collection>
</initial>
