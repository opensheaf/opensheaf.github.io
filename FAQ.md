# OpenSheaf: frequently asked questions

*Answers to questions that come up about the design of
[OpenSheaf](https://opensheaf.org). The specification
([opensheaf-specification-0.1.md](opensheaf-specification-0.1.md)) is
authoritative; this page explains its choices.*

## What is OpenSheaf for?

It is an open format for archives of scholarly documents and for collections
of them: a lean alternative to arXiv and to the usual publication
infrastructure. Anyone can keep an archive of their documents as plain files
on a static website, with sources, versions fixed by hashes, standard
metadata, and collections that combine documents from several archives.

## Why not just use arXiv, or Zenodo?

Both are excellent services, and OpenSheaf works with them: a document can
also be on arXiv (linked with `IsIdenticalTo`), and the Zenodo binding gives
every version a DOI on Zenodo. What OpenSheaf adds is an archive that its
owner keeps and controls, that stores sources (not only PDFs) in a
documented layout, that anyone can verify file by file, and that can be
combined with other archives into collections and selections without asking
any central service.

## Do I need Zenodo, TeXmacs, git or GitHub?

No. The core of the format is an OCFL storage root and a discovery document
served over HTTPS. Zenodo, TeXmacs and the website are optional profiles
(appendices A, B and C). Git and GitHub Pages are convenient ways to keep and
serve an archive, but any static web server will do.

## Can an archive be served straight from GitHub, without GitHub Pages?

For tools, yes; for readers, no. The raw file server of a public GitHub
repository (`https://raw.githubusercontent.com/<owner>/<repository>/main/`)
serves every file byte for byte and allows cross-origin requests, so the
Explorer, and other tools that read archives over HTTP, can read and verify an
archive from it. It does not serve a website: it sends pages as plain text and
PDFs as downloads, so landing pages are neither shown nor read by search
engines, and it serves the pointers of Git LFS, not the files. It is best
listed as a second location in `mirrors` of the discovery document, next to a
GitHub Pages site or another web server. See section 7.4 of [OpenSheaf
archives in git](opensheaf-git-0.1.md).

## Why OCFL? Isn't git enough?

Git records history, but its layout is internal to git and its hashes (SHA-1
in most repositories) are not meant for long-term preservation. OCFL (the
Oxford Common File Layout) is a published specification for exactly this
problem: versioned objects stored as plain files, every file fixed by a
SHA-512 digest, readable without any special software, with independent
validators, used by research libraries. An OpenSheaf archive can still be
kept in git; git just is not part of its integrity.

## Why DataCite metadata, and not RO-Crate, Dublin Core or JATS?

DataCite is the metadata behind DOIs for repositories (Zenodo, arXiv's DOIs,
university repositories). It has the relations needed here (versions,
preprints and published articles, collections), it maps directly to Zenodo,
and its records are harvested by ORCID, OpenAlex and search services.
RO-Crate is richer but heavier; Dublin Core is too thin; JATS is for the
full text of journal articles.

## Why JSON and not YAML?

The metadata files are written by tools and checked by machines. JSON is
strict, has one way of writing each value, and is read everywhere without
extra libraries. YAML is nicer to edit by hand but converts values silently
(dates, version numbers like `1.10`, identifiers like `2611.14296`).

## Why is there a discovery document (opensheaf.json)?

Static web servers cannot list folders, so a program visiting an archive
could not find its objects. `opensheaf.json`, at the archive's address, lists
them with their head versions and digests, names the storage root and the
main collection, and says which version of the specification the archive
follows. It is only a map: everything it says is checked against the storage
root.

## Why are identifiers short names and not URIs?

On `main` they are: the flat-direct storage layout puts each object in a
folder named by its identifier, so paths stay readable and can be computed
over plain HTTP; a folder name cannot contain `/`. The archive itself has a
URI-like identifier (a `tag:` URI), and an object is named globally by the
pair (archive identifier, object identifier).

The identity proposal (sections 6.3, 6.5 and 6.6, not yet agreed) changes
this. A work gets a name independent of any archive, the digest of its
genesis record, and each history of it an owner; the identifier of an object
is its line, written as a `sheaf:` URI, `sheaf:<name>:<owner>`. Identifiers
chosen by each archive clash as soon as one archive keeps copies of another's
objects; identifiers made from lines never do, so one storage root can hold
the lines its owners write and copies of others' side by side. The default
layout puts a line at `<owner>/<name>/`, one folder per owner; a large
archive may instead spread its objects over folders named by parts of the
hash of their identifiers. Archives have no identifiers of their own: they
are found at their addresses. Readable names (`kpz-details`) become
**labels** in the discovery document, used for the website's URLs; they are
not permanent, and permanent links use `sheaf:` URIs, for instance
`sheaf:<name>/v3`.

## What is the difference between a document version and an object version?

The document version is the version of the work, what readers see and what
gets a DOI: it changes only when the document's own files change (sources,
renditions, change note). The object version (`v1`, `v2`, ...) is OCFL's: it
changes at every change of the object, including corrections of the
description (adding the DOI of the journal version, fixing an affiliation)
and notices about earlier versions.

