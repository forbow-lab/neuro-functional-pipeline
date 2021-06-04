#!/bin/bash



Usage(){
	echo "Usage: `basename $0` <ssid>"
	echo
	echo "Example: `basename $0` 005_C"
	echo 
	exit 1
}

SCRIPT=$(python -c "from os.path import abspath; print(abspath('$0'))")
SCRIPTSDIR=$(dirname $SCRIPT)
if [[ -z "${BIDS_WORK_DIR}" ]]; then
	source "$SCRIPTSDIR/SetupEnv.sh"
fi

FORCE_OVERWRITE="no"
if [ "$1" == "-f" ]; then
	FORCE_OVERWRITE="yes"
	shift ;
fi

[ "$#" -lt 1 ] && Usage



for Subj in $@ ; do
	
	S=$(basename $Subj)
	if [ "${#S}" -eq 4 ]; then		#001C
		ssid=${S:0:3}
    	sess=${S:3:1}
    	S="${ssid}_${sess}"
	elif [ "${#S}" -eq 5 ]; then	#001_C
		ssid=${S:0:3}
    	sess=${S:4:1}
    else	
		echo "*** ERROR: must specify SSID as 5-digit code <SSID_SESS>, eg: 074_C"
		continue
	fi
    SubjRawDIR=$(find $RAW_DATA_DIR -maxdepth 1 -type d -name "${S}_20??????" -print | head -1)
    if [ ! -d "$SubjRawDIR" ]; then
        echo "*** ERROR: could not find subject raw data folder = $RAW_DATA_DIR/${S}_YYYYMMDD"
        continue
    fi
    
    bidsID=${ssid}${sess}
    subjRawBidsDIR="$SubjRawDIR/BIDS_raw/sub-${ssid}/ses-${sess}"
    if [ ! -d "$subjRawBidsDIR" ]; then
        echo "*** ERROR: could not find subject rawdata BIDS_raw = $subjRawBidsDIR"
        continue
    fi
    
    ##---------- check directory to ensure BIDS-complete ----------------------------------------------------------------
	FAIL_ON_MISSING_DWI_BIDS="no"
	AD="$subjRawBidsDIR/anat"
	DD="$subjRawBidsDIR/dwi"
	FMD="$subjRawBidsDIR/fmap"
	FUD="$subjRawBidsDIR/func"
	pf="sub-${ssid}_ses-${sess}"
	goodBIDS="yes"
	for f in $AD/${pf}_T1w.nii.gz $AD/${pf}_T1w.json $AD/${pf}_mod-T1w_defacemask.nii.gz $AD/${pf}_T2w.nii.gz $AD/${pf}_T2w.json $AD/${pf}_mod-T2w_defacemask.nii.gz ; do
		if [ ! -f "$f" ]; then
			echo " - missing $f" >&2
			goodBIDS="no"
		fi
	done
	for pe in AP PA ; do
		for f in $DD/${pf}_dir-${pe}_dwi.nii.gz $DD/${pf}_dir-${pe}_dwi.json $DD/${pf}_dir-${pe}_dwi.bval $DD/${pf}_dir-${pe}_dwi.bvec ; do
			if [ ! -f "$f" ]; then
				echo " - missing $f" >&2
				if [ "$FAIL_ON_MISSING_DWI_BIDS" == "yes" ]; then
					goodBIDS="no"
				fi
			fi
		done
	done
	for f in $FMD/${pf}_dir-AP_epi.nii.gz $FMD/${pf}_dir-AP_epi.json $FMD/${pf}_dir-PA_epi.nii.gz $FMD/${pf}_dir-PA_epi.json ; do
		if [ ! -f "$f" ]; then
			echo " - missing $f" >&2
			goodBIDS="no"
		fi
	done
	for f in $FUD/${pf}_task-rest_bold.nii.gz $FUD/${pf}_task-rest_bold.json $FUD/${pf}_task-rest_sbref.nii.gz $FUD/${pf}_task-rest_sbref.json ; do
		if [ ! -f "$f" ]; then
			echo " - missing $f" >&2
			goodBIDS="no"
		fi
	done
	if [ "$goodBIDS" == "yes" ]; then
		echo " + bids complete = $subjRawBidsDIR" >&1
	else
		echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
		echo " * WARNING: incomplete $subjRawBidsDIR/"
		echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
		continue
	fi
    
    
    subjWorkBidsRawDIR=$BIDS_WORK_DIR/BIDS_raw/sub-${bidsID}
    subjWorkBidsDefacedDIR=$BIDS_WORK_DIR/BIDS_defaced/sub-${bidsID}
    if [ "$FORCE_OVERWRITE" == "yes" ]; then
    	echo " * FORCE_OVERWRITE is enabled, removing old BIDS=${subjWorkBidsRawDIR}/"
    	rm -rf ${subjWorkBidsRawDIR}/ ${subjWorkBidsDefacedDIR}/
    fi
    
    
    ## -------- Copy /rawdata/SSID/BIDS_raw/sub-xxx/ses-X/ --> /BIDS_WORK/BIDS_raw/sub-xxxX/
    if [ ! -d "$subjWorkBidsRawDIR" ]; then 
        echo " ++ copying bids data from $subjRawBidsDIR/ to $subjWorkBidsRawDIR/, starting `date`"
        cp -rpvf $subjRawBidsDIR $subjWorkBidsRawDIR
    fi
    echo " ++ renaming ssid_ses to ssidses in subjWorkBidsRawDIR/"
    rename.ul -v "sub-${ssid}_ses-${sess}" "sub-${bidsID}" $subjWorkBidsRawDIR/*/*
    grep -rl "sub-${ssid}_ses-${sess}" $subjWorkBidsRawDIR/fmap/* | xargs sed -i "s|sub\-${ssid}_ses\-${sess}|sub\-${bidsID}|g"
    grep -rl "ses-${sess}" $subjWorkBidsRawDIR/fmap/* | xargs sed -i "s|ses\-${sess}/||g"
    grep -rl "sub-${bidsID}/func" $subjWorkBidsRawDIR/fmap/* | xargs sed -i "s|sub\-${bidsID}/func|func|g"

   ## -------- Copy /BIDS_WORK/BIDS_raw/sub-xxxX/ --> /BIDS_WORK/BIDS_defaced/sub-xxxX/,  and apply defacemask to T1w/T2w 
    if [ ! -d "$subjWorkBidsDefacedDIR" ]; then 
        echo " ++ copying bids data from $subjWorkBidsRawDIR/ to $subjWorkBidsDefacedDIR/, starting `date`"
        cp -rpvf $subjWorkBidsRawDIR $subjWorkBidsDefacedDIR
    fi
    ## apply /anat/ defacemasks, and delete defacemasks.
    echo " ++ applying T1w_defacemask to T1w"
    fslmaths $subjWorkBidsDefacedDIR/anat/sub-${bidsID}_mod-T1w_defacemask.nii.gz -binv -mul $subjWorkBidsDefacedDIR/anat/sub-${bidsID}_T1w.nii.gz $subjWorkBidsDefacedDIR/anat/sub-${bidsID}_T1w.nii.gz
    rm -fv $subjWorkBidsDefacedDIR/anat/sub-${bidsID}_mod-T1w_defacemask.nii.gz
    echo " ++ applying T2w_defacemask to T2w"
    fslmaths $subjWorkBidsDefacedDIR/anat/sub-${bidsID}_mod-T2w_defacemask.nii.gz -binv -mul $subjWorkBidsDefacedDIR/anat/sub-${bidsID}_T2w.nii.gz $subjWorkBidsDefacedDIR/anat/sub-${bidsID}_T2w.nii.gz
    rm -fv $subjWorkBidsDefacedDIR/anat/sub-${bidsID}_mod-T2w_defacemask.nii.gz
    
    echo " +++ finished copying bids data from $SubjRawDIR/ to $subjWorkBidsRawDIR/ and subjWorkBidsDefacedDIR, on `date`"
done

exit 0
