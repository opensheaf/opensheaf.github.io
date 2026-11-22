# OpenSheaf as an exchange layer for scholarly communication

*Working paper, draft of 15 November 2026, revised for version 0.2 of the
specification on 22 November 2026. Non-normative: ideas and positions, not
decisions. Scholarly communication bundles several functions: recording,
preserving, announcing, filtering, distributing and assigning merit.
Preprint servers and publishers each hold a bundle of them, and the function
that authors cannot do without tends to bring the others with it. The case
for separating them is not new. This paper argues that what has been missing
is a common form in which the separated parties exchange what they handle:
documents fixed by digests, named independently of where they are kept, and
statements about them (collections) that are themselves fixed and
verifiable. OpenSheaf is meant to be that form, an exchange layer: archives
kept by anyone below it, announcement, filtering, evaluation and
preservation built by anyone above it, and federations of archives and
services joined through it. The paper compares it with the infrastructure of
scholarly communication and with federated and distributed systems, weighs
what separating the functions costs, and makes proposals. A companion
paper, [federated-publishing.md](federated-publishing.md), surveys earlier
proposals of federated publishing: most of OpenSheaf's parts exist
elsewhere, and what is new is their combination.*

> [!NOTE]
> Revised for [version 0.2](../opensheaf-specification-0.2.md) of the
> specification, as of 22 November 2026: section numbers of the specification
> are those of 0.2. Where this paper and the specification differ, the
> specification holds. A section number with a decimal point (6.6), or
> marked as the specification's, is a section of the specification; a whole
> number alone is a section of this paper.

## 1. The functions

A classic analysis of scientific communication (Roosendaal and Geurts,
1997) distinguishes registration, awareness, certification and archiving;
Van de Sompel and others (2004) add rewarding. We use a slightly
different division, closer to what the actors of today do:

- <dfn>Record</dfn>. Fix the work, every version of it, unchanged; give
  it a stable name, so that it can be cited; state when each version
  appeared, which supports claims of priority.
- <dfn>Preserve</dfn>. Keep what was recorded available for a long time,
  through the end of servers, domains, institutions and careers.
- <dfn>Announce</dfn>. Tell the community that something new exists. For
  many mathematicians, the daily listings of arXiv are the main source of
  scientific news: one reads the new submissions in one's subjects every
  morning, as one would read a newspaper. Mailing lists, seminars and,
  more and more, social networks play the same part.
- <dfn>Filter</dfn>. Select, out of everything announced, what deserves
  attention, and vouch for it: refereeing, editorial choice, reviews,
  reading lists. Journals are filters and aggregators: by gathering papers
  under a name and a standard, they focus the attention of a community on
  a manageable set of works.
- <dfn>Distribute</dfn>. Deliver the files to readers, in usable forms,
  and make them findable: hosting, mirrors, indexes, search, formats.
  Announcing reaches readers when something appears; distributing serves
  them when they look for it.
- <dfn>Assign merit</dfn>. Turn the record into credit for its authors:
  where a paper was published, who reviewed it and what they said, who
  cites it. Hiring, promotion and funding rely on these signals, mostly on
  the name of the journal.

The functions are distinct. Recording needs fixity; preserving needs
institutions that last; announcing needs speed; filtering needs judgement
and a community that trusts it; distributing needs bandwidth and formats;
assigning merit needs evidence that others can check. They have different
costs, different time scales and different people doing them.

That they should be separated has been argued for a long time: the
"deconstructed journal" (Smith, 1999), the distributed system of
scholarly communication of Van de Sompel and others (2004), the
"decoupled journal" (Priem and Hemminger, 2012), and the repository
community's Pubfair (section 4). Decentralised publishing has been
proposed and built many times since, on peer-to-peer networks,
blockchains, linked data and signed records
([federated-publishing.md](federated-publishing.md)). What this paper adds
is a view of what the separated parties need in common, and a format for
it (section 3).

## 2. How the functions are bundled today

The actors of scholarly communication each carry a bundle of functions:

| Actor | Record and preserve | Announce | Filter | Distribute | Merit |
|---|---|---|---|---|---|
| arXiv | yes, with dated submissions | yes, the daily listings | endorsement and moderation, not review | yes | little |
| Hexagon | yes, with the provenance of each version | yes, listings by month and feeds by subject | screening only | yes | none, on purpose |
| alphaXiv | arXiv's for most papers, its own for direct submissions | yes, feeds and trending papers | screening, ranking by attention | yes, also to AI agents | attention (views, follows) |
| A journal and its publisher | the version of record | weak (tables of contents, alerts) | yes, refereeing | yes, often behind a paywall | yes, the main signal |
| An overlay journal (Discrete Analysis, the journals of Episciences) | relies on arXiv, HAL or Zenodo | weak | yes | relies on the same | yes |
| SciPost | relies on preprint servers, keeps its published version | weak | yes, refereeing with published reports | yes, open access | yes |
| Peer Community In | relies on preprint servers | weak | yes, recommendations | relies on preprint servers | some |
| An institutional repository | yes | no | no | yes | reporting to the institution |
| Zenodo | yes, with DOIs | no | no | yes | citations through DOIs |
| zbMATH Open, Mathematical Reviews | no | partly | reviews | indexes | yes |
| Google Scholar | no | alerts | ranking | search | citation counts |

Three things follow from the table.

**Bundling gives control.** A publisher that holds the filter, which
authors need for merit, also obtains the record and the distribution: the
transfer of copyright, or the exclusive licence, that often comes with
acceptance moves the version of record behind its platform. The function
that authors cannot do without carries the others with it.

**The unbundled actors already exist.** Overlay journals, Peer Community
In and SciPost show that filtering can live apart from recording and
distribution: they vet documents that stay where their authors put them.
Their weak point is that they rest on archives they do not control and
which do not know about them. A selection of arXiv papers can name the
version it vetted (`arXiv:...v2`), but only arXiv vouches for the bytes
behind that name, and the selection itself is a web page, not a record
that others can check or build on. None of the overlays surveyed in
[federated-publishing.md](federated-publishing.md) (Peer Community In,
Episciences, eLife) publishes a digest of the version it vetted; some keep
their own copy, which no one else can check.

**Each function is concentrated.** The arXiv listings are the
announcement channel of whole disciplines, and journals are the merit
system; arXiv is one organisation, and much of journal publishing is in
the hands of a few publishers. There is no common form in which an
announcement, a selection or a review could be made by someone else, over
the same documents, and checked by anyone.

Three working papers compare OpenSheaf with some of these actors in
detail: [arxiv.md](arxiv.md), [hexagon.md](hexagon.md) and
[alphaxiv.md](alphaxiv.md).

