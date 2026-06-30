#!/usr/bin/env bash
# Refresh the TEI sources and encoding schema from the main da_ponte corpus.
# Verbatim copies — the main corpus is the source of truth. Run before a release.
set -euo pipefail

SRC="${DA_PONTE_SRC:-../da_ponte}"
HERE="$(cd "$(dirname "$0")" && pwd)"
mkdir -p "$HERE/tei" "$HERE/schema"

copy() {  # $1 = path under $SRC, $2 = path under $HERE
  install -m 0644 "$SRC/$1" "$HERE/$2"
  echo "  $1 -> $2"
}

echo "Copying TEI from $SRC ..."
copy "corpus/cinna_daponte/cinna.xml"            "tei/cinna_1798.xml"
copy "corpus/ricco_daponte/ricco_dun_giorno.xml" "tei/ricco-dun-giorno_1784.xml"
copy "corpus/talismano_daponte/daponte-1788.xml" "tei/talismano_1788.xml"

echo "Copying schema ..."
copy "schemas/libretto.odd" "schema/libretto.odd"
copy "schemas/libretto.sch" "schema/libretto.sch"

echo "Done."
