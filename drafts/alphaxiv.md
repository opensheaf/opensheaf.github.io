# alphaXiv and OpenSheaf

*Working paper, draft of 21 November 2026. Non-normative: ideas and positions,
not decisions. alphaXiv is a hosted service for following, reading and
discussing research papers, built over arXiv and, since it began to publish
papers directly, a preprint server of its own. This paper describes what it
offers, sets it against OpenSheaf function by function (in the division of
[positioning.md](positioning.md): record, preserve, announce, filter,
distribute, assign merit) and point by point, and evaluates the position of
each: where they compete, where they meet, what alphaXiv shows OpenSheaf to be
missing, and what OpenSheaf could give a service of its kind. It ends with
proposals, experiments and open questions.*

> [!NOTE]
> The facts on alphaXiv were read on 21 November 2026 from its home page, its
> submission policy (`/docs/submission-policy`), the documentation of its MCP
> server (`/docs/mcp`), its list of submissions, its blog and the page of its
> Autoresearch application (`openresearch.sh`). Points marked *(unverified)*
> come from earlier knowledge and were not found on those pages. Services
> change: check them before relying on them. Section numbers are those of
> [version 0.2](../opensheaf-specification-0.2.md) of the specification.

## 1. The question

The [positioning paper](positioning.md) argues that scholarly communication
bundles several functions, that the function authors cannot do without
tends to bring the others with it, and that OpenSheaf should be an exchange
layer under which anyone keeps archives and over which anyone builds
services. alphaXiv is a test of that argument from the other side: a young
service that started with one function over another service's
record (reading and discussing arXiv papers) and has since taken on others
(announcing, distributing, recording). Two questions follow. Is it a
competitor, a possible user, or neither? And what does its success say about
what OpenSheaf lacks?

## 2. What alphaXiv is

As its pages describe it on 21 November 2026:

- **A reading and discovery service.** The home page is a feed of papers,
  with explainer videos, counts (unlabelled on the page), and the researchers
  and organisations of each paper. It describes itself as connecting "papers,
  researchers, and organizations, grounding its answers in the underlying
  work", and offers a "grounded literature review". Papers are at
  `/abs/<id>`, researchers at `/@<slug>`, conferences at
  `/conferences/<name>/<year>`.
- **A corpus over arXiv.** Its papers come mostly from arXiv, under arXiv
  identifiers; "Papers not yet in the database are fetched from arXiv". It
  also reads Semantic Scholar pages and direct PDF URLs.
