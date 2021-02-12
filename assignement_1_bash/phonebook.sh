#!/bin/bash

#Assign the DB path into a variable
#FILE=/etc/phonebook
FILE=/etc/phonebookDB.txt

args=$#
arg_option=$1
arg_name=$2
args_list=($@)

#functions implementations

#function display the DB content
function display_data(){

 echo "Phonebook Data base content"
 echo ""
 cat $FILE
 
}

#function to delete the DB file
function delete_all(){
if [ -s $FILE ]
then
#delete data in database
cat /dev/null > $FILE

echo "The DB is now empty"

else
echo "the file already empty"
fi
}

#function for check on name regex
function name_check()
{

 name_re=^[A-Za-z]+$
 
 if [[ ! $1 =~ $name_re ]];
 then
    clear
    echo "error : "
    echo "usage [name]"
    echo "ex : bash phonebook -i LinuUser 01xxxxxxxxx" 
    echo "note : you can add multiple phone number splitting them with spaces"
    echo "ex : bash phonebook -i LinuUser 01xxxxxxxxx 01xxxxxxxx ...." 
    return 1	 
else
   
    return 0
 fi

}


#function for check on name regex
function phonenumber_check(){
counter=0
ph_re=01[0-9]{9}
#check if phonenumber added later
if [[ $1 =~ $ph_re ]]
then
   return 0
fi


#check if phonenumber added on time
for (( i=2; i<$args; i++ ))
do
  if [[ ${args_list[$i]} =~ $ph_re ]];
  then
     
     ((counter=$counter+1))
  fi
done

((check=$args-2))

if [ $counter -eq $check ]
then 
 return 0
fi

return 1

}



#function write into database
function DB_write()
{
  

    echo -n "$arg_name ," >> $FILE 
      
for (( j=2; j<${args}; j++ ))
 do
 #  echo ${arg_list[$i]} >> $FILE
  echo -n "${args_list[$j]} " >> $FILE 
 
 done

  echo "  " >> $FILE 
  echo "Data added successfully"

return 0

}


#function to search for specific name in DB
function search_by_name
{

  if  grep -w -q $1 $FILE ; 
   then
    return 0
 else
   return 1
 fi

}

#function to delete a specific name and its data
function delete()
{
#check=grep -w  $arg_name $FILE 

 sed -i  -E  "/^$1 ,/d" $FILE

}


#function to take name and phone number from user
function insert (){
echo " "
echo "insert option has been selected"
read -p "Enter contact's name  : " name
read -p "Enter contact's number  "  phone_number

#name_check func call to check on name regex then check its value
name_check $name
name_regex=$?

#phonenumber_check func call to check on phone regex then check its value
phonenumber_check $phone_number
phonenumber_regex=$?

if [ $name_regex -eq 0 ] && [ $phonenumber_regex -eq 0 ]
then 

   search_by_name $name
   if [ $? -eq 0 ]
   then
   echo "sorry already exists"
   else
      echo -n "$name , " >> $FILE
      echo "$phone_number" >> $FILE
      echo " "
      echo "Data added successfully"
   fi
else
   echo "error : "
   echo "error : unavailable pattern"
   echo "usage : bash phonebook [OPTION] PATTERN[NAME] or [NAME][PHONE NUMBER]"
   echo "ex : AhmedAli 01xxxxxxxxx  01xxxxxxxxx "


fi

}





#***********************************   Main code implementation   **************************#

#check if the DB exists in the required path or not
#if yes we access it , if no we create one
clear
if [ ! -f $FILE ]
then
    touch DB
fi

#check if any arguments is passed
if [ $args -ne 0 ]
then

#check on arguments passed


    #display the whole data base option
    if [ $arg_option == -v ]
    then
	clear
	#display all func call to display DB content
	display_data 

    #delete the whole data base data
    elif [ $arg_option == -e ]
    then
	clear
	#delete all func call to delete all  DB content
       delete_all



    #insert data in data base option
    elif [ $arg_option == -i ]
    then
	clear
	#check if there are another argument passed to script
	if [ $args -gt 2 ]
	then
	   #name_check func call to check on name regex then check its value
	   name_check $arg_name
           name_regex=$?

           #name_check func call to check on name regex then check its value
	   phonenumber_check
	   phonenumber_regx=$?
 
	   #check on return and then write the value 
           if [ $name_regex -eq 0 ] && [ $phonenumber_regx -eq 0 ]
           then 
               search_by_name $arg_name
               if [ $? -eq 0 ]
               then
                  echo "Name already exists , can't add it"
               else
                  DB_write
               fi
           else
		echo "error : with input arguments "
		echo "name should be only letters from aA to zZ and phone numbers only digits 0-9"
		echo "ex : AhmedAli 01xxxxxxxxx  01xxxxxxxxx "
           fi
	else
	   echo "error : unavailable pattern"
           echo "usage : bash phonebook [OPTION] PATTERN[NAME] or [NAME][PHONE NUMBER]"
	   echo "ex : AhmedAli 01xxxxxxxxx  01xxxxxxxxx "
	   echo "but we got your back xD"
	   insert
	fi

     #delete a specific data option
     elif [ $arg_option == -d ]
      then 
          #check on the presence of argument you want to delete
         if [ $args -gt 1 ]
	 then
            search_by_name $arg_name
            if [ $? -eq 0 ]
            then
               
		delete  $arg_name 
	       echo "Name and its data has been deleted"

            else
               echo "The name you want to delete doesnot exists"
            fi
	     else

                echo "error : missing in options"
                echo "bash phonebook [options]"
                echo " "
                echo "-i  insert name and phone numbers"
                echo "-v print all contacts"
                echo "-s search by contact name"
                echo "-e delete all records"
                echo "-d delete one contact name"
         fi
 
     #search for data option
     elif [ $arg_option == -s ]
     then
	 #check on the presence of argument you want to delete
         if [ $args -gt 1 ]
         then
            search_by_name $arg_name
            if [ $? -eq 0 ]
            then
  		  
		echo "the data you search for"
		grep -w  $arg_name $FILE ;
 

            else
               echo "The name you search for doesnot exists"
             fi
         else
		echo "error : missing in options"
   		echo "bash phonebook [options]"
  	 	echo " "
   		echo "-i  insert name and phone numbers"
   		echo "-v print all contacts"
   		echo "-s search by contact name"
   		echo "-e delete all records"
   		echo "-d delete one contact name"
         fi



    else
       clear
       echo "error : unavailable options"
       echo "usage : bash phonebook [OPTION] PATTERN[NAME]| [NAME][PHONE NUMBER]"
       echo "provided options"
       echo "-i  insert name and phone numbers"
       echo "-v print all contacts"
       echo "-s search by contact name"
       echo "-e delete all records"
       echo "-d delete one contact name"
    fi

else
   clear
   echo "error : missing in options"
   echo "bash phonebook [options]"
   echo " "
   echo "-i  insert name and phone numbers"
   echo "-v print all contacts"
   echo "-s search by contact name"
   echo "-e delete all records"
   echo "-d delete one contact name"

fi


exit 0
#############################################################################################################################

