<TeXmacs|2.1.5>

<style|<tuple|notes|notes-meta>>

<\body>
  <notes-header>

  <chapter*|OpenSheaf archives in git>

  <notes-abstract|Companion to the OpenSheaf specification 0.1. Version 0.1 (draft), 18 November 2026. How to keep an OpenSheaf archive in a git repository, publish it from there and copy it, without git changing a byte of what the archive holds. It adds nothing to the format: readers of an archive never need to know that it is kept in git. The text is licensed under CC BY-SA 4.0.>

  <os-alert|warning|Warning.|<strong|Draft for discussion.> This document is a first draft. Its open questions are listed in section 13; none of them is settled.>

  <section*|1. Introduction (non-normative)><label|1-introduction-non-normative>

  The <hlink|OpenSheaf specification|opensheaf-specification-0.1.tm> allows an archive to be kept in git and served by any static web server (section 5 of the specification), and says that git hashes are not part of its integrity (section 13.2). This document says how, for those who keep an archive in git and for the tools that write to such a repository.

  Git gives an archive what the format leaves to its maintainer:

  <\itemize>
    <item><strong|a history of the whole archive>: every state of the discovery document, so every state the archive published, which the format itself does not keep (the discovery document is a mutable map, section 6.1 of the specification);

    <item><strong|copies>: every clone is a complete copy of the archive, with its history;

    <item><strong|review before publication>: a deposit can be prepared on a branch, checked, and merged;

    <item><strong|checks on every change>, by continuous integration;

    <item><strong|hosting>, through services such as GitHub Pages.
  </itemize>

  Git also works against an archive in four ways, which this document answers:

  <\itemize>
    <item><strong|Bytes.> By default git may convert line endings, run filters, expand keywords or store large files elsewhere (Git LFS). The files of an archive must be stored and served byte for byte (section 4).

    <item><strong|History can be rewritten>, and files edited in place. Object versions must never change (section 5).

    <item><strong|History cannot easily forget.> A takedown must remove content; in git, a deleted file stays in every earlier commit, every clone and every fork (section 9).

    <item><strong|Size.> Hosts limit files, repositories and sites; an archive keeps every version forever (section 8).
  </itemize>

  The principle: git is a store and a transport for the files of the archive. The archive is what is on the published branch. Git never changes those bytes, and the published branch never rewrites what it has published.

  <section*|2. Conventions and terms><label|2-conventions-and-terms>

  The key words MUST, MUST NOT, REQUIRED, SHOULD, SHOULD NOT, RECOMMENDED, MAY and OPTIONAL are to be interpreted as described in BCP 14 (RFC 2119, RFC 8174) when, and only when, they appear in all capitals. Terms of the specification (archive, storage root, discovery document, object, object version, pin, mirror, witness, takedown, tombstone, owner, owner object, key log, draft, signed version, not a version, ended owner, fork) keep their meaning.

  <\itemize>
    <item><dfn|Repository>: a git repository holding one archive.

    <item><dfn|Archive files>: the files the specification requires to be served byte for byte: the discovery document <verbatim|opensheaf.json>, the storage root (by convention <verbatim|ocfl/>) and, if used, the indexes (the folders <verbatim|names/>, <verbatim|owners/> and <verbatim|sha512/>, which an archive declares in its discovery document, and <verbatim|indexes.json>, only in a repository that serves indexes for several archives, as a custodian or a resolver does; section 6.6 of the specification).

    <item><dfn|Presentation files>: the website of the archive (appendix C of the specification), generated from the archive files.

    <item><dfn|Working files>: every other file of the repository: settings of tools, descriptions of deposits, sources being prepared, scripts, workflows.

    <item><dfn|Published branch>: the branch from which the archive is served (usually <verbatim|main>). A <dfn|published commit> is a commit of its first-parent history.

    <item><dfn|Deployment>: the copy of the files of a published commit to the place the archive is served from.
  </itemize>

  A repository conforms to this document if every published commit satisfies sections 3 to 5 and its deployments satisfy section 7. A tool conforms if every commit it makes on the published branch, and every deployment it makes, keeps the repository conforming. Conformance to this document is not declared in the discovery document (but see section 13, question 1).

  <section*|3. The repository><label|3-the-repository>

  A repository SHOULD hold one archive, with the discovery document at the top of the repository and the storage root in <verbatim|ocfl/>. An archive kept in a sub-folder of a larger repository is allowed; what follows then applies to that folder.

  Working files MAY be kept in the repository. They are not part of the archive: they MUST NOT be placed inside the storage root or the folders of the indexes, and they are not published unless the maintainer means them to be (section 7).

  The archive files MUST NOT contain symbolic links or git submodules. Members of collections that belong to other archives are reached through the discovery documents of those archives and checked by their pins (section 10.3 of the specification), never included as submodules; copies of lines kept elsewhere are mirrors (section 10.4 of the specification), copied byte for byte into the storage root.

  <section*|4. Storing bytes><label|4-storing-bytes>

  <subsection*|4.1 Attributes><label|41-attributes>

  The repository MUST contain a <verbatim|.gitattributes> file at its top with these lines (with the lines of the indexes only if it keeps them, and the paths adjusted if the archive is in a sub-folder):

  <\verbatim-code>
    # OpenSheaf archive files: stored and checked out byte for byte,

    # never merged as text.

    opensheaf.json -text -filter -ident -working-tree-encoding -export-subst -merge

    ocfl/** \ \ \ \ \ \ \ -text -filter -ident -working-tree-encoding -export-subst -merge

    indexes.json \ \ -text -filter -ident -working-tree-encoding -export-subst -merge

    names/** \ \ \ \ \ \ -text -filter -ident -working-tree-encoding -export-subst -merge

    owners/** \ \ \ \ \ -text -filter -ident -working-tree-encoding -export-subst -merge

    sha512/** \ \ \ \ \ -text -filter -ident -working-tree-encoding -export-subst -merge
  </verbatim-code>

  <\itemize>
    <item><verbatim|-text>: no conversion of line endings, whatever the settings of the clone (<verbatim|core.autocrlf>, <verbatim|core.eol>).

    <item><verbatim|-filter>: no clean or smudge filter, such as that of Git LFS.

    <item><verbatim|-ident>: no expansion of <verbatim|$Id$> in file contents.

    <item><verbatim|-working-tree-encoding>: no conversion of character sets.

    <item><verbatim|-export-subst>: no substitution in copies made by <verbatim|git archive>.

    <item><verbatim|-merge>: no merge as text (section 6.3).
  </itemize>

  Attributes in the repository take precedence over those of the user (<verbatim|core.attributesFile>) and of the system only for the attributes they name; an attribute the repository leaves unspecified falls through to them. A user-wide <verbatim|*.pdf filter=lfs> would otherwise apply to the PDFs of the archive. For this reason every attribute is named, not only <verbatim|-text>.

  <subsection*|4.2 Git LFS><label|42-git-lfs>

  Archive files MUST NOT be stored with Git LFS, or any other mechanism that keeps a pointer in the repository in place of the file, unless every deployment and every copy of the repository used as a copy of the archive replaces the pointers by the files. A deployment that serves the pointer serves a file whose digest does not match its inventory. GitHub Pages, deploying from a branch, serves the pointers. Pointers committed by mistake are repaired (section 5.3).

  <subsection*|4.3 File names><label|43-file-names>

  Git stores file names as bytes, but the file systems it checks them out on are not alike: macOS and Windows ignore case by default, macOS may change the Unicode normalisation of names, Windows forbids some characters (<verbatim|\<less\>\<gtr\>:"\|?*>) and names (<verbatim|CON>, <verbatim|NUL>, ...) and limits the length of paths. A file whose name cannot be checked out cannot be verified or served from that clone.

  OCFL separates the logical path of a file (its name in the version, as the depositor gave it) from its content path (where its bytes are stored in the object). Tools SHOULD choose content paths that check out everywhere: path segments made of ASCII letters, digits, <verbatim|.>, <verbatim|_> and <verbatim|->, not ending with <verbatim|.>, no two content paths of an object differing only in case, and each content path at most 200 characters from the top of the repository. Logical paths keep the names given by the depositor.

  <subsection*|4.4 What git does not keep><label|44-what-git-does-not-keep>

  Git keeps neither empty folders nor modification times, and records of file modes only whether a file is executable. None of these is part of an OCFL object: inventories list files, not folders, and dates come from the inventories. Tools MUST NOT rely on any of them.

  <section*|5. The published branch><label|5-the-published-branch>

  <subsection*|5.1 Append-only><label|51-append-only>

  Let C be a published commit and C' the next one on the published branch. Between C and C', the archive files MAY change only as follows:

  1. a new object folder <verbatim|ocfl/\<less\>path\<gtr\>/>, where <verbatim|\<less\>path\<gtr\>> is the object's path in the layout of the storage root (<verbatim|\<less\>owner\<gtr\>/\<less\>name\<gtr\>> in the owner-name layout, or the folders of the hash and the encoded identifier in the hashed layout, section 5 of the specification), with the folders above it that it needs (a new owner's folder, or folders of the hash), and the files of a complete OCFL object: a new object, or the copy of a line kept elsewhere, up to its latest signed version (its root inventory then that of this version, section 10.4 of the specification); 2. new version folders <verbatim|ocfl/\<less\>path\<gtr\>/v\<less\>N\<gtr\>/> to <verbatim|ocfl/\<less\>path\<gtr\>/v\<less\>M\<gtr\>/>, M not less than N, where <verbatim|v\<less\>N-1\<gtr\>> is the head of the object in C, with the replacement of the object's root <verbatim|inventory.json> and its checksum file by those of <verbatim|v\<less\>M\<gtr\>>, and the versions' signature files in item 3; 3. files added in an object's <verbatim|extensions/opensheaf-witnesses/> folder: signature files <verbatim|\<less\>version\<gtr\>/signature-\<less\>k\<gtr\>.json> of the line's owner that are not invalid (section 13.2 of the specification), their timestamp files, others' witnesses and, in an owner object, the evidence of forks of its key log under <verbatim|fork/> (section 6.5 of the specification). A file there, once published, is never replaced or removed, except with its object by a takedown, even when it is not a witness (a stray or malformed file, which is reported and kept): timestamps are made of the bytes of signature files, and a completed timestamp proof is a new file beside the pending one; 4. the replacement of <verbatim|opensheaf.json>, and files added, replaced or removed among the indexes (<verbatim|indexes.json>, <verbatim|names/>, <verbatim|owners/>, <verbatim|sha512/>), which are rewritten at every deposit and takedown (section 6.6 of the specification, proposal); 5. at the creation of the storage root, its own files (<verbatim|0=ocfl_1.1>, <verbatim|ocfl_layout.json>, the configuration of the layout extension, and the loose files allowed by section 5 of the specification); 6. the removal of an object folder, with the folders above it that it leaves empty (an owner's folder, or folders of the hash), by a takedown (section 9); 7. the repair of a file whose bytes do not match the digest its inventory records (section 5.3); 8. any change inside the folder of a draft (section 6.5 of the specification; <verbatim|ocfl/draft/\<less\>id\<gtr\>/> in the owner-name layout), including its removal, with the creation of the <verbatim|draft/> folder and its removal when it is left empty: drafts are the only objects that may be rewritten or deleted, and are never copied out of the archive.

  No other file of the archive changes, and no file of an existing version folder is changed, renamed or removed, except by a repair. Several changes MAY be made in one commit.

  <strong|Only signed versions are added.> Every object version added by items 1 and 2, other than a draft's, MUST be signed once added (sections 6.5 and 13.2 of the specification): signed with good signatures of its line's owner, against the key log of the owner object kept at its path, which the same commit adds or extends if needed, or extended by a version so signed that the same commit adds; and, for an owner that has ended, or whose key log is forked, as the commit's tree shows (by <verbatim|ended>, or by the evidence of a fork), versions of its lines are added only from a copy found elsewhere, up to the latest signed version of a copy that agrees with the published line, never as a new deposit (section 6.5 of the specification). A version of a key log added is signed with good signatures of keys of the version before, up to and including one with <verbatim|ended>, and none after it, nor after the point of a fork whose evidence the tree holds. Since nothing is removed from the published branch afterwards and OCFL cannot skip a version, a version let in that is not signed would hold its number for good, and the owner's own version of that number could never be added to this archive. Versions already published stay, whatever happens later.

  The published branch MUST NOT be rewritten, except for a takedown (section 9). Repositories SHOULD use the protection of their host to refuse force-pushes to the published branch and its deletion (on GitHub: a branch protection rule or a ruleset).

  <subsection*|5.2 Every published commit is an archive><label|52-every-published-commit-is-an-archive>

  Every published commit MUST hold a conforming archive: the archive files of the commit, alone, pass the verification of section 14 of the specification. In particular a new object version, the replaced root inventory and the updated discovery document are committed together. Since a deployment serves the files of one commit, readers never see half a deposit.

  <subsection*|5.3 Repairs><label|53-repairs>

  A published commit may hold a file whose bytes differ from those its inventory records: a Git LFS pointer committed in place of the file (section 4.2), line endings converted by a clone with other attributes, a file damaged on disk. The inventory, and every pin to it, still name the right bytes; only this copy of the file is wrong. The depositor's own clone may hold the right bytes and verify, while every other copy fails.

  Such a file MUST be repaired by a new commit on the published branch that replaces its bytes by bytes whose digest is the one its inventory records, taken from any copy that matches (the depositor's files, the LFS storage, a mirror, an external deposit). A repair changes no inventory, no checksum file and no discovery document; its commit message SHOULD name the files it repairs and say why. A repair is not a rewrite: the commits holding the wrong bytes stay in the history, as a record of what was served.

  If no copy with the right bytes can be found, the file is lost. It MUST NOT be replaced by other bytes, and verifiers keep reporting it as missing or corrupt. (Lost and corrupted files are in scope for OCFL version 2; see section 11.3 of the specification.)

  <section*|6. Commits, working branches and merging><label|6-commits-working-branches-and-merging>

  <subsection*|6.1 Commits><label|61-commits>

  A commit MAY add any number of object versions. A commit SHOULD hold one act of the archive (a deposit, an import, an update of the main collection, the addition of witnesses), and its message SHOULD name the object versions it adds (for instance <verbatim|kpz-details v3: document version 2, the published version>).

  The author and committer of a commit record who made the commit; the inventory records who deposited each object version (its <verbatim|user>) and when (its <verbatim|created>), and the inventory is authoritative. They may differ: an assistant commits a version deposited by an author.

  Commits and tags MAY be signed. They are witnesses of who published a state of the archive, not part of its integrity (section 13.2 of the specification).

  <subsection*|6.2 Working branches><label|62-working-branches>

  Git branches other than the published branch are <dfn|working branches>: working space, not branches of an object (section 10.5 of the specification, proposal). They MAY be rewritten, but only drafts may be rebuilt on them: a sealed version is signed by its owner, and is never rebuilt, on any branch, since a new version with other bytes would be a fork of its line (section 6.5 of the specification). Drafts, under the reserved owner <verbatim|draft>, may change freely; sealing makes a new, fixed object from a draft; private states of archives are discussed in <hlink|issue #29|https://github.com/opensheaf/opensheaf.github.io/issues/29>.

  <subsection*|6.3 Merging><label|63-merging>

  A deposit prepared on a branch is published by merging the branch into the published branch. The published branch MUST then satisfy section 5, comparing the merge commit with its first parent.

  Two branches may conflict:

  <\itemize>
    <item><strong|Versions of the same object.> If both add version <verbatim|v\<less\>N\<gtr\>> of the same draft, the second to be merged MUST be redone by the tool as <verbatim|v\<less\>N+1\<gtr\>>, with a new inventory; it MUST NOT be resolved by editing files. A sealed version is signed when it is made (section 6.5 of the specification), and never rebuilt (section 6.2): two versions <verbatim|v\<less\>N\<gtr\>> of one line are a fork of the line, never redone by a merge; only one is published, and the other is reported.

    <item><strong|The discovery document and the main collection.> Branches that add versions to different objects both change <verbatim|opensheaf.json>, and usually the main collection. A merge of these files as text can produce a discovery document that parses but no longer matches the storage root, or a collection version holding the members of only one branch. The <verbatim|-merge> attribute (section 4.1) makes every such change a conflict; the tool resolves it by writing the discovery document again from the storage root, and by making a new version of the collection, never by combining texts.
  </itemize>

  A deposit MAY be proposed by a pull request (or merge request) and published by the maintainer of the archive when it is merged, after the checks of section 10 have passed on it. The version MUST already be signed by its line's owner, with the owner's own keys, before the pull request is merged: a contributor proposes versions of its own lines, or copies of other owners' lines up to their latest signed versions, and continues another owner's line only by a branch under its own owner (section 10.5 of the specification). The object version is created (its <verbatim|created> date in the inventory) before it is published. (When a version becomes public, and how this is recorded, is discussed in <hlink|issue #29|https://github.com/opensheaf/opensheaf.github.io/issues/29>.)

  <section*|7. Publishing><label|7-publishing>

  <subsection*|7.1 What is served><label|71-what-is-served>

  A deployment MUST serve the archive files of one published commit, byte for byte (section 5 of the specification), and MAY serve presentation files. It SHOULD NOT serve working files. A deployment SHOULD be made only from a commit whose verification (section 10) has passed.

  The bytes MUST be taken from a checkout made with the attributes of section 4.1, or directly from the git objects (for instance with <verbatim|git archive>, which honours <verbatim|-export-subst>).

  <subsection*|7.2 GitHub Pages><label|72-github-pages>

  GitHub Pages can publish a branch, or the files uploaded by a workflow. Publishing by a workflow is RECOMMENDED: the workflow verifies the commit, copies only the archive and presentation files, and resolves Git LFS pointers if presentation files use them.

  A branch published directly is served whole, and is processed by Jekyll unless the branch has a <verbatim|.nojekyll> file at the top of the published folder. Jekyll leaves out files and folders whose names begin with <verbatim|_> or <verbatim|.>, which sources often have (<verbatim|_preamble.tex>, <verbatim|.latexmkrc>). A repository published from a branch MUST therefore contain <verbatim|.nojekyll>.

  GitHub Pages compresses responses (<verbatim|Content-Encoding: gzip>); the bytes after decoding are those stored, as the specification requires. It allows cross-origin requests (<verbatim|Access-Control-Allow-Origin: *>), as the specification recommends. Its limits are in section 8.

  <subsection*|7.3 Other hosts><label|73-other-hosts>

  Any static web server, or object storage, can serve a checkout of a published commit, under the same rules. A deployment that copies files (for instance with <verbatim|rsync>, or to a bucket) MUST copy the files of the checkout without conversion, and SHOULD remove files that are not in the commit.

  <subsection*|7.4 Raw file servers><label|74-raw-file-servers>

  A forge's raw file server, such as <verbatim|raw.githubusercontent.com> for a public GitHub repository, serves the files of a branch or a commit directly from the git objects, at <verbatim|https://raw.githubusercontent.com/\<less\>owner\<gtr\>/\<less\>repository\<gtr\>/\<less\>branch or commit\<gtr\>/>. With the attributes of section 4.1, it serves the archive files byte for byte, and it allows cross-origin requests (<verbatim|Access-Control-Allow-Origin: *>): it meets the requirements of section 5 of the specification, and tools, including those running in a browser, can read and verify the archive from it.

  It does not serve a website: it sends files as <verbatim|text/plain> or <verbatim|application/octet-stream>, with <verbatim|X-Content-Type-Options: nosniff>, so an archive that follows the website profile MUST also be published by another deployment (section 7.2 or 7.3). It serves Git LFS pointers, not the files (section 4.2), caches responses for some minutes, may limit the rate of requests, and its base URL changes when the repository or the branch is renamed (a URL with a commit hash names a fixed state).

  Its base URL MAY be listed in <verbatim|mirrors> of the discovery document, as a second location; it is not independent of the forge, and does not replace a copy kept elsewhere (section 11).

  <section*|8. Size and limits><label|8-size-and-limits>

  An archive keeps every version of every object, so a repository only grows. Hosts set limits; on GitHub, as of November 2026:

  <block|<tformat|<cwith|1|1|1|-1|font-series|bold>|<cwith|1|-1|1|-1|cell-valign|top>|<cwith|1|-1|1|-1|cell-hyphen|t>|<table|<row|<cell|What>|<cell|Limit>>|<row|<cell|a file in a repository>|<cell|a warning at 50 MB; refused above 100 MB>>|<row|<cell|a repository>|<cell|best below 1 GB; strongly advised below 5 GB>>|<row|<cell|a site on GitHub Pages>|<cell|at most 1 GB>>|<row|<cell|traffic of a site on GitHub Pages>|<cell|a soft limit of 100 GB a month>>>>>

  Git stores identical files once, across objects and versions, as OCFL already does within an object (a file unchanged in a new version is not stored again). A repository's history also keeps every rebuild made while the format is a draft: in the first archive, the storage root takes 132 MB and the history 240 MB.

  An archive near these limits can:

  <\itemize>
    <item>keep only working files and presentation files in git, and the storage root in object storage, whose URL the discovery document gives (<verbatim|storageRoot>, section 6.1 of the specification); git then no longer keeps the archive, and this document no longer applies to its storage root;

    <item>store large files with Git LFS, deployed by a workflow (section 4.2);

    <item>move to a host with other limits, or to its own server.
  </itemize>

  Tools working on a large archive MAY use a partial clone (<verbatim|git clone --filter=blob:none>) or a sparse checkout, since adding a version to an object needs only that object's folder and the discovery document. In git, the owner-name layout reaches its limits first: every deposit rewrites the tree of an owner's folder, which lists every line of that owner, and the tree of <verbatim|ocfl/>, which lists every owner, and the web views of forges show at most about a thousand entries of a folder. An archive expected to hold tens of thousands of objects or more SHOULD therefore be created with the hashed layout (section 5 of the specification), which spreads the objects over folders of a few entries each. (Indexes for archives of millions of objects are discussed in <hlink|issue #19|https://github.com/opensheaf/opensheaf.github.io/issues/19>.)

  <section*|9. Takedown><label|9-takedown>

  A takedown deletes an object from the storage root and adds a tombstone to the discovery document (section 11.2 of the specification). In git, a commit that deletes the object folder removes it from what is served, but not from the history: the files remain in every earlier commit, every clone, every fork and every archive of the repository.

  When content must be removed (by law, or for a breach of rights), the maintainer MUST:

  1. commit the removal of the object folder and the tombstone, and the update of the indexes if the archive keeps them (the object's entries kept with <verbatim|status> <verbatim|removed>, its name removed from <verbatim|owners/>, section 6.6 of the specification, proposal), as in section 5.1, items 4 and 6; owner objects whose key logs other objects of the archive need are not removed with the line, and an owner object is taken down only for itself (section 11.2 of the specification); 2. rewrite the history of every branch of the repository to remove the object's files from every commit (for instance with <verbatim|git filter-repo --invert-paths --path ocfl/\<less\>path\<gtr\>/>, with the object's path in the layout); 3. force-push the rewritten branches, and delete tags that point to commits holding the files; 4. ask the host to remove what it keeps of the old history (on GitHub, cached views and the references of pull requests are removed on request to its support; forks are separate repositories, which it does not change).

  This is the only rewrite of the published branch allowed. The commit of step 1 SHOULD say that it is a takedown, and name the object, so that a check comparing the history before and after (section 10) can recognise it. The rewrite changes the hash of every commit after the first that held the object: signatures of those commits and tags no longer verify, and clones must be made again. Copies of the repository elsewhere (forks, other clones, Software Heritage) follow their own rules, as external copies do (section 11.3 of the specification).

  <section*|10. Verification><label|10-verification>

  A repository is checked, besides the verification of section 14 of the specification on each published commit, for:

  <\itemize>
    <item><strong|attributes>: <verbatim|git check-attr> reports <verbatim|text>, <verbatim|filter>, <verbatim|ident>, <verbatim|working-tree-encoding>, <verbatim|export-subst> and <verbatim|merge> unset on every archive file (section 4.1);

    <item><strong|no pointers, links or submodules> among the archive files: no Git LFS pointer, symbolic link or submodule (sections 3 and 4.2);

    <item><strong|append-only>: between each published commit and the next, only the changes of section 5.1 (for a pull request: between its base and its head); nothing is removed from an object's version folders or witness folder except by a takedown, and a change to a file of an existing version folder is accepted only as a repair, when the new bytes have the digest its inventory records and the old bytes did not;

    <item><strong|signed additions>: every object version added, other than a draft's, is signed once added, as section 5.1 says, against key logs that are owner objects at their paths in the commit's tree; an added version that is not signed (unsigned, invalid, or unchecked: a key-log version not found), unless a signed version added in the same commit extends it; a version of a key log after one with <verbatim|ended>, or after the point of a fork whose evidence the tree holds; and an added signature file of the owner that is invalid, are failures, so that a pull request adding them cannot pass;

    <item><strong|reported, never failing>: versions already published that are not signed (a breach of section 5.1 that cannot be undone), files that are not witnesses, ended owners and the versions added to their lines (which come only from copies, a rule the check cannot see), forks of lines and of key logs (section 6.5 of the specification);

    <item><strong|portable names>: the content paths of section 4.3 (a warning, not an error);

    <item><strong|the deployment>: after a deployment, the served discovery document, and the files it names, have the digests of the commit.
  </itemize>

  These checks SHOULD run on every push and every pull request (for instance in a workflow), before any deployment.

  <section*|11. Copies, mirrors and witnesses><label|11-copies-mirrors-and-witnesses>

  A clone of the published branch is a complete copy of the archive. A clone that is served (for instance a fork published with GitHub Pages) is a copy at another base URL; the archive MAY list it in <verbatim|mirrors> of its discovery document (section 6.1 of the specification). It is not a mirror in the sense of section 10.4 of the specification, which copies one line kept elsewhere into an archive's own storage root.

  Mirroring a line kept elsewhere is copying its files and checking them against a pin; it does not need, and SHOULD NOT use, a merge of the other archive's repository.

  A mirror is a copy of a line (section 10.4 of the specification), at the path of its identifier, with the owner objects of every owner whose signatures it carries (its own, and for a branch its parents' owners) at their own paths; signatures are in each object's <verbatim|extensions/opensheaf-witnesses/>. Copying a line is copying those object folders, up to the latest signed version of the line (section 5.1); an owner moving to another archive copies its folder of the owner-name layout (section 5 of the specification). A branch holds the evidence of its parent version as content files (section 10.5 of the specification), so it never shares an object folder with a copy of its parent's line.

  A public repository SHOULD be archived by <hlink|Software Heritage|https://www.softwareheritage.org/>, which keeps dated snapshots of it named by SWHIDs. A snapshot is a witness that the archive held these files at that date, as other external copies are (section 13.2 of the specification); its identifiers are git hashes, not part of the integrity of the archive. Together with the history of the published branch, snapshots also witness the successive states of the discovery document.

  <section*|12. Security and privacy><label|12-security-and-privacy>

  <\itemize>
    <item><strong|What is pushed is public.> Everything committed to a public repository, on any branch, including working files and commits later reverted, is published and copied, and is hard to withdraw (section 9). Private drafts and private reviews (issue <hlink|#29|https://github.com/opensheaf/opensheaf.github.io/issues/29>) MUST NOT be pushed to a public repository, even on a branch.

    <item><strong|Commit metadata> publishes the names and e-mail addresses of authors and committers, and their time zones. Maintainers SHOULD commit with an address meant to be public (on GitHub, a <verbatim|noreply> address). Commits that concern anonymous referees are made in the name of the journal, not of the referee.

    <item><strong|Code.> Filters and hooks are configured by each user, not by the repository; the attributes of section 4.1 keep user filters off the archive files. Workflows SHOULD NOT build or run deposited sources.

    <item><strong|Secrets>, such as tokens for Zenodo and the private keys of owners, MUST NOT be committed; workflows read tokens from the secrets of the host. Owners sign with their own tools, before a version is pushed; a workflow that signs holds a key of the owner, and is as trusted as that key.

    <item><strong|Pull requests> are checked before they are merged (section 10): a version that is not signed cannot pass, and once merged nothing can remove it (section 5.1).
  </itemize>

  <section*|13. Open questions><label|13-open-questions>

  1. <strong|A profile, or a guide?> This document adds nothing that readers see, so it is not declared in the discovery document. Tools that copy archives would gain from knowing where to clone one from: should the discovery document name its repository (a <verbatim|repository> URL), or the website link to it? 2. <strong|Takedown without rewriting history.> Section 9 makes takedown a rewrite of history. Alternatives: content files outside git, one repository per object, or the deletion mechanism expected in OCFL 2 (section 11.3 of the specification). Archives that hold documents of others (a journal, an institution) need it most. 3. <strong|Portable content paths> (section 4.3): a recommendation here, or a rule of the specification itself, since it matters for any copy made on another system? 4. <strong|Drafts and publication dates> (sections 6.2 and 6.3): the draft state and the date a version becomes public, in <hlink|issue #29|https://github.com/opensheaf/opensheaf.github.io/issues/29>. 5. <strong|Scale> (section 8): indexes and the size of git trees for very large archives, in <hlink|issue #19|https://github.com/opensheaf/opensheaf.github.io/issues/19> and <hlink|issue #32|https://github.com/opensheaf/opensheaf.github.io/issues/32>. 6. <strong|Objects held by others> (<hlink|issue #13|https://github.com/opensheaf/opensheaf.github.io/issues/13>): whether objects controlled by their authors and kept by custodians call for one repository per object, and how such repositories make up an archive without submodules.

  <section*|14. Changelog><label|14-changelog>

  <\itemize>
    <item><strong|0.1 (draft), 15 November 2026:> first draft; raw file servers (section 7.4), which serve the archive files byte for byte with cross-origin requests allowed, but not a website nor Git LFS files; repairs (section 5.3) of a file whose bytes do not match its inventory, the only change allowed to an existing version folder.

    <item><strong|0.1 (draft), 16 November 2026:> the hashed storage layout in the append-only rules, takedowns and the advice for large archives (sections 5.1, 8 and 9); the indexes of the identity proposal as archive files (sections 4.1, 5.1 and 9); working branches (section 6.2), on which a sealed version is never rebuilt.

    <item><strong|0.1 (draft), 17 November 2026, for the identity proposal of the specification (PR #30):> copies of lines carry their signers' key logs as owner objects, the parents' owners' included, and an owner moves by copying its folder (section 11); drafts at <verbatim|draft/\<less\>id\<gtr\>/> may change or go (section 5.1, item 8); witness files, signature files <verbatim|signature-\<less\>k\<gtr\>.json> among them, are only added, never replaced or removed except with their object by a takedown, and the evidence of forks of key logs is kept among them (item 3); several versions of an object may be added in one commit (item 2); only signed versions are added, a copy stopping at its latest signed version, and none to the lines of an ended or forked owner (section 5.1), and the check of section 10 fails a commit or pull request that adds any other, or an invalid signature file of the owner, while what was published before is only reported; two signed versions of one number are a fork, never redone by a merge, and only drafts are redone (section 6.3); contributors propose their own lines, or copies of others' signed lines (section 6.3); takedowns leave in place the owner objects that other objects need (section 9); private keys are never committed (section 12). Setting aside versions, removing files, revocation and the tail, tried during the day, were withdrawn.; after a thirteenth review: the key log of an ended or forked owner is added up to its end, and its lines may be copied, only extending them is refused.

    <item><strong|0.1 (draft), 18 November 2026:> the lines of an ended or forked owner are added only from copies, up to the latest signed version of a copy that agrees, also to extend a published line, and reported; no key-log version after the point of a known fork; the exception for versions extended in the same commit applies to unsigned versions only (sections 5.1 and 10).
  </itemize>

</body>

<\initial>
  <\collection>
    <associate|page-medium|paper>
  </collection>
</initial>
