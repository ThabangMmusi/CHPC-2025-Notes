#!/bin/bash

# This script will source my_sourced_file.sh and use its contents

# Source the file
source "$(dirname "$0")"/my_sourced_file.sh

# Now you can use variables and functions defined in my_sourced_file.sh

echo "Accessing MY_VARIABLE from main_script.sh: $MY_VARIABLE"

my_function

echo "Script finished."