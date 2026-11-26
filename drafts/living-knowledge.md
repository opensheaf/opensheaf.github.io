# Living knowledge in a time of abundance

Science and mathematics are entering a period of abundance. Automated
provers, formal proof libraries, large-scale experiments and AI systems now
produce results faster than any community can read them: lemmas,
conjectures, computations, datasets, partial proofs, negative results. Much
of this output is raw. It is correct or nearly so, but scattered, redundant,
written in many idioms, and rarely connected explicitly to what is already
known. A fact that cannot be found, compared or trusted contributes little
to understanding, however true it may be.

Turning such material into knowledge has always been intellectual work:
distillation, unification and normalisation. A survey reorganises a field, a
textbook chooses definitions, a referee checks and situates a claim, a
formal library states a result in a form others can build on. This work is
becoming more important, not less, and more demanding. It is also what makes
knowledge useful to machines. Systems that learn from and reason over the
scientific record depend on clean and aligned signal: texts whose versions
are fixed, whose authorship and provenance are known, and whose relations
to other texts (correction, extension, endorsement, disagreement) are
recorded rather than guessed. Knowledge of this kind is not a static
archive. It is living: revised, reorganised and argued over, while keeping a
precise memory of what was said, by whom and when.

No single institution can or should do this work. Distillation involves
choices (which definitions, which presentation, which results matter and how
they fit together) and different schools, communities and individuals will
reasonably choose differently. Academic freedom here means the freedom to
take the same material and explore it in several ways: to reorganise a
field from another point of view, to continue someone else's work along a
different line, to assemble one's own selection of what deserves attention.
A centralised infrastructure, however well meant, tends to fix one reading
and one set of gatekeepers. A federated and decentralised one lets many
readings coexist.

Freedom without exchange, however, is fragmentation. Science is a communal
and accountable activity: claims must be attributable, versions comparable,
corrections visible, disagreements traceable. Several lines of work on the
same subject must be able to refer to one another precisely, and a reader,
human or machine, must be able to tell which version of a text a statement
concerns and who stands behind it. The infrastructure has to support
divergence and dialogue at the same time.

OpenSheaf is an attempt to provide such an infrastructure at the level of
the format rather than of a platform. Authors and communities keep their
works in archives of plain files that any host can serve. Each version is
fixed and signed by its owners, and a work keeps one name across its
versions, its hosts and changes of keys. Others can continue a work along
lines of their own, under the same name, without overwriting the original.
Journals, overlays and personal selections are collections that point to
precise versions in other people's archives instead of holding copies, and
archives can mirror one another to preserve what they rely on. The aim is
not one more place to publish, but a common, verifiable layer on which many
independent efforts of distillation and curation can build, disagree and
remain in conversation. OpenSheaf is a draft (specification 0.2), developed
in the open at https://opensheaf.org/.
