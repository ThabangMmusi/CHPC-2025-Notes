#!/bin/bash

# This file contains variables and functions to be sourced by other scripts

MY_VARIABLE="Hello from my_sourced_file.sh"

my_function() {
  echo "This function is called from my_sourced_file.sh"
  echo "MY_VARIABLE inside function: $MY_VARIABLE"
}