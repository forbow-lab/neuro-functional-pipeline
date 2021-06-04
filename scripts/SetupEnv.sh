#!/bin/bash

## Main Project Path
if [ "$HOSTNAME" == "Aoraki.local" ]; then
	PROJECT_DIR="/Users/carl/work/uher/FORBOW"
    IMAGE_CONTAINER_PATH="/opt"
elif [ "$HOSTNAME" == "mars" -o "$HOSTNAME" == "jaylah" ]; then
    PROJECT_DIR="/shared/uher/FORBOW"
    IMAGE_CONTAINER_PATH="/opt/SingularityImgs"
elif [ "$HOSTNAME" == "cedar1.cedar.computecanada.ca" ]; then
    PROJECT_DIR="$HOME/projects/def-ruher/fmri"
    IMAGE_CONTAINER_PATH="$PROJECT_DIR/SingularityImgs"
else
    echo "*** ERROR: this program must be run from Mars or Jaylah...exiting"
    exit 1
fi

echo " * `date +%Y%m%d-%H%M`: running `basename $0` on $HOSTNAME, PROJECT_DIR=$PROJECT_DIR/"

RAW_DATA_DIR=$PROJECT_DIR/rawdata
BIDS_WORK_DIR=$PROJECT_DIR/BIDS_WORK

