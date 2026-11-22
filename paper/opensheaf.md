# OpenSheaf: an exchange layer for scholarly documents
author: Massimiliano Gubinelli
affiliation: University of Oxford
email:
date: 22 November 2026

*Scholarly communication bundles several functions: recording, preserving,
announcing, filtering, distributing and assigning merit. Preprint servers and
publishers each hold a bundle of them, and the case for separating them is
old. We argue that what has been missing is a common, verifiable form in which
separate parties exchange documents and statements about them: an exchange
layer. OpenSheaf is a format for that layer. An archive is a set of plain
files on a static web server, stored in OCFL 1.1 and described in DataCite
4.7. Every version of a document is fixed by SHA-512 inventories and pinned by
the digest of its inventory. Works and owners are named by digests of genesis
records, independently of hosts and keys. Owners are keyed identities whose
key logs use pre-rotation, and they sign every version of their lines.
Collections, which pin versions of documents held in any archive, are objects
of the same format. Any copy can be checked anywhere. We describe version 0.2
of the specification, a draft; its reference tools; a formal model in Lean;
and a first archive of 83 documents. We compare OpenSheaf with some thirty
earlier designs. Most of its parts exist elsewhere; their combination was not
found. Adoption, incentives, key management and discovery remain open.*

keywords: scholarly communication, digital preservation, content addressing, signatures, key rotation, OCFL, DataCite, overlay journals

## Introduction {#sec:intro}

A classic analysis of scientific communication distinguishes registration,
awareness, certification and archiving [@roosendaal1997]; Van de Sompel and
others add rewarding [@vandesompel2004]. We use a division closer to what the
actors of today do [@positioning]: to <dfn>record</dfn> (fix every version
of a work and name it), to <dfn>preserve</dfn>, to <dfn>announce</dfn>, to
<dfn>filter</dfn> (select what deserves attention and vouch for it), to
<dfn>distribute</dfn> and to <dfn>assign merit</dfn>. Table @tab:functions
summarises what each function needs and who holds it today.

Table: The functions of scholarly communication, after [@positioning]. {#tab:functions}

| Function | Needs | Held today by |
|---|---|---|
| Record | fixity | arXiv, repositories, Zenodo, publishers |
| Preserve | institutions that last | repositories, LOCKSS, CLOCKSS, arXiv |
| Announce | speed | arXiv listings, mailing lists, social networks |
| Filter | judgement, a community that trusts it | journals, overlays, PCI, SciPost |
| Distribute | bandwidth, formats | servers, publishers, indexes |
| Assign merit | evidence others can check | journals, citation indexes |

The functions have different costs, time scales and people, yet they are
bundled: a publisher that holds the filter, which authors need for merit,
also obtains the record and the distribution [@positioning]. The case for
separating them is old: the deconstructed journal [@smith1999], the
distributed system of Van de Sompel and others [@vandesompel2004], the
decoupled journal [@priem2012], the repository community's Pubfair
[@pubfair2019]. Unbundled actors exist. Overlay journals, Peer Community In
and SciPost vet documents that stay where their authors put them. But they
rest on archives they do not control: a selection of arXiv papers can name
the version it vetted (`arXiv:...v2`), yet only arXiv vouches for the bytes
behind that name, and none of the overlays surveyed publishes a digest of the
version it vetted [@fedpub].

Our thesis is that what has been missing is a common form in which separated
parties exchange what they handle, so that each can rely on what the others
did without asking them: an <dfn>exchange layer</dfn> [@positioning]. It is
not a transport; HTTP, git or any copy moves the bytes. It is a narrow waist,
with any host below it (a static web server, a forge, a repository, a
preservation network) and any service above it (an announcement service, a
journal, an index). It defines how a version of a document is fixed, named,
found and checked, and how statements about documents are expressed. It
defines the forms of statements, not the acts: a selection is the form in
which a filter states what it vetted, but who filters, and by what standard,
is not its business.

OpenSheaf is a proposal for that layer [@spec02]. This paper describes it as
of 22 November 2026. Version 0.2 of the specification is a draft,
incompatible with version 0.1; archives made with the draft are rebuilt when
0.2 is final (specification, section 16.1). We present the principles of the
layer (Section @sec:principles), the format (Section @sec:format), an
implementation with reference tools, a formal model in Lean and a first
archive (Section @sec:impl), and a comparison with some thirty earlier
designs, which shows what is new and what is not (Section @sec:related).
Section @sec:eval discusses limitations and open questions.

## Design principles {#sec:principles}

Two meta-principles shape the rest. **Standards first:** storage follows the
Oxford Common File Layout (OCFL 1.1) [@ocfl] and description the DataCite
Metadata Schema 4.7 [@datacite]; OpenSheaf defines only what they leave open.
**A minimal core:** richer structures are built on top, by links, DataCite
relations or extensions (specification, appendix D.1). Eight principles
follow.

#### Fixity by digests
Every file of a version is fixed by its SHA-512 digest in an OCFL inventory,
and every inventory by its own digest. A version never changes once
deposited; corrections are new versions.

#### Names independent of hosts and keys
A work is named by the digest of a small file written when it is sealed, its
genesis record, which every copy carries. The name holds in every archive and
survives a change of keys.

#### Authority in owners' keys, not in hosts
Each history of a work belongs to an <dfn>owner</dfn>, a person, group or
institution holding keys, who signs its versions. An archive hosts what
owners write there and copies what others wrote elsewhere; it decides nothing
about what is authentic.

#### Statements are objects of the same format
A collection, which states that a set of versions belongs together or was
vetted, is itself a versioned, signed object, pinning its members by digest.
A document never states the collections that include it.

#### Static files only
An archive is files on any static web server: no server software, database,
chain, token or registry is needed to keep or to read one.

#### Copies checkable anywhere
Every location is a hint. What is fetched is checked against digests and
signatures, so a wrong location gives a reader nothing, or an older valid
copy, never a forged one (specification, section 3).

#### Append-only history
Nothing deposited is changed or removed, except in a draft and by a takedown.
Descriptions, notices, withdrawals and key changes are new versions.

#### Archives answer for their own rights
An archive that keeps a copy of another owner's work is responsible for
having the right to redistribute it. The format does not judge it, and
metadata are under CC0 so that pins, signatures and key logs can always be
copied (specification, sections 11.2 and 15.6).

## The format {#sec:format}

This section summarises version 0.2 [@spec02], which is authoritative. Its
appendix C follows one paper of the first archive through an illustrative
history; the names, keys, digests and signatures it shows are computed, with
a few stated exceptions. The listings below are taken from it, with long
digests and keys shortened in the middle.

### Archives and the discovery document {#sec:archives}

An <dfn>archive</dfn> is a host of objects, served at a base URL. Its base
URL is a location, not a name: no file of an object names the archive that
holds it, and an archive may be served at several base URLs (specification,
section 3). It consists of a discovery document and a storage root, both
required; indexes, recommended; and presentation files, such as a website,
never authoritative. Files are served byte for byte, and should be readable
across origins, so that tools in a browser can check them.

The <dfn>discovery document</dfn>, `opensheaf.json`, exists because static
web servers cannot list folders (Listing @lst:discovery). It names the
storage root and its layout, the profiles followed, the owners hosted with
their owner catalogues, every object but drafts with its head version, the
digest of its head inventory and its status, and the tombstones of objects
taken down. Beyond about a thousand objects the list moves into pages. It is
a map, not a witness: verifiers check it against the storage root
(specification, section 3.1). A <dfn>label</dfn> is a readable name the
archive may give a line for its website, never an identifier.

Listing: An excerpt of the discovery document of appendix C.6: `contact` and `extensions` are left out, and of `objects` only the paper's entry is shown. {#lst:discovery}

```json
{
  "format": "opensheaf-archive/0.2",
  "specification": "0.2",
  "name": "Papers of Massimiliano Gubinelli",
  "storageRoot": "ocfl/",
  "storageLayout":
    "opensheaf-owner-name-storage-layout",
  "profiles":
    [ "zenodo", "texmacs", "website" ],
  "owners": [ {
    "owner": "56wo6cdp...z3pa",
    "catalogue":
      "sheaf:kdye5s4i...kxeq:56wo6cdp...z3pa"
  } ],
  "indexes": { "names": 2, "owners": 2,
               "sha512": 2 },
  "objects": [ ..., {
    "id":
      "sheaf:zzgdggwl...oz4q:56wo6cdp...z3pa",
    "kind": "document",
    "name": "zzgdggwl...oz4q",
    "owner": "56wo6cdp...z3pa",
    "head": "v2",
    "inventorySha512": "e3e1...bb25",
    "status": "active",
    "label": "fractional-phi42-mass-gap"
  }, ... ],
  "tombstones": [ ... ]
}
```

The <dfn>storage root</dfn> is an OCFL 1.1 storage root. Its default layout
puts the line `sheaf:<name>:<owner>` at `<owner>/<name>/` and an owner's key
log at `<owner>/<owner>/`, so that an owner moves to another archive by
copying one folder; large archives use OCFL's hashed layout (specification,
section 3.2). An archive need not be public. It serves all its lines or
none, and a line kept privately is published by copying it into a public
archive, where it is the same line and every pin made before stays valid.

