#!/bin/bash

# ============================================================
# Script: 00_run_repeatmodeler_repeatmasker.sh
# Purpose: Build a de novo repeat library with RepeatModeler,
#          combine it with the LTR_retriever library, and run
#          RepeatMasker on the Castanea sativa reference genome.
# Author: Alejandro Arévalo Sánchez
# ============================================================

set -euo pipefail

# -----------------------------
# Input files
# -----------------------------

GENOME="data/castano_genoma_filtrado.fasta"
LTR_LIB="data/castano_genoma_filtrado.fasta.LTRlib.fa"

# -----------------------------
# Output directories
# -----------------------------

OUTDIR="results/repeat_annotation"
mkdir -p "$OUTDIR"

# -----------------------------
# RepeatModeler database
# -----------------------------

BuildDatabase \
  -name "$OUTDIR/Castanea_DB" \
  "$GENOME"

# -----------------------------
# Run RepeatModeler
# -----------------------------

RepeatModeler \
  -database "$OUTDIR/Castanea_DB" \
  -pa 12

# -----------------------------
# Output tracking and validation
# -----------------------------

RM_DIR=$(find . -maxdepth 1 -type d -name 'RM_*' -printf '%T@ %p\n' \
          | sort -n | tail -1 | cut -d' ' -f2)

if [[ -z "$RM_DIR" || ! -f "$RM_DIR/consensi.fa.classified" ]]; then
    echo "ERROR: no se encontró consensi.fa.classified en ningún RM_*"
    exit 1
fi

REPEATMODELER_LIB="$OUTDIR/consensi.fa.classified"
COMBINED_LIB="$OUTDIR/Castanea_TE_library.fa"

# -----------------------------
# Combine RepeatModeler and LTR_retriever libraries
# -----------------------------

cp "$RM_DIR/consensi.fa.classified" "$REPEATMODELER_LIB"
cat "$REPEATMODELER_LIB" "$LTR_LIB" > "$COMBINED_LIB"

# -----------------------------
# Run RepeatMasker
# -----------------------------

RepeatMasker \
  -pa 12 \
  -lib "$COMBINED_LIB" \
  -gff \
  -xsmall \
  -dir "$OUTDIR" \
  "$GENOME"
