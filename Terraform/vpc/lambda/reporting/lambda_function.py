import boto3

ec2 = boto3.client("ec2")

def lambda_handler(event, context):
    snapshots = ec2.describe_snapshots(OwnerIds=["self"])["Snapshots"]

    print(f"Total snapshots: {len(snapshots)}")

    for snap in snapshots:
        print(f"{snap['SnapshotId']} - {snap['StartTime']}")