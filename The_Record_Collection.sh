#!/bin/bash

#This function creates the file with the name provided by the external argument:
Create_File() {
# Check if an argument is provided
if [[ -z "$1" ]]; then
    echo "Please provide file name as an argument!"
   exit 1
fi

local file_name="$1"
# Check if the file already exists
if [[ -e "$file_name" ]] ; then
    echo "File '$file_name' already exists."
    exit 2
fi


# Create the file
touch "$file_name"

echo "File '$file_name' created."
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
file="$1"
Create_File "$file"
Menu

