# Working papers

Drafts about OpenSheaf that are not part of the specification: positions,
ideas, comparisons, designs being thought through. They are non-normative.
Where they describe something the specification does not support, they say
so and point to the issue where it is discussed; where they disagree with
the specification, the specification is right.

The papers are plain Markdown, read on GitHub. They are not built into the
site, and they may change or be dropped at any time. A paper that settles
into an agreed design goes into the specification, the FAQ or the use
cases, through an issue.

| Paper | About |
|---|---|
| [positioning.md](positioning.md) | The functions of scholarly communication (record, preserve, announce, filter, distribute, assign merit), OpenSheaf as an exchange layer between the parties that carry them, comparisons with scholarly infrastructure and with federated and distributed systems, what separating the functions costs, and proposals |
| [git-as-implementation.md](git-as-implementation.md) | Git's commits, trees, references and transport as the implementation of OpenSheaf: git instead of OCFL, a deterministic git view of OCFL objects (checkable through Software Heritage), or git as transport only; the lines of PR #30 in git terms; experiments |
| [deployment.md](deployment.md) | Where and how to serve an archive: what a host must do, the hosts that work (static hosting, raw file servers, object storage, institutional web space, WebDAV servers) and those that do not (cloud drives, shared drives, reference managers), the order of uploads, several locations, and how to check a deployment |
| [database.md](database.md) | A database behind an archive: as an index derived from the files, as the storage behind a server that delivers them byte for byte, or instead of them (not recommended); the trap of re-serialising metadata; an index published as a static SQLite file for large archives; Fedora, and why OpenSheaf objects cannot be Fedora objects but Fedora can store and serve an archive's files; experiments |
| [radicle.md](radicle.md) | Radicle, a peer-to-peer network for git repositories, set against OpenSheaf: repositories named by a digest and owners as keys (PR #30), peer namespaces as lines, seed nodes as mirrors and custodians, signed references and witnesses, collaborative objects; names and RID collisions, read from its source; Radicle as a transport for archives in git, as a model (not recommended), or as a source of designs; its security disclosure of September 2026; experiments |
