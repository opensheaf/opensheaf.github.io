# arXiv and OpenSheaf

*Working paper, draft of 21 November 2026. Non-normative: ideas and positions,
not decisions. arXiv is the preprint server of physics, mathematics, computer
science and several other fields, and since July 2026 an independent
nonprofit. It is the record and the announcement channel that many of the
papers OpenSheaf archives would hold already have. This paper describes what
arXiv offers, sets it against OpenSheaf function by function (in the division
of [positioning.md](positioning.md)) and point by point, and evaluates the
position of each. It builds on sections 1 to 3 of the positioning paper,
which already place arXiv among the bundles of scholarly communication, and
continues the comparisons with [alphaXiv](alphaxiv.md), an overlay on arXiv,
and [Hexagon](hexagon.md), a repository made for AI-generated mathematics
that, in its founders' account, arXiv would not take. Its main findings:
arXiv's record is permanent but fixed only by its word; its default licence
gives arXiv a right to distribute that it cannot pass on, so most arXiv
papers cannot be mirrored under section 11.2; and its interfaces for machines
are better than anything OpenSheaf has. It ends with proposals,
experiments and open questions.*

> [!NOTE]
> The facts on arXiv were read on 21 November 2026 from its pages on
> `info.arxiv.org`: the about page (`/about/index.html`), the FAQ on the
> spinout from Cornell (`/about/spinout_faq.html`), governance
> (`/about/governance/index.html`), licences (`/help/license/index.html`),
> the submission agreement (`/help/policies/submission_agreement.html`), the
> policies index, replacements (`/help/replace.html`), withdrawals
> (`/help/withdraw.html`), moderation (`/help/moderation/index.html`, with its
> section on generative AI), content types
> (`/help/policies/content-types.html`), the code of conduct, endorsement
> (`/help/endorsement.html`), identifiers (`/help/arxiv_identifier.html`),
> DOIs (`/help/doi.html`), bulk data (`/help/bulk_data.html`,
> `/help/bulk_data_s3.html`), OAI-PMH (`/help/oa/index.html`), the API
> (`/help/api/index.html`, `basics.html` and its terms of use, `tou.html`),
> arXivLabs (`/labs/index.html`), submission formats (`/help/submit/index.html`,
> `/help/faq/whytex.html`); from the summaries of the default licence and of
> the assumed licence of 1991-2003 on `arxiv.org/licenses/`; from three posts
> of the arXiv blog (31 October 2025, on review articles and position papers
> in CS; 21 January 2026, on endorsement; 3 February 2026, on preservation);
> and from the abstract page of `arXiv:1706.03762`, current and `v1`. The
> one-strike rule on AI output was read only in a secondary source, "arXiv's
> one-strike rule on AI", CERN Courier, 23 July 2026; it was not found on
> arXiv's own pages read. Not read: the Kaggle page of the dataset (it did not
> render), arXiv's page on copyright infringement, its source code. The
> reference archive [mgubi/papers](https://github.com/mgubi/papers) was read
> from a local copy on the same day. Services change: check them before
> relying on any of this. Section numbers are those of [version
> 0.2](../opensheaf-specification-0.2.md) of the specification.

## 1. The question

The [positioning paper](positioning.md) lists arXiv first among the bundles
of scholarly communication (section 2): it records "with dated
submissions", announces through "the daily listings", filters by
"moderation only", and distributes. It also names the limit that matters
here: "A selection of arXiv papers can name the version it vetted
(`arXiv:...v2`), but only arXiv vouches for the bytes behind that name."

The other comparisons were with newcomers. [alphaXiv](alphaxiv.md) grew from
reading arXiv papers into a service of its own; [Hexagon](hexagon.md) was
founded, in its founder's account, because arXiv was not going to be the home
of results found with language models. arXiv is the incumbent: the record
that, in mathematics, physics and computer science, many papers already have,
and the record from which the only real OpenSheaf archive was built. Three
questions follow. What does arXiv do that OpenSheaf should not try to do? What
does OpenSheaf add to a paper that is already on arXiv? And what, in arXiv's
rules, limits what OpenSheaf can do with arXiv papers?

## 2. What arXiv is

**Who runs it.** arXiv was founded by Paul Ginsparg in 1991 and was hosted by
Cornell University for decades. "On July 1, 2026, arXiv established itself
as an independent nonprofit organization" (spinout FAQ): arXiv, Inc., "a
nonprofit, nonstock Delaware Corporation", granted tax-exempt status, with
"two founding Members: the Simons Foundation and Cornell University". It is
governed by a Board of Directors; a Chief Executive Officer leads its
operations (Penelope Lewis from 17 August 2026), with "numerous volunteer
subject moderators" and three advisory councils (editorial, institutions,
science). For the near term its headquarters remain at Cornell Tech. It is funded by Simons
Foundation International, member institutions and donors, and remains
"committed to being free to use". It "now hosts more than three million
scholarly articles in eight subject areas" (about page).

