# gen_init_file.sh
Auto generate rule file for init of all declared items within items folder of openhab.
This file can be put into ..../openhab2/items folder of a linux machine
then run it using sudo sh get_init_file.sh

It will loop through all .items files and loop through all lines identifing all items. 
Then it will generate a rules file with initial values of all items.

ToDo:
I am considering adding: if (item == NULL) for each sendCommand so that the script only changes null items. 




Have fun
SySfRaMe
