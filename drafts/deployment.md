# Deploying an OpenSheaf archive: hosting options

*Working note, draft of 15 November 2026. Non-normative: practical advice
on where and how to serve an archive, outside the specification (which
refers to "a deployment guide, outside this specification"). It sets out
what a host must do, which kinds of host do it (static hosting, object
storage, institutional web space), which do not (consumer cloud drives,
shared drives, reference managers), how to upload, and how to check a
deployment. Facts about services are as of November 2026, and change:
check them before relying on them.*

## 1. What a host must do

An archive is a folder of plain files: the discovery document
(`opensheaf.json`) at the base URL, the storage root (by convention
`ocfl/`), optionally `witnesses/`, and optionally presentation files (the
website profile). Section 5 of the specification asks of whatever serves
it:

- **Fixed paths under one base URL.** Every file is reached by an
  anonymous `GET` of `<base URL>/<path>`: `opensheaf.json`,
  `ocfl/<object>/v1/inventory.json`, and so on. Links made of tokens or
  identifiers, one per file, do not do.
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

Nothing else is needed: no server software, no database, no folder
listings. The storage root may even be on another host than the
discovery document, which gives its URL (`storageRoot`, section 6.1 of
the specification).

## 2. Hosts that work

### Static hosting services

GitHub Pages, GitLab Pages, Codeberg Pages, Cloudflare Pages, Netlify and
similar services publish a folder as a website, with HTTPS, a custom
domain and proper content types: the website profile works. They are fed
from a git repository or by an upload step. This is the default for most
archives, and GitHub Pages is what the archive and collection templates
use.

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

Cloud drives that speak WebDAV are another matter (section 4).

## 3. Uploading

Whatever the host, the files of a new object version are uploaded in an
order that never shows a reader an archive that refers to files not yet
there:

1. the content files of the new version;
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
- **Shared drives built on Nextcloud or ownCloud**, including the
  university services built on them: their WebDAV endpoints need a login,
  public shares use a token in place of the archive's paths, and the
  cross-origin header is usually not sent and cannot be set by the user.
- **Reference managers' storage**, such as Zotero's: files are attachments
  of bibliographic items, reached through an API by keys, not by paths,
  under a model of editable records.

All of these keep files byte for byte, so they are good places for a
private copy of an archive, from which it is published to a host that
works.

## 5. To be tested

- **The Internet Archive.** An item on archive.org holds a tree of files,
  served at `https://archive.org/download/<item>/<path>`: possibly a free,
  long-lived copy kept by a library. Whether every file is served byte for
  byte, and whether cross-origin reads are allowed, needs a test.
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
