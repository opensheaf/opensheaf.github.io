# FAIR and OpenSheaf

*Working paper, draft of 22 November 2026, revised 23 November 2026. Non-normative: ideas and positions,
not decisions. The FAIR principles ask that research outputs be Findable,
Accessible, Interoperable and Reusable, by people and above all by machines.
This paper surveys the principles and the work built on them (the RDA
maturity model, automated assessment, FAIR Signposting, FAIR Digital
Objects, FAIR for research software, the TRUST principles for repositories),
sets each of the fifteen principles against the specification, records
where OpenSheaf is strong, where it is weak and where it departs on purpose,
and ends with proposals, experiments and open questions. It is a companion
to [linked-data.md](linked-data.md), which treats the interoperability
principles at greater length.*

> [!NOTE]
> **Revised 23 November 2026.** Most proposals of section 6 are now in the
> specification ([#79](https://github.com/opensheaf/opensheaf.github.io/issues/79),
> and the first point of
> [#77](https://github.com/opensheaf/opensheaf.github.io/issues/77)): a
> rights entry is required, the website profile requires Signposting and
> JSON-LD with listed contents, and section 3 asks a public archive to be
> indexed. The table of section 3 and section 6 say what changed; the rest
> of the paper is as first written.

> [!NOTE]
> The principles are quoted from Wilkinson and others, "The FAIR Guiding
> Principles for scientific data management and stewardship", *Scientific
> Data* 3, 160018 (2016), and from the GO FAIR pages
> (<https://www.go-fair.org/fair-principles/>). The other sources are listed
> at the end. No assessment tool was run for this draft; section 7 proposes
> to run them. Section numbers are those of
> [version 0.2](../opensheaf-specification-0.2.md) of the specification.

## 1. The principles

The FAIR principles were published in 2016 by a group from academia,
industry, funders and publishers, after a workshop in Leiden in 2014. They
are fifteen short statements, grouped under four letters. They name
qualities, not technologies: they do not require RDF, a repository or open
access, though they are often read as requiring the first. Their emphasis is
on **machine-actionability**: a program, not only a person, should be able to
find an output, know how to get it, read its metadata and know whether it
may reuse it.

**Findable.**

- F1. (Meta)data are assigned a globally unique and persistent identifier.
- F2. Data are described with rich metadata (defined by R1 below).
- F3. Metadata clearly and explicitly include the identifier of the data
  they describe.
- F4. (Meta)data are registered or indexed in a searchable resource.

**Accessible.**

- A1. (Meta)data are retrievable by their identifier using a standardised
  communications protocol.
  - A1.1. The protocol is open, free and universally implementable.
  - A1.2. The protocol allows for an authentication and authorisation
    procedure, where necessary.
- A2. Metadata are accessible, even when the data are no longer available.

**Interoperable.**

- I1. (Meta)data use a formal, accessible, shared and broadly applicable
  language for knowledge representation.
- I2. (Meta)data use vocabularies that follow FAIR principles.
- I3. (Meta)data include qualified references to other (meta)data.

**Reusable.**

- R1. (Meta)data are richly described with a plurality of accurate and
  relevant attributes.
  - R1.1. (Meta)data are released with a clear and accessible data usage
    licence.
  - R1.2. (Meta)data are associated with detailed provenance.
  - R1.3. (Meta)data meet domain-relevant community standards.

FAIR is not open: a closed output with clear access conditions can be FAIR,
and an open PDF without metadata is not. The principles were written for
data, but are applied to every research output, papers included.

## 2. The work built on them

- **The RDA FAIR Data Maturity Model** (Research Data Alliance, 2020) turns
  the principles into 41 indicators, each *essential*, *important* or
  *useful*, with levels from 0 (not FAIR) to 4. It is the common basis of
  assessments, and the indicators below are read from it.
- **Automated assessment.** F-UJI (FAIRsFAIR, PANGAEA) and the FAIR Evaluator
  (FAIR Metrics group) test an output from its identifier: they resolve it,
  look for metadata in the landing page (embedded JSON-LD, Signposting,
  `citation_*` tags), in content negotiation, and in DataCite or Crossref,
  and score each principle. They recognise a fixed list of identifier
  schemes (DOI, Handle, ARK, PURL, w3id, URN and others). What they cannot
  see, they score as absent.
- **FAIR Signposting** (Van de Sompel and others, 2022) is a light way to
  meet F and A on the web: typed links (`cite-as`, `describedby`, `item`,
  `license`, `type`, `author`) from a landing page, in HTML or HTTP headers.
  It is designed for repositories that cannot offer full Linked Data, and the
  automated tools read it.
- **FAIR Digital Objects** (FDO Forum, from 2019) describe an output as an
  object with a persistent identifier that resolves to a record of its type,
  metadata and bit sequence, with operations defined by type. The
  identifiers are usually Handles.
- **FAIR for Research Software** (FAIR4RS, Barker and others, 2022) adapts
  the principles to software: identifiers for each version, metadata for
  dependencies, provenance and licence, reuse by execution and modification.
- **The TRUST principles** (Lin and others, 2020) apply to repositories, not
  outputs: Transparency, Responsibility, User focus, Sustainability,
  Technology. CoreTrustSeal certifies repositories against them.
- **The CARE principles** (Global Indigenous Data Alliance, 2019) add
  collective benefit, authority to control, responsibility and ethics, for
  data concerning indigenous peoples. They touch scholarly papers little,
  and are not treated further here.

## 3. Point by point

| Principle | OpenSheaf | Where |
|---|---|---|
| F1 Persistent identifier | **Strong, but not recognised.** `sheaf:` URIs are unique by construction (digests) and do not depend on a host; a pin names one set of bytes. Not a registered scheme (#36), no common resolver (#35, #20). DOIs only under the Zenodo profile. | 5, 12, A.1 |
| F2 Rich metadata | **Yes.** DataCite 4.7 in `datacite.json`, with `object.json` (sources, renditions, toolchain, stage, history, notices). | 4.3, 4.4 |
| F3 Metadata include the identifier | **Yes.** `object.json` has `name` and `owner`; `datacite.json` has `doi`, `url` and the `sheaf:` URI as a related `URL`; metadata and data are fixed together by one inventory. | 4.3, 4.4 |
| F4 Indexed in a searchable resource | **Recommended.** Indexes are maps for resolvers, not search services. A public archive SHOULD be indexed, through the website profile (search engines, Google Scholar), the Zenodo profile (DataCite) or an OAI-PMH static repository. Discovery itself is outside the specification. | 3, 12.5, A.1, A.3 |
| A1 Retrievable by identifier, standard protocol | **Partly.** Files are fetched over HTTPS, but a `sheaf:` URI is retrieved by an OpenSheaf resolver, not by a generic client. A DOI or a landing page is retrieved by any client. | 3, 12.3 |
| A1.1 Open, free protocol | **Yes.** HTTPS, plain files, cross-origin requests. | 3, 15.3 |
| A1.2 Authentication where necessary | **Yes, outside the format.** Private archives, and archives served to some readers only, follow the specification all the same; access control is the host's. | 3.1 |
| A2 Metadata outlive the data | **Partly.** A withdrawn line keeps all its versions and metadata. A takedown leaves a tombstone with only name, owner, pin, date and reason, by design. Collections cache a citation of each member (`cite`); mirrors and Zenodo records keep metadata elsewhere. | 8.2, 13 |
| I1 Formal shared language | **Partly.** JSON with JSON Schema and the DataCite schema: formal, shared, open; not RDF. Schema.org JSON-LD and Signposting on landing pages (MUST, under the website profile). | 4.4, A.3 |
| I2 FAIR vocabularies | **Largely.** DataCite's controlled lists, SPDX, NISO-JAV, media types, MSC2020, ORCID, ROR. OpenSheaf's own terms are defined in the specification, not published as a vocabulary. | 4.3, 4.4 |
| I3 Qualified references | **Yes, in JSON.** `relatedIdentifiers` with `relationType`; member pins; `parent` with its evidence; `external` with `role`. | 4.4, 8, 9 |
| R1 Plurality of attributes | **Yes.** | 4.3, 4.4 |
| R1.1 Clear licence | **Yes.** `rightsList` is required, with at least one licence or rights statement ("All rights reserved", or that the rights are not known). Metadata is CC0. | 4.4, 15.6 |
| R1.2 Detailed provenance | **Strong.** Depositor, date and message of every version; signatures by the owner; key logs; change notes, history and notices; branches with evidence of their parent; external records; toolchain; agreement. Not expressed in PROV. | 4, 6, 7, 9 |
| R1.3 Community standards | **Yes.** OCFL 1.1, DataCite 4.7, SPDX, NISO-JAV, Google Scholar, Signposting; a TeXmacs profile. | 4, A |

## 4. Reading the table

### 4.1 Where OpenSheaf is strong

**Identity and fixity (F1, F3).** Most FAIR identifiers are persistent by
promise: a DOI persists because a registration agency and a publisher keep it
pointing somewhere. A `sheaf:` URI with a pin persists by construction: it
names bytes, and any copy that matches is the thing. The identifier of the
data is inside the metadata, and both are fixed by the same inventory, so
that metadata cannot drift from what it describes. This is stronger than
F1 and F3 ask.

**Provenance (R1.2).** Few repositories record more than a deposit date and
an account. OpenSheaf records who deposited each version and why, signs
each version with its owner's keys, keeps the history of the keys, records
what changed, links branches to the exact version they continue, and lists
the external records that witness each version. The FAIR4RS reading of R1.2
(the provenance of each version) is met fully.

**Reuse of the content (R1, FAIR4RS).** Most FAIR assessments of papers stop
at the metadata. OpenSheaf keeps the sources of each version with a
`toolchain` "enough to reproduce the renditions", and says so when the
sources are missing. Reuse of a paper as a source, not only as a PDF, is
what the R of FAIR aims at, and what preprint servers mostly do not offer.

**Metadata under CC0 (R1.1 for metadata).** Inventories, key logs,
member lists and descriptions are CC0, so that they can be harvested and
mirrored freely, which many publishers' metadata are not.

### 4.2 Where OpenSheaf is weak

**Recognition of the identifier (F1, A1).** Assessors and aggregators
recognise registered schemes resolved by a known service. `sheaf:` is
neither, yet. An output with only a `sheaf:` URI and a landing page would
score low on F1 with an automated tool, whatever its real persistence. An
output with a DOI (Zenodo profile) scores as any DataCite record does.

**Findability (F4).** The specification leaves discovery out on purpose, and
a public archive without the website profile is indexed by nobody. With the
profile it is found by Google Scholar and search engines; with the Zenodo
profile, by DataCite's search and the aggregators fed from it (OpenAIRE,
BASE). F4 is met by the profiles, not by the format.

**The licence (R1.1).** A document version may have no `rightsList` at all.
FAIR does not require an open licence, but it requires a clear one, and
the maturity model counts a missing licence as an essential failure. "All
rights reserved" is clear; silence is not.

**Machine-readable vocabularies (I1, I2).** The metadata is formal and
shared, but in JSON whose meaning is in prose (DataCite's documentation,
this specification). The maturity model accepts this at its lower levels;
higher levels, and assessors, look for RDF or schema.org. See
[linked-data.md](linked-data.md) and
[#77](https://github.com/opensheaf/opensheaf.github.io/issues/77).

### 4.3 Where OpenSheaf departs on purpose

**A2 and takedowns.** A2 asks that metadata stay when the data goes. A
withdrawal meets it fully: nothing is removed, and the withdrawal is shown
with its reason. A takedown does not: its tombstone keeps names and a pin
but SHOULD NOT repeat what was taken down, since a takedown may be for
erasure of personal data or by law (sections 13.2, 13.3, 15.5). This is the
reading of A2 most repositories adopt too (a takedown for legal reasons
removes the metadata), and the cached citations of collections and the
records of mirrors and Zenodo keep metadata where they lawfully can.

**Persistence without a resolver (F1, A1).** OpenSheaf does not want one
service in the middle of every lookup. FAIR does not require one either,
but its tools assume one. A gateway (#35) would give `sheaf:` URIs the HTTP
form that tools expect, without making names depend on it.

**Outputs, not repositories (TRUST).** FAIR assessment of an output often
leans on the repository that holds it (CoreTrustSeal, re3data). An
OpenSheaf archive kept by one person will not be certified. The format
answers sustainability differently: mirrors, accepted copies, external
records on Zenodo and Software Heritage, and verification by anyone. Whether
assessors should credit this is an open question for them, not for
OpenSheaf.

### 4.4 FAIR Digital Objects

An OpenSheaf object is close to a FAIR Digital Object: an identifier (the
`sheaf:` URI), a type (`kind`, and `format` naming the schema of each JSON
file), metadata (`datacite.json`, `object.json`) and a bit sequence fixed by
digests. What it lacks is the FDO resolution model: an identifier resolving,
through a known service, to a record of these. A gateway or an index
answering a `sheaf:` URI with a small typed record would make each object an
FDO; whether that is worth the dependence is the question of #35.

## 5. Evaluation

On the substance of the principles, OpenSheaf is among the more FAIR ways
to keep scholarly documents: identifiers stronger than F1 asks, metadata
fixed with the data, provenance far beyond the usual, sources kept for
reuse, metadata under CC0. On the tests that measure FAIRness in practice,
it would score lower than its substance, for three reasons it can partly
remove: an unregistered identifier scheme without a resolver, findability
left to optional profiles, and a licence that may be absent. The
interoperability gap (JSON rather than RDF) is shared with most repositories
and is narrowed by the schema.org JSON-LD of landing pages.

An archive that follows the Zenodo and website profiles is, in practice, as
FAIR as a Zenodo record, since it is one, plus everything Zenodo does not
record. An archive that follows neither is FAIR in substance and hard to
see.

## 6. Proposals

Status on 23 November 2026: the first four are in the specification
(#79, #77); the PROV-O mapping belongs to the JSON-LD context still open in
#77; the FAQ entry is written.

- **Require a rights entry.** Make `rightsList` in `datacite.json`
  REQUIRED, with at least one licence or rights statement, so that R1.1 is
  never silent. This changes what a valid archive is, and would need to be
  decided before 0.2 is final.
- **Strengthen the website profile** as proposed in
  [#77](https://github.com/opensheaf/opensheaf.github.io/issues/77):
  Signposting and schema.org JSON-LD required, with ORCID iDs, licences,
  versions and relations. These are what automated assessors read, and they
  cover F1, F3, A1, I1 and R1.1 for a landing page.
- **Add `type` to Signposting** (`<link rel="type"
  href="https://schema.org/ScholarlyArticle">`) and `author` links to ORCID
  iDs, which FAIR Signposting defines and the tools do not yet write.
- **Recommend a path to F4**: that a public archive follow the website
  profile, or the Zenodo profile, or publish an OAI-PMH static repository
  for aggregators such as BASE and OpenAIRE.
- **Register the scheme and settle the gateway** (#36, #35), the two steps
  that make `sheaf:` URIs recognisable identifiers for assessors and FDO
  infrastructure.
- **Map provenance to PROV-O** in the JSON-LD context proposed in #77, so
  that R1.2 is visible to machines, not only to OpenSheaf's tools.
- **A FAQ entry**, "Is OpenSheaf FAIR?", with the short answer of
  section 5.

## 7. Experiments

- Run F-UJI and the FAIR Evaluator on a landing page of
  <https://mgubi.org/papers/>, on the same paper's arXiv identifier, and on
  a paper of the archive with a Zenodo DOI; record the scores principle by
  principle, and which gaps come from the format, which from the archive,
  and which from the tools.
- Repeat after the changes of #77, to see what they buy.
- Score one object by hand against the 41 indicators of the RDA maturity
  model, including those the automated tools cannot test (provenance,
  sources, fixity).
- Check whether OpenAIRE and BASE can harvest an OpenSheaf archive through a
  static OAI-PMH repository written by the tools.

## 8. Open questions

- Should `rightsList` be required (section 6), and is "All rights reserved"
  then enough, as FAIR allows?
- Should a tombstone OPTIONALLY keep a citation (title, creators, year) when
  the takedown is not for personal data or by law, so that A2 holds for
  lines an archive merely stops keeping, or is that the job of the
  collections and mirrors that cite them?
- Should the specification say anything about findability (F4), or leave
  it, as now, to the profiles and to services built on top?
- Is it worth registering `sheaf:` with a FAIR-facing service (a Handle
  prefix, w3id.org redirects to a gateway) for recognition, at the cost of a
  dependence?
- How should assessors credit preservation by mirrors and external records,
  which no repository certification covers?

## References

- M. D. Wilkinson and others, "The FAIR Guiding Principles for scientific
  data management and stewardship", *Scientific Data* 3, 160018 (2016):
  <https://doi.org/10.1038/sdata.2016.18>.
- GO FAIR, "FAIR Principles": <https://www.go-fair.org/fair-principles/>.
- RDA FAIR Data Maturity Model Working Group, "FAIR Data Maturity Model:
  specification and guidelines" (2020):
  <https://doi.org/10.15497/rda00050>.
- A. Devaraju and R. Huber, F-UJI, an automated FAIR data assessment tool:
  <https://www.f-uji.net/>.
- M. D. Wilkinson and others, "Evaluating FAIR maturity through a scalable,
  automated, community-governed framework", *Scientific Data* 6, 174
  (2019): <https://doi.org/10.1038/s41597-019-0184-5>.
- FAIR Signposting profile: <https://signposting.org/FAIR/>.
- FAIR Digital Objects Forum: <https://fairdo.org/>.
- M. Barker and others, "Introducing the FAIR Principles for research
  software", *Scientific Data* 9, 622 (2022):
  <https://doi.org/10.1038/s41597-022-01710-x>.
- D. Lin and others, "The TRUST Principles for digital repositories",
  *Scientific Data* 7, 144 (2020):
  <https://doi.org/10.1038/s41597-020-0486-7>.
- CoreTrustSeal: <https://www.coretrustseal.org/>.
- CARE Principles for Indigenous Data Governance:
  <https://www.gida-global.org/care>.
- PROV-O, W3C Recommendation, 2013: <https://www.w3.org/TR/prov-o/>.