**Who may submit.** A registered user, endorsed for the category: "arXiv
requires that users be endorsed before submitting their first paper to arXiv
or a new category." Endorsement "verifies that arXiv contributors belong to
the scientific community" and "is not peer review". Since January 2026 an
institutional e-mail address alone no longer qualifies a new author: it must
come with prior authorship in the domain, or a personal endorsement is
needed; the stated reason is "the flood of low-quality, non-scientific
submissions" (blog, 21 January 2026).

**Moderation.** "[T]he arXiv moderation process is not a peer-review process."
Moderators expect submissions "to be of scholarly archival interest", may
decline one that "lacks originality, novelty, significance", reclassify, and
"arXiv, in its sole discretion, may decline to post works". Research
articles are the primary content; the content types also cover theses,
proceedings, books, lecture notes, translations, and comments and replies.

**Generative AI.** Authors must report significant use of sophisticated
tools, "text-to-text generative AI" included; each author takes "full
responsibility" for the content, however it was generated; and "generative
AI language tools should not be listed as an author" (moderation page). In
computer science, review articles and position papers must now "be accepted
at a journal or a conference and complete successful peer review" before
submission, because of "the unmanageable influx" of them, to which
generative AI has "added" (blog, 31 October 2025); the post presents this as
practice, not a new policy, since such papers were never an accepted
content type. A CERN Courier article of July 2026 reports a further
"one-strike" rule: authors of papers with "incontrovertible evidence of
hallucinatory AI generation" risk "a year's suspension", described by arXiv's
scientific director as "a matter of enforcement, rather than a new rule".
That rule was not found on arXiv's own pages read.

**Identifiers and versions.** `arXiv:YYMM.NNNNN` since January 2015 (four
digits from April 2007; `archive/YYMMNNN` before), with a version suffix
`vN` from `v1`; an identifier without a version names "the most recent
version". "It is not possible to make changes without generating a new
version", and "Previous versions of your article will remain publicly
available". The exceptions are journal reference, DOI and report number,
added without a new version; other changes in place are refused because
"all changes would be backdated". Same-day edits before the daily cutoff do
not make a new version stamp. Replacements are asked to be no more than
once a week.

**DOIs.** "All articles submitted to arXiv are automatically assigned DOIs",
`10.48550/arXiv.<id>`, registered with DataCite. The DOI is the article's,
not a version's: "Replacing an article with a new version will not generate
a new DOI", and it "will always point to the latest version".

**Withdrawal and removal.** "A withdrawal creates a new version of the paper
marked as withdrawn", which shows the reason, publicly, and "does not link
directly to the full text"; the page says "that the paper has been
withdrawn, and by whom", and "Previous versions will still be accessible,
including the full text." "Articles that have been announced and made public
cannot be completely removed" by their authors; the submission agreement
reserves arXiv's right "to reclassify, reject, or remove any submission",
and to remove a work or block access to it under applicable laws. Copyright
infringement is handled apart from withdrawal.

**Rights.** Six licences, chosen per version: CC BY 4.0, CC BY-SA 4.0, CC
BY-NC-SA 4.0, CC BY-NC-ND 4.0, CC0, and the "arXiv.org perpetual,
non-exclusive license 1.0", the default. "The license chosen is irrevocable
and cannot be changed", but "different versions of the work can have
different licenses". The default licence "gives limited rights to arXiv to
distribute the article, and also limits re-use of any type from other
entities or individuals"; it "does not assign copyright to arXiv, nor grant
arXiv the right to grant any specific rights to others", so "We are thus
unable to grant others the right to distribute arXiv articles" (bulk data
page). Submissions before January 2004 carry an assumed licence to the same
effect, inferred from the act of submitting. Metadata are under CC0. arXiv
"encourages choosing a liberal license", and says that "Most articles" use
the default.

