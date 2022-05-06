#!/bin/bash

HEIGHT=30
WIDTH=100
CHOICE_HEIGHT=4
BACKTITLE="history browser"
TITLE="choose a command"
MENU="Choose one of the following options:"

OIFS=$IFS #save original delimiter
IFS='\\\\'

n=100 #number of elements

#get the last n elements of history, invert them, and store them in his variable, delimited by \\\\
his=$( tail -$n ~/.bash_history | tac -s '\n' | awk '{print " " $0 "\\\\"}' )

i=1
while [ $i -ne $n ]
do  
    #dialog options format is (number1 "string1" number2 "string2" ...)

    #awk the current row
    cur=($(echo ${his[@]} | awk -v i="$i" 'FNR == i {print $0;exit}'))
    
    #add the row number
    opt=(${opt[@]} $i)

    #add the row content
    opt=(${opt[@]} $cur)

    i=$(($i+1))
done

CHOICE=$(dialog \
                --backtitle "$BACKTITLE" \
                --title "$TITLE" \
                --menu "$MENU" \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                ${opt[@]} \
                2>&1 >/dev/tty)
clear
echo ${his[@]} | awk -v CHOICE="$CHOICE" 'FNR == CHOICE {print $0;exit}'
