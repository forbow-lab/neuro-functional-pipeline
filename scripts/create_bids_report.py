#!/usr/bin/env python3

import os,sys
from bids.layout import BIDSLayout
from bids.reports import BIDSReport

#bids.config.set_option('extension_initial_dot', True)

SCRIPTSDIR=os.path.dirname(os.path.abspath(sys.argv[0]))
BDIR=os.path.join(os.path.dirname(SCRIPTSDIR),'BIDS')


### --- Load the BIDS dataset
layout = BIDSLayout(BDIR, 'synthetic')

### --- Initialize a report for the dataset
report = BIDSReport(layout)

### --- Method generate returns a Counter of unique descriptions across subjects
## *** ERROR: AttributeError: BIDSImageFile object has no attribute named 'run'
#descriptions = report.generate()
### after installing pybids-0.12.4.post.dev13), this still fails with error:
## *** ERROR: AttributeError: BIDSImageFile object has no attribute named 'run'
#nii_files = layout.get(session='C', extension=['.nii.gz','.nii'])
#descriptions = report.generate_from_files(nii_files)
## this works, but only prints a subset of the information...
desc = report.generate(session='C', task=['anat','rest'])

# For datasets containing a single study design, all but the most common
# description most likely reflect random missing data.
print(desc.most_common()[0][0])
#For session C:
#	MR data were acquired using a 3-Tesla GE DISCOVERY MR750 MRI scanner.
#	One run of rest EPI muxarcepi (muxarcepi) single-echo fMRI data were collected (51 slices in interleaved ascending order; repetition time, TR=950ms; echo time, TE=30ms; flip angle, FA=60<deg>; field of view, FOV=216x216mm; matrix size=72x72; voxel size=3x3x3mm; MB factor=3; in-plane acceleration factor=2). Each run was 7:55 minutes in length, during which 500 functional volumes were acquired. 
#	Dicoms were converted to NIfTI-1 format. This section was (in part) generated automatically using pybids (0.12.4.post.dev13). 

sys.exit(1)


## REFERENCE: 
##   https://bids-standard.github.io/pybids/_modules/bids/reports/report.html
# from os.path import join
# from bids.layout import BIDSLayout
# from bids.reports import BIDSReport
# from bids.tests import get_test_data_path
# layout = BIDSLayout(join(get_test_data_path(), 'synthetic'))
# report = BIDSReport(layout)
# nii_files = layout.get(session='C', extension=['.nii.gz', '.nii'])
# counter = report.generate_from_files(nii_files)
# ###Number of patterns detected: 1
# ###Remember to double-check everything and to replace <deg> with a degree symbol.
# counter.most_common()[0][0]  # doctest: +ELLIPSIS