**Formats.** TeX/LaTeX first "in order of preference", then PDF and HTML;
arXiv compiles TeX itself, and does not accept PDF made from TeX. "Source
files are of higher archival value than converted documents". The abstract
page offers PDF, HTML (experimental) and the TeX source.

**Preservation.** The submission agreement says "arXiv maintains a permanent
collection of submitted Works". Since February 2026 Portico and TIB, the
German national library of science and technology, keep arXiv's content
"dark" until it is needed, "in the unlikely event that arXiv is no longer able
to host content" (blog, 3 February 2026); the post does not say what they
keep (PDFs, sources, every version).

**Access for machines.** OAI-PMH (`https://oaipmh.arxiv.org/oai`), "the
preferred way to bulk-download or keep an up-to-date copy of arXiv
metadata", in three formats, of which `arXivRaw` "Includes history for
previous versions of the paper", with sets by category, updated after each
announcement, Sunday to Thursday. A query API returning Atom, at one request
every three seconds. PDFs and sources on Amazon S3 in a requester-pays
bucket, in tar files of about 500 MB updated about monthly, with manifests
giving an MD5 sum of each tar file. "The full, machine-readable arXiv dataset
is available on Kaggle." The terms of use of the APIs forbid to "Store and
serve arXiv e-prints (PDFs, source files, or other content) from your
servers" without the copyright holder's permission or a licence that allows
it, and ask to "Direct users to arXiv.org to retrieve e-print content"; the
bulk data pages ask that tools built on the full text "link back to arXiv
for downloads".

**arXivLabs.** Features built with outside collaborators, shown in tabs on
the abstract page: on that of `1706.03762`, bibliographic tools, citation
services, "Code, Data and Media" (alphaXiv among them) and demos. New
proposals are paused while arXiv modernises its systems.

**What an abstract page shows.** For `1706.03762`: the submitter ("From:"),
the seven versions with their dates and sizes, "Cite as" with and without the
version, the DOI, the comments, the subjects, a link to the licence. **No
digest of any file is shown.**

**Not found.** A digest of a version or of its files, outside the MD5 sums of
the bulk tar files; signatures; discussion on arXiv's own pages; what stays
at the address of a work removed for legal reasons; whether arXiv's software
is open source (its documentation is edited on GitHub; the code was not
looked at).

## 3. Function by function

In the division of [positioning.md](positioning.md), section 1, refining its
table of section 2:

| Function | arXiv | OpenSheaf |
|---|---|---|
| Record | yes: dated versions `vN`, all kept public, with sources; an identifier per article and per version, a DOI per article; no published digests | the form of the record: object versions fixed by SHA-512 inventories, signed by their owners, named by `sheaf:` URIs |
| Preserve | a permanent collection, and since 2026 dark archives at Portico and TIB | none by itself; checkable copies (section 11), allowed only where the licences allow (section 11.2) |
| Announce | the daily listings, the announcement channel of whole disciplines | the raw material: an archive's feed (section 3.1, appendix A.3); aggregation is a service |
| Filter | endorsement and moderation, not review; in CS, prior peer review for reviews and position papers | the form of a filter's statements: selections pinning the revisions vetted (section 8.4) |
| Distribute | yes: pages, PDF, HTML, sources; OAI-PMH, an API, bulk data on S3 and Kaggle; tools of others through arXivLabs | any web server; landing pages for search engines (appendix A.3); the Explorer |
| Assign merit | little; links to citation services of others | none counted; the evidence made checkable |

arXiv is the bundle that [positioning.md](positioning.md) describes, and a
mild one: it filters lightly (moderation, not review), takes no copyright, and
asks for no payment. Its hold on the other functions comes from announcement.
The volume of submissions, to which generative AI adds by arXiv's own account,
has pushed it to filter more (endorsement, the CS rule).

## 4. Point by point

