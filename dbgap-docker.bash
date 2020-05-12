#!/bin/bash

#================================================================
# HEADER
#================================================================
#% SYNOPSIS
#+    ${SCRIPT_NAME} [-h] [-i [input directory]] [-o [output directory]] [-t [local|nfs]]
#%
#% DESCRIPTION
#%    This script runs the NIH NCBI tool to validate data
#%    submitted to the dbGaP database. It loads a docker-compose
#%    file and runs several docker containers.
#%
#%
#% OPTIONS
#%    -o [file], --output=[file]    Set log file (default=/dev/null)
#%                                  use DEFAULT keyword to autoname file
#%                                  The default value is /dev/null.
#%    -t, --timelog                 Add timestamp to log ("+%y/%m/%d@%H:%M:%S")
#%    -x, --ignorelock              Ignore if lock file exists
#%    -h, --help                    Print this help
#%    -v, --version                 Print script information
#%
#% EXAMPLES
#%    ${SCRIPT_NAME} -o DEFAULT arg1 arg2
#%
#================================================================
#- IMPLEMENTATION
#-    version         ${SCRIPT_NAME} 0.0.1
#-    author          Dale Conklin
#-    copyright       Copyright (c) 2020
#-    license         GNU General Public License
#-
#================================================================
#  HISTORY
#     2020/05/11 : dconklin : Script creation
# 
#================================================================
# END_OF_HEADER
#================================================================



#== needed variables ==#
SCRIPT_HEADSIZE=$(head -200 ${0} |grep -n "^# END_OF_HEADER" | cut -f1 -d:)
SCRIPT_NAME="$(basename ${0})"

#== usage functions ==#
usage() { printf "Usage: "; head -${SCRIPT_HEADSIZE:-99} ${0} | grep -e "^#+" | sed -e "s/^#+[ ]*//g" -e "s/\${SCRIPT_NAME}/${SCRIPT_NAME}/g" ; }
usagefull() { head -${SCRIPT_HEADSIZE:-99} ${0} | grep -e "^#[%+-]" | sed -e "s/^#[%+-]//g" -e "s/\${SCRIPT_NAME}/${SCRIPT_NAME}/g" ; }
scriptinfo() { head -${SCRIPT_HEADSIZE:-99} ${0} | grep -e "^#-" | sed -e "s/^#-//g" -e "s/\${SCRIPT_NAME}/${SCRIPT_NAME}/g"; }

while getopts "ht:i:o:" option; do
   case $option in
      h) # display Help
         usage
         exit
         ;;
      t) # type of storage
         FS_TYPE=$OPTARG
         FS_TYPE="$(echo -e "${FS_TYPE,,}" | tr -d '[[:space:]]')"
            if ! [[ "${FS_TYPE}" =~ ^(local|nfs)$ ]]; then
               echo "Valid options for filesystem type are local or nfs."
               usage
               exit 2
            fi
            if [ -z "$FS_TYPE" ]; then
               echo $FS_TYPE " Filesystem type problem"
               exit 2
            fi
            if [ z"${OPTARG:0:1}" == "z-" ]; then
               echo $FS_TYPE " Looks like filesystem was set with an option string"
               exit 2
            fi 
            ;;
      i) # input directory
         INPUT_DIR=$OPTARG 
         INPUT_DIR="$(echo -e "${INPUT_DIR}" | tr -d '[[:space:]]')"
            if [ -z "$INPUT_DIR" ]; then
               echo $INPUT_DIR " input directory is a problem"
               exit 2
            fi
            if [ z"${OPTARG:0:1}" == "z-" ]; then
               echo $INPUT_DIR " Looks like input directory was set with an option string"
               exit 2
            fi 
            ;;
      o) # output directory
         OUTPUT_DIR=$OPTARG 
         OUTPUT_DIR="$(echo -e "${OUTPUT_DIR}" | tr -d '[[:space:]]')"
            if [ -z "$OUTPUT_DIR" ]; then
               echo $OUTPUT_DIR "Output directory has problem"
               exit 2
            fi
            if [ z"${OPTARG:0:1}" == "z-" ]; then
               echo $OUTPUT_DIR "Output directory was set with an option string"
               exit 2
            fi 
            ;;
      ?) echo "we have a problem"; usage
         exit 2
         ;;
      :) 
         echo "Invalid option: $OPTARG requires an argument"; usage 1>&2
         exit 2 ;;
   esac
done

########################
# Validate that all options have been set
########################
ERROR_TEXT=""
if [ -z ${INPUT_DIR} ]; then
   ERROR_TEXT=$ERROR_TEXT$'Input directory has not been set.\n'
fi
if [ -z ${OUTPUT_DIR} ]; then
   ERROR_TEXT=$ERROR_TEXT$'Output directory has not been set.\n'
fi
if [ -z ${FS_TYPE} ]; then
   ERROR_TEXT=$ERROR_TEXT$'Filesystem type has not been set. Valid options are local or nfs.\n'
fi
if [ ! -z "${ERROR_TEXT}" ]; then
   echo "$ERROR_TEXT"
   usage
   exit 2
fi

#########################
# Replace all variables in the template file
#########################

echo "Filesystem |"$FS_TYPE"| input directory: |"$INPUT_DIR"| " 
