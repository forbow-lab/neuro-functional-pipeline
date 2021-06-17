#!/bin/bash

Usage(){
	echo "Usage: `basename $0`"
	echo
	echo "Example: `basename $0`"
	echo 
	exit 1
}

SCRIPT=$(python -c "from os.path import abspath; print(abspath('$0'))")
SCRIPTSDIR=$(dirname $SCRIPT)
if [[ -z "${BIDS_WORK_DIR}" ]]; then
    source "$SCRIPTSDIR/SetupEnv.sh"
fi

RUN_FMRIDENOISE=yes


FMRIDENOISE_IMG="/opt/SingularityImgs/fmridenoise-0.2.1.sif"	#.sif is newer format vs .simg; for Singularity-v3.0+
if [ ! -r "$FMRIDENOISE_IMG" ]; then
	echo "*** ERROR: fmridenoise image is not readable...."
	exit 2
	#sudo mkdir -p /opt/SingularityImgs/
	#sudo singularity build ${FMRIDENOISE_IMG} docker://hfxcarlos/fmridenoise:0.2.1
fi


#[ "$#" -lt 1 ] && Usage
if [ "$#" -lt 1 ]; then
	E=$BIDS_WORK_DIR/derivatives/fmriprep; subjlist=""; 
	InputSubjects=""
	for S in $(ls -d $E/sub-????); do bn=$(basename $S); InputSubjects="${InputSubjects} ${bn:4:4}"; done
else
	InputSubjects=$@
fi

SubjList=""
for Subj in $InputSubjects ; do
	BID=$(basename $Subj)
	if [ "${#BID}" -ne 4 ]; then
		echo "*** ERROR: must specify SSID as either an 4-digit code; eg., 0123A"
		continue
	fi
	SDIR="$BIDS_WORK_DIR/BIDS_defaced/sub-${BID}"
	if [ ! -d "$SDIR" ]; then
		echo "*** ERROR: could not find subject directory = $SDIR"
		continue
	fi
	htmlFile=$BIDS_WORK_DIR/derivatives/fmriprep/sub-${BID}.html
	outDIR=$BIDS_WORK_DIR/derivatives/fmriprep/sub-${BID}
	anatOutput=$outDIR/anat/sub-${BID}_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
	funcOutput=$outDIR/func/sub-${BID}_task-rest_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz
	confOutput=$outDIR/func/sub-${BID}_task-rest_desc-confounds_timeseries.tsv
	if [ ! -r "$htmlFile" -o ! -r "$anatOutput" -o ! -r "$funcOutput" -o ! -r "$confOutput" ]; then
		echo " * Fmriprep has not been run on subject=$S, see $outDIR/"
		continue
	elif [ "$(grep -l 'a_comp_cor_101' $confOutput)" != "$confOutput" ]; then 
		echo " - missing a_comp_cor_100 from ${confOutput} ..."
		continue
	fi
	SubjList="${SubjList} $BID"
done

echo "$SubjList"
echo "+++++++++++++ DEBUG EARLY EXIT +++++++++++++++"
exit 


nSubj=$(echo $SubjList | wc -w | bc)
if [ "$RUN_FMRIDENOISE" == "yes" -a "$nSubj" -gt 0 ]; then
	DSTR=$(date +%Y%m%d-%H%M)
	ST=$SECONDS
	cd ${BIDS_WORK_DIR}/
	mkdir -p ./derivatives/fmridenoise/ ./derivatives/logs/ ./derivatives/work/fmridenoise
	export TEMPLATEFLOW_HOME=/data/derivatives/templateflow
	export SINGULARITYENV_TEMPLATEFLOW_HOME=/data/derivatives/templateflow
	export FS_LICENSE=/data/derivatives/freesurfer_license.txt
	export SINGULARITYENV_FS_LICENSE=/data/derivatives/freesurfer_license.txt
	#export SINGULARITY_BINDPATH=/scratch,/opt	#unnecessary
	pipelines="pipeline-24HMP_aCompCor_SpikeReg_4GS pipeline-Null"
	##pipelines="pipeline-24HMP_8Phys_SpikeReg pipeline-24HMP_8Phys_SpikeReg_4GS pipeline-24HMP_aCompCor_SpikeReg pipeline-24HMP_aCompCor_SpikeReg_4GS pipeline-Null"  
	workDir=/data/derivatives/work/fmridenoise
	mkdir -p ${workDir}
	pLog="/data/derivatives/fmridenoise/${DSTR}_resource_profile_group${nSubj}.log"
	gPath="/data/derivatives/fmridenoise/${DSTR}_workflow_graph_group${nSubj}"
	cmd="singularity run --cleanenv -B ${BIDS_WORK_DIR}:/data ${FMRIDENOISE_IMG} compare -sub ${SubjList} -t rest -p ${pipelines} -w ${workDir} --MultiProc --profiler ${pLog} --graph ${gPath} /data "
	echo " ++ `date`: running subject-level fmridenoise, with command:  ${cmd}"
	${cmd} > ${BIDS_WORK_DIR}/derivatives/logs/${DSTR}_fmridenoise_group_${nSubj}.log 2>&1
	ET=$(($SECONDS - $ST))
	echo " ++ `date`: finished fmridenoise -sub=${SubjList}; elapsed-time = $(($ET/60)) min, $(($ET%60)) sec"
fi


exit 0


## problems 2021/04/07:
$ tail -n 30 derivatives/logs/20210407-1320_fmridenoise_group_387.log 
210407-13:36:27,267 nipype.workflow WARNING:
	 [Node] Error on "BidsValidate" (/tmp/tmpp4e_vt66/BidsValidate)