**SciPost** (<https://scipost.org>) deserves a word, as the most complete of
the unbundled filters. It is a not-for-profit foundation in Amsterdam
(Stichting SciPost), founded by J.-S. Caux and run largely by working
scientists, with eighteen journals in physics, astronomy, chemistry and a
few other fields. Its referees' reports are published, anonymous by default;
submissions come preferably through a preprint server; the accepted paper is
typeset by SciPost and published with its own DOI under CC BY 4.0, and
preserved through CLOCKSS. Neither authors nor readers pay: SciPost's
business model estimates its cost at about 500 euros a paper on average (its
accounts give more in recent years), and asks the organisations that benefit
for sponsorship, weighing each paper among its authors' institutions (its
"PubFracs"). Its software is open source and its finances public. Section 3
takes it as the worked example of a filter.

## 3. OpenSheaf as an exchange layer

### What the layer is

Separated functions are carried by separate parties: an author's archive,
a journal, an announcement service, an institution that preserves, a
committee that evaluates. What they need in common is a way to exchange
what they handle, so that each can rely on what the others did without
asking them: the documents, fixed and named, and the statements made
about them. OpenSheaf defines that, and nothing else. We call it an
<dfn>exchange layer</dfn>.

It is not a transport: HTTP, git or any copy moves the bytes. It is not
only a record either, since what it records is meant to be exchanged and
built on, across parties that do not share a platform, and joined into
federations. Its place is that of the narrow waist of the Internet: one
common form, with any host below it (a static web server, a forge, a
repository, a preservation network) and any service above it (an
announcement service, a journal, an index, an evaluation), so that each
side can change without the other.

The layer defines:

- how a version of a document is **fixed**: object versions in OCFL, every
  file covered by a SHA-512 inventory, nothing ever changed once
  deposited, and every version signed by the owner of its line;
- how it is **named**: the line `sheaf:<name>:<owner>`, where the name is
  a digest of the work's genesis record and the owner a keyed identity
  whose key log checks itself, and the document version, independent of
  where the files are served (sections 5 to 7 of the specification);
- how it is **found**: the discovery document of an archive, its indexes
  and its feed of new object versions, and `sheaf:` URIs with their hints
  (specification, section 12);
- how copies are **checked**: any copy, from anywhere, is valid when its
  bytes match the pin and its versions carry the owner's signatures, so
  that copies can be kept by others;
- how statements about documents are **expressed**: collections, which
  are themselves signed, versioned objects pinning their members by
  digest, across archives; catalogues that keep objects whole, and
  selections that vet particular revisions.

It defines the *forms* of statements, not the *acts*: a selection is the
form in which a filter states what it vetted, but who filters, by what
standard, is not the layer's business; likewise for announcing, preserving
and assigning merit. These are services built on the layer: anyone can run
them, several can work over the same documents, and each of their
statements is an object that can be cited and verified as it stood.

What is new is not any one part. Names from digests (Trusty URIs,
SWHIDs), versions signed by their authors (Document Succession
Identifiers, nanopublications), copies checked by digest (LOCKSS, the
Underlay) and overlays that vet versions held elsewhere all exist (section
5; [federated-publishing.md](federated-publishing.md)). What was not found
elsewhere is their combination as a common form: a name of the work shared
by the lines of several owners, apart from hosts and keys; owners whose key
logs let them change keys and answer a theft; and statements pinned by
digest and signed, across archives that can be kept by the authors
themselves as static files, so that a filter, an index or a preservation
network can be built by someone who controls none of the archives it works
on.

### Record

This is what the layer carries most directly. An archive is a host, plain
files on any static web server, in a layout used by research libraries for
long-term preservation (OCFL); the lines it holds belong to their owners,
not to the archive, and an owner moves to another archive by copying its
folder (sections 3 and 6.5 of the specification). Every version of every
document is fixed, with its sources (or a statement that they are
missing); corrections, notices and withdrawals are new versions, and the
history can be checked from the files alone. The inventory of each version
states who deposited it and when; these are statements of the archive,
not proofs. Each version is signed by the owner of its line, which shows
that the owner's keys signed it, but "not who wrote the document ..., who
the owner is ..., when it was signed, or that no later version exists"
(section 15.1). Dates come from witnesses, such as the timestamps of the
[timestamps extension](../opensheaf-timestamps-0.2.md); who an owner is,
from its keeper (an ORCID iD or a domain, section 6.6).

### Preserve

