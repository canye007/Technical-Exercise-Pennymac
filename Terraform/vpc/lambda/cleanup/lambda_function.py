import boto3
from datetime import datetime, timezone, timedelta

ec2 = boto3.client("ec2")

def lambda_handler(event, context):
    snapshots = ec2.describe_snapshots(OwnerIds=["self"])["Snapshots"]

    cutoff = datetime.now(timezone.utc) - timedelta(days=365)

    for snap in snapshots:
        if snap["StartTime"] < cutoff:
            print(f"Deleting {snap['SnapshotId']}")
            try:
                ec2.delete_snapshot(SnapshotId=snap["SnapshotId"])
            except Exception as e:
                print(f"Error: {e}")