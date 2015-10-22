#!/bin/bash

scriptname=`basename $0`

# name of the run
name=EFT_xdxHDHc

## customercards
custom=EFT_xdxHDHc_customizecards.dat 

export PRODHOME=`pwd`
CARDSDIR=${PRODHOME}/cards

########################
#Locating the proc card#
########################
if [ ! -e $CARDSDIR/${name}_proc_card.dat ]; then
    echo $CARDSDIR/${name}_proc_card.dat " does not exist!"
    exit 1;
fi


########################
#Locating the customization 
########################
if [ ! -e $CARDSDIR/$custom ]; then
    echo $CARDSDIR/$custom " does not exist!"
    exit 1;
fi


run=run_card.dat
########################
#Locating the run card
########################
if [ ! -e $CARDSDIR/$run ]; then
    echo $CARDSDIR/$run " does not exist!"
    exit 1;
fi

extra=extramodels.dat
########################
#Locating the extramodels card
########################
if [ ! -e $CARDSDIR/$extra ]; then
    echo $CARDSDIR/$extra " does not exist!"
    exit 1;
fi

########################
#Run the code-generation step to create the process directory
########################
topdir=$CARDSDIR/$name
mkdir $topdir

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
        wz=(`head -n $iterchi $chimassfile  | tail -1 | awk -v my_var1=2 '{print $my_var1}'`)
	    iteration=$(( iteration + 1 ))
	    echo ""
	    echo "Producing cards for chi mass = "$chimass" GeV "
	    echo "Producing cards for Lambda   = "$lambda" GeV "
	    echo "Producing cards for Z width  = "$wz" GeV "
	    echo ""
	    newname=${name}_MChi${chimass}_Lambda${lambda}
	    mkdir $topdir/$newname
	    dir=$CARDSDIR/$name/$newname
	    sed -e 's/'$name'/'${newname}'/g' $CARDSDIR/${name}_proc_card.dat > $dir/${newname}_proc_card.dat
	    sed -e 's/MCHI/'$chimass'/g' -e 's/LAMBDA/'$lambda'/g' -e 's/WZ/'$wz'/g' $CARDSDIR/$custom > $dir/${newname}_customizecards.dat
	    cp $CARDSDIR/run_card.dat $dir/${newname}_run_card.dat
	    cp $CARDSDIR/extramodels.dat $dir/${newname}_extramodels.dat
    done
done

echo "There are "$iteration" mass points in total."
