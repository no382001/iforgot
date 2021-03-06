#!/bin/bash

#main cycle
OIFS=$IFS #save original delimiter
IFS='\\\\'

#get all the elements of history, invert them, and store them in this variable, delimited by \\\\
uniq=$( cat ~/.bash_history | tac -s '\n' | awk '{!seen[$0]++};END{for(i in seen) if(seen[i]>0)print i}' )

#get the first word
firstlayer=$( echo $uniq | cut -d" " -f1 | awk '{!seen[$0]++};END{for(i in seen) if(seen[i]>0)print i}' )

#format them for the menu
fn=$( echo $firstlayer | wc -l )
i=1
while [ $i -ne $fn ]
do
    cur=($(echo $firstlayer| awk -v i="$i" 'FNR == i {print $0;exit}'))

    num=$(echo $uniq | grep "^$cur*" | wc -l)

    if [ $num -lt 2 ]
    #dialog options format is (number1 "string1" number2 "string2" ...)
        then
            cur=$(echo $uniq | grep "^$cur*")
            uniqopt=(${uniqopt[@]} "$i" $(echo '|'$cur))
        else
            uniqopt=(${uniqopt[@]} "$i" $(echo n:$num'|'$cur))
    fi

    i=$(($i+1))
done

HEIGHT=30
WIDTH=70
CHOICE_HEIGHT=4
BACKTITLE="history browser"
TITLE="1st layer"
MENU=$(echo $uniq | wc -l)" grouped occurences "$(echo $firstlayer | wc -l)" 1st layer choices"

#show first dialog and expect choice
CHOICE=$(dialog \
                --backtitle "$BACKTITLE" \
                --title "$TITLE" \
                --column-separator "|" \
                --menu "$MENU" \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                ${uniqopt[@]} \
                2>&1 >/dev/tty)

choice_str=$(echo $firstlayer| awk -v i="$CHOICE" 'FNR == i {print $0;exit}')

#show second dialog choice
HEIGHT=30
WIDTH=130
CHOICE_HEIGHT=4
BACKTITLE="history browser"
TITLE="2nd layer"
MENU="choose one of the following commands:"
                                                      #maybe some fail bc they are just one word and im searching for more
secondlayer=$( echo $uniq | grep "^$choice_str*" )

#format them for the menu
secuniqopt=()
sn=($(echo ${secondlayer[@]} | wc -l))
i=1
while [ $i -ne $sn ]
do
    cur=($(echo ${secondlayer[@]}| awk -v i="$i" 'FNR == i {print $0;exit}'))
    #dialog options format is (number1 "string1" number2 "string2" ...)
    secuniqopt=(${secuniqopt[@]} $i $cur)
    i=$(($i+1)) 
done

CHOICE=$(dialog \
                --backtitle "$BACKTITLE" \
                --title "$TITLE" \
                --menu "$MENU" \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                ${secuniqopt[@]} \
                2>&1 >/dev/tty)
clear

second_choice_str=$(echo ${secondlayer[@]} | awk -v i="$CHOICE" 'FNR == i {print $0;exit}')

if [ -z "$second_choice_str" ]
    then
        echo $choice_str
    else
        echo $second_choice_str
fi
