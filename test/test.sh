#!/usr/bin/env bash

read -p "Enter the input: " num1

if [ -z "$num1" ]
then
    echo "The number is empty"
    exit 0
fi

if [ "${num1}" -eq 1 ]
   echo "Number entered is 1"
else
   echo "Not equal to One !!"
fi