/usr/local/lib/python3.8/dist-packages/nilearn-0.7.1-py3.8.egg/nilearn/datasets/__init__.py:87: FutureWarning: Fetchers from the nilearn.datasets module will be updated in version 0.9 to return python strings instead of bytes and Pandas dataframes instead of Numpy arrays.
  warn("Fetchers from the nilearn.datasets module will be "
Traceback (most recent call last):
  File "/usr/lib/python3.8/runpy.py", line 194, in _run_module_as_main
    return _run_code(code, main_globals, None,
  File "/usr/lib/python3.8/runpy.py", line 87, in _run_code
    exec(code, run_globals)
  File "/usr/local/lib/python3.8/dist-packages/fmridenoise-0.2.1-py3.8.egg/fmridenoise/__main__.py", line 238, in <module>
    main()
  File "/usr/local/lib/python3.8/dist-packages/fmridenoise-0.2.1-py3.8.egg/fmridenoise/__main__.py", line 230, in main
    compare(args)
  File "/usr/local/lib/python3.8/dist-packages/fmridenoise-0.2.1-py3.8.egg/fmridenoise/__main__.py", line 179, in compare
    workflow = init_fmridenoise_wf(input_dir,
  File "/usr/local/lib/python3.8/dist-packages/fmridenoise-0.2.1-py3.8.egg/fmridenoise/workflows/base.py", line 455, in init_fmridenoise_wf
    result = bids_validate.run()
  File "/usr/local/lib/python3.8/dist-packages/nipype-1.6.0-py3.8.egg/nipype/pipeline/engine/nodes.py", line 516, in run
    result = self._run_interface(execute=True)
  File "/usr/local/lib/python3.8/dist-packages/nipype-1.6.0-py3.8.egg/nipype/pipeline/engine/nodes.py", line 635, in _run_interface
    return self._run_command(execute)
  File "/usr/local/lib/python3.8/dist-packages/nipype-1.6.0-py3.8.egg/nipype/pipeline/engine/nodes.py", line 741, in _run_command
    result = self._interface.run(cwd=outdir)
  File "/usr/local/lib/python3.8/dist-packages/nipype-1.6.0-py3.8.egg/nipype/interfaces/base/core.py", line 434, in run
    runtime = self._run_interface(runtime)
  File "/usr/local/lib/python3.8/dist-packages/fmridenoise-0.2.1-py3.8.egg/fmridenoise/interfaces/bids.py", line 408, in _run_interface
    entities_files, (tasks, sessions, subjects, runs) = BIDSValidate.validate_files(
  File "/usr/local/lib/python3.8/dist-packages/fmridenoise-0.2.1-py3.8.egg/fmridenoise/interfaces/bids.py", line 361, in validate_files
    raise MissingFile(
fmridenoise.interfaces.bids.MissingFile: missing file(s) for {'subject': '001C', 'task': 'rest', 'session': 'A', 'extension': 'tsv', 'suffix': ['regressors', 'timeseries'], 'desc': 'confounds'} (check if you are using AROMA pipelines)
## fix?
## tried running manually, same issue.
## tried deleting extra "_edited_confounds*", ...?




Singularity> fmridenoise compare --help
usage: fmridenoise compare [-h] [-sub SUBJECTS [SUBJECTS ...]] [-ses SESSIONS [SESSIONS ...]] [-t TASKS [TASKS ...]] [-r RUNS [RUNS ...]] [-p PIPELINES [PIPELINES ...]] [-d DERIVATIVES] [--high-pass HIGH_PASS] [--low-pass LOW_PASS] [-w WORKDIR] [--MultiProc] [--profiler PROFILER] [-g] [--graph GRAPH] [--dry] bids_dir

positional arguments:
  bids_dir              Path do preprocessed BIDS dataset.

optional arguments:
  -h, --help            show this help message and exit
  -sub SUBJECTS [SUBJECTS ...], --subjects SUBJECTS [SUBJECTS ...]
                        List of subjects
  -ses SESSIONS [SESSIONS ...], --sessions SESSIONS [SESSIONS ...]
                        List of session numbers, separated with spaces.
  -t TASKS [TASKS ...], --tasks TASKS [TASKS ...]
                        List of tasks names, separated with spaces.
  -r RUNS [RUNS ...], --runs RUNS [RUNS ...]
                        List of runs names, separated with spaces.
  -p PIPELINES [PIPELINES ...], --pipelines PIPELINES [PIPELINES ...]
                        Name of pipelines used for denoising, can be both paths to json files with pipeline or name of pipelines from package.
  -d DERIVATIVES, --derivatives DERIVATIVES
                        Name (or list) of derivatives for which fmridenoise should be run. By default workflow looks for fmriprep dataset.
  --high-pass HIGH_PASS
                        High pass filter value, deafult 0.008.
  --low-pass LOW_PASS   Low pass filter value, default 0.08
  -w WORKDIR, --workdir WORKDIR
                        Temporary working directory. Default is '/tmp/fmridenoise
  --MultiProc           Run script on multiple processors, default False
  --profiler PROFILER   Run profiler along workflow execution to estimate resources usage PROFILER is path to output log file.
  -g, --debug           Run fmridenoise in debug mode - richer output, stops on first unchandled exception.
  --graph GRAPH         Create workflow graph at GRAPH path
  --dry                 Perform everything except actually running workflow
Singularity> 