**Fixity.** An arXiv version does not change once announced, by arXiv's rule,
and its source, when there is one, is kept with it. But nothing outside arXiv
fixes it: the abstract page shows sizes, not digests, and the MD5 sums of the
bulk data check a download of a tar file, not the identity of a version. A
citation of `arXiv:1406.7675v5` names bytes that only arXiv can produce and
vouch for, as [positioning.md](positioning.md) (section 2) says. An
OpenSheaf version is fixed by its inventory, and its pin is checked against
any copy (sections 4 and 7.6). An import adds something arXiv lacks: the
SHA-512 digests of the files received from arXiv, recorded in `external`
(section 4.3) and signed with the version. They fix what the importing owner
received, when it imported, not what arXiv served on the day of the
version; for older versions the two are separated by years.

**Who stands behind a version.** On arXiv, the account of the submitter,
endorsed for the category, who certifies "the right to grant this license";
the abstract page names the submitter, and a withdrawal says by whom. No
version is signed. In OpenSheaf an owner's keys sign each version it publishes (section 7.1;
drafts are not signed, section 10); a keeper may answer for the owner (section 6.6), and authorship stays
in `creators` (section 4.4). An imported arXiv version is signed by the
owner that imported it: the signature says that this owner decided the
version and received these bytes, not that arXiv or every author agreed.