The layer does not keep anything: it makes copies checkable, so that others
can keep them. Mirrors keep byte-for-byte copies of whole lines, with the
key logs their signatures need, so that a copy can be checked without the
archive it came from (sections 6.5 and 11.1); a pin says which copy is
right. External deposits (Zenodo) and software archives (Software Heritage)
keep further copies, but a Zenodo record holds the content files without the
inventory, so it is a witness, not a copy, and resolves no pin (section
12.3); whether it could, by uploading the inventory, is open (issue #22).

Preservation is then a service built on the layer, like the others:
<dfn>federated archiving</dfn>. Institutions (libraries, universities,
learned societies) run networks of archives, peer to peer, that keep
copies of what the leaves hold: the personal and group archives at the
edge of the network, which come and go. A federation is a consortium of
peers that trust one another, academic institutions or communities with
other means of establishing a minimum of real-world trust; joining it is a
social act, as in LOCKSS, not an open protocol. When a leaf disappears (a
domain lapses, an author dies, a hosting service closes), its objects can
still be resolved from the copies the network holds, and the pins in
every collection still say which copies are right. Custody is shared
between the owner, who alone signs the versions of its lines, and the
federation, which keeps them alive.

The format already has most of the parts. A mirror is a byte-for-byte copy
of a line, grown only by adding the owner's signed versions (section 11.1);
an archive's list of the lines it holds as copies is a catalogue. Since, in
the default layout, an object's path is `<owner>/<name>/` (section 3.2),
lines of different owners never clash, and one node can hold the lines of
any number of leaves in one storage root. Resolution (section 12.3) tries
the `at` of a `sheaf:` URI or of a collection member, a branch's parent URL,
the indexes it knows and its user's configuration; a custodian may keep
indexes of many archives at an address of its own (section 12.5).

Two questions are settled. An archive that keeps a mirror is responsible
for having the right to redistribute it, by the licences of the versions,
by the agreement of the rights holders, or by law; the format does not
judge it, and tools may warn when they know no licence that allows it
(section 11.2, issue #34). A rule that would have allowed mirrors only of
lines under one standard licence was considered and not adopted. And a
tombstone speaks for its archive only: copies elsewhere do not follow a
takedown by themselves, each archive answering for what it serves, and
resolution goes on to them (section 13.3, issues #33 and #66). A
federation that must remove content removes it at each node; an owner who
wants every copy to show that a work is no longer valid withdraws it, a
signed version that copies follow. What remains open:

- **Finding the network when the leaf is gone.** The leaf's discovery
  document and indexes disappear with it, and a member's `at` gives only the
  locations its curator recorded, often the leaf alone. A federation needs
  its own way to be asked: indexes kept for many archives, found by a
  registry, a well-known address per network, or a distributed hash table
  (section 5). Who keeps such indexes, and how resolvers find them, is open
  (issue #20).
- **Copies short of the whole line.** Licences belong to versions, but a
  mirror copies a line up to its latest signed version. Whether a custodian
  may stop at a pinned version, keeping exactly what it pins or what it has
  the right to redistribute, and how copying by agreement is recorded, is
  open (issue #39); so is what a custodian promises to keep (issue #54).
  What may not be served can still be kept as a dark copy, under an
  agreement with the owner, released only after a trigger such as the leaf
  being gone for good, as CLOCKSS does for journals: an agreement of the
  federation, not a state of the format.

Federated archiving keeps the rest of the design as it is: the leaves stay
static files, owners stay the single writers of their lines, and any copy,
from any node, is checked by the same pins and signatures. It is LOCKSS for
documents that are named and versioned at the edge. The same network can
also resolve, not only keep; what that requires is a proposal of its own
(section 7).

### Announce

The specification provides the raw material: each archive MAY publish a
feed of its new object versions, and a catalogue that follows its members
records, version by version, what was added. An announcement service is
then an aggregator of feeds: it reads the feeds of many archives, groups
the new document versions by subject (from the DataCite `subjects` of each
version, for instance the Mathematics Subject Classification), and
publishes daily listings, as arXiv does. Such a listing can itself be a
catalogue, and so a citable record of what was announced on a given day.

None of this needs a central archive. It needs feeds, a common way to
state subjects, a way to find the feeds, and someone to run the
aggregator, which can be run by several communities, each with its own
subjects and its own moderation. For scale, an archive with many objects
lists them in pages, and its feed holds the recent versions, linking
earlier ones as archived feeds (sections 3.1 and A.3, issue #19); an
aggregation of arXiv's size remains to be tried. Following and discussion
belong to the social networks, which the layer can feed but does not try
to be (section 5).

### Filter

Selections are the form of a filter's statements. An overlay journal, a
digest, a reading list, a review journal or a seminar's programme is a
selection: each member pins the revision that was vetted, later versions
by the authors are not part of it, and any change of what is vetted is an
act of the curator, recorded as a new version of the selection. A
selection that wants to keep the files it vetted keeps an accepted copy, a
branch of the authors' line owned by the selection's owner; a journal that
typesets and publishes its own version makes it a later version of that
accepted copy, with the authors' agreement and relations to their versions
(section 9.6). The [use cases](../USE-CASES.md) describe these in detail,
including peer review from a private submission to a published record;
blind review, with anonymous referees or authors, is open (issue #63).

Because a selection pins by digest, it says exactly which bytes were
vetted, and anyone can check that they have not changed. Because
collections are objects, they nest: "Both types may have collections as
members (an archive of archives, a selection of issues)" (section 8.1 of
the specification), so a journal's issues can form a selection, and the
overlay journals of a field a catalogue. Several filters can work on the
same documents without copying them, and without the authors' archives
knowing about them: a document never states the collections that include
it. Who includes or reviews a document is learnt the other way, by
notifications sent to its archive (section 4).

**SciPost as a worked example.** SciPost (section 2) is already close to
what a selection describes, and shows what the layer would add:

- **A journal as a selection.** Each issue would pin the revision
  accepted, by digest, instead of naming a preprint identifier, so that
  the record of what was published is verifiable from the files. The
  earlier versions that were refereed but not accepted are not vetted,
  and are not members of the selection; the reviews pin them.
- **Reports as documents.** Published reports, replies and comments are
  review documents (`PeerReview`), each pinning the version it reviews,
  kept, versioned and cited like the papers; anonymous reports are part
  of the open question of blind review (issue #63).
- **Its own version as a version of its accepted copy.** SciPost's
  typeset paper is a later version of the journal's accepted copy of the
  authors' line, with SciPost as publisher (section 9.6).
- **A licence that allows copying.** A licence such as CC BY 4.0 gives any
  custodian the right to redistribute that section 11.2 asks of a mirror:
  such papers can be kept by any federation.

The words collide here: SciPost Selections is the name of one of its
journals, still in development, which publishes extended abstracts of
papers that its editorial colleges single out from its flagship journals;
in OpenSheaf terms it is a selection over SciPost's own journals, but the
name is SciPost's own.

### Distribute

Archives are static websites: any web server distributes them, and any
mirror can stand in. The website profile gives every line of an owner
catalogue a landing page that search engines read (Google Scholar); the
Zenodo profile gives it a DOI; `sheaf:` URIs name lines and pinned versions
wherever they are kept, and a gateway can turn them into web links
(specification, section 12, issue #35); the OpenSheaf Explorer reads and
verifies any archive in the browser. Distribution is the function that needs
least from the layer, which only asks that files be served byte for byte and
readable from other sites. Search across archives is not part of the format;
like announcement, it is a service that needs aggregation.

### Assign merit

The layer does not count anything. It makes the evidence on which merit is
assigned explicit and checkable: which selections vetted which revision, and
when (the versions of each selection); what the referees said, when reviews
are published as documents of their own; how documents relate, through
DataCite relations; which owner signed what, as the signatures show, and
when, as timestamps can prove (Record, above). A record of this kind is
checked from the files, instead of being taken on the word of a platform.

Two cautions. First, the reverse question (which selections include a given
document?) cannot be answered from the document: it needs notifications sent
to its archive (section 4) or an index over many archives, which is again a
service. Crossref's Event Data, which recorded where DOIs were mentioned,
was such an index for DOIs; its public API was sunset on 23 April 2026, its
historical data kept. Second, making evidence easy to collect makes it easy
to count; a format should not invent metrics, and this one does not.

### What the layer leaves out

On purpose:

- search and ranking;
- the identity of persons: an owner is a keyed identity that names no one,
  tied to a person only by its keeper (an ORCID iD or a domain), by keys it
  shares with another owner, and by what its versions say; authors are named
  in `creators`, with their ORCID iDs (sections 6.6 and 15.5);
- moderation of announcement channels;
- payment;
- the hosting itself.

Each of these is a service that can be run on the layer by someone who
takes responsibility for it.

## 4. The infrastructure of scholarly communication

The layer has to live with what exists: repositories, harvesting,
notification protocols, preservation networks and DOIs.

### Institutional repositories

Most universities and research institutes run a repository: a website
where their researchers' papers, theses, reports and data are deposited
and published, usually in open access. It is built with one of a few
platforms: DSpace (begun in 2002 by MIT Libraries and Hewlett-Packard, the
most widely used), EPrints (begun in 2000 at the University of
Southampton), Invenio (from CERN, on which Zenodo runs), Fedora (with its
front ends Islandora and Samvera), and Dataverse for data. Some national
repositories, such as HAL in France, run their own software. Deposit is
often required by funders and institutions, which is how much of open
access ("green" open access) comes about.

**What they do.** A repository records, preserves and distributes: it
keeps what is deposited, under the institution's preservation policy;
gives each item a stable page and identifier (a Handle, sometimes a DOI);
exposes its metadata to aggregators; manages access, embargoes and
licences; and reports to the institution, which counts what its
researchers produce. It does little announcing and no filtering: it holds
what its members deposit, often the accepted manuscript of a paper
published elsewhere. Deposits can come in from other systems through
SWORD, a protocol for depositing into repositories.

**How they differ from an OpenSheaf archive.**

- **Software and operation.** A repository is a server application, with a
  database, a running web application, and staff to keep it. An OpenSheaf
  archive is static files on any web server.
- **Who controls it.** A repository belongs to its institution, which
  decides what is accepted and how it is shown; a researcher who moves
  leaves their deposits behind. An OpenSheaf archive decides only which
  owners it hosts; the lines belong to their owners, who sign them, and
  an owner who moves copies its folder to another archive, the same lines
  continuing there (section 6.5).
- **Versions, sources and fixity.** Repositories hold files and metadata
  per item, with versions as far as the platform allows, and checksums for
  preservation inside the platform; sources are rarely kept, and the
  deposit is often a single version. OpenSheaf keeps every version of a
  document, with its sources, each fixed by an inventory that anyone can
  check from outside. Fedora 6 already keeps its objects in OCFL, the
  layout OpenSheaf uses, which shows how close the two can come.
- **Collections.** A repository's collections group its own items (by
  department, by type). OpenSheaf's collections are objects that pin their
  members by digest, across archives, and can be cited and verified as
  they stood.
- **Description.** Repositories describe items in their own schemas,
  often derived from Dublin Core, and map them for harvesting; OpenSheaf
  uses DataCite throughout.

**How they relate.** Repositories are not what OpenSheaf replaces but what
it needs: the institutions that keep things for the long term.

- **Custodians and preservation nodes.** A university that runs a
  repository can host its researchers as owners, mirror their lines kept
  elsewhere, or keep them as a node of a federation (section 3), with the
  same staff and policies.
- **Two ways in.** A repository can ingest OpenSheaf objects, through
  SWORD or a dedicated import, or publish what it holds as an OpenSheaf
  archive, generated from its records, so that its items can be pinned by
  selections elsewhere.
- **Reporting.** An author's OpenSheaf archive can be the source from which
  the institution's records are filled, rather than a second place to
  deposit.

### OAI-PMH and harvesting

Repositories already form a network: they expose their metadata through
OAI-PMH, and aggregators (BASE, CORE, OpenAIRE) harvest it. The discovery
document and the feed of an OpenSheaf archive play the same part, with
three additions: the content is fixed and verifiable, not only the
metadata; versions are explicit; and collections across archives are part
of the format, not a feature of an aggregator. An archive's website may
also publish an OAI-PMH static repository (appendix A.3), so that existing
harvesters read it as they read a repository; its metadata are under CC0
(section 15.6).

### Notification protocols and COAR Notify

A family of web protocols carries messages between the parties. Their use
falls on the services built on the layer rather than on the archives: a
static archive can be read, but cannot receive anything.

- **Announcing.** WebSub (W3C, 2018) lets a hub push the updates of a feed
  to its subscribers, so that aggregators learn of new versions without
  polling. An archive could name a hub in its Atom feed, and whatever builds
  the archive would tell the hub at each update; the archive itself stays
  static. A bridge to ActivityPub would let an archive or an announcement
  service be followed (section 5).
- **Notifications between parties.** Linked Data Notifications (W3C, 2017)
  define an inbox, declared by a resource, to which others post
  notifications about it; Webmention does the same, more simply, for links
  between web pages. They answer the reverse question that a document cannot
  answer about itself (which selections include it, who reviewed it) without
  breaking the rule that a document never states the collections that
  include it: the selection sends a notification to the document's archive,
  and the notifications are kept outside the objects. (They are not the
  notices of the specification, which an owner adds to its own versions,
  section 4.2.)
- **COAR Notify.** The Confederation of Open Access Repositories' protocol,
  COAR Notify (version 1.0.1), builds on Linked Data Notifications and the
  ActivityStreams 2.0 vocabulary to connect repositories with the services
  that review and endorse what they hold.
  - Its patterns include requests (*Request Review*, *Request Endorsement*),
    acknowledgements (accept, reject), and announcements (*Announce Review*,
    *Announce Endorsement*, *Announce Relationship*). A repository offers a
    preprint to a review service, and the service announces the review back,
    naming the reviewed resource in the notice's `context`.
  - Repository platforms (DSpace, EPrints, Dataverse), repositories (HAL),
    preprint servers (bioRxiv, Preprints.org, SciELO Preprints), and review
    and overlay services (Peer Community In, Episciences, PREreview, Sciety)
    implement it, as listed on the protocol's site.

  It is the separation of section 2, already at work between filters and
  archives, and the protocol to follow rather than to reinvent.

What OpenSheaf can add is integrity. A COAR Notify notice identifies
resources by URI (a landing page, a DOI as `cite-as`), with no digest and
no signature: it says that a review exists of "the resource at this page",
not of which bytes. With OpenSheaf, the object of a notice can be a pin
(the reviewed revision, and the version of the selection that includes
it), so that whoever receives the notice can check it against the files,
and the notice stops being only a claim. This needs a way for an archive
to name its inbox, which can be run elsewhere since the archive itself is
static, and a convention for writing pins in notices; both belong to an
extension, not to the core (section 7).

### Pubfair: COAR's repository model

The repository community has made the same argument for separating the
functions. COAR's Next Generation Repositories (2017) set out a vision of
repositories as a distributed network with services built on top, and the
white paper *Pubfair* (Ross-Hellauer, Fecher, Shearer and Rodrigues, 2019)
made it a framework for open publishing: a modular, open-source publishing
layer over a distributed network of repositories, which hold the research
outputs while separate services review, curate and disseminate them. Pubfair
itself is a conceptual model, not software; COAR Notify, launched in 2021,
implements part of it, with working cases such as the review of HAL's
preprints by Episciences journals. A related model, from the preprint-review
movement and adopted by eLife and Sciety, is now often called "publish,
review, curate".

OpenSheaf agrees with this model and differs in what it assumes about the
archives:

- **Who keeps them.** Pubfair's archives are institutional repositories.
  OpenSheaf's can be kept by authors and groups themselves, as static
  files, with institutions as custodians and preservation nodes.
- **What is kept.** A repository holds deposits and their metadata, with
  versions as the platform allows. An OpenSheaf archive holds every
  version of a document, with its sources, fixed by digests.
- **What statements fix.** In Pubfair, a review or an endorsement refers to
  a resource by its address or DOI. In OpenSheaf, a selection pins the
  bytes it vetted, across archives, and is itself a versioned object.

The two fit together: an OpenSheaf archive can be a repository in COAR's
network, with an inbox run beside it, and COAR Notify can carry, with
pins, the notices between OpenSheaf archives and the services that review
and select. The repository community is where institutions and review
services already are, and joining its protocols is a likely way for
OpenSheaf to be adopted rather than to compete.

### LOCKSS and CLOCKSS

LOCKSS (Lots Of Copies Keep Stuff Safe) is a network of libraries that
keep copies of the same content and compare them to repair damage;
CLOCKSS, built on it, keeps dark copies of journals, released only when a
publisher stops providing them. It is the model for federated archiving
(section 3). Pins make one part of it simpler: any node's copy can be
checked against the pin on its own, without the nodes comparing their
copies with one another.

### DOI registries

Crossref and DataCite register DOIs: persistent names, resolved through
the Handle system to wherever the publisher or repository says the work
is, with metadata deposited by their members. They are central
registries, run by membership organisations, and they are what everyone
already cites. A DOI says where a work is and what it is called; it does
not fix the bytes, since it resolves to a landing page that may change.
OpenSheaf uses DataCite's metadata as its description, and a document may
receive a DOI (the Zenodo profile, and the open question of an archive's
own prefix, issue #8); the pin then says which bytes the DOI's work is.

## 5. Federated and distributed systems

Outside scholarly communication, many systems replace a central service
by a network of independent parties. The comparison shows what OpenSheaf
borrows, what it does differently, and what it might reuse.

### Mastodon and ActivityPub

Mastodon is a federation of servers speaking ActivityPub, a W3C
Recommendation (2018). Each user has an account on one server; servers
push activities (posts, replies, boosts) to the servers of the followers;
each server moderates its own users and chooses which servers it talks
to.

- **Similar.** No central service; anyone can run a node; communities set
  their own rules, as selections and announcement services would.
- **Different.** ActivityPub delivers by push and needs a running server
  for every node; an OpenSheaf archive is static files, read by pull. A
  post can be edited or deleted and its author's identity is bound to the
  server's domain; an OpenSheaf version never changes, its integrity is
  checked by digest and signature, and its line is named by digests, not
  by where it is served.
- **To reuse.** ActivityPub is a good announcement channel, which the
  layer does not try to be. A bridge that turns an archive's feed into
  ActivityPub posts would let researchers follow archives, or announcement
  services, from the networks they already read; replies and discussion
  stay there, and what deserves to be kept can become a document of its
  own.

### Bluesky and the AT Protocol

The AT Protocol separates roles that Mastodon keeps together: each user's
data is a signed repository of records, hosted by a server the user can
leave; relays crawl the repositories and produce a stream of everything;
application views and custom feeds build what readers see from that
stream. Identity is a decentralised identifier (DID), portable across
hosts.

- **Similar.** Of all these systems, this is the closest in architecture. A
  user's repository is an archive; a relay is an aggregator of feeds; a
  custom feed is a filter, built by anyone over the same data. The
  separation of keeping, relaying and presenting is the separation of
  record, announce and filter of section 1.
- **Different.** An AT repository is a mutable set of small records, signed
  as a whole at each change; an OpenSheaf archive holds large documents in
  append-only versions, each fixed by its own inventory. Both design in
  portable identity. Its main method there, `did:plc`, depends on a
  directory developed by Bluesky, for which an independent steward, the PLC
  Organization, a Swiss association, was founded in 2026; an OpenSheaf owner
  is instead a key log that checks itself from its name, with rotation keys
  committed in advance, and needs no directory (specification, section 6).
  The price is that a fork of a key log ends the owner, since nothing can
  tell which side is the owner's; the working paper
  [federated-identity.md](federated-identity.md) compares the two designs,
  and [keys-and-forks.md](keys-and-forks.md) the problems of forks.
- **To reuse.** The role of the relay, and the idea that feeds are built by
  third parties over a shared stream, describe the announcement and index
  services that the layer needs.

### Nostr

Nostr reduces federation to signed events and simple relays that store
and forward them; the client holds the user's key and chooses the relays.
Identity is the key itself. It shows how little a relay needs to know, and
how much robustness comes from signing at the source. OpenSheaf signs at
the source too, but its identities are owners, not keys: an owner's key
log lets it add, retire and expose keys under the same owner name, which
a Nostr key cannot; archives have no identity at all.

### IPFS and content addressing

IPFS names content by its hash and fetches it from whoever has it. Pins in
OpenSheaf rest on the same idea, that the right copy is the one whose
digest matches, wherever it comes from. Two differences matter. A content
address fixes one file or tree; an OpenSheaf pin fixes an object version
and, through its inventory, all the versions before it, together with a
name and a history. And content addressing alone does not keep anything
available: someone must hold the bytes. The words collide once more: to
*pin* in IPFS means to keep content available on a node, while a pin in
OpenSheaf is a reference fixed by a digest, and keeps nothing.

### Distributed hash tables

A distributed hash table (DHT), such as Kademlia in BitTorrent and IPFS,
is a lookup service run by peers: given a key, usually a hash, the network
routes the query to the nodes that hold the value or know who does. It
answers a question that OpenSheaf does not ask. A pin carries no address:
it says whether a copy is right, not where to find one. OpenSheaf finds
documents from a name and a location (the `at` of a URI or of a
collection member, an archive's discovery document and indexes), and uses
the digest only to check what it found. A DHT supplies the missing
"where".

The two also differ in custody. In a DHT, data stays reachable while some
peer chooses to serve it, and records expire unless they are published
again; in OpenSheaf an archive keeps its objects, and mirrors are kept by
named parties. A DHT needs nodes that are always online; an archive needs
only a static web server. Mutable data in a DHT are records signed with a
key (IPNS in IPFS, BEP 44 in BitTorrent); in OpenSheaf the mutable map is
the discovery document, served by the archive itself. A DHT has weak
points of its own: routing can be attacked by many fake nodes (Sybil and
eclipse attacks), which hashes do not prevent, and queries tell the
network what its users read. Its possible use, as an optional resolver,
is a proposal (section 7).

### Git, forges and Software Heritage

Git is the most widely used distributed system for versioned work: every
clone is complete, commits are linked by hashes, and forges add
collaboration on top. Many archives will be kept in git, and Software
Heritage archives public repositories with intrinsic identifiers. But git
hashes are SHA-1 in most repositories and its layout is internal to git;
OpenSheaf uses git as a convenient store and transport, and keeps its
integrity in OCFL inventories. How to keep an archive in git without git
changing a byte is set out in [OpenSheaf archives in
git](../opensheaf-git-0.2.md); whether git's own structures could carry the
format is the subject of a sibling working paper,
[git-as-implementation.md](git-as-implementation.md). A Software Heritage
snapshot of an archive is a further witness. Radicle, a peer-to-peer network
for git repositories, is compared in [radicle.md](radicle.md), and Matrix,
as a channel beside archives, in [matrix.md](matrix.md).

### Earlier proposals of decentralised publishing

Scholarly publishing has its own decentralised designs, surveyed in
[federated-publishing.md](federated-publishing.md). Three are close to
OpenSheaf in parts:

- **Nanopublications** (since 2010): small signed RDF statements, named by
  Trusty URIs (digests of their content), replicated between registries
  that check digest and signature and give each key a quota derived from
  endorsements. A Trusty URI names one content, so a work has no name
  across its versions, and the documented queries count a supersession
  only under the same key.
  They are the natural form for statements about OpenSheaf versions
  (section 7).
- **Document Succession Identifiers** (Ellerman, 2024): a document's
  editions kept as one git history, signed with keys listed in the
  document, and named by the initial commit. It shares OpenSheaf's
  premises, with one succession per name and no owners or collections.
- **The Underlay** (Knowledge Futures, revived in 2026): collections of
  content-addressed records, with immutable sequential versions, signed
  log entries and mirrors; each collection has one authoritative server.

The others (decentralised science on IPFS and blockchains, Dat and
Hypercore, linked data on personal servers) show mostly what to avoid:
every platform found that made a chain or token the basis of publishing,
except DeSci Nodes, has closed or dropped the chain, and a design with one
indispensable party, a registry or a server, is as fragile as that party.

### Summary

| System | Unit | Changes | Delivery | Needs running software | Integrity | Identity |
|---|---|---|---|---|---|---|
| ActivityPub (Mastodon) | post | editable, deletable | push | yes, every node | the server's | account at a domain |
| AT Protocol (Bluesky) | record in a repository | mutable, signed | relays | yes (host, relay) | signed repository | DID, portable |
| Nostr | signed event | fixed, some kinds replaceable | relays | relays | signature | key |
| IPFS | file or tree | new address per change | peer to peer | a node | content address | the hash |
| DHT (Kademlia) | key and value | records expire unless republished | routed lookup | online peers | the key, when it is a hash | the key |
| Git | commit | append, history rewritable | clone, pull | no | SHA-1 or SHA-256 chain | none of its own |
| Institutional repository | item | updated in place, versions as allowed | web, harvest | yes | checksums inside the platform | Handle or DOI |
| OAI-PMH | metadata record | updated in place | harvest | yes, usually | none | repository identifiers |
| DOI registries | registered work | metadata updated, target may move | resolution | yes (registry, resolver) | none | DOI |
| Nanopublications | signed RDF statement | fixed; superseded or retracted by new records | replicating registries | yes (registries) | Trusty URI, signature | a key, declared with an ORCID iD |
| Document Succession Identifiers | edition in a git history | append, signed | git host | no, a git host | git hashes, signatures | initial commit; keys listed in the document |
| Underlay | collection version | immutable, sequential | server and mirrors | yes (an authoritative server) | SHA-256 content addresses, signed log | collection at its server |
| OpenSheaf | object version | append-only, signed | pull, static files | no, a static web server | SHA-512 inventories, pins, owners' signatures | line: name of the work and owner, both digests |

What sets OpenSheaf apart is the combination, not any one row: append-only
versions of large documents, fixed by digests and signed by their owners;
names of works independent of where they are served and of any one key,
checked from any copy; static files that need no running software; and
statements (collections) that are themselves versioned, signed, pinned
objects. What it lacks, compared with the
social systems, is everything about attention: pushing news to readers,
following, replying. That is deliberate, and it is where bridges to those
systems would help.

## 6. What separating the functions costs

Separating the functions is not free. Each bundle today also answers
questions that a layer of documents leaves open.

### Who pays

Each function has its own costs: storage and bandwidth for recording and
distribution, institutions for preservation, editors' and referees' time
for filtering, running aggregators for announcement and indexes. Today
they are paid together, by subscriptions, publication charges,
institutions and grants, and cross-subsidised within each bundle. The
layer makes the cheapest part very cheap: an archive is static files,
which a university, a free hosting service or a git forge can serve at
little or no cost. The other functions still need people and money. A
separate function can be funded separately (a society runs a journal as a
selection, a library runs an announcement service for its field), but
whether it will be is a question of institutions, not of format.
SciPost's model, in which the organisations that benefit are asked to
sponsor it in proportion to their share of its papers, is one working
answer for filtering. A risk to name: services that are free today
(forges, hosting) may change their terms, which is one more reason for
mirrors. Shared infrastructure has ended before when its funders or
stewards left (Coko, reportedly; PubPub nearly; ResearchEquals asks for
EUR 100k a year beyond 2027): OpenSheaf shares that risk for its tools,
not for its archives, which stay valid and readable with any OCFL tool and
the specification if every OpenSheaf tool stops
([federated-publishing.md](federated-publishing.md), section 10).

### Adoption and incentives

The value of an exchange layer appears only when several parties use it,
and OpenSheaf has one real archive. Earlier designs show how slow this is:
nanopublications, the most successful decentralised design found, count
some 80,000 records by some 600 signers after more than fifteen years.
Researchers publish where evaluation counts, and a system outside the
indexes is outside the incentives; OpenSheaf reaches them only through
DOIs (appendix A.1, issue #8), landing pages for search engines (appendix
A.3) and overlays that do count. And it asks more of authors than any
comparable design: current keys on each device and rotation keys kept apart
(section 6.2), for a better answer to theft. Whether authors will bear it
is untested.

### Abuse and noise

A central service can refuse a submission; an open network cannot stop
anyone from publishing an archive. Spam, plagiarism, generated papers and
fake archives created to inflate one another's records will appear as soon
as there is something to gain. The layer offers some defences: every version
is fixed and signed, and with timestamps dated, so that copying can be shown
and priority argued; selections and moderated catalogues are acts of owners
who sign them and, when they name a keeper, are tied to someone who answers
for them. Works written with or by language models raise the same question
at a larger scale; how Hexagon records their provenance, and how a version
could, is discussed in [hexagon.md](hexagon.md). But filtering abuse is a
function of its own, and falls to announcement services and selections,
which must moderate, as arXiv's moderators and journals' editors do now.
Evidence for merit drawn from an open network is only as good as the
curators it counts.

### Rights, licences and takedowns

Distribution depends on rights. A reference (a pin) needs no permission, but
an archive that keeps a mirror or an accepted copy redistributes its files,
and answers for having the right to, by a licence, the agreement of the
rights holders, or law; the format does not judge it (sections 9.7 and
11.2). The `agreement` of a version records only that the authors agreed to
a deposit and its licence; how copying by agreement is recorded is open
(issue #39). Documents under restrictive licences, such as arXiv's default
licence, can be pinned by anyone and recorded in their authors' own
archives, but copied only where that right exists ([arxiv.md](arxiv.md)).
Takedowns are harder in a network than in one place: when a document must be
removed for legal reasons, its archive deletes it and leaves a tombstone,
which speaks for that archive only; mirrors and external copies answer for
what they serve, and content that must not be served anywhere is taken down
at each archive that serves it (section 13.3).

### Anonymity and review

Merit rests in part on peer review, and peer review usually rests on
anonymity: referees are not named to authors, and submissions are not public
before acceptance. A network of public archives fits public records better
than confidential ones. The specification allows private archives: an
archive need not be public, serves all its lines or none, and publishes a
line by copying it into a public archive, with the same inventories and
signatures, so that pins made in private stay valid (section 3.1); drafts
are never shared as objects (specification, section 10). Anonymous referees,
anonymous authors, and opening the record later are still open (issue #63);
until they are settled, a journal can keep its review process where it is
today and publish its decisions as selections.

## 7. Proposals and open questions

These are proposals, not plans; each would need an issue and agreement
before anything enters the specification.

### Resolution through a federation

The preservation network of section 3 can resolve as well as keep. Nodes
contact one another for the objects they exchange, and can exchange
resolution information with them: which archives they know, where those
archives are now, which nodes hold which objects up to which version. A
reader, or a verifier, can then ask any node for an object whose archive
is unreachable, and the network answers with copies that the pins check.

Integrity is not the difficulty: a pin checks every byte, whichever node
supplied it. The difficulty is everything a pin does not fix: where things
are, what is current, what was removed, and whether a key log is complete.
Content is self-certifying; state is not. Among trusted peers, false nodes
are not a concern, but these remain:

- **Freshness.** Whatever follows the latest version, and whoever asks for
  the current version, depends on the last discovery document a node has
  seen. A node with an old one hides newer versions, notices and
  withdrawals, and a withdrawal that never arrives looks like none. A newer
  inventory lists all earlier versions, so going back is visible once a
  newer one has been seen. A copy that does not match its pin is reported
  with its location, and the pin is a mismatch only if no copy found
  matches (section 12.3).
- **Removals do not spread.** A withdrawal is a signed version, which
  copies follow once they see it, and a node that missed it shows the line
  as active. A tombstone is not signed and speaks for its archive only
  (section 13.3): a federation that must remove content removes it at
  each node, by agreement among its members.
- **Authority after the leaf.** The owner, not the archive, is the single
  writer of its lines, and signs every version, so an owner that starts
  again elsewhere continues the same lines, and an impostor can sign
  nothing in its name. What remains is the owner's key log: a copy that
  stops early looks complete, so a node holding an old one may miss that
  the owner has ended or exposed keys (sections 6.5 and 15.1); nodes that
  record which version of a key log they saw first would help (issue #70).
- **Answers depend on the node.** Nodes keep different subsets, so
  "unavailable" may mean only "unknown to this node", and two verifiers may
  report the same collection differently, unless a report says where it was
  made, or the federation guarantees what each node holds.
- **Privacy.** Resolution queries tell nodes what is being read, and
  exchanging holdings tells the federation what each member keeps.
- **Browsers.** The Explorer and readers speak HTTP, not a peer-to-peer
  protocol, so HTTP gateways would become new central points, unless they
  are untrusted: they return records and pins that the client checks.
- **The protocol stays outside the core.** The nodes run software and
  speak a protocol, with its own specification and versions; the format
  must not come to depend on it.

Trust between institutions is not trust in their servers: a compromised
or misconfigured node of a trusted member still spreads stale or wrong
state. The answer of version 0.2 is that state be stated by the owner:
versions, withdrawals and key changes are signed, and names are digests
that any copy checks, so that a node can withhold but not forge (section
15.1). What a federation protocol still has to provide is freshness and
reach: indexes of many archives and a way to find them (issue #20).

### Owners and ORCID

This paper first proposed that authors publish their keys on their ORCID
records. Version 0.2 took a related path: keys belong to owners, whose key
logs check themselves, and an owner MAY name a keeper, an ORCID iD or a
domain, fixed with its owner name, which MAY confirm the link by naming the
owner in its ORCID record or in a file on its domain (section 6.6). The
link says who answers for an owner, not who owns its lines, which only its
keys decide, nor who wrote its documents.

- **The binding now, not then.** A confirmation is read as it is now: a
  keeper who withdraws it ends the link, and a record that is later taken
  over gives its new holder the keeper's powers (section 15.1). A
  timestamped snapshot of the confirmation would date it.
- **Self-asserted.** The link proves only what the holder of the ORCID
  account published.
- **ORCID's signed tokens as a complement.** ORCID's signed login tokens
  can carry the digest of an inventory, and so witness that the holder of
  an iD approved a deposit at a given time, without any key for the author
  to manage; they rest on ORCID's keys, which must be kept to check them
  later. Such proofs, with attesters and DNS records, are open (issue
  #41).

### Other proposals

- **Announcement services and bridges** (section 3). Daily listings by
  subject, built from feeds, run by communities, each a catalogue of what
  it announced; feeds bridged to ActivityPub or the AT Protocol. Needs a
  common way to state subjects (DataCite `subjects` with a scheme, such as
  MSC2020), a way to find feeds (a registry, or a catalogue of archives),
  and a trial at scale.
- **Moderated subject catalogues.** A community curates the catalogue of
  its subject, admitting documents, or whole owners through their owner
  catalogues, as arXiv moderators admit submissions: moderation becomes
  an act of a curator, recorded in the versions of the catalogue.
- **Overlay journals on authors' own archives** (section 3). Selections
  over authors' archives, with accepted copies when the journal wants to
  keep the version it published, and review records as documents;
  statements by a journal about its members (volume, acceptance, its DOI,
  retraction) are open (issue #40).
- **Notifications with pins** (section 4). Selections and reviewers notify the
  archives of the documents they include or review, with COAR Notify,
  giving the pin of what they vetted; archives name an inbox, run
  elsewhere if they are static, through an extension. This builds the
  reverse index from the edge; references and applications in general are
  discussed in issue #21.
- **Resolvers and gateways.** `sheaf:` URIs and names checked from the
  content are in the specification (its sections 5 and 12). Still open: a
  gateway run by the project, and on which domain (issue #35); the
  registration of the scheme with IANA (issue #36); indexes of many
  archives and how resolvers find them, for which a DHT could serve as an
  optional resolver, from inventory digests and owner names to archives
  holding copies (section 5, issue #20); and external records that resolve
  pins (issue #22).
- **Custody** (section 3). Copies up to a pin and copying by agreement
  (issue #39), custody policies (issue #54), the Internet Archive as a
  mirror (issue #43), and bundles that carry a collection with its members
  in one file (issue #74).
- **Neighbours.** Write to the authors of Document Succession
  Identifiers, of the nanopublication network and of the Underlay, to test
  OpenSheaf's choices against theirs and find where records could pass
  between them; publish statements about pinned versions (reviews,
  endorsements, errata) as nanopublications, as one answer to issue #21;
  export the history of a selection as docmaps, which Sciety and Europe PMC
  read; and suggest to overlays that they record, at each decision, the
  digests of the version they vetted
  ([federated-publishing.md](federated-publishing.md), section 11).
- **If the project stops.** State on the site that archives remain valid,
  readable and checkable with any OCFL tool and the specification if every
  OpenSheaf tool and service ends: the answer to the commonest failure of
  earlier projects.
- **Adoption.** OpenSheaf works alongside existing services: a document
  can be on arXiv (`IsIdenticalTo`), have a DOI, and be found by Google
  Scholar; `osheaf arxiv import` brings an author's arXiv papers into an
  archive, and the papers on arXiv, Hexagon and alphaXiv propose how each
  service could meet the layer. The first step for an author costs little
  and changes nothing else.

### Open questions

- Which service should be demonstrated first: announcement (an aggregator
  of feeds) or filtering (an overlay journal on authors' archives)?
- How much of attention (following, notifications, discussion) should be
  left entirely to other networks, and how much should be bridged?
- Should preservation federations be specified at all, or only made
  possible by the layer, as LOCKSS was by the web?
- Is a per-owner key log worth its cost, against keys listed in each
  document as in Document Succession Identifiers, for authors who will
  never meet a theft?
- Should statements about versions join an existing network (the
  nanopublication registries) rather than have forms of their own?

## 8. Conclusion

The functions of scholarly communication are bundled because nothing lets
separate parties rely on one another's work: a filter must trust the
archive it points to, an index must trust the platforms it reads, an
institution must take custody to be sure of what it keeps. OpenSheaf
proposes the missing common form: documents fixed by digests and named
independently of their hosts, and statements about them, catalogues and
selections, that are themselves fixed and checkable. On that exchange
layer, recording can stay with authors, preservation can be shared by
federations of institutions, and announcing, filtering and evaluation can
be built by anyone, over the same documents, without asking the archives.
None of its parts is new by itself; earlier designs have each of them, and
ended for want of funders, stewards or users more often than for any flaw
of design. OpenSheaf needs nothing but static files, which removes one
cause, and shares the others.

What exists today is the format (specification 0.2, a draft), the tools that
keep, sign and verify archives, a Manager and an Explorer that work with
them in the browser, and a first archive. What is needed next is a service
on top that people use: an announcement service for a field, or an overlay
journal on authors' own archives, speaking the protocols of the repository
community.

## References

- Roosendaal, H. E. and Geurts, P. A. Th. M., *Forces and functions in
  scientific communication: an analysis of their interplay*, 1997.
- Smith, J. W. T., *The deconstructed journal: a new model for academic
  publishing*, Learned Publishing 12 (2), 1999.
- Van de Sompel, H., Payette, S., Erickson, J., Lagoze, C. and Warner, S.,
  *Rethinking scholarly communication: building the system that scholars
  deserve*, D-Lib Magazine 10 (9), September 2004:
  <https://dlib.org/dlib/september04/vandesompel/09vandesompel.html>.
- Priem, J. and Hemminger, B. M., *Decoupling the scholarly journal*,
  Frontiers in Computational Neuroscience 6, 2012.
- Ross-Hellauer, T., Fecher, B., Shearer, K. and Rodrigues, E.,
  *Pubfair: a distributed framework for open publishing services*,
  version 2, COAR, 27 November 2019 (first version, September 2019:
  *Pubfair: a framework for sustainable, distributed, open science
  publishing services*).
- COAR, *Next Generation Repositories*, 2017.
- arXiv: <https://arxiv.org>.
- Discrete Analysis, an arXiv overlay journal:
  <https://discreteanalysisjournal.com>.
- Episciences, a platform of overlay journals:
  <https://www.episciences.org>.
- Peer Community In: <https://peercommunityin.org>.
- SciPost: <https://scipost.org>.
- COAR Notify, version 1.0.1: <https://coar-notify.net>.
- Linked Data Notifications, W3C Recommendation, 2017:
  <https://www.w3.org/TR/ldn/>.
- Webmention, W3C Recommendation, 2017:
  <https://www.w3.org/TR/webmention/>.
- WebSub, W3C Recommendation, 2018: <https://www.w3.org/TR/websub/>.
- ActivityPub, W3C Recommendation, 2018:
  <https://www.w3.org/TR/activitypub/>.
- AT Protocol: <https://atproto.com>.
- Nostr: <https://github.com/nostr-protocol/nips>.
- IPFS: <https://ipfs.tech>.
- Maymounkov, P. and Mazieres, D., *Kademlia: a peer-to-peer information
  system based on the XOR metric*, IPTPS, 2002.
- OAI-PMH: <https://www.openarchives.org/pmh/>.
- SWORD: <https://swordapp.org>.
- LOCKSS: <https://www.lockss.org>; CLOCKSS: <https://clockss.org>.
- OCFL 1.1: <https://ocfl.io>.
- DataCite Metadata Schema: <https://schema.datacite.org>.
- ORCID: <https://orcid.org>.
- Crossref, *Strengthening support for data citations and saying goodbye
  to Event Data*, 24 March 2026:
  <https://www.crossref.org/blog/strengthening-support-for-data-citations-and-saying-goodbye-to-event-data/>.
- The PLC Organization: <https://plcred.org>.
- Software Heritage: <https://www.softwareheritage.org>.
- The OpenSheaf [specification](../opensheaf-specification-0.2.md),
  [FAQ](../FAQ.md), [use cases](../USE-CASES.md), [OpenSheaf archives in
  git](../opensheaf-git-0.2.md), the [timestamps
  extension](../opensheaf-timestamps-0.2.md), and the working papers
  [git-as-implementation.md](git-as-implementation.md),
  [keys-and-forks.md](keys-and-forks.md),
  [federated-identity.md](federated-identity.md),
  [radicle.md](radicle.md), [matrix.md](matrix.md),
  [arxiv.md](arxiv.md), [hexagon.md](hexagon.md),
  [alphaxiv.md](alphaxiv.md) and
  [federated-publishing.md](federated-publishing.md), whose references
  give the sources for the systems of section 5 not listed here.
- Kuhn, T. and Dumontier, M., *Trusty URIs: verifiable, immutable, and
  permanent digital artifacts for linked data*, ESWC 2014, LNCS 8465, pp.
  395-410, doi:10.1007/978-3-319-07443-6_27.
- Ellerman, E. C., *Document Succession Git Layout*, edition 1.1, 20
  February 2024, <https://castedo.github.io/dsgl-spec/>.
- Knowledge Futures, *Underlay, revived*, 27 April 2026,
  <https://www.knowledgefutures.org/updates/2026-04-27-underlay-revived>.
