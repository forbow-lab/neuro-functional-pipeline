# Neuro functional pipeline

Repository documenting [fMRIPrep](https://fmriprep.org/en/stable/) usage within containerized environments such as [Singularity](https://sylabs.io/singularity/)


1) Create a BIDS dataset for all subjects/sessions within a given project. Ideally, all subjects matching sequences with matching parameters. Each anat sequence should be defaced, and notes to this effect should exist in the readme.txt at project level.
`./scripts/0_setup_bids.sh`

2) Run mriqc on each subject, when done, run mriqc group.
` ./scripts/1_run_mriqc_session.sh 001C`

Singularity basic commands:
 shell
 exec 
 run
