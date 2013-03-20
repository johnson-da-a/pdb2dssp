#! /bin/bash

#Checks if a file exists. Modifies second variable accordingly

function fileExists {
	if [  -f "$1" ]
	then
		calculateDssp $1 $2
	fi
}

#$1 = proteinName
function findPath {
	x=1

	checkPath=true
	filePath=$(echo "$PDBPATH" | cut -d':' -f $x) 


	while [[ $checkPath=true ]];
	do
		if [[ "$filePath" != *[a-zA-Z0-9]* && "$filePath" != *.* ]]
		then
			checkPath=false
			break
		else
			fileExists "$filePath"/"$1".pdb	$1						#Check if file exists
			if [[ $file_exists=true ]];
			then
				checkPath=false
			fi #if [[ $file_exists=true ]]
		fi #if [[ "$filePath" != *[a-zA-Z0-9]* && "$filePath" != *.* ]]
		(( x++ ))
		filePath=$(echo "$PDBPATH" | cut -d':' -f $x) 
	done
}

function calculateDssp {
	echo "-"$2
	dssp -i $1 -o $2.dssp
}

for currentJob in $@
do
	if [[ "$currentJob" != *.* ]]									#single file input arg
	then
		proteinName=$currentJob
		findPath $currentJob
	else															#file with list of pdbs
		echo "Reading "$currentJob
		while read line || [[ -n "$line" ]]; do
			if [[ "$line" == \#* || "$line" != *[a-zA-Z0-9]* ]]		#Skipping comment and blank lines
			then
				continue
			elif [[ "$line" != *.pdb ]]
			then													#if .pdb is not found
				currentJob="$line"
			else													#if it contains .pdb
				currentJob=$(echo "$line" | cut -d'.' -f 1)		#extract file name w/out extension 
			fi 
			findPath $currentJob
		done < "$currentJob"
	fi
done