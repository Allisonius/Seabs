#!/usr/bin/env bash

trap "exit" INT

_SEABS_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

SEABS="Seabs"
JAR_PATHS="${_SEABS_DIR}/libs/alloy4.2.jar:${_SEABS_DIR}/libs/commons-cli-1.0.jar"

# Main functionality

# Generate the kodkod program
function seabs.generate() {
	javac -cp "${JAR_PATHS}:." scr/main/java/alloyuse/GenerateAFKodKod.java scr/main/java/solver/Solver.java
        java -cp "${JAR_PATHS}:${_SEABS_DIR}/scr/main/java/:." alloyuse.GenerateAFKodKod "$@"
}

# Execute the kodkod program
function seabs.enumerate() {
	javac -cp "${JAR_PATHS}:." "${1}" scr/main/java/solver/Solver.java
	filename=$(basename "$1" .java)
	path="$1"
	path=${path%/*}
        java -cp "${JAR_PATHS}:${_SEABS_DIR}/scr/main/java/:$path/:." "$filename"
}

# ----------
# Main.

case $1 in
        --generate) shift;
	                    seabs.generate "$@";;
	--enumerate) shift;
	                    seabs.enumerate "$@";;
        *)
	        echo "ERROR: Incorrect arguments: $@"
	        exit 1;;
esac
