import boto3
import os

ec2 = boto3.client("ec2")
sns = boto3.client("sns")

SNS_TOPIC_ARN = os.environ.get("SNS_TOPIC_ARN")


def lambda_handler(event, context):
    print("Generating snapshot report...")

    try:
        snapshots = ec2.describe_snapshots(OwnerIds=["self"])["Snapshots"]

        total = len(snapshots)
        report_lines = [f"Total snapshots: {total}\n"]

        for snap in snapshots:
            line = f"{snap['SnapshotId']} - {snap['StartTime']}"
            report_lines.append(line)

        report_message = "\n".join(report_lines)

        print("Sending report to SNS...")

        sns.publish(
            TopicArn=SNS_TOPIC_ARN,
            Subject="EC2 Snapshot Report",
            Message=report_message
        )

        print("Report sent successfully")

        return {
            "status": "success",
            "total_snapshots": total
        }

    except Exception as e:
        print(f"ERROR: {str(e)}")

        return {
            "status": "error",
            "message": str(e)
        }