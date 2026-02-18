#!/usr/bin/env bash
# BacFluxL — output dir cleanup helper

set -euo pipefail

DRYRUN=0

usage() {
  echo "Usage: $(basename "$0") [--dry-run]"
  echo
  echo "  --dry-run   Print what would be removed without deleting files"
  echo "  --help      Show this help message"
}

# Parse simple long options
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)
      DRYRUN=1
      shift
      ;;
    --help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      usage
      exit 1
      ;;
  esac
done

die() { echo "ERROR: $*" >&2; exit 1; }

# Guardrail: ensure correct directory
for d in 01.pre-processing 02.assembly 03.post-processing 04.taxonomy 05.annotation 08.phages; do
  [[ -d "$d" ]] || die "Run this script from the BacFluxL output directory."
done

run_rm() {
  if [[ "$DRYRUN" -eq 1 ]]; then
    echo "DRY-RUN: rm -rf $*"
  else
    rm -rf "$@"
  fi
}

echo "== BacFluxL cleanup starting (dry-run=$DRYRUN) =="

run_rm 01.pre-processing/*.fastq
run_rm 02.assembly/*/[0-4]0-*

run_rm 03.post-processing/completeness_evaluation/*/bins \
       03.post-processing/completeness_evaluation/*/storage \
       03.post-processing/completeness_evaluation/*/*.ms

run_rm 03.post-processing/consensus/*/*.bam* \
       03.post-processing/consensus/*/*.bed \
       03.post-processing/consensus/*/*.hdf

run_rm 03.post-processing/*/*.fai \
       03.post-processing/*/*.mmi

run_rm 03.post-processing/contaminants/*/*.fai \
       03.post-processing/contaminants/*/*.mmi

run_rm 04.taxonomy/*/identify \
       04.taxonomy/*/align

run_rm 05.annotation/antismash/databases/ \
       05.annotation/dbcan/dbcan_db_v5.1.2/

run_rm 08.phages/checkv/*/tmp
run_rm 08.phages/checkv_db
run_rm 08.phages/vs2_db
run_rm 08.phages/virsorter/*/iter-* \
       08.phages/virsorter/*/log

echo "== Cleanup finished =="

