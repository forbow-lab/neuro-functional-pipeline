#!/bin/bash


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


[ "$#" -lt 1 ] && Usage

cd $BIDS_WORK_DIR/derivatives/fmriprep/
SUBJECTS="$@" #$(ls -d sub-????)
for D in $SUBJECTS ; do
	S=${D:4:4}
	SDIR=$(pwd)/sub-${S}
	if [ ! -d "$SDIR" ]; then
		echo "*** ERROR: could not find subject directory = $SDIR"
		continue
	fi
	anatOutput=$SDIR/anat/sub-${S}_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
	funcOutput=$SDIR/func/sub-${S}_task-rest_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz
	if [ -r "$anatOutput" -a -r "$funcOutput" ]; then
		echo "$S"
	else
		echo " *** ERROR: missing fmriprep outputs for $SDIR/"
	fi
done

exit 0


## Results from Terminal:
cd /shared/uher/FORBOW/BIDS_WORK/derivatives/fmriprep/
for D in `ls -d sub-???[A,B]`; do S=${D:4:4}; A=$D/anat/sub-${S}_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz; if [ -r "$A" ]; then echo " + found $A"; else echo " - could not find $A"; fi; done
 - could not find sub-035A/anat/sub-035A_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
 - could not find sub-035B/anat/sub-035B_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
 + found sub-036A/anat/sub-036A_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
 + found sub-036B/anat/sub-036B_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
 + found sub-037A/anat/sub-037A_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
 + found sub-037B/anat/sub-037B_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
 - could not find sub-039A/anat/sub-039A_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
 - could not find sub-040A/anat/sub-040A_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
 + found sub-041A/anat/sub-041A_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
 + found sub-041B/anat/sub-041B_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
 + found sub-042A/anat/sub-042A_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
 + found sub-042B/anat/sub-042B_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
 - could not find sub-049A/anat/sub-049A_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
 - could not find sub-050A/anat/sub-050A_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
 + found sub-057A/anat/sub-057A_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
 + found sub-057B/anat/sub-057B_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
 + found sub-063A/anat/sub-063A_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
 + found sub-063B/anat/sub-063B_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
 + found sub-065A/anat/sub-065A_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
 + found sub-065B/anat/sub-065B_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
 + found sub-067A/anat/sub-067A_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
 + found sub-067B/anat/sub-067B_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
 + found sub-068A/anat/sub-068A_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
 + found sub-068B/anat/sub-068B_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
 + found sub-069A/anat/sub-069A_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
 + found sub-069B/anat/sub-069B_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
 + found sub-072A/anat/sub-072A_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
 + found sub-072B/anat/sub-072B_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
 + found sub-074A/anat/sub-074A_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
 + found sub-074B/anat/sub-074B_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
 + found sub-075A/anat/sub-075A_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
 + found sub-075B/anat/sub-075B_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
 + found sub-077A/anat/sub-077A_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
 + found sub-077B/anat/sub-077B_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
 + found sub-078A/anat/sub-078A_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
 + found sub-078B/anat/sub-078B_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
 + found sub-079A/anat/sub-079A_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
 + found sub-079B/anat/sub-079B_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
 + found sub-082A/anat/sub-082A_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
 + found sub-082B/anat/sub-082B_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
 + found sub-083A/anat/sub-083A_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
 + found sub-083B/anat/sub-083B_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
 + found sub-085A/anat/sub-085A_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
 + found sub-085B/anat/sub-085B_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
 + found sub-087A/anat/sub-087A_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
 + found sub-087B/anat/sub-087B_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
 + found sub-097A/anat/sub-097A_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
 + found sub-097B/anat/sub-097B_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
 + found sub-098A/anat/sub-098A_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
 + found sub-098B/anat/sub-098B_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
 + found sub-099A/anat/sub-099A_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
 + found sub-099B/anat/sub-099B_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
 + found sub-100A/anat/sub-100A_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
 + found sub-100B/anat/sub-100B_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
 + found sub-103A/anat/sub-103A_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
 + found sub-103B/anat/sub-103B_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
 + found sub-107A/anat/sub-107A_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
 + found sub-107B/anat/sub-107B_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
 + found sub-128A/anat/sub-128A_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
 + found sub-128B/anat/sub-128B_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
 + found sub-133A/anat/sub-133A_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
 + found sub-133B/anat/sub-133B_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
 + found sub-136A/anat/sub-136A_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
 + found sub-136B/anat/sub-136B_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
 + found sub-138A/anat/sub-138A_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
 + found sub-138B/anat/sub-138B_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
 + found sub-139A/anat/sub-139A_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
 + found sub-139B/anat/sub-139B_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
 + found sub-147A/anat/sub-147A_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
 + found sub-147B/anat/sub-147B_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
 + found sub-151A/anat/sub-151A_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
 + found sub-151B/anat/sub-151B_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
 + found sub-153A/anat/sub-153A_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
 + found sub-153B/anat/sub-153B_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
 + found sub-161A/anat/sub-161A_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
 + found sub-161B/anat/sub-161B_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
 + found sub-164A/anat/sub-164A_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
 + found sub-164B/anat/sub-164B_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
 + found sub-169A/anat/sub-169A_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
 + found sub-169B/anat/sub-169B_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
 + found sub-172A/anat/sub-172A_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
 + found sub-172B/anat/sub-172B_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
 + found sub-173A/anat/sub-173A_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
 + found sub-173B/anat/sub-173B_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
 + found sub-176A/anat/sub-176A_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
 + found sub-176B/anat/sub-176B_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
 + found sub-183A/anat/sub-183A_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
 + found sub-183B/anat/sub-183B_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
 + found sub-187A/anat/sub-187A_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
 + found sub-187B/anat/sub-187B_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
 + found sub-188A/anat/sub-188A_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
 + found sub-188B/anat/sub-188B_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
 + found sub-189A/anat/sub-189A_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
 + found sub-189B/anat/sub-189B_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
 + found sub-190A/anat/sub-190A_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
 + found sub-190B/anat/sub-190B_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
 + found sub-201A/anat/sub-201A_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
 + found sub-201B/anat/sub-201B_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
 + found sub-202A/anat/sub-202A_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
 + found sub-202B/anat/sub-202B_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
 + found sub-212A/anat/sub-212A_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
 + found sub-212B/anat/sub-212B_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz