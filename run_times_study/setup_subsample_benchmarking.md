
Note: for reasons I don't understand, sometimes the run fails and is fixed by moving up a directory and then back into the directory

Run this from the root directory

# compare just alignment times (without pre-filtering data) - from any branch

1. Pull the full subtype a dataset by running just the merge_inputs.smk workflow

```
nextstrain build . "results/a/sequences.fasta"
```

And pull the nextclade dataset
```
nextstrain build . "results/nextclade_rsv-a.zip"
```

2. Change VS code end-of-line default to LF

3. run:
```
nextstrain shell .
bash run_times_study/compare_align_times.sh
```

# pre-filter then align before subsample

1. Move to the branch `test-align-before-subsample` and copy the `folder run_times_study` to the root directory

2. Set configfile to use example data by DELETING existing input lines & replacing with: 
```
inputs:
  - name: example-data
    metadata: example_data/{a_or_b}/metadata.tsv
    sequences: example_data/{a_or_b}/sequences.fasta
```

3. run benchmark workflow shell scripts 1-3:
```
 bash run_times_study/benchmark_workflow_<1-3>.sh
```

4. Pull the full dataset by running just the merge_inputs.smk workflow

5. Generate subsamples of the primary data with

```
nextstrain shell .
seqkit sample -n 5000 results/a/sequences.fasta > data_subsample/a/sequences.fasta
seqkit sample -n 5000 results/b/sequences.fasta > data_subsample/b/sequences.fasta

grep '^>' data_subsample/a/sequences.fasta | sed 's/^>//' | cut -d' ' -f1 > data_subsample/a/ids.txt
grep '^>' data_subsample/b/sequences.fasta | sed 's/^>//' | cut -d' ' -f1 > data_subsample/b/ids.txt

awk -F'\t' 'NR==FNR {ids[$1]; next} FNR==1 || ($1 in ids)' data_subsample/a/ids.txt results/a/metadata.tsv > data_subsample/a/metadata.tsv
awk -F'\t' 'NR==FNR {ids[$1]; next} FNR==1 || ($1 in ids)' data_subsample/b/ids.txt results/b/metadata.tsv > data_subsample/b/metadata.tsv

```

6. Set configfile to use subsampled data by DELETING existing input lines & replacing with: 
```
inputs:
  - name: subsampled-data
    metadata: data_subsample/{a_or_b}/metadata.tsv
    sequences: data_subsample/{a_or_b}/sequences.fasta
```

7. run benchmark workflow shell scripts 4-6:
```
 bash run_times_study/benchmark_workflow_<4-6>.sh
```

8. Copy the run times into `"C:\Users\hlk0303\OneDrive - Washington State Executive Branch Agencies\Investigations\rsv_align_subsample_run_times\rsv_run_times_for_workflow_reorg.xlsx"`


