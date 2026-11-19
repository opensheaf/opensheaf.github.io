# OpenSheaf archives in git

*Companion to the OpenSheaf specification 0.1. Version 0.1 (draft), 19 November 2026. How to keep an OpenSheaf archive in a git repository, publish it from there and copy it, without git changing a byte of what the archive holds. It adds nothing to the format: readers of an archive never need to know that it is kept in git. The text is licensed under CC BY-SA 4.0.*

> [!WARNING]
> **Draft for discussion.** This document is a first draft. Its open questions are listed in section 13; none of them is settled.

## 1. Introduction (non-normative)

The [OpenSheaf specification](opensheaf-specification-0.1.md) allows an archive to be kept in git and served by any static web server (section 3 of the specification), and says that git hashes are not part of its integrity (sections 7.6 and 15.2). This document says how, for those who keep an archive in git and for the tools that write to such a repository.

Git gives an archive what the format leaves to its maintainer:

- **a history of the whole archive**: every state of the discovery document, so every state the archive published, which the format itself does not keep (the discovery document is a mutable map, section 3.1 of the specification);
- **copies**: every clone is a complete copy of the archive, with its history;
- **review before publication**: a deposit can be prepared on a branch, checked, and merged;
- **checks on every change**, by continuous integration;
- **hosting**, through services such as GitHub Pages.

Git also works against an archive in four ways, which this document answers:

- **Bytes.** By default git may convert line endings, run filters, expand keywords or store large files elsewhere (Git LFS). The files of an archive must be stored and served byte for byte (section 4).
- **History can be rewritten**, and files edited in place. Object versions must never change (section 5).
- **History cannot easily forget.** A takedown must remove content; in git, a deleted file stays in every earlier commit, every clone and every fork (section 9).
- **Size.** Hosts limit files, repositories and sites; an archive keeps every version forever (section 8).

The principle: git is a store and a transport for the files of the archive. The archive is what is on the published branch. Git never changes those bytes, and the files published change only as section 5.1 allows; the history of the published branch is never rewritten, except for a takedown (section 9).

## 2. Conventions and terms

The key words MUST, MUST NOT, REQUIRED, SHOULD, SHOULD NOT, RECOMMENDED, MAY and OPTIONAL are to be interpreted as described in BCP 14 (RFC 2119, RFC 8174) when, and only when, they appear in all capitals. Terms of the specification (archive, storage root, discovery document, object, object version, pin, mirror, witness, takedown, tombstone, owner, owner object, key log, draft, signed version, not a version, ended owner, fork of a line, fork of a key log, fork record, current key, rotation key, exposed key) keep their meaning.

- <dfn>Repository</dfn>: a git repository holding one archive.
- <dfn>Archive files</dfn>: the files the specification requires to be served byte for byte: the discovery document `opensheaf.json`, the storage root (by convention `ocfl/`) and, if used, the indexes (the folders `names/`, `owners/` and `sha512/`, which an archive declares in its discovery document, and `indexes.json`, only in a repository that serves indexes for several archives, as a custodian or a resolver does; section 12.5 of the specification).
- <dfn>Presentation files</dfn>: the website of the archive (appendix A.3 of the specification), generated from the archive files.
- <dfn>Working files</dfn>: every other file of the repository: settings of tools, descriptions of deposits, sources being prepared, scripts, workflows.
- <dfn>Published branch</dfn>: the branch from which the archive is served (usually `main`). A <dfn>published commit</dfn> is a commit of its first-parent history.
- <dfn>Deployment</dfn>: the copy of the files of a published commit to the place the archive is served from.

A repository conforms to this document if every published commit satisfies sections 3 to 5 and its deployments satisfy section 7. A tool conforms if every commit it makes on the published branch, and every deployment it makes, keeps the repository conforming. Conformance to this document is not declared in the discovery document (but see section 13, question 1).

## 3. The repository

A repository SHOULD hold one archive, with the discovery document at the top of the repository and the storage root in `ocfl/`. An archive kept in a sub-folder of a larger repository is allowed; what follows then applies to that folder.

Working files MAY be kept in the repository. They are not part of the archive: they MUST NOT be placed inside the storage root or the folders of the indexes, and they are not published unless the maintainer means them to be (section 7).

