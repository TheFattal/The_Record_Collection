function printSortedCollection() {
    echo "Printing the collection in a sorted manner."

    # Check if the records file exists
    if [ ! -f "records.txt" ]; then
        echo "No records in the database."
        echo "Task completed."
        return
    fi

    # Sort and print the records from the records file
    sort -k1,1 "records.txt"

    # Record the action in the log
    echo "$(date): Printed sorted collection." >> log.txt

    echo "Task completed."
}

printSortedCollection

