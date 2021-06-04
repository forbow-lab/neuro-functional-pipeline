#!/bin/bash

##---------------------------------------------------------------------------------------
## recommended to run one-subject-at-once with 3-threads,8GB RAM/thread.
## start 5-subjects-in-parallel:
##		@ 3-threads/ea requires CORES=5*3==15, RAM=24*5~=120GB
##
## start 4-subjects-in-parallel:
##		@ 4-threads/ea requires CORES=4*4==16, RAM=36*4~=144GB (!) too-much (!)
##
## On Mars, 12 jobs @5procs,4threads,12GBmaxmem staggered by ~20mins worked well.
##---------------------------------------------------------------------------------------
## find derivatives/freesurfer -type f -name "IsRunning.*" -print
##
## 

Usage(){
	echo "Usage: `basename $0` <ssid>"
	echo
	echo "Example: `basename $0` 005C"
	echo 
	exit 1
}

SCRIPT=$(python -c "from os.path import abspath; print(abspath('$0'))")
SCRIPTSDIR=$(dirname $SCRIPT)
if [[ -z "${BIDS_WORK_DIR}" ]]; then
    source "$SCRIPTSDIR/SetupEnv.sh"
fi

if [ "$HOSTNAME" == "Aoraki.local" ]; then
    N_PROCS=6
    N_THREADS=6
    MAX_MEM=16
elif [ "$HOSTNAME" == "mars" -o "$HOSTNAME" == "jaylah" ]; then
    N_PROCS=5	  ## --nprocs NPROCS:  maximum number of threads across all processes
    N_THREADS=4	## --omp-nthreads OMP_NTHREADS: maximum number of threads per-proces
    MAX_MEM=12	## --mem MEMORY_GB:  upper bound memory limit for fMRIPrep processes
elif [ "$HOSTNAME" == "cedar1.cedar.computecanada.ca" ]; then
    N_PROCS=5	
    N_THREADS=4	
    MAX_MEM=12
fi


RUN_FMRIPREP=yes


FMRIPREP_IMG="$IMAGE_CONTAINER_PATH/fmriprep-20.2.1.simg"
if [ ! -r "$FMRIPREP_IMG" ]; then
	echo "*** ERROR: fmriprep image is not readable...."
	exit 2
	#sudo mkdir -p /opt/singularity_home/
	#sudo singularity build ${FMRIPREP_IMG} docker://nipreps/fmriprep:20.2.1
fi


[ "$#" -lt 1 ] && Usage


for Subj in $@ ; do
	
	S=$(basename $Subj)
	if [ "${#S}" -eq 4 ]; then
		ssid=${S:0:3}
    	sess=${S:3:1}
	elif [ "${#S}" -eq 5 ]; then
		ssid=${S:0:3}
    	sess=${S:4:1}
    	S="${ssid}${sess}"
	else
		echo "*** ERROR: must specify SSID and SESSION as 4-digit or 5-digit code, eg: 074C or 074_C"
		continue
	fi

	SDIR="$BIDS_WORK_DIR/BIDS/sub-${S}"
	if [ ! -d "$SDIR" ]; then
		echo "*** ERROR: could not find subject directory = $SDIR"
		continue
	fi
	
	outDIR=$BIDS_WORK_DIR/derivatives/fmriprep/sub-${S}
	anatOutput=$outDIR/anat/sub-${S}_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
	funcOutput=$outDIR/func/sub-${S}_task-rest_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz
	if [ -r "$anatOutput" -a -r "$funcOutput" ]; then
		echo " * Fmriprep has already been run on subject=$S, see $outDIR/"
		continue
	fi

	if [ "$RUN_FMRIPREP" == "yes" ]; then
		DSTR=$(date +%Y%m%d-%H%M)
		ST=$SECONDS
		cd ${BIDS_WORK_DIR}/
		mkdir -p ./derivatives/fmriprep/ ./derivatives/logs/ 
		export TEMPLATEFLOW_HOME=/data/derivatives/templateflow
		export SINGULARITYENV_TEMPLATEFLOW_HOME=/data/derivatives/templateflow
		export SINGULARITYENV_FS_LICENSE=/data/derivatives/freesurfer_license.txt
		#export SINGULARITY_BINDPATH=/scratch,/opt	#unnecessary
		cmd="singularity run --cleanenv -B ${BIDS_WORK_DIR}:/data ${FMRIPREP_IMG} /data/BIDS /data/derivatives participant -w /data/derivatives/work -vvvv --no-sub --participant_label ${S} --nprocs ${N_PROCS} --omp-nthreads ${N_THREADS} --mem ${MAX_MEM} --resource-monitor --skip_bids_validation "
		echo " ++ `date`: running subject-level MRIQC, with command:  ${cmd}"
		${cmd} > ${BIDS_WORK_DIR}/derivatives/logs/${DSTR}_fmriprep_${S}.log 2>&1
		ET=$(($SECONDS - $ST))
		echo " ++ `date`: finished fmriprep; elapsed-time = $(($ET/60)) min, $(($ET%60)) sec"
	fi
