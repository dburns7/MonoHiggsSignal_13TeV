#!/bin/bash

scriptname=`basename $0`

# name of the run
name=Scalar

## customercards
custom=Scalar_customizecards.dat 

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


Zpmassfile=inputs/input_zprimemass
Zpwidthfile=inputs/input_zprimewidth
lastZppoint=`cat $Zpmassfile | wc -l`
echo "There are "$lastZppoint" Zprime mass points"

chimassfile=inputs/input_chi
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
	    echo "Producing cards for Zprime mass = "$Zpmass" GeV"
	    echo "Producing cards for Zprime width = "$Zpwidth" GeV"
	    echo "Producing cards for chi mass = "$chimass" GeV "
	    echo ""
	    newname=${name}_MZp${Zpmass}_MChi${chimass}
	    mkdir $topdir/$newname
	    dir=$CARDSDIR/$name/$newname
	    sed -e 's/'$name'/'${newname}'/g' $CARDSDIR/${name}_proc_card.dat > $dir/${newname}_proc_card.dat
	    sed -e 's/MZP/'$Zpmass'/g' -e 's/MCHI/'$chimass'/g' -e 's/WZP/'$Zpwidth'/g' $CARDSDIR/$custom > $dir/${newname}_customizecards.dat
	    cp $CARDSDIR/run_card.dat $dir/${newname}_run_card.dat
	    cp $CARDSDIR/extramodels.dat $dir/${newname}_extramodels.dat
	fi
    done
done

echo "There are "$iteration" mass points in total."
