#!/bin/bash

## ERROR: freesurfer already ran on this dataset:
## find derivatives/freesurfer -type f -name "IsRunning.*" -print
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

RUN_MRIQC=yes

## ensure MRIQC image is read/exec
MRIQC_IMG="$IMAGE_CONTAINER_PATH/mriqc-0.16.1.simg"
if [ ! -r "$MRIQC_IMG" ]; then
	echo "*** ERROR: mriqc image is not readable...."
	exit 2
	#sudo mkdir -p $IMAGE_CONTAINER_PATH/
	#sudo singularity build ${MRIQC_IMG} docker://nipreps/mriqc:20.2.1
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
    if [ "$RUN_MRIQC" == "yes" ]; then
        DSTR=$(date +%Y%m%d-%H%M)
        ST=$SECONDS
        cd ${BIDS_WORK_DIR}/
        mkdir -p ./derivatives/mriqc/ ./derivatives/logs/ 
        export TEMPLATEFLOW_HOME=/data/derivatives/templateflow
        export SINGULARITYENV_TEMPLATEFLOW_HOME=/data/derivatives/templateflow
        export SINGULARITYENV_FS_LICENSE=/data/derivatives/freesurfer_license.txt
        #export SINGULARITY_BINDPATH=/scratch,/opt	#unnecessary
        cmd="singularity run --cleanenv -B ${BIDS_WORK_DIR}:/data ${MRIQC_IMG} /data/BIDS_raw /data/derivatives/mriqc participant -w /data/derivatives/work -vvvv --no-sub --participant_label ${S} --nprocs ${N_PROCS} --omp-nthreads ${N_THREADS} --mem ${MAX_MEM} --profile --write-graph "
        echo " ++ `date`: running subject-level MRIQC, with command:  ${cmd}"
        ${cmd} > ${BIDS_WORK_DIR}/derivatives/logs/${DSTR}_mriqc_${S}.log 2>&1
        ET=$(($SECONDS - $ST))
        echo " ++ `date`: finished mriqc; elapsed-time = $(($ET/60)) min, $(($ET%60)) sec"
    fi
done


exit 0


################################################################################################################
uher@jaylah:/shared/uher/FORBOW/BIDS_WORK$ singularity shell /opt/SingularityImgs/mriqc-0.16.1.simg mriqc
Singularity> mriqc --help
usage: mriqc [-h] [--version] [-v]
             [--participant-label PARTICIPANT_LABEL [PARTICIPANT_LABEL ...]]
             [--session-id [SESSION_ID [SESSION_ID ...]]]
             [--run-id [RUN_ID [RUN_ID ...]]]
             [--task-id [TASK_ID [TASK_ID ...]]]
             [-m [MODALITIES [MODALITIES ...]]] [--dsname DSNAME]
             [--nprocs NPROCS] [--omp-nthreads OMP_NTHREADS] [--mem MEMORY_GB]
             [--testing] [-f] [--pdb] [-w WORK_DIR] [--verbose-reports]
             [--write-graph] [--dry-run] [--profile] [--use-plugin USE_PLUGIN]
             [--no-sub] [--email EMAIL] [--webapi-url WEBAPI_URL]
             [--webapi-port WEBAPI_PORT] [--upload-strict] [--ants-float]
             [--ants-settings ANTS_SETTINGS] [--ica] [--fft-spikes-detector]
             [--fd_thres FD_THRES] [--deoblique] [--despike]
             [--start-idx START_IDX] [--stop-idx STOP_IDX]
             [--correct-slice-timing]
             bids_dir output_dir {participant,group} [{participant,group} ...]

MRIQC 0.16.1 Automated Quality Control and visual reports for Quality
Assesment of structural (T1w, T2w) and functional MRI of the brain. IMPORTANT:
Anonymized quality metrics (IQMs) will be submitted to MRIQC's metrics
repository. Submission of IQMs can be disabled using the ``--no-sub``
argument. Please visit https://mriqc.readthedocs.io/en/latest/dsa.html to
revise MRIQC's Data Sharing Agreement.

