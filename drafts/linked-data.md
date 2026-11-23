# Linked Data and OpenSheaf

*Working paper, draft of 22 November 2026. Non-normative: ideas and positions,
not decisions. This paper asks whether OpenSheaf conforms to Linked Data, as
the W3C describes it, and to the "five stars" of open data. It sets each
principle against the specification point by point, records what the first
archive serves today, explains where OpenSheaf departs on purpose, and
weighs ways to close the gap. It ends with proposals, experiments and open
questions.*

> [!NOTE]
> The principles are read from the W3C wiki page on Linked Data
> (<https://www.w3.org/wiki/LinkedData>) and from Tim Berners-Lee's design
> note it cites (<https://www.w3.org/DesignIssues/LinkedData.html>). What the
> first archive serves was read on 22 November 2026 from
> <https://mgubi.org/papers/>, its discovery document and one landing page;
> what the tools write was read from `literate/30-website.md` of
> `opensheaf-py`. Section numbers are those of
> [version 0.2](../opensheaf-specification-0.2.md) of the specification.

## 1. The question

Linked Data is the W3C's name for publishing structured data on the web so
that it can be followed from one thing to another and merged by programs.
Scholarly infrastructure has adopted it unevenly. DataCite and Crossref
answer DOIs with RDF and schema.org JSON-LD through content negotiation.
ORCID publishes RDF. Wikidata and the OpenAIRE Graph are built on it.
Most repositories expose only HTML and OAI-PMH, and FAIR Signposting
(<https://signposting.org/FAIR/>) was proposed as a lighter way for them to
be read by machines.

OpenSheaf names things by URIs and links them by digest across archives, so
it is natural to ask whether it is Linked Data. The short answer: in spirit
yes, by the letter no. Its names are not HTTP URIs, and its metadata is
JSON checked by JSON Schema, not RDF. Only the landing pages of the website
profile come close, with schema.org JSON-LD and Signposting, and these are
only recommended (appendix A.3).

## 2. The principles

The design note gives four rules:

1. Use URIs as names for things.
2. Use HTTP URIs so that people can look up those names.
3. When someone looks up a URI, provide useful information, using the
   standards (RDF, SPARQL).
4. Include links to other URIs, so that they can discover more things.

It adds a scale of five stars for open data: on the web under an open
licence (one star); as structured data (two); in a non-proprietary format
(three); using URIs to denote things, so that people can point at them
(four); linked to other data to provide context (five). The fourth and fifth
stars are usually read as "in RDF".

Two practices come with the rules. A URI naming a thing that is not a web
page (a person, a paper as a work) is answered with a 303 redirect to a
document describing it, or carries a fragment; this separates the thing
from its description (the "httpRange-14" resolution of the W3C TAG, 2005).
And one URI serves several representations, chosen by content negotiation:
HTML for people, Turtle or JSON-LD for programs.

## 3. Point by point

| Principle | OpenSheaf | Where |
|---|---|---|
| 1. URIs as names | **Yes.** Lines, versions, pins, works and owners are `sheaf:` URIs; people are ORCID iDs, versions may have DOIs, keepers are ORCID iDs or domains. | 12.1, 6, 4.4 |
| 2. HTTP URIs, looked up | **No, on purpose.** `sheaf:` names what a thing is, not where it is kept, and is looked up by a resolver, not by HTTP. A gateway (`https://opensheaf.org/sheaf:<name>/v3`) is provisional and open ([#35](https://github.com/opensheaf/opensheaf.github.io/issues/35)); the scheme is not yet registered ([#36](https://github.com/opensheaf/opensheaf.github.io/issues/36)). Each line has an HTTP landing page and may have a DOI. | 12.3, 12.6, A.3 |
| 3. Useful data in standard formats | **Partly.** Metadata is DataCite JSON and OpenSheaf's own JSON files, defined by JSON Schema, with no `@context`. Landing pages SHOULD carry schema.org `ScholarlyArticle` JSON-LD and Signposting links. No SPARQL. | 4.4, A.3 |
| 4. Links to other URIs | **Yes, in JSON.** `relatedIdentifiers` (`HasPart`, `IsVersionOf`, `IsIdenticalTo`, ...), member pins across archives, branch parents, ORCID iDs, Signposting. None of it is RDF. | 4.4, 8, 9, A.3 |
| Five stars | **Three, four on landing pages.** Metadata is CC0, structured, in open formats; the JSON-LD of landing pages uses URIs for things. | 15, A.3 |

**Names.** The first rule is met fully, and more strictly than most Linked
Data: a `sheaf:` URI with a digest (`sheaf:<name>/v3?sha512=...`) names
exactly one set of bytes, which no HTTP URI does. It is close to the Trusty
URIs of nanopublications (see
[federated-publishing.md](federated-publishing.md), section 3.1), which put
a digest in an HTTP URI.

**Lookup.** The second rule is where OpenSheaf departs. A `sheaf:` URI may
be found in any archive that holds a copy, and the copy is checked, not
trusted (section 12.3). An HTTP URI would tie the name to one host, which is
what the format sets out to avoid. The `at` parameter carries a location as
a hint, outside what the URI names.

**Data.** The third rule asks for RDF. OpenSheaf asks for files that can be
checked byte for byte, against schemas and digests. These are compatible:
JSON can be read as RDF through a JSON-LD context without changing a byte
(section 6.2). But nothing in the specification provides one.

**Links.** The fourth rule is met in substance. A catalogue or selection is
a list of links to other archives, each fixed by a digest; DataCite relations
link versions, works and external records. A program can follow them, but
only one that knows OpenSheaf's JSON, not a generic Linked Data client.

## 4. What the first archive serves

From <https://mgubi.org/papers/>, on 22 November 2026:

- **Landing pages** carry the Google Scholar tags, a `canonical` link, the
  Signposting links `cite-as` (the DOI, or the landing page when there is
  none), `describedby` (the `datacite.json` of the current version, typed
  `application/vnd.datacite.datacite+json`), `item` (the PDF) and `license`,
  and a schema.org `ScholarlyArticle` in JSON-LD with `name`, `url`,
  `author`, `datePublished`, `version`, `abstract`, `license`, an `encoding`
  for the PDF, and the `sheaf:` URI of the line among its `identifier`s.
- **Signposting is in HTML only.** The links are `<link>` elements; no
  `Link` HTTP header is sent, since a static host cannot set one per file.
  FAIR Signposting allows both, and HTML is level 1.
- **Authors are names only** in the JSON-LD: an ORCID iD present in
  `datacite.json` is not carried over as the author's `@id` or `sameAs`.
- **Relations stay in JSON.** `relatedIdentifiers` (here an
  `IsIdenticalTo` to the arXiv version) do not appear in the JSON-LD.
- **JSON files** are served as `application/json` with
  `Access-Control-Allow-Origin: *`, so a client can fetch them, but they
  have no `@context` and are not RDF.
- **The discovery document** lists the profile `texmacs` only, though the
  archive has landing pages; it does not declare `website`. This is a
  matter for the archive, not the format, but it means a verifier does not
  check the pages against appendix A.3.

So the archive reaches four stars on its landing pages, with a JSON-LD
record that is thin but correct, and three stars in its files.

## 5. Where OpenSheaf departs, and why

**Names without places.** The departure from the second rule is the point of
the format: a document outlives its host, is mirrored and branched, and is
found wherever a copy is. Linked Data has met the same need with
persistent HTTP URIs run by a resolver (DOIs at `doi.org`, PURLs, w3id.org),
which put one service in the middle. OpenSheaf keeps that service optional:
a gateway may give every `sheaf:` URI an HTTP form, but no name depends on
it.

**Fixity by bytes, not by graphs.** Pins, signatures and genesis records are
computed over files (sections 4, 5, 7). RDF has its own canonical form (RDF
Dataset Canonicalization, W3C 2024) and signatures over graphs (Data
Integrity), and nanopublications use them. OpenSheaf does not need them:
it fixes bytes, and anything read from the bytes, RDF included, is fixed with
them.

**Static hosting.** An archive is plain files on any web server (section 3,
[deployment.md](deployment.md)). Content negotiation, 303 redirects and
per-file `Link` headers all need a server that can be configured; GitHub
Pages and most static hosts cannot. Whatever Linked Data an archive offers
must therefore live in files and in HTML, or in a service beside the
archive (a gateway, an index).

**Schemas over vocabularies.** The JSON files are defined by JSON Schema so
that verifiers can reject what is malformed (section 14). An RDF vocabulary
says what terms mean but not what a file must contain. The two are
complementary: a context can give the meaning, the schema the shape.

## 6. Ways to close the gap

From cheapest to dearest. None changes an archive's authoritative files,
and none needs to be decided before 0.2 is final.

### 6.1 Landing pages

*Done on 23 November 2026: appendix A.3 now requires the Signposting links
and the JSON-LD record, with the contents below (#77, first point).*

Make the JSON-LD and Signposting of appendix A.3 a MUST, as the Google
Scholar tags already are, and say what the JSON-LD contains:

- the `sheaf:` URI of the line, the DOI and the concept DOI as
  `identifier`, and the gateway URL, once there is one, as `sameAs`;
- each author with an ORCID iD as `@id` (`https://orcid.org/...`);
- every document version, as `workExample` or `hasPart` entries with their
  `version`, date and DOI, or at least `isBasedOn`/`sameAs` for the
  external records of `relatedIdentifiers` (arXiv, Zenodo);
- for a collection, `@type` `Collection` with `hasPart` to the landing pages
  or DOIs of its members.

DataCite publishes a crosswalk from its schema to schema.org, which the
tools can follow rather than invent one. Cost: a few lines in the tools,
one paragraph in A.3.

### 6.2 A JSON-LD context for OpenSheaf's files

Publish, beside the schemas, a context
(`https://opensheaf.org/contexts/opensheaf-0.2.jsonld`) mapping the fields of
`object.json`, `members.json`, the discovery document and the key log to
terms of existing vocabularies (DataCite's ontology or schema.org,
Dublin Core, PROV-O for branches and derivations, FaBiO for work and
version). A JSON-LD processor could then read the files as RDF. There are
three ways to attach it:

- **An `@context` field in each file.** Simplest for clients, but it adds a
  field to every authoritative file, enters genesis records and signatures
  where those files are signed, and makes every file depend on the meaning of
  a document at a URL. Possible while 0.2 is a draft; not recommended.
- **An HTTP `Link` header** with `rel="http://www.w3.org/ns/json-ld#context"`.
  The JSON-LD way of attaching a context to plain JSON, but static hosts
  cannot send it (section 5).
- **Presentation files.** The website profile writes, beside each landing
  page, an `index.jsonld` (or embeds it in the page) generated from the
  object's files, as it already writes the JSON-LD of the page. It is not
  authoritative and can change without a new version. Recommended.

### 6.3 A gateway with content negotiation

The gateway of section 12.6 is where `sheaf:` URIs become HTTP URIs. If the
project runs one (#35), it can follow the Linked Data practice: answer
`text/html` with a page, `application/ld+json` or `text/turtle` with the
description of what it resolved, generated from the checked files, and use
303 for a URI naming a work or an owner, which are not documents. Section
12.6 already allows 303 and forbids permanent redirects, which fits. The
gateway URL then is the HTTP name of the thing, `owl:sameAs` its `sheaf:`
URI. Cost: running a service, which the project has not decided to do.

### 6.4 Vocabularies for what OpenSheaf adds

Some of OpenSheaf's notions have no term in common vocabularies: a line as
opposed to a work, a pin, an owner with a key log, an accepted copy, a
selection that vets versions. Mapping them would need a small OpenSheaf
vocabulary, or a choice among FRBR-like models (FaBiO's `Work`,
`Expression`, `Manifestation`) that fit only roughly. This is the dearest
step, and the one most likely to be wrong if done before the format is final.

### 6.5 Announcements and relations

Two neighbouring questions already have Linked Data answers, discussed
elsewhere: Linked Data Notifications and COAR Notify for announcing versions
and reviews to inboxes ([positioning.md](positioning.md)), and
nanopublications for relations between documents, as one answer to
[#21](https://github.com/opensheaf/opensheaf.github.io/issues/21)
([federated-publishing.md](federated-publishing.md)). Both sit beside the
archive and need nothing of its files.

## 7. Evaluation

**What conformance would buy.** Records that aggregators built on RDF can
take without a custom harvester: Wikidata and Scholia, the OpenAIRE Graph,
knowledge graphs of research software and data. Search engines already read
the schema.org JSON-LD, which is where most of the practical value lies.

**What it would cost.** Normative RDF would bring a second definition of
every file, a dependence on vocabularies OpenSheaf does not control, and
service requirements (content negotiation, 303) that static archives cannot
meet. Its strengths, fixity, verification and independence from hosts,
owe nothing to RDF.

**Position.** OpenSheaf should not claim Linked Data conformance, and should
not make RDF normative. It can honestly claim to be linked-data friendly:
location-independent URIs for everything it names, links fixed by digest,
and, on landing pages, schema.org JSON-LD and Signposting. Sections 6.1 and
6.2 (as presentation files) make that claim firm at little cost; section 6.3
follows if the project runs a gateway.

## 8. Proposals

- Make schema.org JSON-LD and FAIR Signposting a MUST of the website
  profile, with the contents listed in section 6.1, following DataCite's
  crosswalk to schema.org.
- Carry ORCID iDs as `@id` of authors, and `relatedIdentifiers` as
  `sameAs`/`isBasedOn`, in the JSON-LD the tools write.
- Publish a JSON-LD context for the files of 0.2, used only by
  presentation files (`index.jsonld` beside landing pages), never inside
  the storage root.
- If the project runs a gateway (#35), give it content negotiation and 303
  for works and owners.
- Add a FAQ entry, "Is OpenSheaf Linked Data?", with the short answer of
  section 1.

## 9. Experiments

- Run the landing pages of <https://mgubi.org/papers/> through the
  Signposting validator (`signposting.org`) and a schema.org validator, and
  record what they report.
- Write a draft context for `object.json` and `members.json`, expand a few
  files with a JSON-LD processor (`pyld`), and see which fields have no
  sensible term.
- Load the expanded records of the first archive and of a catalogue into a
  triple store, and write the SPARQL query a reader would want ("every
  version of every member of this selection, with its DOI"), to see whether
  RDF makes it simpler than reading the JSON.
- Compare with what `doi.org` returns for the same papers'
  DOIs under `Accept: application/ld+json`.

## 10. Open questions

- Should the website profile require Signposting in HTTP `Link` headers
  where the host allows, as FAIR Signposting level 1 recommends for
  non-HTML resources (PDFs, JSON files)?
- Which HTTP URI should a Linked Data client use for a line: the landing
  page (one archive's), the DOI (one version's), or a gateway URL (one
  service's)? Each ties the name to a party OpenSheaf means to make
  optional.
- Should the context be versioned with the format (`opensheaf-0.2.jsonld`),
  and fixed once 0.2 is final?
- Is a vocabulary for lines, pins and owners worth defining, or should
  OpenSheaf stay with schema.org and DataCite and leave its own notions in
  its own JSON?

## References

- T. Berners-Lee, "Linked Data", Design Issues, 2006, revised 2009:
  <https://www.w3.org/DesignIssues/LinkedData.html>.
- W3C wiki, "LinkedData": <https://www.w3.org/wiki/LinkedData>.
- W3C TAG, "httpRange-14" resolution, 2005, and "Cool URIs for the
  Semantic Web", W3C Interest Group Note, 2008:
  <https://www.w3.org/TR/cooluris/>.
- JSON-LD 1.1, W3C Recommendation, 2020:
  <https://www.w3.org/TR/json-ld11/>.
- RDF Dataset Canonicalization, W3C Recommendation, 2024:
  <https://www.w3.org/TR/rdf-canon/>.
- FAIR Signposting profile: <https://signposting.org/FAIR/>.
- schema.org `ScholarlyArticle`: <https://schema.org/ScholarlyArticle>.
- DataCite content negotiation:
  <https://support.datacite.org/docs/datacite-content-resolver>.
- FaBiO, the FRBR-aligned Bibliographic Ontology:
  <http://purl.org/spar/fabio>.
- PROV-O, W3C Recommendation, 2013: <https://www.w3.org/TR/prov-o/>.
- Linked Data Notifications, W3C Recommendation, 2017:
  <https://www.w3.org/TR/ldn/>.
