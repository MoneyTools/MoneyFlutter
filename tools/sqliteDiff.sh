#!/bin/bash

# Function to output messages in bold
function bold_echo {
    printf "\033[1m$@\033[0m\n"
}

# Function to check if sqlite3 is installed
function check_sqlite3 {
    if ! command -v sqlite3 &> /dev/null; then
        bold_echo "Error: sqlite3 is not installed."
        exit 1
    fi
}

# Function to dump SQLite schema to a file
function dump_schema {
    DB_FILE=$1
    OUTPUT_FILE=$2
    sqlite3 "$DB_FILE" ".schema" > "$OUTPUT_FILE"
}

# Function to dump data rows of a table to a file
function dump_table_data {
    DB_FILE=$1
    TABLE_NAME=$2
    OUTPUT_FILE=$3
    sqlite3 "$DB_FILE" "SELECT * FROM $TABLE_NAME;" > "$OUTPUT_FILE"
}

# Function to compare dumped files and show only modified lines
function compare_files {
    FILE1=$1
    FILE2=$2
    TABLE_NAME=$3

    # Check if diff tool is available
    if ! command -v diff &> /dev/null; then
        bold_echo "Error: diff tool is not installed."
        exit 1
    fi

    # Compare files and capture modified lines only
    DIFF_OUTPUT=$(diff "$FILE1" "$FILE2" | awk '
        /^</ { print "\033[31m-" $0 "\033[0m" }    # Red for lines removed
        /^>/ { print "\033[32m+" $0 "\033[0m" }    # Green for lines added
    ')
    
    if [ -n "$DIFF_OUTPUT" ]; then
        bold_echo "$TABLE_NAME --------------------------------------------------"
        echo "$DIFF_OUTPUT"
        echo ""
    fi
}

# Main function to compare two SQLite databases
function compare_sqlite_databases {
    DB_FILE1=$1
    DB_FILE2=$2

    # Check if sqlite3 is installed
    check_sqlite3

    # Temporary directory to store dumped files
    TEMP_DIR=$(mktemp -d)

    # Dump schema of first database
    SCHEMA_FILE1="$TEMP_DIR/schema1.sql"
    dump_schema "$DB_FILE1" "$SCHEMA_FILE1"

    # Dump schema of second database
    SCHEMA_FILE2="$TEMP_DIR/schema2.sql"
    dump_schema "$DB_FILE2" "$SCHEMA_FILE2"

    # Compare dumped schemas
    compare_files "$SCHEMA_FILE1" "$SCHEMA_FILE2" "Schema"

    # Get list of tables from the first database
    TABLES=$(sqlite3 "$DB_FILE1" "SELECT name FROM sqlite_master WHERE type='table';")

    # Loop through each table and compare data rows
    for TABLE in $TABLES; do
        DATA_FILE1="$TEMP_DIR/data1_$TABLE.sql"
        DATA_FILE2="$TEMP_DIR/data2_$TABLE.sql"

        # Dump data rows of the table from first database
        dump_table_data "$DB_FILE1" "$TABLE" "$DATA_FILE1"

        # Dump data rows of the table from second database
        dump_table_data "$DB_FILE2" "$TABLE" "$DATA_FILE2"

        # Compare dumped data files
        compare_files "$DATA_FILE1" "$DATA_FILE2" "$TABLE"
    done

    # Clean up temporary directory
    rm -rf "$TEMP_DIR"
}

# Check if two arguments are provided
if [ $# -ne 2 ]; then
    bold_echo "Usage: ./compare_sqlite_databases.sh <path_to_database1.db> <path_to_database2.db>"
    exit 1
fi

# Run main function with provided arguments
compare_sqlite_databases "$1" "$2"

# End of script