The archive files MUST NOT contain symbolic links or git submodules. Members of collections that belong to other archives are reached through the discovery documents of those archives and checked by their pins (section 8.5 of the specification), never included as submodules; copies of lines kept elsewhere are mirrors (section 11 of the specification), copied byte for byte into the storage root.

## 4. Storing bytes

### 4.1 Attributes

The repository MUST contain a `.gitattributes` file at its top with these lines (with the lines of the indexes only if it keeps them, and the paths adjusted if the archive is in a sub-folder):

```
# OpenSheaf archive files: stored and checked out byte for byte,
# never merged as text.
opensheaf.json -text -filter -ident -working-tree-encoding -export-subst -merge
ocfl/**        -text -filter -ident -working-tree-encoding -export-subst -merge
indexes.json   -text -filter -ident -working-tree-encoding -export-subst -merge
names/**       -text -filter -ident -working-tree-encoding -export-subst -merge
owners/**      -text -filter -ident -working-tree-encoding -export-subst -merge
sha512/**      -text -filter -ident -working-tree-encoding -export-subst -merge
```

- `-text`: no conversion of line endings, whatever the settings of the clone (`core.autocrlf`, `core.eol`).
- `-filter`: no clean or smudge filter, such as that of Git LFS.
- `-ident`: no expansion of `$Id$` in file contents.
- `-working-tree-encoding`: no conversion of character sets.
- `-export-subst`: no substitution in copies made by `git archive`.
- `-merge`: no merge as text (section 6.3).

Attributes in the repository take precedence over those of the user (`core.attributesFile`) and of the system only for the attributes they name; an attribute the repository leaves unspecified falls through to them. A user-wide `*.pdf filter=lfs` would otherwise apply to the PDFs of the archive. For this reason every attribute is named, not only `-text`.

### 4.2 Git LFS

Archive files MUST NOT be stored with Git LFS, or any other mechanism that keeps a pointer in the repository in place of the file, unless every deployment and every copy of the repository used as a copy of the archive replaces the pointers by the files. A deployment that serves the pointer serves a file whose digest does not match its inventory. GitHub Pages, deploying from a branch, serves the pointers. Pointers committed by mistake are repaired (section 5.3).

### 4.3 File names

Git stores file names as bytes, but the file systems it checks them out on are not alike: macOS and Windows ignore case by default, macOS may change the Unicode normalisation of names, Windows forbids some characters (`<>:"|?*`) and names (`CON`, `NUL`, ...) and limits the length of paths. A file whose name cannot be checked out cannot be verified or served from that clone.

OCFL separates the logical path of a file (its name in the version, as the depositor gave it) from its content path (where its bytes are stored in the object). Tools SHOULD choose content paths that check out everywhere: path segments made of ASCII letters, digits, `.`, `_` and `-`, not ending with `.`, no two content paths of an object differing only in case, and each content path at most 200 characters from the top of the repository. Logical paths keep the names given by the depositor.

### 4.4 What git does not keep

Git keeps neither empty folders nor modification times, and records of file modes only whether a file is executable. None of these is part of an OCFL object: inventories list files, not folders, and dates come from the inventories. Tools MUST NOT rely on any of them.

## 5. The published branch

### 5.1 Append-only

Let C be a published commit and C' the next one on the published branch. Between C and C', the archive files MAY change only as follows:

