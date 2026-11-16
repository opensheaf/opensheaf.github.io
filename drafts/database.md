# A database behind an OpenSheaf archive

*Working paper, draft of 16 November 2026. Non-normative: ideas and positions,
not decisions. An OpenSheaf archive is a folder of plain files served over
HTTP. This paper asks what a database can do for it: as an index derived from
the files, as the storage behind a server that delivers them, or instead of
them. It sets out what the format requires of any of these, the trap of
re-serialising metadata, an index published as a static SQLite file for large
archives, and experiments.*

## 1. The question

The specification describes an archive as plain files on a static website, and
the [deployment note](deployment.md) says that nothing else is needed: "no
server software, no database". Some keepers will want one all the same: an
institution holding thousands of objects, an aggregator reading many archives,
a portal depositing for researchers, an archive with private versions (issue
[#29](https://github.com/opensheaf/opensheaf.github.io/issues/29)), an archive
the size of arXiv (issue
[#19](https://github.com/opensheaf/opensheaf.github.io/issues/19)). The
question is where a database may sit without changing the format, and where it
would.

## 2. What the format fixes

The format constrains only what a reader receives. Section 5 of the
specification requires every file of the discovery document, the storage
root and `witnesses/` to be "served byte for byte, as stored", at fixed paths
under the base URL; it allows git and static servers ("MAY") but does not
require them. A verifier (section 14) sees nothing but HTTP responses and
checks them against the pins. Whatever produces the responses is free, so long
as:

- **the bytes are those that were hashed**, every time, for every file;
- **the archive only grows**: the files of an object version never change,
  and nothing in the storage root disappears except by a takedown (section
  11);
- **readers never see a version half made**: the discovery document names a
  version only once all its files are served (section 3 of the deployment
  note gives the order for uploads);
- **the archive can leave**: it can be written out as a plain OCFL storage
  root, the same bytes at the same paths, and served from anywhere else.

The last is the test of every design below: export the archive to a folder,
validate the folder with an OCFL validator and the OpenSheaf verifier, and
compare it, byte for byte, with what the server delivers.

## 3. Three roles

### 3.1 An index derived from the files

The storage root stays the truth; a database holds what is read from it, and
can be rebuilt from it at any time. This is the common pattern for OCFL:
Fedora 6 keeps its repository as OCFL objects with an index in a relational
database, which it can rebuild from the objects, and the Java library
ocfl-java can keep object locks and a cache of object details in a database.

Uses:

- **search and browsing**: titles, authors, dates, subjects, relations, read
  from `datacite.json` and `object.json` of every version;
- **an aggregator**: an index over many archives, filled by reading their
  discovery documents and following their collections, with the pins checked
  once and recorded;
- **generated files**: the discovery document, the Atom feed (`feed`, section
  6.1), a sitemap and the landing pages of the website profile, written from
  the index after each deposit;
- **a verifier's memory**: the digests already checked, so that a new
  verification checks only what is new.

Rules: the index records, for each object version it read, the digest of its
inventory, so that it can say which version it describes and notice a
change; it is never the only copy of anything; and it is not evidence. Like
the discovery document, it is a map.

This role needs nothing from the format. It is what an aggregator, a portal
(section 8 of the deployment note) or a large Explorer would do anyway.

### 3.2 The storage behind a server

The files are kept in a database or an object store, and a server delivers
them at the paths of the storage root. Content files can be stored once, keyed
by their SHA-512 digest, which the inventories already give; inventories,
checksum files, `datacite.json`, `object.json`, `members.json` and the
discovery document are stored as the bytes that were written.

Gains:

- **Deduplication across objects.** OCFL stores a file once within an object;
  a store keyed by digest stores it once across the archive (the same PDF in
  a document and in an accepted copy, the same figure in several papers).
- **Transactions.** A deposit can be one transaction: the new version becomes
  visible, discovery document included, all at once or not at all. OCFL leaves
  concurrent writing to implementations, which use locks; a database provides
  them.
- **Access control.** Private versions and reviews (#29) need a server that
  decides who reads what; a static host cannot.
- **Scale.** Millions of objects (#19) are easier to keep in a database than
  in a folder tree, and the discovery document can be generated, or paged,
  from it.

Costs:

- **A server.** The archive is no longer a static site: it needs software
  running, kept secure and up, where a static host needs none. A static
  export, published as a mirror (`mirrors`, section 6.1), keeps the archive
  readable when the server is down.
- **The bytes** (section 4).
- **The export** must be maintained and tested, since it is the way out and
  the proof of conformance.
- **Mirrors and custodians** still copy files: what they receive is the OCFL
  storage root, whatever the source keeps.

### 3.3 A database instead of the files

The truth is in rows; the files are generated on request, and not kept. This
is the question of the [working paper on git](git-as-implementation.md)
(section 5.1) again, with less in its favour:

- a database is read only with its software, in a format of that software's
  version; a dump is a backup, not a format of preservation;
- no other tool can validate the archive as it is kept, only as it is served;
- every pin depends on the generation being right, every time, for every
  file, in every later version of the software;
- the archive leaves only through an export that is never exercised until it
  is needed.

This paper does not recommend it. A database that generates the files once,
and then keeps them as bytes, is the design of section 3.2.

## 4. The bytes

A pin is the SHA-512 digest of the bytes of an inventory, and an inventory
fixes every file by the digest of its bytes, metadata files included:
`datacite.json`, `object.json` and `members.json` are content files of their
versions. JSON has many ways of writing the same value: the order of keys,
spaces and line ends, escapes (`\u00e9` or the character itself, `\/` or
`/`), numbers (`1.0`, `1`, `1e0`), a final line end. A database that parses
these files into rows, or into a JSON column (PostgreSQL's `jsonb` reorders
keys and drops spaces), and writes them out again, will sooner or later write
other bytes. Every pin of that version, and of every version after it, then
fails.

Rules:

- Keep every file as the bytes written at deposit, in a byte column or an
  object store, and serve those bytes.
- Columns for search are read from the bytes, never the other way round.
- Check the digest when storing and, from time to time, when reading:
  databases and object stores fail too, and the inventory says what the bytes
  must be.

The same trap catches the git view of the other paper, where inventories are
copied into commits "as stored, never re-serialised".

## 5. A published index for large archives

A discovery document lists every object of an archive. For an archive of a
few hundred objects it is small; for millions (#19) it is hundreds of
megabytes, which no browser tool should download to find one object.

A SQLite database can be served as one static file and queried from a browser
without a server: libraries such as sql.js-httpvfs run SQLite in the page and
read the file with HTTP range requests, fetching only the pages a query
needs. An archive could publish such a file beside the discovery document,
with a table of objects (identifier, head version, digest of its inventory,
kind), and tables read from the metadata (titles, authors, dates), so that a
reader can find an object, or search the archive, with a few requests.

Conditions and limits:

- **It is a map.** Like the discovery document, it is checked against the
  storage root: what it says about a version is confirmed by the version's
  inventory and the pins.
- **It is replaced, not changed.** A reader fetching pages of a file while it
  is replaced gets pages of two databases. Each build gets a new name (for
  instance its digest), and a small file, or the discovery document, names
  the current one.
- **The host must honour range requests**, send the cross-origin header for
  them, and not compress the file in a way that breaks ranges; GitHub Pages,
  object storage and ordinary web servers are expected to, to be tested.
- **It is derived**, so it can always be rebuilt from the storage root, and
  its format (a SQLite file of a given schema) need not be preserved.

Sharded JSON (one file per prefix of identifiers, for instance) gives the
lookups without SQLite, but not the search; both are answers to #19, which is
open. Either would need a field in the discovery document naming the index;
this paper proposes none.

## 6. What the specification and the notes might say

- **Nothing new in the format** for sections 3.1 and 3.2: the specification
  already constrains only the bytes served. A sentence in section 5 could say
  so outright: an archive may be served by any server, static or not, that
  delivers the files as stored.
- **The deployment note** says that a server backed by a database is a host
  like any other, on the same conditions, with the export test.
- **The tools**: `osheaf` could export and check (`osheaf export`, comparing
  a folder with a base URL byte for byte), which is useful for any host.
- **An index for large archives** (section 5) belongs to #19.

## 7. Experiments

1. **The export test.** A command that downloads an archive from its base URL
   into a folder, validates the folder, and compares every file with the
   source; run against the first archive on GitHub Pages and on its raw file
   server, then against any server backed by a database.
2. **An index of the first archive.** The objects and metadata of
   `mgubi/papers` in a SQLite file on GitHub Pages, queried from the Explorer
   with range requests: requests and bytes per lookup, compared with reading
   the discovery document.
3. **An aggregator.** An index of several archives and their collections,
   rebuilt from scratch and updated from the discovery documents, with the
   digests it has checked.
4. **Round trip.** Deposit through a server keeping files in a database,
   export, and compare digests; then parse and rewrite the JSON files on
   purpose, to show what the rules of section 4 prevent.

## 8. Open questions

- Should section 5 of the specification say explicitly that any server may
  serve an archive, or is "MAY be kept in git and served by any static web
  server" already read that way?
- Does a large archive publish an index, and in what form (SQLite, sharded
  JSON, paged discovery documents)? Issue #19.
- How does an archive with private versions (#29) serve them: one server with
  access control, or a private archive beside a public one?
- Should `osheaf` provide the export test as a command?

Related issues:
[#19](https://github.com/opensheaf/opensheaf.github.io/issues/19) (scale),
[#29](https://github.com/opensheaf/opensheaf.github.io/issues/29) (private
archives and reviews); and the [working paper on git](git-as-implementation.md)
and the [deployment note](deployment.md).
