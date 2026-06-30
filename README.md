# Lorenzo Da Ponte's Libretti — TEI Editions

TEI P5 digital editions of three *drammi per musica* by **Lorenzo Da Ponte**
(1749–1838), encoded as part of the *Da Ponte Libretti* digital scholarly
edition. This repository is a standalone, citable dataset: the encoded texts
plus the project's TEI encoding model.

## Contents

| Libretto | Year | Siglum | Witness (shelfmark) | Encoder | File |
|---|---|---|---|---|---|
| Cinna | 1798 | LO98 | London 1798, E. Jackson — London, British Library, Gb-Lbl 907.k.5.(1) | Ilaria Scarponi | `tei/cinna_1798.xml` |
| Il Ricco d'un giorno | 1784 | VI84 | Vienna 1784, Kurzbeck — Bologna, Museo Int. e Biblioteca della Musica, Lo.02886 | Alessandro Malavasi | `tei/ricco-dun-giorno_1784.xml` |
| Il Talismano | 1788 | VI88 | Vienna 1788, Imperiale Stamperia de' Sordi e Muti — Vienna, ÖNB, 32542-A | Marta Pacchin | `tei/talismano_1788.xml` |

## Encoding

Encoded in **TEI P5**. The encoding model is in `schema/`:
`libretto.odd` (ODD specification) and `libretto.sch` (Schematron rules).

## License

All content is released under **[CC BY 4.0](LICENSE)** (Creative Commons
Attribution 4.0 International). Please attribute the editors when reusing.

## How to cite

See [`CITATION.cff`](CITATION.cff). A DOI is minted by Zenodo on the first
release — until then, cite by repository URL and version.

## Part of a larger edition

These libretti are part of the **Da Ponte Libretti** digital scholarly
edition: <https://daponte.ficlit.unibo.it>.

## Updating

The TEI and schema are **verbatim snapshots** of the main `da_ponte` project
corpus (the source of truth). To refresh them before a release:

```bash
./update-tei.sh            # reads from ../da_ponte by default
DA_PONTE_SRC=/path/to/da_ponte ./update-tei.sh   # or point it explicitly
```
