#!/bin/bash


Usage(){
	echo "Usage: `basename $0` ssid1 ssid2"
	echo
	echo "Example: `basename $0` 035A 035B"
	echo 
	exit 1
}

SCRIPT=$(python -c "from os.path import abspath; print(abspath('$0'))")
SCRIPTSDIR=$(dirname $SCRIPT)
if [[ -z "${BIDS_WORK_DIR}" ]]; then
    source "$SCRIPTSDIR/SetupEnv.sh"
fi


[ "$#" -lt 1 ] && Usage

SUBJECTS=$@

## Singularity will be directed to mount BIDS_WORK_DIR:SING_DATA_PATH
SING_DATA_PATH="/data"

## RELATIVE PATHS inside container mount point SING_DATA_PATH/data/
BIDS_DIR="${SING_DATA_PATH}/BIDS"
MRIQC_DIR="${SING_DATA_PATH}/derivatives/mriqc"
WORK_DIR="${SING_DATA_PATH}/derivatives/work"

## log files from singularity/docker jobs
LOG_DIR="${BIDS_WORK_DIR}/logs"
mkdir -p ${LOG_DIR}/

## ensure the VM image exists locally - size of version 0.16.1 is ~2.9GB
MRIQC_IMG="$IMAGE_CONTAINER_PATH/mriqc-0.16.1.simg"
if [ ! -r "$MRIQC_IMG" ]; then
	echo "*** ERROR: mriqc image is not readable...."
	exit 2
	#sudo mkdir -p /opt/SingularityImgs/
	#sudo singularity build ${MRIQC_IMG} docker://poldracklab/mriqc:0.16.1
fi

export TEMPLATEFLOW_HOME=${SING_DATA_PATH}/derivatives/templateflow
export SINGULARITYENV_TEMPLATEFLOW_HOME=${SING_DATA_PATH}/derivatives/templateflow
export SINGULARITYENV_FS_LICENSE=${SING_DATA_PATH}/derivatives/freesurfer_license.txt

DSTR=$(date +%Y%m%d-%H%M)
ST=$SECONDS
cd ${BIDS_WORK_DIR}/
cmd="singularity run --cleanenv -B ${BIDS_WORK_DIR}:${SING_DATA_PATH} ${MRIQC_IMG} ${BIDS_DIR} ${MRIQC_DIR} group --participant-label ${SUBJECTS} -w ${WORK_DIR} -vvvv --no-sub --nprocs ${N_PROCS} --omp-nthreads ${N_THREADS} --mem ${MAX_MEM}"
echo " ++ `date`: running group-level MRIQC, with command:  ${cmd}"
${cmd} > ${LOG_DIR}/${DSTR}_mriqc_group_singularity.log 2>&1
ET=$(($SECONDS - $ST))
echo " ++ `date`: finished mriqc; elapsed-time = $(($ET/60)) min, $(($ET%60)) sec"



exit 0
