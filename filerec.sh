#!/bin/bash
#############save the file's name in file_name
file_name="$1"
chosenLine=""
lines=()
############search function, input: name of a record, output: line that has the name
Search_Record()
{
	recordName=$1
	while IFS= read -r line; do
    		lines+=("$line")
	done < <(grep -i "$recordName" "$file_name")
	if [ "${#lines[@]}" -eq 0 ]; then
		echo "No lines containing '$recordName' found in the file."
        	return 0
   	fi
   	return 1
}

Update_Name()
{
	read -p "Hi whitch name do you want to update? " old_text
	line= search_Record $old_text
	read -p "what do you want the new name to be? " new_text
	echo **** old gets this $old_text *****
	echo **** new gets $new_text *****
	echo this is the line $line
	IFS=',' read -ra $old_text <<< "$line"
	
	if($line); then
		sed -i "s/$old_text/$new_text/g" "$file_name"
		echo "Replacement done in $file_name"
	fi
}

Update_Amount()
{
        read -p "Please enter record name: " recordName
        Search_Record $recordName
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
       	
	read -p "Please enter record's amount: " recordAmount
	recordName=$1
	recordAmount=$2
	
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
            	read -p "what are you looking for?" recordName
                Search_Record $recordName
                echo the line is $chosenLine
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
file="$1"
Menu
