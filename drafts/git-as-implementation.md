# Git as the implementation of OpenSheaf

*Working paper, draft of 15 November 2026. Non-normative: ideas and positions,
not decisions. OpenSheaf keeps its archives as OCFL objects, plain files fixed
by SHA-512 digests, and may keep those files in git as a convenient store
([OpenSheaf archives in git](../opensheaf-git-0.1.md)). This paper asks the
other question: what if git's own structures, its commits, trees, references
and transport, carried OpenSheaf? It sets what OpenSheaf needs against what
git provides, describes three designs, from git replacing OCFL to git as a
view derived from it, weighs what each gains and costs, and proposes
experiments.*

## 1. The question

Git and OCFL solve close problems. Both keep versioned trees of files; both
name content by its digest; in both, a reference to a version fixes that
version and every version before it. Git adds what OCFL leaves out: a
transport that copies only what is missing, a protocol for pushing and
fetching, signatures, forks and merges, hosting by forges, and long-term
archiving by Software Heritage, whose identifiers are git's own. Many
OpenSheaf archives will be kept in git anyway.

So one can ask whether the archive could *be* git: an object a line of
commits, a pin a commit hash, a mirror a fetch, a collection a tree of
references to other repositories. The answer decides whether OpenSheaf stays a
format of plain files with git as an optional store, or becomes a convention
on top of git.

The specification today takes the first view: git hashes are not part of the
integrity of an archive (section 13.2 of the specification), and the FAQ
explains why OCFL rather than git. This paper does not change that; it looks
at what the second view would give, and at a middle way.

## 2. What OpenSheaf needs

The format rests on a few properties; any implementation must provide them.

1. **Fixed versions.** An object version, once made, never changes;
   corrections are new versions.
2. **Ordered history.** The versions of an object form a sequence, and each
   version knows the ones before it.
3. **Pins.** A pin is a reference that fixes one object version and every
   earlier one, so that any copy can be checked against it, wherever it comes
   from (section 6.4 of the specification). Collections are made of pins, so
   they are hash trees across archives.
