# Neuro functional pipeline

Repository documenting [fMRIPrep](https://fmriprep.org/en/stable/) usage within containerized environments such as [Singularity](https://sylabs.io/singularity/)


1) Create a BIDS dataset for all subjects/sessions within a given project. Ideally, all subjects matching sequences with matching parameters. Each anat sequence should be defaced, and notes to this effect should exist in the readme.txt at project level.
[`./scripts/0_setup_bids.sh`](https://github.com/forbow-lab/neuro-functional-pipeline/blob/main/scripts/0_setup_bids.sh)

2) Run mriqc on each subject. Once all subjects are completed, run mriqc group (without SSIDS, it runs on the whole set automatically).
` ./scripts/1_run_mriqc_session.sh 001C`
`./scripts/2_run_mriqc_group.sh`

3) Run fmriprep on each subject (~10hrs with 5xCPU,4xCores,12GB mem)
`./scripts/3_run_fmriprep_session.sh 001C`

---


Singularity basic commands:
 shell
 exec 
 run

---

# Running jobs on Compute Canada

1) currently re-writing code to be a single master script that will:
    a. upload a single-dataset raw-bids (given project, site, ssid)
    b. run/monitor/re-run fmriprep with doubled cpu/ram/time options if failed due to time-out
    c. download fmriprep results