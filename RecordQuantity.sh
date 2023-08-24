function printTotalQuantity() {
    echo "Printing total quantity of records."

    total_quantity=0

    # Check if the records file exists
    if [ ! -f "records.txt" ]; then
        echo "No records file found."
        echo "Task completed."
        return
    fi

    # Loop through the records and calculate total quantity
    while IFS= read -r line; do
        name=$(echo "$line" | awk '{print $1}')
        quantity=$(echo "$line" | awk '{print $2}')
        total_quantity=$((total_quantity + quantity))
        echo "$name, $quantity"  # Print the record name and quantity separated by a comma
    done < "records.txt"

    if [ "$total_quantity" -gt 0 ]; then
        echo "Total number of records: $total_quantity"
    else
        echo "No records in the database."
    fi

    # Record the action in the log
    echo "$(date): Printed total quantity: $total_quantity" >> log.txt

    echo "Task completed."
}
printTotalQuantity
