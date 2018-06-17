#!/bin/bash

BASE=$(cd $(dirname $0);pwd)

source ${BASE}/scripts-common/helpers

sync_init_with_depth(){
    echo "repo init --depth=1 -g ${REPO_GROUPS} -p linux"
    repo init --depth=1 -g ${REPO_GROUPS} -p linux
}

sync_init_without_depth(){
    echo "repo init --depth=0 -g ${REPO_GROUPS} -p linux"
    repo init --depth=0 -g ${REPO_GROUPS} -p linux
}

sync(){
    echo "repo sync -j${CPUS} ${TARGETS[@]}"
    repo sync -j${CPUS} ${TARGETS[@]}
}

##########################################################
##########################################################
while [ "$1" != "" ]; do
	case $1 in
		-j)	# set build parallellism
			shift
			echo "Num threads: $1"
			CPUS=$1
			;;
		-d)
			echo "Print debug"
			dbg=true
			;;
		*)	# default adds to target list without shift
			echo "Adding repo target: $1"
			TARGETS=(${TARGETS[@]} $1)
			;;
	esac
	shift
done

sync_init_without_depth
#echo "${TARGETS[@]}"
sync "${TARGETS[@]}"
sync_init_with_depth
