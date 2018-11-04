# musicxml-tools

This repository contains transformations on MusicXML scores.

Transformations operate on XML score files and are implemented as XSLT.

Unit tests are provided for each transformation. Tests are written using [XSpec](https://github.com/xspec/xspec) framework.

## Prerequisites

All stylesheets only requires XSLT 1.0.
Some stylesheets requires a few EXSL functions. These have their name suffixed by `Exsl`.

## List of available transformations

### Music transformations

* **Score part selection**:
  * `removeLastPart`: removes the last score part.
  * `removeAllButLastPart`: removes all score parts except the last one.

* **Clef change**:

  * `changeClef`: Replace all clef in the score by a given one
  * `changeClefAllButLastPart`: Replace all clef in all score parts, except the last one.

* **Pitch transposition**:
  * `transpositionsSemitonesExsl`: transpose the whole score by a given number of semitones. This implementation requires EXSL.
  * `transpositionsSemitones`: transpose the whole score by a given number of semitones. This implementation does _not_ requires EXSL.
  * `transpositionsOctaves`: transpose the whole score by a given number of octaves.

### Other transformations

Other transformations aim at alleviating bugs in some MusicXML imports, by removing special cases that are.

* `removeElisions`: replace all elisions, _i.e._, multiple `<syllabic>` elements inside the `<lyric>` for a note, by a single `<syllabic>` element.