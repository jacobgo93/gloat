#!/bin/bash

# Get the list of IP addresses passed as arguments
IP_LIST="$@"

# Run Tsunami scan for each IP address
for IP in $IP_LIST; do
    echo "Running Tsunami scan for IP: $IP"
    java -cp tsunami.jar:plugins/* -Dtsunami-config.location=tsunami.yaml com.google.tsunami.main.cli.TsunamiCli --ip-v4-target="$IP" --scan-results-local-output-format=JSON --scan-results-local-output-filename=/usr/tsunami/logs/tsunami-output-$IP.json
    
    # Run Python script to parse the output for each IP address
    echo "Parsing Tsunami output for IP: $IP"
    python3 /usr/tsunami/tsunami_output_parser.py /usr/tsunami/logs/tsunami-output-$IP.json
done

