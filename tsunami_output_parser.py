import json
import requests
import sys

def parse_tsunami_output(tsunami_output):
    data = json.loads(tsunami_output)

    # Extract scan status, start time, and duration
    scan_status = data.get("scanStatus")
    scan_start_time = data.get("scanStartTimestamp")
    scan_duration = data.get("scanDuration")

    message = f"Scan Status: {scan_status}\nScan Start Time: {scan_start_time}\nScan Duration: {scan_duration}\n\n"

    # Extract IP addresses and their associated scan findings
    for finding in data.get("scanFindings", []):
        target_info = finding.get("targetInfo", {}).get("networkEndpoints", [])
        ip_address = target_info[0].get("ipAddress", {}).get("address")
        network_service = finding.get("networkService", {})
        port = network_service.get("networkEndpoint", {}).get("port", {}).get("portNumber")
        vulnerabilities = [finding.get("vulnerability", {})]
        for vuln in vulnerabilities:
            vul_id = vuln.get("mainId", {}).get("value")
            severity = vuln.get("severity")
            description = vuln.get("description")
            recommendation = vuln.get("recommendation")
            message += f"IP Address: {ip_address}\nOpen Port: {port}\nVulnerability ID: {vul_id}\nSeverity: {severity}\nDescription: {description}\nRecommendation: {recommendation}\n\n"

    return message

def send_to_slack(message, slack_webhook_url):
    payload = {
        "text": message
    }
    response = requests.post(slack_webhook_url, json=payload)
    if response.status_code != 200:
        print(f"Failed to send message to Slack: {response.text}")
    else:
        print("Message sent successfully to Slack!")

# Read Tsunami output from file
if len(sys.argv) < 3:
    print("Usage: python script.py <tsunami_output_file> <slack_webhook_url>")
    sys.exit(1)

tsunami_output_file = sys.argv[1]
slack_webhook_url = sys.argv[2]
with open(tsunami_output_file, 'r') as file:
    tsunami_output = file.read()

# Parse Tsunami output
parsed_output = parse_tsunami_output(tsunami_output)

# Send parsed output to Slack
send_to_slack(parsed_output, slack_webhook_url)
