
#!/bin/bash

# Set variables
START_DATE="2023-07-01"
END_DATE="2023-07-31"
OUTPUT_FILE="aws_costs.csv"

# Retrieve cost data from AWS
aws ce get-cost-and-usage --time-period Start=$START_DATE,End=$END_DATE \
    --granularity MONTHLY \
    --metrics "BlendedCost" "UnblendedCost" "UsageQuantity" \
    --group-by Type=DIMENSION,Key=SERVICE \
    > cost_data.json

# Extract relevant data from JSON (using jq for JSON parsing)
jq -r '.ResultsByTime[].Groups[] | [.Keys[0], .Metrics.BlendedCost.Amount, .Metrics.UnblendedCost.Amount, .Metrics.UsageQuantity.Amount] | @csv' cost_data.json > $OUTPUT_FILE

# Optional: Remove intermediate JSON file
rm cost_data.json

echo "AWS costs have been written to $OUTPUT_FILE"
