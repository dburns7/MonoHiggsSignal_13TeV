#!/bin/bash

scriptname=`basename $0`

# name of the run
name=EFT_HHxx_scalar

## customercards
custom=EFT_HHxx_scalar_customizecards.dat 

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

########################
#Run the code-generation step to create the process directory
########################
topdir=$CARDSDIR/$name
mkdir $topdir


#Zpmassfile=inputs/input_zprime
#lastZppoint=`cat $Zpmassfile | wc -l`
#echo "There are "$lastZppoint" Zprime mass points"

chimassfile=inputs/input_chi
lastchipoint=`cat $chimassfile | wc -l`
echo "There are "$lastchipoint" chi mass points"

iteration=0
#iterZp=0

#while [ $iterZp -lt $lastZppoint ]; 
#do
#    iterZp=$(( iterZp + 1 ))  
#    Zpmass=(`head -n $iterZp $Zpmassfile  | tail -1 | awk '{print $1}'`)    
    iterchi=0

    while [ $iterchi -lt $lastchipoint ]; 
    do
	iterchi=$(( iterchi + 1 ))
#	iterZwidth=$(( iterchi + 1 ))
#        Zpwidth=(`head -n $iterZp $Zpmassfile  | tail -1 | awk -v my_var=$iterZwidth '{print $my_var}'`)
        chimass=(`head -n $iterchi $chimassfile  | tail -1 | awk '{print $1}'`) 
	
#	if (( $(echo "$Zpwidth > 0.0" | bc -l) ))
        #if [[ $Zpwidth -gt 0.0 ]]
#	then
	    iteration=$(( iteration + 1 ))

	    echo ""
#	    echo "Producing cards for Zprime mass = "$Zpmass" GeV"
	    echo "Producing cards for chi mass = "$chimass" GeV "
	    echo ""
	    newname=${name}_MChi${chimass}
#	    newname=${name}_MZp${Zpmass}_MChi${chimass}
	    mkdir $topdir/$newname
	    dir=$CARDSDIR/$name/$newname
	    sed -e 's/'$name'/'${newname}'/g' $CARDSDIR/${name}_proc_card.dat > $dir/${newname}_proc_card.dat
	    sed -e 's/MCHI/'$chimass'/g' $CARDSDIR/$custom > $dir/${newname}_customizecards.dat
#	    sed -e 's/MZP/'$Zpmass'/g' -e 's/MCHI/'$chimass'/g' -e 's/WZP/'$Zpwidth'/g' $CARDSDIR/$custom > $dir/${newname}_customizecards.dat
	    cp $CARDSDIR/run_card.dat $dir/${newname}_run_card.dat
#	fi
    done
#done

echo "There are "$iteration" mass points in total."