positional arguments:
  bids_dir              the root folder of a BIDS valid dataset (sub-XXXXX
                        folders should be found at the top level in this
                        folder).
  output_dir            The directory where the output files should be stored.
                        If you are running group level analysis this folder
                        should be prepopulated with the results of
                        theparticipant level analysis.
  {participant,group}   Level of the analysis that will be performed. Multiple
                        participant level analyses can be run independently
                        (in parallel) using the same output_dir.

optional arguments:
  -h, --help            show this help message and exit
  --version             show program's version number and exit
  -v, --verbose         increases log verbosity for each occurrence, debug
                        level is -vvv (default: 0)

Options for filtering BIDS queries:
  --participant-label PARTICIPANT_LABEL [PARTICIPANT_LABEL ...], --participant_label PARTICIPANT_LABEL [PARTICIPANT_LABEL ...]
                        a space delimited list of participant identifiers or a
                        single identifier (the sub- prefix can be removed)
                        (default: None)
  --session-id [SESSION_ID [SESSION_ID ...]]
                        filter input dataset by session id (default: None)
  --run-id [RUN_ID [RUN_ID ...]]
                        filter input dataset by run id (only integer run ids
                        are valid) (default: None)
  --task-id [TASK_ID [TASK_ID ...]]
                        filter input dataset by task id (default: None)
  -m [MODALITIES [MODALITIES ...]], --modalities [MODALITIES [MODALITIES ...]]
                        filter input dataset by MRI type (default: None)
  --dsname DSNAME       a dataset name (default: None)

Options to handle performance:
  --nprocs NPROCS, --n_procs NPROCS, --n_cpus NPROCS, -n-cpus NPROCS
                        maximum number of threads across all processes
                        (default: None)
  --omp-nthreads OMP_NTHREADS, --ants-nthreads OMP_NTHREADS
                        maximum number of threads per-process (default: None)
  --mem MEMORY_GB, --mem_gb MEMORY_GB, --mem-gb MEMORY_GB
                        upper bound memory limit for MRIQC processes (default:
                        None)
  --testing             use testing settings for a minimal footprint (default:
                        False)
  -f, --float32         Cast the input data to float32 if it's represented in
                        higher precision (saves space and improves perfomance)
                        (default: True)
  --pdb                 open Python debugger (pdb) on exceptions (default:
                        False)

Instrumental options:
  -w WORK_DIR, --work-dir WORK_DIR
                        path where intermediate results should be stored
                        (default: /home/uher/work)
  --verbose-reports
  --write-graph         Write workflow graph. (default: False)
  --dry-run             Do not run the workflow. (default: False)
  --profile             hook up the resource profiler callback to nipype
                        (default: False)
  --use-plugin USE_PLUGIN
                        nipype plugin configuration file (default: None)
  --no-sub              Turn off submission of anonymized quality metrics to
                        MRIQC's metrics repository. (default: False)
  --email EMAIL         Email address to include with quality metric
                        submission. (default: )
  --webapi-url WEBAPI_URL
                        IP address where the MRIQC WebAPI is listening
                        (default: None)
  --webapi-port WEBAPI_PORT
                        port where the MRIQC WebAPI is listening (default:
                        None)
  --upload-strict       upload will fail if if upload is strict (default:
                        False)

Specific settings for ANTs:
  --ants-float          use float number precision on ANTs computations
                        (default: False)
  --ants-settings ANTS_SETTINGS
                        path to JSON file with settings for ANTS (default:
                        None)

Functional MRI workflow configuration:
  --ica                 Run ICA on the raw data and include the components in
                        the individual reports (slow but potentially very
                        insightful) (default: False)
  --fft-spikes-detector
                        Turn on FFT based spike detector (slow). (default:
                        False)
  --fd_thres FD_THRES   Threshold on Framewise Displacement estimates to
                        detect outliers. (default: 0.2)
  --deoblique           Deoblique the functional scans during head motion
                        correction preprocessing (default: False)
  --despike             Despike the functional scans during head motion
                        correction preprocessing (default: False)
  --start-idx START_IDX
                        Initial volume in functional timeseries that should be
                        considered for preprocessing (default: None)
  --stop-idx STOP_IDX   Final volume in functional timeseries that should be
                        considered for preprocessing (default: None)
  --correct-slice-timing
                        Perform slice timing correction (default: False)
Singularity> 