- **A preprint server.** Anyone with an account can publish a paper
  directly (its list of submissions starts in June 2025): "Anyone with an alphaXiv account can submit a paper they
  authored, or submit on behalf of its authors with their permission". Such
  papers get identifiers of their own (`2611.harness-cg`). There are two
  tracks, human-written ("AI assistance is welcome, including substantial
  assistance") and AI ("Fully AI-written papers are welcome"). Every
  submission is screened, and "Screening is not peer review"; a reupload of
  an arXiv paper is refused as a duplicate. New versions can be uploaded and
  "Earlier versions of submissions will stay available"; corrections of
  title, authors or categories change the paper without a new version. A
  withdrawn paper, and one taken down, keeps its URL. Authors keep their
  copyright and grant alphaXiv "a non-exclusive, perpetual and irrevocable
  license to host, distribute and preserve the paper", and may add one of
  five Creative Commons licences (CC BY, CC BY-SA, CC BY-NC-SA, CC BY-NC-ND,
  CC0). "Published papers are kept permanently", and would be transferred to
  "a third-party archive" if alphaXiv shut down.
- **Researcher profiles**, at `/@<slug>`, which its tools match to names
  and positions, and which may answer that "nothing matched confidently". How a researcher
  claims a profile is not documented on the pages read.
- **AI over the corpus.** An MCP server (`https://api.alphaxiv.org/mcp/v1`,
  OAuth or an API key) with some twenty tools: feeds, search by "an agentic
  retrieval loop", the text of a paper or "a structured AI-generated
  intermediate report" of it, answers to questions with page-level excerpts,
  reading a paper's code on GitHub, researcher profiles and a personal
  library. Search and analysis count against an assistant quota.
  Browser-hosted clients (claude.ai, chatgpt.com) are not supported, since
  its cross-origin access is limited to its own sites. A desktop application,
  Autoresearch, turns coding agents into "research agents that review
  literature, develop hypotheses, and run experiments".
- **Discussion.** *(Unverified.)* alphaXiv began in 2024 as a place to
  comment on arXiv papers, line by line, and was linked from arXiv's
  abstract pages through arXivLabs. The pages read neither show nor describe
  comments today.

Not found on the pages read: a business model or prices, DOIs, a bulk export,
a public API other than the MCP server, any way to run it elsewhere.

## 3. Function by function

In the division of [positioning.md](positioning.md), section 1:

| Function | alphaXiv | OpenSheaf |
|---|---|---|
| Record | arXiv's, for most papers; its own for direct submissions: versions kept, URLs kept after withdrawal | the form of the record: object versions fixed by SHA-512 inventories, signed by their owners, named by `sheaf:` URIs |
| Preserve | a promise: kept permanently, transferred to a third party on closure | none by itself; checkable copies (mirrors, section 11), so that others can preserve |
| Announce | yes: feeds, trending papers, conference pages, follows | the raw material: an archive's feed (section 3.1, appendix A.3); aggregation is a service |
| Filter | screening of submissions; ranking by attention; AI search | the form of a filter's statements: selections pinning the revisions vetted (section 8.4) |
| Distribute | yes, in its interface and to agents through its MCP server | any web server; landing pages for search engines (appendix A.3); the Explorer |
| Assign merit | attention (views, follows, researcher profiles) | none counted; the evidence made checkable (signatures, selections, relations) |

Two things follow. alphaXiv now holds every function but merit in the
strict sense, which it approaches through attention. And it holds them in
the way [positioning.md](positioning.md) (section 2) describes: the
function that drew its readers (reading and discussing papers, now AI
reading) brought announcement and distribution with it, and then the
record.

## 4. Point by point

**Fixity.** An alphaXiv version is fixed by alphaXiv's word: a reader cannot
check that the PDF served today is the one served when a version was cited,
or that a correction of the metadata did not change what a version says. An
OpenSheaf version is fixed by its inventory: any copy, from anywhere, is
checked against its pin (sections 4 and 7.6). The difference matters little
while the host is trusted and lasts, and decides everything when it is not,
or does not.

**Names.** alphaXiv's identifiers (arXiv identifiers, its own such as
`2611.harness-cg`, the `universal_paper_id` of its MCP server) are names in
one service, resolved by it. A `sheaf:` URI names a line by a digest of its
genesis record and its owner, and with a pin one object version, in every
archive (section 12.1); it is resolved by any resolver, from any copy that
passes the checks (section 12.3). alphaXiv issues no DOIs, as far as the
pages say; OpenSheaf can carry them (`doi` in `datacite.json`, section 4.4;
issue [#8](https://github.com/opensheaf/opensheaf.github.io/issues/8)).

**Versions.** Both keep every version. alphaXiv lets corrections of title,
authors and categories change a version in place; OpenSheaf records any
change as a new object version, a description-only one when the document
does not change (section 4.2), so that what a version said can always be
read back. What a description-only version may change is open
([#24](https://github.com/opensheaf/opensheaf.github.io/issues/24)).

**Withdrawal and takedown.** Close in intent: on both, a withdrawn paper
keeps its address and its versions, and a takedown is for law and rights.
OpenSheaf's withdrawal is a signed act of the owner (section 13.1), and a
takedown leaves a tombstone with a pin (section 13.3); on alphaXiv both are
states of its database.

**Rights.** alphaXiv takes a perpetual, irrevocable, non-exclusive licence to
host, distribute and preserve, and offers five Creative Commons licences.
OpenSheaf takes nothing: the licence is in `rightsList` (section 4.4), the
metadata are under CC0 (section 15.6), and a mirror is allowed only where the
licences allow redistribution (section 11.2;
[#34](https://github.com/opensheaf/opensheaf.github.io/issues/34)). alphaXiv's
licence is what lets it promise preservation alone; OpenSheaf's rule is what
lets others preserve without asking.

**Preservation.** alphaXiv's promise to transfer its papers on closure is a
promise of one company, with no named recipient. OpenSheaf promises nothing
itself and relies on custodians (section 11), whose promises are open
([#54](https://github.com/opensheaf/opensheaf.github.io/issues/54)). Neither
is yet backed by an institution that lasts, as CLOCKSS or Portico back
journals (see [positioning.md](positioning.md), section 4).

**Authors.** alphaXiv's researchers are profiles that its tools match, and
submissions are made by accounts, for oneself or with the authors'
permission. OpenSheaf's owners are keys with key logs (section 6), whose
signatures say which owner's keys signed a version, and checking them needs
no account anywhere. An owner may name a keeper, an ORCID iD or a domain,
who answers for it, not for who wrote its documents (section 6.6); proofs
beyond the keeper are open
([#41](https://github.com/opensheaf/opensheaf.github.io/issues/41)).

**Curation.** alphaXiv curates by feeds, trending lists, conference pages
and personal folders: lists inside the service, which cannot be cited as
they stood. OpenSheaf's collections are themselves signed, versioned objects
that pin their members (section 8), held by anyone, citable at each
version.

**Discussion.** alphaXiv's original feature *(unverified)*, not described on
the pages read; OpenSheaf has no form for it.
Comments, reviews and replies about a version are an open design question
([#21](https://github.com/opensheaf/opensheaf.github.io/issues/21)), and so
is blind review
([#63](https://github.com/opensheaf/opensheaf.github.io/issues/63)); the
[Matrix paper](matrix.md) describes discussion carried beside an archive.

**Machine readers.** alphaXiv's present direction: a corpus, agentic search,
AI reports on papers, an MCP server, agents that do research. Its answers
are "grounded" in papers named by its own identifiers, read from its own
copies. OpenSheaf has no AI layer and wants none, but has what grounding
lacks: a way to say which bytes an answer was drawn from, checkable by the
reader.

**Openness and dependence.** alphaXiv is one service: its corpus, its
identifiers, its profiles and its API are its own, reachable through
accounts and quotas, with no export described. OpenSheaf is a published
format with open tools, and its archives are static files that anyone can
copy, check and serve.

## 5. Evaluating the positions

### What alphaXiv does well

- **It goes where readers are.** It starts from arXiv papers, AI reading
  and conference feeds, and builds from there; how many readers it has is
  not on its pages (its counts are unlabelled). OpenSheaf has no audience
  of its own, and no plan for one beyond the services that might be built on
  it.
- **It lowers the cost of every step.** Submitting needs an account; reading
  needs nothing; asking needs a question. OpenSheaf asks an author for keys,
  a host and tools before anything appears.
- **It took the record seriously.** Its submission policy has versions kept,
  addresses kept after withdrawal, a takedown policy, a licence chosen per
  version and a preservation promise. These are the rules of a preprint
  server, and close in spirit to sections 4.2 and 13 of the specification.
- **It treats machines as readers.** An MCP server is a better answer to
  "how does an agent read the literature" than scraping, and the question
  will only grow.

### Where its position is weak

- **One party holds everything.** The record of its direct submissions,
  their only copy, the identifiers, the profiles, the attention and the
  access for machines are in one service. This is the bundling that
  [positioning.md](positioning.md) (section 2) describes, rebuilt quickly: a
  reader of today's alphaXiv depends on it as a reader of a journal depends
  on its publisher.
- **The record is not checkable.** The pages describe no digests: a
  citation of an alphaXiv version, and an AI answer grounded in one, rest on
  alphaXiv's word about the bytes. For papers that exist only there, there
  is no second copy to compare.
- **Preservation is a promise.** A transfer to an unnamed third party, by a
  company whose business model is not stated, is weaker than copies already
  held by others.
- **AI-written papers make filtering the hard problem.** Screening "only
  checks that a submission belongs on alphaXiv". With an AI track, the
  volume of papers can grow faster than any attention; what is read will
  depend on filters, and on alphaXiv's ranking above all.
- **Two records of one work.** A reupload of an arXiv paper is refused as
  a duplicate, but the policy does not say what happens when a paper
  published on alphaXiv is later put on arXiv: a work may then have two
  records, under two identifiers, whose versions nothing links.

### Where OpenSheaf's position is weak

- **No readers, no discovery.** Feeds and indexes exist in the format
  (sections 3.1 and 12.5), but no service aggregates them, and the
  scale of an aggregation is open
  ([#19](https://github.com/opensheaf/opensheaf.github.io/issues/19),
  [#20](https://github.com/opensheaf/opensheaf.github.io/issues/20)).
- **No discussion.** What alphaXiv started with is what OpenSheaf leaves
  out ([#21](https://github.com/opensheaf/opensheaf.github.io/issues/21)).
- **Cost to authors.** Keys, key logs, hosting and the command line are a
  real barrier, which the [manager](https://opensheaf.org/manager/) and the
  archive template only begin to lower.
- **No machine interface.** An agent can read an archive's files, but there
  is no resolver it can call, and no gateway yet
  ([#35](https://github.com/opensheaf/opensheaf.github.io/issues/35)).

### The relation

They are not on the same layer, and should not compete. OpenSheaf is the
form of the record and of statements about it; alphaXiv is a service of
reading, announcement and, lately, recording. In the terms of
[positioning.md](positioning.md), alphaXiv is one of the services the
exchange layer is meant to carry, and the place where OpenSheaf could matter
to it is exactly where it is weak: the checkability of its record, its
dependence on one copy, the grounding of its answers and the portability of
its curation.

The realistic order is the other way round: alphaXiv does not need
OpenSheaf, and an OpenSheaf archive can use alphaXiv today. Its papers can
be read through their PDFs (alphaXiv reads direct PDF URLs), and those not
on arXiv could also be published there, with a deposit recorded as an
external record of the version (section 4.3), a witness, not a copy
(section 12.3), as for Zenodo
([#22](https://github.com/opensheaf/opensheaf.github.io/issues/22)). What
OpenSheaf can offer in return, should alphaXiv or a service like it want it,
is small and concrete: pins for what it cites and answers from, and
collections for what it curates.

## 6. Proposals

These are ideas for discussion, not decisions; each would go through an
issue before anything changes.

- **Grounding by pins.** A service that answers from papers should say
  which version it read, by a URI that the reader can check:
  `sheaf:<name>:<owner>/v<n>?sha512=<digest>` for a paper in an archive, and
  for others at least the version and a digest of the file read. This is
  the strongest argument OpenSheaf has to offer AI reading services, and it
  needs nothing new from the format. It could be written up for the FAQ or
  the use cases.
- **A resolver for agents.** An MCP server, or a plain HTTP API, over the
  resolver of `opensheaf-py` (resolve a URI, list the versions of a line,
  fetch a file checked against its pin), so that agents read archives with
  the same checks as the Explorer. It belongs with the tools and with the
  gateway question
  ([#35](https://github.com/opensheaf/opensheaf.github.io/issues/35)), not
  with the specification.
- **Publishing on alphaXiv from an archive.** A profile like the Zenodo one
  (appendix A.1): deposit a version not on arXiv, record the deposit in
  `external`, keep the alphaXiv identifier as an external label. Worth doing
  only if alphaXiv offers an API for submissions, which its pages do not
  describe.
- **Curation as collections.** A reading list, a conference's accepted
  papers or a "trending" list made into a catalogue or a selection pins what
  it lists, and can be cited and kept by others. A service could export its
  lists in that form without changing anything else.
- **Discussion.** alphaXiv shows that discussion of a precise version is
  wanted. Whether OpenSheaf should define a form for comments that pin what
  they discuss, or leave discussion to services and only define how a
  comment names a version, is for
  [#21](https://github.com/opensheaf/opensheaf.github.io/issues/21).

## 7. Experiments

- Give alphaXiv the PDF URL of a paper of an OpenSheaf archive (for
  instance one of [mgubi/papers](https://github.com/mgubi/papers)) and see
  what it reads: the metadata of the landing page (Google Scholar tags,
  JSON-LD, Signposting, appendix A.3), or only the PDF.
- Check whether alphaXiv shows an arXiv paper that is also in an OpenSheaf
  archive under one identity or two, and what it does with the
  `IsVersionOf` and `IsIdenticalTo` relations of its `datacite.json`.
- Ask its MCP server for a paper and record what identifies the bytes it
  answered from: an identifier, a version, a URL, a digest.
- Read the submission form, and whether it can take a version's licence and
  identifiers (a `sheaf:` URI as a related identifier).

## 8. Open questions

- Is AI reading a function of its own, beside the six of
  [positioning.md](positioning.md), or a form of filtering and distributing?
  Its weight in alphaXiv suggests the first.
- Does a format need to care about the scale of AI-written papers, or is
  that entirely a matter for filters?
- What would an alphaXiv-like service gain from a record it does not hold,
  enough to read archives instead of keeping its own copies?
- How much of alphaXiv's attention comes from discussion, and how much from
  AI and feeds? The answer decides whether
  [#21](https://github.com/opensheaf/opensheaf.github.io/issues/21) matters
  for adoption.

## 9. Conclusion

alphaXiv shows the bundling of [positioning.md](positioning.md) happening
again, quickly and with good intentions: a service of reading drew readers,
then took on announcement, distribution and the record, with sound rules of
its own and a promise of preservation. Its weak points are those of every
bundle: one party holds the only copy, the names and the access, and its
record is checked only by its word. OpenSheaf is weak where alphaXiv is
strong: readers, discovery, discussion, ease. The two do not compete. What
OpenSheaf can offer such a service is narrow: a way to name exactly what was
read, cited and curated, checkable by anyone, and a record that outlives any
one host. Whether services want it depends less on the format than on the
tools that make it cheap.
