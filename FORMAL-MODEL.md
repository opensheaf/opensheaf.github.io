# A formal model in Lean

*The specification is accompanied by a formal model in Lean 4: the format,
its owners and key logs, its archives and the changes they go through,
written as definitions, and the properties the specification states in
prose proved as theorems, checked by the computer. The model is a literate
program, to be read like a paper: [OpenSheaf in
Lean](https://opensheaf.org/opensheaf-lean/). This page gives a glimpse of
it.*

> [!NOTE]
> The model is **non-normative**. Where it and the specification differ,
> the specification holds, and the difference is a bug of one or the other.
> It follows version 0.2 of the specification, the current draft.

## Why a formal model

A specification states rules in prose, and promises in prose: that a pin,
once valid, stays valid; that a host cannot add a version to another
owner's line; that a fork of a key log freezes its owner. Prose leaves room
for corner cases nobody thought of. The model writes the rules as
definitions and the promises as theorems, and the proof assistant checks
that the promises follow from the rules. A theorem that fails to go through
shows a gap in the rules, or a promise stated too strongly; a definition
that cannot be written shows a rule that is ambiguous. The model was written
alongside version 0.2 of the specification, and audited several times by
reading it against the text.

The model is written as two [literate
programs](https://github.com/opensheaf/literate), in the repository
[opensheaf/opensheaf-lean](https://github.com/opensheaf/opensheaf-lean):
chapters of prose with the Lean code inside them, from which the Lean files
are generated and checked.

- [The model](https://opensheaf.org/opensheaf-lean/model/): objects, lines
  and owners, key logs, signatures, archives, collections, branches and
  drafts, and what valid changes guarantee; the use cases as theorems; what
  cannot happen; what keys can do; a reader's check; and stories checked by
  computation.
- [OpenSheaf as a sheaf](https://opensheaf.org/opensheaf-lean/sheaf/): an
  application of the model, which makes the name precise. Named document
  versions are the points of a space, each object version is a section, and
  the sections of all copies of a line glue into one.

## What the model leaves open

The model keeps what the properties depend on, and nothing else. Digests,
the names of genesis records and signatures are given by an environment,
about which almost nothing is assumed:

```lean
structure Env (D : Type) where
  hash : Hash D
  keyDigest : Key → D
  nameOf : Genesis D → Nat → Name
  verifies : Sig D → Bool
```

`hash` gives the digest of an inventory and `keyDigest` that of a key;
`nameOf` gives the 16 names of a genesis record; `verifies` says which
signature files verify, that is, were made with their keys. Immutability,
for instance, holds for any digest function at all, even a constant one:
pins stay valid because archives only add versions, not because SHA-512 is
hard to break. Where a theorem needs more, it says so, and asks only that
the two inventories it compares do not collide, never that the digest
function be injective, which no real digest is.

A pin is the pin of the specification, with its hints (`at`), which are not
part of what it names:

```lean
structure Pin (D : Type) where
  line : LineId
  version : Nat
  digest : D
  hints : List ArchiveId := []
```

## Archives change only by adding

A world is a map from locations to archives, and every change of an archive
is one of four steps: a new archive, a new object, a new version, new
signature files.

```lean
inductive Step : World D → World D → Prop
  | newArchive ...
  | create ...
  | append ...
  | witness ...
```

The first theorem is immutability: once a pin resolves to a version at an
archive, no step changes what it resolves to there.

```lean
theorem Step.resolveAt_ok {w w' : World D} (hs : Step w w') {b : ArchiveId} {p : Pin D}
    {v : Version D} (h : resolveAt hash w b p = .ok v) : resolveAt hash w' b p = .ok v
```

The valid steps add the checks of the specification: identity, document
versions, member lists, branch points, and, for a new version of a line,
that the archive's copy of the owner's key log is valid, not frozen by a
fork, and signs the version without an exposed key (section 7.5):

```lean
def LineOk (w : World D) (a : ArchiveId) (ar : Archive D) (l : LineId) (o : Obj D) : Prop :=
  ∃ kl, lookup w a (.line (keyLogLine l.owner)) = some (.live kl) ∧ KeyLogOk E l.owner kl ∧
    ¬ Frozen kl ∧ SignedClean E kl l o o.versions.length ∧
    ((l.owner ∈ ar.owners ∧ ¬ HasEnding kl) ∨ CopyOf w a o)
```

## Key logs and pre-rotation

The key log of an owner is modelled as section 6 writes it: a first
version computed from the genesis record, then versions each signed by the
rotation keys that the version before committed to by their digests. A new
version of a key log needs `nextThreshold` distinct committed rotation keys
of the version before:

```lean
def RotationSigned (X : OwnerName) (o : Obj D) (n : Nat) (pk : Keys D) : Prop :=
  pk.ended = false ∧ pk.nextThreshold ≤
    (rotationSigners E (keyLogLine X) (n + 1) (E.hash (o.inventory (n + 1))) (keyPin E X o n)
      pk o.sigs).length
```

From the rules of section 6.1 the model proves that no key is ever both a
current key and a rotation key, and so that whoever holds only current
keys, the owner's or stolen ones, cannot change the key log:

```lean
theorem current_keys_cannot_extend {X : OwnerName} {o : Obj D} {x : Version D}
    {ss : List (Sig D)} (hne : o.versions ≠ []) {k : Keys D} (hx : x.keys = some k)
    (hcur : ∀ s ∈ o.sigs ++ ss, E.verifies s = true → s.line = keyLogLine X →
      s.version = o.versions.length + 1 →
      ∃ i, ∃ hi : i < o.versions.length, ∃ ki, (o.versions[i]'hi).keys = some ki ∧
        s.key ∈ ki.keys) :
    ¬ KeyLogOk E X (o.append x ss)
```

Nor can they make a fork record, nor prevent an exposure, which depends
only on signatures by rotation keys. A fork, once an archive records it,
freezes the owner there for ever: no later change adds anything to its
lines in that archive.

```lean
theorem Events.fork_freezes_forever {w w' : World D} (hs : Events E w w') {a : ArchiveId}
    {X : OwnerName} {kl : Obj D} (hkl : lookup w a (.line (keyLogLine X)) = some (.live kl))
    (hf : Frozen kl) :
    (∃ kl', lookup w' a (.line (keyLogLine X)) = some (.live kl') ∧ Grows kl kl' ∧
      Frozen kl') ∧
    ∀ l, l.owner = X → l ≠ keyLogLine X → ∀ o', lookup w' a (.line l) = some (.live o') →
      ∃ o, lookup w a (.line l) = some (.live o) ∧ o'.versions = o.versions
```

## Owners sign, places host

A signature counts as the owner's in a world when it is made with a current
key of a version of the owner's key log that the world holds:

```lean
def OwnerKey (w : World D) (X : OwnerName) (s : Sig D) : Prop :=
  s.keyLog.line = keyLogLine X ∧ ∃ b kl, lookup w b (.line (keyLogLine X)) = some (.live kl) ∧
    ∃ v, kl.versionAt s.keyLog.version = some v ∧
      E.hash (kl.inventory s.keyLog.version) = s.keyLog.digest ∧
      ∃ kv, v.keys = some kv ∧ kv.ended = false ∧ s.key ∈ kv.keys
```

In every world built by valid steps and takedowns, the head of every copy
of every line, mirrors included, is signed so, and vouches for every
version before it. Stated as a contrapositive: if nobody holding such a key
signed a version of a line, no archive holds a copy of it.

```lean
theorem forgery_needs_owner_key {w : World D}
    (hs : Events E (fun _ => (none : Option (Archive D))) w) {l : LineId}
    (hno : ∀ s, E.verifies s = true → s.line = l → ¬ OwnerKey E w l.owner s)
    {b : ArchiveId} {o : Obj D} (hl : lookup w b (.line l) = some (.live o))
    (hk : o.kind ≠ .owner) : False
```

Such keys are the owner's, or those that whoever holds its rotation keys
committed in a new version of its key log, which the key log then shows;
the model proves this too, and proves the residual risks of section 15.1
possible, on concrete worlds: an archive that has not seen an exposure
accepts what an up-to-date one refuses, a thief who forks a key log can
make the owner's past contested without forging anything, a retired key
never exposed still signs.

## Copies agree, and pins form no cycles

An owner may write a line in several archives, and its keys, or a thief's,
sign what they sign. Copies of a line agree when the owner signs one
history, and no copy the world holds collides with it:

```lean
def SignsHistory (w : World D) (l : LineId) (g : Option (Genesis D)) (H : List (Version D)) :
    Prop :=
  ∀ s, E.verifies s = true → s.line = l → OwnerKey E w l.owner s →
    s.version ≤ H.length ∧ s.digest = E.hash (histInv l g H s.version)

def NoCollisionWith (w : World D) (l : LineId) (g : Option (Genesis D)) (H : List (Version D)) :
    Prop :=
  ∀ b o, lookup w b (.line l) = some (.live o) → o.kind ≠ .owner →
    ∀ n, n ≤ o.versions.length → NoCollision E (o.inventory n) (histInv l g H n)

theorem Events.copiesAgree {w : World D}
    (hs : Events E (fun _ => (none : Option (Archive D))) w) {l : LineId}
    (h1 : OneHistory E w l) : CopiesAgree w l
```

With it, section 8.5's "pins cannot form cycles" is a theorem about every
world built by valid steps, whatever the digest beyond the pairs compared:

```lean
theorem no_cycles {w : World D}
    (hs : ValidSteps E (fun _ => (none : Option (Archive D))) w)
    (hh : ∀ l, l ≠ keyLogLine l.owner → OneHistory E w l)
    (s : LineId × Nat) : ¬ Chain (PinsTo w) s s
```

## A reader's check

The guarantees above hold for worlds built by the rules. A reader cannot
assume that the archive serving a copy followed them. The last chapter of
the model defines what a reader checks of one copy, with a copy of the
owner's key log, wherever they came from:

```lean
def ReaderAccepts (kl : Obj D) (l : LineId) (o : Obj D) : Prop :=
  o.id = .line l ∧ o.kind ≠ .owner ∧ o.versions ≠ [] ∧ IdentityOk E l o ∧
    KeyLogOk E l.owner kl ∧ ¬ Frozen kl ∧ SignedClean E kl l o o.versions.length
```

and proves, for any objects at all, that what a reader accepts was signed
with a current key of a key-log version that goes back to the owner's
genesis record; and that, if the owner's keys sign one history, every copy
a reader accepts is a prefix of it:

```lean
theorem ReaderAccepts.no_forgery {kl : Obj D} {l : LineId} {o : Obj D}
    (h : ReaderAccepts E kl l o) {g : Option (Genesis D)} {H : List (Version D)}
    (hsign : KeysSignHistory E kl l g H)
    (hcol : NoCollision E (o.inventory o.versions.length) (histInv l g H o.versions.length)) :
    o.versions.length ≤ H.length ∧ o.versions = H.take o.versions.length ∧ o.genesis = g
```

The only assumptions are that a signature verifies only when made with its
key, and that the two inventories compared do not collide. This is the
formal content of section 15.1: "a host or a network therefore cannot forge
a version, nor add one to another owner's line".

## OpenSheaf as a sheaf

The second literate program reads the worlds of the model as sheaves. The
base is the set of named document versions, a line and a document version
number, ordered by deposit; each object version, wherever it is kept, is a
section, giving each document version it holds its content. The main
theorem says that the sections of a world glue into exactly one:

```lean
theorem world_glues {w : World D}
    (hs : Events E (fun _ => (none : Option (Archive D))) w) {H : Histories D} (hh : Honest E H w) :
    ∃ g, Glues (sections w) g ∧ ∀ g', Glues (sections w) g' → g' = g
```

When they do not glue, a fork of a line is the reason: two copies, neither
extending the other, each signed with keys of the owner's key log. Names
keep their content for ever, what a collection pins lies below it in the
order with pins, and verification is local, needing only what lies below.

## Reading and building it

The chapters are published at
[opensheaf.org/opensheaf-lean](https://opensheaf.org/opensheaf-lean/),
with the Lean code inside the prose. To check every proof yourself, install
Lean with [elan](https://github.com/leanprover/elan) and build the
repository:

```sh
git clone https://github.com/opensheaf/opensheaf-lean
cd opensheaf-lean
lake build
```

The model has no dependency beyond Lean's standard library. Questions it
raises about the specification are discussed in the
[issues](https://github.com/opensheaf/opensheaf.github.io/issues) of the
specification; questions about the model itself in those of
[opensheaf-lean](https://github.com/opensheaf/opensheaf-lean/issues).
