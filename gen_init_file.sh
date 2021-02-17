#!/bin/bash


tmpfile="/tmp/init_values.tmp"
openhab_logfile="/var/log/openhab2/openhab.log"
#openhab_logfile="/var/log/openhab2/events.log"
openhab_conf="/etc/openhab2/"

cd ${openhab_conf}/items


echo "Trying to delete uncompleted tmp file"
rm -f ${tmpfile}


echo -e "Preparing file\n\n"
echo "rule 'init_values'" >> ${tmpfile}
echo "when" >> ${tmpfile}


# here we can define what will trigger the init rule. comment/uncomment one of below
echo -e "\tSystem started" >> ${tmpfile}
#echo -e "\tItem InitSwitch changed to ON" >> ${tmpfile}


echo "then" >> ${tmpfile}


for filename in *.items; do
        echo -e "Processing file: ${filename}"
        echo -e "\n\t// from ${filename}:" >> ${tmpfile}


    #Change lineendlings from CRLF to LF. This way the script does not complain about empty lines when the itemfile has CRLF line endings
    tr -d '\015' < $filename > /tmp/"$filename""_lf"
    filename="/tmp/"$filename"_lf"

    while IFS="" read -r line || [ -n "$line" ]; do #Add newlines to each file so every item is proccessed even if the items file doesn't have a newline at the end
#               [[ -z "$line" ]] && continue
        item=$(echo $line | awk '{print $2}')
        type=$(echo $line | awk '{print $1}')
#               echo "Item: ${item} - Type: ${type}"
        case "$type" in
                "Switch")
                        echo -e "\t${item}.sendCommand(OFF)" >> ${tmpfile}
                ;;
                "String")
                        echo -e "\t${item}.sendCommand('')" >> ${tmpfile}
                ;;
                "Number"*) #for example: Number:Dimensionless
                        echo -e "\t${item}.sendCommand('0')" >> ${tmpfile}
                ;;
                "Dimmer")
                        echo -e "\t${item}.sendCommand('0')" >> ${tmpfile}
                ;;
                "Contact")
                        echo -e "\t${item}.sendCommand(CLOSED)" >> ${tmpfile}
                ;;
                "Group"*)
                        #echo "Group contains items. So Groups should not be initilized"
                ;;
                "Color")
                        echo -e "\t${item}.sendCommand('0,0,0')" >> ${tmpfile}
                                ;;
                "DateTime")
                        #What about DateTime?
                ;;
                "Player")
                                echo -e "\t${item}.sendCommand(PAUSE)" >> ${tmpfile}
                ;;
                "//"*|"/*"*|"*"*)
#                        echo "Don't process comments"
                ;;
                ""|" ")
#                        echo "Don't process empty lines"
                ;;
                *)
                        echo -e "\e[31m${item} - unknown type: ${type}\e[0m"
        esac

        done <${filename}

        rm $filename

done

echo "end" >> ${tmpfile}


echo -e "\n\nDo you wish to move tmp file to rules folder and rename it to init_systems.rules? (Y/N)"
read -e awnser
    case $awnser in
        [Yy]* )
            mv ${tmpfile} ../rules/init_system.rules
            echo "Please wait"
            sleep 10s
            echo "Rule loading check:"
            cat /var/log/openhab2/openhab.log | grep 'init_system.rules' | tail -1
            break;;
        [Nn]* )
                echo "Your file is in ${tmpfile}"
                exit;;
        * ) echo "Please answer yes or no.";;
    esac

exit 0