## How are versions numbered and ordered?

The archive numbers document versions itself, from 1 and without gaps, even
when an external service numbers them differently: if arXiv still serves only
v1, v3 and v4 of a paper, they are document versions 1, 2 and 3, and the
arXiv labels are recorded beside them. Versions are normally in the order of
their numbers. When an earlier version turns up later, it gets the next
number and an explicit `history` in `object.json` puts it in its place; the
current version, the one readers are directed to, is the last in the
history. Dates are only information: they may be approximate or unknown, so
they never decide the order.

## What if a version turns out to be wrong?

Deposit a corrected version, with a change note saying what changed. To warn
readers of the earlier version, add a notice about it (for instance an
erratum, as text or as a file): notices are later statements about a version,
kept with the object and shown with that version, and they never change the
version itself.

## How do collections work across archives? What if another archive disappears?

A collection lists its members by line (name and owner, under the identity
proposal), an address where a copy was found, version and the SHA-512 digest
of that version's inventory (the "pin"). Since an inventory fixes all its
files, the pin fixes the member completely, and a collection becomes a hash
tree over everything it contains. If the member's archive moves or
disappears, the member can be fetched from a mirror, from its DOI deposit or
from a Software Heritage snapshot: any copy that matches the pin is the right
one. A collection also keeps a cached citation of each member, so that it
stays readable even if no copy is found.

## Why both archives and collections?

They answer different questions. An **archive** is custody: a storage root
and a discovery document, served at an address. It says what is kept there
and where its files are. Under the identity proposal, an archive hosts the
lines of any number of owners and owns none of them by hosting them: every
version of a line is signed by its owner, wherever it is stored, and an
archive cannot add to another owner's line. A copy kept elsewhere (a mirror)
stays its owner's line and can only receive the owner's versions. (On
`main`, the archive is the single writer of its objects, named by an archive
identifier; see "Who owns an object, and what is a branch?")

A **collection** is a statement: a versioned list of pins, made by a curator,
over objects kept anywhere. It says which objects, in which versions, go
together: an author's papers, an issue of a journal, a reading list.
Collections are objects themselves, so they can be pinned, nested and
included in other collections, across archives.

The two are kept apart because an archive changes at every deposit and holds
facts that are nobody's claim (which objects it holds, their heads, mirrors,
tombstones), while a collection changes by the rules its curator set (adding
members, following them as they grow, vetting their versions), and each of
its versions can be cited and verified as it stood. When an archive's
documents should be cited as they stood, that is what its main collection is
for: a catalogue of them, pinned like any other. Archives hold copies, each
line possibly in several; collections overlay them, any number of views over
any holdings.

## What is the difference between a catalogue and a selection?

Keeping and vetting are different acts, and OpenSheaf has a kind of collection
for each. A **catalogue** keeps objects whole and is impartial about their
versions: each member pins an object with all its versions, and the collection
may follow it as its owner adds versions. An author's archive, an
institution's repository and a storage site list what they keep in catalogues.
A **selection** vets particular revisions: a journal its accepted version, a
digest or a review journal the version it read. Each member pins the revision
set that was vetted; later versions by the authors are not part of it, and any
change of what is vetted (a correction accepted by the editors) is an explicit
act of the curator, recorded as a new version of the selection. The [use
cases](USE-CASES.md) show both at work.

## Can I put someone else's paper in my collection?

Yes. A reference (a pin) copies nothing and needs no permission. There are
two ways to keep a copy, both allowed only if the licence of what is copied
permits redistribution (or the authors agree): a **mirror** copies the whole
line, every version, and stays its owner's line (for an institution or a
storage site); an **accepted copy** takes the one revision a selection vetted
into a line of the selection's owner, where later changes are the curator's
acts (for a journal). The licence of a collection (CC0 for the list) never
extends to its members.

## Who owns an object, and what is a branch?

