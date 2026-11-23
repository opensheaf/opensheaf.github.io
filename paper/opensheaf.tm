<TeXmacs|2.1.5>

<style|<tuple|article|opensheaf-paper|british>>

<\body>
  <\hide-preamble>
    <new-figure|listing|Listing>
  </hide-preamble>

  <doc-data|<doc-title|OpenSheaf: an exchange layer for scholarly
  documents>|<doc-author|<author-data|<author-name|Massimiliano
  Gubinelli>|<author-affiliation|University of Oxford>>>|<doc-date|22
  November 2026>>

  <abstract-data|<\abstract>
    Scholarly communication bundles several functions: recording, preserving,
    announcing, filtering, distributing and assigning merit. Preprint servers
    and publishers each hold a bundle of them, and the case for separating
    them is old. We argue that what has been missing is a common, verifiable
    form in which separate parties exchange documents and statements about
    them: an exchange layer. OpenSheaf is a format for that layer. An archive
    is a set of plain files on a static web server, stored in OCFL 1.1 and
    described in DataCite 4.7. Every version of a document is fixed by
    SHA-512 inventories and pinned by the digest of its inventory. Works and
    owners are named by digests of genesis records, independently of hosts
    and keys. Owners are keyed identities whose key logs use pre-rotation,
    and they sign every version of their lines. Collections, which pin
    versions of documents held in any archive, are objects of the same
    format. Any copy can be checked anywhere. We describe version 0.2 of the
    specification, a draft; its reference tools; a formal model in Lean; and
    a first archive of 83 documents. We compare OpenSheaf with some thirty
    earlier designs. Most of its parts exist elsewhere; their combination was
    not found. Adoption, incentives, key management and discovery remain
    open.
  </abstract>|<abstract-keywords|scholarly communication|digital
  preservation|content addressing|signatures|key
  rotation|OCFL|DataCite|overlay journals>>

  <\with|par-columns|2>
    <section|Introduction><label|sec:intro>

    A classic analysis of scientific communication distinguishes
    registration, awareness, certification and archiving
    <cite|roosendaal1997>; Van de Sompel and others add rewarding
    <cite|vandesompel2004>. We use a division closer to what the actors of
    today do: to <dfn|record> (fix every version of a work and name it), to
    <dfn|preserve>, to <dfn|announce>, to <dfn|filter> (select what deserves
    attention and vouch for it), to <dfn|distribute> and to <dfn|assign
    merit>. Table <reference|tab:functions> summarises what each function
    needs and who holds it today.

    <big-table|<with|font-size|0.84|<tformat|<twith|table-width|1par>|<twith|table-hmode|exact>|<cwith|1|-1|1|-1|cell-hyphen|t>|<cwith|1|-1|1|-1|cell-valign|top>|<cwith|1|-1|1|-1|cell-halign|l>|<cwith|1|-1|1|-1|cell-lsep|0.3em>|<cwith|1|-1|1|-1|cell-rsep|0.3em>|<cwith|1|1|1|-1|font-series|bold>|<cwith|3|3|1|-1|cell-background|#f2f4f7>|<cwith|5|5|1|-1|cell-background|#f2f4f7>|<cwith|7|7|1|-1|cell-background|#f2f4f7>|<cwith|1|1|1|-1|cell-background|#dde4ee>|<cwith|1|-1|1|-1|cell-tsep|0.25em>|<cwith|1|-1|1|-1|cell-bsep|0.25em>|<cwith|1|1|1|-1|cell-tborder|1ln>|<cwith|1|1|1|-1|cell-bborder|0.5ln>|<cwith|-1|-1|1|-1|cell-bborder|1ln>|<cwith|1|-1|1|1|cell-hpart|1>|<cwith|1|-1|2|2|cell-hpart|1>|<cwith|1|-1|3|3|cell-hpart|1>|<table|<row|<cell|<with|par-mode|left|Function>>|<cell|<with|par-mode|left|Needs>>|<cell|<with|par-mode|left|Held
    today by>>>|<row|<cell|<with|par-mode|left|Record>>|<cell|<with|par-mode|left|fixity>>|<cell|<with|par-mode|left|arXiv,
    repositories, Zenodo, publishers>>>|<row|<cell|<with|par-mode|left|Preserve>>|<cell|<with|par-mode|left|institutions
    that last>>|<cell|<with|par-mode|left|repositories, LOCKSS, CLOCKSS,
    arXiv>>>|<row|<cell|<with|par-mode|left|Announce>>|<cell|<with|par-mode|left|speed>>|<cell|<with|par-mode|left|arXiv
    listings, mailing lists, social networks>>>|<row|<cell|<with|par-mode|left|Filter>>|<cell|<with|par-mode|left|judgement,
    a community that trusts it>>|<cell|<with|par-mode|left|journals,
    overlays, PCI, SciPost>>>|<row|<cell|<with|par-mode|left|Distribute>>|<cell|<with|par-mode|left|bandwidth,
    formats>>|<cell|<with|par-mode|left|servers, publishers,
    indexes>>>|<row|<cell|<with|par-mode|left|Assign
    merit>>|<cell|<with|par-mode|left|evidence others can
    check>>|<cell|<with|par-mode|left|journals, citation indexes>>>>>>|The
    functions of scholarly communication.<label|tab:functions>>

    The functions have different costs, time scales and people, yet they are
    bundled: a publisher that holds the filter, which authors need for merit,
    also obtains the record and the distribution. The case for separating
    them is old: the deconstructed journal <cite|smith1999>, the distributed
    system of Van de Sompel and others <cite|vandesompel2004>, the decoupled
    journal <cite|priem2012>, the repository community's Pubfair
    <cite|pubfair2019>. Unbundled actors exist. Overlay journals, Peer
    Community In and SciPost vet documents that stay where their authors put
    them. But they rest on archives they do not control: a selection of arXiv
    papers can name the version it vetted
    (<verbatim|arXiv:<line-break>NNNN.<line-break>NNNNNv2>), yet only arXiv
    vouches for the bytes behind that name, and none of the overlays we
    examined publishes a digest of the version it vetted
    <cite|elife|pci|episciences>. Beyond the archives, the links of scholarly
    articles rot and their targets drift <cite|klein2014|jones2016>.

    Our thesis is that what has been missing is a common form in which
    separated parties exchange what they handle, so that each can rely on
    what the others did without asking them: an <dfn|exchange layer>. It is
    not a transport; HTTP, git or any copy moves the bytes. It is a narrow
    waist, with any host below it (a static web server, a forge, a
    repository, a preservation network) and any service above it (an
    announcement service, a journal, an index). It defines how a version of a
    document is fixed, named, found and checked, and how statements about
    documents are expressed. It defines the forms of statements, not the
    acts: a selection is the form in which a filter states what it vetted,
    but who filters, and by what standard, is not its business.

    OpenSheaf is a proposal for that layer <cite|spec02>. This paper
    describes it as of 22 November 2026. Version 0.2 of the specification is
    a draft, incompatible with version 0.1; archives made with the draft are
    rebuilt when 0.2 is final (specification, section 16.1). We present the
    principles of the layer (Section <reference|sec:principles>), the format
    (Section <reference|sec:format>), an implementation with reference tools,
    a formal model in Lean and a first archive (Section
    <reference|sec:impl>), and a comparison with some thirty earlier designs,
    which shows what is new and what is not (Section
    <reference|sec:related>). Section <reference|sec:eval> discusses
    limitations and open questions.

    <section|Design principles><label|sec:principles>

    Two meta-principles shape the rest. <strong|Standards first:> storage
    follows the Oxford Common File Layout (OCFL 1.1) <cite|ocfl> and
    description the DataCite Metadata Schema 4.7 <cite|datacite>; OpenSheaf
    defines only what they leave open. <strong|A minimal core:> richer
    structures are built on top, by links, DataCite relations or extensions
    (specification, appendix D.1). Eight principles follow.

    <paragraph|Fixity by digests>Every file of a version is fixed by its
    SHA-512 digest in an OCFL inventory, and every inventory by its own
    digest. A version never changes once deposited; corrections are new
    versions.

    <paragraph|Names independent of hosts and keys>A work is named by the
    digest of a small file written when it is sealed, its genesis record,
    which every copy carries. The name holds in every archive and survives a
    change of keys.

    <paragraph|Authority in owners' keys, not in hosts>Each history of a work
    belongs to an <dfn|owner>, a person, group or institution holding keys,
    who signs its versions. An archive hosts what owners write there and
    copies what others wrote elsewhere; it decides nothing about what is
    authentic.

    <paragraph|Statements are objects of the same format>A collection, which
    states that a set of versions belongs together or was vetted, is itself a
    versioned, signed object, pinning its members by digest. A document never
    states the collections that include it.

    <paragraph|Static files only>An archive is files on any static web
    server: no server software, database, chain, token or registry is needed
    to keep or to read one.

    <paragraph|Copies checkable anywhere>Every location is a hint. What is
    fetched is checked against digests and signatures, so a wrong location
    gives a reader nothing, or an older valid copy, never a forged one
    (specification, section 3).

    <paragraph|Append-only history>Nothing deposited is changed or removed,
    except in a draft and by a takedown. Descriptions, notices, withdrawals
    and key changes are new versions.

    <paragraph|Archives answer for their own rights>An archive that keeps a
    copy of another owner's work is responsible for having the right to
    redistribute it. The format does not judge it, and metadata are under CC0
    so that pins, signatures and key logs can always be copied
    (specification, sections 11.2 and 15.6).

    <section|The format><label|sec:format>

    This section summarises version 0.2 <cite|spec02>, which is
    authoritative. Its appendix C follows one paper of the first archive
    through an illustrative history: the owner, the dates, the journal, the
    DOIs, the Zenodo record and the ORCID iD are invented or placeholders,
    and the names, keys, digests and signatures are computed from them. The
    listings below are taken from it, with long digests and keys shortened in
    the middle.

    <subsection|Archives and the discovery document><label|sec:archives>

    An <dfn|archive> is a host of objects, served at a base URL. Its base URL
    is a location, not a name: no file of an object names the archive that
    holds it, and an archive may be served at several base URLs
    (specification, section 3). It consists of a discovery document and a
    storage root, both required; indexes, recommended; and presentation
    files, such as a website, never authoritative. Files are served byte for
    byte, and should be readable across origins, so that tools in a browser
    can check them.

    The <dfn|discovery document>, <no-break-start><verbatim|opensheaf.json><no-break-end>,
    exists because static web servers cannot list folders (Listing
    <reference|lst:discovery>). It names the storage root and its layout, the
    profiles followed, the owners hosted with their owner catalogues, every
    object but drafts with its head version, the digest of its head inventory
    and its status, and the tombstones of objects taken down. Beyond about a
    thousand objects the list moves into pages. It is a map, not a witness:
    verifiers check it against the storage root (specification, section 3.1).
    A <dfn|label> is a readable name the archive may give a line for its
    website, never an identifier.

    <\big-listing>
      <\os-code>
        <os-pun|{>

        \ \ <os-key|"format"><os-pun|:> <os-str|"opensheaf-archive/0.2"><os-pun|,>

        \ \ <os-key|"specification"><os-pun|:> <os-str|"0.2"><os-pun|,>

        \ \ <os-key|"name"><os-pun|:> <os-str|"Papers of Massimiliano
        Gubinelli"><os-pun|,>

        \ \ <os-key|"storageRoot"><os-pun|:> <os-str|"ocfl/"><os-pun|,>

        \ \ <os-key|"storageLayout"><os-pun|:>

        \ \ \ \ <os-str|"opensheaf-owner-name-storage-layout"><os-pun|,>

        \ \ <os-key|"profiles"><os-pun|:>

        \ \ \ \ <os-pun|[> <os-str|"zenodo"><os-pun|,>
        <os-str|"texmacs"><os-pun|,> <os-str|"website"> <os-pun|]><os-pun|,>

        \ \ <os-key|"owners"><os-pun|:> <os-pun|[> <os-pun|{>

        \ \ \ \ <os-key|"owner"><os-pun|:>
        <os-str|"56wo6cdp.<no-break>.<no-break>.z3pa"><os-pun|,>

        \ \ \ \ <os-key|"catalogue"><os-pun|:>

        \ \ \ \ \ \ <os-str|"sheaf:kdye5s4i.<no-break>.<no-break>.kxeq:56wo6cdp.<no-break>.<no-break>.z3pa">

        \ \ <os-pun|}> <os-pun|]><os-pun|,>

        \ \ <os-key|"indexes"><os-pun|:> <os-pun|{>
        <os-key|"names"><os-pun|:> 2<os-pun|,> <os-key|"owners"><os-pun|:>
        2<os-pun|,>

        \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ <os-key|"sha512"><os-pun|:> 2
        <os-pun|}><os-pun|,>

        \ \ <os-key|"objects"><os-pun|:> <os-pun|[>
        <os-pun|.<no-break>.<no-break>.><os-pun|,> <os-pun|{>

        \ \ \ \ <os-key|"id"><os-pun|:>

        \ \ \ \ \ \ <os-str|"sheaf:zzgdggwl.<no-break>.<no-break>.oz4q:56wo6cdp.<no-break>.<no-break>.z3pa"><os-pun|,>

        \ \ \ \ <os-key|"kind"><os-pun|:> <os-str|"document"><os-pun|,>

        \ \ \ \ <os-key|"name"><os-pun|:>
        <os-str|"zzgdggwl.<no-break>.<no-break>.oz4q"><os-pun|,>

        \ \ \ \ <os-key|"owner"><os-pun|:>
        <os-str|"56wo6cdp.<no-break>.<no-break>.z3pa"><os-pun|,>

        \ \ \ \ <os-key|"head"><os-pun|:> <os-str|"v2"><os-pun|,>

        \ \ \ \ <os-key|"inventorySha512"><os-pun|:>
        <os-str|"e3e1.<no-break>.<no-break>.bb25"><os-pun|,>

        \ \ \ \ <os-key|"status"><os-pun|:> <os-str|"active"><os-pun|,>

        \ \ \ \ <os-key|"label"><os-pun|:>
        <os-str|"fractional-phi42-mass-gap">

        \ \ <os-pun|}><os-pun|,> <os-pun|.<no-break>.<no-break>.>
        <os-pun|]><os-pun|,>

        \ \ <os-key|"tombstones"><os-pun|:> <os-pun|[>
        <os-pun|.<no-break>.<no-break>.> <os-pun|]>

        <os-pun|}>
      </os-code>
    <|big-listing>
      An excerpt of the discovery document of appendix C.6:
      <no-break-start><verbatim|contact><no-break-end> and
      <no-break-start><verbatim|extensions><no-break-end> are left out, and
      of <no-break-start><verbatim|objects><no-break-end> only the paper's
      entry is shown.<label|lst:discovery>
    </big-listing>

    The <dfn|storage root> is an OCFL 1.1 storage root. In its default
    layout, an owner's key log is at <no-break-start><verbatim|\<less\>owner\<gtr\>/\<less\>owner\<gtr\>/><no-break-end>
    and each of its lines, <verbatim|sheaf:<line-break>\<less\>name\<gtr\>:<line-break>\<less\>owner\<gtr\>>,
    at <no-break-start><verbatim|\<less\>owner\<gtr\>/\<less\>name\<gtr\>/><no-break-end>,
    so that an owner moves to another archive by copying one folder; large
    archives use OCFL's hashed layout (specification, section 3.2). An
    archive need not be public. It serves all its lines or none, and a line
    kept privately is published by copying it into a public archive, where it
    is the same line and every pin made before stays valid (specification,
    section 3.1).

    <subsection|Objects, versions and pins><label|sec:objects>

    An <dfn|object> is an OCFL object of kind
    <no-break-start><verbatim|document><no-break-end>,
    <no-break-start><verbatim|collection><no-break-end> or
    <no-break-start><verbatim|owner><no-break-end>, with identifier
    <verbatim|sheaf:<line-break>\<less\>name\<gtr\>:<line-break>\<less\>owner\<gtr\>>.
    An <dfn|object version> (<no-break-start><verbatim|v1><no-break-end>,
    <no-break-start><verbatim|v2><no-break-end>, ...) is made at every change
    and never changes once made. A <dfn|document version> is a version of the
    work, numbered by the line's owner from 1 without gaps; it changes only
    when the document's own files change, so several object versions, with
    different descriptions or notices, may hold one document version
    (specification, section 4). External numberings are kept as labels: a
    work whose versions 1, 3 and 4 are on arXiv has document versions 1, 2
    and 3.

    A <dfn|pin> is the pair of an object version and the SHA-512 digest of
    its inventory file. An inventory records the digests of the files of its
    version and of every earlier one, and every sealed version after the
    first records in <no-break-start><verbatim|previous><no-break-end> the
    digest of the inventory file before it. A pin therefore fixes the object
    up to that version, the bytes of every earlier inventory included, in any
    copy (specification, sections 4 and 4.3). Collections, branches and
    <no-break-start><verbatim|sheaf:><no-break-end> URIs refer to object
    versions by pins. Table <reference|tab:files> lists the files of an
    object.

    <big-table|<with|font-size|0.84|<tformat|<twith|table-width|1par>|<twith|table-hmode|exact>|<cwith|1|-1|1|-1|cell-hyphen|t>|<cwith|1|-1|1|-1|cell-valign|top>|<cwith|1|-1|1|-1|cell-halign|l>|<cwith|1|-1|1|-1|cell-lsep|0.3em>|<cwith|1|-1|1|-1|cell-rsep|0.3em>|<cwith|1|1|1|-1|font-series|bold>|<cwith|3|3|1|-1|cell-background|#f2f4f7>|<cwith|5|5|1|-1|cell-background|#f2f4f7>|<cwith|7|7|1|-1|cell-background|#f2f4f7>|<cwith|9|9|1|-1|cell-background|#f2f4f7>|<cwith|1|1|1|-1|cell-background|#dde4ee>|<cwith|1|-1|1|-1|cell-tsep|0.25em>|<cwith|1|-1|1|-1|cell-bsep|0.25em>|<cwith|1|1|1|-1|cell-tborder|1ln>|<cwith|1|1|1|-1|cell-bborder|0.5ln>|<cwith|-1|-1|1|-1|cell-bborder|1ln>|<cwith|1|-1|1|1|cell-hpart|1>|<cwith|1|-1|2|2|cell-hpart|1>|<table|<row|<cell|<with|par-mode|left|File>>|<cell|<with|par-mode|left|Role>>>|<row|<cell|<with|par-mode|left|<no-break-start><verbatim|genesis.json><no-break-end>>>|<cell|<with|par-mode|left|fixes
    the name; every version>>>|<row|<cell|<with|par-mode|left|<no-break-start><verbatim|object.json><no-break-end>>>|<cell|<with|par-mode|left|identity,
    versions, state>>>|<row|<cell|<with|par-mode|left|<no-break-start><verbatim|datacite.json><no-break-end>>>|<cell|<with|par-mode|left|description;
    not for owners>>>|<row|<cell|<with|par-mode|left|sources,
    renditions>>|<cell|<with|par-mode|left|the document's own
    files>>>|<row|<cell|<with|par-mode|left|<no-break-start><verbatim|members.json><no-break-end>>>|<cell|<with|par-mode|left|a
    collection's member list>>>|<row|<cell|<with|par-mode|left|<no-break-start><verbatim|keys.json><no-break-end>>>|<cell|<with|par-mode|left|an
    owner's key-log version>>>|<row|<cell|<with|par-mode|left|<no-break-start><verbatim|parent/><no-break-end>>>|<cell|<with|par-mode|left|a
    branch's evidence>>>|<row|<cell|<with|par-mode|left|<no-break-start><verbatim|inventory.json><no-break-end>>>|<cell|<with|par-mode|left|OCFL
    inventory, per version>>>|<row|<cell|<with|par-mode|left|witness
    folder>>|<cell|<with|par-mode|left|signatures, outside versions>>>>>>|The
    files of an object and of its versions (specification, sections 4 to
    9).<label|tab:files>>

    A new document version is made exactly when the own files (sources,
    renditions, change note) differ from those of the current version,
    compared by logical path and digest, except when a version deposited
    without sources is completed (specification, section 4.2). A
    <dfn|description-only version> keeps the files and changes only the
    description: a DOI, a licence, a notice, a withdrawal. A version
    deposited without sources says why, and may be completed later. A
    <dfn|notice>, a statement about a document version made after it, is
    identified by its position and corrected only by a later notice naming
    it. Dates never order document versions. Listing <reference|lst:object>
    shows an <no-break-start><verbatim|object.json><no-break-end>; beside it,
    <no-break-start><verbatim|datacite.json><no-break-end> holds the DataCite
    properties in the form of the DataCite REST API, with relations to the
    same work elsewhere and to earlier versions (specification, section 4.4).

    <\big-listing>
      <\os-code>
        <os-pun|{>

        \ \ <os-key|"format"><os-pun|:> <os-str|"opensheaf-object/0.2"><os-pun|,>

        \ \ <os-key|"specification"><os-pun|:> <os-str|"0.2"><os-pun|,>

        \ \ <os-key|"kind"><os-pun|:> <os-str|"document"><os-pun|,>

        \ \ <os-key|"name"><os-pun|:> <os-str|"zzgdggwl.<no-break>.<no-break>.oz4q"><os-pun|,>

        \ \ <os-key|"owner"><os-pun|:> <os-str|"56wo6cdp.<no-break>.<no-break>.z3pa"><os-pun|,>

        \ \ <os-key|"documentVersion"><os-pun|:> 1<os-pun|,>

        \ \ <os-key|"mainSource"><os-pun|:>

        \ \ \ \ <os-str|"fractional-phi42-mass-gap.tm"><os-pun|,>

        \ \ <os-key|"sourceFormat"><os-pun|:>
        <os-str|"application/x-texmacs"><os-pun|,>

        \ \ <os-key|"renditions"><os-pun|:> <os-pun|[>

        \ \ \ \ <os-pun|{> <os-key|"path"><os-pun|:>
        <os-str|"fractional-phi42-mass-gap.pdf"><os-pun|,>

        \ \ \ \ \ \ <os-key|"mediaType"><os-pun|:> <os-str|"application/pdf">
        <os-pun|}> <os-pun|]><os-pun|,>

        \ \ <os-key|"toolchain"><os-pun|:> <os-pun|[>

        \ \ \ \ <os-pun|{> <os-key|"name"><os-pun|:>
        <os-str|"TeXmacs"><os-pun|,>

        \ \ \ \ \ \ <os-key|"version"><os-pun|:> <os-str|"2.1.5"> <os-pun|}>
        <os-pun|]><os-pun|,>

        \ \ <os-key|"stage"><os-pun|:> <os-pun|{> <os-key|"scheme"><os-pun|:>
        <os-str|"NISO-JAV"><os-pun|,>

        \ \ \ \ \ \ \ \ \ \ \ \ \ <os-key|"value"><os-pun|:> <os-str|"AO">
        <os-pun|}><os-pun|,>

        \ \ <os-key|"agreement"><os-pun|:> <os-pun|{>

        \ \ \ \ <os-key|"by"><os-pun|:> <os-pun|[> <os-str|"P.
        Duch"><os-pun|,> <os-str|"M. Gubinelli"> <os-pun|]><os-pun|,>

        \ \ \ \ <os-key|"date"><os-pun|:> <os-str|"2026-03-01"><os-pun|,>

        \ \ \ \ <os-key|"method"><os-pun|:> <os-str|"by e-mail">
        <os-pun|}><os-pun|,>

        \ \ <os-key|"external"><os-pun|:> <os-pun|[>

        \ \ \ \ <os-pun|{> <os-key|"role"><os-pun|:>
        <os-str|"deposit"><os-pun|,> <os-key|"service"><os-pun|:>
        <os-str|"Zenodo"><os-pun|,>

        \ \ \ \ \ \ <os-key|"record"><os-pun|:>

        \ \ \ \ \ \ \ \ <os-str|"https://zenodo.org/records/1234567"><os-pun|,>

        \ \ \ \ \ \ <os-key|"doi"><os-pun|:>
        <os-str|"10.5281/zenodo.1234567"> <os-pun|}> <os-pun|]><os-pun|,>

        \ \ <os-key|"status"><os-pun|:> <os-str|"active">

        <os-pun|}>
      </os-code>
    <|big-listing>
      The <no-break-start><verbatim|object.json><no-break-end> of the paper's
      first version (appendix C.2), lines broken to fit.<label|lst:object>
    </big-listing>

    <subsection|Names and genesis records><label|sec:names>

    A work and an owner each have a <dfn|name>: a digest of a <dfn|genesis
    record>, the file <no-break-start><verbatim|genesis.json><no-break-end>
    written when a work is sealed or an owner created (specification, section
    5). For a document it holds a kind, a creation time, a nonce of at least
    128 random bits and the <no-break-start><verbatim|originator><no-break-end>,
    the owner of the first line (Listing <reference|lst:genesis>). The record
    is part of every version of the work and of its branches, byte for byte,
    and is never re-serialised, so no canonical form of JSON is needed.

    <\big-listing>
      <\os-code>
        <os-pun|{>

        \ \ <os-key|"format"><os-pun|:> <os-str|"opensheaf-genesis/0.2"><os-pun|,>

        \ \ <os-key|"kind"><os-pun|:> <os-str|"document"><os-pun|,>

        \ \ <os-key|"created"><os-pun|:> <os-str|"2026-03-02T09:14:00Z"><os-pun|,>

        \ \ <os-key|"originator"><os-pun|:>
        <os-str|"56wo6cdp.<no-break>.<no-break>.z3pa"><os-pun|,>

        \ \ <os-key|"nonce"><os-pun|:> <os-str|"6f65cd32058c16d6d78b05011772ff1d">

        <os-pun|}>
      </os-code>
    <|big-listing>
      The genesis record of the example paper (appendix
      C.2).<label|lst:genesis>
    </big-listing>

    Algorithm <em|k>, for <em|k> from 0 to 15, hashes with SHA-256 a seed,
    <no-break-start><verbatim|opensheaf-name-\<less\>k\<gtr\>><no-break-end>,
    then a line feed and the bytes of <no-break-start><verbatim|genesis.json><no-break-end>,
    and writes the digest in lowercase base32 without padding: 52 characters,
    the last of which holds the last bit of the digest and four zero bits,
    set to <em|k> (specification, section 5.2). Names of different algorithms
    never coincide, and are compared as strings, never decoded. Listing
    <reference|lst:name> computes them. On the bytes of the genesis record of
    appendix C.2, with its final line feed, it prints the two names given
    there in full, <no-break-start><verbatim|zzgdggwl.<no-break>.<no-break>.oz4q><no-break-end>
    and, by algorithm 1, <no-break-start><verbatim|aajozkub.<no-break>.<no-break>.iknb><no-break-end>.
    On the owner's record of appendix C.1 it prints the owner name given
    there, <no-break-start><verbatim|56wo6cdp.<no-break>.<no-break>.z3pa><no-break-end>.

    <\big-listing>
      <\os-code>
        <os-kw|import> base64<os-pun|,> hashlib<os-pun|,> sys

        A <os-pun|=> <os-str|"abcdefghijklmnopqrstuvwxyz234567">

        <os-kw|def> name<os-pun|(>g<os-pun|:> bytes<os-pun|,> k<os-pun|:> int
        <os-pun|=> 0<os-pun|)> -\<gtr\> str<os-pun|:>

        \ \ \ \ seed <os-pun|=> <os-str|b"opensheaf-name-%d\\n"> % k

        \ \ \ \ d <os-pun|=> hashlib.sha256<os-pun|(>seed +
        g<os-pun|)>.digest<os-pun|(><os-pun|)>

        \ \ \ \ s <os-pun|=> base64.b32encode<os-pun|(>d<os-pun|)>.decode<os-pun|(><os-pun|)>

        \ \ \ \ s <os-pun|=> s.rstrip<os-pun|(><os-str|"="><os-pun|)>.lower<os-pun|(><os-pun|)>

        \ \ \ \ last <os-pun|=> A.index<os-pun|(>s<os-pun|[>-1<os-pun|]><os-pun|)>
        <os-pun|\|> k

        \ \ \ \ <os-kw|return> s<os-pun|[><os-pun|:>-1<os-pun|]> +
        A<os-pun|[>last<os-pun|]>

        g <os-pun|=> open<os-pun|(>sys.argv<os-pun|[>1<os-pun|]><os-pun|,>
        <os-str|"rb"><os-pun|)>.read<os-pun|(><os-pun|)>

        print<os-pun|(>name<os-pun|(>g<os-pun|,> 0<os-pun|)><os-pun|)>

        print<os-pun|(>name<os-pun|(>g<os-pun|,> 1<os-pun|)><os-pun|)>
      </os-code>
    <|big-listing>
      Computing the names of a genesis record; checked against appendix
      C.<label|lst:name>
    </big-listing>

    A genesis record thus has 16 names; its <dfn|genesis name>, by algorithm
    0, names every line of the work except a branch renamed after a clash and
    the branches named after it. The <dfn|originator>'s line has no parent,
    and its first version must be signed by the originator; every other line
    of the record is a branch (specification, section 5.3). Clashes arise
    only when a line is made, and are resolved there: the originator's tool
    draws a new nonce, and a branch whose line is taken takes the smallest
    free algorithm number above its parent's. A genesis record reused for
    another work gives no valid line, and there are no aliases: a work
    refused for a reused record is sealed anew (specification, section 5.4
    and appendix D.2).

    <subsection|Owners and key logs><label|sec:owners>

    An owner is an object of kind <no-break-start><verbatim|owner><no-break-end>,
    named by its own genesis record, always by algorithm 0. Its object
    versions are its <dfn|key log> (specification, section 6). The design
    follows the pre-rotation of KERI <cite|keri2019>, after earlier drafts in
    which a thief could contest the owner's answer to a theft (Section
    <reference|sec:lessons>).

    Two kinds of keys have separate roles. <dfn|Current keys>, Ed25519 keys
    written as <no-break-start><verbatim|did:key><no-break-end> URIs, sign
    the versions of the owner's lines, at least
    <no-break-start><verbatim|threshold><no-break-end> of them per version.
    <dfn|Rotation keys> sign only the next version of the key log; each
    version commits to them in advance by their SHA-256 digests in
    <no-break-start><verbatim|next><no-break-end>, with a
    <no-break-start><verbatim|nextThreshold><no-break-end>. A rotation key is
    used once, committed in one version only, and never becomes a current
    key; current keys never sign the key log. The first version is computed
    from the owner's genesis record, its <no-break-start><verbatim|object.json><no-break-end>,
    <no-break-start><verbatim|keys.json><no-break-end> and inventory written
    in the JSON Canonicalization Scheme so that every copy has the same
    bytes, and is never signed, so the owner name commits to the first
    current keys and to the digests of the first rotation keys (Listing
    <reference|lst:owner>). The specification advises one current key per
    device and three rotation keys kept apart with a
    <no-break-start><verbatim|nextThreshold><no-break-end> of 2, which
    survive the loss of one or the theft of one (specification, section 6.2).

    <\big-listing>
      <\os-code>
        <os-pun|{>

        \ \ <os-key|"format"><os-pun|:> <os-str|"opensheaf-genesis/0.2"><os-pun|,>

        \ \ <os-key|"kind"><os-pun|:> <os-str|"owner"><os-pun|,>

        \ \ <os-key|"created"><os-pun|:> <os-str|"2026-03-01T17:40:00Z"><os-pun|,>

        \ \ <os-key|"nonce"><os-pun|:> <os-str|"1b4d9964664d9825076eb8558af61162"><os-pun|,>

        \ \ <os-key|"keys"><os-pun|:> <os-pun|[>

        \ \ \ \ <os-str|"did:key:z6MksKLD.<no-break>.<no-break>.MkMuVW">

        \ \ <os-pun|]><os-pun|,>

        \ \ <os-key|"threshold"><os-pun|:> 1<os-pun|,>

        \ \ <os-key|"next"><os-pun|:> <os-pun|[>

        \ \ \ \ <os-str|"oxthfb6b.<no-break>.<no-break>.qnalha"><os-pun|,>

        \ \ \ \ <os-str|"h6k4k6c5.<no-break>.<no-break>.vla6vq"><os-pun|,>

        \ \ \ \ <os-str|"lnaifwjn.<no-break>.<no-break>.npaklq">

        \ \ <os-pun|]><os-pun|,>

        \ \ <os-key|"nextThreshold"><os-pun|:> 2<os-pun|,>

        \ \ <os-key|"keeper"><os-pun|:> <os-pun|[>

        \ \ \ \ <os-str|"https://orcid.org/0000-0002-1234-5677">

        \ \ <os-pun|]><os-pun|,>

        \ \ <os-key|"extensions"><os-pun|:> <os-pun|{>
        <os-pun|.<no-break>.<no-break>.> <os-pun|}>

        <os-pun|}>
      </os-code>
    <|big-listing>
      The genesis record of the authors' owner (appendix C.1); the data of
      the timestamps extension is elided.<label|lst:owner>
    </big-listing>

    <paragraph|Exposure, ending and forks>An owner whose current keys may
    have been exposed, and could reach the
    <no-break-start><verbatim|threshold><no-break-end>, signs at once, with
    rotation keys, a version listing them in
    <no-break-start><verbatim|exposed><no-break-end>, or ends. Whoever holds
    the current keys can neither prevent nor contest it. There is no
    revocation: signatures carry no time, so nothing tells what a key signed
    before it leaked from what a thief signs after; signatures stay good, and
    what needs an exposed key becomes contested (Section
    <reference|sec:lines>). An owner ends by signing a last version with
    <no-break-start><verbatim|ended><no-break-end> and, optionally, a
    successor. Two signed versions of a key log with one number and different
    inventories are a <dfn|fork of the key log>; only rotation keys can make
    one, stolen before use or kept after it. The format cannot tell which
    side is the owner's, so a fork ends the owner and freezes it: archives
    add no more versions of its lines unless trusted evidence dates them
    before the fork (specification, sections 6.3 and 7.5). An archive keeps
    the side it saw first and appends a <dfn|fork record>, an unsigned
    version carrying the other side, so that every copy shows the fork.

    <paragraph|Travel and keepers>A key log checks itself from its owner
    name, so a copy from any source is as good as the original. Every copy of
    an object holds beside it the key logs its signatures need, and the
    longer of two copies is used; no one can prove offline that a key log is
    complete (specification, section 6.5). An owner may name one <dfn|keeper>
    in its genesis record, an ORCID iD or a domain. The keeper may confirm
    the link; names the accepted successor when no ending version before a
    fork point names one; and is, besides the law, the only party at whose
    request an archive takes down an owner object that other objects need
    (specification, sections 6.6 and 13.2). The keeper says who answers for
    an owner, not who owns its lines, which only its keys decide.

    <subsection|Lines, signatures and statuses><label|sec:lines>

    A <dfn|line> is the history of a work as decided by one owner, and is its
    signed versions, wherever stored; it is written
    <verbatim|sheaf:<line-break>\<less\>name\<gtr\>:<line-break>\<less\>owner\<gtr\>>
    (specification, section 7). Every sealed version of a line other than a
    key log is signed by at least <no-break-start><verbatim|threshold><no-break-end>
    current keys of one version of the owner's key log, each in a signature
    file kept in the object's witness folder, outside every version (Listing
    <reference|lst:signature>). The file's name is derived from its key, so a
    reader that knows the keys finds it without listing folders. What is
    signed is a message of five lines: a domain separator, the object, the
    version, the inventory digest and the key-log version, as a pin. A
    signature is judged against that key-log version alone, so retired keys
    leave earlier signatures good. Others' attestations, and timestamps, are
    witnesses, never signatures of the line.

    <\big-listing>
      <\os-code>
        <os-pun|{>

        \ \ <os-key|"format"><os-pun|:> <os-str|"opensheaf-signature/0.2"><os-pun|,>

        \ \ <os-key|"object"><os-pun|:>

        \ \ \ \ <os-str|"sheaf:zzgdggwl.<no-break>.<no-break>.oz4q:56wo6cdp.<no-break>.<no-break>.z3pa"><os-pun|,>

        \ \ <os-key|"version"><os-pun|:> <os-str|"v2"><os-pun|,>

        \ \ <os-key|"inventorySha512"><os-pun|:>
        <os-str|"e3e1.<no-break>.<no-break>.bb25"><os-pun|,>

        \ \ <os-key|"signer"><os-pun|:> <os-str|"56wo6cdp.<no-break>.<no-break>.z3pa"><os-pun|,>

        \ \ <os-key|"key"><os-pun|:> <os-str|"did:key:z6MkugKq.<no-break>.<no-break>.DDvThn"><os-pun|,>

        \ \ <os-key|"keyLog"><os-pun|:>

        \ \ \ \ <os-str|"sheaf:56wo6cdp.<no-break>.<no-break>.z3pa/v2?sha512=7673.<no-break>.<no-break>.3f84"><os-pun|,>

        \ \ <os-key|"signature"><os-pun|:>
        <os-str|"Gf9KOxH/.<no-break>.<no-break>.qipyBA==">

        <os-pun|}>
      </os-code>
    <|big-listing>
      A signature file of the paper's second version (appendix
      C.3).<label|lst:signature>
    </big-listing>

    Statuses are defined once (specification, section 7.3). A signature file
    is invalid, unchecked (its key-log version cannot be reached) or good,
    and stays good for ever. A version of a line is <dfn|signed>, directly or
    <dfn|vouched for> by a later version signed directly that extends it; or
    unchecked; or not a version, never shown as one. A signed version is
    <dfn|contested> when it would not be signed without signatures made with
    an exposed key, or naming a key-log version from a fork point on, unless
    evidence the reader trusts dates them before. Readers use the <dfn|latest
    signed version>, signed and not contested, for a line's history and
    status. Two copies whose latest signed versions do not agree are a
    <dfn|fork of the line>, reported and never recorded. An archive adds a
    version only if it is then signed and not contested, and never removes a
    version on evidence that a host or a thief could produce (specification,
    sections 7.4 and 7.5).

    <subsection|Collections><label|sec:collections>

    A <dfn|collection> is an object whose versions hold
    <no-break-start><verbatim|members.json><no-break-end>, a list of lines of
    documents or collections, in any archive, each pinned (specification,
    section 8). Its source is the member list, so any change of it is a new
    document version. Keeping and vetting are different acts. A
    <dfn|catalogue> keeps objects whole and is impartial about their
    versions; a member may have <no-break-start><verbatim|follow><no-break-end>
    set to <no-break-start><verbatim|latest><no-break-end>, and the
    catalogue's tool then writes a new document version of the catalogue when
    that member's line has a new signed version, never a contested one. A
    <dfn|selection> vets particular versions: each member pins a revision
    set, the document versions vetted (Listing <reference|lst:selection>),
    and later versions by the authors enter only by a new version of the
    selection.

    <\big-listing>
      <\os-code>
        <os-pun|{>

        \ \ <os-key|"format"><os-pun|:> <os-str|"opensheaf-collection/0.2"><os-pun|,>

        \ \ <os-key|"type"><os-pun|:> <os-str|"selection"><os-pun|,>

        \ \ <os-key|"members"><os-pun|:> <os-pun|[> <os-pun|{>

        \ \ \ \ <os-key|"kind"><os-pun|:> <os-str|"document"><os-pun|,>

        \ \ \ \ <os-key|"name"><os-pun|:>
        <os-str|"zzgdggwl.<no-break>.<no-break>.oz4q"><os-pun|,>

        \ \ \ \ <os-key|"owner"><os-pun|:>
        <os-str|"tqr6lchn.<no-break>.<no-break>.tdka"><os-pun|,>

        \ \ \ \ <os-key|"at"><os-pun|:> <os-pun|[>
        <os-str|"https://journal.example.org/"> <os-pun|]><os-pun|,>

        \ \ \ \ <os-key|"revisions"><os-pun|:> <os-pun|[> <os-pun|{>

        \ \ \ \ \ \ <os-key|"documentVersion"><os-pun|:> 2<os-pun|,>

        \ \ \ \ \ \ <os-key|"version"><os-pun|:> <os-str|"v1"><os-pun|,>

        \ \ \ \ \ \ <os-key|"inventorySha512"><os-pun|:>
        <os-str|"1c4e.<no-break>.<no-break>.9a5a"> <os-pun|}>
        <os-pun|]><os-pun|,>

        \ \ \ \ <os-key|"cite"><os-pun|:> <os-pun|{>
        <os-pun|.<no-break>.<no-break>.> <os-pun|}>

        \ \ <os-pun|}><os-pun|,> <os-pun|{>

        \ \ \ \ <os-key|"kind"><os-pun|:> <os-str|"document"><os-pun|,>

        \ \ \ \ <os-key|"name"><os-pun|:>
        <os-str|"zzgdggwl.<no-break>.<no-break>.oz4q"><os-pun|,>

        \ \ \ \ <os-key|"owner"><os-pun|:>
        <os-str|"56wo6cdp.<no-break>.<no-break>.z3pa"><os-pun|,>

        \ \ \ \ <os-key|"at"><os-pun|:> <os-pun|[>
        <os-str|"https://mgubi.org/papers/"> <os-pun|]><os-pun|,>

        \ \ \ \ <os-key|"revisions"><os-pun|:> <os-pun|[> <os-pun|{>

        \ \ \ \ \ \ <os-key|"documentVersion"><os-pun|:> 2<os-pun|,>

        \ \ \ \ \ \ <os-key|"version"><os-pun|:> <os-str|"v2"><os-pun|,>

        \ \ \ \ \ \ <os-key|"inventorySha512"><os-pun|:>
        <os-str|"e3e1.<no-break>.<no-break>.bb25"><os-pun|,>

        \ \ \ \ \ \ <os-key|"doi"><os-pun|:>
        <os-str|"10.5281/zenodo.1234568"> <os-pun|}> <os-pun|]>

        \ \ <os-pun|}> <os-pun|]>

        <os-pun|}>
      </os-code>
    <|big-listing>
      A selection, an issue of a journal (appendix C.4);
      <no-break-start><verbatim|cite><no-break-end> is
      elided.<label|lst:selection>
    </big-listing>

    A member names its line by <no-break-start><verbatim|name><no-break-end>
    and <no-break-start><verbatim|owner><no-break-end>, and gives in
    <no-break-start><verbatim|at><no-break-end> base URLs where copies may be
    found, as equal hints. Since a pin fixes an inventory, which fixes every
    file and earlier version, collections are hash trees across archives, and
    pins cannot form cycles. Each owner an archive hosts has there an
    <dfn|owner catalogue>, signed by that owner only; it replaced a single
    catalogue per archive, which would have needed one owner's keys for every
    other owner's deposits (specification, appendix D.5). A verifier gives
    each member one of the statuses of Table <reference|tab:status>; whether
    a copy matches is decided by the bytes of its inventory file.

    <big-table|<with|font-size|0.84|<tformat|<twith|table-width|1par>|<twith|table-hmode|exact>|<cwith|1|-1|1|-1|cell-hyphen|t>|<cwith|1|-1|1|-1|cell-valign|top>|<cwith|1|-1|1|-1|cell-halign|l>|<cwith|1|-1|1|-1|cell-lsep|0.3em>|<cwith|1|-1|1|-1|cell-rsep|0.3em>|<cwith|1|1|1|-1|font-series|bold>|<cwith|3|3|1|-1|cell-background|#f2f4f7>|<cwith|5|5|1|-1|cell-background|#f2f4f7>|<cwith|7|7|1|-1|cell-background|#f2f4f7>|<cwith|1|1|1|-1|cell-background|#dde4ee>|<cwith|1|-1|1|-1|cell-tsep|0.25em>|<cwith|1|-1|1|-1|cell-bsep|0.25em>|<cwith|1|1|1|-1|cell-tborder|1ln>|<cwith|1|1|1|-1|cell-bborder|0.5ln>|<cwith|-1|-1|1|-1|cell-bborder|1ln>|<cwith|1|-1|1|1|cell-hpart|1>|<cwith|1|-1|2|2|cell-hpart|1>|<table|<row|<cell|<with|par-mode|left|Status>>|<cell|<with|par-mode|left|When>>>|<row|<cell|<with|par-mode|left|verified>>|<cell|<with|par-mode|left|a
    copy matches the pin; signed, not contested>>>|<row|<cell|<with|par-mode|left|contested>>|<cell|<with|par-mode|left|a
    copy matches the pin; contested>>>|<row|<cell|<with|par-mode|left|mismatch>>|<cell|<with|par-mode|left|copies
    found, none matches the pin>>>|<row|<cell|<with|par-mode|left|unchecked>>|<cell|<with|par-mode|left|the
    version pinned is unchecked>>>|<row|<cell|<with|par-mode|left|not a
    version>>|<cell|<with|par-mode|left|the collection pinned what it must
    not>>>|<row|<cell|<with|par-mode|left|unavailable>>|<cell|<with|par-mode|left|no
    copy is found>>>|<row|<cell|<with|par-mode|left|removed>>|<cell|<with|par-mode|left|no
    copy; an archive holds a tombstone>>>>>>|The statuses of a member, or of
    a revision in a selection (specification, section
    8.5).<label|tab:status>>

    <subsection|Branches and accepted copies><label|sec:branches>

    A <dfn|branch> is a line of another owner that continues a work from a
    signed version of another line: a co-author carrying the work on, the
    successor of an ended owner, a journal keeping the version it vetted
    (specification, section 9). It has the work's genesis record, and is a
    new object. Its content holds the evidence of its branch point in
    <no-break-start><verbatim|parent/><no-break-end>: the parent's inventory,
    its <no-break-start><verbatim|object.json><no-break-end>, the parent
    owner's good signature files and, for a branch of a branch, the parent's
    own evidence, back to the originator's line. A branch point is thus
    checked without access to the parent's line, and is inconsistent,
    confirmed or unchecked. A branch numbers its own document versions from
    1, and may take a later version of the same parent line as a new branch
    point. A line is never handed over; work of another line is taken in by a
    deposit with a relation.

    An <dfn|accepted copy> is a branch kept by the owner of a selection from
    a revision it vetted. A version the journal makes itself, such as a
    typeset version of record, is a later version of its accepted copy, with
    the authors' agreement and relations to their versions (specification,
    section 9.6).

    <subsection|Drafts, mirrors and rights><label|sec:drafts>

    A <dfn|draft> belongs to the reserved owner
    <no-break-start><verbatim|draft><no-break-end>: it is never signed,
    pinned, copied or named by a <no-break-start><verbatim|sheaf:><no-break-end>
    URI, and is the only object that may be rewritten or deleted
    (specification, section 10). <dfn|Sealing> makes from a work, under a new
    genesis record, the first signed version of its originator's line, at the
    owner's request, before a version first leaves the owner's hands.

    A <dfn|mirror> is a copy of a line in an archive where its owner does not
    write. Nothing marks it: it is the same line, grown only by the owner's
    signed versions (specification, section 11). Whoever keeps mirrors or
    indexes of others' lines is a <dfn|custodian>. An archive that keeps a
    mirror, or a branch, is responsible for having the right to redistribute
    what it copies, by licence, agreement or law; the specification does not
    judge it, and a reference, a pin without a copy, needs no permission
    (specification, section 11.2). Whether a copy may stop at a pinned
    version (#39) and what a custodian promises to keep (#54) are open.

    <subsection|Identifiers, resolution and indexes><label|sec:uris>

    Lines, versions, pins, works and owners are written as
    <no-break-start><verbatim|sheaf:><no-break-end> URIs (Listing
    <reference|lst:uriforms>). Without an owner part, a URI names the
    originator's line, read from the genesis record every copy carries; never
    "the latest" line. <no-break-start><verbatim|/v\<less\>n\<gtr\>><no-break-end>
    names a document version; a <no-break-start><verbatim|sha512><no-break-end>
    parameter names exactly one object version;
    <no-break-start><verbatim|at><no-break-end> is a hint, not part of what
    is named (specification, section 12.1). For people, names may be
    shortened to prefixes of at least 8 characters, which a resolver expands
    only when one candidate matches. Listing <reference|lst:uris> gives URIs
    of the example.

    <\big-listing>
      <\os-code>
        sheaf:\<less\>name\<gtr\>

        \ \ \ \ <os-com|the originator's line>

        sheaf:\<less\>name\<gtr\>:\<less\>owner\<gtr\>

        \ \ \ \ <os-com|the line of that owner>

        sheaf:\<less\>name\<gtr\>:*

        \ \ \ \ <os-com|the work: all its lines>

        sheaf:\<less\>name\<gtr\>[:\<less\>owner\<gtr\>]/v\<less\>n\<gtr\>

        \ \ \ \ <os-com|document version n of the line>

        sheaf:\<less\>name\<gtr\>[:\<less\>owner\<gtr\>]/v\<less\>n\<gtr\>?sha512=\<less\>digest\<gtr\>

        \ \ \ \ <os-com|one object version holding it>

        sheaf:\<less\>owner\<gtr\>

        \ \ \ \ <os-com|an owner: its key log>

        sheaf:\<less\>owner\<gtr\>/v\<less\>n\<gtr\>?sha512=\<less\>digest\<gtr\>

        \ \ \ \ <os-com|a version of its key log>
      </os-code>
    <|big-listing>
      The forms of <no-break-start><verbatim|sheaf:><no-break-end> URIs
      (specification, section 12.1).<label|lst:uriforms>
    </big-listing>

    <\big-listing>
      <\os-code>
        sheaf:zzgdggwl.<no-break>.<no-break>.oz4q

        \ \ \ \ <os-com|the authors' line>

        sheaf:zzgdggwl.<no-break>.<no-break>.oz4q/v2

        \ \ \ \ <os-com|document version 2 of the authors' line>

        sheaf:zzgdggwl.<no-break>.<no-break>.oz4q/v2?sha512=e3e1.<no-break>.<no-break>.bb25

        \ \ \ \ <os-com|the authors' object version v2>

        sheaf:zzgdggwl.<no-break>.<no-break>.oz4q:tqr6lchn.<no-break>.<no-break>.tdka/v2

        \ \ \ \ <os-com|document version 2 of the journal's line>

        sheaf:zzgdggwl.<no-break>.<no-break>.oz4q:*

        \ \ \ \ <os-com|the work: every line of it>

        sheaf:56wo6cdp.<no-break>.<no-break>.z3pa

        \ \ \ \ <os-com|the authors' owner: its key log>

        sheaf:zzgdggwl/v2

        \ \ \ \ <os-com|a short form of the second>
      </os-code>
    <|big-listing>
      Some of the URIs of the paper, of the accepted copy and of the owner
      given in appendix C.7.<label|lst:uris>
    </big-listing>

    A <dfn|resolver> finds and checks what a URI names (Listing
    <reference|lst:resolve>). It tries the locations it has, in any order,
    checks every copy found, and uses the latest signed version among the
    copies that agree, reporting forks, ended owners, exposed keys and
    tombstones (specification, section 12.3). To find every line of a work,
    it looks up all 16 names and keeps only entries whose genesis record is
    byte for byte the same, so no hash is assumed free of collisions
    (specification, section 12.4). An archive should keep indexes by name, by
    owner and by inventory digest; custodians may keep them for many
    archives. A <dfn|gateway> serves URIs as web links, with a page or a
    temporary redirect only to a copy it has checked (specification, section
    12.6). External deposits, such as a Zenodo record, are witnesses, not
    copies: they hold no inventory and resolve nothing.

    <\big-listing>
      <\os-code>
        <os-kw|resolve><os-pun|(>uri<os-pun|)><os-pun|:>

        \ \ name<os-pun|,> owner<os-pun|,> n<os-pun|,> digest<os-pun|,> at
        <os-pun|=> parse<os-pun|(>uri<os-pun|)>

        \ \ <os-kw|for> loc <os-kw|in> at<os-pun|,> members' at<os-pun|,>
        parent.url<os-pun|,>

        \ \ \ \ \ \ \ \ \ \ \ \ \ indexes<os-pun|,> configuration<os-pun|:>

        \ \ \ \ <os-kw|read> loc/opensheaf.json

        \ \ \ \ <os-kw|find> <os-pun|(>name<os-pun|,> owner<os-pun|)>
        <os-kw|in> the indexes<os-pun|,>

        \ \ \ \ \ \ <os-kw|or> <os-kw|else> <os-kw|in> objects

        \ \ \ \ <os-kw|fetch> the inventory of the version

        \ \ \ \ <os-kw|check> name is a name of genesis.json

        \ \ \ \ <os-kw|check> object.json<os-pun|:> name and owner

        \ \ \ \ <os-kw|check> signatures against the key log

        \ \ \ \ \ \ beside the copy<os-pun|,> <os-kw|or> a longer copy

        \ \ \ \ <os-kw|check> the version holds n

        \ \ \ \ <os-kw|if> digest<os-pun|:> <os-kw|check> the inventory
        bytes<os-pun|,>

        \ \ \ \ \ \ whatever the checksum file says

        \ \ \ \ <os-kw|keep> the copy and its signed versions<os-pun|;>

        \ \ \ \ \ \ a contested one only <os-kw|for> a digest

        \ \ <os-kw|report> copies that do not match<os-pun|,> forks<os-pun|,>

        \ \ \ \ ended owners<os-pun|,> exposed keys<os-pun|,> tombstones

        \ \ <os-kw|if> digest<os-pun|:> <os-kw|return> a copy that
        matches<os-pun|,>

        \ \ \ \ <os-kw|or> <os-kw|else> <os-kw|report> a mismatch

        \ \ <os-kw|return> the latest signed version

        \ \ \ \ among the copies that agree
      </os-code>
    <|big-listing>
      Resolution, after section 12.3 of the specification
      (pseudocode).<label|lst:resolve>
    </big-listing>

    <subsection|Withdrawal, takedown and tombstones><label|sec:withdrawal>

    An owner withdraws a line; an archive takes down an object
    (specification, section 13). A <dfn|withdrawal> is a description-only
    version with status <no-break-start><verbatim|withdrawn><no-break-end>, a
    date and a reason, which withdraws every document version deposited
    before it; they stay signed, pinned and copied, and copies follow the
    withdrawal, since it is a signed version. A new document version
    reinstates the line. A <dfn|takedown> deletes a whole object from one
    archive, since OCFL cannot remove a file without changing inventories and
    so every pin, and leaves a <dfn|tombstone> in the discovery document. A
    tombstone is not signed and speaks for its archive only: copies elsewhere
    do not follow it by themselves, and resolution goes on to them.

    <subsection|Verification and security><label|sec:verification>

    A <dfn|verifier> checks files and storage, key logs, objects, collections
    and the archive as a whole, in that order (specification, section 14).
    Its findings are <dfn|errors>, breaches of a MUST; <dfn|warnings>,
    breaches of a SHOULD, breaches the archive cannot repair, and checks not
    made; and <dfn|results>, such as statuses, forks, ended owners and
    withdrawals, which are states of the world rather than faults. Over HTTP
    a verifier cannot list folders, and says what it could not check.

    The security claim is narrow. A host or a network cannot forge a version,
    add one to another owner's line, or make a valid line from a reused
    genesis record. It can withhold, serving an older copy or a key log that
    stops before an end or a fork record, and it can delete what it serves,
    never a copy held elsewhere (specification, section 15.1). A good
    signature shows that a key of the owner's key log signed one version; not
    who wrote the document, who the owner is, when it was signed, or that no
    later version exists. Among the residual risks the specification lists
    (section 15.1) are a host that withholds an exposure, archives that see
    different sides of a fork, a retired key never exposed, and a thief who
    forks a key log and exposes the owner's earlier keys, which harms trust
    in the owner's past but lets no forgery pass.

    <subsection|Profiles and extensions><label|sec:profiles>

    A <dfn|profile> is a set of rules for an external service or tool,
    normative for archives that declare it (specification, appendix A). The
    Zenodo profile makes each line a record and each document version a
    record version with its own DOI, records MD5 digests, which Zenodo
    reports, in the inventories' <no-break-start><verbatim|fixity><no-break-end>,
    and signs a version before the record is published. The TeXmacs profile
    fixes how renditions are made from TeXmacs sources. The website profile
    makes landing pages with the meta tags that Google Scholar reads, a feed,
    and optionally an OAI-PMH static repository. Extensions record what the
    core leaves open, under <no-break-start><verbatim|extensions><no-break-end>,
    without changing its meaning. The timestamps extension keeps RFC 3161
    tokens and OpenTimestamps proofs of signature files beside them; they are
    evidence only, and change no status by themselves <cite|timestamps02>. A
    companion text says how to keep an archive in git without git changing a
    byte of it <cite|git02>.

    <section|Implementation><label|sec:impl>

    <subsection|Reference tools><label|sec:tools>

    The reference implementation, opensheaf-py, provides the
    <no-break-start><verbatim|osheaf><no-break-end> command <cite|tools>. It
    is a literate program that explains the code along the specification, and
    follows the draft: archives made now may have to be rebuilt. It deposits
    documents and new versions and signs them; keeps notices, withdrawals,
    collections, mirrors, branches, accepted copies and drafts; writes the
    discovery document, the indexes and a website; imports papers from arXiv;
    deposits on Zenodo, by default in its sandbox; and verifies an archive,
    optionally also against the JSON Schemas and with an independent OCFL
    validator. Listing <reference|lst:osheaf> shows a first session, as
    documented in its guide.

    <\big-listing>
      <\os-code>
        <os-kw|osheaf> init my-papers <os-pun|\\>

        \ \ -<no-break>-name <os-str|"Papers of Jane Doe"> <os-pun|\\>

        \ \ -<no-break>-base-url <os-pun|\\>

        \ \ \ \ https<os-pun|:>//janedoe.github.io/papers/ <os-pun|\\>

        \ \ -<no-break>-curator <os-str|"Doe, Jane"> <os-pun|\\>

        \ \ -<no-break>-affiliation <os-str|"Example University"> <os-pun|\\>

        \ \ -<no-break>-new-owner <os-pun|\\>

        \ \ -<no-break>-export /Volumes/USB/opensheaf-keys <os-pun|\\>

        \ \ -<no-break>-print

        <os-kw|cd> my-papers

        <os-kw|osheaf> deposit kpz-uniqueness paper.tex <os-pun|\\>

        \ \ -<no-break>-pdf paper.pdf -<no-break>-new <os-pun|\\>

        \ \ -<no-break>-extra-source refs.bib <os-pun|\\>

        \ \ -<no-break>-extra-source <os-pun|\\>

        \ \ \ \ figures/fig1.pdf<os-pun|=>figures/fig1.pdf <os-pun|\\>

        \ \ -<no-break>-title <os-pun|\\>

        \ \ \ \ <os-str|"Energy solutions of KPZ are unique"> <os-pun|\\>

        \ \ -<no-break>-author <os-str|"Doe, Jane\|Example University">
        <os-pun|\\>

        \ \ -<no-break>-author <os-pun|\\>

        \ \ \ \ <os-str|"Roe, Richard\|Another University"> <os-pun|\\>

        \ \ -<no-break>-abstract-file abstract.txt <os-pun|\\>

        \ \ -<no-break>-keyword <os-str|"stochastic PDE"> <os-pun|\\>

        \ \ -<no-break>-rights cc-by-4.0 -<no-break>-available 2015-08-31

        <os-kw|osheaf> deposit kpz-uniqueness paper.tex <os-pun|\\>

        \ \ -<no-break>-pdf paper.pdf <os-pun|\\>

        \ \ -<no-break>-changes <os-str|"Lemma 2 corrected."> <os-pun|\\>

        \ \ -<no-break>-title <os-pun|\\>

        \ \ \ \ <os-str|"Energy solutions of KPZ are unique"> <os-pun|\\>

        \ \ -<no-break>-author <os-str|"Doe, Jane\|Example University">

        <os-kw|osheaf> notice kpz-uniqueness -<no-break>-about 1 <os-pun|\\>

        \ \ -<no-break>-text <os-pun|\\>

        \ \ <os-str|"Lemma 2 is wrong as stated; see version 2.">

        <os-kw|osheaf> collect

        <os-kw|osheaf> verify
      </os-code>
    <|big-listing>
      Creating an archive and an owner, depositing a paper and a second
      version, adding a notice about the first, and checking the archive
      <cite|tools>.<label|lst:osheaf>
    </big-listing>

    Key management is where the tools meet users most. By default
    <no-break-start><verbatim|init><no-break-end> writes the rotation keys,
    encrypted under a passphrase, to a removable drive and optionally to
    printed sheets, and asks the user to type back a check of each; a key
    wallet in a private GitHub repository or a password manager trades
    security for convenience, and the tools say so. A wallet may be unlocked
    by a passkey. A lost computer is answered by
    <no-break-start><verbatim|osheaf owner expose><no-break-end>, a version
    of the key log signed by two rotation keys; versions the owner made that
    only the exposed key signed are then signed again with a new key.

    <subsection|The Explorer and the Manager><label|sec:explorer>

    The Explorer shows an archive or a collection in the browser, with its
    objects, versions, files and members across archives, and verifies it as
    section 14 of the specification asks, from a static page <cite|explorer>.
    The Manager is a web page that keeps an archive made from the archive
    template, a GitHub repository with its workflows and Pages already set up
    <cite|manager|template>. It can make the owner and add keys to its key
    log; rotation keys then pass through the page's memory, so the highest
    security level keeps them offline, used by
    <no-break-start><verbatim|osheaf><no-break-end> alone.

    <subsection|A formal model in Lean><label|sec:lean>

    The specification states promises in prose: that a pin, once valid, stays
    valid; that a host cannot add a version to another owner's line; that a
    fork of a key log freezes its owner. A model in Lean 4, written as two
    literate programs, states the rules as definitions and the promises as
    theorems <cite|lean>. It is non-normative; a difference between it and
    the specification is a bug of one or the other. Digests, names and
    signature verification are left to an abstract environment, about which
    almost nothing is assumed, and every addition to a world is one of four
    steps: a new archive, object, version or set of signature files;
    takedowns, which remove, are modelled apart. The theorems include:

    <\itemize>
      <item><no-break-start><verbatim|Step.resolveAt_ok><no-break-end>,
      immutability: once a pin resolves at an archive, no step changes what
      it resolves to there, for any digest function, since archives only add;

      <item><no-break-start><verbatim|current_keys_cannot_extend><no-break-end>:
      holders of current keys alone cannot extend a key log;

      <item><no-break-start><verbatim|Events.fork_freezes_forever><no-break-end>:
      a recorded fork freezes the owner there for ever;

      <item><no-break-start><verbatim|forgery_needs_owner_key><no-break-end>:
      in every world built by valid steps and takedowns, the head of every
      copy of every line other than a key log is signed with a current key of
      the owner's key log;

      <item><no-break-start><verbatim|Events.copiesAgree><no-break-end> and
      <no-break-start><verbatim|no_cycles><no-break-end>: copies agree when
      the owner signs one history and no copy collides with it, and pins then
      form no cycles;

      <item><no-break-start><verbatim|ReaderAccepts.no_forgery><no-break-end>:
      what a reader accepts from one copy and a key log, wherever they came
      from, is a prefix of the history the owner's keys signed, assuming only
      that signatures verify only with their keys and that the inventories
      compared do not collide.
    </itemize>

    The model also exhibits the residual risks of section 15.1 on concrete
    worlds. A second program reads worlds as sheaves, which makes the name
    precise: named document versions are the points of a space, each object
    version is a section, and the sections of all copies of a line glue into
    exactly one when the owner signs one history
    (<no-break-start><verbatim|world_glues><no-break-end>); when they do not
    glue, a fork of the line is the reason.

    <subsection|The first archive><label|sec:papers>

    The first archive is the author's, at
    <no-break-start><verbatim|mgubi.org/papers><no-break-end>, kept in the
    git repository mgubi/papers with these tools <cite|papers>. It follows
    version 0.2 since its rebuild on 20 November 2026, and keeps TeXmacs
    sources, HTML versions and PDFs. It holds 83 documents, 81 of which have
    versions imported from arXiv, 154 arXiv versions in all <cite|papers>.
    The import records arXiv as an external record of role
    <no-break-start><verbatim|source><no-break-end>, arXiv's
    <no-break-start><verbatim|vN><no-break-end> as a label, the SHA-512
    digests of the files received, and relations to the versioned arXiv
    identifier and the arXiv DOI. Document versions do not follow arXiv's
    numbers: in one line, document versions 1, 2 and 3 are arXiv's
    <no-break-start><verbatim|v1><no-break-end>,
    <no-break-start><verbatim|v3><no-break-end> and
    <no-break-start><verbatim|v4><no-break-end>, version 4 is the authors'
    accepted version, never on arXiv, and version 5 is arXiv's
    <no-break-start><verbatim|v5><no-break-end>.

    Licences limit what others may do. Of the 81 lines imported from arXiv,
    the latest version of 52 carries arXiv's default licence, 20 the licence
    assumed for submissions of 1991 to 2003, 8 CC BY 4.0 and 1 CC0; only 3
    lines carry an open licence in every version, and in 8 the licence
    changes between versions <cite|papers>. A custodian without the authors'
    agreement has the right to redistribute few of them. The digests recorded
    fix what the owner received when it imported, not what arXiv served on
    the day of each version.

    <subsection|What implementing taught><label|sec:lessons>

    The changelog of the specification records what changed as the tools, the
    model and the archive were built (specification, section 16.2).

    <paragraph|Rules a verifier can decide>Several rules were rewritten so
    that a verifier decides them from the files alone. That a version
    deposited out of order must write <no-break-start><verbatim|history><no-break-end>
    became a definition: the history is the order of numbers unless
    <no-break-start><verbatim|history><no-break-end> says otherwise (#51).
    Digests became lower case, so that a pin is compared as a string (#49). A
    copy whose inventory bytes match a pin matches, whatever its checksum
    file says (#48). On 20 November 2026 a set of ambiguities found while
    writing the tools was resolved in one revision.

    <paragraph|What a pin fixes>A pin fixed the files of earlier versions but
    not the bytes of their inventories, so the pin of a version vouched for
    was weaker than that of one signed directly. The inventory chain closed
    the gap (#46).

    <paragraph|Keys and forks>The rules on keys were rewritten several times;
    each version closed holes and opened others, and letting an owner heal a
    fork of its key log could not converge against a thief holding a listed
    key. In the identity systems we examined, recovery from theft rests
    either on an order the thief cannot rewrite, as in the directory of the
    AT Protocol <cite|atproto>, or on a commitment made before the theft, as
    in KERI <cite|keri2019>. OpenSheaf has no order, so it took the
    commitment: pre-rotation, exposure that cannot be contested, and a fork
    that ends the owner (#58). Among the lessons recorded are never to remove
    on evidence an attacker can shape, to define statuses once, and to
    rewrite rather than patch.

    <section|Related work><label|sec:related>

    This section sets OpenSheaf first against the digital-library literature
    on versions, links and identifiers, then against our survey of
    decentralised and federated publishing, made from the systems' own
    documents and code, which are cited here; what we could not verify is
    marked so. Table <reference|tab:compare> sets OpenSheaf against ten
    systems, among them the three we found closest.
  </with>

  <big-table|<with|font-size|0.84|<tformat|<twith|table-width|1par>|<twith|table-hmode|exact>|<cwith|1|-1|1|-1|cell-hyphen|t>|<cwith|1|-1|1|-1|cell-valign|top>|<cwith|1|-1|1|-1|cell-halign|l>|<cwith|1|-1|1|-1|cell-lsep|0.3em>|<cwith|1|-1|1|-1|cell-rsep|0.3em>|<cwith|1|1|1|-1|font-series|bold>|<cwith|3|3|1|-1|cell-background|#f2f4f7>|<cwith|5|5|1|-1|cell-background|#f2f4f7>|<cwith|7|7|1|-1|cell-background|#f2f4f7>|<cwith|9|9|1|-1|cell-background|#f2f4f7>|<cwith|1|1|1|-1|cell-background|#dde4ee>|<cwith|1|-1|1|-1|cell-tsep|0.25em>|<cwith|1|-1|1|-1|cell-bsep|0.25em>|<cwith|1|1|1|-1|cell-tborder|1ln>|<cwith|1|1|1|-1|cell-bborder|0.5ln>|<cwith|-1|-1|1|-1|cell-bborder|1ln>|<cwith|1|-1|1|1|cell-hpart|1>|<cwith|1|-1|2|2|cell-hpart|1>|<cwith|1|-1|3|3|cell-hpart|1>|<cwith|1|-1|4|4|cell-hpart|1>|<cwith|1|-1|5|5|cell-hpart|1>|<cwith|1|-1|6|6|cell-hpart|1>|<cwith|1|-1|7|7|cell-hpart|1>|<table|<row|<cell|<with|par-mode|left|System>>|<cell|<with|par-mode|left|Fixity>>|<cell|<with|par-mode|left|Names>>|<cell|<with|par-mode|left|Who
  writes>>|<cell|<with|par-mode|left|Copies>>|<cell|<with|par-mode|left|Identity>>|<cell|<with|par-mode|left|Requires>>>|<row|<cell|<with|par-mode|left|Nanopublications>>|<cell|<with|par-mode|left|SHA-256
  Trusty URI>>|<cell|<with|par-mode|left|content
  digest>>|<cell|<with|par-mode|left|any key, quota by
  trust>>|<cell|<with|par-mode|left|registries replicate and
  check>>|<cell|<with|par-mode|left|RSA key, ORCID by
  declaration>>|<cell|<with|par-mode|left|registry
  servers>>>|<row|<cell|<with|par-mode|left|DSI and
  DSGL>>|<cell|<with|par-mode|left|git hashes
  (SHA-1)>>|<cell|<with|par-mode|left|initial
  commit>>|<cell|<with|par-mode|left|SSH keys listed in the
  succession>>|<cell|<with|par-mode|left|any git host, Software
  Heritage>>|<cell|<with|par-mode|left|Ed25519 SSH
  keys>>|<cell|<with|par-mode|left|a git host>>>|<row|<cell|<with|par-mode|left|Underlay>>|<cell|<with|par-mode|left|SHA-256,
  prolly trees>>|<cell|<with|par-mode|left|server namespace, version
  hash>>|<cell|<with|par-mode|left|the collection's server; authors sign in
  v3>>|<cell|<with|par-mode|left|S3 mirrors checked by
  hash>>|<cell|<with|par-mode|left|accounts; author keys in
  v3>>|<cell|<with|par-mode|left|an authoritative
  server>>>|<row|<cell|<with|par-mode|left|DeSci
  Nodes>>|<cell|<with|par-mode|left|IPFS CIDs, Ceramic
  stream>>|<cell|<with|par-mode|left|integer in a
  contract>>|<cell|<with|par-mode|left|stream
  controller>>|<cell|<with|par-mode|left|IPFS pinning, Codex
  nodes>>|<cell|<with|par-mode|left|wallet DID, ORCID in
  profile>>|<cell|<with|par-mode|left|chain, registry, stream
  service>>>|<row|<cell|<with|par-mode|left|Hypergraph
  (Dat)>>|<cell|<with|par-mode|left|Hypercore signed
  log>>|<cell|<with|par-mode|left|public key and
  version>>|<cell|<with|par-mode|left|holder of the write
  key>>|<cell|<with|par-mode|left|peers seed>>|<cell|<with|par-mode|left|the
  key>>|<cell|<with|par-mode|left|online peers (ended
  2021)>>>|<row|<cell|<with|par-mode|left|dokieli>>|<cell|<with|par-mode|left|Memento,
  web archive>>|<cell|<with|par-mode|left|URL>>|<cell|<with|par-mode|left|WebID
  holder>>|<cell|<with|par-mode|left|web archives>>|<cell|<with|par-mode|left|WebID;
  RSA keys since 2026>>|<cell|<with|par-mode|left|a storage
  server>>>|<row|<cell|<with|par-mode|left|eLife, PCI,
  Episciences>>|<cell|<with|par-mode|left|none
  published>>|<cell|<with|par-mode|left|DOI, version,
  URL>>|<cell|<with|par-mode|left|journal or
  group>>|<cell|<with|par-mode|left|own copies at
  most>>|<cell|<with|par-mode|left|accounts,
  ORCID>>|<cell|<with|par-mode|left|the preprint
  server>>>|<row|<cell|<with|par-mode|left|PubPub>>|<cell|<with|par-mode|left|by
  the application>>|<cell|<with|par-mode|left|DOI per pub,
  URL>>|<cell|<with|par-mode|left|community
  members>>|<cell|<with|par-mode|left|exports,
  self-hosting>>|<cell|<with|par-mode|left|accounts, ORCID
  sign-in>>|<cell|<with|par-mode|left|running
  services>>>|<row|<cell|<with|par-mode|left|OpenSheaf>>|<cell|<with|par-mode|left|SHA-512
  inventories, pins>>|<cell|<with|par-mode|left|genesis digest and owner
  name>>|<cell|<with|par-mode|left|the line's
  owner>>|<cell|<with|par-mode|left|any archive,
  checked>>|<cell|<with|par-mode|left|key log,
  pre-rotation>>|<cell|<with|par-mode|left|a static web
  server>>>>>>|OpenSheaf and ten systems, in eight rows.<label|tab:compare>>

  <\with|par-columns|2>
    <subsection|Versions, links and identifiers><label|sec:dl>

    The digital-library literature has measured what OpenSheaf is meant to
    prevent. One article in five in science, technology and medicine suffers
    from reference rot, and seven in ten of those that cite web resources
    <cite|klein2014>; for over three quarters of the references to the web,
    the content has drifted from what was cited <cite|jones2016>.
    <strong|Memento> reaches earlier states of a resource through its
    original URI and a datetime <cite|rfc7089|vandesompel2009>, and
    <strong|Robust Links> add to a link the address of an archived snapshot
    and its date <cite|vandesompel2014|jones2016>. Both find a version by
    time and rely on the archive that returns it; a pin names a version by
    digest, and any copy can be checked against it. A Memento of a landing
    page still records what a server showed, which a pin does not.

    Versions of articles have names for their stages but no identifiers. The
    NISO/ALPSP recommendations name seven stages, from the author's original
    to the version of record <cite|jav2008>; OpenSheaf records the stage as a
    field of a version (Listing <reference|lst:object>), not as its identity.
    Studies of preprints find that the text changes little between a preprint
    and the published article <cite|klein2019>, but that the conclusions of
    some abstracts change <cite|brierley2022>; to compare versions, each
    study had first to match them, by identifiers, titles and authors. Data
    versioning meets the same gap: the first of its proposed principles asks
    that each revision be identified on its own <cite|klump2021>, which a pin
    does for every object version.

    Persistent identifiers rest on services. Kahn and Wilensky's framework
    names digital objects by handles resolved by a registry <cite|kahn2006>;
    DOIs <cite|paskin2010> and ARKs follow it, and the ARK scheme states that
    "persistence is purely a matter of service" <cite|kunze2026>. Guidance
    for identifiers asks that they never be deleted or reassigned, and carry
    nothing likely to change <cite|mcmurry2017>. OpenSheaf's names follow
    this guidance and add what a service cannot give: a name checked against
    the genesis record, and versions checked against the bytes, without the
    registry. They do not replace DOIs, which OpenSheaf records as relations.
    OAIS asks an archive to keep fixity information <cite|oais2012>; an OCFL
    inventory keeps it, and a pin turns it into a name. Van de Sompel and
    Nelson observe that "the notion of a repository does not exist in the
    Architecture of the World Wide Web" <cite|vandesompel2015>; OpenSheaf
    likewise names lines and versions, not archives. <strong|Signposting>
    exposes, by typed links on a landing page, the identifier to cite, the
    files and the metadata <cite|signposting2023>; the landing pages of the
    website profile could carry them.

    <subsection|Content-addressed and signed records>

    <strong|Nanopublications> are small RDF statements <cite|groth2010>,
    named by Trusty URIs, which end with a SHA-256 digest of the content
    <cite|kuhn2014>, and replicated between servers <cite|kuhn2016>. The
    current Nanopub Registry accepts only signed nanopublications, gives each
    key a quota derived from endorsements by trusted agents, and lets a
    declaration bind an ORCID iD to a key <cite|kuhn2026>; a snapshot of 4
    May 2026 counts 79,672 nanopublications by 616 signing agents
    <cite|kuhn2026>. A Trusty URI names one content, so a work has no name
    across its versions, and the documented queries count a supersession only
    under the same key. Nanopublications are a natural form for statements
    about OpenSheaf versions, which are open (#21).

    <strong|Document Succession Identifiers> are the closest design in
    premises <cite|ellerman2024b>: a succession of editions is a git history
    named from its initial commit, each later commit signed with an SSH key
    listed in the succession. Authority rests on keys, so a succession moves
    between hosts. As we read it, a listed key can sign a commit that changes
    the list, so a thief holding one could extend and contest the succession;
    pre-rotation exists to prevent this, at the cost of more keys. A DSI
    names one succession, rests on SHA-1, and has no owners shared across
    documents, no branches of other owners, no collections and no withdrawal.

    <strong|The Underlay> keeps collections of content-addressed records with
    immutable, sequential versions, append-only logs signed by the server
    after Certificate Transparency, and mirrors checked against hashes
    <cite|kf2026a|kf2026c>. Each collection has one authoritative server; in
    its draft third protocol authors may sign changes, but one authority
    still accepts versions <cite|underlayprotocol>. Its salted commitments to
    private records bear on blind review (#63). <strong|SWHIDs> name source
    code by intrinsic digests <cite|dicosmo2018> and are now an ISO standard
    <cite|iso18670>, with no identity, signature or notion of a work;
    OpenSheaf records them as relations and witnesses. <strong|RO-Crate>
    describes research packages and leaves fixity to the packaging, OCFL
    among them <cite|rocrate2022>.

    <subsection|Peer-to-peer and blockchain publishing>

    <strong|DeSci Nodes> name research objects by dPIDs, integers in an
    upgradeable registry contract deployed on a test network, with histories
    as Ceramic streams anchored on Ethereum <cite|descinodes>; Ceramic's
    developers deprecated the software it used in 2025 <cite|ceramic2025>,
    and we could not verify whether its anchor service has closed. A
    <no-break-start><verbatim|sheaf:><no-break-end> name is checked without a
    registry, chain or stream service. <strong|Hypergraph>, built on Dat
    <cite|hartgerink2019>, named each module by a public key, so the module's
    identity and the authority to write it were one secret; it ended in 2021,
    for reasons we could not verify, and its successor, ResearchEquals, keeps
    a static archive as its safety net <cite|researchequals>. The other
    <strong|blockchain platforms> for publishing we found closed or dropped
    the chain, as Orvium and Pluto did <cite|orvium|pluto2019>; what lasted
    is the dated digest, as in bloxberg's proofs of existence
    <cite|wittek2020> and Ledger's signed digests, whose Bitcoin timestamps
    are unverified <cite|ledger>. OpenSheaf keeps dated digests as optional
    witnesses, in its timestamps extension.

    <subsection|Linked data, personal servers and signing>

    <strong|dokieli> and Linked Research publish articles as linked data on
    authors' servers <cite|capadisli2017|capadisli2020>; versions are fixed
    by Mementos and web archives, identity is a WebID, and since 2026 dokieli
    signs annotations, as nanopublications, with RSA keys that are added,
    never replaced, and so cannot be rotated after a theft <cite|dokieli>; we
    could not verify whether whole articles are signed. <strong|Solid> pods
    are mutable stores behind access control <cite|solid>, and the
    ResearcherPod work records the life of an artefact as notifications kept
    by each party <cite|hochstenbach2023>. <strong|Sigstore>, as used by
    PyPI, binds short-lived certificates to a workflow identity and dates
    signatures in a transparency log <cite|pep740>; <strong|C2PA> is proposed
    for research images <cite|oric2pa>, but we found no publisher adopting
    it. These bind a signature to an identity checked at signing time by a
    third party; OpenSheaf binds it to a key log that checks itself, and its
    signatures carry no time. A Sigstore signature over a pin could be a
    witness (#41).

    <subsection|Overlays and platforms>

    <strong|eLife>'s docmaps fix the preprint versions it reviews by DOI,
    version, URL and archived packages, but by no digest <cite|elife>;
    <strong|Docmaps> describe such editorial events <cite|mcdowell2021>.
    <strong|Peer Community In> recommends a particular version of a preprint,
    and <strong|Episciences> asks for the version submitted
    <cite|pci|episciences>. Each overlay fixes what it vetted by a number or
    URL, valid while the server keeps it; a selection pins it by digest,
    checked in any copy. <strong|PubPub> has releases numbered from 1, like
    document versions, but fixed by a rule of its database, with DOIs for
    pubs, not releases <cite|pubpubcode>; in June 2025, after a funder
    withdrew, it announced the end of its hosted services, and in January
    2026 reversed this <cite|kf2025b|kf2026f>. Its export to the Underlay
    comes closest to OpenSheaf, with files named by SHA-256 but fixed by a
    server's log, not signed.

    <subsection|Repositories, preservation and harvesting>

    <strong|LOCKSS> libraries keep copies of the same content and compare
    them to repair damage, and <strong|CLOCKSS> keeps dark copies of journals
    <cite|maniatis2003|lockss>; with pins, any node's copy is checked alone.
    <strong|COAR Notify> carries review requests and announcements between
    repositories and services <cite|coarnotify>, implementing part of Pubfair
    <cite|pubfair2019>; its notices name resources by URI, with no digest or
    signature, and could carry pins. <strong|OAI-PMH> harvests metadata
    <cite|oaipmh>; the discovery document and feed play its part with
    verifiable content. <strong|DOIs> resolve through registries to wherever
    a work is said to be, and do not fix bytes; a pin says which bytes a
    DOI's work is.

    <subsection|Federated and distributed systems>

    <strong|ActivityPub> needs a running server per node and binds identity
    to a domain <cite|activitypub>; it suits announcement, which the layer
    leaves to others. <strong|The AT Protocol> is the closest in
    architecture, with signed user repositories, relays and third-party feeds
    <cite|atproto>, but its repositories are mutable and its main identity
    method depends on a directory; an OpenSheaf owner needs none, and pays
    with the rule that a fork ends it. <strong|Nostr> signs at the source,
    but its identity is the key itself <cite|nostr>. <strong|IPFS> fetches
    content by hash <cite|ipfs>; an OpenSheaf pin also fixes all earlier
    versions, and, unlike a pin in IPFS, keeps nothing available.
    <strong|Distributed hash tables> <cite|kademlia2002> answer where a copy
    is, which pins do not, and could serve as optional resolvers (#20).
    <strong|Git> links commits by hashes, SHA-1 in most repositories;
    OpenSheaf uses it as a store, its integrity staying in OCFL inventories
    <cite|git02>. <strong|Radicle> names repositories by a digest and peers
    by keys, each peer writing only its own namespace, with delegates changed
    by a threshold of the previous ones <cite|radicle>; OpenSheaf took from
    it, as from The Update Framework <cite|tuf>, a key log signed by keys of
    the version before, and added pre-rotation and plain files.

    <subsection|arXiv, Hexagon and alphaXiv>

    <strong|arXiv> keeps every version and its sources, refuses changes in
    place because they would be backdated, and since 2026 has dark copies at
    Portico and TIB <cite|arxivreplace|arxivblog2026>. But its record is
    fixed only by its word, with no digest published; its DOIs name articles,
    not versions; and its default licence gives it a right to distribute that
    it cannot pass on. OpenSheaf adds pins, signatures, versions never on
    arXiv and selections that say what they vetted, and cannot replace
    arXiv's announcement. <strong|Hexagon>, a repository for the mathematical
    sciences opened in September 2026, accepts works written in part or
    entirely by language models, records how each version was made and
    publishes SHA-256 digests of files <cite|antieau2026|hexagon>; signatures
    were not found, and OpenSheaf has no field for provenance.
    <strong|alphaXiv> grew from discussing arXiv papers into a service that
    also records; its pages describe no digests <cite|alphaxiv>.

    <subsection|What is new, and what is not><label|sec:new>

    Most of OpenSheaf's parts exist elsewhere (Table <reference|tab:new>).
    What we did not find is their combination, for scholarly documents: a
    name of the work shared by the lines of several owners, apart from hosts
    and keys; owners with key logs and pre-rotation; collections that pin
    other parties' versions as signed objects, keeping whole objects apart
    from vetting versions; rules for withdrawal, takedown and the rights of
    copies in a federation where no archive binds another; and static files
    as the whole requirement. Each closest design has parts OpenSheaf lacks:
    nanopublications a working network with trust and quotas, the Underlay
    salted commitments and packs, DSGL the simplicity of one git history per
    document.

    <big-table|<with|font-size|0.84|<tformat|<twith|table-width|1par>|<twith|table-hmode|exact>|<cwith|1|-1|1|-1|cell-hyphen|t>|<cwith|1|-1|1|-1|cell-valign|top>|<cwith|1|-1|1|-1|cell-halign|l>|<cwith|1|-1|1|-1|cell-lsep|0.3em>|<cwith|1|-1|1|-1|cell-rsep|0.3em>|<cwith|1|1|1|-1|font-series|bold>|<cwith|3|3|1|-1|cell-background|#f2f4f7>|<cwith|5|5|1|-1|cell-background|#f2f4f7>|<cwith|7|7|1|-1|cell-background|#f2f4f7>|<cwith|9|9|1|-1|cell-background|#f2f4f7>|<cwith|11|11|1|-1|cell-background|#f2f4f7>|<cwith|13|13|1|-1|cell-background|#f2f4f7>|<cwith|15|15|1|-1|cell-background|#f2f4f7>|<cwith|1|1|1|-1|cell-background|#dde4ee>|<cwith|1|-1|1|-1|cell-tsep|0.25em>|<cwith|1|-1|1|-1|cell-bsep|0.25em>|<cwith|1|1|1|-1|cell-tborder|1ln>|<cwith|1|1|1|-1|cell-bborder|0.5ln>|<cwith|-1|-1|1|-1|cell-bborder|1ln>|<cwith|1|-1|1|1|cell-hpart|1>|<cwith|1|-1|2|2|cell-hpart|1>|<table|<row|<cell|<with|par-mode|left|Element>>|<cell|<with|par-mode|left|Earlier
    work>>>|<row|<cell|<with|par-mode|left|names from content
    digests>>|<cell|<with|par-mode|left|Trusty URIs, SWHIDs,
    IPFS>>>|<row|<cell|<with|par-mode|left|versions signed by
    authors>>|<cell|<with|par-mode|left|DSGL, Dat, Ledger,
    nanopublications>>>|<row|<cell|<with|par-mode|left|a name from the first
    state>>|<cell|<with|par-mode|left|DSIs>>>|<row|<cell|<with|par-mode|left|new
    signed records, nothing deleted>>|<cell|<with|par-mode|left|nanopublications>>>|<row|<cell|<with|par-mode|left|copies
    checked by digest>>|<cell|<with|par-mode|left|nanopub registries,
    Underlay, LOCKSS>>>|<row|<cell|<with|par-mode|left|append-only signed
    logs>>|<cell|<with|par-mode|left|Underlay, after
    CT>>>|<row|<cell|<with|par-mode|left|dated
    digests>>|<cell|<with|par-mode|left|bloxberg, OpenTimestamps, Ledger
    (unverified)>>>|<row|<cell|<with|par-mode|left|overlays over versions
    held elsewhere>>|<cell|<with|par-mode|left|PCI, Episciences,
    eLife>>>|<row|<cell|<with|par-mode|left|packaging with
    digests>>|<cell|<with|par-mode|left|BagIt, OCFL,
    RO-Crate>>>|<row|<cell|<with|par-mode|left|static files or a git host
    only>>|<cell|<with|par-mode|left|DSGL, BagIt, OCFL, ResearchEquals'
    static archive>>>|<row|<cell|<with|par-mode|left|a work name shared by
    several owners>>|<cell|<with|par-mode|left|not
    found>>>|<row|<cell|<with|par-mode|left|owner key logs with
    pre-rotation>>|<cell|<with|par-mode|left|KERI, not for
    documents>>>|<row|<cell|<with|par-mode|left|collections pinning others'
    versions>>|<cell|<with|par-mode|left|not
    found>>>|<row|<cell|<with|par-mode|left|rules for takedown in a
    federation>>|<cell|<with|par-mode|left|not
    found>>>|<row|<cell|<with|par-mode|left|all of the above as static
    files>>|<cell|<with|par-mode|left|not found>>>>>>|What is new and what is
    not, among the systems we examined.<label|tab:new>>

    <section|Evaluation and limitations><label|sec:eval>

    Earlier designs ended for lack of funding or of a steward, or by
    depending on a token, a chain, peers online or a service run by someone
    else; others were overtaken by other services, and the most successful
    remains small (Section <reference|sec:related>). OpenSheaf avoids the
    dependencies and shares the rest; we weigh it against them.

    <paragraph|Adoption>An exchange layer is worth something only when
    several parties use it, and OpenSheaf has one real archive. The most
    successful decentralised design found, nanopublications, counts some
    80,000 records by some 600 signers after more than fifteen years
    <cite|kuhn2026>. What is needed next is a service people use on top: an
    announcement service for a field, or an overlay journal on authors' own
    archives.

    <paragraph|Incentives>Researchers publish where evaluation counts:
    eLife's submissions fell by more than half after its indexing changed
    <cite|elife2025>. An OpenSheaf archive counts for nothing by itself, and
    reaches the indexes only through DOIs, landing pages for search engines,
    and overlays that do count. DOIs with an archive's own prefix are open
    (#8).

    <paragraph|Key management>OpenSheaf asks more of authors than the
    comparable designs we examined (dokieli, DSGL, nanopublications): a
    current key on each device and rotation keys kept apart, for a better
    answer to theft. The Manager and passkeys lower the cost; whether authors
    will bear it is untested, and a per-owner key log may not be worth it to
    authors who never meet a theft. Weighted thresholds for groups (#69) and
    witnesses of which key-log version was seen first (#70) are left for
    after 0.2.

    <paragraph|Discovery and scale>Without indexes of many archives, a line
    whose archives have gone is hard to find, however checkable its copies;
    who keeps them is open (#20), as are a gateway run by the project (#35)
    and registering <no-break-start><verbatim|sheaf><no-break-end> with IANA
    (#36). Feeds exist, but nothing aggregates them yet. Paged discovery
    documents and partial verification address large archives (#19); an
    aggregation of arXiv's size remains untried.

    <paragraph|Funding and rights>The tools, the Explorer and any gateway
    need maintainers; an archive needs only a static web server, and stays
    readable with any OCFL tool and the specification if every OpenSheaf tool
    stops. Copies need rights, and in the first archive few lines can be
    copied without the authors' agreement.

    <paragraph|Open questions>As of 22 November 2026 every open issue of the
    specification is marked as an addition after 0.2 or as a task. Besides
    those above, they include: external records that resolve pins (#22);
    reviews, comments and relations between documents (#21); statements by
    collections about their members (#40); owner proofs beyond the keeper
    (#41); custodians' copies (#39) and policies (#54); blind review (#63);
    owner catalogues bound to their archive (#76); and bundles of a
    collection with its members (#74).

    <section|Conclusion><label|sec:conclusion>

    We have argued that the functions of scholarly communication stay bundled
    in part because nothing lets separate parties rely on one another's work.
    OpenSheaf proposes a common form for that: documents fixed by digests and
    named apart from their hosts and keys, owners who sign their lines and
    can answer the theft of a signing key, and catalogues and selections that
    are themselves fixed and checkable. On it, recording can stay with
    authors, preservation can be shared by institutions, and announcing,
    filtering and assigning merit can be built by anyone, without asking the
    archives. Version 0.2 is a draft, with tools, a formal model and a first
    archive; whether it is adopted depends on the services built on it.

    <section*|References>

    <\bib-list|83>
      <bibitem*|1><label|bib-roosendaal1997>H. E. Roosendaal and P. A. Th. M.
      Geurts. Forces and functions in scientific communication: an analysis
      of their interplay. CRISP 97, Cooperative Research Information Systems
      in Physics, Oldenburg, 1997.

      <bibitem*|2><label|bib-vandesompel2004>H. Van de Sompel, S. Payette, J.
      Erickson, C. Lagoze and S. Warner. Rethinking scholarly communication:
      building the system that scholars deserve. D-Lib Magazine 10 (9), 2004.
      https://<line-break>dlib.<line-break>org/<line-break>dlib/<line-break>september04/<line-break>vandesompel/<line-break>09vandesompel.<line-break>html

      <bibitem*|3><label|bib-smith1999>J. W. T. Smith. The deconstructed
      journal: a new model for academic publishing. Learned Publishing 12
      (2), 1999.

      <bibitem*|4><label|bib-priem2012>J. Priem and B. M. Hemminger.
      Decoupling the scholarly journal. Frontiers in Computational
      Neuroscience 6, 2012.

      <bibitem*|5><label|bib-pubfair2019>T. Ross-Hellauer, B. Fecher, K.
      Shearer and E. Rodrigues. Pubfair: a distributed framework for open
      publishing services, version 2. COAR, 2019.

      <bibitem*|6><label|bib-elife>eLife. eLife's new model: your questions
      answered. https://<line-break>elifesciences.<line-break>org/<line-break>inside-<line-break>elife/<line-break>2b765a27/<line-break>elife-<line-break>s-<line-break>new-<line-break>model-<line-break>your-<line-break>questions-<line-break>answered

      <bibitem*|7><label|bib-pci>Peer Community In. Frequently asked
      questions. https://<line-break>peercommunityi<line-break>n.<line-break>org/<line-break>faq/<line-break>

      <bibitem*|8><label|bib-episciences>Episciences. Publishing model.
      https://<line-break>www.<line-break>episciences.<line-break>org/<line-break>publishing-<line-break>model/<line-break>

      <bibitem*|9><label|bib-klein2014>M. Klein, H. Van de Sompel, R.
      Sanderson, H. Shankar, L. Balakireva, K. Zhou and R. Tobin. Scholarly
      context not found: one in five articles suffers from reference rot.
      PLoS ONE 9 (12), e115253, 2014. doi:10.1371/journal.pone.0115253

      <bibitem*|10><label|bib-jones2016>S. M. Jones, H. Van de Sompel, H.
      Shankar, M. Klein, R. Tobin and C. Grover. Scholarly context adrift:
      three out of four URI references lead to changed content. PLoS ONE 11
      (12), e0167475, 2016. doi:10.1371/journal.pone.0167475

      <bibitem*|11><label|bib-spec02>OpenSheaf project. OpenSheaf: an open
      format for document archives and collections, version 0.2 (draft), 22
      November 2026. OpenSheaf, 2026. https://<line-break>opensheaf.<line-break>org/<line-break>opensheaf-<line-break>specification-<line-break>0.<line-break>2

      <bibitem*|12><label|bib-ocfl>OCFL. Oxford Common File Layout
      specification, version 1.1. https://<line-break>ocfl.<line-break>io/<line-break>1.<line-break>1/<line-break>spec/<line-break>

      <bibitem*|13><label|bib-datacite>DataCite. DataCite Metadata Schema
      4.7. https://<line-break>schema.<line-break>datacite.<line-break>org/<line-break>meta/<line-break>kernel-<line-break>4.<line-break>7/<line-break>

      <bibitem*|14><label|bib-keri2019>S. M. Smith. Key Event Receipt
      Infrastructure (KERI). White paper, 2019.
      https://<line-break>arxiv.<line-break>org/<line-break>abs/<line-break>1907.<line-break>02143

      <bibitem*|15><label|bib-timestamps02>OpenSheaf project. OpenSheaf
      timestamps, version 0.2 (draft), 21 November 2026. Extension to the
      OpenSheaf specification 0.2, 2026. https://<line-break>opensheaf.<line-break>org/<line-break>opensheaf-<line-break>timestamps-<line-break>0.<line-break>2

      <bibitem*|16><label|bib-git02>OpenSheaf project. OpenSheaf archives in
      git, version 0.2 (draft), 22 November 2026. Companion to the OpenSheaf
      specification 0.2, 2026. https://<line-break>opensheaf.<line-break>org/<line-break>opensheaf-<line-break>git-<line-break>0.<line-break>2

      <bibitem*|17><label|bib-tools>OpenSheaf project. opensheaf-py, a
      literate program, and The command-line tools, its guide. 2026.
      https://<line-break>github.<line-break>com/<line-break>opensheaf/<line-break>opensheaf-<line-break>py
      and https://<line-break>opensheaf.<line-break>org/<line-break>tools

      <bibitem*|18><label|bib-explorer>OpenSheaf project. The OpenSheaf
      Explorer. Literate program, 2026. https://<line-break>opensheaf.<line-break>org/<line-break>explorer/<line-break>
      (source: https://<line-break>github.<line-break>com/<line-break>opensheaf/<line-break>explorer)

      <bibitem*|19><label|bib-manager>OpenSheaf project. The OpenSheaf
      Manager. 2026. https://<line-break>manager.<line-break>opensheaf.<line-break>org/<line-break>
      (source: https://<line-break>github.<line-break>com/<line-break>opensheaf/<line-break>manager)

      <bibitem*|20><label|bib-template>OpenSheaf project. archive-template, a
      template for an OpenSheaf archive. 2026.
      https://<line-break>github.<line-break>com/<line-break>opensheaf/<line-break>archive-<line-break>template

      <bibitem*|21><label|bib-lean>OpenSheaf project. OpenSheaf in Lean.
      Literate program, 2026. https://<line-break>opensheaf.<line-break>org/<line-break>opensheaf-<line-break>lean/<line-break>
      (source: https://<line-break>github.<line-break>com/<line-break>opensheaf/<line-break>opensheaf-<line-break>lean)

      <bibitem*|22><label|bib-papers>M. Gubinelli. Papers of Massimiliano
      Gubinelli, an OpenSheaf archive. 2026.
      https://<line-break>mgubi.<line-break>org/<line-break>papers/<line-break>
      (repository: https://<line-break>github.<line-break>com/<line-break>mgubi/<line-break>papers)

      <bibitem*|23><label|bib-atproto>Bluesky. AT Protocol.
      https://<line-break>atproto.<line-break>com

      <bibitem*|24><label|bib-rfc7089>H. Van de Sompel, M. Nelson and R.
      Sanderson. HTTP framework for time-based access to resource states:
      Memento. RFC 7089, 2013. doi:10.17487/RFC7089

      <bibitem*|25><label|bib-vandesompel2009>H. Van de Sompel, M. L. Nelson,
      R. Sanderson, L. L. Balakireva, S. Ainsworth and H. Shankar. Memento:
      time travel for the Web. arXiv:0911.1112, 2009.

      <bibitem*|26><label|bib-vandesompel2014>H. Van de Sompel, M. Klein and
      H. Shankar. Towards robust hyperlinks for web-based scholarly
      communication. CICM 2014, LNCS 8543, 12-25, 2014.
      doi:10.1007/978-3-319-08434-3_2

      <bibitem*|27><label|bib-jav2008>NISO/ALPSP. Journal Article Versions
      (JAV): recommendations of the NISO/ALPSP JAV Technical Working Group.
      NISO RP-8-2008, 2008. doi:10.3789/niso-rp-8-2008

      <bibitem*|28><label|bib-klein2019>M. Klein, P. Broadwell, S. E. Farb
      and T. Grappone. Comparing published scientific journal articles to
      their pre-print versions. International Journal on Digital Libraries 20
      (4), 335-350, 2019. doi:10.1007/s00799-018-0234-1

      <bibitem*|29><label|bib-brierley2022>L. Brierley, F. Nanni, J. K.
      Polka, G. Dey, M. Pálfy, N. Fraser and J. A. Coates. Tracking changes
      between preprint posting and journal publication during a pandemic.
      PLOS Biology 20 (2), e3001285, 2022. doi:10.1371/journal.pbio.3001285

      <bibitem*|30><label|bib-klump2021>J. Klump, L. Wyborn, M. Wu, J.
      Martin, R. R. Downs and A. Asmi. Versioning data is about more than
      revisions: a conceptual framework and proposed principles. Data Science
      Journal 20, 12, 2021. doi:10.5334/dsj-2021-012

      <bibitem*|31><label|bib-kahn2006>R. Kahn and R. Wilensky. A framework
      for distributed digital object services. International Journal on
      Digital Libraries 6 (2), 115-123, 2006. doi:10.1007/s00799-005-0128-x

      <bibitem*|32><label|bib-paskin2010>N. Paskin. Digital Object Identifier
      (DOI) system. Encyclopedia of Library and Information Sciences, 3rd
      edition, 1586-1592, 2010. doi:10.1081/E-ELIS3-120044418

      <bibitem*|33><label|bib-kunze2026>J. Kunze and E. Bermès. The ARK
      identifier scheme. IETF Internet-Draft draft-kunze-ark-44, 2026.
      https://<line-break>datatracker.<line-break>ietf.<line-break>org/<line-break>doc/<line-break>draft-<line-break>kunze-<line-break>ark/<line-break>

      <bibitem*|34><label|bib-mcmurry2017>J. A. McMurry and others.
      Identifiers for the 21st century: how to design, provision, and reuse
      persistent identifiers to maximize utility and impact of life science
      data. PLOS Biology 15 (6), e2001414, 2017.
      doi:10.1371/journal.pbio.2001414

      <bibitem*|35><label|bib-oais2012>CCSDS. Reference Model for an Open
      Archival Information System (OAIS). Recommended Practice CCSDS
      650.0-M-2, 2012 (ISO 14721:2012; now CCSDS 650.0-M-3, ISO 14721:2025).

      <bibitem*|36><label|bib-vandesompel2015>H. Van de Sompel and M. L.
      Nelson. Reminiscing about 15 years of interoperability efforts. D-Lib
      Magazine 21 (11/12), 2015. doi:10.1045/november2015-vandesompel

      <bibitem*|37><label|bib-signposting2023>H. Van de Sompel, M. Klein, S.
      Jones, M. L. Nelson and others. FAIR Signposting profile. 2023.
      https://<line-break>signposting.<line-break>org/<line-break>FAIR/<line-break>

      <bibitem*|38><label|bib-groth2010>P. Groth, A. Gibson and J. Velterop.
      The anatomy of a nanopublication. Information Services and Use 30
      (1-2), 51-56, 2010. doi:10.3233/ISU-2010-0613

      <bibitem*|39><label|bib-kuhn2014>T. Kuhn and M. Dumontier. Trusty URIs:
      verifiable, immutable, and permanent digital artifacts for linked data.
      ESWC 2014, LNCS 8465, 395-410, 2014. doi:10.1007/978-3-319-07443-6_27

      <bibitem*|40><label|bib-kuhn2016>T. Kuhn and others. Decentralized
      provenance-aware publishing with nanopublications. PeerJ Computer
      Science 2, e78, 2016. doi:10.7717/peerj-cs.78

      <bibitem*|41><label|bib-kuhn2026>T. Kuhn, V. Balseiro, A. Caselli, Z.
      Plutschow, P. Sowinski and A. Danilenka. A robust decentralized
      infrastructure for trust-aware open knowledge sharing. ISWC 2026, LNCS,
      152-170, 2026. doi:10.1007/978-3-032-42015-2_8

      <bibitem*|42><label|bib-ellerman2024b>E. C. Ellerman. Document
      Succession Git Layout, edition 1.1. 2024.
      https://<line-break>pilot.<line-break>perm.<line-break>pub/<line-break>VGajCjaNP1Ugz5<line-break>8Khn1JWOEdMZ8/<line-break>

      <bibitem*|43><label|bib-kf2026a>Knowledge Futures. Underlay, revived.
      2026. https://<line-break>www.<line-break>knowledgefutur<line-break>es.<line-break>org/<line-break>updates/<line-break>2026-<line-break>04-<line-break>27-<line-break>underlay-<line-break>revived

      <bibitem*|44><label|bib-kf2026c>Knowledge Futures. Underlay moves to
      protocol v2. 2026. https://<line-break>www.<line-break>knowledgefutur<line-break>es.<line-break>org/<line-break>updates/<line-break>2026-<line-break>10-<line-break>06-<line-break>underlay-<line-break>protocol-<line-break>v2

      <bibitem*|45><label|bib-underlayprotocol>Knowledge Futures. The
      Underlay protocol. https://<line-break>underlay.<line-break>org/<line-break>docs/<line-break>protocol

      <bibitem*|46><label|bib-dicosmo2018>R. Di Cosmo, M. Gruenpeter and S.
      Zacchiroli. Identifiers for digital objects: the case of software
      source code preservation. iPRES 2018, 2018. doi:10.17605/OSF.IO/KDE56

      <bibitem*|47><label|bib-iso18670>ISO/IEC 18670:2025. The SoftWare Hash
      IDentifier (SWHID) specification. 2025.
      https://<line-break>www.<line-break>iso.<line-break>org/<line-break>standard/<line-break>89985.<line-break>html

      <bibitem*|48><label|bib-rocrate2022>S. Soiland-Reyes and others.
      Packaging research artefacts with RO-Crate. Data Science 5 (2), 97-138,
      2022. doi:10.3233/DS-210053

      <bibitem*|49><label|bib-descinodes>DeSci Labs. DeSci Nodes and Codex.
      2026. https://<line-break>github.<line-break>com/<line-break>desci-<line-break>labs/<line-break>nodes

      <bibitem*|50><label|bib-ceramic2025>Ceramic. The future of Ceramic.
      2025. https://<line-break>blog.<line-break>ceramic.<line-break>network/<line-break>the-<line-break>future-<line-break>of-<line-break>ceramic-<line-break>focusing-<line-break>on-<line-break>recall/<line-break>

      <bibitem*|51><label|bib-hartgerink2019>C. H. J. Hartgerink. Verified,
      shared, modular, and provenance based research communication with the
      Dat protocol. Publications 7 (2), 40, 2019.
      doi:10.3390/publications7020040

      <bibitem*|52><label|bib-researchequals>ResearchEquals.
      https://<line-break>researchequals<line-break>.<line-break>com/<line-break>

      <bibitem*|53><label|bib-orvium>Orvium.
      https://<line-break>orvium.<line-break>io/<line-break>

      <bibitem*|54><label|bib-pluto2019>Pluto Labs. Blockchain is NOT a cure
      to Academia. 2019. https://<line-break>medium.<line-break>com/<line-break>pluto-<line-break>inc/<line-break>blockchain-<line-break>is-<line-break>not-<line-break>a-<line-break>cure-<line-break>to-<line-break>academia-<line-break>ef352985526

      <bibitem*|55><label|bib-wittek2020>K. Wittek, D. Krakau, N. Wittek, J.
      Lawton and N. Pohlmann. Integrating bloxberg's proof of existence
      service with MATLAB. Frontiers in Blockchain 3, 2020.
      doi:10.3389/fbloc.2020.546264

      <bibitem*|56><label|bib-ledger>Ledger. About the journal.
      https://<line-break>ledger.<line-break>pitt.<line-break>edu/<line-break>ojs/<line-break>ledger/<line-break>about

      <bibitem*|57><label|bib-capadisli2017>S. Capadisli, A. Guy, R.
      Verborgh, C. Lange, S. Auer and T. Berners-Lee. Decentralised
      authoring, annotations and notifications for a read-write web with
      dokieli. ICWE 2017, LNCS, 469-481, 2017.
      doi:10.1007/978-3-319-60131-1_33

      <bibitem*|58><label|bib-capadisli2020>S. Capadisli. Linked Research on
      the Decentralised Web. Doctoral thesis, University of Bonn, 2020.
      https://<line-break>csarven.<line-break>ca/<line-break>linked-<line-break>research-<line-break>decentralised-<line-break>web

      <bibitem*|59><label|bib-dokieli>dokieli. Documentation.
      https://<line-break>dokie.<line-break>li/<line-break>docs

      <bibitem*|60><label|bib-solid>W3C Solid Community Group. Solid
      Protocol, version 0.11.0. 2024. https://<line-break>solidproject.<line-break>org/<line-break>TR/<line-break>protocol

      <bibitem*|61><label|bib-hochstenbach2023>P. Hochstenbach, R. Verborgh
      and H. Van de Sompel. Using event notifications, Solid and
      orchestration for decentralizing and decoupling scholarly
      communication. Code4Lib Journal 58, 2023.
      https://<line-break>journal.<line-break>code4lib.<line-break>org/<line-break>articles/<line-break>17823

      <bibitem*|62><label|bib-pep740>Python Software Foundation. PEP 740 and
      PyPI digital attestations. 2024. https://<line-break>docs.<line-break>pypi.<line-break>org/<line-break>attestations/<line-break>

      <bibitem*|63><label|bib-oric2pa>US Office of Research Integrity.
      Content provenance. https://<line-break>ori.<line-break>hhs.<line-break>gov/<line-break>content-<line-break>provenance

      <bibitem*|64><label|bib-mcdowell2021>G. S. McDowell, J. K. Polka, T.
      Ross-Hellauer and G. Stein. The DocMaps framework for representing
      assertions on research products in an extensible, machine-readable, and
      discoverable format. bioRxiv, 2021. doi:10.1101/2021.07.13.452204

      <bibitem*|65><label|bib-pubpubcode>Knowledge Futures. PubPub, source
      code. https://<line-break>github.<line-break>com/<line-break>knowledgefutur<line-break>es/<line-break>pubpub

      <bibitem*|66><label|bib-kf2025b>Knowledge Futures. Not enough: open
      infrastructure funding and the future of Knowledge Futures. 2025.
      https://<line-break>www.<line-break>knowledgefutur<line-break>es.<line-break>org/<line-break>updates/<line-break>2025-<line-break>06-<line-break>update/<line-break>

      <bibitem*|67><label|bib-kf2026f>Knowledge Futures. A path forward for
      PubPub. 2026. https://<line-break>www.<line-break>knowledgefutur<line-break>es.<line-break>org/<line-break>updates/<line-break>2026-<line-break>01-<line-break>update

      <bibitem*|68><label|bib-maniatis2003>P. Maniatis, D. S. H. Rosenthal,
      M. Roussopoulos, M. Baker, T. J. Giuli and Y. Muliadi. Preserving peer
      replicas by rate-limited sampled voting. SOSP 2003, 44-59, 2003.
      doi:10.1145/945445.945451

      <bibitem*|69><label|bib-lockss>LOCKSS and CLOCKSS.
      https://<line-break>www.<line-break>lockss.<line-break>org and
      https://<line-break>clockss.<line-break>org

      <bibitem*|70><label|bib-coarnotify>COAR. COAR Notify, version 1.0.1.
      https://<line-break>coar-<line-break>notify.<line-break>net

      <bibitem*|71><label|bib-oaipmh>Open Archives Initiative. The Protocol
      for Metadata Harvesting (OAI-PMH). https://<line-break>www.<line-break>openarchives.<line-break>org/<line-break>pmh/<line-break>

      <bibitem*|72><label|bib-activitypub>W3C. ActivityPub. W3C
      Recommendation, 2018. https://<line-break>www.<line-break>w3.<line-break>org/<line-break>TR/<line-break>activitypub/<line-break>

      <bibitem*|73><label|bib-nostr>Nostr. Nostr Implementation Possibilities
      (NIPs). https://<line-break>github.<line-break>com/<line-break>nostr-<line-break>protocol/<line-break>nips

      <bibitem*|74><label|bib-ipfs>IPFS. https://<line-break>ipfs.<line-break>tech

      <bibitem*|75><label|bib-kademlia2002>P. Maymounkov and D. Mazieres.
      Kademlia: a peer-to-peer information system based on the XOR metric.
      IPTPS, 2002.

      <bibitem*|76><label|bib-radicle>Radicle. Radicle protocol guide.
      https://<line-break>radicle.<line-break>xyz/<line-break>guides/<line-break>protocol

      <bibitem*|77><label|bib-tuf>The Update Framework.
      https://<line-break>theupdateframe<line-break>work.<line-break>io/<line-break>

      <bibitem*|78><label|bib-arxivreplace>arXiv. Replacing an article.
      https://<line-break>info.<line-break>arxiv.<line-break>org/<line-break>help/<line-break>replace.<line-break>html

      <bibitem*|79><label|bib-arxivblog2026>arXiv. Post of 3 February 2026 on
      dark archives at Portico and TIB. arXiv blog, 2026.
      https://<line-break>blog.<line-break>arxiv.<line-break>org/<line-break>

      <bibitem*|80><label|bib-antieau2026>B. Antieau. Hexagon. 2026.
      https://<line-break>antieau.<line-break>github.<line-break>io/<line-break>2026/<line-break>10/<line-break>05/<line-break>hexagon.<line-break>html

      <bibitem*|81><label|bib-hexagon>Hexagon.
      https://<line-break>hexagonmath.<line-break>org/<line-break>

      <bibitem*|82><label|bib-alphaxiv>alphaXiv.
      https://<line-break>www.<line-break>alphaxiv.<line-break>org/<line-break>

      <bibitem*|83><label|bib-elife2025>eLife. The eLife model: three-year
      update. 2025. https://<line-break>elifesciences.<line-break>org/<line-break>inside-<line-break>elife/<line-break>7da92a51/<line-break>the-<line-break>elife-<line-break>model-<line-break>three-<line-break>year-<line-break>update
    </bib-list>
  </with>
</body>

<\initial>
  <\collection>
    <associate|font-base-size|10>
    <associate|page-bot|2cm>
    <associate|page-even|1.8cm>
    <associate|page-medium|paper>
    <associate|page-odd|1.8cm>
    <associate|page-right|1.8cm>
    <associate|page-top|2cm>
    <associate|page-type|a4>
    <associate|par-columns-sep|1.5fn>
  </collection>
</initial>

<\references>
  <\collection>
    <associate|auto-1|<tuple|1|1>>
    <associate|auto-10|<tuple|7|2>>
    <associate|auto-11|<tuple|8|2>>
    <associate|auto-12|<tuple|3|2>>
    <associate|auto-13|<tuple|3.1|2>>
    <associate|auto-14|<tuple|1|2>>
    <associate|auto-15|<tuple|3.2|2>>
    <associate|auto-16|<tuple|2|3>>
    <associate|auto-17|<tuple|2|3>>
    <associate|auto-18|<tuple|3.3|3>>
    <associate|auto-19|<tuple|3|3>>
    <associate|auto-2|<tuple|1|1>>
    <associate|auto-20|<tuple|4|3>>
    <associate|auto-21|<tuple|3.4|3>>
    <associate|auto-22|<tuple|5|4>>
    <associate|auto-23|<tuple|1|4>>
    <associate|auto-24|<tuple|2|4>>
    <associate|auto-25|<tuple|3.5|4>>
    <associate|auto-26|<tuple|6|4>>
    <associate|auto-27|<tuple|3.6|4>>
    <associate|auto-28|<tuple|7|5>>
    <associate|auto-29|<tuple|3|5>>
    <associate|auto-3|<tuple|2|1>>
    <associate|auto-30|<tuple|3.7|5>>
    <associate|auto-31|<tuple|3.8|5>>
    <associate|auto-32|<tuple|3.9|5>>
    <associate|auto-33|<tuple|8|5>>
    <associate|auto-34|<tuple|9|6>>
    <associate|auto-35|<tuple|10|6>>
    <associate|auto-36|<tuple|3.10|6>>
    <associate|auto-37|<tuple|3.11|6>>
    <associate|auto-38|<tuple|3.12|6>>
    <associate|auto-39|<tuple|4|6>>
    <associate|auto-4|<tuple|1|1>>
    <associate|auto-40|<tuple|4.1|6>>
    <associate|auto-41|<tuple|11|7>>
    <associate|auto-42|<tuple|4.2|7>>
    <associate|auto-43|<tuple|4.3|7>>
    <associate|auto-44|<tuple|4.4|7>>
    <associate|auto-45|<tuple|4.5|8>>
    <associate|auto-46|<tuple|1|8>>
    <associate|auto-47|<tuple|2|8>>
    <associate|auto-48|<tuple|3|8>>
    <associate|auto-49|<tuple|5|8>>
    <associate|auto-5|<tuple|2|2>>
    <associate|auto-50|<tuple|4|8>>
    <associate|auto-51|<tuple|5.1|8>>
    <associate|auto-52|<tuple|5.2|9>>
    <associate|auto-53|<tuple|5.3|9>>
    <associate|auto-54|<tuple|5.4|9>>
    <associate|auto-55|<tuple|5.5|9>>
    <associate|auto-56|<tuple|5.6|10>>
    <associate|auto-57|<tuple|5.7|10>>
    <associate|auto-58|<tuple|5.8|10>>
    <associate|auto-59|<tuple|5.9|10>>
    <associate|auto-6|<tuple|3|2>>
    <associate|auto-60|<tuple|5|10>>
    <associate|auto-61|<tuple|6|10>>
    <associate|auto-62|<tuple|1|10>>
    <associate|auto-63|<tuple|2|10>>
    <associate|auto-64|<tuple|3|11>>
    <associate|auto-65|<tuple|4|11>>
    <associate|auto-66|<tuple|5|11>>
    <associate|auto-67|<tuple|6|11>>
    <associate|auto-68|<tuple|7|11>>
    <associate|auto-69|<tuple|7|11>>
    <associate|auto-7|<tuple|4|2>>
    <associate|auto-8|<tuple|5|2>>
    <associate|auto-9|<tuple|6|2>>
    <associate|bib-activitypub|<tuple|72|13>>
    <associate|bib-alphaxiv|<tuple|82|13>>
    <associate|bib-antieau2026|<tuple|80|13>>
    <associate|bib-arxivblog2026|<tuple|79|13>>
    <associate|bib-arxivreplace|<tuple|78|13>>
    <associate|bib-atproto|<tuple|23|12>>
    <associate|bib-brierley2022|<tuple|29|12>>
    <associate|bib-capadisli2017|<tuple|57|13>>
    <associate|bib-capadisli2020|<tuple|58|13>>
    <associate|bib-ceramic2025|<tuple|50|12>>
    <associate|bib-coarnotify|<tuple|70|13>>
    <associate|bib-datacite|<tuple|13|11>>
    <associate|bib-descinodes|<tuple|49|12>>
    <associate|bib-dicosmo2018|<tuple|46|12>>
    <associate|bib-dokieli|<tuple|59|13>>
    <associate|bib-elife|<tuple|6|11>>
    <associate|bib-elife2025|<tuple|83|13>>
    <associate|bib-ellerman2024b|<tuple|42|12>>
    <associate|bib-episciences|<tuple|8|11>>
    <associate|bib-explorer|<tuple|18|11>>
    <associate|bib-git02|<tuple|16|11>>
    <associate|bib-groth2010|<tuple|38|12>>
    <associate|bib-hartgerink2019|<tuple|51|12>>
    <associate|bib-hexagon|<tuple|81|13>>
    <associate|bib-hochstenbach2023|<tuple|61|13>>
    <associate|bib-ipfs|<tuple|74|13>>
    <associate|bib-iso18670|<tuple|47|12>>
    <associate|bib-jav2008|<tuple|27|12>>
    <associate|bib-jones2016|<tuple|10|11>>
    <associate|bib-kademlia2002|<tuple|75|13>>
    <associate|bib-kahn2006|<tuple|31|12>>
    <associate|bib-keri2019|<tuple|14|11>>
    <associate|bib-kf2025b|<tuple|66|13>>
    <associate|bib-kf2026a|<tuple|43|12>>
    <associate|bib-kf2026c|<tuple|44|12>>
    <associate|bib-kf2026f|<tuple|67|13>>
    <associate|bib-klein2014|<tuple|9|11>>
    <associate|bib-klein2019|<tuple|28|12>>
    <associate|bib-klump2021|<tuple|30|12>>
    <associate|bib-kuhn2014|<tuple|39|12>>
    <associate|bib-kuhn2016|<tuple|40|12>>
    <associate|bib-kuhn2026|<tuple|41|12>>
    <associate|bib-kunze2026|<tuple|33|12>>
    <associate|bib-lean|<tuple|21|12>>
    <associate|bib-ledger|<tuple|56|13>>
    <associate|bib-lockss|<tuple|69|13>>
    <associate|bib-manager|<tuple|19|11>>
    <associate|bib-maniatis2003|<tuple|68|13>>
    <associate|bib-mcdowell2021|<tuple|64|13>>
    <associate|bib-mcmurry2017|<tuple|34|12>>
    <associate|bib-nostr|<tuple|73|13>>
    <associate|bib-oaipmh|<tuple|71|13>>
    <associate|bib-oais2012|<tuple|35|12>>
    <associate|bib-ocfl|<tuple|12|11>>
    <associate|bib-oric2pa|<tuple|63|13>>
    <associate|bib-orvium|<tuple|53|13>>
    <associate|bib-papers|<tuple|22|12>>
    <associate|bib-paskin2010|<tuple|32|12>>
    <associate|bib-pci|<tuple|7|11>>
    <associate|bib-pep740|<tuple|62|13>>
    <associate|bib-pluto2019|<tuple|54|13>>
    <associate|bib-priem2012|<tuple|4|11>>
    <associate|bib-pubfair2019|<tuple|5|11>>
    <associate|bib-pubpubcode|<tuple|65|13>>
    <associate|bib-radicle|<tuple|76|13>>
    <associate|bib-researchequals|<tuple|52|13>>
    <associate|bib-rfc7089|<tuple|24|12>>
    <associate|bib-rocrate2022|<tuple|48|12>>
    <associate|bib-roosendaal1997|<tuple|1|11>>
    <associate|bib-signposting2023|<tuple|37|12>>
    <associate|bib-smith1999|<tuple|3|11>>
    <associate|bib-solid|<tuple|60|13>>
    <associate|bib-spec02|<tuple|11|11>>
    <associate|bib-template|<tuple|20|12>>
    <associate|bib-timestamps02|<tuple|15|11>>
    <associate|bib-tools|<tuple|17|11>>
    <associate|bib-tuf|<tuple|77|13>>
    <associate|bib-underlayprotocol|<tuple|45|12>>
    <associate|bib-vandesompel2004|<tuple|2|11>>
    <associate|bib-vandesompel2009|<tuple|25|12>>
    <associate|bib-vandesompel2014|<tuple|26|12>>
    <associate|bib-vandesompel2015|<tuple|36|12>>
    <associate|bib-wittek2020|<tuple|55|13>>
    <associate|lst:discovery|<tuple|1|2>>
    <associate|lst:genesis|<tuple|3|3>>
    <associate|lst:name|<tuple|4|3>>
    <associate|lst:object|<tuple|2|3>>
    <associate|lst:osheaf|<tuple|11|7>>
    <associate|lst:owner|<tuple|5|4>>
    <associate|lst:resolve|<tuple|10|6>>
    <associate|lst:selection|<tuple|7|5>>
    <associate|lst:signature|<tuple|6|4>>
    <associate|lst:uriforms|<tuple|8|5>>
    <associate|lst:uris|<tuple|9|6>>
    <associate|sec:archives|<tuple|3.1|2>>
    <associate|sec:branches|<tuple|3.7|5>>
    <associate|sec:collections|<tuple|3.6|4>>
    <associate|sec:conclusion|<tuple|7|11>>
    <associate|sec:dl|<tuple|5.1|8>>
    <associate|sec:drafts|<tuple|3.8|5>>
    <associate|sec:eval|<tuple|6|10>>
    <associate|sec:explorer|<tuple|4.2|7>>
    <associate|sec:format|<tuple|3|2>>
    <associate|sec:impl|<tuple|4|6>>
    <associate|sec:intro|<tuple|1|1>>
    <associate|sec:lean|<tuple|4.3|7>>
    <associate|sec:lessons|<tuple|4.5|8>>
    <associate|sec:lines|<tuple|3.5|4>>
    <associate|sec:names|<tuple|3.3|3>>
    <associate|sec:new|<tuple|5.9|10>>
    <associate|sec:objects|<tuple|3.2|2>>
    <associate|sec:owners|<tuple|3.4|3>>
    <associate|sec:papers|<tuple|4.4|7>>
    <associate|sec:principles|<tuple|2|1>>
    <associate|sec:profiles|<tuple|3.12|6>>
    <associate|sec:related|<tuple|5|8>>
    <associate|sec:tools|<tuple|4.1|6>>
    <associate|sec:uris|<tuple|3.9|5>>
    <associate|sec:verification|<tuple|3.11|6>>
    <associate|sec:withdrawal|<tuple|3.10|6>>
    <associate|tab:compare|<tuple|4|8>>
    <associate|tab:files|<tuple|2|3>>
    <associate|tab:functions|<tuple|1|1>>
    <associate|tab:new|<tuple|5|10>>
    <associate|tab:status|<tuple|3|5>>
  </collection>
</references>

<\auxiliary>
  <\collection>
    <\associate|bib>
      roosendaal1997

      vandesompel2004

      smith1999

      vandesompel2004

      priem2012

      pubfair2019

      elife

      pci

      episciences

      klein2014

      jones2016

      spec02

      ocfl

      datacite

      spec02

      keri2019

      timestamps02

      git02

      tools

      tools

      explorer

      manager

      template

      lean

      papers

      papers

      papers

      atproto

      keri2019

      klein2014

      jones2016

      rfc7089

      vandesompel2009

      vandesompel2014

      jones2016

      jav2008

      klein2019

      brierley2022

      klump2021

      kahn2006

      paskin2010

      kunze2026

      mcmurry2017

      oais2012

      vandesompel2015

      signposting2023

      groth2010

      kuhn2014

      kuhn2016

      kuhn2026

      kuhn2026

      ellerman2024b

      kf2026a

      kf2026c

      underlayprotocol

      dicosmo2018

      iso18670

      rocrate2022

      descinodes

      ceramic2025

      hartgerink2019

      researchequals

      orvium

      pluto2019

      wittek2020

      ledger

      capadisli2017

      capadisli2020

      dokieli

      solid

      hochstenbach2023

      pep740

      oric2pa

      elife

      mcdowell2021

      pci

      episciences

      pubpubcode

      kf2025b

      kf2026f

      maniatis2003

      lockss

      coarnotify

      pubfair2019

      oaipmh

      activitypub

      atproto

      nostr

      ipfs

      kademlia2002

      git02

      radicle

      tuf

      arxivreplace

      arxivblog2026

      antieau2026

      hexagon

      alphaxiv

      kuhn2026

      elife2025
    </associate>
    <\associate|listing>
      <tuple|normal|<\surround|<hidden-binding|<tuple>|1>|>
        An excerpt of the discovery document of appendix C.6:
        <no-break-start><with|font|<quote|IBM Plex
        Mono>|font-size|<quote|0.71485>|<with|font-family|<quote|tt>|language|<quote|verbatim>|contact>><no-break-end>
        and <no-break-start><with|font|<quote|IBM Plex
        Mono>|font-size|<quote|0.71485>|<with|font-family|<quote|tt>|language|<quote|verbatim>|extensions>><no-break-end>
        are left out, and of <no-break-start><with|font|<quote|IBM Plex
        Mono>|font-size|<quote|0.71485>|<with|font-family|<quote|tt>|language|<quote|verbatim>|objects>><no-break-end>
        only the paper's entry is shown.
      </surround>|<pageref|auto-14>>

      <tuple|normal|<\surround|<hidden-binding|<tuple>|2>|>
        The <no-break-start><with|font|<quote|IBM Plex
        Mono>|font-size|<quote|0.71485>|<with|font-family|<quote|tt>|language|<quote|verbatim>|object.json>><no-break-end>
        of the paper's first version (appendix C.2), lines broken to fit.
      </surround>|<pageref|auto-17>>

      <tuple|normal|<\surround|<hidden-binding|<tuple>|3>|>
        The genesis record of the example paper (appendix C.2).
      </surround>|<pageref|auto-19>>

      <tuple|normal|<\surround|<hidden-binding|<tuple>|4>|>
        Computing the names of a genesis record; checked against appendix C.
      </surround>|<pageref|auto-20>>

      <tuple|normal|<\surround|<hidden-binding|<tuple>|5>|>
        The genesis record of the authors' owner (appendix C.1); the data of
        the timestamps extension is elided.
      </surround>|<pageref|auto-22>>

      <tuple|normal|<\surround|<hidden-binding|<tuple>|6>|>
        A signature file of the paper's second version (appendix C.3).
      </surround>|<pageref|auto-26>>

      <tuple|normal|<\surround|<hidden-binding|<tuple>|7>|>
        A selection, an issue of a journal (appendix C.4);
        <no-break-start><with|font|<quote|IBM Plex
        Mono>|font-size|<quote|0.71485>|<with|font-family|<quote|tt>|language|<quote|verbatim>|cite>><no-break-end>
        is elided.
      </surround>|<pageref|auto-28>>

      <tuple|normal|<\surround|<hidden-binding|<tuple>|8>|>
        The forms of <no-break-start><with|font|<quote|IBM Plex
        Mono>|font-size|<quote|0.71485>|<with|font-family|<quote|tt>|language|<quote|verbatim>|sheaf:>><no-break-end>
        URIs (specification, section 12.1).
      </surround>|<pageref|auto-33>>

      <tuple|normal|<\surround|<hidden-binding|<tuple>|9>|>
        Some of the URIs of the paper, of the accepted copy and of the owner
        given in appendix C.7.
      </surround>|<pageref|auto-34>>

      <tuple|normal|<\surround|<hidden-binding|<tuple>|10>|>
        Resolution, after section 12.3 of the specification (pseudocode).
      </surround>|<pageref|auto-35>>

      <tuple|normal|<\surround|<hidden-binding|<tuple>|11>|>
        Creating an archive and an owner, depositing a paper and a second
        version, adding a notice about the first, and checking the archive
        [<write|bib|tools><reference|bib-tools>].
      </surround>|<pageref|auto-41>>
    </associate>
    <\associate|table>
      <tuple|normal|<surround|<hidden-binding|<tuple>|1>||The functions of
      scholarly communication.>|<pageref|auto-2>>

      <tuple|normal|<surround|<hidden-binding|<tuple>|2>||The files of an
      object and of its versions (specification, sections 4 to
      9).>|<pageref|auto-16>>

      <tuple|normal|<surround|<hidden-binding|<tuple>|3>||The statuses of a
      member, or of a revision in a selection (specification, section
      8.5).>|<pageref|auto-29>>

      <tuple|normal|<surround|<hidden-binding|<tuple>|4>||OpenSheaf and ten
      systems, in eight rows.>|<pageref|auto-50>>

      <tuple|normal|<surround|<hidden-binding|<tuple>|5>||What is new and
      what is not, among the systems we examined.>|<pageref|auto-60>>
    </associate>
    <\associate|toc>
      <vspace*|1fn><with|font-series|<quote|bold>|math-font-series|<quote|bold>|1<space|2spc>Introduction>
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-1><vspace|0.5fn>

      <vspace*|1fn><with|font-series|<quote|bold>|math-font-series|<quote|bold>|2<space|2spc>Design
      principles> <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-3><vspace|0.5fn>

      <with|par-left|<quote|3tab>|Fixity by digests
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-4>>

      <with|par-left|<quote|3tab>|Names independent of hosts and keys
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-5>>

      <with|par-left|<quote|3tab>|Authority in owners' keys, not in hosts
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-6>>

      <with|par-left|<quote|3tab>|Statements are objects of the same format
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-7>>

      <with|par-left|<quote|3tab>|Static files only
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-8>>

      <with|par-left|<quote|3tab>|Copies checkable anywhere
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-9>>

      <with|par-left|<quote|3tab>|Append-only history
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-10>>

      <with|par-left|<quote|3tab>|Archives answer for their own rights
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-11>>

      <vspace*|1fn><with|font-series|<quote|bold>|math-font-series|<quote|bold>|3<space|2spc>The
      format> <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-12><vspace|0.5fn>

      <with|par-left|<quote|1tab>|3.1<space|2spc>Archives and the discovery
      document <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-13>>

      <with|par-left|<quote|1tab>|3.2<space|2spc>Objects, versions and pins
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-15>>

      <with|par-left|<quote|1tab>|3.3<space|2spc>Names and genesis records
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-18>>

      <with|par-left|<quote|1tab>|3.4<space|2spc>Owners and key logs
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-21>>

      <with|par-left|<quote|3tab>|Exposure, ending and forks
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-23>>

      <with|par-left|<quote|3tab>|Travel and keepers
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-24>>

      <with|par-left|<quote|1tab>|3.5<space|2spc>Lines, signatures and
      statuses <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-25>>

      <with|par-left|<quote|1tab>|3.6<space|2spc>Collections
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-27>>

      <with|par-left|<quote|1tab>|3.7<space|2spc>Branches and accepted copies
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-30>>

      <with|par-left|<quote|1tab>|3.8<space|2spc>Drafts, mirrors and rights
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-31>>

      <with|par-left|<quote|1tab>|3.9<space|2spc>Identifiers, resolution and
      indexes <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-32>>

      <with|par-left|<quote|1tab>|3.10<space|2spc>Withdrawal, takedown and
      tombstones <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-36>>

      <with|par-left|<quote|1tab>|3.11<space|2spc>Verification and security
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-37>>

      <with|par-left|<quote|1tab>|3.12<space|2spc>Profiles and extensions
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-38>>

      <vspace*|1fn><with|font-series|<quote|bold>|math-font-series|<quote|bold>|4<space|2spc>Implementation>
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-39><vspace|0.5fn>

      <with|par-left|<quote|1tab>|4.1<space|2spc>Reference tools
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-40>>

      <with|par-left|<quote|1tab>|4.2<space|2spc>The Explorer and the Manager
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-42>>

      <with|par-left|<quote|1tab>|4.3<space|2spc>A formal model in Lean
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-43>>

      <with|par-left|<quote|1tab>|4.4<space|2spc>The first archive
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-44>>

      <with|par-left|<quote|1tab>|4.5<space|2spc>What implementing taught
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-45>>

      <with|par-left|<quote|3tab>|Rules a verifier can decide
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-46>>

      <with|par-left|<quote|3tab>|What a pin fixes
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-47>>

      <with|par-left|<quote|3tab>|Keys and forks
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-48>>

      <vspace*|1fn><with|font-series|<quote|bold>|math-font-series|<quote|bold>|5<space|2spc>Related
      work> <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-49><vspace|0.5fn>

      <with|par-left|<quote|1tab>|5.1<space|2spc>Versions, links and
      identifiers <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-51>>

      <with|par-left|<quote|1tab>|5.2<space|2spc>Content-addressed and signed
      records <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-52>>

      <with|par-left|<quote|1tab>|5.3<space|2spc>Peer-to-peer and blockchain
      publishing <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-53>>

      <with|par-left|<quote|1tab>|5.4<space|2spc>Linked data, personal
      servers and signing <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-54>>

      <with|par-left|<quote|1tab>|5.5<space|2spc>Overlays and platforms
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-55>>

      <with|par-left|<quote|1tab>|5.6<space|2spc>Repositories, preservation
      and harvesting <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-56>>

      <with|par-left|<quote|1tab>|5.7<space|2spc>Federated and distributed
      systems <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-57>>

      <with|par-left|<quote|1tab>|5.8<space|2spc>arXiv, Hexagon and alphaXiv
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-58>>

      <with|par-left|<quote|1tab>|5.9<space|2spc>What is new, and what is not
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-59>>

      <vspace*|1fn><with|font-series|<quote|bold>|math-font-series|<quote|bold>|6<space|2spc>Evaluation
      and limitations> <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-61><vspace|0.5fn>

      <with|par-left|<quote|3tab>|Adoption
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-62>>

      <with|par-left|<quote|3tab>|Incentives
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-63>>

      <with|par-left|<quote|3tab>|Key management
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-64>>

      <with|par-left|<quote|3tab>|Discovery and scale
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-65>>

      <with|par-left|<quote|3tab>|Funding and rights
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-66>>

      <with|par-left|<quote|3tab>|Open questions
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-67>>

      <vspace*|1fn><with|font-series|<quote|bold>|math-font-series|<quote|bold>|7<space|2spc>Conclusion>
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-68><vspace|0.5fn>

      <vspace*|1fn><with|font-series|<quote|bold>|math-font-series|<quote|bold>|References>
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-69><vspace|0.5fn>
    </associate>
  </collection>
</auxiliary>