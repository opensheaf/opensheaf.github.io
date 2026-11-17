<TeXmacs|2.1.5>

<style|<tuple|notes|notes-meta>>

<\body>
  <notes-header>

  <chapter*|OpenSheaf: use cases>

  How the <hlink|specification|opensheaf-specification-0.1.tm> adapts to the people and institutions that keep and select scholarly documents. It is non-normative: where it and the specification differ, the specification holds. Commands of the reference tools, <hlink|opensheaf-py|https://github.com/opensheaf/opensheaf-py> (<verbatim|osheaf>), are given as illustrations; any tool following the specification will do.

  Three roles recur:

  <\itemize>
    <item><hlink|<dfn|authors>|#authors> make documents and their versions;

    <item><hlink|<dfn|archives>|#archives> keep documents, every version, impartially: an author's own archive, an institution's repository, an independent storage site;

    <item><hlink|<dfn|selections>|#selections> vet particular versions (revisions) of documents: a journal, a digest, a review journal, a reading list, proceedings.
  </itemize>

  Archives list what they keep in <dfn|catalogues>, which pin objects whole and may follow them as they grow; selections are the other kind of collection of section 10, which pins revision sets and changes only by an act of its curator. Copies are of two kinds too: a <dfn|mirror> copies a whole line, with the key log of its owner (an archive keeping another owner's work), an <dfn|accepted copy> is a branch: a new line of the selection's owner, starting from one vetted revision. Collections and copies only concern documents kept in OpenSheaf archives: a paper that exists only on arXiv or on a publisher's site is first deposited in an archive (for instance imported from arXiv into its author's archive) before it can be pinned.

  Every line has an <dfn|owner>: a person, a group or an institution with keys, which signs every version it makes (section 6.5). An archive hosts the lines of any number of owners, and owns none of them by hosting them; it is found at its address, and has no identity of its own. A line is named by the work's name and its owner, written as a <verbatim|sheaf:> URI. The commands below name lines by their <strong|labels>, the readable names an archive gives them (section 6.3).

  <section*|Authors><label|authors>

  <subsection*|A researcher's own archive><label|a-researchers-own-archive>

  A mathematician keeps an archive of her papers on her website (the first archive, <hlink|mgubi.org/papers|https://mgubi.org/papers/>, is one).

  <\itemize>
    <item>She is an owner: her key log, kept in her archive at <verbatim|\<less\>owner\<gtr\>/\<less\>owner\<gtr\>/>, lists her keys (one for daily use, a spare kept apart), and every version she deposits is signed with them. Each paper is one of her lines, at <verbatim|\<less\>owner\<gtr\>/\<less\>name\<gtr\>/>, with a label (<verbatim|kpz-uniqueness>) for the website.

    <item>Work not yet shared can be a <strong|draft> (section 6.5), kept by her archive under the reserved owner <verbatim|draft>: unsigned, never copied, and free to be rewritten. When she first shares a paper, sealing makes its line.

    <item>Each version of the paper is a document version, numbered by her from 1 without gaps. Versions imported from arXiv keep arXiv's label (<verbatim|v3>) in <verbatim|external>.

    <item>A version that arXiv keeps only as a PDF is deposited without sources (<verbatim|sourcesMissing>); when she finds the sources, they complete that same version (section 7.3).

    <item>An early version or a submitted manuscript found later is deposited in its place in the history (<verbatim|history>), without renumbering what exists; versions never public at the time carry a <verbatim|Created> date, and their <verbatim|Available> date is the date of their deposit.

    <item>An erratum is a notice about a version; a retraction is a withdrawal. Both are description-only versions: nothing deposited changes.

    <item>The archive's main collection is a <strong|catalogue> of her own documents, following them: the index shows the current version of each.

    <item>DOIs come from the Zenodo binding (appendix A): a concept DOI for each document and a DOI for each document version. A version deposited out of order may be deposited as a separate Zenodo record, and notices are not uploaded, since the files of a published Zenodo record are fixed.
  </itemize>

  <\html-div-class|language-bash>
  <\verbatim-code>
    # deposit a new paper: its LaTeX source, the files it includes, and the PDF

    osheaf deposit kpz-uniqueness paper.tex \\

    \ \ --pdf paper.pdf \\

    \ \ --extra-source refs.bib \\

    \ \ --extra-source figures/fixed-point.pdf=figures/fixed-point.pdf \\

    \ \ --title "Uniqueness of the KPZ fixed point" \\

    \ \ --author "Doe, Jane\|University of Example" \\

    \ \ --rights cc-by-4.0 \\

    \ \ --stage AO



    # a second version, revised after the referees' comments and accepted

    # (the title, the authors and the licence are given again for each version)

    osheaf deposit kpz-uniqueness paper.tex \\

    \ \ --pdf paper.pdf \\

    \ \ --extra-source refs.bib \\

    \ \ --extra-source figures/fixed-point.pdf=figures/fixed-point.pdf \\

    \ \ --title "Uniqueness of the KPZ fixed point" \\

    \ \ --author "Doe, Jane\|University of Example" \\

    \ \ --rights cc-by-4.0 \\

    \ \ --changes "Corrected the proof of Lemma 3; new appendix." \\

    \ \ --stage AM



    # an erratum about version 1, which stays as it was deposited

    osheaf notice kpz-uniqueness \\

    \ \ --about 1 \\

    \ \ --text "Lemma 3 is wrong as stated; corrected in version 2."



    # papers on arXiv: download them (downloads/ is created; identifiers.json

    # in it maps arXiv identifiers to labels), then import the new

    # versions of papers already in the archive

    osheaf arxiv fetch downloads --refresh

    osheaf arxiv import downloads --update



    # update the main collection and the website, then check everything

    osheaf collect

    osheaf index

    osheaf verify
  </verbatim-code>
  </html-div-class>

  <subsection*|Co-authors in different archives><label|co-authors-in-different-archives>

  Two co-authors each keep an archive; their joint paper is deposited once, in one of them. The other lists it in a collection of her own archive (for instance "papers with my students") as a member of another archive. In a <strong|catalogue> with <verbatim|follow>, each time she updates the collection (<verbatim|osheaf collect>) it pins the head of her co-author's line, its newest object version; nothing is copied, and no permission is needed. Her member entry lists in <verbatim|at> the archives where the paper may be found, all equal locations (section 10.2), so that readers still reach it when her co-author's archive is down. If she wants the paper in her archive too, and the licences of all its versions allow redistribution, she can <strong|mirror> it: a byte-for-byte copy of her co-author's line, every version, kept in her storage root beside her own lines, with her co-author's key log. Its versions stay her co-author's, checked by her co-author's signatures; her archive can add nothing to them. If she carries the work on herself, she makes a <strong|branch>: a new line of hers, starting from a version of her co-author's, and keeps the mirror beside it if she wants the earlier versions at hand (section 10.5).

  <subsection*|A research group, a seminar, lecture notes><label|a-research-group-a-seminar-lecture-notes>

  A group keeps one archive for its members' papers, theses and slides, or each researcher keeps her own and the group keeps a catalogue whose members are documents of those archives. Lecture notes and slides are documents like papers (<verbatim|resourceTypeGeneral> <verbatim|Text>, with <verbatim|resourceType> "Lecture notes", or <verbatim|Presentation> for slides); notes revised every year are versions of one document, or separate documents when an edition is a different work (a new title, a different course). A group can also be one owner, with the keys of several members and a threshold of signatures (section 6.5): what it publishes is then signed by that many of them.

  <section*|Archives><label|archives>

  <subsection*|An institutional repository><label|an-institutional-repository>

  A university keeps an archive of its members' work.

  <\itemize>
    <item>Members may deposit their lines in the institution's archive, as owners with keys of their own: the archive hosts them, and lists them in a catalogue, perhaps with one catalogue per department. The lines stay the members': a member who leaves copies her key log and her lines to another archive and continues them there (section 6.5). The institution decides which owners it hosts, and lists them in <verbatim|owners> of its discovery document.

    <item>Or members keep their own archives, and the institution <strong|mirrors> their lines: each mirror is a whole copy, every version, with the member's key log, kept up to date by copying new versions, and checked by the member's signatures. Mirroring is allowed only when the licences of all the versions copied allow redistribution (section 10.4). Many papers imported from arXiv carry arXiv's default licence, which does not; the institution then only references them, or asks the authors to deposit openly licensed versions.

    <item>The institution is impartial: it keeps what its members deposit. It does not vet versions; that is what selections do.
  </itemize>

  <subsection*|An independent storage site><label|an-independent-storage-site>

  A preservation service (a library, a consortium) keeps copies of archives so that they survive their owners' servers.

  <\itemize>
    <item>It mirrors whole archives, or chosen lines of them, byte for byte, with the key logs of their owners. An archive mirrored entirely can list the copy in the <verbatim|mirrors> of its discovery document, which helps as long as that document can be reached; collections that should survive an archive's disappearance list several locations in their members' <verbatim|at> (section 10.2), all of which clients may try (section 6.4).

    <item>Since every collection pins its members by digest, any copy whose bytes match is as good as the original: integrity comes from the pin, not from the place; and a copy without a digest is its owner's when its signatures hold. Verifiers check mirrors exactly as originals.

    <item>Further witnesses: the owner's signatures, which every version carries, and others' signatures, which say who made or vouched for a version; and timestamps (section 13.2), which show that it existed by a date; a snapshot of the archive's git repository by Software Heritage, cited by its SWHID (section 8.1); and Zenodo deposits (appendix A), which keep the content files, though without the inventory a Zenodo record cannot be checked against a pin.
  </itemize>

  <\html-div-class|language-bash>
  <\verbatim-code>
    # copy a line of another archive, byte for byte, with all its versions and

    # its owner's key log

    osheaf mirror https://example.org/papers/ kpz-uniqueness



    # list it in a collection of the archive, so that the website shows it and

    # verify checks it (preserved.yaml below; "mirror: yes" copies and lists

    # in one step)

    osheaf collection sync preserved --from preserved.yaml



    # write the discovery document and the website, then check the archive;

    # members of other archives are checked too, on their mirrors when their

    # own archive does not answer

    osheaf index

    osheaf verify --remote
  </verbatim-code>
  </html-div-class>

  <\html-div-class|language-yaml>
  <\verbatim-code>
    id: preserved

    title: Papers preserved by the library

    type: catalogue

    members:

    \ \ - archive: https://example.org/papers/ \ \ # a base URL (in `at` of members.json)

    \ \ \ \ id: kpz-uniqueness \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ # its label

    \ \ \ \ mirror: yes
  </verbatim-code>
  </html-div-class>

  <subsection*|An archive that moves><label|an-archive-that-moves>

  An author moves her archive to a new domain. The archive has no identifier to change: it is found at its address, and every address is a hint, since what is found there is checked by pins and signatures (section 6.2). Moving it is copying its files. Collections recorded the base URLs of the time (<verbatim|at>): readers still reach the archive through HTTP redirects from the old address, which she should keep as long as she can, through the other locations listed in member entries, or through indexes and resolvers that find her lines by name; curators update <verbatim|at> in a new version of their collections. Pins and signatures stay valid, because they fix bytes and owners, not addresses.

  She can also move without the archive: as an owner, she copies her key log and her lines to another archive (an institution's, say) and continues them there, as the same lines (section 6.5).

  <section*|Selections><label|selections>

  <subsection*|An overlay journal><label|an-overlay-journal>

  A journal whose papers are kept by their authors in OpenSheaf archives (a paper only on arXiv is first imported into an archive, its author's or the journal's, with arXiv recorded as its source) accepts, after review, a particular version of each paper.

  <\itemize>
    <item>An issue is a <strong|selection>: each member pins the revision set the editors vetted, usually the accepted version.

    <item>The authors' later versions are not in the issue: they have not been reviewed. A correction accepted by the editors adds a revision to the set, as a new version of the issue, recorded in its inventory as the editors' act.

    <item>To make sure what it vetted stays available, the journal keeps an <strong|accepted copy> of each vetted revision: a branch of the paper, owned by the journal (an owner with keys of its own), a new object holding every file of that version except its <verbatim|datacite.json>, its <verbatim|object.json> and the version's own evidence if it is itself a branch (<verbatim|parent.*>), byte for byte, with the evidence of the authors' version (their inventory, <verbatim|object.json>, signatures and key log up to the latest version known, and, if the authors' version is itself a branch, the evidence of its own parents; section 10.5). It keeps the document version of the revision it copies (the authors' version 3, say). Only the copied revision needs a licence allowing redistribution; a paper whose first preprint was under a restrictive licence can be accepted in a later, openly licensed version. Later versions of the accepted copy (corrections, notices, a withdrawal) are the editors' acts, signed by the journal; the authors cannot change them. A journal will usually declare in its key log that every version it signs is timestamped, by an RFC 3161 authority it trusts or by OpenTimestamps (section 13.2), so that its record is dated. A correction the journal makes itself is its own version 4 (provisionally: the numbering on branches is open); when the editors later vet the authors' corrected version, the copy moves its branch point to it, with the same evidence, as the journal's next version (the journal's own files are then dropped; how a move keeps them is open, section 6.5).
  </itemize>

  <\html-div-class|language-bash>
  <\verbatim-code>
    # keep an accepted copy of the version the editors vetted; --version names

    # the object version vetted (vN in the authors' storage), not the document

    # version

    osheaf accept https://authors.example.org/ network-discrimination \\

    \ \ --version v3 \\

    \ \ --stage VoR \\

    \ \ --agreement "the journal's publication terms"



    # list the issue (issue-7.yaml below): a selection, whose member pins the

    # revisions vetted; update never changes them, it only reports versions

    # not vetted. Name the collection: without a name, sync replaces the main

    # collection.

    osheaf collection sync issue-7 --from issue-7.yaml
  </verbatim-code>
  </html-div-class>

  <\html-div-class|language-yaml>
  <\verbatim-code>
    id: issue-7

    title: Issue 7

    type: selection

    members:

    \ \ - archive: "." \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ # the accepted copy, in the journal's archive

    \ \ \ \ id: network-discrimination \ \ \ # its label

    \ \ \ \ revisions: [3] \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ # the document version it copies; after a correction, [3, 4]
  </verbatim-code>
  </html-div-class>

  <subsection*|A journal that publishes its own version><label|a-journal-that-publishes-its-own-version>

  A journal typesets the accepted paper in its own layout, gives it a DOI, and publishes it under its licence, with the authors' agreement.

  <\itemize>
    <item>The journal's version of record is a later version of the journal's branch of the authors' document (its accepted copy, section 10.5), not a version of the authors' line (section 7.3): it has the journal as <verbatim|publisher>, its DOI in <verbatim|doi>, <verbatim|stage> <verbatim|VoR>, the journal's <verbatim|rightsList>, the authors' agreement in <verbatim|object.json>, and a relation to the authors' version it was made from (<verbatim|IsVariantFormOf>: the same work in another form, section 8.1). A derived work, such as a translation, would be a new object, with its own genesis record.

    <item>The authors' preprint is linked to it by a description-only version of their own document (<verbatim|IsVersionOf> the article's DOI, section 8.1), if they want.

    <item>The journal's issues are selections of its own lines, or catalogues of them: the journal's lines change only by its own acts in either case.
  </itemize>

  <subsection*|A short account of a proof, with its detailed argument><label|a-short-account-of-a-proof-with-its-detailed-argument>

  A mathematician proves a theorem and writes two documents, both in her own archive: a <dfn|short account>, written to explain how the argument works (the idea, the structure of the proof, where the difficulty lies), and the <dfn|detailed argument>, every step written out, possibly largely produced with an AI system, possibly with a formal proof beside it. A journal reviews both, in particular versions, and publishes only the short account; the detailed argument stays online, in the version reviewed, open to scrutiny and to analysis by people and machines.

  <\itemize>
    <item><strong|Two documents, not one.> Each has its own versions, licence and history: the detailed argument may change often (a gap closed, a step expanded after a machine check) while the account stays as it is. Each is a line of hers, with the labels <verbatim|kpz-account> and <verbatim|kpz-details>. The detailed argument says how it was made in its <verbatim|datacite.json> (a description of type <verbatim|Methods>: the AI system and its version, what the authors checked and how), and lists in its <verbatim|toolchain> the tools needed to rebuild it and its formal checks; its creators are the persons who answer for it.

    <item><strong|The account focuses on the detailed argument.> The core of the format has no relation of this kind, and needs none: the link is made from inside. The account cites, in its text, the exact object version of the detailed argument, as a <verbatim|sheaf:> URI with the digest of its inventory (<verbatim|sheaf:\<less\>name\<gtr\>/v3?sha512=...>, section 6.6), and its <verbatim|datacite.json> links that URI with <verbatim|IsSupplementedBy>; the detailed argument may link back with <verbatim|IsSupplementTo>, added by a description-only version. Since the digest is in the account's own files, a pin of the account fixes the detailed argument too: the hash tree goes on through the link, though only readers, and tools that read the text, see it.

    <item><strong|The journal vets the pair.> Its issue is a <strong|selection> whose member is the account: an accepted copy of the vetted revision, or the journal's own version of record made from it. The detailed argument is not published by the journal, but the version it reviewed is fixed by the account's pin. So that plain verifiers check it as well, the journal may keep a second selection beside the issue (say <verbatim|issue-7-details>), pinning the revisions of the detailed arguments it reviewed.

    <item><strong|The detailed argument stays available.> Her archive keeps it, with all its versions. To make sure the version reviewed survives her server, the journal, or a storage site, <strong|mirrors> the detailed argument, if its licences allow: a mirror is a copy of her line, with her key log, impartial, every version, which is what the journal wants for a document it vetted but does not publish (an accepted copy would make it a line of the journal). The selection <verbatim|issue-7-details> lists the mirror in its member's <verbatim|at>; a Software Heritage snapshot of her archive is a further witness.

    <item><strong|Later versions.> When she improves the detailed argument after publication, her catalogue follows it; the account published by the journal keeps pointing to the version reviewed, and presentations may say that later, unreviewed versions exist. If scrutiny finds an error, the journal adds a notice to its accepted copy, or vets a corrected pair, as a new version of the issue.
  </itemize>

  <\html-div-class|language-bash>
  <\verbatim-code>
    # the journal keeps an accepted copy of the account, mirrors the detailed

    # argument, and lists both in selections (issue-7.yaml, issue-7-details.yaml)

    osheaf accept https://authors.example.org/ kpz-account --version v3 --stage VoR \\

    \ \ --agreement "the journal's publication terms"

    osheaf mirror https://authors.example.org/ kpz-details

    osheaf collection sync issue-7 --from issue-7.yaml

    osheaf collection sync issue-7-details --from issue-7-details.yaml
  </verbatim-code>
  </html-div-class>

  <strong|With an extension.> Linking from inside asks nothing of the format, but tools do not know that the two documents go together: mirroring or copying the account does not bring the detailed argument with it, and verifiers do not check its pin. An extension (section 4 of the specification) can record the relation for tools, in the account's <verbatim|object.json>, reusing the fields of a member of a selection; the archive lists the extension in the <verbatim|extensions> of its discovery document. For instance (an illustration: no such extension is published yet, and its design is discussed in issue #28):

  <\html-div-class|language-json>
  <\verbatim-code>
    "extensions": {

    \ \ "https://example.org/extensions/companions": {

    \ \ \ \ "companions": [

    \ \ \ \ \ \ {

    \ \ \ \ \ \ \ \ "role": "detailed-argument",

    \ \ \ \ \ \ \ \ "kind": "document",

    \ \ \ \ \ \ \ \ "name": "kpzdetailsaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",

    \ \ \ \ \ \ \ \ "owner": "janedoeownerbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbq",

    \ \ \ \ \ \ \ \ "at": [ "https://authors.example.org/" ],

    \ \ \ \ \ \ \ \ "revisions": [

    \ \ \ \ \ \ \ \ \ \ { "documentVersion": 3, "version": "v3", "inventorySha512": "9f2c..." }

    \ \ \ \ \ \ \ \ ]

    \ \ \ \ \ \ }

    \ \ \ \ ]

    \ \ }

    }
  </verbatim-code>
  </html-div-class>

  Tools that know the extension follow it. Verifying the account resolves and checks the companions' pins like the pins of members. Mirroring the account mirrors its companions too, or reports that their licences forbid it. Keeping an accepted copy of the account does the same, and records the relation again in the copy's own <verbatim|object.json>, since an accepted copy is a line of its own, which keeps the original's <verbatim|object.json> only as evidence, in <verbatim|parent.object.json> (section 10.5). Presentations show "the full argument, version 3, as reviewed" beside the account. A selection could also treat the companions, in their pinned versions, as vetted with the account; whether an extension may do so is one of the questions of #28, and in the core the journal pins them itself, in a selection such as <verbatim|issue-7-details>. Tools that do not know the extension still read, copy and verify both documents by the core rules alone.

  The same pattern serves other relations in which one document focuses on another: slides and the paper they present, a survey and the papers it explains, a paper and its formalisation, an article and the data and code of its computations. The core defines none of them, on purpose: it stays small, so that such relations, and in time an infrastructure for scientific knowledge built from them, can be designed on top of it, while the pins keep everything that is built checkable.

  <subsection*|Peer review, from a private submission to a published record><label|peer-review-from-a-private-submission-to-a-published-record>

  The authors prepare a paper in an archive that is not public: an archive of their own kept in a private git repository, or on their own machine. Until they send it, the paper can be a draft, rewritten freely; sealing it, before it first leaves their hands, makes their line (section 6.5). A journal reviews it privately, and in the end publishes the accepted version together with as much of the review as the participants agree to make public (ideally the reports themselves, even if this is not customary today).

  <\itemize>
    <item><strong|A private archive.> The specification describes archives that are served (section 5), but the same files, kept in a private repository, can be deposited, pinned and verified in the same way by whoever has them. Whether such an archive conforms, what <verbatim|at> it gives and how its members are resolved are open questions (issue #29). So is its <verbatim|Available> date: the specification asks for the date of deposit (section 8), as for the early versions found later in <hlink|A researcher's own archive|#a-researchers-own-archive>, while a version deposited privately becomes public only later; #29 proposes to leave it out and add it, by a description-only version, when the version is made public.

    <item><strong|Priority without disclosure.> The authors can timestamp the signature of each object version (section 13.2), with an RFC 3161 time-stamping authority or with <hlink|OpenTimestamps|https://opentimestamps.org/>, or both. The signature file holds only digests, which reveal nothing of the content, and the timestamp later shows that exactly these files existed at that date. The authors' signatures, which every version carries (section 13.2), show who made them. Since a line is the same wherever it is copied, the proof still holds when the line is later made public.

    <item><strong|The submission.> The authors send the journal their line (a copy, with their key log, kept by the journal as a mirror: byte for byte, still the authors' line, checked by their signatures), or a small collection pinning the objects that go together (the paper, a detailed argument, data). The journal checks what it received against the pins the authors give it. A manuscript under review is usually not licensed for redistribution, while the specification allows mirrors only when the licences allow it (section 10.4): here the mirror is made with the authors' agreement, which the specification does not yet provide for (copying by agreement, #39; what custodians promise, #54).

    <item><strong|The review as a selection.> The journal keeps, in its own private archive, a selection for each submission. Its members are the documents of the process, each pinned in the version that played its part: the submitted versions, the referees' reports (documents of type <verbatim|PeerReview>, each with <verbatim|Reviews> pointing to the exact object version reviewed), the authors' replies, and the editors' decisions. Each new version of the selection is a step of the process, an act of the editors recorded in its inventory (who, when, and a message saying what was decided), so the history of the selection is the history of the review.

    <item><strong|Objects travel on their own.> Every object is independent of the collections that list it, and can be sent whole: the journal sends a report to the authors as an object, which they keep as a mirror and check against its pin, again by agreement rather than by licence; their reply comes back the same way.

    <item><strong|Anonymous referees.> A fixed version cannot forget what it records: a referee's name in a report's <verbatim|datacite.json> or in its files, or as the depositor in its inventory, could be removed afterwards only by a takedown (section 11.2), which breaks every pin of it. Anonymity must therefore be built in from the start. The journal deposits the reports itself (the inventory names the editorial office as depositor), as lines of the journal's owner, signed with its keys, not the referee's. The report's files are cleared of what identifies the referee (PDF metadata, comments in the sources, the <verbatim|toolchain>) before deposit. If the archive is kept in git, commits that are sent or published name the journal, not the referee.

    <item><strong|The referee as a commitment.> In place of the referee's name, the report's creator is a cryptographic <dfn|commitment>: the SHA-512 digest of the referee's identifier (an ORCID iD, which is unambiguous where a name is not) followed by a secret known to the journal and the referee. The commitment is fixed in the report's version, so it cannot be changed afterwards: neither the journal nor anyone else can later attribute the report to someone else. Revealing the identifier and the secret (the referee, to claim the report; the journal, with the referee's agreement or as an institution may require) lets anyone check the attribution by recomputing the digest. A referee who agrees to be named in the reports after acceptance is added to their creators, by name, by description-only versions, with the identifier and the secret that open the commitment.

    <item><strong|The secrets.> The secret keeps the referee anonymous until then. Without it, anyone could compute the digests of candidate identifiers until one matches. The journal draws a random secret for each paper, and gives each referee of the paper a secret derived from it: an HMAC of the referee's identifier under the paper's secret. The reports of one referee on one paper, through every round of the review, then carry the same digest, so readers see that they come from the same person. The reports of different referees, or of the same referee on different papers, cannot be linked. Revealing a referee's secret discloses neither the paper's secret nor the other referees. The secrets are kept outside the archive and never deposited: whatever is deposited can never be deleted, and travels with every copy. The papers' secrets are independent of each other, not derived from a single seed of the journal, so a leak of one paper's secret exposes the referees of that paper only.

    <item><strong|The record.> When the paper is accepted, the journal keeps the accepted version, with the reports, the replies and the decisions, in its archive: the complete record of the process, fixed by pins. It publishes only the public part: an accepted copy of the paper (section 10.5) and, with the agreement of those concerned, the reports and replies, listed with the paper in the issue (a selection) or in a public selection of the review. Each report keeps its <verbatim|Reviews> relation to the submitted version it reviewed, and the accepted copy links its reports with <verbatim|IsReviewedBy>. Everything else stays private, still verifiable by those who have it.
  </itemize>

  Open questions for the specification, discussed in issues #29, #39 and #54:

  <\itemize>
    <item>how a line kept privately becomes public: a copy of it in a public archive is the same line, with the same inventories, so published reports keep pinning versions readers can resolve; what remains open is whether an archive may serve only part of its lines, and how it says so;

    <item>what <verbatim|at> a private archive gives, and how verifiers resolve its members;

    <item><verbatim|Available> for versions deposited privately;

    <item>mirrors made with the owner's agreement, for objects whose licence does not allow redistribution (#39, #54);

    <item>how a commitment is written as a creator in DataCite (for instance a <verbatim|nameIdentifier> with a scheme of its own), with the exact encoding of what is hashed, so that every tool computes the same digest.
  </itemize>

  <subsection*|A learning record: a thesis, a project, an essay, an experiment><label|a-learning-record-a-thesis-a-project-an-essay-an-experiment>

  A student documents the progression of a piece of work: a thesis, a project, an essay, an experiment. Each revision is kept, with the comments of the supervisors and, at the end, the reports of the examiners. The result is a <dfn|learning record>: an official, verifiable account of how the work was done, not only of what was handed in.

  <\itemize>
    <item><strong|The work.> The work is a document (<verbatim|resourceTypeGeneral> <verbatim|Dissertation> for a thesis, <verbatim|Text> with a <verbatim|resourceType> such as "Essay" or "Project report" otherwise); the data of an experiment and its code are documents of their own (<verbatim|Dataset>, <verbatim|Software>), linked to it by relations. Each revision the student hands in is a new document version, with a <verbatim|changes> note saying what changed (in answer to which comments, with which tools). Its <verbatim|stage> follows a scheme named by the institution (for instance "draft", "submitted for examination", "final"). The inventory records who deposited each version and when, so the history of the object is the log of the work.

    <item><strong|Where it is kept.> The student keeps the work in an archive of their own, which they keep after leaving, or deposits it directly in an archive of the institution; either way the student is its owner, with keys of their own, signs every version, and takes the line along on leaving (section 6.5). Until the work is examined the archive is usually private (issue #29). Work in progress is a draft (section 6.5), which may be rewritten; handing it in seals it: sealing makes a new, fixed object, the line, from the draft.

    <item><strong|Dates.> A timestamp of each object version (section 13.2) shows that this revision existed by that date, which is what a deadline asks; the student's signature shows whose it is. Timestamps are optional; an institution may ask its students to declare them in their key logs. When the institution keeps a mirror of the work at each submission (if the licence allows; copying by agreement is open, #39), the mirror is also its receipt.

    <item><strong|Comments.> The supervisors' comments are documents (<verbatim|Text>, with a <verbatim|resourceType> such as "Supervisor's comments"), each with <verbatim|Reviews> pointing to the exact object version commented on: a short text, an annotated PDF of that version, or both. The student's replies are documents too, or the <verbatim|changes> note of the next revision. A comment therefore always refers to the version it was written about, even after the work has moved on.

    <item><strong|The record as a selection.> The institution keeps, in its archive, a selection for each piece of work. Its members are the documents of the process, each pinned in the version that played its part: the revisions handed in, the comments, the examiners' reports (<verbatim|PeerReview>, with <verbatim|Reviews> pointing to the version examined) and the decision. Each new version of the selection is a step, recorded by the department (who, when, and a message saying what was decided), as for <hlink|peer review|#peer-review-from-a-private-submission-to-a-published-record>. Examiners are usually named; where they are anonymous, they can be recorded as commitments, as referees are there.

    <item><strong|What it shows.> The record does not prove who wrote the work, but it shows how it grew, revision by revision, and what was said about each revision: a body of evidence for the assessment of the work and of the student's part in it, and a record the student can show later, checkable by anyone they give it to.

    <item><strong|What is published.> Usually only the final version, as the thesis in the institution's repository (an accepted copy, section 10.5) or in the student's own archive, made public. The rest of the record, with marks and comments, is personal data (section 16) and stays private, still verifiable by those who have it. When the institution's retention period ends, the record is deleted by a takedown (section 11.2); its tombstones show that it existed, and the student's own copy is not affected.
  </itemize>

  <subsection*|A digest, a reading list, a curated bibliography><label|a-digest-a-reading-list-a-curated-bibliography>

  A researcher publishes a list of recommended papers on a topic, from any OpenSheaf archives.

  <\itemize>
    <item>The list is a <strong|selection>: each member pins the revision she read and recommends. A later version of a paper enters the list only if she adds it, after reading it.

    <item>Nothing is copied, so no permission is needed; the members' cached citations keep the list readable if an archive disappears.

    <item>A selection may contain collections: a digest of digests, or of journal issues, each pinned in the version vetted.
  </itemize>

  <subsection*|A review journal (like Mathematical Reviews or zbMATH Open)><label|a-review-journal-like-mathematical-reviews-or-zbmath-open>

  A review journal publishes short reviews of papers published elsewhere.

  <\itemize>
    <item>Each review is a line of the review journal's owner (<verbatim|resourceTypeGeneral> <verbatim|PeerReview>), written by a reviewer, with <verbatim|relatedIdentifiers> <verbatim|Reviews> pointing to the reviewed paper (its DOI, or a <verbatim|sheaf:> URI with the digest of the object version reviewed).

    <item>Reviewed papers kept in OpenSheaf archives form a <strong|selection>: each member pins exactly the revision that was reviewed. When a paper gets a new version, the review stays attached to the reviewed revision, and the selection does not move; a new review of the new version adds a revision to the set, by the editors' act. Papers published only elsewhere (a publisher's site) are linked by the review's <verbatim|Reviews> relation alone.

    <item>Reviews and the selection are kept by the review journal, so the record of what was reviewed, and in which version, is fixed and checkable even if the papers' archives change.
  </itemize>

  <subsection*|Proceedings, special issues, volumes><label|proceedings-special-issues-volumes>

  Proceedings of a conference are a selection of the talks' papers, each vetted in the version presented; a volume is a selection whose members are its issues (collections), each pinned in the version published. A special issue of a journal is a selection of the journal's own documents, or of accepted copies.

  <section*|What happens when ...><label|what-happens-when->

  <block|<tformat|<cwith|1|1|1|-1|font-series|bold>|<cwith|1|-1|1|-1|cell-valign|top>|<cwith|1|-1|1|-1|cell-hyphen|t>|<table|<row|<cell|Event>|<cell|Catalogue (an archive, a storage site)>|<cell|Selection (a journal, a digest)>>|<row|<cell|the authors deposit a new version>|<cell|it is followed (with <verbatim|follow>): the next collection version pins the new head>|<cell|nothing changes; the curator may vet it and add it to the revision set>>|<row|<cell|the authors revise a document that another one focuses on (the detailed argument of a short account)>|<cell|it is followed, like any new version>|<cell|nothing changes: the account, and any selection of the detailed argument, keep pinning the version reviewed; the curator may vet the new one>>|<row|<cell|the authors add a notice or a description>|<cell|it is followed, like any new version>|<cell|not vetted; presentations may show it, saying where it comes from>>|<row|<cell|the authors withdraw the document>|<cell|it is followed: the withdrawn document stays, with its notice>|<cell|the vetted revisions stay, and presentations show the authors' withdrawal notice with the document (section 11.1); the curator decides what else (a notice of its own, a withdrawal of its accepted copy)>>|<row|<cell|the editors correct a vetted version>|<cell|not applicable>|<cell|a new revision in the set, or a new version of the accepted copy: the editors' act, in the selection's history>>|<row|<cell|a document is taken down (by law, or to erase personal data, section 16)>|<cell|the object is deleted and a tombstone stays; verifiers report the member as removed>|<cell|the same for the pinned revisions; an accepted copy is a line of the selection's owner, to which the takedown is applied separately; copies kept elsewhere are not reached (open, #33)>>|<row|<cell|a document kept privately is made public>|<cell|it can be a member once a copy of its line is public: the same line, so earlier pins stay valid (issue #29)>|<cell|the same; published reports keep pointing to the versions they reviewed>>|<row|<cell|a referee agrees to be named>|<cell|the report's owner (the journal) adds the referee to its creators by a description-only version, which is followed>|<cell|the vetted revision keeps its pin; the version naming the referee is not vetted, unless a new document version is>>|<row|<cell|the member's archive moves>|<cell|the pin stays valid; readers follow redirects, the other locations listed in member entries (<verbatim|at>), or indexes>|<cell|the same>>|<row|<cell|the member's owner moves to another archive>|<cell|the line continues there, as the same line; the collection finds it through <verbatim|at>, once updated, or through indexes>|<cell|the same; vetted revisions are unchanged>>|<row|<cell|another archive adds a version to a member's line>|<cell|it is not the owner's: its signature does not hold, so verifiers reject it, and the collection does not follow it>|<cell|the same>>|<row|<cell|the member's archive disappears>|<cell|members are fetched from mirrors, or any copy matching the pin; Zenodo deposits keep the files but cannot be checked against the pin>|<cell|the accepted copy keeps the vetted revision; references keep their cached citations>>|<row|<cell|a version's licence forbids redistribution>|<cell|the line cannot be mirrored, only referenced>|<cell|the revision cannot be copied, only referenced (copying by agreement is open, #39)>>>>>

</body>

<\initial>
  <\collection>
    <associate|page-medium|paper>
  </collection>
</initial>
