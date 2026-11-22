# The command-line tools

*`osheaf` is the command that keeps an OpenSheaf archive on your computer:
it deposits your papers and their new versions, signs them, keeps
collections of papers from any archive, writes the website, verifies the
whole, imports papers from arXiv and gets DOIs from Zenodo. This page shows
how to use it, task by task. It is part of
[opensheaf-py](https://github.com/opensheaf/opensheaf-py), the reference
implementation of the [specification](opensheaf-specification-0.2.md).*

> [!WARNING]
> **Under development.** The tools follow version 0.2 of the specification,
> a draft, and change with it. Archives made now may have to be rebuilt
> when the format changes. Do not rely on them yet for anything you cannot
> redo.

## Running it

The tools need Python 3.9 or later. The simplest way to run them while they
are developed is [uv](https://docs.astral.sh/uv/), which fetches the latest
version from GitHub and runs it without installing anything:

```sh
uvx --python 3.13 --from "opensheaf[validate,keys] @ git+https://github.com/opensheaf/opensheaf-py" osheaf --help
```

Give it a short name once, in your shell's configuration (`~/.zshrc` on a
Mac):

```sh
alias osheaf='uvx --python 3.13 --from "opensheaf[validate,keys] @ git+https://github.com/opensheaf/opensheaf-py" osheaf'
```

uv keeps what it fetched; to move to the latest version of the tools, run
the same line once with `--refresh` after `uvx`. Naming the Python
(`--python 3.13`) matters on a Mac: see the keychain, below.

To install the command instead, with uv or with pipx:

```sh
uv tool install "opensheaf[validate,keys] @ git+https://github.com/opensheaf/opensheaf-py"
pipx install "opensheaf[validate,keys] @ git+https://github.com/opensheaf/opensheaf-py"
```

The extras add what is optional: `validate` lets `osheaf verify` also check
the files against the JSON Schemas and the storage root with an independent
OCFL validator; `keys` keeps your keys in the system's credential store.
Nothing else is needed, unless you deposit TeXmacs documents, which the
archive typesets itself: then [GNU TeXmacs](https://www.texmacs.org) (by
default the macOS application, or wherever `TEXMACS_BIN` says) and the
TeXmacs plugins your archive names in its configuration.

**The keychain on a Mac.** When a Python other than the one that stored
your key reads it, macOS asks: "python3.13 wants to use your confidential information stored in
opensheaf-current-key". Answer **Always Allow**, with your login password,
and that Python is not asked again. A different Python is asked anew, which
is why the line above names one. If you would rather keep no key on the
computer at all, see [Where the keys are kept](#where-the-keys-are-kept).

`osheaf --help` lists the commands, and `osheaf COMMAND --help` (for
instance `osheaf collection add --help`) gives the options of each.
`osheaf help-config` describes the configuration file of an archive,
`osheaf.json`, and your own, `~/.config/opensheaf/config.json`.

## Your first archive

An archive is a folder. `osheaf init` makes it, together with its
<dfn>owner</dfn>: the keyed identity that signs every version of your
papers (section 6 of the [specification](opensheaf-specification-0.2.md#6-owners)).

```sh
osheaf init my-papers --name "Papers of Jane Doe" --base-url https://janedoe.github.io/papers/ \
  --curator "Doe, Jane" --affiliation "Example University" \
  --new-owner --export /Volumes/USB/opensheaf-keys --print
cd my-papers
```

`--base-url` is the address where the archive will be served. Every later
command is run inside the folder (or given it with `--root`).

### Choosing where the keys live

An owner has two kinds of keys. **Current keys** sign your papers; each
computer has its own. **Rotation keys**, three by default, of which any two
are needed, change the current keys: they add a new computer, retire an old
one, or declare a stolen one. Whoever holds two rotation keys controls the
owner, so where they live is the owner's **security level**, chosen with
`--keys` when the owner is made:

- `--keys offline` (the default, and the safest). The rotation keys are
  written once, encrypted under a passphrase you choose, to the folder of
  `--export` (a USB stick), and, with `--print`, printed on sheets. `init`
  asks you to type back the check of each key once it is put away. They are
  never kept on the computer: store the stick and the sheets apart from it,
  and from each other.
- `--keys github:OWNER/REPO`, a key wallet in a private GitHub
  repository of its own (create it by hand first, for instance with
  `gh repo create me/opensheaf-keys --private`; the tools refuse a public
  one, or the archive's own). The rotation keys and the current keys are
  kept there, encrypted under the passphrase, and a new computer gets its
  key from the wallet. It needs the [GitHub CLI](https://cli.github.com),
  signed in once with `gh auth login`.
- `--keys command`, a key wallet in your password manager (1Password's
  `op`, Bitwarden's `bw`, `pass`): the same, through a `read` and a `write`
  command, given as a JSON object,
  `{"wallet": "command", "read": READ, "write": WRITE}`, where READ prints
  a key and WRITE stores one (for 1Password, READ is
  `op read 'op://Private/opensheaf-{owner}-{k}/notesPlain'`). Since these
  commands run on your computer, they are read only from your own
  configuration: the environment variable `OPENSHEAF_WALLET`, or
  `~/.config/opensheaf/config.json`; never from an archive's
  `osheaf.json`, which anyone may have written, and which is refused if it
  names one. Chapter 9 of the
  [literate program](https://opensheaf.org/opensheaf-py/) gives the
  commands for the three managers.

A wallet trades security for convenience: whoever controls the wallet and
knows the passphrase controls the owner, and the tools say so each time
they put keys in one. Keep the passphrase elsewhere than the wallet. You
can move up to `offline` at any time with one rotation (see
[Keys](#keys)).

```sh
osheaf init my-papers --name "Papers of Jane Doe" --base-url https://janedoe.github.io/papers/ \
  --curator "Doe, Jane" --new-owner --keys github:janedoe/opensheaf-keys
```

`--keeper` names who answers for the owner, an ORCID iD or a domain of
yours (`--keeper https://orcid.org/0000-0002-1825-0097`, or
`--keeper https://example.org/`; section
[6.6](opensheaf-specification-0.2.md#66-keepers)). An owner can keep
several archives: `osheaf init` with `--owner OWNER --key-log DIR` instead
of `--new-owner` starts an archive with an owner you already have, copying its key log from another
archive.

### What appears in the folder

- `osheaf.json`: the settings of the archive (name, address, owner,
  curator, the GitHub wallet if any);
- `.gitattributes`, unless the folder has one already: it tells git to keep
  every file of the archive byte for byte (section
  [4.1](opensheaf-git-0.2.md#41-attributes) of
  [OpenSheaf archives in git](opensheaf-git-0.2.md));
- `ocfl/`: the storage itself, one folder per work, with the key log of the
  owner at `ocfl/<owner>/<owner>/`;
- `opensheaf.json`: the discovery document, which readers and tools start
  from, with the labels of your papers;
- `names/`, `owners/`, `sha512/`: indexes for looking things up;
- the website: `index.html`, a page per paper at `paper/<label>/`, a page
  per owner at `owner/<owner>/`, `sitemap.xml`, and the templates they are
  made from in `templates/`, which you can edit.

With `--index texmacs`, the home page is instead a TeXmacs document made
from a template (`--index-template FILE`), with HTML versions of TeXmacs
papers in `site/`; the landing pages are the same. `--curated` makes an
owner catalogue that you choose by hand rather than one that lists every
paper.

## Daily work

### Depositing a paper

A new paper gets a **label** of your choice, which names it in your archive
and gives the address of its page, `paper/<label>/`. `--new` makes the new
work; the deposit prints its permanent name, a `sheaf:` URI. A label may
change later (`osheaf label`, below); the permanent name does not.

```sh
osheaf deposit kpz-uniqueness paper.tex --pdf paper.pdf --new \
  --extra-source refs.bib --extra-source figures/fig1.pdf=figures/fig1.pdf \
  --title "Energy solutions of KPZ are unique" \
  --author "Doe, Jane|Example University" --author "Roe, Richard|Another University" \
  --abstract-file abstract.txt --keyword "stochastic PDE" \
  --rights cc-by-4.0 --available 2015-08-31
```

`--rights` takes an SPDX key (`cc-by-4.0`, `cc-by-sa-4.0`, `cc0-1.0`,
`gpl-3.0-only`, `gpl-3.0-or-later`) or a statement in plain text; by
default a new version keeps the licence of the previous one, and a new
paper is "All rights reserved". Any source works (LaTeX, Markdown, ...) with its PDF; a TeXmacs source
(`.tm`) needs no PDF, since the archive typesets it. A paper whose sources
are lost is deposited as a PDF alone, saying why:
`--no-source "the sources are lost"`; `osheaf complete LABEL --version N
--source paper.tex` adds them later. Files are kept byte for byte.

The options can also come from a YAML or JSON file, with the same names,
which is handy for papers with many authors or for several deposits at once
(a list in the file):

```sh
osheaf deposit --from kpz.yaml
```

```yaml
id: kpz-uniqueness
source: paper.tex
pdf: paper.pdf
extra-sources: [refs.bib]
title: Energy solutions of KPZ are unique
authors:
  - Doe, Jane|Example University
abstract: |
  We prove that energy solutions of the KPZ equation are unique.
rights: cc-by-4.0
available: 2015-08-31
```

### New versions

The same command without `--new` adds a version, signed, to the paper with
that label. It keeps the abstract, keywords and licence of the previous
version unless you give them again:

```sh
osheaf deposit kpz-uniqueness paper.tex --pdf paper.pdf --changes "Typos corrected." \
  --title "Energy solutions of KPZ are unique" --author "Doe, Jane|Example University"
```

Dates follow the specification: `--available` (when this version was
first made available, public or not; by default today, the deposit),
`--created` for when a version deposited long after was written, `--issued`
for the first appearance of the work. A version found
later, which belongs earlier in the history, is placed with `--after N`.
The publication stage is `--stage` (`AM` for an accepted manuscript, `VoR`
for the version of record, ...).

### Notices, corrections and withdrawals

These change what is said about a paper without changing its files. Each
makes a new version that holds only the description.

```sh
osheaf notice kpz-uniqueness --about 1 --text "Lemma 2 is wrong as stated; see version 2."
osheaf describe kpz-uniqueness --title "Energy solutions of the KPZ equation are unique"
osheaf relicense kpz-uniqueness --rights cc-by-4.0 --method "confirmed by email"
osheaf relate kpz-uniqueness --to arxiv:1508.07764 --relation IsIdenticalTo
osheaf withdraw kpz-uniqueness --reason "Superseded by a joint paper."
```

A notice is about one version (`--about`) and stays in every later one;
its `--text` is required, and `--file` adds a full statement, such as an
erratum. `describe` corrects the title, the abstract, the keywords or the
authors. `relicense` records a new licence with the authors' agreement;
its `--rights` takes the same values as that of `deposit`. `relate` links the same work elsewhere (on
arXiv, or by a DOI). `withdraw` withdraws the versions of the paper
deposited so far: the content stays, and every page that shows them shows
the withdrawal; its `--reason` is required. A later `deposit` of a new
version reinstates the paper, while the versions withdrawn stay withdrawn
(section [13](opensheaf-specification-0.2.md#13-withdrawal-takedown-and-tombstones)).

### Changing a label

A label is your archive's choice, and may change
(section [3.1](opensheaf-specification-0.2.md#31-the-discovery-document));
the permanent name of a paper, its `sheaf:` URI, does not.

```sh
osheaf label kpz-uniqueness kpz-energy-solutions    # a paper or a collection, by its label
osheaf label "sheaf:<name>:<owner>" kpz-copy        # a line without a label, by its identifier
osheaf label --owner <owner> jane-doe               # the owner object
osheaf label kpz-copy --unset                       # no label: the page is at paper/<name>/
```

The discovery document, the indexes and the website are written again;
the featured collection is renamed in `osheaf.json` too. The page moves to `paper/<new>/`, and the HTML version
of a TeXmacs paper to `site/<new>/<new>.html`, with its images. The
versions already deposited give the old address in their descriptions,
and links to it are out in the world, so the old address leads to the
new one: `osheaf.json` records it in `formerAddresses`, and the website
keeps a small page there that sends the reader on. A takedown removes
them with the paper.

### Updating the archive and checking it

```sh
osheaf collect   # new versions of the owner catalogues, listing the latest versions
osheaf index     # rewrite opensheaf.json, the indexes and the website
osheaf verify    # check everything, as section 14 of the specification asks
```

Each owner the archive hosts has an owner catalogue of its own, made when
the owner is set up (by `osheaf init`, or by `osheaf owner init` for
another owner in the same archive), which lists its papers in the archive,
branches included
(section [8.1](opensheaf-specification-0.2.md#81-catalogues-and-selections)).
`osheaf collect` gives a new version only to the catalogues whose papers
changed, each signed by its own owner; `--owner OWNER` takes one owner's
catalogue alone. The catalogue of the archive's first owner is labelled
`main`; that of another owner `<label>-catalogue`, when the owner has a
label, which `osheaf label --owner` gives or changes with the owner's.

With several owners, the home page lists the papers of all the catalogues
together, newest first, each with its owner; with
`"index": {"owners": "by-owner"}` in `osheaf.json` (the default is
`"together"`), it lists them under a heading for each owner, in the order
of `owners` in `opensheaf.json`. With one owner both are the same.

The website is written again after every command that changes the archive,
so `osheaf index` is only needed to rewrite everything. `osheaf verify`
reports errors, warnings and the status of every signature and member;
`--remote` also checks the members of your collections held in other
archives, and `--json` prints the findings for a program. The same checks
can be run on a published archive from the browser, with the
[Explorer](https://opensheaf.org/explorer/).

### Publishing

An archive is plain files: serve the folder from any static web server, at
the address given as `--base-url`. With git and GitHub Pages, the easiest
start is the [archive template](https://github.com/opensheaf/archive-template),
which has the workflows and Pages already set up. A folder made with
`osheaf init` is ready for git as it is: `init` wrote its `.gitattributes`,
so that git keeps every file byte for byte. Then, after each change:

```sh
osheaf verify
git add -A && git commit -m "A new version of kpz-uniqueness" && git push
```

On GitHub, turn Pages on once (**Settings**, **Pages**, **Deploy from a
branch**, `main`, `/ (root)`). The archive is only ever added to: never
rewrite the history of a published branch.

## Keys

The owner's <dfn>key log</dfn> is kept in the archive, and travels with
every copy of your papers, so that anyone can check that a version was
signed by you (section [6](opensheaf-specification-0.2.md#6-owners)).
The private keys are never in the archive.

```sh
osheaf owner show   # the key log: current keys, rotation keys committed, keeper
osheaf key list     # what the key wallet holds (never a secret)
```

Wallets and owners are many to many: one wallet may hold the keys of
several owners (an institution's), several people may share one owner's
keys in a wallet, each with a passkey of their own, and the keys of one
owner may be in several wallets. Two lists say where keys are looked for:

- your own wallets, in `~/.config/opensheaf/config.json`,
  `{"wallets": ["github:me/opensheaf-keys", "github:institute/keys"]}`;
- for each owner of an archive, the wallets that hold its keys, as hints
  in its `osheaf.json`, `"keys": {"<owner>": {"wallets": [...]}}`
  (GitHub wallets only), written by `init`, `owner init` and `owner
  rotate` with `--keys github:...`, and by `key push --wallet github:...`.

The `key` commands look for the keys of an owner in the wallets hinted
for it, then in yours, in order, and use the first that holds them;
`OPENSHEAF_WALLET` wins over both, and `--wallet github:OWNER/REPO` (or
`--wallet command`) names another. A wallet configured under `keys` in
your file (a command wallet) comes after your `wallets`.

```sh
osheaf key wallet                    # where the keys of the owner are looked for, in order
osheaf key wallet --owner OWNER --add github:me/opensheaf-keys     # a hint in osheaf.json
osheaf key wallet --remove github:me/old-keys
osheaf key wallets                   # your wallets, the owners each holds, their locks
osheaf key wallets --add github:institute/keys                     # in your configuration file
```

### A new computer

With a key wallet, a new computer takes the current key from it:

```sh
osheaf key pull     # asks the passphrase (or the passkey), keeps the key here
```

With the offline level, a new computer makes its own key, which two
rotation keys add to the key log:

```sh
osheaf key new      # on the new computer: prints its did:key
osheaf owner rotate --add did:key:z6Mk... \
  --rotation-key /Volumes/USB/opensheaf-keys/rotation-...-1.txt \
  --rotation-key /Volumes/USB/opensheaf-keys/rotation-...-2.txt \
  --export /Volumes/USB/opensheaf-keys-2 --print
```

Each rotation uses up the rotation keys that sign it and makes new ones,
exported as the first were; destroy the old ones once it is done. `owner
rotate --retire DID` retires a key you no longer use.

### Unlocking with a passkey

With a key wallet, a **passkey** (Touch ID on a Mac, or a security key) can
replace the passphrase:

```sh
osheaf key enroll   # once: asks the passphrase, then makes the passkey in the browser
osheaf key unlock   # on another computer: Touch ID, and the current keys are pulled
```

`key enroll` opens the page
[unlock.opensheaf.org](https://unlock.opensheaf.org/) in the browser, which
makes a passkey for `unlock.opensheaf.org` and hands a secret derived from
it back to `osheaf` on your own computer. `osheaf` opens the page a second
time, to check that the new passkey alone gives the same secret, and only
then locks the keys of the owner in the wallet under that secret as well as
under the passphrase. A passkey kept in iCloud Keychain is on all your
Macs. From then on, whenever `osheaf` needs a key of the wallet, it opens
the page, which asks for Touch ID. The page needs a recent browser (Safari
17, Chrome 133, Firefox 130 or later) and a passkey provider that supports
the PRF extension (iCloud Keychain, Google Password Manager, 1Password, or
a security key).

**Check the code.** Each time, `osheaf` prints a code of six digits ("Check
that the browser shows the code 123 456"), and the page shows one too. The
page does nothing until you tick **The terminal shows the same code**; a
page that shows another code was not opened by this `osheaf`: close it.

The passphrase remains the way back: `osheaf` asks for it if the page
reports an error, after two minutes without an answer, when you press
Ctrl-C while it waits, or when the browser's answer does not open a key.
Writing new keys into the wallet still needs the passphrase. Run
`osheaf key enroll` again after a rotation that did not unlock with the
passkey, so that it opens the new keys too; `--new-passkey` adds a passkey
of another provider. `--no-browser` prints the address instead of opening
it.

**From the browser.** The
[OpenSheaf Manager](https://manager.opensheaf.org/) does the same for the
owner of an archive it keeps ("Write directly", then "Set up a key
wallet"): it puts the current key of your computer's key store in a
private repository you created, locked with the passphrase, as `osheaf key
push` does, and adds the lock of a passkey made by the same page of
`unlock.opensheaf.org`, opened as a popup of the Manager, as `osheaf key
enroll` does. The files are the same, and `osheaf key pull` and `osheaf
key unlock` read them. When the current key is not at hand, the page can
make a new one instead ("Create a new key here"): it adds the key to the
owner's key log by a new version, as `osheaf owner rotate --add` does,
signed by the rotation keys you give it (the files `--export` wrote, or
those the wallet keeps at the security level `--keys github:OWNER/REPO`),
commits that version to the archive and puts the key in the wallet. With
files, the new rotation keys are given back as files of the same names
and text (and the sheets of `--print`), locked with the passphrase, and
the version is committed only once you have typed their checks; with the
wallet, the new ones are put there. The rotation keys then pass through
the page's memory: the maximum security level keeps them offline, used by
`osheaf` alone.

**A new archive from the browser.** For a repository made from the
archive template and not set up yet, the Manager can also make the owner
itself ("Create the owner and set up the archive here"), as `osheaf init
--new-owner --key DID` makes it: a current key that signs in the page and
goes to your key wallet, a current key for the archive's workflows (the
`DID`, stored as the repository secret `OPENSHEAF_SIGNING_KEY` when your
sign-in may set secrets, otherwise shown once for you to store), and three
rotation keys, two of which sign the next version of the key log; the
first version of the key log is the one `osheaf` makes for the same keys
and time. The rotation keys are given as the files of `--export` (one zip,
or one by one) and the sheets of `--print`, locked with the passphrase,
and nothing is committed until their checks are typed back; or, at the
level `--keys github:OWNER/REPO`, they are kept in the wallet. The page
then sets the archive up as the template's "Set up the archive" does, with
the same files, and opens it with your key unlocked. The rotation keys
pass through the page's memory: to keep them away from any browser, make
the owner with `osheaf` (the key ceremony of the template's README), which
the Manager also guides.

**Passkeys made on opensheaf.org.** The first version of the page, at
`opensheaf.org/manager/unlock.html`, made passkeys for `opensheaf.org`,
which `osheaf` no longer asks the browser for; the keys they locked still
open with the passphrase. Move once, to a passkey for
`unlock.opensheaf.org`, then remove the old locks (the passphrase lock
stays):

```sh
osheaf key enroll --new-passkey
osheaf key forget --rp opensheaf.org
```

`osheaf key forget --passkey CRED` likewise removes the locks of one
passkey, named by its credential.

### Where the keys are kept

On each computer, the current key is kept in the system's credential store
(the macOS keychain, with the extra `keys`), or else in the keychain through
the `security` command, or else in a file under `~/.config/opensheaf/keys`
readable only by you. The environment variable `OPENSHEAF_KEY_STORE`
chooses: `keyring`, `security` (the macOS keychain through its own
command) or `file` use that store alone, and **`none`** keeps no key on the
computer at all: every command that signs opens the key from the wallet
(one Touch ID, or the passphrase) and forgets it when it ends. `none` needs
a key wallet, and suits `uvx`, whose Pythons come and go:

```sh
export OPENSHEAF_KEY_STORE=none
```

Other variables: `OPENSHEAF_WALLET` names the wallet instead of
`osheaf.json` (to keep its name out of a public archive, or for a command
wallet);
`OPENSHEAF_PASSPHRASE_COMMAND` names a command that prints the passphrase
(for instance `security find-generic-password -w -s opensheaf-passphrase`);
`OPENSHEAF_UNLOCK=passphrase` skips the passkey, as does
`OPENSHEAF_PASSPHRASE` (the passphrase itself, for scripts). In a workflow on GitHub, a
key of its own, added with `owner rotate --add`, is given in the secret
`OPENSHEAF_SIGNING_KEY`; the template's README shows how.

A key also moves through a password manager by the clipboard: `osheaf key
export --clipboard` (with `--encrypt` to encrypt it under the passphrase),
and `osheaf key import --clipboard` on the other computer.

### Moving up to offline

A wallet's rotation keys can be replaced by offline ones in one rotation,
after which those in the wallet are used up and can be removed:

```sh
osheaf owner rotate --keys offline --export /Volumes/USB/opensheaf-keys --print
osheaf key forget --from-wallet --used
```

### If a computer is lost or stolen

Its current key must be treated as known to someone else. From another
computer, make a new key and **expose** the old one: a new version of the
key log, signed by two rotation keys, which a thief holding only the
current key cannot contest (section
[6.3](opensheaf-specification-0.2.md#63-ending-exposed-keys-and-forks)).
`osheaf owner show` gives the `did:key` of the lost key.

```sh
osheaf key new                                   # prints did:key:NEW
osheaf owner expose did:key:OLD --add did:key:NEW \
  --rotation-key /Volumes/USB/opensheaf-keys/rotation-...-1.txt \
  --rotation-key /Volumes/USB/opensheaf-keys/rotation-...-2.txt \
  --export /Volumes/USB/opensheaf-keys-2 --print
```

With a key wallet, leave out `--rotation-key` and `--export`: the rotation
keys are read from the wallet. If the passphrase of the wallet may also be
known, move up to offline at the same time (`--keys offline --export DIR`).
Versions that only the exposed key signed are now **contested**; if you
made them, sign them again with the new key:

```sh
osheaf sign kpz-uniqueness --version v3
```

Publish the result at once, so that readers learn of the exposure.

### Ending an owner

`osheaf owner end` signs the last version of the key log, with two
rotation keys, for instance when the work moves to another owner
(`--successor OWNER`), or when rotation keys may have been stolen, which is
the one thing an exposure cannot repair; `--expose DID` also exposes keys.
An ended owner signs nothing more; what it signed before stays good.

## Collections and other archives

### Collections

A <dfn>collection</dfn> gathers papers of any archive, each pinned to a
version (section [8](opensheaf-specification-0.2.md#8-collections)). A
**catalogue** may follow its papers to their new versions; a **selection**,
such as a reading list or a journal issue, lists only the versions you
vetted.

```sh
osheaf collection new reading --type selection --title "Reading list"
osheaf collection add reading "sheaf:<name>:<owner>?at=https%3A%2F%2Fother.example%2Fpapers%2F" --revision 2
osheaf collection add reading kpz-uniqueness --revision 1
osheaf collection status reading
```

A member is given by its `sheaf:` URI (shown on its page), with `at` or
`--at URL` saying where to find it, or by a label of your own archive; only
verified versions are pinned. In a catalogue, `--follow` (or `osheaf
collection follow`) follows a paper; `osheaf collection update` then moves
it to the latest signed version, and for a selection lists the versions
not yet vetted. `collection remove` removes a member or a revision, and
`collection sync LABEL --from collection.yaml` writes a whole collection
from a file. To show a collection first on the home page, set `"featured":
"reading"` under `index`, `html` in `osheaf.json`.

### Finding a paper

`osheaf resolve` finds and checks what a `sheaf:` URI names, in any
archive: every copy found is checked against its owner's key log, and the
URI resolves to the latest signed version among the copies that agree
(section [12.3](opensheaf-specification-0.2.md#123-resolution)).

```sh
osheaf resolve "sheaf:<name>:<owner>/v2" --at https://mgubi.org/papers/
```

### Mirrors

A library, or a colleague keeping a preservation copy, **mirrors** a paper
written elsewhere: a byte-for-byte copy, checked, with its owner's key log
(section [11](opensheaf-specification-0.2.md#11-copies-and-mirrors)). Your
archive answers for having the right to redistribute it, by its licence or the
authors' agreement (section 11.2): a version not under a licence the tool
knows to be open is copied with a warning, which `--licence-checked` silences.
`osheaf mirror --all` brings every mirror up to date, and reports a line taken
down where it was copied from: the takedown does not reach your mirror, which
you keep or take down yourself (section 13.3).

```sh
osheaf mirror "sheaf:<name>:<owner>" --at https://mgubi.org/papers/ --label kpz-copy
```

### Branches and accepted copies

A **branch** continues a signed version of someone else's paper as a paper
of your own, keeping the evidence of where it started (section
[9](opensheaf-specification-0.2.md#9-branches-and-accepted-copies)). A
journal **accepts** a paper as an accepted copy, a branch listed by one of
its selections (section [9.6](opensheaf-specification-0.2.md#96-accepted-copies));
its own typeset version is then deposited as a later version of that copy,
with `--stage VoR` and `--agreement`. A branch numbers its own versions
from 1: its first version is its version 1, whatever the parent's number,
which it records. Branching or accepting a later version of the same paper
again gives the existing branch a new branch point, its next version,
which keeps the branch's own notices (section
[9.4](opensheaf-specification-0.2.md#94-later-versions-and-new-branch-points)).

```sh
osheaf branch "sheaf:<name>:<owner>/v3" --at https://other.example/papers/ --label kpz-continued
osheaf accept "sheaf:<name>:<owner>/v2" --at https://other.example/papers/ --selection issue-1
```

### Key logs of other owners

`osheaf owner pull URL` compares your copy of an owner's key log with the
copy at another archive: it extends yours, or, if the two disagree, records
a fork, which freezes that owner.

```sh
osheaf owner pull https://other.example/papers/ --owner <owner>
```

### Drafts and sealing

A **draft** is unsigned work in progress at `draft/<id>/`, listed apart in
the discovery document and deleted without a trace (section
[10](opensheaf-specification-0.2.md#10-drafts-and-sealing)). It takes the
options of `deposit`. **Sealing** makes it a signed paper, version 1.

```sh
osheaf draft new notes notes.tex --pdf notes.pdf --title "Notes on KPZ" --author "Doe, Jane"
osheaf draft deposit notes notes.tex --pdf notes.pdf --replace
osheaf seal notes --label kpz-notes --delete-draft
```

### Taking down

`osheaf takedown` deletes an object, leaving a tombstone in the discovery
document. It is for what must not be served (by law, for a breach of
rights, to erase personal data) or a paper the archive stops keeping, not
for a paper that is merely wrong, which is withdrawn instead (section
[13](opensheaf-specification-0.2.md#13-withdrawal-takedown-and-tombstones)).

```sh
osheaf takedown kpz-notes --reason "Deposited by mistake."
```

## arXiv and Zenodo

### Importing from arXiv

`osheaf arxiv fetch` downloads papers from arXiv, every version with its
licence and comments (it needs no archive, and can be run again: what is
already downloaded is not fetched again). `osheaf arxiv import` makes one
signed paper per arXiv paper, one version per arXiv version, with arXiv's
files byte for byte; the labels come from `identifiers.json` in the
downloads folder.

```sh
osheaf arxiv fetch downloads --author doe_j_1        # or arXiv identifiers
echo '{"1508.07764": "kpz-uniqueness"}' > downloads/identifiers.json
osheaf arxiv import downloads --agreement "deposited by an author"
osheaf arxiv fetch downloads --refresh 1508.07764    # later: new arXiv versions
osheaf arxiv import downloads 1508.07764 --update
```

`--dry-run` shows what would be imported, and `--versions v1,v3` imports
only some versions.

### DOIs from Zenodo

`osheaf zenodo LABEL` deposits the current version of a paper on Zenodo
and records its DOI in a new, signed version (appendix
[A.1](opensheaf-specification-0.2.md#a1-zenodo-zenodo)). By default it uses
the Zenodo **sandbox**, on a copy, leaving the archive unchanged: try it
there first. `--production` deposits on zenodo.org for real.

```sh
osheaf zenodo kpz-uniqueness                  # the sandbox
osheaf zenodo kpz-uniqueness --production
```

The tokens are read from `ZENODO_SANDBOX_TOKEN` and `ZENODO_TOKEN`, or from
the credential store under `zenodo-sandbox-token` and `zenodo-token`.

## Command reference

| Command | What it does |
|---|---|
| `init` | create an archive: `osheaf.json`, storage, owner, its owner catalogue |
| `deposit LABEL [SOURCE]` | deposit a paper (`--new`) or a new version of it |
| `notice LABEL` | a notice about a version (`--about N --text TEXT`) |
| `describe LABEL` | correct the title, abstract, keywords or authors |
| `relicense LABEL` | record a new licence, with the authors' agreement |
| `relate LABEL` | link the same work elsewhere (arXiv, DOI) |
| `withdraw LABEL` | withdraw a paper (`--reason TEXT`); the content stays |
| `complete LABEL` | add the sources of a version deposited without them |
| `collect` | new versions of the owner catalogues, when needed (`--owner`: one) |
| `index` | rewrite `opensheaf.json`, the indexes and the website |
| `verify` | check the archive (`--remote`, `--json`) |
| `collection new LABEL` | make a collection (`--type`, `--title`) |
| `collection add`, `remove` | add or remove members |
| `collection follow`, `update` | follow members to their new versions |
| `collection status`, `sync` | the status of members; write from a file |
| `resolve URI` | find and check what a `sheaf:` URI names |
| `mirror URI` | copy a paper written elsewhere (`--all`: update every mirror) |
| `branch URI` | continue another owner's version as a paper of yours |
| `accept URI` | an accepted copy, listed by a selection |
| `draft new DRAFT`, `deposit`, `delete` | unsigned work in progress |
| `seal DRAFT` | seal a draft as a new paper (`--label LABEL`) |
| `label LINE LABEL` | give a paper or collection a new label (`--unset`; `--owner OWNER`: the owner object) |
| `takedown LABEL` | delete an object, leaving a tombstone |
| `owner init` | make an owner (done by `init --new-owner`); in an archive, with its owner catalogue |
| `owner show` | show the key log |
| `owner rotate` | add or retire current keys, new rotation keys |
| `owner expose DID` | declare stolen or leaked keys |
| `owner end` | the last version of the key log |
| `owner pull URL` | meet another copy of a key log |
| `sign LABEL` | sign again a version contested by an exposed key (`--version vN`) |
| `key new` | a new current key for this computer |
| `key push`, `pull` | current keys to and from the key wallet (`--wallet WALLET`) |
| `key list` | what the key wallet holds |
| `key wallet` | the wallets an owner's keys are looked for in; hints in `osheaf.json` (`--add`, `--remove`) |
| `key wallets` | your wallets and the owners each holds (`--add`, `--remove`) |
| `key forget` | remove keys from this computer (`--from-wallet`: also from the wallet) |
| `key forget --rp RP`, `--passkey CRED` | remove the passkey locks of a relying party or a passkey |
| `key export`, `import` | a key to and from a password manager |
| `key enroll`, `unlock` | open the keys of the wallet with a passkey |
| `arxiv fetch` | download papers from arXiv |
| `arxiv import DOWNLOADS` | import them, one signed paper each |
| `zenodo LABEL` | a DOI from Zenodo (sandbox, or `--production`) |
| `help-config` | describe `osheaf.json` and `~/.config/opensheaf/config.json` |

## Where to go next

- To keep an archive from the browser, without the command line: the
  [archive template](https://github.com/opensheaf/archive-template), whose
  README also walks through the key ceremony, and the
  [OpenSheaf Manager](https://manager.opensheaf.org/), which keeps an archive
  made from the template from a page. Both run `osheaf` for you.
- To look at an archive and check it: the
  [Explorer](https://opensheaf.org/explorer/), for instance on the
  [first archive](https://opensheaf.org/explorer/?url=https://mgubi.org/papers/),
  [mgubi.org/papers](https://mgubi.org/papers/), which is kept with these
  tools.
- To understand how the tools work: the
  [literate program](https://opensheaf.org/opensheaf-py/), which explains
  the code along the specification.
- Problems, questions and ideas about the tools: the
  [issues of opensheaf-py](https://github.com/opensheaf/opensheaf-py/issues);
  about the format: the
  [issues of the specification](https://github.com/opensheaf/opensheaf.github.io/issues).
