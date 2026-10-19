#!/usr/bin/env bash
set -euo pipefail

person_id="${1:?Usage: bash extract_unmapped.sh PERSON_ID}"
[[ "$person_id" =~ ^[0-9]+$ ]] || { echo "Invalid person_id"; exit 1; }

bam_dir="/home/jupyter/workspace/Data from All of Us Controlled Tier /vwb-aou-datasets-controlled-v9/pooled/multiomics/v9_base/rnaseq/bam"
bam="$bam_dir/${person_id}.Aligned.sortedByCoord.out.md.bam"

[[ -r "$bam" ]] || { echo "BAM not found: $bam"; exit 1; }

out="data/$person_id"
mkdir -p data
mkdir "$out"  # Stops if this folder already exists.
mkdir -p "singletons/$person_id"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

samtools view -u -f 4 -F 0x900 "$bam" \
  | samtools collate -u -O - "$tmp/collate" \
  | samtools fastq -n \
      -1 "$out/${person_id}_R1.fastq.gz" \
      -2 "$out/${person_id}_R2.fastq.gz" \
      -s "singletons/$person_id/singletons.fastq.gz" \
      -0 "singletons/$person_id/other.fastq.gz" -

echo "Done: $out"