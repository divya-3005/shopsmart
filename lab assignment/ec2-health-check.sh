#!/bin/bash

INSTANCE_ID="i-074292282f5f1d0b1"

STATE=$(aws ec2 describe-instances \
  --instance-ids $INSTANCE_ID \
  --query "Reservations[0].Instances[0].State.Name" \
  --output text)

SYSTEM_STATUS=$(aws ec2 describe-instance-status \
  --instance-ids $INSTANCE_ID \
  --query "InstanceStatuses[0].SystemStatus.Status" \
  --output text 2>/dev/null)

INSTANCE_STATUS=$(aws ec2 describe-instance-status \
  --instance-ids $INSTANCE_ID \
  --query "InstanceStatuses[0].InstanceStatus.Status" \
  --output text 2>/dev/null)

echo "Instance ID: $INSTANCE_ID"
echo "State:       $STATE"

if [ "$STATE" != "running" ]; then
  echo "Health:      N/A"
elif [ "$SYSTEM_STATUS" == "ok" ] && [ "$INSTANCE_STATUS" == "ok" ]; then
  echo "Health:      [OK]"
else
  echo "Health:      [ALERT]"
fi