**Names and DOIs.** `arXiv:YYMM.NNNNNvN` names a version in one service, and
without `vN` the latest. arXiv's DOI is an article's, resolved to the latest
version: a citation by DOI does not say which version was read. A `sheaf:` URI names a document
version, and with `?sha512=` exactly one object version (section 12.1),
resolved from any copy that passes the checks (section 12.3). OpenSheaf
records arXiv's names beside its own: in the reference archive, an imported
version has `IsIdenticalTo` `arXiv:1406.7675v5` and `IsVersionOf` the DOI
`10.48550/arXiv.1406.7675` in `datacite.json` (section 4.4). DOIs of an
archive's own are open
([#8](https://github.com/opensheaf/opensheaf.github.io/issues/8)).

**Versions.** Close in intent: every version kept, no change without a new
version. arXiv's reason for refusing changes in place, that "all changes
would be backdated", is the reason OpenSheaf records every change as a new
object version, a description-only one when the files do not change (section
4.2). Where arXiv adds a journal reference or a DOI in place, OpenSheaf adds
them by a description-only version, so that what a version said can be read
back; what such a version may change is open
([#24](https://github.com/opensheaf/opensheaf.github.io/issues/24)). The
numbering differs on purpose: the owner numbers document versions from 1
without gaps, independently of arXiv, and arXiv's `v3` is a label in
`external` (section 4.2, "Numbering"). The reference archive shows why. In
one line, document versions 1, 2 and 3 are arXiv's `v1`, `v3` and `v4`,
document version 4 is the authors' accepted version, never on arXiv, and
document version 5 is arXiv's `v5`. In another, document version 1 is the
authors' draft of the day before arXiv's `v1`, which is document version 2.
arXiv's comments become the change note, `changes` (section 4.3), and the
date of an arXiv version its `Available` date (section 4.4).

**Withdrawal and removal.** arXiv's withdrawal is close to OpenSheaf's
(section 13.1): the earlier versions stay, the withdrawal is public with a
reason. The difference is in form. On arXiv a withdrawal is a new numbered
version without full text; in OpenSheaf it is a description-only version,
which makes no new document version. How an import maps arXiv's withdrawn
`vN` (as a withdrawal of the line, with `vN` as a label) is a question for the
tools, and what follows a withdrawal is open
([#25](https://github.com/opensheaf/opensheaf.github.io/issues/25)). arXiv's
removal for legal reasons is OpenSheaf's takedown (section 13.2); the pages
read do not say what stays at its address, where OpenSheaf leaves a
tombstone with a pin (section 13.3). Whether a takedown reaches copies
elsewhere is open in OpenSheaf
([#33](https://github.com/opensheaf/opensheaf.github.io/issues/33),
[#66](https://github.com/opensheaf/opensheaf.github.io/issues/66)); for
arXiv papers there are few copies elsewhere, for the reason that follows.

**Rights and licences.** This is the point that matters most for OpenSheaf. An
author who submits under arXiv's default licence keeps the copyright and
grants arXiv a right to distribute, which arXiv cannot pass on to anyone.
OpenSheaf allows a mirror only if the licences of every version copied allow
redistribution (section 11.2), and a branch, an accepted copy included, needs
the right to redistribute its parent versions (sections 9.7 and 15.6). The
proposal of [#34](https://github.com/opensheaf/opensheaf.github.io/issues/34)
names "arXiv's distribution licence" among what "cannot be mirrored". The
reference archive shows the scale. Of its 81 lines imported from arXiv, the
latest version of 52 carries arXiv's default licence, 20 the assumed licence
of 1991-2003, 8 CC BY 4.0 and 1 CC0. Only 3 lines carry an open licence in
every version. In 8 the licence changes between versions: 6 of them reach CC
BY or CC0 only after restricted versions (arXiv's licence, or "All rights
reserved" for a draft never on arXiv), the case of #34 in which the open head
reuses files of a restricted version, and 2 change between restrictive
licences. So 3 of 81 lines could be mirrored as they stand. The author, who
holds the rights, may keep and serve the archive; a custodian, a mirror or a
journal keeping an accepted copy needs the authors' permission besides the
licence. `agreement` (section 4.3) records only that the authors agreed to a
deposit and its licence; copying by the agreement of the rights holders is
open (section 11.2,
[#39](https://github.com/opensheaf/opensheaf.github.io/issues/39)). A
reference needs no permission (section 8.5), but a selection can only pin
lines, so a paper that is only on arXiv is first imported into an archive
([use cases](../USE-CASES.md)). How a verifier tells a licence from a rights
statement, such as arXiv's licence, which has no SPDX identifier, is open too
([#50](https://github.com/opensheaf/opensheaf.github.io/issues/50)).

**Preservation.** arXiv's own collection, and dark copies at Portico and TIB
released only if arXiv cannot serve: the arrangement that
[positioning.md](positioning.md) (section 3) proposes for works that may not
be served, done by the record itself. It is stronger than anything OpenSheaf
has, whose custodians' promises are open
([#54](https://github.com/opensheaf/opensheaf.github.io/issues/54)). Its
limit is that the copies are dark and arXiv's: no one else can check them
against a version, or serve them. In OpenSheaf any copy is checked by its pin,
but only openly licensed lines may be copied at all.

**Moderation and AI-generated work.** arXiv filters at the door, and its
filtering is growing under the volume of submissions, generated ones among
them: endorsement tightened, prior peer review for CS reviews and position
papers, and, reportedly, suspensions for unchecked AI output. AI use is to be
disclosed; the pages read do not define a field for it. [Hexagon](hexagon.md)
exists, in its founders' account, because arXiv would not take such work, and
records how a version was made in fields of its own. OpenSheaf has no door:
anyone can publish an archive, and filtering falls to the selections and
announcement services built over archives ([positioning.md](positioning.md),
section 6, "Abuse and noise"). That frees the record from moderation, and
leaves the volume to filters that do not exist yet. OpenSheaf has no field for
provenance either; the [Hexagon paper](hexagon.md) proposes one.

**Discussion.** arXiv has none on its own pages; comments and replies are
papers, and discussion lives in services linked through arXivLabs, such as
alphaXiv, whose threads do not say which version they discuss
([alphaxiv.md](alphaxiv.md)). OpenSheaf has no form for it either
([#21](https://github.com/opensheaf/opensheaf.github.io/issues/21)).

**Machine readers.** arXiv's strongest point after announcement: metadata by
OAI-PMH, with the history of versions (`arXivRaw`) and licences (`arXiv`
format), under CC0; a query API; bulk PDFs and sources; a dataset on Kaggle;
documented rate limits and terms. The terms keep the full text with arXiv:
indexes may be built, copies may not be served. OpenSheaf archives are files
that any program can read and check, with indexes (section 12.5) and a feed
(section 3.1); the website profile MAY publish a static OAI-PMH repository
(appendix A.3). But there is no aggregate: no harvestable view across
archives, no resolver to call, no gateway yet
([#19](https://github.com/opensheaf/opensheaf.github.io/issues/19),
[#20](https://github.com/opensheaf/opensheaf.github.io/issues/20),
[#35](https://github.com/opensheaf/opensheaf.github.io/issues/35)).

**Openness and governance.** arXiv is now an independent nonprofit with a
board, two founding members, institutional members and volunteer moderators:
a community institution, free to read and to submit to. It is also one
organisation, one host, one set of identifiers, as
[positioning.md](positioning.md) (section 2) notes. OpenSheaf is a published
format with open tools, under which anyone keeps archives; it has no
institution, and its governance is that of a draft specification and its
issues.

## 5. Evaluating the positions

### What arXiv does well

- **It is where the readers are.** The daily listings are how many
  mathematicians learn of new work
  ([positioning.md](positioning.md), section 1). No format replaces that.
- **Its record is careful.** No change without a new version, every version
  public, withdrawal without removal, a reason given against backdating.
  These are the rules OpenSheaf writes into its format (sections 4.2 and 13).
- **It keeps sources.** TeX is preferred and served, for "higher archival
  value", which OpenSheaf also asks for (section 4.2).
- **It costs authors nothing.** An account, an endorsement, an upload.
- **It serves machines.** OAI-PMH with version histories and licences, an API,
  bulk data, all documented, with CC0 metadata.
- **It plans for its own end.** Dark copies at Portico and TIB, and now an
  institution of its own.

### Where its position is weak

- **The record rests on its word.** No digests are published, so neither a
  citation nor a selection can say which bytes it means in a way others can
  check, and an AI service or an overlay that reads arXiv cannot either.
- **Its default licence locks the copies in.** arXiv cannot grant others the
  right to distribute, its terms forbid serving its e-prints, and its dark
  archives are its own. Most arXiv papers may be served only by arXiv and
  by their authors.
- **Its DOIs name articles, not versions.** The identifier with `vN` is
  precise; the DOI, which most citation systems prefer, is not.
- **Moderation carries the weight of volume.** As generated papers grow, a
  central door, kept by volunteer moderators, must filter more; the rules of
  2025 and 2026 show the strain.
- **Trust is by account.** Endorsement and certification are records in
  arXiv's database, not statements others can check.

### Where OpenSheaf's position is weak

- **It depends on arXiv for content.** 81 of the 83 documents of the
  reference archive have versions imported from arXiv; OpenSheaf there adds to arXiv's record,
  it does not replace it.
- **It cannot copy most of what it imports.** By its own rule (section 11.2),
  arXiv's licences confine most imported papers to the author's archive.
- **Dates come from arXiv.** An imported version is deposited and signed when
  imported; its `Available` date is arXiv's, a claim recorded by the owner.
  Priority stays with arXiv's record.
- **No audience and no announcement.** Feeds exist; no service aggregates
  them ([#19](https://github.com/opensheaf/opensheaf.github.io/issues/19)).
- **Cost to authors.** Keys, a host and tools, against an upload.

### The relation

They are not on the same layer. arXiv is a record, an announcement channel
and a distributor, run by an institution; OpenSheaf is a form for records
and for statements about them, kept by anyone. An author's OpenSheaf archive
sits beside arXiv: arXiv announces and serves, and the archive fixes each
version by a pin, signs it, keeps versions that were never on arXiv (drafts,
the accepted manuscript, the original TeXmacs sources, as in the reference
archive), and lets selections pin what they vetted. The flow is one way: from
arXiv into archives, through `osheaf arxiv import` ([TOOLS.md](../TOOLS.md)),
which reads what arXiv makes public and asks nothing of it. The FAQ calls
OpenSheaf "a lean alternative to arXiv"; as far as announcement and audience
go, this comparison suggests a complement.

What OpenSheaf could offer arXiv is small: digests that make each version
checkable outside arXiv, and a form for selections and overlays that pin
arXiv versions. What arXiv could do for OpenSheaf is larger, and is not in
OpenSheaf's hands: a liberal licence chosen by more authors would make their
papers copyable by any custodian.

## 6. Proposals

These are ideas for discussion, not decisions; each would go through an
issue before anything changes.

- **Licences at import.** The importer could report, for each line, whether
  it can be mirrored under section 11.2 (and under the proposal of
  [#34](https://github.com/opensheaf/opensheaf.github.io/issues/34)), and
  the FAQ or the use cases could advise authors to choose CC BY for their
  next arXiv versions, as arXiv itself "encourages". The licence of a version
  already on arXiv cannot be changed there, so a later version is the only
  way to open a line, and it reuses the files of the restricted ones (case 2
  of #34).
- **An arXiv import, written down.** The mapping that `osheaf arxiv import`
  follows (arXiv as an external record of role `source`, `vN` as `label`, the
  files received with their SHA-512 in `files`, `IsIdenticalTo` the versioned
  identifier, `IsVersionOf` the arXiv DOI, arXiv's licence URL in
  `rightsList`, `sourcesMissing` when arXiv has no source, comments as
  `changes`, the version's date as `Available`) could become a profile beside
  Zenodo's (appendix A), or a section of the use cases, so that other tools
  import alike. Withdrawn arXiv versions need a rule
  ([#25](https://github.com/opensheaf/opensheaf.github.io/issues/25)).
- **Witnessed digests of arXiv versions.** A custodian could publish the
  SHA-512 digests of arXiv versions as first fetched, without the files, so
  that a selection or an AI answer naming `arXiv:...vN` could also name the
  bytes. Whether a reference to a version outside any archive, with a digest,
  can be a member or a relation is for
  [#21](https://github.com/opensheaf/opensheaf.github.io/issues/21) and
  [#22](https://github.com/opensheaf/opensheaf.github.io/issues/22); today a
  selection pins only lines (section 8).
- **Copies by agreement.** For arXiv-licensed papers whose authors agree, a
  minimal record of the agreement and the copies it allows, as
  [#39](https://github.com/opensheaf/opensheaf.github.io/issues/39) discusses;
  dark copies under federation agreements stay outside the format
  ([positioning.md](positioning.md), section 3).
- **A suggestion to arXiv.** Publish a digest of each file of each version,
  in the abstract page and in `arXivRaw`, as Hexagon does per file
  ([hexagon.md](hexagon.md)). It costs little, and would make every arXiv
  citation checkable without arXiv.

## 7. Experiments

- Fetch again, from arXiv, the files of the 154 arXiv versions imported into
  the reference archive, and compare their SHA-512 with those recorded in
  `external`: do arXiv's bytes for a version stay the same over time (a PDF
  regenerated, a source repackaged)?
- Harvest a month of metadata by OAI-PMH and count licences: the share of
  new arXiv papers that could be mirrored under section 11.2, and how often a
  line changes licence.
- Compare a version's source in the S3 bulk data with the one served by the
  abstract page.
- Import, in a test archive, an arXiv paper with a withdrawn version, and one
  whose source is not served, and see what `osheaf` records.
- Build a selection over imported arXiv papers (an overlay journal's issue)
  and record which of its members could also be kept as accepted copies under
  their licences.

## 8. Open questions

- Should an archive import arXiv papers of which its owner is not an author?
  The default licence gives others no right to distribute them; a selection
  needs them as lines.
- What does a signature on an imported version mean to a reader: that the
  owner received these bytes from arXiv, or that the owner vouches for the
  version? The [keys and forks paper](keys-and-forks.md) discusses what a
  signature can and cannot show about time.
- Can priority ever rest on anything but arXiv's record for papers first
  posted there?
- Is OpenSheaf an alternative to arXiv, as the FAQ says, or a layer beside it?
- Would arXiv, now an independent institution planning a move of its systems,
  have reasons of its own to publish digests or inventories?

## 9. Conclusion

arXiv is the record and the announcement channel of the fields OpenSheaf
starts from, run carefully and now by an institution of its own. Its rules on
versions and withdrawal are those OpenSheaf writes into its format. It differs
in two things that matter: its record is fixed only by its word, since no
digests are published, and its default licence makes arXiv, with the authors,
the only ones who may serve most papers, which rules out mirrors under section
11.2 for all but a few of them. OpenSheaf can add to an arXiv paper what arXiv
does not give: a pin for each version, signatures, versions that were never on
arXiv, and selections that say exactly what they vetted. It cannot take
arXiv's place as announcer, nor copy freely what authors licensed to arXiv
alone. The most useful steps are modest: write down how arXiv papers are
imported, help authors choose open licences, and ask arXiv to publish digests.
