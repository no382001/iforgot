#add copy to terminal
#add --keep-title

#add grouping 



#!/bin/bash

HEIGHT=30
WIDTH=15
CHOICE_HEIGHT=4
BACKTITLE="history browser"
TITLE="1st layer"
MENU="choose one of the following starting words:"

OIFS=$IFS #save original delimiter
IFS='\\\\'

n=100 #number of elements

#get the last n elements of history, invert them, and store them in his variable, delimited by \\\\
his=$( tail -$n ~/.bash_history | tac -s '\n' | awk '{print " " $0 "\\\\"}' )


uniq=()

i=1
while [ $i -ne $n ]
do  
    #dialog options format is (number1 "string1" number2 "string2" ...)
    #awk the current row
    cur=($(echo ${his[@]} | awk -v i="$i" 'FNR == i {print $0;exit}'))
    
    i=$(($i+1)) 

    #check current element's first word if it is in the unique set of elements
    #turncate to first word
    firstword=($( echo ${cur[@]} | cut -d " " -f2 ))

    #check if uniq contains firstword or not
    echo ${uniq[@]} | grep -w -q $firstword
    
    #compare stdout 
    if [ $? == 1 ]; then
        #add to set
        uniq=(${uniq[@]} $firstword)
    fi
done


un=($(echo ${uniq[@]} | wc -w))
i=1
while [ $i -ne $un ]
do
    #awk the current row
    cur=($(echo ${uniq[@]}| awk -v i="$i" ' {print $i}'))

    #add the row number
    uniqopt=(${uniqopt[@]} $i)

    #add the row content
    uniqopt=(${uniqopt[@]} $cur)

    #i++
    i=$(($i+1)) 

done

#show first dialog expect choice
CHOICE=$(dialog \
                --backtitle "$BACKTITLE" \
                --title "$TITLE" \
                --menu "$MENU" \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                ${uniqopt[@]} \
                2>&1 >/dev/tty)
clear

#show second dialog choice
HEIGHT=20
WIDTH=10
CHOICE_HEIGHT=4
BACKTITLE="history browser"
TITLE="2nd layer"
MENU="choose one of the following commands:"

#create an array of elements that match the first word
#place them in the selection menu

CHOICE=$(dialog \
                --backtitle "$BACKTITLE" \
                --title "$TITLE" \
                --menu "$MENU" \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                ${uniqopt[@]} \
                2>&1 >/dev/tty)
clear




# echo ${his[@]} | awk -v CHOICE="$CHOICE" 'FNR == CHOICE {print $0;exit}'
