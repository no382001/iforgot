#!/bin/bash



#main cycle
programdone=0
while [ $programdone -ne 1 ]
do

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
    all=$( tail -$n ~/.bash_history | tac -s '\n' | awk '{print $0 "\\\\"}' )

    uniq=$( echo ${all[@]} | sort --unique )

    firstlayer=$( echo $uniq | sed 's/|/ /' | awk '{print $1}' | sort --unique )

    #fomat them for the menu
    #dialog options format is (number1 "string1" number2 "string2" ...)
    fn=$( echo ${firstlayer[@]} | wc -l )
    i=1
    while [ $i -ne $fn ]
    do
        #awk the current row
        cur=($(echo ${firstlayer[@]}| awk -v i="$i" 'FNR == i {print $0;exit}'))
        
        #add the row number
        uniqopt=(${uniqopt[@]} $i)

        #add the row content
        uniqopt=(${uniqopt[@]} $cur)

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
    for k in ${secondlayer[@]}
    do
        #add the (number, row)
        secuniqopt=(${secuniqopt[@]} $i $k)
        
        #i++
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

    echo "-------------------"
    echo ${secondlayer[$CHOICE-1]}
    exit
done