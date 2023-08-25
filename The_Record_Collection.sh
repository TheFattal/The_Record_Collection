#!/bin/bash
lines=()


#This function creates the file with the name provided by the external argument, if it's NOT exists. Also validates the input:
Create_File() {

#validation-1: checks if there are more than 1 argument:
if [[ -n "$2" ]]; then
    echo "Please provide ONE argument only!"
   exit 1
fi

local file_name="$1"
#Validation-2: Checks if an argument is provided:
if [[ -z $file_name ]]; then
    echo "Please provide file name as an argument!"
   exit 2
fi

#Validation-3: Checks if the file already exists:
if [[ -e $file_name ]] ; then
    echo "File '$file_name' already exists - let's use it! "
    return 1
fi

#Validation-4: Checks if the file name characters are valid:
  local valid='^[a-zA-Z0-9_\-\.]+$'
if ! [[ $file_name =~ $valid ]]; then
    echo "Invalid characters in the file name."
    exit 4
fi

# Create the file and massage a success message:
touch "$file_name"
echo "File '$file_name' was successfully created."

}

#This function searches the Data-Base by name:
Search_Record()
{
	read -p "what are you looking for?" recordName
	while IFS= read -r line; do
    		lines+=("$line")
	done < <(grep -i "$recordName" "$file")
	if [ "${#lines[@]}" -eq 0 ]; then
		echo "No lines containing '$recordName' found in the file."
		echo "$(date) Search Failure" >> log.txt
        	return 0
   	fi
   	for element in "${lines[@]}"; do
    		echo "$element"
	done
	echo "$(date) Search Success" >> log.txt
}

#This function prints all the Data-Base sorted: 
Print_Sorted()   {
   
   if [[ -s "$file" ]]; then
       sort -k1,1 "$file"
       echo "$(date) PrintAll Success" >> log.txt
   else 
       echo "No records in the DataBase!"
       echo "$(date) PrintAll Failure" >> log.txt
   fi
   
}


Search_by_name()
{
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
	else
		echo invalid option
		return 0
	fi
}

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
		sed -i "s/^$escaped_line/${chosenLine%,*},$quantity/" "$file"
		echo "Replacement done in $file"
	else
		echo invalid option
		return 0
	fi
	
}


#This function adds a record to the file:
Add_Record() {
local record_name
read -p "Please enter record name: " record_name

read -p "Please enter record's amount: " record_amount
#we need to search if it exists!!!


}

Menu() {
while true; do
   PS3="Select an operation: "
    options=("Add Record" "Delete Record" "Search Record" "Update Name" "Update Amount" "Print Total Amount" "Print Sorted" "Exit")

    select menu_answer in "${options[@]}"; do
        case $menu_answer in
            "Add Record")
               Add_Record
               Menu
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

#Input an Argument
file="$1"
file2="$2"
Create_File "$file" "$file2"
Menu
