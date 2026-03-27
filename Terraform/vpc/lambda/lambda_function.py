import boto3

ec2 = boto3.client('ec2')

def lambda_handler(event, context):
    print("Running snapshot cleanup...")

    snapshots = ec2.describe_snapshots(OwnerIds=['self'])['Snapshots']

    for snapshot in snapshots:
        print(f"Found snapshot: {snapshot['SnapshotId']}")

    return {"status": "completed"}