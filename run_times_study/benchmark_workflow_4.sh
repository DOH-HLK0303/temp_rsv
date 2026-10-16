#!/usr/bin/env bash

set -u -o pipefail

# Specify a subset of targets
targets=(results/{a,b}/{genome,G,F,F-antibody-escape}/{all-time,6y}/subsampled.fasta)


for i in $(seq 1 3); do

    # Delete prior outputs
    nextstrain build . "${targets[@]}" --delete-all-output --cores 8 > /dev/null 2>&1

    # Run up to the subsampled targets (last step before tree-building)
    start=$(date +%s)
    nextstrain build . "${targets[@]}" --cores 8  --forceall > /dev/null 2>&1 || { echo "run $i failed"; exit 1; }
    end=$(date +%s)

    echo "run $i: $((end - start)) s" | tee -a run_times_study/run_times/run_times_4.txt

    # Print benchmark times
    {
        echo "run $i"
        for f in benchmarks/*.txt; do
            echo "  $f: $(awk 'NR==2 {print $1}' "$f") s"
        done
        echo 
    } | tee -a run_times_study/run_times/benchmarks_4.txt

done