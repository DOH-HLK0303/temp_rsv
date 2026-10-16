set -u -o pipefail

mkdir -p data_subsample2/a temp run_times_study/align_times

for i in 40000 40000 40000 80000 80000 80000; do

    seqkit sample -2 -n "$i" results/a/sequences.fasta > data_subsample2/a/sequences.fasta

    start=$(date +%s)
    nextclade3 run -j 8 \
        data_subsample2/a/sequences.fasta \
        -D "results/nextclade_rsv-a.zip" \
        --output-fasta temp/aligned.fasta \
        || { echo "sequences $i failed"; exit 1; }
    end=$(date +%s)

    echo "sequences $i: $((end - start)) s" | tee -a run_times_study/align_times/align_times.txt

    rm -f data_subsample2/a/sequences.fasta temp/aligned.fasta

done
