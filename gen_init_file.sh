#!/bin/sh
tmpfile="init_values.tmp"

echo "Trying to delete uncomplete tmp file"
rm -f ${tmpfile}

echo "Preparing file"
echo "rule 'init_values'" >> ${tmpfile}
echo "when" >> ${tmpfile}

# here we can define what will trigger the init rule. comment/uncomment one of below
echo "\tSystem started" >> ${tmpfile}
#echo "Item InitSwitch changed to ON" >> ${tmpfile}



echo "then" >> ${tmpfile}


for filename in *.items; do
        echo "processing file:${filename}"
        echo "// from ${filename}:" >> ${tmpfile}
while read p; do
        item=$(echo $p | awk '{print $2;}')
        type=$(echo $p | awk '{print $1;}')
#       echo $type
        case "$type" in
                Switch)
                        echo "\t${item}.sendCommand(Off)" >> ${tmpfile}
                ;;
                String)
                        echo "\t${item}.sendCommand('')" >> ${tmpfile}
                ;;
                Number)
                        echo "\t${item}.sendCommand('0')" >> ${tmpfile}
                ;;
                Dimmer)
                        echo "\t${item}.sendCommand('0')" >> ${tmpfile}
                ;;
                Contact)
                        echo "\t${item}.sendCommand(CLOSED)" >> ${tmpfile}
                ;;
                "Group"*)
                        #echo "Group contains items. So Groups should not be initilized"
                ;;
                "Color")
                        echo "\t${item}.sendCommand('0,0,0')" >> ${tmpfile}
                ;;
                "//"*)
                        #echo "Don't process comments"
                ;;
                "")
                        #echo "Don't process empty lines"
                ;;
                *)
                        echo "${item} - unknown type: ${type}"
        esac

done <${filename}

done

echo "end" >> ${tmpfile}

echo "Moving tmp file into rule folder. comment/uncomment at your desire"
read -p "Do you wish to move tmp file to rules folder and rename to .rules?" yn
    case $yn in
        [Yy]* )
                mv ${tmpfile} ../rules/init_system.rules
                echo "Please wait"
                sleep 10s
                echo "Rule loading check:"
                cat /var/log/openhab2/openhab.log | grep 'init_system.rules' | tail -1
                break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
