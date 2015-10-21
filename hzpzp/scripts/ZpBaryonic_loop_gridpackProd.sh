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

name=ZpBaryonic

Zpmassfile=inputs_${name}/input_zprimemass
Zpwidthfile=inputs_${name}/input_zprimewidth
lastZppoint=`cat $Zpmassfile | wc -l`
echo "There are "$lastZppoint" Zprime mass points"

chimassfile=inputs_${name}/input_chi
lastchipoint=`cat $chimassfile | wc -l`
echo "There are "$lastchipoint" chi mass points"

iteration=0
iterZp=0
while [ $iterZp -lt $lastZppoint ]; 
do
    iterZp=$(( iterZp + 1 ))
    iterchi=0
    while [ $iterchi -lt $lastchipoint ]; 
    do
	iterchi=$(( iterchi + 1 ))
        iterZwidth=$(( iterchi + 1 ))
        Zpmass=(`head -n $iterZp $Zpmassfile  | tail -1 | awk -v my_var1=$iterZwidth '{print $my_var1}'`)
        Zpwidth=(`head -n $iterZp $Zpwidthfile  | tail -1 | awk -v my_var2=$iterZwidth '{print $my_var2}'`)
        chimass=(`head -n $iterchi $chimassfile  | tail -1 | awk '{print $1}'`)
	
	if (( $(echo "$Zpwidth > 0.0" | bc -l) ))
	then
	    iteration=$(( iteration + 1 ))
	    echo ""
	    echo "Producing gridpacks for Zprime mass  = "$Zpmass" GeV"
            echo "Producing gridpacks for Zprime width = "$Zpwidth" GeV"
	    echo "Producing gridpacks for chi mass     = "$chimass" GeV "
	    echo ""
	    process=${name}_MZp${Zpmass}_MChi${chimass}
	    dir=$CARDSDIR/$name/$process
	    ls $dir
	    bsub -q $queue $PWD/runJob.sh $PWD $process $dir Higgs_hzpzp_UFO.tar.gz
	fi
    done
done

echo "There are "$iteration" mass points in total."
