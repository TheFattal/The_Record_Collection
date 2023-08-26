#!/bin/bash

#Global variables:
lines=()

#This function creates the DB and LOG files with the name provided by the external argument, if it's NOT exists. Also validates the argument input:
Create_Files() {

#validation-1 --- checks if there are more than 1 argument:
if [[ -n "$2" ]]; then
    echo "Please provide ONE argument only!"
   exit 1
fi

local file_name="$1"
#Validation-2 --- Checks if an argument is provided:
if [[ -z $file_name ]]; then
    echo "Please provide file name as an argument!"
   exit 2
fi

#Validation-3 --- Checks if the file already exists - and creates log file if necessary:
if [[ -e $file_name ]] ; then
    echo "The DB file '$file_name' already exists - let's use it! "
    declare -g log_file_name="${file_name}_log"
    if [ -e "$log_file_name" ]; then
       echo "And it's log file '$log_file_name' exists too!"
    else
       touch "$log_file_name"
       echo "A log file '$log_file_name' was successfull created"
    fi
    return 1
fi

#Validation-4 --- Checks if the file name characters are valid:
  local valid='^[a-zA-Z0-9_\-\.]+$'
if ! [[ $file_name =~ $valid ]]; then
    echo "Invalid characters in the file name."
    exit 4
fi

# Create the file and the log file, and massage a success message:
touch "$file_name"
declare -g log_file_name="${file_name}_log"

touch "$log_file_name"
echo "DB File '$file_name' and log file '$log_file_name' were successfully created."
}

#This function searches the Data-Base by record name:
Search_Record()
{
	read -p "what are you looking for?" recordName
	while IFS= read -r line; do
    		lines+=("$line")
	done < <(grep -i "$recordName" "$file")
	if [ "${#lines[@]}" -eq 0 ]; then
		echo "No lines containing '$recordName' found in the file."
		echo "$(date) Search Failure" >> "$log_file_name"
        	return 0
   	fi
   	for element in "${lines[@]}"; do
    		echo "$element"
	done
	echo "$(date) Search Success" >> "$log_file_name"
}

#This function prints all the Data-Base sorted: 
Print_Sorted()   {
   
   if [[ -s "$file" ]]; then
       sort -k1,1 "$file"
       echo "$(date) PrintAll Success" >> "$log_file_name" 
 
       # Writes all the Sorted Records to the log file:
       sorted_file=$(sort -k1,1 "$file")
       date_prefix=$(date)
       modified_text=$(echo "$sorted_file" | awk -v date="$date_prefix" '{print date, $0}')
       echo "$modified_text" >> "$log_file_name"

   else 
       echo "No records in the DataBase!"
       echo "$(date) PrintAll Failure" >> "$log_file_name"
   fi
   
}

#The function calculates the TOTAL amount of records in the Data-Base:
Print_Total_Amount() 
{   
    #Calculets total amount - and print the outcome:
    total_quantity=$(awk '{n += $NF}; END{print n}' $file)
    if [[ total_quantity -gt 0 ]]; then
        echo "The records TOTAL AMOUNT is: $total_quantity"
        echo "$(date) PrintAmount Success" >> "$log_file_name"
        echo "$(date) PrintAmount $total_quantity" >> "$log_file_name"
    else
        echo "The are NO records in the Data-Base!"
        echo "$(date) PrintAmount Success" >> "$log_file_name"
        echo "$(date) PrintAmount $total_quantity" >> "$log_file_name"
     fi   
}