done


exit 0



#### ERRORS ####################################################################################################################
singularity run --cleanenv ~/SingularityImgs/fmriprep-20.2.1.simg -B $(pwd):/data -B $(pwd)/derivatives:/out -B $(pwd)/derivatives/work:/work participant --participant_label 005 --nthreads 16 --omp-nthreads 16

warnings.warn("The ability to pass arguments to BIDSLayout that control "
usage: fmriprep [-h] [--version] [--skip_bids_validation]
                [--participant-label PARTICIPANT_LABEL [PARTICIPANT_LABEL ...]]
                [-t TASK_ID] [--echo-idx ECHO_IDX] [--bids-filter-file FILE]
                [--anat-derivatives PATH] [--bids-database-dir PATH]
                [--nprocs NPROCS] [--omp-nthreads OMP_NTHREADS]
                [--mem MEMORY_GB] [--low-mem] [--use-plugin FILE]
                [--anat-only] [--boilerplate_only] [--md-only-boilerplate]
                [--error-on-aroma-warnings] [-v]
                [--ignore {fieldmaps,slicetiming,sbref,t2w,flair} [{fieldmaps,slicetiming,sbref,t2w,flair} ...]]
                [--longitudinal]
                [--output-spaces [OUTPUT_SPACES [OUTPUT_SPACES ...]]]
                [--bold2t1w-init {register,header}] [--bold2t1w-dof {6,9,12}]
                [--force-bbr] [--force-no-bbr] [--medial-surface-nan]
                [--dummy-scans DUMMY_SCANS] [--random-seed _RANDOM_SEED]
                [--use-aroma]
                [--aroma-melodic-dimensionality AROMA_MELODIC_DIM]
                [--return-all-components]
                [--fd-spike-threshold REGRESSORS_FD_TH]
                [--dvars-spike-threshold REGRESSORS_DVARS_TH]
                [--skull-strip-template SKULL_STRIP_TEMPLATE]
                [--skull-strip-fixed-seed]
                [--skull-strip-t1w {auto,skip,force}] [--fmap-bspline]
                [--fmap-no-demean] [--use-syn-sdc] [--force-syn]
                [--fs-license-file FILE] [--fs-subjects-dir PATH]
                [--no-submm-recon] [--cifti-output [{91k,170k}] |
                --fs-no-reconall] [--output-layout {bids,legacy}]
                [-w WORK_DIR] [--clean-workdir] [--resource-monitor]
                [--reports-only] [--config-file FILE] [--write-graph]
                [--stop-on-first-crash] [--notrack]
                [--debug {compcor,all} [{compcor,all} ...]] [--sloppy]
                bids_dir output_dir {participant}
fmriprep: error: Path does not exist: </shared/uher/FORBOW/rawdata/FORBOW_BIDS:/data>.


$ singularity exec ~/singularity_home/fmriprep-20.2.1.simg fmriprep --help
/usr/local/miniconda/lib/python3.7/site-packages/bids/layout/validation.py:46: UserWarning: The ability to pass arguments to BIDSLayout that control indexing is likely to be removed in future; possibly as early as PyBIDS 0.14. This includes the `config_filename`, `ignore`, `force_index`, and `index_metadata` arguments. The recommended usage pattern is to initialize a new BIDSLayoutIndexer with these arguments, and pass it to the BIDSLayout via the `indexer` argument.
  warnings.warn("The ability to pass arguments to BIDSLayout that control "
usage: fmriprep [-h] [--version] [--skip_bids_validation]
                [--participant-label PARTICIPANT_LABEL [PARTICIPANT_LABEL ...]]
                [-t TASK_ID] [--echo-idx ECHO_IDX] [--bids-filter-file FILE]
                [--anat-derivatives PATH] [--bids-database-dir PATH]
                [--nprocs NPROCS] [--omp-nthreads OMP_NTHREADS]
                [--mem MEMORY_GB] [--low-mem] [--use-plugin FILE]
                [--anat-only] [--boilerplate_only] [--md-only-boilerplate]
                [--error-on-aroma-warnings] [-v]
                [--ignore {fieldmaps,slicetiming,sbref,t2w,flair} [{fieldmaps,slicetiming,sbref,t2w,flair} ...]]
                [--longitudinal]
                [--output-spaces [OUTPUT_SPACES [OUTPUT_SPACES ...]]]
                [--bold2t1w-init {register,header}] [--bold2t1w-dof {6,9,12}]
                [--force-bbr] [--force-no-bbr] [--medial-surface-nan]
                [--dummy-scans DUMMY_SCANS] [--random-seed _RANDOM_SEED]
                [--use-aroma]
                [--aroma-melodic-dimensionality AROMA_MELODIC_DIM]
                [--return-all-components]
                [--fd-spike-threshold REGRESSORS_FD_TH]
                [--dvars-spike-threshold REGRESSORS_DVARS_TH]
                [--skull-strip-template SKULL_STRIP_TEMPLATE]
                [--skull-strip-fixed-seed]
                [--skull-strip-t1w {auto,skip,force}] [--fmap-bspline]
                [--fmap-no-demean] [--use-syn-sdc] [--force-syn]
                [--fs-license-file FILE] [--fs-subjects-dir PATH]
                [--no-submm-recon] [--cifti-output [{91k,170k}] |
                --fs-no-reconall] [--output-layout {bids,legacy}]
                [-w WORK_DIR] [--clean-workdir] [--resource-monitor]
                [--reports-only] [--config-file FILE] [--write-graph]
                [--stop-on-first-crash] [--notrack]
                [--debug {compcor,all} [{compcor,all} ...]] [--sloppy]
                bids_dir output_dir {participant}

fMRIPrep: fMRI PREProcessing workflows v20.2.1

positional arguments:
  bids_dir              the root folder of a BIDS valid dataset (sub-XXXXX
                        folders should be found at the top level in this
                        folder).
  output_dir            the output path for the outcomes of preprocessing and
                        visual reports
  {participant}         processing stage to be run, only "participant" in the
                        case of fMRIPrep (see BIDS-Apps specification).

optional arguments:
  -h, --help            show this help message and exit
  --version             show program's version number and exit

Options for filtering BIDS queries:
  --skip_bids_validation, --skip-bids-validation
                        assume the input dataset is BIDS compliant and skip
                        the validation (default: False)
  --participant-label PARTICIPANT_LABEL [PARTICIPANT_LABEL ...], --participant_label PARTICIPANT_LABEL [PARTICIPANT_LABEL ...]
                        a space delimited list of participant identifiers or a
                        single identifier (the sub- prefix can be removed)
                        (default: None)
  -t TASK_ID, --task-id TASK_ID
                        select a specific task to be processed (default: None)
  --echo-idx ECHO_IDX   select a specific echo to be processed in a multiecho
                        series (default: None)
  --bids-filter-file FILE
                        a JSON file describing custom BIDS input filters using
                        PyBIDS. For further details, please check out https://
                        fmriprep.readthedocs.io/en/20.2.1/faq.html#how-do-I-
                        select-only-certain-files-to-be-input-to-fMRIPrep
                        (default: None)
  --anat-derivatives PATH
                        Reuse the anatomical derivatives from another fMRIPrep
                        run or calculated with an alternative processing tool
                        (NOT RECOMMENDED). (default: None)
  --bids-database-dir PATH
                        Path to an existing PyBIDS database folder, for faster
                        indexing (especially useful for large datasets).
                        (default: None)

Options to handle performance:
  --nprocs NPROCS, --nthreads NPROCS, --n_cpus NPROCS, --n-cpus NPROCS
                        maximum number of threads across all processes
                        (default: None)
  --omp-nthreads OMP_NTHREADS
                        maximum number of threads per-process (default: None)
  --mem MEMORY_GB, --mem_mb MEMORY_GB, --mem-mb MEMORY_GB
                        upper bound memory limit for fMRIPrep processes
                        (default: None)
  --low-mem             attempt to reduce memory usage (will increase disk
                        usage in working directory) (default: False)
  --use-plugin FILE, --nipype-plugin-file FILE
                        nipype plugin configuration file (default: None)
  --anat-only           run anatomical workflows only (default: False)
  --boilerplate_only    generate boilerplate only (default: False)
  --md-only-boilerplate
                        skip generation of HTML and LaTeX formatted citation
                        with pandoc (default: False)
  --error-on-aroma-warnings
                        Raise an error if ICA_AROMA does not produce sensible
                        output (e.g., if all the components are classified as
                        signal or noise) (default: False)
  -v, --verbose         increases log verbosity for each occurence, debug
                        level is -vvv (default: 0)

Workflow configuration:
  --ignore {fieldmaps,slicetiming,sbref,t2w,flair} [{fieldmaps,slicetiming,sbref,t2w,flair} ...]
                        ignore selected aspects of the input dataset to
                        disable corresponding parts of the workflow (a space
                        delimited list) (default: [])
  --longitudinal        treat dataset as longitudinal - may increase runtime
                        (default: False)
  --output-spaces [OUTPUT_SPACES [OUTPUT_SPACES ...]]
                        Standard and non-standard spaces to resample
                        anatomical and functional images to. Standard spaces
                        may be specified by the form
                        ``<SPACE>[:cohort-<label>][:res-<resolution>][...]``,
                        where ``<SPACE>`` is a keyword designating a spatial
                        reference, and may be followed by optional, colon-
                        separated parameters. Non-standard spaces imply
                        specific orientations and sampling grids. Important to
                        note, the ``res-*`` modifier does not define the
                        resolution used for the spatial normalization. To
                        generate no BOLD outputs, use this option without
                        specifying any spatial references. For further
                        details, please check out
                        https://fmriprep.readthedocs.io/en/20.2.1/spaces.html
                        (default: None)
  --bold2t1w-init {register,header}
                        Either "register" (the default) to initialize volumes
                        at center or "header" to use the header information
                        when coregistering BOLD to T1w images. (default:
                        register)
  --bold2t1w-dof {6,9,12}
                        Degrees of freedom when registering BOLD to T1w
                        images. 6 degrees (rotation and translation) are used
                        by default. (default: 6)
  --force-bbr           Always use boundary-based registration (no goodness-
                        of-fit checks) (default: None)
  --force-no-bbr        Do not use boundary-based registration (no goodness-
                        of-fit checks) (default: None)
  --medial-surface-nan  Replace medial wall values with NaNs on functional
                        GIFTI files. Only performed for GIFTI files mapped to
                        a freesurfer subject (fsaverage or fsnative).
                        (default: False)
  --dummy-scans DUMMY_SCANS
                        Number of non steady state volumes. (default: None)
  --random-seed _RANDOM_SEED
                        Initialize the random seed for the workflow (default:
                        None)

Specific options for running ICA_AROMA:
  --use-aroma           add ICA_AROMA to your preprocessing stream (default:
                        False)
  --aroma-melodic-dimensionality AROMA_MELODIC_DIM
                        Exact or maximum number of MELODIC components to
                        estimate (positive = exact, negative = maximum)
                        (default: -200)

Specific options for estimating confounds:
  --return-all-components
                        Include all components estimated in CompCor
                        decomposition in the confounds file instead of only
                        the components sufficient to explain 50 percent of
                        BOLD variance in each CompCor mask (default: False)
  --fd-spike-threshold REGRESSORS_FD_TH
                        Threshold for flagging a frame as an outlier on the
                        basis of framewise displacement (default: 0.5)
  --dvars-spike-threshold REGRESSORS_DVARS_TH
                        Threshold for flagging a frame as an outlier on the
                        basis of standardised DVARS (default: 1.5)

Specific options for ANTs registrations:
  --skull-strip-template SKULL_STRIP_TEMPLATE
                        select a template for skull-stripping with
                        antsBrainExtraction (default: OASIS30ANTs)
  --skull-strip-fixed-seed
                        do not use a random seed for skull-stripping - will
                        ensure run-to-run replicability when used with --omp-
                        nthreads 1 and matching --random-seed <int> (default:
                        False)
  --skull-strip-t1w {auto,skip,force}
                        determiner for T1-weighted skull stripping ('force'
                        ensures skull stripping, 'skip' ignores skull
                        stripping, and 'auto' applies brain extraction based
                        on the outcome of a heuristic to check whether the
                        brain is already masked). (default: force)

Specific options for handling fieldmaps:
  --fmap-bspline        fit a B-Spline field using least-squares
                        (experimental) (default: False)
  --fmap-no-demean      do not remove median (within mask) from fieldmap
                        (default: True)

Specific options for SyN distortion correction:
  --use-syn-sdc         EXPERIMENTAL: Use fieldmap-free distortion correction
                        (default: False)
  --force-syn           EXPERIMENTAL/TEMPORARY: Use SyN correction in addition
                        to fieldmap correction, if available (default: False)

Specific options for FreeSurfer preprocessing:
  --fs-license-file FILE
                        Path to FreeSurfer license key file. Get it (for free)
                        by registering at
                        https://surfer.nmr.mgh.harvard.edu/registration.html
                        (default: None)
  --fs-subjects-dir PATH
                        Path to existing FreeSurfer subjects directory to
                        reuse. (default: OUTPUT_DIR/freesurfer) (default:
                        None)

Surface preprocessing options:
  --no-submm-recon      disable sub-millimeter (hires) reconstruction
                        (default: True)
  --cifti-output [{91k,170k}]
                        output preprocessed BOLD as a CIFTI dense timeseries.
                        Optionally, the number of grayordinate can be
                        specified (default is 91k, which equates to 2mm
                        resolution) (default: False)
  --fs-no-reconall      disable FreeSurfer surface preprocessing. (default:
                        True)

Other options:
  --output-layout {bids,legacy}
                        Organization of outputs. legacy (default) creates
                        derivative datasets as subdirectories of outputs. bids
                        places fMRIPrep derivatives directly in the output
                        directory, and defaults to placing FreeSurfer
                        derivatives in <output-dir>/sourcedata/freesurfer.
                        (default: legacy)
  -w WORK_DIR, --work-dir WORK_DIR
                        path where intermediate results should be stored
                        (default: /home/good/work)
  --clean-workdir       Clears working directory of contents. Use of this flag
                        is notrecommended when running concurrent processes of
                        fMRIPrep. (default: False)
  --resource-monitor    enable Nipype's resource monitoring to keep track of
                        memory and CPU usage (default: False)
  --reports-only        only generate reports, don't run workflows. This will
                        only rerun report aggregation, not reportlet
                        generation for specific nodes. (default: False)
  --config-file FILE    Use pre-generated configuration file. Values in file
                        will be overridden by command-line arguments.
                        (default: None)
  --write-graph         Write workflow graph. (default: False)
  --stop-on-first-crash
                        Force stopping on first crash, even if a work
                        directory was specified. (default: False)
  --notrack             Opt-out of sending tracking information of this run to
                        the FMRIPREP developers. This information helps to
                        improve FMRIPREP and provides an indicator of real
                        world usage crucial for obtaining funding. (default:
                        False)
  --debug {compcor,all} [{compcor,all} ...]
                        Debug mode(s) to enable. 'all' is alias for all
                        available modes. (default: None)
  --sloppy              Use low-quality tools for speed - TESTING ONLY
                        (default: False)
                        
