
Note: for reasons I don't understand, sometimes the run fails and is fixed by moving up a directory and then back into the directory

Run this from the root directory

Instructions are included to generate all files from scratch, but these are also stored locally here: `Investigations\rsv_align_subsample_run_times`

# compare just alignment times (without pre-filtering data)

## Run the above from the test-run-times branch
- 

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

# Test run times under different workflow configurations

## Run the above seperately from these 5 branches:
- test-run-times: no edits to workflow except test data is used & subsample sizes are decreased
- test-align-before-subsample: Workflow is edited to move subsampling after alignment step. The initial subsampling step is left but edited to only do QC, length, & date filtering (& split by build & resolution). Test data is used & subsample sizes are decreased.
- test-align-before-subsample-V2: Same as above but the initial subsampling step does not seperate per build & resolution until the final subsampling step
- test-align-before-subsample-no-pre-filter: Workflow is edited to move subsampling after alignment step. No initial filtering is done, although this step is still used to stratify by build. Test data is used & subsample sizes are decreased.
- test-align-before-subsample-no-pre-filter-V2: Same as above but the initial subsampling step is entirely removed, so the workflow is not seperated per build & resolution until the final subsampling step

1a. Edit the config file (this should already be done if you're on this branch). Reduce all `max_sequences` values to ~ 1/7 (this is to keep the same relative sampling % after we decrease the starting sample size from 70L to 10K):
- 3,000 -> 430
- 300 -> 43
- 2,000 -> 290
- 200 -> 29

1. Copy the folder `C:\Users\hlk0303\OneDrive - Washington State Executive Branch Agencies\Investigations\rsv_align_subsample_run_times\scripts\run_times_study` to the root directory

2. Make sure config/config.yaml `inputs` is set to the default (pulling data from the nextstrain S3 folders). Pull the full dataset by running just the merge_inputs.smk workflow
```
nextstrain build . "results/a/sequences.fasta" "results/a/metadata.tsv" --forceall
nextstrain build . "results/b/sequences.fasta" "results/b/metadata.tsv" --forceall
```

And pull the nextclade dataset
```
nextstrain build . "results/nextclade_rsv-a.zip"
nextstrain build . "results/nextclade_rsv-b.zip"
```

3. Generate subsamples of the primary data with

```
nextstrain shell .
seqkit sample -n 5000 results/a/sequences.fasta > data_subsample/a/sequences.fasta
seqkit sample -n 5000 results/b/sequences.fasta > data_subsample/b/sequences.fasta

grep '^>' data_subsample/a/sequences.fasta | sed 's/^>//' | cut -d' ' -f1 > data_subsample/a/ids.txt
grep '^>' data_subsample/b/sequences.fasta | sed 's/^>//' | cut -d' ' -f1 > data_subsample/b/ids.txt

awk -F'\t' 'NR==FNR {ids[$1]; next} FNR==1 || ($1 in ids)' data_subsample/a/ids.txt results/a/metadata.tsv > data_subsample/a/metadata.tsv
awk -F'\t' 'NR==FNR {ids[$1]; next} FNR==1 || ($1 in ids)' data_subsample/b/ids.txt results/b/metadata.tsv > data_subsample/b/metadata.tsv

exit
```

4. Set configfile to use subsampled data by DELETING existing input lines & replacing with: 
```
inputs:
  - name: subsampled-data
    metadata: data_subsample/{a_or_b}/metadata.tsv
    sequences: data_subsample/{a_or_b}/sequences.fasta
```

5. run benchmark workflow shell scripts 4-6:
```
 bash run_times_study/benchmark_workflow_<4-6>.sh
```

6. Repeat the above analyses with the sample data. Set configfile to use example data by DELETING existing input lines & replacing with: 
```
inputs:
  - name: example-data
    metadata: example_data/{a_or_b}/metadata.tsv
    sequences: example_data/{a_or_b}/sequences.fasta
```

7. run benchmark workflow shell scripts 1-3:
```
 bash run_times_study/benchmark_workflow_<1-3>.sh
```

8. Copy the run times into `C:\Users\hlk0303\OneDrive - Washington State Executive Branch Agencies\Investigations\rsv_align_subsample_run_times\rsv_run_times_for_workflow_reorg.xlsx`


# Generate a DAG
generate a dag for the A subtype, F and genome builds, 6Y & all-time resolutions
```
nextstrain build . \
"results/a/genome/all-time/subsampled.fasta" \
"results/a/genome/6y/subsampled.fasta" \
"results/a/F/all-time/subsampled.fasta" \
"results/a/F/6y/subsampled.fasta" \
--forceall \
--dag | dot -Tsvg > dag.svg
```