> [!NOTE]
> This answer describes a proposal (sections 6.5 and 10.5 of the
> specification, on the branches `proposal/identity` and `proposal/owners`;
> issues #55 and #52), not yet agreed.

A work has a <dfn>name</dfn>, the digest of the genesis record written when
it is sealed, at its owner's request, before it is first shared. Each history
of it has an <dfn>owner</dfn>: a person, a group or an institution, which
decides its versions and signs them. The pair (name, owner) identifies a
<dfn>line</dfn>: one history, with a single writer. A line is its signed
versions, wherever they are stored: the archive that keeps a copy is only
where it lives, and an owner who moves to another archive continues its
lines there.

An owner is itself an object, named by its own genesis record, whose
versions are its <dfn>key log</dfn>: the list of its public keys and the
number of them that must sign, each version signed by the keys of the one
before. Keys can thus be added, replaced or revoked while the owner stays the
same; a group of co-authors can share one owner with a threshold, for
instance two signatures out of three. Every version of every line is signed,
and the key logs travel with the objects they sign, so a line can be checked
from any copy, even when the archives that served it have gone. An owner may
name who answers for it (an ORCID iD, an institution), which the keeper
confirms in a place only it controls; nothing requires it. A draft has no
owner and no genesis record: that absence is what marks it as a draft.

Anyone can copy a genesis record, so the name alone cannot say whose history
is the right one. That is why the owner is part of the identity: a copy
continued by another owner is a <dfn>branch</dfn>, which declares the version
it starts from, and an archive cannot pass its own changes off as another
owner's, since it cannot sign for it. A branch is a new object: it keeps
only the version it starts from, with the parent's inventory, `object.json`,
signatures and the part of the parent owner's key log they need as evidence,
and adds its own versions (a journal keeping the version it vetted, then its
corrections; a co-author carrying the work on). It cannot continue the
parent's object, whose inventories record the parent's identifier. A
co-author who wants the whole past at hand keeps a copy of the parent's line
beside the branch, as a separate object; in git the files they share are
stored once. An accepted copy is a branch kept by a selection's owner.

A branch can be checked without its parent: the genesis record gives the
name, the copied inventory gives the parent pin, the files match that
inventory, the copied `object.json` says whose version it was, and the parent
owner's signature, checked against the copied part of its key log, shows that
the version is that owner's.

## Can documents be linked in richer ways (a short account and its full proof)?

Yes, on top of the format rather than in it. The core keeps only what every
archive needs to keep, cite, compose and verify documents. Other relations
are built from it: by links inside the documents and DataCite relations,
which need nothing more, or by **extensions** (section 4 of the
specification), published separately, whose data an object version records in
its `object.json`, so that tools that know them can follow the relation when
they copy, verify or present documents. Extensions never change the core: an
archive is read and verified without them. The [use cases](USE-CASES.md)
show a journal publishing a short account of a proof whose detailed argument,
possibly written with AI, stays online in the version reviewed.

## Where do signatures and timestamps go, and why not in the version itself?

A signature or timestamp of an object version can only be made after the
version is committed, so it cannot be part of that version: a signature of an
inventory cannot be listed in the inventory it signs. Making a new version
for each signature would mix evidence with changes of the work, and every
upgrade of a timestamp proof (OpenTimestamps proofs are completed once their
attestation is confirmed) would be another version.

OCFL does not allow arbitrary files in an object folder; its `logs/` folder
is meant for unstructured records of actions and is not covered by digests.
The place OCFL provides for data that is not part of any version is the
object's `extensions/` folder (the registered mutable-head extension keeps its
data there). So OpenSheaf puts witnesses in
`extensions/opensheaf-witnesses/`, where they travel with the object. An
archive that never touches object folders after commit may keep them in a
`witnesses/` folder outside the storage root instead. Witnesses need no
digests of their own: each one is checked directly against the checksum file
it names, which the pins fix.

## Why is the HTML version not part of the deposit?

Because presentations improve (stylesheets, exporters, fixes) and deposits
must not change. The deposit keeps the sources and the PDF; the HTML is
regenerated from the sources whenever the presentation changes.

## How do I withdraw or take down a document?

To withdraw a document (for instance a retraction), make a new version with a
withdrawal notice: the content and its history stay, and presentations show
the notice. If content must be removed (by law, or for a breach of rights),
the object is deleted and a tombstone is left in the discovery document, so
that collections pinning it report it as removed rather than corrupt. OCFL
version 2 is expected to add a native mechanism for deleting single files;
OpenSheaf will adopt it when it is published.

## Can I use "All rights reserved"?

Yes. Each document carries the licence its authors choose; "All rights
reserved" means readers may access the document but not reuse it. The metadata
(descriptions, object records, member lists, inventories) is CC0, so that it
can be harvested and mirrored freely. On Zenodo, "All rights reserved" is
entered as a custom licence.

## Will Google Scholar find the papers?

If the archive follows the website profile: each document then has a landing
page with the `citation_*` meta tags Google Scholar reads, and a PDF on the
same host. Appendix C also recommends a sitemap and FAIR Signposting links.

## How do I check an archive?

A verifier validates the JSON files against the schemas in
[schemas/](schemas/), validates the storage root with a standard OCFL
validator (such as `ocfl-py`), checks that the discovery document matches the
storage root, and resolves and checks every member of every collection. The
specification (section 14) lists the checks.

## Is the format stable?

Not yet: version 0.1 is a draft, and versions before 1.0 may change in
incompatible ways. Every file declares the version of the format it follows,
so that tools can tell. From version 1.0, minor versions will be backward
compatible.

## Why the name?

A sheaf is a bundle of papers. In mathematics, a sheaf is the structure in
which local pieces glue into a whole: archives kept and verified separately
compose into collections.
