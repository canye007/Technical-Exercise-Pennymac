# Lambda Function Monitoring Strategy
 Overview
Comprehensive monitoring of the EC2 Snapshot Cleanup Lambda function using AWS CloudWatch, including metrics, logs, alarms, and dashboards.

1. CloudWatch Logs
2. Log Structure

 Log Levels
- DEBUG: Detailed operation information (enable only in development)
- INFO: Normal operation events (default)
- WARNING: Non-critical issues (rate limiting, missing data)
- ERROR: Failed operations (deletion failures, API errors)
- CRITICAL: Application-breaking issues (unrecoverable errors)

##Log Groups & Streams
Log group: /aws/lambda/ec2-snapshot-cleanup-snapshot-cleanup
Log streams: 
- 2024/01/15/[$LATEST] Sample
- 2024/01/14/[$LATEST] Sample

2. CloudWatch Metrics
AWS/Lambda Namespace Metrics

Metric	              Description  	                                 Alarm Threshold
Invocations	             Number of Lambda executions	                >1 per day (alert if 0)
Errors	                 Number of failed executions	                >0 (immediate alert)
Duration	                Execution time in milliseconds	            > 240,000 ms (4 minutes)
Throttles	                Number of throttled executions	            >0
ConcurrentExecutions	    Number of concurrent executions	             >1
DeadLetterErrors	        Messages sent to DLQ	                      >0 (if configured)

Custom Metrics (Snapshots Namespace)

Metric	               Description	                         Collection Method
SnapshotsFound	          Total snapshots in account	              Count from describe_snapshots
SnapshotsOld	            Snapshots older than retention	          Filtered count
SnapshotsDeleted	        Successfully deleted	                    Count from successful deletions
DeletionErrors	           Failed deletions	                        Count from failed deletions
DeletionDuration	         Time to process all deletions	           Start to end time


Monitoring Dashboard Screenshots & KPIs

Success Rate: >99% of snapshots deleted successfully

Deletion Count: Average 50-200 snapshots deleted per day
Execution Time: <60 seconds (normal), <300 seconds (peak)
Error Rate: <1% of total executions
Coverage: 100% of snapshots >365 days identified

Service Level Objectives (SLOs)

Availability: 99.9% (execution daily)
Accuracy: 100% (no deletion of recent snapshots)
Timeliness: Daily execution within 5 minutes of schedule
Data Freshness: Logs available within 5 minutes of execution
