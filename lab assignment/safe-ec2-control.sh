#!/bin/bash

INSTANCE_ID="i-074292282f5f1d0b1"
ACTION=$1

CURRENT_STATE=$(aws ec2 describe-instances \
  --instance-ids $INSTANCE_ID \
  --query "Reservations[0].Instances[0].State.Name" \
  --output text)

echo "[INFO] Current State: $CURRENT_STATE"

if [ "$ACTION" == "start" ]; then
  if [ "$CURRENT_STATE" == "running" ]; then
    echo "[SKIP] Instance is already running"
  else
    aws ec2 start-instances --instance-ids $INSTANCE_ID
  fi

elif [ "$ACTION" == "stop" ]; then
  if [ "$CURRENT_STATE" == "stopped" ]; then
    echo "[SKIP] Instance is already stopped"
  else
    aws ec2 stop-instances --instance-ids $INSTANCE_ID
  fi

else
  echo "[ERROR] Usage: ./safe-ec2-control.sh start|stop"
fi