### Objects, versions and pins {#sec:objects}

An <dfn>object</dfn> is an OCFL object of kind `document`, `collection` or
`owner`, with identifier `sheaf:<name>:<owner>`. An <dfn>object
version</dfn> (`v1`, `v2`, ...) is made at every change and never changes
once made. A <dfn>document version</dfn> is a version of the work, numbered
by the line's owner from 1 without gaps; it changes only when the document's
own files change, so several object versions, with different descriptions
or notices, may hold one document version (specification, section 4).
External numberings are kept as labels: a work whose versions 1, 3 and 4 are
on arXiv has document versions 1, 2 and 3.

A <dfn>pin</dfn> is the pair of an object version and the SHA-512 digest of
its inventory file. An inventory records the digests of the files of its
version and of every earlier one, and every sealed version after the first
records in `previous` the digest of the inventory file before it. A pin
therefore fixes the object up to that version, the bytes of every earlier
inventory included, in any copy (specification, section 4.3). Collections,
branches and `sheaf:` URIs refer to object versions by pins. Table @tab:files
lists the files of an object.

Table: The files of an object and of its versions (specification, sections 4 to 9). {#tab:files}

| File | Role |
|---|---|
| `genesis.json` | fixes the name; every version |
| `object.json` | identity, versions, state |
| `datacite.json` | description; not for owners |
| sources, renditions | the document's own files |
| `members.json` | a collection's member list |
| `keys.json` | an owner's key-log version |
| `parent/` | a branch's evidence |
| `inventory.json` | OCFL inventory, per version |
| witness folder | signatures, outside versions |

A new document version is made exactly when the own files (sources,
renditions, change note) differ from those of the current version, compared
by logical path and digest (specification, section 4.2). A
<dfn>description-only version</dfn> keeps the files and changes only the
description: a DOI, a licence, a notice, a withdrawal. A version deposited
without sources says why, and may be completed later. A <dfn>notice</dfn>, a
statement about a document version made after it, is identified by its
position and corrected only by a later notice naming it. Dates never order
document versions. Listing @lst:object shows an `object.json`; beside it,
`datacite.json` holds the DataCite properties in the form of the DataCite
REST API, with relations to the same work elsewhere and to earlier versions
(specification, section 4.4).

Listing: The `object.json` of the paper's first version (appendix C.2), lines broken to fit. {#lst:object}

```json
{
  "format": "opensheaf-object/0.2",
  "specification": "0.2",
  "kind": "document",
  "name": "zzgdggwl...oz4q",
  "owner": "56wo6cdp...z3pa",
  "documentVersion": 1,
  "mainSource":
    "fractional-phi42-mass-gap.tm",
  "sourceFormat": "application/x-texmacs",
  "renditions": [
    { "path": "fractional-phi42-mass-gap.pdf",
      "mediaType": "application/pdf" } ],
  "toolchain": [
    { "name": "TeXmacs",
      "version": "2.1.5" } ],
  "stage": { "scheme": "NISO-JAV",
             "value": "AO" },
  "agreement": {
    "by": [ "P. Duch", "M. Gubinelli" ],
    "date": "2026-03-01",
    "method": "by e-mail" },
  "external": [
    { "role": "deposit", "service": "Zenodo",
      "record":
        "https://zenodo.org/records/1234567",
      "doi": "10.5281/zenodo.1234567" } ],
  "status": "active"
}
```

### Names and genesis records {#sec:names}

A work and an owner each have a <dfn>name</dfn>: a digest of a
<dfn>genesis record</dfn>, the file `genesis.json` written when a work is
sealed or an owner created (specification, section 5). For a document it
holds a kind, a creation time, a nonce of at least 128 random bits and the
`originator`, the owner of the first line (Listing @lst:genesis). The record
is part of every version of the work and of its branches, byte for byte, and
is never re-serialised, so no canonical form of JSON is needed.

Listing: The genesis record of the example paper (appendix C.2). {#lst:genesis}

```json
{
  "format": "opensheaf-genesis/0.2",
  "kind": "document",
  "created": "2026-03-02T09:14:00Z",
  "originator": "56wo6cdp...z3pa",
  "nonce": "6f65cd32058c16d6d78b05011772ff1d"
}
```

Algorithm k, for k from 0 to 15, takes the SHA-256 digest of the seed
`opensheaf-name-<k>`, a line feed and the bytes of `genesis.json`, and
writes it in lowercase base32 without padding: 52 characters, the last of
which holds the last bit of the digest and four zero bits, set to k
(specification, section 5.2). Names of different algorithms never coincide,
and are compared as strings, never decoded. Listing @lst:name computes them.
We ran it on the bytes of the genesis record of appendix C.2, with its final
line feed: it prints `zzgdggwlldcrw4bdeuvntiaobtw2kge6bc4go737pfekhfc5oz4q`
and, by algorithm 1, `aajozkubvmxu37pbu2lumdl37llv4ntkazd6j2es54zn23fkiknb`,
the names given there. On the owner's record of appendix C.1 it prints the
owner name given there, `56wo6cdpjsxk7ddgnqfp2quipfghukhtmvjuahvwzko7m4tkz3pa`.

Listing: Computing the names of a genesis record; checked against appendix C. {#lst:name}

```python
import base64, hashlib, sys

A = "abcdefghijklmnopqrstuvwxyz234567"

def name(g: bytes, k: int = 0) -> str:
    seed = b"opensheaf-name-%d\n" % k
    d = hashlib.sha256(seed + g).digest()
    s = base64.b32encode(d).decode()
    s = s.rstrip("=").lower()
    last = A.index(s[-1]) | k
    return s[:-1] + A[last]

g = open(sys.argv[1], "rb").read()
print(name(g, 0))
print(name(g, 1))
```

A genesis record thus has 16 names; its <dfn>genesis name</dfn>, by algorithm
0, names every line of the work except a branch renamed after a clash and the
branches named after it. The <dfn>originator</dfn>'s line has no parent, and
its first version must be signed by the originator; every other line of the
record is a branch (specification, section 5.3). Clashes arise only when a
line is made, and are resolved there: the originator's tool draws a new nonce,
and a branch whose line is taken takes the smallest free algorithm number
above its parent's. A genesis record reused for another work gives no valid
line, and there are no aliases: a work refused for a reused record is sealed
anew (specification, section 5.4).

### Owners and key logs {#sec:owners}

An owner is an object of kind `owner`, named by its own genesis record,
always by algorithm 0. Its object versions are its <dfn>key log</dfn>
(specification, section 6). The design follows the pre-rotation of KERI
[@keri2019], after earlier drafts in which a thief could contest the owner's
answer to a theft [@keysforks; @fedidentity].

Two kinds of keys have separate roles. <dfn>Current keys</dfn>, Ed25519 keys
written as `did:key` URIs, sign the versions of the owner's lines, at least
`threshold` of them per version. <dfn>Rotation keys</dfn> sign only the next
version of the key log; each version commits to them in advance by their
SHA-256 digests in `next`, with a `nextThreshold`. A rotation key is used
once, committed in one version only, and never becomes a current key;
current keys never sign the key log. The first version is computed from the
owner's genesis record, byte for byte in the JSON Canonicalization Scheme,
and is never signed, so the owner name commits to the first current keys and
to the digests of the first rotation keys (Listing @lst:owner). The
specification advises one current key per device and three rotation keys
kept apart with a `nextThreshold` of 2, which survive the loss of one or the
theft of one (specification, section 6.2).

Listing: The genesis record of the authors' owner (appendix C.1); the data of the timestamps extension is elided. {#lst:owner}

```json
{
  "format": "opensheaf-genesis/0.2",
  "kind": "owner",
  "created": "2026-03-01T17:40:00Z",
  "nonce": "1b4d9964664d9825076eb8558af61162",
  "keys": [
    "did:key:z6MksKLD...MkMuVW"
  ],
  "threshold": 1,
  "next": [
    "oxthfb6b...qnalha",
    "h6k4k6c5...vla6vq",
    "lnaifwjn...npaklq"
  ],
  "nextThreshold": 2,
  "keeper": [
    "https://orcid.org/0000-0002-1234-5677"
  ],
  "extensions": { ... }
}
```

#### Exposure, ending and forks
An owner whose current keys may have been exposed, and could reach the
`threshold`, signs at once, with rotation keys, a version listing them in
`exposed`, or ends. Whoever holds
the current keys can neither prevent nor contest it. There is no
revocation: signatures carry no time, so nothing tells what a key signed
before it leaked from what a thief signs after; signatures stay good, and
what needs an exposed key becomes contested (Section @sec:lines). An owner
ends by signing a last version with `ended` and, optionally, a successor.
Two signed versions of a key log with one number and different inventories
are a <dfn>fork of the key log</dfn>; only rotation keys can make one,
stolen before use or kept after it. The format cannot tell which side is the
owner's, so a fork ends the owner and freezes it: archives add no more
versions of its lines unless trusted evidence dates them before the fork
(specification, sections 6.3 and 7.5). An archive keeps the side it saw
first and appends a <dfn>fork record</dfn>, an unsigned version carrying the
other side, so that every copy shows the fork.

#### Travel and keepers
A key log checks itself from its owner name, so a copy from any source is as
good as the original. Every copy of an object holds beside it the key logs
its signatures need, and the longer of two copies is used; no one can prove
offline that a key log is complete (specification, section 6.5). An owner may
name one <dfn>keeper</dfn> in its genesis record, an ORCID iD or a domain,
who may confirm the link, names the accepted successor when no ending
version before a fork point names one, and, besides the law, alone can have
an owner object that other objects need taken down (specification,
sections 6.6 and 13.2). The
keeper says who answers for an owner, not who owns its lines, which only its
keys decide.

### Lines, signatures and statuses {#sec:lines}

A <dfn>line</dfn> is the history of a work as decided by one owner,
`sheaf:<name>:<owner>`, and is its signed versions, wherever stored
(specification, section 7). Every sealed version is signed by at least
`threshold` current keys of one version of the owner's key log, each in a
signature file kept in the object's witness folder, outside every version
(Listing @lst:signature). The file's name is derived from its key, so a
reader that knows the keys finds it without listing folders. What is signed
is a message of five lines: a domain separator, the object, the version, the
inventory digest and the key-log version, as a pin. A signature is judged
against that key-log version alone, so retired keys leave earlier signatures
good. Others' attestations, and timestamps, are witnesses, never signatures
of the line.

Listing: A signature file of the paper's second version (appendix C.3). {#lst:signature}

```json
{
  "format": "opensheaf-signature/0.2",
  "object":
    "sheaf:zzgdggwl...oz4q:56wo6cdp...z3pa",
  "version": "v2",
  "inventorySha512": "e3e1...bb25",
  "signer": "56wo6cdp...z3pa",
  "key": "did:key:z6MkugKq...DDvThn",
  "keyLog":
    "sheaf:56wo...z3pa/v2?sha512=7673...3f84",
  "signature": "Gf9KOxH/...qipyBA=="
}
```

Statuses are defined once (specification, section 7.3). A signature file is
invalid, unchecked (its key-log version cannot be reached) or good, and stays
good for ever. A version of a line is <dfn>signed</dfn>, directly or
<dfn>vouched for</dfn> by a later version signed directly that extends it;
or unchecked; or not a version, never shown as one. A signed version is
<dfn>contested</dfn> when it would not be signed without signatures made
with an exposed key, or naming a key-log version from a fork point on,
unless evidence the reader trusts dates them before. Readers use the
<dfn>latest signed version</dfn>, signed and not contested, for a line's
history and status. Two copies whose latest signed versions do not agree are
a <dfn>fork of the line</dfn>, reported and never recorded. An archive adds a
version only if it is then signed and not contested, and never removes a
version on evidence that a host or a thief could produce (specification,
sections 7.4 and 7.5).

### Collections {#sec:collections}

A <dfn>collection</dfn> is an object whose versions hold `members.json`, a
list of lines of documents or collections, in any archive, each pinned
(specification, section 8). Its source is the member list, so any change of
it is a new document version. Keeping and vetting are different acts. A
<dfn>catalogue</dfn> keeps objects whole and is impartial about their
versions; with `follow` set to `latest`, its tool writes a new version when a
member has a new signed version. A <dfn>selection</dfn> vets particular
versions: each member pins a revision set, the document versions vetted
(Listing @lst:selection), and later versions by the authors enter only by a
new version of the selection.

Listing: A selection, an issue of a journal (appendix C.4); `cite` is elided. {#lst:selection}

```json
{
  "format": "opensheaf-collection/0.2",
  "type": "selection",
  "members": [ {
    "kind": "document",
    "name": "zzgdggwl...oz4q",
    "owner": "tqr6lchn...tdka",
    "at": [ "https://journal.example.org/" ],
    "revisions": [ {
      "documentVersion": 2,
      "version": "v1",
      "inventorySha512": "1c4e...9a5a" } ],
    "cite": { ... }
  }, {
    "kind": "document",
    "name": "zzgdggwl...oz4q",
    "owner": "56wo6cdp...z3pa",
    "at": [ "https://mgubi.org/papers/" ],
    "revisions": [ {
      "documentVersion": 2,
      "version": "v2",
      "inventorySha512": "e3e1...bb25",
      "doi": "10.5281/zenodo.1234568" } ]
  } ]
}
```

A member names its line by `name` and `owner`, and gives in `at` base URLs
where copies may be found, as equal hints. Since a pin fixes an inventory,
which fixes every file and earlier version, collections are hash trees
across archives, and pins cannot form cycles. Each owner an archive hosts
has there an <dfn>owner catalogue</dfn>, signed by that owner only; it
replaced a single catalogue per archive, which would have needed one owner's
keys for every other owner's deposits (specification, appendix D.5). A
verifier gives each member one of the statuses of Table @tab:status; whether
a copy matches is decided by the bytes of its inventory file.

Table: The statuses of a member, or of a revision in a selection (specification, section 8.5). {#tab:status}

| Status | When |
|---|---|
| verified | a copy matches the pin; signed, not contested |
| contested | a copy matches the pin; contested |
| mismatch | copies found, none matches the pin |
| unchecked | the version pinned is unchecked |
| not a version | the collection pinned what it must not |
| unavailable | no copy is found |
| removed | no copy; an archive holds a tombstone |

### Branches and accepted copies {#sec:branches}

A <dfn>branch</dfn> is a line of another owner that continues a work from a
signed version of another line: a co-author carrying the work on, the
successor of an ended owner, a journal keeping the version it vetted
(specification, section 9). It has the work's genesis record, and is a new
object. Its content holds the evidence of its branch point in `parent/`: the
parent's inventory, its `object.json`, the parent owner's good signature
files and, for a branch of a branch, the parent's own evidence, back to the
originator's line. A branch point is thus checked without access to the
parent's line, and is inconsistent, confirmed or unchecked. A branch numbers
its own document versions from 1, and may take a later version of the same
parent line as a new branch point. A line is never handed over; work of
another line is taken in by a deposit with a relation.

An <dfn>accepted copy</dfn> is a branch kept by the owner of a selection from
a revision it vetted. A version the journal makes itself, such as a typeset
version of record, is a later version of its accepted copy, with the
authors' agreement and relations to their versions (specification, section
9.6).

### Drafts, mirrors and rights {#sec:drafts}

A <dfn>draft</dfn> belongs to the reserved owner `draft`: it is never signed,
pinned, copied or named by a `sheaf:` URI, and is the only object that may be
rewritten or deleted (specification, section 10). <dfn>Sealing</dfn> makes
from a work, under a new genesis record, the first signed version of its
originator's line, at the owner's request, before a version first leaves the
owner's hands.

A <dfn>mirror</dfn> is a copy of a line in an archive where its owner does
not write. Nothing marks it: it is the same line, grown only by the owner's
signed versions (specification, section 11). Whoever keeps mirrors or indexes
of others' lines is a <dfn>custodian</dfn>. An archive that keeps a mirror,
or a branch, is responsible for having the right to redistribute what it
copies, by licence, agreement or law; the specification does not judge it,
and a reference, a pin without a copy, needs no permission (specification,
section 11.2). Whether a copy may stop at a pinned version (#39) and what a
custodian promises to keep (#54) are open.

### Identifiers, resolution and indexes {#sec:uris}

Lines, versions, pins, works and owners are written as `sheaf:` URIs
(Listing @lst:uriforms). Without an owner part, a URI names the originator's
line, read from the genesis record every copy carries; never "the latest"
line. `/v<n>` names a document version; a `sha512` parameter names exactly
one object version; `at` is a hint, not part of what is named
(specification, section 12.1). For people, names may be shortened to
prefixes of at least 8 characters, which a resolver expands only when one
candidate matches. Listing @lst:uris gives URIs of the example.

Listing: The forms of `sheaf:` URIs (specification, section 12.1). {#lst:uriforms}

```text
sheaf:<name>
    the originator's line
sheaf:<name>:<owner>
    the line of that owner
sheaf:<name>:*
    the work: all its lines
sheaf:<name>[:<owner>]/v<n>
    document version n of the line
sheaf:<name>[:<owner>]/v<n>?sha512=<digest>
    one object version holding it
sheaf:<owner>
    an owner: its key log
sheaf:<owner>/v<n>?sha512=<digest>
    a version of its key log
```

Listing: Some of the URIs of the paper, of the accepted copy and of the owner given in appendix C.7. {#lst:uris}

```text
sheaf:zzgdggwl...oz4q
    the authors' line
sheaf:zzgdggwl...oz4q/v2
    document version 2 of the authors' line
sheaf:zzgdggwl...oz4q/v2?sha512=e3e1...bb25
    the authors' object version v2
sheaf:zzgdggwl...oz4q:tqr6lchn...tdka/v2
    document version 2 of the journal's line
sheaf:zzgdggwl...oz4q:*
    the work: every line of it
sheaf:56wo6cdp...z3pa
    the authors' owner: its key log
sheaf:zzgdggwl/v2
    a short form of the second
```

A <dfn>resolver</dfn> finds and checks what a URI names (Listing
@lst:resolve). It tries the locations it has, in any order, checks every copy
found, and uses the latest signed version among the copies that agree,
reporting forks, ended owners, exposed keys and tombstones (specification,
section 12.3). To find every line of a work, it looks up all 16 names and
keeps only entries whose genesis record is byte for byte the same, so no hash
is assumed free of collisions (specification, section 12.4). An archive should
keep indexes by name, by owner and by inventory digest; custodians may keep
them for many archives. A <dfn>gateway</dfn> serves URIs as web links, with a
page or a temporary redirect only to a copy it has checked (specification,
section 12.6). External deposits, such as a Zenodo record, are witnesses, not
copies: they hold no inventory and resolve nothing.

Listing: Resolution, after section 12.3 of the specification (pseudocode). {#lst:resolve}

```text
resolve(uri):
  name, owner, n, digest, at = parse(uri)
  for loc in at, members' at, parent.url,
             indexes, configuration:
    read loc/opensheaf.json
    find (name, owner) in the indexes,
      or else in objects
    fetch the inventory of the version
    check name is a name of genesis.json
    check object.json: name and owner
    check signatures against the key log
      beside the copy, or a longer copy
    check the version holds n
    if digest: check the inventory bytes,
      whatever the checksum file says
    keep the copy, with its location
  report copies that do not match, forks,
    ended owners, exposed keys, tombstones
  if digest: return a copy that matches,
    or else report a mismatch
  return the latest signed version
    among the copies that agree
```

### Withdrawal, takedown and tombstones {#sec:withdrawal}

An owner withdraws a line; an archive takes down an object (specification,
section 13). A <dfn>withdrawal</dfn> is a description-only version with
status `withdrawn`, a date and a reason, which withdraws every document
version deposited before it; they stay signed, pinned and copied, and copies
follow the withdrawal, since it is a signed version. A new document version
reinstates the line. A <dfn>takedown</dfn> deletes a whole object from one
archive, since OCFL cannot remove a file without changing inventories and so
every pin, and leaves a <dfn>tombstone</dfn> in the discovery document. A
tombstone is not signed and speaks for its archive only: copies elsewhere do
not follow it by themselves, and resolution goes on to them.

### Verification and security {#sec:verification}

A <dfn>verifier</dfn> checks files and storage, key logs, objects,
collections and the archive as a whole, in that order (specification, section
14). Its findings are <dfn>errors</dfn>, breaches of a MUST;
<dfn>warnings</dfn>, breaches of a SHOULD, breaches the archive cannot
repair, and checks not made; and <dfn>results</dfn>, such as statuses, forks,
ended owners and withdrawals, which are states of the world rather than
faults. Over HTTP a verifier cannot list folders, and says what it could not
check.

The security claim is narrow. A host or a network cannot forge a version,
add one to another owner's line, or make a valid line from a reused genesis
record. It can withhold, serving an older copy or a key log that stops
before an end or a fork record, and it can delete what it serves, never a
copy held elsewhere (specification, section 15.1). A good signature shows
that a key of the owner's key log signed one version; not who wrote the
document, who the owner is, when it was signed, or that no later version
exists. Among the residual risks it lists are a host that withholds an exposure,
archives that see different sides of a fork, a retired key never exposed,
and a thief who forks a key log and exposes the owner's earlier keys, which
harms trust in the owner's past but lets no forgery pass.

### Profiles and extensions {#sec:profiles}

A <dfn>profile</dfn> is a set of rules for an external service or tool,
normative for archives that declare it (specification, appendix A). The
Zenodo profile makes each line a record and each document version a record
version with its own DOI, records MD5 digests, which Zenodo reports, in the
inventories' `fixity`, and signs a version before the record is published.
The TeXmacs profile fixes how renditions are made from TeXmacs sources. The
website profile makes landing pages with the meta tags that Google Scholar
reads, a feed, and optionally an OAI-PMH static repository. Extensions
record what the core leaves open, under `extensions`, without changing its
meaning. The timestamps extension keeps RFC 3161 tokens and OpenTimestamps
proofs of signature files beside them; they are evidence only, and change no
status by themselves [@timestamps02]. A companion text says how to keep an
archive in git without git changing a byte of it [@git02].

## Implementation {#sec:impl}

### Reference tools {#sec:tools}

The reference implementation, opensheaf-py, provides the `osheaf` command
[@tools]. It is a literate program that explains the code along the
specification, and follows the draft: archives made now may have to be
rebuilt. It deposits documents and new versions and signs them; keeps
notices, withdrawals, collections, mirrors, branches, accepted copies and
drafts; writes the discovery document, the indexes and a website; imports
papers from arXiv; deposits on Zenodo, by default in its sandbox; and
verifies an archive, optionally also against the JSON Schemas and with an
independent OCFL validator. Listing @lst:osheaf shows a first session, as
documented in its guide.

Listing: Creating an archive and an owner, depositing a paper and a second version, adding a notice about the first, and checking the archive [@tools]. {#lst:osheaf}

```sh
osheaf init my-papers \
  --name "Papers of Jane Doe" \
  --base-url \
    https://janedoe.github.io/papers/ \
  --curator "Doe, Jane" \
  --affiliation "Example University" \
  --new-owner \
  --export /Volumes/USB/opensheaf-keys \
  --print
cd my-papers
osheaf deposit kpz-uniqueness paper.tex \
  --pdf paper.pdf --new \
  --extra-source refs.bib \
  --extra-source \
    figures/fig1.pdf=figures/fig1.pdf \
  --title \
    "Energy solutions of KPZ are unique" \
  --author "Doe, Jane|Example University" \
  --author \
    "Roe, Richard|Another University" \
  --abstract-file abstract.txt \
  --keyword "stochastic PDE" \
  --rights cc-by-4.0 --available 2015-08-31
osheaf deposit kpz-uniqueness paper.tex \
  --pdf paper.pdf \
  --changes "Lemma 2 corrected." \
  --title \
    "Energy solutions of KPZ are unique" \
  --author "Doe, Jane|Example University"
osheaf notice kpz-uniqueness --about 1 \
  --text \
  "Lemma 2 is wrong as stated; see version 2."
osheaf collect
osheaf verify
```

Key management is where the tools meet users most. By default `init` writes
the rotation keys, encrypted under a passphrase, to a removable drive and
optionally to printed sheets, and asks the user to type back a check of each;
a key wallet in a private GitHub repository or a password manager trades
security for convenience, and the tools say so. A wallet may be unlocked by
a passkey. A lost computer is answered by `osheaf owner expose`, a version
of the key log signed by two rotation keys; versions the owner made that
only the exposed key signed are then signed again with a new key.

### The Explorer and the Manager {#sec:explorer}

The Explorer shows an archive or a collection in the browser, with its
objects, versions, files and members across archives, and verifies it as
section 14 of the specification asks, from a static page [@explorer]. The
Manager keeps from a page an archive made from the archive template, a GitHub
repository with its workflows and Pages already set up [@manager; @template].
It can make the owner and add keys to its key log; rotation keys then pass
through the page's memory, so the highest security level keeps them offline,
used by `osheaf` alone.

### A formal model in Lean {#sec:lean}

The specification states promises in prose: that a pin, once valid, stays
valid; that a host cannot add a version to another owner's line; that a fork
of a key log freezes its owner. A model in Lean 4, written as two literate
programs, states the rules as definitions and the promises as theorems
[@lean]. It is non-normative; a difference between it and the specification
is a bug of one or the other. Digests, names and signature verification are
left to an abstract environment, about which almost nothing is assumed, and
every change of a world is one of four steps: a new archive, object, version
or set of signature files. The theorems include:

- `Step.resolveAt_ok`, immutability: once a pin resolves at an archive, no
  step changes what it resolves to there, for any digest function, since
  archives only add;
- `current_keys_cannot_extend`: holders of current keys alone cannot extend
  a key log;
- `Events.fork_freezes_forever`: a recorded fork freezes the owner there for
  ever;
- `forgery_needs_owner_key`: in every world built by valid steps and
  takedowns, the head of every copy of every line other than a key log is
  signed with a current key of the owner's key log;
- `Events.copiesAgree` and `no_cycles`: copies agree when the owner signs
  one history and no copy collides with it, and pins then form no cycles;
- `ReaderAccepts.no_forgery`: what a reader accepts from one copy and a key
  log, wherever they came from, is a prefix of the history the owner's keys
  signed, assuming only that signatures verify only with their keys and that
  the inventories compared do not collide.

The model also exhibits the residual risks of section 15.1 on concrete
worlds. A second program reads worlds as sheaves, which makes the name
precise: named document versions are the points of a space, each object
version is a section, and the sections of all copies of a line glue into
exactly one when the owner signs one history (`world_glues`); when they do
not glue, a fork of the line is the reason.

### The first archive {#sec:papers}

The first archive is the author's, at `https://mgubi.org/papers/`, kept in
the git repository mgubi/papers with these tools [@papers]. It follows
version 0.2 since its rebuild on 20 November 2026, and keeps TeXmacs sources,
HTML versions and PDFs. It holds 83 documents, 81 of which have versions
imported from arXiv, 154 arXiv versions in all [@arxivwp]. The import
records arXiv as an external record of role `source`, arXiv's `vN` as a
label, the SHA-512 digests of the files received, and relations to the
versioned arXiv identifier and the arXiv DOI. Document versions do not
follow arXiv's numbers: in one line, document versions 1, 2 and 3 are
arXiv's `v1`, `v3` and `v4`, version 4 is the authors' accepted version,
never on arXiv, and version 5 is arXiv's `v5`.

Licences limit what others may do. Of the 81 lines imported from arXiv, the
latest version of 52 carries arXiv's default licence, 20 the licence assumed
for submissions of 1991 to 2003, 8 CC BY 4.0 and 1 CC0; only 3 lines carry
an open licence in every version, and in 8 the licence changes between
versions [@arxivwp]. A custodian without the authors' agreement has the
right to redistribute few of them. The digests recorded fix what the owner
received when it imported, not what arXiv served on the day of each version.

### What implementing taught {#sec:lessons}

The changelog of the specification records what changed as the tools, the
model and the archive were built (specification, section 16.2).

#### Rules a verifier can decide
Several rules were rewritten so that a verifier decides them from the files
alone. That a version deposited out of order must write `history` became a
definition: the history is the order of numbers unless `history` says
otherwise (#51). Digests became lower case, so that a pin is compared as a
string (#49). A copy whose inventory bytes match a pin matches, whatever its
checksum file says (#48). On 20 November 2026 a set of ambiguities found
while writing the tools was resolved in one revision.

#### What a pin fixes
A pin fixed the files of earlier versions but not the bytes of their
inventories, so the pin of a version vouched for was weaker than that of one
signed directly. The inventory chain closed the gap (#46).

#### Keys and forks
The rules on keys were rewritten several times; each version closed holes and
opened others, and letting an owner heal a fork of its key log could not
converge against a thief holding a listed key [@keysforks]. A survey of
identity systems found that recovery from theft rests either on an order the
thief cannot rewrite or on a commitment made before the theft
[@fedidentity]. OpenSheaf has no order, so it took the commitment:
pre-rotation, exposure that cannot be contested, and a fork that ends the
owner (#58). Among the lessons recorded are never to remove on evidence an
attacker can shape, to define statuses once, and to rewrite rather than
patch.

## Related work {#sec:related}

This section follows two working papers that survey decentralised and
federated publishing from their own sources [@fedpub; @positioning]; claims
marked unverified there are marked so here. Table @tab:compare sets
OpenSheaf against ten systems of the survey, among them the three it finds
closest.

Table*: OpenSheaf and ten systems of the survey [@fedpub]. {#tab:compare}

| System | Fixity | Names | Who writes | Copies | Identity | Requires |
|---|---|---|---|---|---|---|
| Nanopublications | SHA-256 Trusty URI | content digest | any key, quota by trust | registries replicate and check | RSA key, ORCID by declaration | registry servers |
| DSI and DSGL | git hashes (SHA-1) | initial commit | SSH keys listed in the succession | any git host, Software Heritage | Ed25519 SSH keys | a git host |
| Underlay | SHA-256, prolly trees | server namespace, version hash | the collection's server; authors sign in v3 | S3 mirrors checked by hash | accounts; author keys in v3 | an authoritative server |
| DeSci Nodes | IPFS CIDs, Ceramic stream | integer in a contract | stream controller | IPFS pinning, Codex nodes | wallet DID, ORCID in profile | chain, registry, stream service |
| Hypergraph (Dat) | Hypercore signed log | public key and version | holder of the write key | peers seed | the key | online peers (ended 2021) |
| dokieli | Memento, web archive | URL | WebID holder | web archives | WebID; RSA keys since 2026 | a storage server |
| eLife, PCI, Episciences | none published | DOI, version, URL | journal or group | own copies at most | accounts, ORCID | the preprint server |
| PubPub | by the application | DOI per pub, URL | community members | exports, self-hosting | accounts, ORCID sign-in | running services |
| OpenSheaf | SHA-512 inventories, pins | genesis digest and owner name | the line's owner | any archive, checked | key log, pre-rotation | a static web server |

### Content-addressed and signed records

**Nanopublications** are small RDF statements [@groth2010], named by Trusty
URIs, which end with a SHA-256 digest of the content [@kuhn2014], and
replicated between servers [@kuhn2016]. The current Nanopub Registry accepts
only signed nanopublications, gives each key a quota derived from endorsements
by trusted agents, and lets a declaration bind an ORCID iD to a key
[@kuhn2026]; a snapshot of 4 May 2026 counts 79,672 nanopublications by 616
signing agents [@kuhn2026; @fedpub]. A Trusty URI names one content, so a work
has no name across its versions, and the documented queries count a
supersession only under the same key. Nanopublications are a natural form for
statements about OpenSheaf versions, which are open (#21).

**Document Succession Identifiers** are the closest design in premises
[@ellerman2024b]: a succession of editions is a git history named from its
initial commit, each later commit signed with an SSH key listed in the
succession. Authority rests on keys, so a succession moves between hosts.
As read in [@fedpub], a listed key can sign a commit that changes the list,
so a thief holding one could extend and contest the succession; pre-rotation
exists to prevent this, at the cost of more keys. A DSI names one
succession, rests on SHA-1, and has no owners shared across documents, no
branches of other owners, no collections and no withdrawal.

**The Underlay** keeps collections of content-addressed records with
immutable, sequential versions, append-only logs signed by the server after
Certificate Transparency, and mirrors checked against hashes
[@kf2026a; @kf2026c]. Each collection has one authoritative server; in its
draft third protocol authors may sign changes, but one authority still
accepts versions. Its salted commitments to private records bear on blind
review (#63). **SWHIDs** name source code by intrinsic digests
[@dicosmo2018] and are now an ISO standard [@fedpub], with no identity,
signature or notion of a work; OpenSheaf records them as relations and
witnesses. **RO-Crate** describes research packages and leaves fixity to the
packaging, OCFL among them [@rocrate2022].

### Peer-to-peer and blockchain publishing

**DeSci Nodes** name research objects by dPIDs, integers in an upgradeable
registry contract deployed on a test network, with histories as Ceramic
streams anchored on Ethereum [@descinodes]; Ceramic's developers deprecated
the software it used in 2025 [@ceramic2025], and whether its anchor service
has closed is unverified [@fedpub]. A `sheaf:` name is checked without a
registry, chain or stream service. **Hypergraph**, built on Dat
[@hartgerink2019], named each module by a public key, so the module's
identity and the authority to write it were one secret; it ended in 2021,
for reasons unverified, and its successor keeps a static archive as its
safety net [@fedpub]. The other **blockchain platforms** for publishing found
closed or dropped the chain [@fedpub]; what lasted is the dated digest, as
in bloxberg's proofs of existence [@wittek2020] and Ledger's signed digests,
whose Bitcoin timestamps are unverified [@ledger].
OpenSheaf keeps dated digests as optional witnesses, in its timestamps
extension.

### Linked data, personal servers and signing

**dokieli** and Linked Research publish articles as linked data on authors'
servers [@capadisli2017; @capadisli2020]; versions are fixed by Mementos and
web archives, identity is a WebID, and since 2026 dokieli signs annotations,
as nanopublications, with RSA keys that are added, never replaced, and so
cannot be rotated after a theft; whether whole articles are signed is
unverified [@fedpub]. **Solid** pods are mutable stores behind access control
[@solid], and the ResearcherPod work records the life of an artefact as
notifications kept by each party [@hochstenbach2023]. **Sigstore**, as used by
PyPI, binds short-lived certificates to a workflow identity and dates
signatures in a transparency log [@pep740]; **C2PA** is proposed for research
images [@oric2pa], but no publisher was found adopting it [@fedpub]. These
bind a signature to an identity checked at signing time by a third party;
OpenSheaf binds it to a key log that checks itself, and its signatures carry
no time. A Sigstore signature over a pin could be a witness (#41).

### Overlays and platforms

**eLife**'s docmaps fix the preprint versions it reviews by DOI, version, URL
and archived packages, but by no digest [@elife; @fedpub]; **Docmaps**
describe such editorial events [@mcdowell2021]. **Peer Community In**
recommends a particular version of a preprint, and **Episciences** asks for
the version submitted [@pci; @episciences; @fedpub]. Each overlay fixes what
it vetted by a number or URL, valid while the server keeps it; a selection
pins it by digest, checked in any copy. **PubPub** has releases numbered from
1, like document versions, but fixed by a rule of its database, with DOIs for
pubs, not releases [@fedpub]; in June 2025, after a funder withdrew, it
announced the end of its hosted services, and in January 2026 reversed this
[@kf2025b; @kf2026f]. Its export to the Underlay comes closest to OpenSheaf,
with files named by SHA-256 but fixed by a server's log, not signed.

### Repositories, preservation and harvesting

**LOCKSS** libraries keep copies of the same content and compare them to
repair damage, and **CLOCKSS** keeps dark copies of journals
[@maniatis2003; @lockss]; with pins, any node's copy is checked alone.
**COAR Notify** carries review requests and announcements between
repositories and services [@coarnotify], implementing part of Pubfair
[@pubfair2019]; its notices name resources by URI, with no digest or
signature, and could carry pins. **OAI-PMH** harvests metadata [@oaipmh];
the discovery document and feed play its part with verifiable content.
**DOIs** resolve through registries to wherever a work is said to be, and do
not fix bytes [@positioning]; a pin says which bytes a DOI's work is.

### Federated and distributed systems

**ActivityPub** needs a running server per node and binds identity to a domain
[@activitypub]; it suits announcement, which the layer leaves to others. **The
AT Protocol** is the closest in architecture, with signed user repositories,
relays and third-party feeds [@atproto], but its repositories are mutable and
its main identity method depends on a directory; an OpenSheaf owner needs
none, and pays with the rule that a fork ends it. **Nostr** signs at the
source, but its identity is the key itself [@nostr]. **IPFS** fetches content
by hash [@ipfs]; an OpenSheaf pin also fixes all earlier versions, and, unlike
a pin in IPFS, keeps nothing available. **Distributed hash tables**
[@kademlia2002] answer where a copy is, which pins do not, and could serve as
optional resolvers (#20). **Git** links commits by mostly SHA-1 hashes;
OpenSheaf uses it as a store, its integrity staying in OCFL inventories
[@git02]. **Radicle** names repositories by a digest and peers by keys, each
peer writing only its own branch, with delegates changed by a threshold of the
previous ones [@radicle]; OpenSheaf took from it, as from The Update Framework
[@tuf], a key log signed by keys of the version before, and added pre-rotation
and plain files [@radiclewp; @fedidentity].

### arXiv, Hexagon and alphaXiv

**arXiv** keeps every version and its sources, refuses changes in place
because they would be backdated, and since 2026 has dark copies at Portico
and TIB [@arxivwp]. But its record is fixed only by its word, with no digest
published; its DOIs name articles, not versions; and its default licence
gives it a right to distribute that it cannot pass on. OpenSheaf adds pins,
signatures, versions never on arXiv and selections that say what they
vetted, and cannot replace arXiv's announcement. **Hexagon**, a repository
for the mathematical sciences opened in September 2026, accepts works written
in part or entirely by language models, records how each version was made
and publishes SHA-256 digests of files [@antieau2026; @hexagonwp];
signatures were not found, and OpenSheaf has no field for provenance.
**alphaXiv** grew from discussing arXiv papers into a service that also
records; its pages describe no digests [@alphaxivwp].

### What is new, and what is not {#sec:new}

Most of OpenSheaf's parts exist elsewhere (Table @tab:new). What the search
did not find is their combination, for scholarly documents [@fedpub]: a name
of the work shared by the lines of several owners, apart from hosts and keys;
owners with key logs and pre-rotation; collections that pin other parties'
versions as signed objects, keeping whole objects apart from vetting versions;
rules for withdrawal, takedown and the rights of copies in a federation where
no archive binds another; and static files as the whole requirement. Each
closest design has parts OpenSheaf lacks: nanopublications a working network
with trust and quotas, the Underlay salted commitments and packs, DSGL the
simplicity of one git history per document.

Table: What is new and what is not [@fedpub]. {#tab:new}

| Element | Earlier work |
|---|---|
| names from content digests | Trusty URIs, SWHIDs, IPFS |
| versions signed by authors | DSGL, Dat, Ledger, nanopublications |
| a name from the first state | DSIs |
| new signed records, nothing deleted | nanopublications |
| copies checked by digest | nanopub registries, Underlay, LOCKSS |
| append-only signed logs | Underlay, after CT |
| dated digests | bloxberg, Ledger, OpenTimestamps |
| overlays over versions held elsewhere | PCI, Episciences, eLife |
| packaging with digests | BagIt, OCFL, RO-Crate |
| static files or a git host only | DSGL, BagIt, OCFL, ResearchEquals' static archive |
| a work name shared by several owners | not found |
| owner key logs with pre-rotation | KERI, not for documents |
| collections pinning others' versions | not found |
| rules for takedown in a federation | not found |
| all of the above as static files | not found |

## Evaluation and limitations {#sec:eval}

Earlier designs ended for lack of funding or of a steward, for lack of
adoption, or by depending on a token, a chain or a service run by someone
else; others were overtaken by other services [@fedpub]. OpenSheaf avoids
the third cause and shares the others; we weigh it against them.

#### Adoption
An exchange layer is worth something only when several parties use it, and
OpenSheaf has one real archive. The most successful decentralised design
found, nanopublications, counts some 80,000 records by some 600 signers
after more than fifteen years [@fedpub]. What is needed next is a service
people use on top: an announcement service for a field, or an overlay
journal on authors' own archives [@positioning].

#### Incentives
Researchers publish where evaluation counts: eLife's submissions fell by more
than half after its indexing changed [@fedpub]. An OpenSheaf archive counts
for nothing by itself, and reaches the indexes only through DOIs, landing
pages for search engines, and overlays that do count. DOIs with an archive's
own prefix are open (#8).

#### Key management
OpenSheaf asks more of authors than the comparable designs surveyed
(dokieli, DSGL, nanopublications) [@fedpub]: a current key on
each device and rotation keys kept apart, for a better answer to theft. The
Manager and passkeys lower the cost; whether authors will bear it is
untested, and a per-owner key log may not be worth it to authors who never
meet a theft. Weighted thresholds for groups (#69) and witnesses of which
key-log version was seen first (#70) are left for after 0.2.

#### Discovery and scale
Without indexes of many archives, a line whose archives have gone is hard to
find, however checkable its copies; who keeps them is open (#20), as are a
gateway run by the project (#35) and registering `sheaf` with IANA (#36).
Feeds exist, but nothing aggregates them yet. Paged discovery documents and
partial verification address large archives (#19); an aggregation of
arXiv's size remains untried.

#### Funding and rights
The tools, the Explorer and any gateway need maintainers; an archive needs
only a static web server, and stays readable with any OCFL tool and the
specification if every OpenSheaf tool stops. Copies need rights, and in the
first archive few lines can be copied without the authors' agreement.

#### Open questions
As of 22 November 2026 every open issue of the specification is marked as an
addition after 0.2 or as a task. Besides those above, they include: external
records that resolve pins (#22); reviews, comments and relations between
documents (#21); statements by collections about their members (#40); owner
proofs beyond the keeper (#41); custodians' copies (#39) and policies (#54);
blind review (#63); owner catalogues bound to their archive (#76); and
bundles of a collection with its members (#74).

## Conclusion {#sec:conclusion}

We have argued that the functions of scholarly communication stay bundled
in part because nothing lets separate parties rely on one another's work.
OpenSheaf proposes a common form for that: documents fixed by digests and named apart from their hosts and
keys, owners who sign their lines and can answer a theft, and catalogues and
selections that are themselves fixed and checkable. On it, recording can stay
with authors, preservation can be shared by institutions, and announcing,
filtering and evaluation can be built by anyone, without asking the
archives. Most of the parts exist elsewhere; their combination was not
found. Version 0.2 is a draft, with tools, a formal model and a first archive; whether it
is adopted depends on the services built on it.

## References

- [roosendaal1997] H. E. Roosendaal and P. A. Th. M. Geurts. Forces and functions in scientific communication: an analysis of their interplay. 1997.
- [vandesompel2004] H. Van de Sompel, S. Payette, J. Erickson, C. Lagoze and S. Warner. Rethinking scholarly communication: building the system that scholars deserve. D-Lib Magazine 10 (9), 2004. https://dlib.org/dlib/september04/vandesompel/09vandesompel.html
- [smith1999] J. W. T. Smith. The deconstructed journal: a new model for academic publishing. Learned Publishing 12 (2), 1999.
- [priem2012] J. Priem and B. M. Hemminger. Decoupling the scholarly journal. Frontiers in Computational Neuroscience 6, 2012.
- [pubfair2019] T. Ross-Hellauer, B. Fecher, K. Shearer and E. Rodrigues. Pubfair: a distributed framework for open publishing services, version 2. COAR, 2019.
- [spec02] M. Gubinelli (editor). OpenSheaf: an open format for document archives and collections, version 0.2 (draft), 22 November 2026. OpenSheaf, 2026. https://opensheaf.org/opensheaf-specification-0.2
- [git02] OpenSheaf project. OpenSheaf archives in git, version 0.2 (draft), 22 November 2026. Companion to the OpenSheaf specification 0.2, 2026. https://opensheaf.org/opensheaf-git-0.2
- [timestamps02] OpenSheaf project. OpenSheaf timestamps, version 0.2 (draft), 21 November 2026. Extension to the OpenSheaf specification 0.2, 2026. https://opensheaf.org/opensheaf-timestamps-0.2
- [tools] OpenSheaf project. opensheaf-py, a literate program, and The command-line tools, its guide. 2026. https://github.com/opensheaf/opensheaf-py and https://opensheaf.org/tools
- [explorer] OpenSheaf project. The OpenSheaf Explorer. Literate program, 2026. https://opensheaf.org/explorer/ (source: https://github.com/opensheaf/explorer)
- [manager] OpenSheaf project. The OpenSheaf Manager. 2026. https://manager.opensheaf.org/ (source: https://github.com/opensheaf/manager)
- [template] OpenSheaf project. archive-template, a template for an OpenSheaf archive. 2026. https://github.com/opensheaf/archive-template
- [lean] OpenSheaf project. OpenSheaf in Lean. Literate program, 2026. https://opensheaf.org/opensheaf-lean/ (source: https://github.com/opensheaf/opensheaf-lean)
- [papers] M. Gubinelli. Papers of Massimiliano Gubinelli, an OpenSheaf archive. 2026. https://mgubi.org/papers/ (repository: https://github.com/mgubi/papers)
- [positioning] OpenSheaf project. OpenSheaf as an exchange layer for scholarly communication. Working paper, 2026. https://github.com/opensheaf/opensheaf.github.io/blob/main/drafts/positioning.md
- [fedpub] OpenSheaf project. Federated publishing: proposals and systems compared with OpenSheaf. Working paper, 2026. https://github.com/opensheaf/opensheaf.github.io/blob/main/drafts/federated-publishing.md
- [arxivwp] OpenSheaf project. arXiv and OpenSheaf. Working paper, 2026. https://github.com/opensheaf/opensheaf.github.io/blob/main/drafts/arxiv.md
- [hexagonwp] OpenSheaf project. Hexagon and OpenSheaf. Working paper, 2026. https://github.com/opensheaf/opensheaf.github.io/blob/main/drafts/hexagon.md
- [alphaxivwp] OpenSheaf project. alphaXiv and OpenSheaf. Working paper, 2026. https://github.com/opensheaf/opensheaf.github.io/blob/main/drafts/alphaxiv.md
- [radiclewp] OpenSheaf project. Radicle and OpenSheaf. Working paper, 2026. https://github.com/opensheaf/opensheaf.github.io/blob/main/drafts/radicle.md
- [keysforks] OpenSheaf project. Keys, revocation and forks: what went wrong on the way. Working paper, 2026. https://github.com/opensheaf/opensheaf.github.io/blob/main/drafts/keys-and-forks.md
- [fedidentity] OpenSheaf project. Federated and decentralized identity, and the key logs of OpenSheaf. Working paper, 2026. https://github.com/opensheaf/opensheaf.github.io/blob/main/drafts/federated-identity.md
- [ocfl] OCFL. Oxford Common File Layout specification, version 1.1. https://ocfl.io/1.1/spec/
- [datacite] DataCite. DataCite Metadata Schema 4.7. https://schema.datacite.org/meta/kernel-4.7/
- [keri2019] S. M. Smith. Key Event Receipt Infrastructure (KERI). White paper, 2019. https://arxiv.org/abs/1907.02143
- [groth2010] P. Groth, A. Gibson and J. Velterop. The anatomy of a nanopublication. Information Services and Use 30 (1-2), 51-56, 2010. doi:10.3233/ISU-2010-0613
- [kuhn2014] T. Kuhn and M. Dumontier. Trusty URIs: verifiable, immutable, and permanent digital artifacts for linked data. ESWC 2014, LNCS 8465, 395-410, 2014. doi:10.1007/978-3-319-07443-6_27
- [kuhn2016] T. Kuhn and others. Decentralized provenance-aware publishing with nanopublications. PeerJ Computer Science 2, e78, 2016. doi:10.7717/peerj-cs.78
- [kuhn2026] T. Kuhn, V. Balseiro, A. Caselli, Z. Plutschow, P. Sowinski and A. Danilenka. A robust decentralized infrastructure for trust-aware open knowledge sharing. ISWC 2026, LNCS, 152-170, 2026. doi:10.1007/978-3-032-42015-2_8
- [ellerman2024b] E. C. Ellerman. Document Succession Git Layout, edition 1.1. 2024. https://castedo.github.io/dsgl-spec/
- [kf2026a] Knowledge Futures. Underlay, revived. 2026. https://www.knowledgefutures.org/updates/2026-04-27-underlay-revived
- [kf2026c] Knowledge Futures. Underlay moves to protocol v2. 2026. https://www.knowledgefutures.org/updates/2026-10-06-underlay-protocol-v2
- [kf2025b] Knowledge Futures. Not enough: open infrastructure funding and the future of Knowledge Futures. 2025. https://www.knowledgefutures.org/updates/2025-06-update/
- [kf2026f] Knowledge Futures. A path forward for PubPub. 2026. https://www.knowledgefutures.org/updates/2026-01-update
- [dicosmo2018] R. Di Cosmo, M. Gruenpeter and S. Zacchiroli. Identifiers for digital objects: the case of software source code preservation. iPRES 2018, 2018. doi:10.17605/OSF.IO/KDE56
- [rocrate2022] S. Soiland-Reyes and others. Packaging research artefacts with RO-Crate. Data Science 5 (2), 97-138, 2022. doi:10.3233/DS-210053
- [descinodes] DeSci Labs. DeSci Nodes and Codex. 2026. https://github.com/desci-labs/nodes
- [ceramic2025] Ceramic. The future of Ceramic. 2025. https://blog.ceramic.network/the-future-of-ceramic-focusing-on-recall/
- [hartgerink2019] C. H. J. Hartgerink. Verified, shared, modular, and provenance based research communication with the Dat protocol. Publications 7 (2), 40, 2019. doi:10.3390/publications7020040
- [ledger] Ledger. About the journal. https://ledger.pitt.edu/ojs/ledger/about
- [wittek2020] K. Wittek, D. Krakau, N. Wittek, J. Lawton and N. Pohlmann. Integrating bloxberg's proof of existence service with MATLAB. Frontiers in Blockchain 3, 2020. doi:10.3389/fbloc.2020.546264
- [capadisli2017] S. Capadisli, A. Guy, R. Verborgh, C. Lange, S. Auer and T. Berners-Lee. Decentralised authoring, annotations and notifications for a read-write web with dokieli. ICWE 2017, LNCS, 469-481, 2017. doi:10.1007/978-3-319-60131-1_33
- [capadisli2020] S. Capadisli. Linked Research on the Decentralised Web. Doctoral thesis, University of Bonn, 2020. https://csarven.ca/linked-research-decentralised-web
- [solid] W3C Solid Community Group. Solid Protocol, version 0.11.0. 2024. https://solidproject.org/TR/protocol
- [hochstenbach2023] P. Hochstenbach, R. Verborgh and H. Van de Sompel. Using event notifications, Solid and orchestration for decentralizing and decoupling scholarly communication. Code4Lib Journal 58, 2023. https://journal.code4lib.org/articles/17823
- [pep740] Python Software Foundation. PEP 740 and PyPI digital attestations. 2024. https://docs.pypi.org/attestations/
- [oric2pa] US Office of Research Integrity. Content provenance. https://ori.hhs.gov/content-provenance
- [elife] eLife. eLife's new model: your questions answered. https://elifesciences.org/inside-elife/2b765a27/elife-s-new-model-your-questions-answered
- [mcdowell2021] G. S. McDowell, J. K. Polka, T. Ross-Hellauer and G. Stein. The DocMaps framework for representing assertions on research products in an extensible, machine-readable, and discoverable format. bioRxiv, 2021. doi:10.1101/2021.07.13.452204
- [pci] Peer Community In. Frequently asked questions. https://peercommunityin.org/faq/
- [episciences] Episciences. Publishing model. https://www.episciences.org/publishing-model/
- [maniatis2003] P. Maniatis, D. S. H. Rosenthal, M. Roussopoulos, M. Baker, T. J. Giuli and Y. Muliadi. Preserving peer replicas by rate-limited sampled voting. SOSP 2003, 44-59, 2003. doi:10.1145/945445.945451
- [lockss] LOCKSS and CLOCKSS. https://www.lockss.org and https://clockss.org
- [coarnotify] COAR. COAR Notify, version 1.0.1. https://coar-notify.net
- [oaipmh] Open Archives Initiative. The Protocol for Metadata Harvesting (OAI-PMH). https://www.openarchives.org/pmh/
- [activitypub] W3C. ActivityPub. W3C Recommendation, 2018. https://www.w3.org/TR/activitypub/
- [atproto] Bluesky. AT Protocol. https://atproto.com
- [nostr] Nostr. Nostr Implementation Possibilities (NIPs). https://github.com/nostr-protocol/nips
- [ipfs] IPFS. https://ipfs.tech
- [kademlia2002] P. Maymounkov and D. Mazieres. Kademlia: a peer-to-peer information system based on the XOR metric. IPTPS, 2002.
- [radicle] Radicle. Radicle protocol guide. https://radicle.xyz/guides/protocol
- [tuf] The Update Framework. https://theupdateframework.io/
- [antieau2026] B. Antieau. Hexagon. 2026. https://antieau.github.io/2026/10/05/hexagon.html