4. **Names.** An archive has an identifier that survives a move (section 6.2);
   an object has a short identifier in its archive (section 6.3), and, in the
   proposal of [PR
   #30](https://github.com/opensheaf/opensheaf.github.io/pull/30), a
   self-certifying name, the digest of a genesis record, and an owner.
5. **A mutable map.** The discovery document lists the objects and their
   heads; it is not evidence, and is checked against the objects.
6. **Description.** Every version carries `datacite.json` and `object.json`,
   and the inventory records who deposited it and when.
7. **Witnesses** outside the versions: signatures and timestamps, added and
   upgraded later (section 13.2).
8. **Withdrawal and takedown**: a withdrawal is a new version; a takedown
   deletes content and leaves a tombstone (section 11).
9. **Reading with nothing but HTTP.** An archive is a static website; a
   browser, a crawler or a script can read and verify it, with no server-side
   software.
10. **Long-term readability.** The files can be read in decades, without the
    software that made them, and the digests remain strong.

## 3. Git in brief

Git stores four kinds of objects, each named by the digest of its content: a
**blob** (the bytes of a file), a **tree** (a list of names, each with a mode
and the digest of a blob or a tree, or of a commit, a *gitlink*), a **commit**
(a tree, its parent commits, an author and a committer with dates, and a
message) and an annotated **tag** (a name for another object, with a message).
Digests are SHA-1 in almost every repository; repositories in the SHA-256
object format exist, but tools and forges support them only partly, and the
two formats do not interoperate on the same repository.

**References** (`refs/heads/main`, `refs/tags/v1`) are mutable names for
commits: the only mutable part of a repository. **Notes** attach text to
commits after the fact, under references of their own. Commits and tags can be
**signed** (OpenPGP, SSH or X.509). The **transport** fetches only the objects
missing from a clone, over the git protocol or HTTP; the "dumb" HTTP protocol
works from a static web server. **Shallow** clones hold the last commits
without their ancestors; **partial** clones hold commits and trees without all
blobs.

[Software Heritage](https://www.softwareheritage.org/) archives public
repositories and names their objects with SWHIDs that are git's own digests:
`swh:1:cnt:` a blob, `swh:1:dir:` a tree, `swh:1:rev:` a commit, `swh:1:rel:`
a tag, and `swh:1:snp:` a snapshot of all the references.

## 4. How the concepts meet

| OpenSheaf | Today (OCFL) | In git |
|---|---|---|
| object | an OCFL object folder | a line of commits, under one reference |
| object version | a version folder with its inventory | a commit |
| content of a version | logical paths in the inventory | the tree of the commit |
| history | `v1`, `v2`, ... and the inventory listing them | the chain of parent commits |
| pin | object version and SHA-512 of its inventory | a commit hash |
| depositor and date | `user` and `created` in the inventory | author and dates of the commit |
| change note | `message` in the inventory, `changes` in `object.json` | the commit message |
| discovery document | `opensheaf.json` | the references of the repository |
| collection version | `members.json` with pins | a tree of gitlinks, with `members.json` |
| mirror | a byte copy of an object folder | a fetch of the object's reference |
| deep branch (#30) | the earlier versions copied, continued | a fork |
| shallow branch (#30) | the branch point, with the parent's inventory | a shallow clone, grafted at the branch point |
| self-certifying name (#20, #30) | the digest of `genesis.json` | the hash of a root commit holding `genesis.json` |
| witness | files in `extensions/opensheaf-witnesses/` | signed tags, notes |
| withdrawal | a description-only version | a commit changing only the description |
| takedown | the object folder deleted, a tombstone | the reference deleted, the history rewritten |

The match is close. A commit hash fixes its whole history, as an OpenSheaf pin
does through the inventory. A fork is a deep branch; a shallow clone is
literally a shallow branch, a commit whose parent is named but not held. A
gitlink, the tree entry that submodules use, is a pin inside a tree. The
references of a repository are a mutable map, checked against the objects, as
the discovery document is. And the owner and line of PR #30 resemble git's own
practice: one writer per branch, copies that agree when one is a prefix of the
other, and a fork when they diverge.

## 5. Three designs

### 5.1 Git instead of OCFL

The archive is a git repository, and nothing else. Each object is a line of
commits under `refs/opensheaf/objects/<id>`, whose trees hold the files of the
version with `datacite.json` and `object.json`. A pin is a commit hash. A
collection version is a commit whose tree holds `members.json` and a gitlink
to each member's commit. The discovery document is the list of references, or
a file generated from it. Mirrors are fetches; collections across archives are
fetched as submodules, each checked by git against its hash.

**Gains.** One mechanism for storage, history, transport, copies and
archiving. Mirroring becomes incremental and cheap. Software Heritage archives
an OpenSheaf archive as it archives any repository, and its SWHIDs are the
pins. Forks and pull requests are deep branches and proposals, with tools
everyone knows.

**Costs.**

- **Digests.** Pins become SHA-1, or SHA-256 where forges do not follow. SHA-1
  has known collision attacks; git detects the known attack technique, but a
  format meant for decades should not rest on it, and git's change of
  algorithm is far from complete. OCFL lets the digest algorithm be chosen per
  inventory, and OpenSheaf chose SHA-512.
- **Reading with HTTP.** A browser cannot read a repository from the main
  forges: their git endpoints do not allow cross-origin requests, and objects
  come in compressed packs, which need a git implementation in the reader
  (such as isomorphic-git) and often fetching much more than one file. A
  repository published with the dumb protocol on a static site can be read,
  but still through packs. The Explorer, crawlers, Google Scholar and the
  website profile all assume plain files.
- **Long-term readability.** Git's formats are documented and stable, but they
  are compressed and packed: reading a file needs software that understands
  them. OCFL is chosen by research libraries for the opposite property, that
  an object can be read with a file browser.
- **Fixity of files.** A blob hash is the digest of a header and the content,
  not of the file; it cannot be compared with the checksums of Zenodo or of a
  download. Each file would need its own digests in `object.json`.
- **Deletion.** Removing one file from one version changes the hash of that
  version and of every later one: every pin to the object breaks. OCFL has the
  same limit for single files (section 11.3 of the specification), but a pin
  to an OCFL version survives a missing file, which verification reports as
  missing, since the pin fixes the inventory. Git can hold a tree whose blob
  is absent (partial clones do), but its tools treat that as damage.
- **Paths.** Tree entries cannot be named `.git`, and some forges refuse other
  names; OCFL logical paths have no such limits.
- **Standards.** OpenSheaf's first principle is to use existing standards for
  storage and description. Git is a de facto standard of software, not of
  preservation, and an archive in git alone would no longer be an OCFL storage
  root, readable by the tools of libraries.

### 5.2 Git as a view of OCFL

The archive stays an OCFL storage root, and each object version also has a
<dfn>git view</dfn>: a commit built from the version **deterministically**, so
that anyone can recompute it from the OCFL object alone.

- the tree: the logical state of the version, every file with mode `100644`,
  folders as trees;
- the parent: the commit of the previous version (none for `v1`);
- the author and committer: the `user` of the inventory version (its `name`,
  and its `address` between angle brackets, empty if absent), with the
  `created` date and its offset;
- the message: the `message` of the inventory version, or a fixed text built
  from the object identifier and version.

Since the tree hash depends only on the files, and the commit hash only on the
tree, the parent and these fields, the git view of an object version is a
function of the OCFL object. It adds a second digest to every version without
changing a byte of the archive.

**Gains.**

- **Software Heritage.** If an archive publishes its git views as a
  repository, Software Heritage archives it, and its SWHIDs can be recomputed
  from the OCFL objects: a verifier can confirm that the version it holds is
  the one Software Heritage holds, at the date of its snapshot, without
  trusting either. This is an external witness that is checkable against a
  pin, which issue
  [#22](https://github.com/opensheaf/opensheaf.github.io/issues/22) looks for.
- **Transport.** Mirrors and custodians can follow an archive with `git
  fetch`, receiving only new versions, and rebuild the OCFL objects from the
  commits and the inventories (which the view would also need to carry; see
  section 6).
- **Collections as superprojects.** A collection version's git view can hold a
  gitlink for each member pin. Cloning it with its submodules fetches every
  member at the vetted version, each checked by git, from the archives'
  repositories or from Software Heritage.
- **Tools.** Every git tool can browse the history of a document, compare two
  versions, and show who deposited what.
- **The format stays.** Readers who know nothing of git read the archive as
  today; the view is optional, and can be added to existing archives.

**Costs.** A second representation to keep in step; a deterministic mapping to
specify exactly (dates, encodings, names, empty folders, file names git
refuses); and the views do not carry the inventories, so a repository of views
alone does not rebuild the archive unless it carries them too.

### 5.3 Git as the transport only

The repository holds the OCFL files themselves, as in [OpenSheaf archives in
git](../opensheaf-git-0.1.md), and git moves them. Commits record states of
the whole archive, not object versions. This is what archives do today. It
gains transport, history of the discovery document and hosting, but git's
structures say nothing about objects: a commit hash fixes a state of the
archive, which is not a pin, and a fetch copies whole archives, not objects.

## 6. Problems to solve for the git view

- **Determinism.** Every field of the commit must be fixed by the OCFL object:
  the encoding of names and messages (UTF-8, line endings, a trailing
  newline), the date format and time zone, the order of tree entries (git's
  own), the handling of a missing name or address, of empty folders (absent in
  git), and of logical paths git cannot store (`.git`, paths with a component
  that a tree cannot name). A version that cannot be mapped must be reported,
  not silently changed.
- **Where the commit hash is recorded.** A version cannot hold its own commit
  hash (the hash depends on the content). It can be recorded outside: in the
  discovery document (`gitCommit` next to `inventorySha512`), in the next
  version's `object.json`, in witnesses, or not at all, since anyone can
  recompute it. Recording it in the discovery document makes it visible to
  readers who do not compute it.
- **Inventories and description.** `datacite.json` and `object.json` are in
  the tree, as files of the version. The inventory is not (it lists the
  version's files, and would change the tree that it describes). To rebuild an
  OCFL object from a repository of views, the inventories travel beside the
  commits: as notes, as files under a separate reference, or in a parallel
  tree.
- **Description-only versions** are commits whose tree differs only in
  `datacite.json` or `object.json`, which suits git well.
- **Collections.** A gitlink records a commit hash, not a version label or an
  inventory digest; the view of a collection holds both: the gitlinks for git,
  and `members.json` for OpenSheaf, with a check that they agree.
- **SHA-1 or SHA-256.** The view can be computed in both object formats. SHA-1
  views match Software Heritage and the forges; SHA-256 views are stronger,
  and could be computed now and published later. Neither replaces the SHA-512
  pins.
- **Names.** The root commit of a line, built from a version holding
  `genesis.json` (PR #30), is a natural git name for the line; but the
  self-certifying name of #20 is the digest of the genesis record alone, which
  does not depend on dates or depositors, and should stay so.
- **Takedown.** Deleting the files of a view means rewriting the repository of
  views, as in section 9 of [OpenSheaf archives in
  git](../opensheaf-git-0.1.md); the views computed elsewhere, and Software
  Heritage, keep them. Takedowns across copies are discussed in issue
  [#33](https://github.com/opensheaf/opensheaf.github.io/issues/33).
- **Privacy.** The view publishes the depositor's address from the inventory
  as a commit author, where a reader of git expects it. Inventories already
  publish it; the view makes it more visible.

## 7. The lines of PR #30 in git

The proposal for owners and lines in [PR
#30](https://github.com/opensheaf/opensheaf.github.io/pull/30) reads naturally
in git terms:

- a **line** (owner, name) is a branch with a single writer: its owner pushes,
  no one else does;
- two copies of a line agree when one is a prefix of the other, which is git's
  fast-forward; when neither is, the line has forked, which git detects in the
  same way;
- a **deep branch** is a fork: the history copied, then continued under
  another owner;
- a **shallow branch** is a shallow clone at the branch point: the parent
  version is named by its hash, and its inventory kept as evidence; git's
  `.git/shallow` records exactly such a boundary;
- **moving the branch point** forward to a later version of the parent's line
  is a merge of that version into the branch, which git records with two
  parents.

The analogy is a check on the design rather than an argument to build it on
git: a structure that git has used at scale for twenty years is unlikely to
hide a contradiction. It also suggests that the git view of section 5.2 could
carry lines and branches without new machinery.

## 8. Assessment

Git instead of OCFL (section 5.1) would give OpenSheaf a ready transport and
archiving, at the price of its two foundations: strong digests chosen for
preservation, and archives readable as plain files over HTTP. The price seems
too high, and the gains can be had otherwise.

Git as a view (section 5.2) keeps the format and adds what git does best:
incremental copies, a familiar interface to histories, collections fetched in
one command, and above all a second, independent witness through Software
Heritage, checkable against the pins. It costs a mapping to specify carefully,
and a second representation to keep. It would be an extension of the format,
or a tool convention, not a change of the core.

Git as the transport (section 5.3) is what archives already do, and what
[OpenSheaf archives in git](../opensheaf-git-0.1.md) makes safe.

The proposal of this paper is therefore to try the git view, without
committing to it.

## 9. Experiments

1. **A deterministic export.** A command (for instance `osheaf git-view`) that
   builds the git view of every object version of an archive, and a test that
   two independent runs, on different systems, give the same commit hashes.
2. **The first archive.** The views of `mgubi/papers`, published as a
   repository and saved by Software Heritage; then a verifier that recomputes
   the SWHIDs from the OCFL objects and finds them in Software Heritage.
3. **A collection as a superproject.** The view of a selection with members in
   two archives, cloned with its submodules.
4. **A mirror by fetch.** A copy of an archive kept up to date by `git fetch`
   of the views and their inventories, rebuilt into an OCFL storage root, and
   verified byte for byte against the original.
5. **Reading in a browser.** The cost of reading one document version from a
   repository with isomorphic-git, from a static host, compared with reading
   the OCFL files.

## 10. Open questions

- Is the git view part of the specification (an optional field `gitCommit` in
  the discovery document, a profile), an extension, or only a convention of
  the tools?
- SHA-1, SHA-256 or both, and for how long SHA-1 views are worth computing.
- How inventories travel with the views, so that a repository of views is
  enough to rebuild the archive.
- Whether the git view of a collection should hold gitlinks, which tools would
  fetch automatically from places the collection does not vouch for.
- How lines, owners and branches (PR #30) appear in the views: one repository
  per line, per owner or per archive.
- Takedowns across repositories of views and Software Heritage (#33).

Related issues:
[#13](https://github.com/opensheaf/opensheaf.github.io/issues/13)
(decentralised holding),
[#14](https://github.com/opensheaf/opensheaf.github.io/issues/14) (global
names), [#19](https://github.com/opensheaf/opensheaf.github.io/issues/19)
(scale), [#20](https://github.com/opensheaf/opensheaf.github.io/issues/20)
(self-certifying names),
[#22](https://github.com/opensheaf/opensheaf.github.io/issues/22) (external
copies and pins),
[#29](https://github.com/opensheaf/opensheaf.github.io/issues/29) (drafts and
private archives),
[#33](https://github.com/opensheaf/opensheaf.github.io/issues/33) (takedowns),
and the proposal [PR
#30](https://github.com/opensheaf/opensheaf.github.io/pull/30).
