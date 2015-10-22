#!/bin/bash

scriptname=`basename $0`
EXPECTED_ARGS=2

if [ $# -ne $EXPECTED_ARGS ]
then
    echo "Usage: $scriptname queue directoryName"
    echo "Example: ./$scriptname 2nd cards/production/13TeV/monoHiggs"
    exit 1
fi

# name of the run
queue=$1
CARDSDIR=$2

name=EFT_HHxx_combined

chimassfile=inputs_${name}/input_chi
lastchipoint=`cat $chimassfile | wc -l`
echo "There are "$lastchipoint" chi mass points"

iterchi=0
while [ $iterchi -lt $lastchipoint ]; 
do
	iterchi=$(( iterchi + 1 ))
        chimass=(`head -n $iterchi $chimassfile  | tail -1 | awk '{print $1}'`)
	
	    echo ""
	    echo "Producing gridpacks for chi mass     = "$chimass" GeV "
	    echo ""
	    process=${name}_MChi${chimass}
	    dir=$CARDSDIR/$name/$process
	    ls $dir
	    #bsub -q $queue $PWD/runJob.sh $PWD $process $dir
done

echo "There are "$iterchi" mass points in total."
