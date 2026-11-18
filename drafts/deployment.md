# Deploying an OpenSheaf archive: hosting options

*Working note, draft of 16 November 2026. Non-normative: practical advice on
where and how to serve an archive, outside the specification (which refers to
"a deployment guide, outside this specification"). It sets out what a host
must do, which kinds of host do it (static hosting, object storage,
institutional web space, servers backed by a database, and with conditions
WebDAV servers and Nextcloud shares), which do not (consumer cloud drives,
reference managers), how to upload, how to check a deployment, and middle
layers for those who use neither git nor the command line. Facts about
services are as of November 2026, and change: check them before relying on
them.*

> [!NOTE]
> Written before the rebuild of the specification (18 and 19 November 2026)
> and not updated: its section numbers are those of the earlier text. The
> `mirrors` field of the discovery document is gone: a copy served elsewhere
> is the same archive at another location (section 3), and archives have no
> identifiers (#52). Where they differ, the specification holds.

## 1. What a host must do

An archive is a folder of plain files: the discovery document
(`opensheaf.json`) at the base URL, the storage root (by convention
`ocfl/`), optionally `witnesses/`, and optionally presentation files (the
website profile). Section 5 of the specification asks of whatever serves
it:

- **Fixed paths under one base URL.** Every file is reached by an anonymous
  `GET` of `<base URL>/<path>`: `opensheaf.json`,
  `ocfl/<object>/v1/inventory.json` (or
  `ocfl/<t1>/<t2>/<t3>/<object>/v1/inventory.json` in the hashed layout of
  large archives, section 5 of the specification), and so on. Links made of
  tokens or identifiers, one per file, do not do.
- **Bytes as stored.** The archive files MUST be served byte for byte: no
  conversion of line endings or character sets, no compression that
  changes the bytes after decoding (compression in transport, such as
  `Content-Encoding: gzip`, is fine). Features that rewrite content
  (minifiers, optimisers, script injection) must be off, at least for
  `opensheaf.json`, `ocfl/` and `witnesses/`.
- **HTTPS** (SHOULD).
- **Cross-origin reads** (SHOULD): `Access-Control-Allow-Origin: *` on the
  archive files, so that tools running in a browser, such as the
  Explorer, can read the archive and resolve the members of collections.

For the **website profile** (landing pages read by readers and search
engines) the host must also serve HTML as `text/html` and PDFs as
`application/pdf`, so that browsers display them.

Nothing else is needed: no server software, no database, no folder listings.
Nor is anything else excluded: a server running software, with a database
behind it, is a host like any other if it meets these conditions (section 2,
"Servers backed by a database"). The storage root may even be on another host
than the discovery document, which gives its URL (`storageRoot`, section 6.1
of the specification).

## 2. Hosts that work

### Static hosting services

GitHub Pages, GitLab Pages, Codeberg Pages, Cloudflare Pages, Netlify and
similar services publish a folder as a website, with HTTPS, a custom
domain and proper content types: the website profile works. They are fed
from a git repository or by an upload step. This is the default for most
archives, and GitHub Pages is what the template,
[archive-template](https://github.com/opensheaf/archive-template), uses.

- **Publishing from git.** How to keep an archive in git and publish it
  without git changing a byte (attributes, Jekyll, workflows) is in
  [OpenSheaf archives in git](../opensheaf-git-0.1.md), sections 4 and 7.
- **Limits.** Each service limits the size of a site, of a file, the
  number of files or the traffic; for GitHub, see section 8 of the git
  document (a site of at most 1 GB, files under 100 MB). An archive keeps
  every version forever, so it only grows: check the limits against its
  expected size.
- **Cross-origin reads.** GitHub Pages sends `Access-Control-Allow-Origin:
  *`. Other services may need a headers file (for instance `_headers` on
  Cloudflare Pages and Netlify).

### Raw file servers of forges

The raw file server of a public repository (`raw.githubusercontent.com`)
serves the archive files byte for byte, with cross-origin reads allowed:
tools can read and verify an archive from it (tested on the first
archive). It does not serve a website (pages come as plain text, PDFs as
downloads), nor files stored with Git LFS. It is best listed as a second
location in `mirrors` of the discovery document. Details are in section
7.4 of the git document.

### Object storage

Amazon S3, Cloudflare R2, Backblaze B2, Google Cloud Storage, Azure Blob
Storage, and the S3-compatible stores that many institutions run, serve
every object of a public bucket at `<bucket URL>/<key>`: exactly the
fixed paths an archive needs. They have no practical limit on size, and
cost little for a personal archive (a few gigabytes stored; some, such as
R2, charge nothing for traffic).

Setting up:

- **Public read** for the bucket, or for the prefix that holds the archive.
- **Cross-origin reads**: a CORS rule on the bucket, for instance, in the
  form S3 and R2 use:

      [{"AllowedOrigins": ["*"], "AllowedMethods": ["GET", "HEAD"],
        "AllowedHeaders": ["*"], "MaxAgeSeconds": 3600}]

- **HTTPS and a custom domain**: S3's "website" endpoint is HTTP only, so a
  CDN goes in front (CloudFront, or Cloudflare); R2 and B2 serve HTTPS
  directly or through Cloudflare.
- **Metadata**: upload files without `Content-Encoding` (unless they are
  stored compressed, which archive files are not), and with the right
  `Content-Type` if the website profile is served from the bucket.

Object storage also suits a split deployment: the website and the
discovery document on a static hosting service, the storage root in a
bucket, named by `storageRoot`. The git repository then keeps only
working and presentation files (section 8 of the git document).

### Institutional web space

A university web server, or a personal page area on it, serves files as
they are. It usually does not send the cross-origin header by default; on
Apache it can be added for the archive folder, if the server allows
`.htaccess` files and has `mod_headers`:

    Header set Access-Control-Allow-Origin "*"

and on nginx, in the location of the archive:

    add_header Access-Control-Allow-Origin "*" always;

### WebDAV servers

A WebDAV server is a web server with methods for writing (`PUT`,
`MKCOL`), listing (`PROPFIND`) and locking; readers use plain `GET`. A
server configured for anonymous reads and authenticated writes (Apache
`mod_dav`, nginx's DAV module) serves an archive like any web server, and
gives two things more:

- **A way to publish without git.** A tool can upload new files with
  `PUT`, in the order of section 3, straight to the server: no
  repository, no workflow.
- **Folder listings.** A verifier working over HTTP cannot list folders,
  so it cannot tell whether the storage root holds objects that the
  discovery document does not list (section 14 of the specification).
  Where a server allows anonymous `PROPFIND`, a verifier could check that
  too.

Cloud drives that speak WebDAV are another matter: see Nextcloud below,
and section 4.

### Nextcloud public shares, with conditions

Nextcloud and the university services built on it (and, presumably,
ownCloud, not checked) share folders by links, `https://<host>/s/<token>`,
which open Nextcloud's web interface and reach the files of a folder by a
query string (`.../download?path=...&files=...`), not by path. Since
Nextcloud 29, however, a link share is also served over WebDAV at an
endpoint that "does not require authentication":

    https://<host>/public.php/dav/files/<share token>/

A folder shared by link, without a password, so has a base URL, and the
archive's files can be read under it with a plain `GET` (from the developer
manual; files in subfolders are reached by path, as in any WebDAV tree, though
the manual gives no example). Conditions:

- **Nextcloud 29 or later**, and link shares allowed by the administrator.
- **No password.** A share with a password needs HTTP Basic credentials,
  which readers and tools do not send.
- **Downloads allowed**: reading "only works if the download permission
  was not denied by the sharer".
- **Cross-origin reads only if the administrator adds them.** The
  documentation says nothing about CORS, and Nextcloud does not appear to
  send `Access-Control-Allow-Origin`: command-line tools can read the
  share, browser tools such as the Explorer cannot, unless the header is
  added in the web server or a proxy in front of Nextcloud.
- **Limits.** Brute-force protection and rate limits are on by default
  (`429 Too Many Requests`); how they apply to many reads of a public
  share is not documented, and a verification makes hundreds of requests.
- **The base URL is tied to the share.** Deleting and recreating the share
  changes the token, and so the URL; institutions may also set expiry
  dates on shares.
- **No website**: content types and download headers of these responses
  are not documented, and the share is not meant to display pages.
- **Writing** to a share (deploying to it) needs a share that allows
  uploads, and, for methods other than `GET`, the header
  `X-Requested-With: XMLHttpRequest`.

A Nextcloud share is thus usable as a mirror for command-line tools, and
for browser tools where the administrator adds the cross-origin header;
not as the home of an archive's website. This is from the documentation,
not yet tested on a server.

### Servers backed by a database

A server that keeps the archive's files in a database, or in a store keyed by
digest, and delivers them at the paths of the storage root, serves an archive
like a static host. It suits institutions, portals, very large archives and
archives with private versions, at the price of software to run. Conditions,
beyond those of section 1:

- **Bytes as written.** Every file, the JSON files included, is kept as the
  bytes written at deposit and served as such; never parsed into rows and
  written out again, which changes spacing, order of keys or escapes, and
  breaks every pin from that version on.
- **Whole versions.** A version appears, discovery document included, only
  once all its files are served; a transaction gives this directly.
- **A way out.** The archive can be exported as a folder, a plain OCFL storage
  root, identical byte for byte to what the server delivers. A copy of that
  export on a static host, listed in `mirrors`, keeps the archive readable
  when the server is down.

The test is the export: download the archive from its base URL into a folder,
validate it, and compare every file with the server. The [working paper on
databases](database.md) discusses this design, an index derived from the
files, and an index published as a static SQLite file for large archives.

## 3. Uploading

Whatever the host, the files of a new object version are uploaded in an
order that never shows a reader an archive that refers to files not yet
there:

1. the content files of the new version (for a new object in the hashed
   layout, after the folders of the hash, where a host needs folders created,
   such as WebDAV's `MKCOL`);
2. its inventory and inventory checksum, inside the version folder;
3. the object's root inventory and checksum (the copies of the latest
   inventory, at the root of the object);
4. witnesses, if any;
5. last, `opensheaf.json`.

An upload that fails half-way leaves extra files, never a broken archive,
and the next upload completes it.

- **Copy, do not mirror deletions.** Tools such as `rclone sync` or
  `aws s3 sync --delete` remove from the host what is not in the local
  folder. Nothing in `ocfl/` is ever deleted (apart from takedowns, which
  follow their own procedure), so use a copy without deletions for the
  storage root, or check what a sync would delete before running it.
- **No conversion.** Upload in binary mode; disable any option that
  converts line endings or character sets.
- **Caches.** CDNs and some hosts cache files for minutes or hours. Files
  of a version never change, so only `opensheaf.json`, the root
  inventories and the presentation files are affected; a short cache
  time for them (or a purge after an upload) keeps readers up to date.

## 4. Hosts that do not work

- **Consumer cloud drives**: Dropbox, Google Drive, OneDrive, iCloud Drive,
  Box. They share files by links made of tokens or identifiers, one per
  file or folder, not by paths under a base URL; links redirect to
  temporary download addresses, some show warning pages for large files,
  and cross-origin reads are not allowed. Dropbox's Public folder, which
  did serve files by path, stopped serving them for all users on
  1 September 2017; accounts of that time still have a folder of that
  name, but it is an ordinary private folder.
- **Nextcloud's ordinary share links** (`/s/<token>`, and the WebDAV
  endpoint for logged-in users, `/remote.php/dav`): they need a login, or
  reach files by a query string; the public WebDAV endpoint of section 2
  is the way that works.
- **Reference managers' storage**, such as Zotero's: files are attachments
  of bibliographic items, reached through an API by keys, not by paths,
  under a model of editable records.

All of these keep files byte for byte, so they are good places for a
private copy of an archive, from which it is published to a host that
works.

## 5. To be tested

- **Nextcloud public shares** (section 2): files in subfolders, headers
  (content types, cross-origin), rate limits under a full verification,
  on a real server.
- **The Internet Archive.** An item on archive.org holds files served at
  `https://archive.org/download/<item>/<path>`: possibly a free,
  long-lived copy kept by a library. A read-only test on existing items
  found files served byte for byte, but the cross-origin header sent for
  some types (`.json`, `.txt`, `.gz`) and not others (`.pdf`, `.xml`,
  `.html`, `.zip`), and derived files (OCR text, page images) added next
  to every uploaded PDF unless derivation is off at upload, which would
  put files listed by no inventory inside the storage root. A test
  upload is planned in issue #43.
- **IPFS.** A folder published on IPFS is served by gateways at
  `https://<gateway>/ipfs/<CID>/<path>`, but the CID changes with every
  deposit, so a stable base URL needs IPNS or DNSLink, and availability
  depends on someone keeping the content.

## 6. Several locations

An archive is safer in more than one place. Its discovery document MAY
list in `mirrors` the base URLs of complete copies served elsewhere (a
raw file server, a bucket, an institution's server). Tools fall back on
them when the main location fails, and pins say whether what they find is
right. Copies on the same provider as the main location (a forge's pages
and its raw files) protect against a broken deployment, not against the
provider; a copy kept by an institution, or a federation of them, protects
against more (see the [positioning paper](positioning.md), section 3).

## 7. Checking a deployment

- **Headers.** For the discovery document and a file of the storage root:

      curl -sI <base URL>/opensheaf.json

  should show `HTTP/2 200` (or 1.1), and `access-control-allow-origin: *`.
- **Bytes.** Download a content file and compare its SHA-512 with the
  inventory, or with the local file.
- **The whole archive.** Open it in the
  [OpenSheaf Explorer](https://opensheaf.org/explorer/) with
  `?url=<base URL>`, and run its verification; or, from a clone of the
  Explorer's repository, `node tests/verify-url.mjs <base URL>` (with
  `--digests` to download and check every content file).
- **The website.** Open a landing page in a browser: it should display,
  not download or show source.

## 8. Without git: easier ways to deposit and publish

Everything above assumes someone who can run `osheaf` and, usually, git.
Most researchers do neither. Middle layers can hide both; from the
cheapest to the most ambitious:

1. **GitHub's web pages and Actions.** The template,
   [archive-template](https://github.com/opensheaf/archive-template),
   serves both an archive of papers and collections (a reading list, a
   journal issue), and is kept entirely from the browser:
   - **Set up the archive**, a workflow run from the Actions tab with a
     short form, sets it up; it asks what the repository is mainly for
     (papers, a selection or a catalogue) and, for a collection, creates
     it and features it on the home page. GitHub Pages is turned on by
     hand, once (the workflow's token cannot), as the run's page says.
   - **Issue forms** do the rest: a deposit, with the PDF and the sources
     dragged in as attachments (a new version with the same form), a
     notice, a withdrawal, a new licence; a new collection (inside another,
     featured or not); a member added, vetted or removed, from any
     archive. A workflow checks that the issue comes from someone who may
     write to the repository, runs `osheaf`, commits and publishes, and
     answers in the issue, renaming it after what was done, so that the
     list of issues is a log of the archive; an error is explained in
     plain words and changes nothing.
   - **Update the collections**, from the Actions tab, moves catalogues to
     their members' new versions and lists the versions a selection has
     not vetted.

   No git, no installation, no server; GitHub only, and limited by the size
   of attachments (sources best in one zip, since GitHub does not accept
   every type of file, such as `.tex`, as an attachment). Tested on GitHub,
   including deposits made by dragging files into the form
   (opensheaf/archive-template#3 and #4).
2. **A deposit tool in the browser**, beside the Explorer: the author
   picks files and fills a form (pre-filled from an arXiv identifier, a
   DOI or an ORCID record); the page computes the inventories itself,
   shows the result, and writes the new version to a host: GitHub through
   its API, object storage, a WebDAV server, a Nextcloud share, or a
   local folder. It works with every host of section 2, but is a second
   implementation of deposits, which must agree with `osheaf` byte for
   byte. Writing to GitHub needs the author's authorisation, and
   GitHub's sign-in cannot be completed by a page alone: the step that
   turns the sign-in into a token needs the application's secret, which
   cannot be put in a public page, and GitHub's sign-in endpoints do not
   allow cross-origin requests from browsers. A small service is needed for
   that step. One runs at `https://opensheaf-gh-auth.opensheaf.workers.dev`
   ([opensheaf/gh-auth](https://github.com/opensheaf/gh-auth)): a
   Cloudflare Worker that completes the sign-in for a GitHub App and gives
   the token only to pages at the origins on its list (for now
   `https://opensheaf.org`); it stores nothing. The app's tokens reach only
   the repositories where the author installed it, with permission to write
   their contents, and expire after eight hours, renewed through the same
   service. Anyone can run a copy, with their own GitHub App, for their own
   pages. Alternatively the author pastes a personal access token limited
   to the archive's repository, which needs no service but is less
   convenient.
3. **Inside the authoring tool.** A "publish to my archive" command in
   TeXmacs (which has a profile in the specification), and later in
   others, sends the document, its sources and its PDF to the archive in
   one step, through one of the other routes.
4. **Archives hosted by institutions or communities.** A library or a
   learned society runs a portal: the researcher signs in (with ORCID),
   deposits through a form, and the portal keeps the archive, under the
   researcher's archive identifier. Unlike a repository, the archive
   stays the author's: it is plain files, which the author can download
   or move at any time without changing its identifier or its pins. The
   portal's operator is also a natural custodian and preservation node.

Importing what an author already has (arXiv papers, with `osheaf arxiv
import`) makes a new archive start full rather than empty, whichever
route is taken.