Search_by_name()
{ 
        for ((i=0; i<${#lines[@]}; i++)); do
        my_array[$i]=0
        done
	recordName="$1"
	while IFS= read -r line; do
    		lines+=("$line")
	done < <(grep -i "$recordName" "$file")
	if [ "${#lines[@]}" -eq 0 ]; then
		echo "No lines containing '$recordName' found in the file."
        	return 0
   	fi
}

Search_select()
{
	PS3="Select a line: "
	select selected_line in "${lines[@]}"; do
         if [ -n "$selected_line" ]; then
             	echo "Selected line: $selected_line"
               	chosenLine="$selected_line"
               	return 1
         else
               	echo "Invalid selection. Please choose a valid line."
               	chosenLine=""
               	return 0
        fi
       	done

}


#This function RENAMES a sfecific record name:
Update_Name()
{
	read -p "Hi which record would you like to rename? " recordName
	Search_by_name $recordName
       	Search_select
       	if [ $? -eq 1 ]; then
		read -p "What would you like the new name to be? " newName
        	IFS=',' read -ra oldName <<< "$chosenLine"
        	sed -i "s/^${oldName[0]},/${newName},/" "$file"
       		echo "Replacement done in $file"
       		echo "$(date) UpdateName Success" >> "$log_file_name"
	else
		echo invalid option
		echo "$(date) UpdateName Failure" >> "$log_file_name"
		return 0
	fi
}

#This function CHANGES QUANTITY of a sfecific record:
Update_Amount()
{
        read -p "Please enter record name: " recordName
        Search_by_name $recordName
       	Search_select
       	if [ $? -eq 1 ]; then
       		#echo the line is $chosenLine
 		read -p "Please enter new record's amount: " quantity
 		escaped_line=$(sed 's/[\/&]/\\&/g' <<< "$chosenLine")
		# Replace the line with the new number using sed
		sed -i "s/^$escaped_line/${chosenLine%,*}, $quantity/" "$file"
		echo "Replacement done in $file"
		echo "$(date) UpdateName Success" >> "$log_file_name"
	else
		echo invalid option
		echo "$(date) UpdateAmount Failure" >> "$log_file_name"
		return 0
	fi
	
}


#This function adds a record to the file:
Add_Record() {
local record_name
read -p "Please enter a new record name you would like to add: " record_name
read -p "Please enter the record's amount: " record_amount
#Search for resaults and show the selections in a menu:

Search_by_name $record_name
find_lines_length=${#lines[@]}
if [[ find_lines_length -ge 1 ]]; then

lines+=("ADD THE SEARCH: $record_name, $record_amount")
echo "Typing lines:"
for item in "${lines[@]}"; do
    echo "$item"
done

PS3="Select a line: "
	select selected_line in "${lines[@]}"; do
	  selected_number=$REPLY
         if [ -n "$selected_line" ]; then
             	echo "Selected line: $selected_line"
               	chosenLine="$selected_line"
               	break
         else
               	echo "Invalid selection. Please choose a valid line."
               	echo "$(date) Insert Failure" >> "$log_file_name"
               	chosenLine=""
        fi
       	done
       	# The case of Adding the current search to the DB, instead of updating quantity:
       	desired_value=$(( $find_lines_length + 1 ))
       	if [ $REPLY -eq $desired_value ]; then
       	  echo "$record_name, $record_amount" >> $file
	  echo "A new record was made successfuly in the Data-base!"
	  echo "$(date) Insert Success" >> "$log_file_name"
	  return 0
       	fi
             		
 	#Updating the record amount after choosing selection: 	
 	escaped_line=$(sed 's/[\/&]/\\&/g' <<< "$chosenLine")
	# Replace the line with the new number using sed
	sed -i "s/^$escaped_line/${chosenLine%,*}, $record_amount/" "$file"
	echo "Amount replacement was done in $file"
	echo "$(date) UpdateAmount Success" >> "$log_file_name"
	
#If there were NO search resault at all, add the new record to the DB:		
else 
  	       echo "$record_name, $record_amount" >> $file
	       echo "A new record was made successfuly in the Data-base!"
	       echo "$(date) Insert Success" >> "$log_file_name"	       

fi
}

#This function removes a record to the file:
Delete_Record() {
local record_name
read -p "Please enter the record name you would like to REMOVE: " record_name
read -p "Please enter the record's new amount: " record_amount
chosenLine=0
Search_by_name $record_name
find_lines_length=${#lines[@]}
if [[ find_lines_length -ge 1 ]]; then
echo "lines number are $find_lines_length"

lines+=("ADD THE SEARCH: $record_name, $record_amount")
PS3="Select a line: "
	select selected_line in "${lines[@]}"; do
	  selected_number=$REPLY
         if [ -n "$selected_line" ]; then
             	echo "Selected line: $selected_line"
               	chosenLine="$selected_line"
               	break
         else
               	echo "Invalid selection. Please choose a valid line."
               	chosenLine=""
        fi
       	done
       	echo "lines length: $find_lines_length , selected num: $selected_number , Reply: $REPLY"
       	desired_value=$(( $find_lines_length + 1 ))
       	
             		
 		
 	escaped_line=$(sed 's/[\/&]/\\&/g' <<< "$chosenLine")
	# Replace the line with the new number using sed
	sed -i "s/^$escaped_line/${chosenLine%,*}, $record_amount/" "$file"
	echo "Amount replacement was done in $file"	
else 
  	       echo "$record_name, $record_amount" >> $file
	       echo "A new record was made successfuly in the Data-base!"	       

fi


}

Menu() {
while true; do
   PS3="Select an operation: "
    options=("Add Record" "Delete Record" "Search Record" "Update Name" "Update Amount" "Print Total Amount" "Print Sorted" "Exit")

    select menu_answer in "${options[@]}"; do
        case $menu_answer in
               "Add Record")
                Add_Record     
                ;;
               "Delete Record")
                Delete_Record
                ;;
               "Search Record")
                Search_Record
                ;;
               "Update Name")
                Update_Name
                ;;
               "Update Amount")
                Update_Amount
                ;;
               "Print Total Amount")
                Print_Total_Amount
                ;;
                "Print Sorted")
                Print_Sorted
                ;;
                 "Exit")
                echo "GoodBye!"
                  exit 0
                ;;
            *)
                echo "Invalid choice. Please select a valid option."
                ;;
        esac
      
        break  # Exit the inner select loop to display the menu again
    done
done
}

#Input Arguments:
file="$1"
file2="$2"
#Call Create_Files function:
Create_Files "$file" "$file2"
#Running the Menu:
Menu
