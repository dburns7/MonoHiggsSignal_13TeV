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

name=EFT_xdxHDHc

chimassfile=inputs_${name}/input_chi
lastchipoint=`cat $chimassfile | wc -l`
echo "There are "$lastchipoint" chi mass points"

lambdafile=inputs_${name}/input_lambda
lastlambdapoint=`cat $lambdafile | wc -l`
echo "There are "$lastlambdapoint" cutoff points"

iteration=0
iterlambda=0
while [ $iterlambda -lt $lastlambdapoint ];
do
  iterlambda=$(( iterlambda + 1))
  lambda=(`head -n $iterlambda $lambdafile  | tail -1 | awk '{print $1}'`) 
  iterchi=0
  while [ $iterchi -lt $lastchipoint ]; 
  do
  	iterchi=$(( iterchi + 1 ))
        chimass=(`head -n $iterchi $chimassfile  | tail -1 | awk '{print $1}'`)
	iteration=$(( iteration + 1 ))
	    echo ""
	    echo "Producing gridpacks for chi mass     = "$chimass" GeV "
	    echo "Producing gridpacks for Lambda       = "$lambda" GeV "
	    echo ""
	    process=${name}_MChi${chimass}_Lambda${lambda}
	    dir=$CARDSDIR/$name/$process
	    ls $dir
	    bsub -q $queue $PWD/runJob.sh $PWD $process $dir Higgs_xdxhDhc_UFO.tar.gz
  done
done

echo "There are "$iteration" mass points in total."
