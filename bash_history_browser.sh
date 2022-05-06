#!/bin/bash

#main cycle
HEIGHT=30
WIDTH=25
CHOICE_HEIGHT=4
BACKTITLE="history browser"
TITLE="1st layer"
MENU="choose one of the following starting words:"

OIFS=$IFS #save original delimiter
IFS='\\\\'

n=600 #number of elements

#get the last n elements of history, invert them, and store them in his variable, delimited by \\\\
#tail -$n
all=$( cat ~/.bash_history | sort --unique |tac -s '\n' | awk '{print $0 "\\\\"}' )

uniq=$( echo ${all[@]} )

#get the first word
firstlayer=$( echo $uniq | sed 's/|/ /' | awk '{print $1}' | sort --unique )

#fomat them for the menu
#dialog options format is (number1 "string1" number2 "string2" ...)
fn=$( echo ${firstlayer[@]} | wc -l )
i=1
while [ $i -ne $fn ]
do
    #awk the current row
    cur=($(echo ${firstlayer[@]}| awk -v i="$i" 'FNR == i {print $0;exit}'))

    uniqopt=(${uniqopt[@]} $i $cur)

    #i++
    i=$(($i+1)) 
done


#show first dialog and expect choice
CHOICE=$(dialog \
                --backtitle "$BACKTITLE" \
                --title "$TITLE" \
                --menu "$MENU" \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                ${uniqopt[@]} \
                2>&1 >/dev/tty)

CHOICE=${uniqopt[($CHOICE*2)-1]} #(choice*2)-1 transfer function to the dialog option format

#show second dialog choice
HEIGHT=30
WIDTH=130
CHOICE_HEIGHT=4
BACKTITLE="history browser"
TITLE="2nd layer"
MENU="choose one of the following commands:"

secondlayer=$( echo $uniq | grep "^$CHOICE" )

#fomat them for the menu
#dialog options format is (number1 "string1" number2 "string2" ...)

secuniqopt=()

sn=($(echo ${secondlayer[@]} | wc -l))
i=1
while [ $i -ne $sn ]
do
    #awk the current row
    cur=($(echo ${secondlayer[@]}| awk -v i="$i" 'FNR == i {print $0;exit}'))
    
    #add the (number, row)
    secuniqopt=(${secuniqopt[@]} $i $cur)
    #i++

    i=$(($i+1)) 
done

echo ${secuniqopt[@]}

CHOICE=$(dialog \
                --backtitle "$BACKTITLE" \
                --title "$TITLE" \
                --menu "$MENU" \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                ${secuniqopt[@]} \
                2>&1 >/dev/tty)
clear

echo ${secuniqopt[($CHOICE*2)-1]}