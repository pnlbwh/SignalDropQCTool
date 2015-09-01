#!/bin/bash

if [[ $1 == "-h" || $1 == "--help" ]]; then
    echo "Runs matlab Quality Control tool"
    echo "Usage:"
    echo
    echo "   QC_Tool.sh [mode] [path]"
    echo
    echo "Mode: semi-automatic, automatic, batch"
    echo
    echo "Example: QC_Tool.sh batch \"/mypath/*.nhdr\""
    echo 
    echo "1. 'semi-automatic' mode displays a User Interface, from which you have
 access to all the control buttons. path can be empty or a path to a NRRD file"
    echo
    echo "2. 'automatic' mode allows you to process one particular file without
 displaying the interface. Ex path = \"/projects/study/diff/dwi.nhdr\""
    echo
    echo "3. 'batch' mode allows you to process all the file with a given pattern in
 a folder. Ex: path = \"/projects/study/diffusion/*.nhdr\""
    echo
    echo "Sensitivity should be 1 or 4, default is 1"
    echo
    echo "On an 8-cores machine, with 12GB of RAM, it usually takes 5 minutes to compute the KL divergence for 70
 gradients direction and 100*100*70 voxels par gradients"
    echo
    echo " === === === ==="
    echo
    echo "You can also call the QC Tool from Matlab, simply add /projects/software/QC_Tool/ to the path, and then type"
    echo "    help launch_QC_Tool "
    echo "This will display the help"
    echo
    exit 0
fi

MATLAB="matlab -nosplash -r "
QC_PATH="/projects/schiz/software/QC_Tool"

if [[ -z $1 ]]; then
    M_CMD="addpath $QC_PATH; launch_QC_Tool"
    echo "$M_CMD"
    $MATLAB "$M_CMD"
    exit 0
fi

mode=$1

if [[ -z $2 ]]; then
    path_to_file=""
else 
    path_to_file=$2	
fi

M_CMD="addpath $QC_PATH; launch_QC_Tool('$mode', '$path_to_file');"
echo "$M_CMD"
$MATLAB "$M_CMD"