1. a new object folder `ocfl/<path>/`, where `<path>` is the object's path in the layout of the storage root (`<owner>/<name>` in the owner-name layout, or the folders of the hash and the encoded identifier in the hashed layout, section 3.2 of the specification), with the folders above it that it needs (a new owner's folder, or folders of the hash), and the files of a complete OCFL object: a new object, or the copy of a line kept elsewhere, up to its latest signed version (its root inventory then that of this version, section 11.1 of the specification);
2. new version folders `ocfl/<path>/v<N>/` to `ocfl/<path>/v<M>/`, M not less than N, where `v<N-1>` is the head of the object in C, with the replacement of the object's root `inventory.json` and its checksum file by those of `v<M>`, and the versions' signature files in item 3;
3. files added in an object's `extensions/opensheaf-witnesses/` folder: signature files `<version>/signature-<k>.json` of the line's owner that are not invalid (section 7.3 of the specification), their timestamp files, and others' witnesses. A file there, once published, is never replaced or removed, even when it is not a witness (a stray or malformed file, which is reported and kept), except with its object by a takedown: timestamps are made of the bytes of signature files, and a completed timestamp proof is a new file beside the pending one;
4. the replacement of `opensheaf.json`, and files added, replaced or removed among the indexes (`indexes.json`, `names/`, `owners/`, `sha512/`), which are rewritten at every deposit and takedown (section 12.5 of the specification);
5. at the creation of the storage root, its own files (`0=ocfl_1.1`; `opensheaf-owner-name-storage-layout.md` in the owner-name layout, which has no `ocfl_layout.json`, or `ocfl_layout.json` and the configuration of the layout extension in the hashed layout; and the loose files allowed by section 3.2 of the specification);
6. the removal of an object folder, with the folders above it that it leaves empty (an owner's folder, or folders of the hash), by a takedown (section 9);
7. the repair of a file whose bytes do not match the digest its inventory records (section 5.3);
8. any change inside the folder of a draft (section 10.1 of the specification; `ocfl/draft/<id>/` in the owner-name layout), including its removal, with the creation of the `draft/` folder and its removal when it is left empty: drafts are the only objects that may be rewritten or deleted, and are never copied out of the archive;

No other file of the archive changes, and no file of an existing version folder is changed, renamed or removed, except by a repair. Several changes MAY be made in one commit.

**Only signed versions are added.** Every object version added by items 1 and 2, other than a draft's, MUST be signed once added (sections 6.3, 7.3 and 7.5 of the specification). A version of a line is signed with good signatures of its owner, against the key log of the owner object kept at its path, which the same commit adds or extends if needed, or is vouched for by a version so signed that the same commit adds. A version of a key log is the first version computed from the genesis record, or is signed as section 6.1 of the specification says, or is a valid fork record, which records a fork of the key log as a new version after the latest held and replaces nothing; none follows a fork record, and none but a fork record follows an ending version (section 6.3 of the specification). Versions of the lines, other than the key log, of an owner whose key log in the commit's tree has an ending version are added only from copies found elsewhere, never as new deposits, and those of an owner whose key log there has a fork record are not added, unless other evidence dates them before the fork (section 7.5 of the specification); the key log of an ended owner is added as section 6.4 of the specification says. Versions that are contested against the key logs of the commit's tree are never added, from a copy or as a deposit (section 7.3 of the specification). Since OCFL cannot skip a version and nothing is removed from a line but by a takedown, a version let in that is not signed would hold its number for good, and the owner's own version of that number could never be added to this archive. Versions already published stay, whatever happens later.

The published branch MUST NOT be rewritten, except for a takedown (section 9). Repositories SHOULD use the protection of their host to refuse force-pushes to the published branch and its deletion (on GitHub: a branch protection rule or a ruleset).

### 5.2 Every published commit is an archive

Every published commit MUST hold a conforming archive: the archive files of the commit, alone, pass the verification of section 14 of the specification. In particular a new object version, the replaced root inventory and the updated discovery document are committed together. Since a deployment serves the files of one commit, readers never see half a deposit.

### 5.3 Repairs

A published commit may hold a file whose bytes differ from those its inventory records: a Git LFS pointer committed in place of the file (section 4.2), line endings converted by a clone with other attributes, a file damaged on disk. The inventory, and every pin to it, still name the right bytes; only this copy of the file is wrong. The depositor's own clone may hold the right bytes and verify, while every other copy fails.

Such a file MUST be repaired by a new commit on the published branch that replaces its bytes by bytes whose digest is the one its inventory records, taken from any copy that matches (the depositor's files, the LFS storage, a mirror, an external deposit). A repair changes no inventory, no checksum file and no discovery document; its commit message SHOULD name the files it repairs and say why. A repair is not a rewrite: the commits holding the wrong bytes stay in the history, as a record of what was served.

If no copy with the right bytes can be found, the file is lost. It MUST NOT be replaced by other bytes, and verifiers keep reporting it as missing or corrupt. (Lost and corrupted files are in scope for OCFL version 2, #32.)

## 6. Commits, working branches and merging

### 6.1 Commits

A commit MAY add any number of object versions. A commit SHOULD hold one act of the archive (a deposit, an import, an update of the main collection, the addition of witnesses), and its message SHOULD name the object versions it adds (for instance `kpz-details v3: document version 2, the published version`).

The author and committer of a commit record who made the commit; the inventory records who deposited each object version (its `user`) and when (its `created`), and the inventory is authoritative. They may differ: an assistant commits a version deposited by an author.

Commits and tags MAY be signed. They are witnesses of who published a state of the archive, not part of its integrity (section 7.6 of the specification).

### 6.2 Working branches

Git branches other than the published branch are <dfn>working branches</dfn>: working space, not branches of an object (section 9 of the specification). They MAY be rewritten, but only drafts may be rebuilt on them: a sealed version is signed by its owner, and is never rebuilt, on any branch, since a new version with other bytes would be a fork of its line (section 7.4 of the specification). Drafts, under the reserved owner `draft`, may change freely; sealing makes a new, fixed object from a draft; private states of archives are discussed in [issue #29](https://github.com/opensheaf/opensheaf.github.io/issues/29).

### 6.3 Merging

A deposit prepared on a branch is published by merging the branch into the published branch. The published branch MUST then satisfy section 5, comparing the merge commit with its first parent.

Two branches may conflict:

- **Versions of the same object.** If both add version `v<N>` of the same draft, the second to be merged MUST be redone by the tool as `v<N+1>`, with a new inventory; it MUST NOT be resolved by editing files. A sealed version is signed when it is made (section 7.1 of the specification), and never rebuilt (section 6.2): two versions `v<N>` of one line with different inventories are a fork of the line, never redone by a merge: only one is published, and the other is reported, or, for a key log, carried by a fork record added after the version published (section 6.3 of the specification); the first version of a key log, computed, is the same on both branches.
- **The discovery document and the main collection.** Branches that add versions to different objects both change `opensheaf.json`, and usually the main collection. A merge of these files as text can produce a discovery document that parses but no longer matches the storage root, or a collection version holding the members of only one branch. The `-merge` attribute (section 4.1) makes every such change a conflict; the tool resolves it by writing the discovery document again from the storage root, and by making a new version of the collection, never by combining texts.

A deposit MAY be proposed by a pull request (or merge request) and published by the maintainer of the archive when it is merged, after the checks of section 10 have passed on it. The version MUST already be signed by its line's owner, with the owner's own keys, before the pull request is merged: a contributor proposes versions of its own lines, or copies of other owners' lines up to their latest signed versions, and continues another owner's line only by a branch under its own owner (section 9 of the specification). The object version is created (its `created` date in the inventory) before it is published. (When a version becomes public, and how this is recorded, is discussed in [issue #29](https://github.com/opensheaf/opensheaf.github.io/issues/29).)

## 7. Publishing

### 7.1 What is served

A deployment MUST serve the archive files of one published commit, byte for byte (section 3 of the specification), and MAY serve presentation files. It SHOULD NOT serve working files. A deployment SHOULD be made only from a commit whose verification (section 10) has passed.

The bytes MUST be taken from a checkout made with the attributes of section 4.1, or directly from the git objects (for instance with `git archive`, which honours `-export-subst`).

### 7.2 GitHub Pages

GitHub Pages can publish a branch, or the files uploaded by a workflow. Publishing by a workflow is RECOMMENDED: the workflow verifies the commit, copies only the archive and presentation files, and resolves Git LFS pointers if presentation files use them.

A branch published directly is served whole, and is processed by Jekyll unless the branch has a `.nojekyll` file at the top of the published folder. Jekyll leaves out files and folders whose names begin with `_` or `.`, which sources often have (`_preamble.tex`, `.latexmkrc`). A repository published from a branch MUST therefore contain `.nojekyll`.

GitHub Pages compresses responses (`Content-Encoding: gzip`); the bytes after decoding are those stored, as the specification requires. It allows cross-origin requests (`Access-Control-Allow-Origin: *`), as the specification recommends. Its limits are in section 8.

### 7.3 Other hosts

Any static web server, or object storage, can serve a checkout of a published commit, under the same rules. A deployment that copies files (for instance with `rsync`, or to a bucket) MUST copy the files of the checkout without conversion, and SHOULD remove files that are not in the commit.

### 7.4 Raw file servers

A forge's raw file server, such as `raw.githubusercontent.com` for a public GitHub repository, serves the files of a branch or a commit directly from the git objects, at `https://raw.githubusercontent.com/<owner>/<repository>/<branch or commit>/`. With the attributes of section 4.1, it serves the archive files byte for byte, and it allows cross-origin requests (`Access-Control-Allow-Origin: *`): it meets the requirements of section 3 of the specification, and tools, including those running in a browser, can read and verify the archive from it.

It does not serve a website: it sends files as `text/plain` or `application/octet-stream`, with `X-Content-Type-Options: nosniff`, so an archive that follows the website profile MUST also be published by another deployment (section 7.2 or 7.3). It serves Git LFS pointers, not the files (section 4.2), caches responses for some minutes, may limit the rate of requests, and its base URL changes when the repository or the branch is renamed (a URL with a commit hash names a fixed state).

Its base URL is then a second location of the archive (section 3 of the specification), given wherever locations are given (the `at` of collection members and `sheaf:` URIs); it is not independent of the forge, and does not replace a copy kept elsewhere (section 11).

## 8. Size and limits

An archive keeps every version of every object, so a repository only grows. Hosts set limits; on GitHub, as of November 2026:

| What | Limit |
|---|---|
| a file in a repository | a warning at 50 MB; refused above 100 MB |
| a repository | best below 1 GB; strongly advised below 5 GB |
| a site on GitHub Pages | at most 1 GB |
| traffic of a site on GitHub Pages | a soft limit of 100 GB a month |

Git stores identical files once, across objects and versions, as OCFL already does within an object (a file unchanged in a new version is not stored again). A repository's history also keeps every rebuild made while the format is a draft: in the first archive, the storage root takes 132 MB and the history 240 MB.

An archive near these limits can:

- keep only working files and presentation files in git, and the storage root in object storage, whose URL the discovery document gives (`storageRoot`, section 3.1 of the specification); git then no longer keeps the archive, and this document no longer applies to its storage root;
- store large files with Git LFS, deployed by a workflow (section 4.2);
- move to a host with other limits, or to its own server.

Tools working on a large archive MAY use a partial clone (`git clone --filter=blob:none`) or a sparse checkout, since adding a version to an object needs only that object's folder and the discovery document. In git, the owner-name layout reaches its limits first: every deposit rewrites the tree of an owner's folder, which lists every line of that owner, and the tree of `ocfl/`, which lists every owner, and the web views of forges show at most about a thousand entries of a folder. An archive expected to hold tens of thousands of objects or more SHOULD therefore be created with the hashed layout (section 3.2 of the specification), which spreads the objects over folders of a few entries each. (Indexes for archives of millions of objects are discussed in [issue #19](https://github.com/opensheaf/opensheaf.github.io/issues/19).)

## 9. Takedown

A takedown deletes an object from the storage root and adds a tombstone to the discovery document (section 13.2 of the specification). In git, a commit that deletes the object folder removes it from what is served, but not from the history: the files remain in every earlier commit, every clone, every fork and every archive of the repository.

Every removal from the storage root is a takedown, made by step 1 below. When content must also be removed from the history (by law, or for a breach of rights), the maintainer MUST:

1. commit the removal of the object folder and the tombstone, and the update of the indexes if the archive keeps them (the object's entries kept with `status` `removed`, its name removed from `owners/`, section 12.5 of the specification), as in section 5.1, items 4 and 6; owner objects whose key logs other objects of the archive need are not removed with the line, and an owner object is taken down only for itself (section 13.2 of the specification);
2. rewrite the history of every branch of the repository to remove the object's files from every commit (for instance with `git filter-repo --invert-paths --path ocfl/<path>/`, with the object's path in the layout);
3. force-push the rewritten branches, and delete tags that point to commits holding the files;
4. ask the host to remove what it keeps of the old history (on GitHub, cached views and the references of pull requests are removed on request to its support; forks are separate repositories, which it does not change).

This is the only rewrite of the published branch allowed. The commit of step 1 SHOULD say that it is a takedown, and name the object, so that a check comparing the history before and after (section 10) can recognise it. The rewrite changes the hash of every commit after the first that held the object: signatures of those commits and tags no longer verify, and clones must be made again. Copies of the repository elsewhere (forks, other clones, Software Heritage) follow their own rules (section 13.3 of the specification, #33).

## 10. Verification

A repository is checked, besides the verification of section 14 of the specification on each published commit, for:

- **attributes**: `git check-attr` reports `text`, `filter`, `ident`, `working-tree-encoding`, `export-subst` and `merge` unset on every archive file (section 4.1);
- **no pointers, links or submodules** among the archive files: no Git LFS pointer, symbolic link or submodule (sections 3 and 4.2);
- **append-only**: between each published commit and the next, only the changes of section 5.1 (for a pull request: between its base and its head); nothing is removed from an object's version folders or witness folder except by a takedown, and a change to a file of an existing version folder is accepted only as a repair, when the new bytes have the digest its inventory records and the old bytes did not;
- **signed additions**: every object version added, other than a draft's, is signed once added, as section 5.1 says, against key logs that are owner objects at their paths in the commit's tree. An added version that is not signed (unsigned, invalid, or unchecked: a key-log version not found), unless a signed version added in the same commit extends it; a first version of a key log other than the one computed from its genesis record; a version of a key log after a fork record, or after an ending version but a fork record; a fork record that is not valid; and an added signature file of the owner that is invalid, are errors of the commit check (section 14.1 of the specification), stricter than the warnings that section 14 of the specification gives for some of these breaches, so that a pull request adding them cannot pass;
- **reported, never failing**: as warnings, versions already published that are not signed (a breach of section 5.1 that cannot be undone), files that are not witnesses, versions added to the lines, other than the key log, of ended owners (which must come only from copies, after an ending version, which the check cannot see, or, after a fork record, with evidence dating them before the fork, which the check does not weigh), and versions added that are contested (section 7.3 of the specification; the check weighs no evidence that dates them); as results, forks of lines and of key logs, exposed keys, and ended owners (sections 6.3 and 7.4 of the specification);
- **portable names**: the content paths of section 4.3 (a warning, not an error);
- **the deployment**: after a deployment, the served discovery document, and the files it names, have the digests of the commit.

These checks SHOULD run on every push and every pull request (for instance in a workflow), before any deployment.

## 11. Copies, mirrors and witnesses

A clone of the published branch is a complete copy of the archive. A clone that is served (for instance a fork published with GitHub Pages) is a copy at another base URL; it is the same archive at another location (section 3 of the specification), not a mirror in the sense of section 11 of the specification, which copies one line kept elsewhere into an archive's own storage root.

Mirroring a line kept elsewhere is copying its files and checking them against a pin; it does not need, and SHOULD NOT use, a merge of the other archive's repository.

A mirror is a copy of a line (section 11.1 of the specification), at the path of its identifier, with the owner objects of every owner whose signatures it carries (its own, and for a branch its parents' owners) at their own paths; signatures are in each object's `extensions/opensheaf-witnesses/`. Copying a line is copying those object folders, up to the latest signed version of the line (section 5.1); an owner moving to another archive copies its folder of the owner-name layout (sections 3.2 and 6.5 of the specification). A branch holds the evidence of its parent version as content files (section 9.2 of the specification), so it never shares an object folder with a copy of its parent's line.

A public repository SHOULD be archived by [Software Heritage](https://www.softwareheritage.org/), which keeps dated snapshots of it named by SWHIDs. A snapshot is a witness that the archive held these files at that date, not a copy, though it can be read as the archive it holds (section 12.3 of the specification); its identifiers are git hashes, not part of the integrity of the archive. Together with the history of the published branch, snapshots also witness the successive states of the discovery document.

## 12. Security and privacy

- **What is pushed is public.** Everything committed to a public repository, on any branch, including working files and commits later reverted, is published and copied, and is hard to withdraw (section 9). Private drafts and private reviews (issue [#29](https://github.com/opensheaf/opensheaf.github.io/issues/29)) MUST NOT be pushed to a public repository, even on a branch.
- **Commit metadata** publishes the names and e-mail addresses of authors and committers, and their time zones. Maintainers SHOULD commit with an address meant to be public (on GitHub, a `noreply` address). Commits that concern anonymous referees are made in the name of the journal, not of the referee.
- **Code.** Filters and hooks are configured by each user, not by the repository; the attributes of section 4.1 keep user filters off the archive files. Workflows SHOULD NOT build or run deposited sources.
- **Secrets**, such as tokens for Zenodo and the private keys of owners, MUST NOT be committed; workflows read tokens from the secrets of the host. Owners sign with their own tools, before a version is pushed; a workflow that signs holds a key of the owner, and is as trusted as that key.
- **Pull requests** are checked before they are merged (section 10): a version that is not signed cannot pass, and once merged nothing but a takedown can remove it (section 5.1).

## 13. Open questions

1. **A profile, or a guide?** This document adds nothing that readers see, so it is not declared in the discovery document. Tools that copy archives would gain from knowing where to clone one from: should the discovery document name its repository (a `repository` URL), or the website link to it?
2. **Takedown without rewriting history.** Section 9 makes takedown a rewrite of history. Alternatives: content files outside git, one repository per object, or the deletion mechanism expected in OCFL 2 (section 13.3 of the specification, #32). Archives that hold documents of others (a journal, an institution) need it most.
3. **Portable content paths** (section 4.3): a recommendation here, or a rule of the specification itself, since it matters for any copy made on another system?
4. **Drafts and publication dates** (sections 6.2 and 6.3): the draft state and the date a version becomes public, in [issue #29](https://github.com/opensheaf/opensheaf.github.io/issues/29).
5. **Scale** (section 8): indexes and the size of git trees for very large archives, in [issue #19](https://github.com/opensheaf/opensheaf.github.io/issues/19) and [issue #32](https://github.com/opensheaf/opensheaf.github.io/issues/32).
6. **Objects held by others** ([issue #13](https://github.com/opensheaf/opensheaf.github.io/issues/13)): whether objects controlled by their authors and kept by custodians call for one repository per object, and how such repositories make up an archive without submodules.

## 14. Changelog

- **0.1 (draft), 15 November 2026:** first draft; raw file servers (section 7.4), which serve the archive files byte for byte with cross-origin requests allowed, but not a website nor Git LFS files; repairs (section 5.3) of a file whose bytes do not match its inventory, the only change allowed to an existing version folder.
- **0.1 (draft), 16 November 2026:** the hashed storage layout in the append-only rules, takedowns and the advice for large archives (sections 5.1, 8 and 9); the indexes of the identity proposal as archive files (sections 4.1, 5.1 and 9); working branches (section 6.2), on which a sealed version is never rebuilt.
- **0.1 (draft), 17 November 2026, for the identity proposal of the specification (PR #30):** copies of lines carry their signers' key logs as owner objects, the parents' owners' included, and an owner moves by copying its folder (section 11); drafts at `draft/<id>/` may change or go (section 5.1, item 8); witness files, signature files `signature-<k>.json` among them, are only added, never replaced or removed except with their object by a takedown, and the evidence of forks of key logs is kept among them (item 3); several versions of an object may be added in one commit (item 2); only signed versions are added, a copy stopping at its latest signed version, and none to the lines of an ended or forked owner (section 5.1), and the check of section 10 fails a commit or pull request that adds any other, or an invalid signature file of the owner, while what was published before is only reported; two signed versions of one number are a fork, never redone by a merge, and only drafts are redone (section 6.3); contributors propose their own lines, or copies of others' signed lines (section 6.3); takedowns leave in place the owner objects that other objects need (section 9); private keys are never committed (section 12). Setting aside versions, removing files, revocation and the tail, tried during the day, were withdrawn.; after a thirteenth review: the key log of an ended or forked owner is added up to its end, and its lines may be copied, only extending them is refused.
- **0.1 (draft), 18 November 2026:** the lines of an ended or forked owner are added only from copies, up to the latest signed version of a copy that agrees, also to extend a published line, and reported; no key-log version after the point of a known fork; the exception for versions extended in the same commit applies to unsigned versions only (sections 5.1 and 10).
- **0.1 (draft), 19 November 2026 (PR #30):** following the rebuilt specification and its pre-rotation of key logs (#58): section references updated; `mirrors` dropped, a raw file server or a served clone being another location of the same archive (sections 7.4 and 11); every removal is a takedown, and the history of the published branch is rewritten only for one (sections 1 and 9); a fork of a key log is recorded by a fork record added as a new version after the latest held, never by replacing versions, so that repairs are the only changes of a sealed version folder (section 5.1), and at a merge the other side is carried by a fork record (section 6.3); the first version of a key log is computed from the genesis record and not signed; every version added MUST be signed, and versions that are contested, needing a key exposed on either side of a fork or naming a key-log version from a fork point on, are never added, from a copy or as a deposit; versions of the lines of an owner whose key log has a fork record are not added unless other evidence dates them before the fork, and those of an owner with an ending version only from copies (sections 5.1 and 10); the breaches that fail a commit are errors of the commit check, stricter than the warnings of section 14 of the specification, and findings are errors, warnings and results (section 10); in the owner-name layout the storage root holds `opensheaf-owner-name-storage-layout.md` instead of `ocfl_layout.json`, which names only registered OCFL extensions (section 5.1, item 5).
