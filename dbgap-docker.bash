#!/bin/bash

#================================================================
# HEADER
#================================================================
#% SYNOPSIS
#+    ${SCRIPT_NAME} [-hv] [-i [input directory]] [-o [output directory]] [up|down]
#==  [-t [local|nfs]]  to be used later
#+
#% DESCRIPTION
#%    This script runs the NIH NCBI tool to validate data
#%    submitted to the dbGaP database. It loads a docker-compose
#%    file and runs several docker containers.
#%
#%
#% OPTIONS
#%    -i [input directory]          Input directory containing the 
#%                                  data files to be validated.
#%    -o                            Output directory
#%    -h                            Print this help
#%    -v                            Print script information
#%
#% EXAMPLES
#%    ${SCRIPT_NAME} -i ./input_files -o ./output_files up
#%    ${SCRIPT_NAME} down
#%
#%
#% REQUIREMENTS
#%    docker
#%    docker-compose
#%
#%
#================================================================
#- IMPLEMENTATION
#-    version         ${SCRIPT_NAME} 0.0.1
#-    author          Dale Conklin
#-    copyright       Copyright (c) 2020
#-    license         GNU General Public License
#-
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


##################
# Parse and verify command line options
##################
OPTIONS=hvt:i:o:
LONGOPTS=help,input:,output:,type:

# pass arguments only via   -- "$@"   to separate them correctly
! PARSED=$(getopt --options=$OPTIONS --longoptions=$LONGOPTS --name "$0" -- "$@")
if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
    # e.g. return value is 1
    #  then getopt has complained about wrong arguments to stdout
    echo "Wrong number/type of arguments"
    usage
    exit 2
fi
# read getopt output to handle the quoting:
eval set -- "$PARSED"

# interate through to set values for the script
while true; do
    case "$1" in
        -h|--help)
            usagefull
            exit
            ;;
        -v)
            scriptinfo
            exit
            ;;
        -i|--input)
            echo $2
            INPUT_DIR="$2" 
            INPUT_DIR="$(echo -e "${INPUT_DIR}" | tr -d '[[:space:]]')"
            if [ -z "$INPUT_DIR" ]; then
               echo $INPUT_DIR " input directory is a problem"
               usage
               exit 2
            fi
            if [ z"${INPUT_DIR:0:1}" == "z-" ]; then
               echo $INPUT_DIR " Looks like input directory was set with an option string"
               usage
               exit 2
            fi
            shift 2 
            ;;
        -o|--output)
            OUTPUT_DIR="$2" 
            OUTPUT_DIR="$(echo -e "${OUTPUT_DIR}" | tr -d '[[:space:]]')"
            if [ -z "$OUTPUT_DIR" ]; then
               echo $OUTPUT_DIR "Output directory has problem"
               usage
               exit 2
            fi
            if [ z"${OUTPUT_DIR:0:1}" == "z-" ]; then
               echo $OUTPUT_DIR "Output directory was set with an option string"
               usage
               exit 2
            fi 
            shift 2
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "An incorrect option has been supplied"
            usage
            exit 3
            ;;
    esac
done

##################
# Verify up/down arguments were supplied properly
##################
if [[ $# -ne 1 ]]; then
    echo $'\n'"$0: options supplied or argument is incorrect."$'\n'
    usage
    exit 4
fi
DSTATE=$1
if ! [[ "${DSTATE}" =~ ^(up|down)$ ]]; then
    echo $'\n'"$0: up or down are the only allowed arguments."$'\n'
    usage
    exit 4
fi

#########################
# Run the docker-compose commands to bring the environment down
# Skips the rest of the validation and exit the script
#########################
if [ $DSTATE == "down" ]; then
   docker-compose -f docker-compose-CeleryExecutor.yml down
   exit
fi

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
# if [ -z ${FS_TYPE} ]; then
#    ERROR_TEXT=$ERROR_TEXT$'Filesystem type has not been set. Valid options are local or nfs.\n'
# fi
if [ ! -z "${ERROR_TEXT}" ]; then
   echo "$ERROR_TEXT"
   usage
   exit 2
fi

########################
# Validate that the input and output directories exist
########################
if [ ! -d "$INPUT_DIR" ]; then
   echo "Input directory does not exist"
   exit 2
fi
if [ ! -d "$OUTPUT_DIR" ]; then
   echo "Output directory does not exist"
   exit 2
fi

########################
# Create a .env file to be used by docker-compose
########################
echo "OUTPUT_VOL=${OUTPUT_DIR}" > .env
echo "INPUT_VOL=${INPUT_DIR}" >> .env


#########################
# Run the docker-compose commands to bring the environment up
#########################
if [ $DSTATE == "up" ]; then
   docker-compose -f docker-compose-CeleryExecutor.yml up -d
fi

