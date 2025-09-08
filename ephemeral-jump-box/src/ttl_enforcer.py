import boto3
import os
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

ec2_client = boto3.client('ec2')


def lambda_handler(event, context):
    logger.info(f"Received event: {event}")

    # Parse event for instance_id and shutdown_method
    instance_id = event.get('instance_id')
    shutdown_method = event.get('shutdown_method', 'stop').lower()

    if not instance_id:
        logger.error("Missing 'instance_id' in event")
        return {"status": "error", "message": "Missing instance_id"}

    if shutdown_method not in ['stop', 'terminate']:
        logger.error(f"Invalid 'shutdown_method': {shutdown_method}")
        return {"status": "error", "message": "Invalid shutdown_method"}

    try:
        if shutdown_method == 'terminate':
            logger.info(f"Terminating instance: {instance_id}")
            response = ec2_client.terminate_instances(
                InstanceIds=[instance_id])
        else:
            logger.info(f"Stopping instance: {instance_id}")
            response = ec2_client.stop_instances(InstanceIds=[instance_id])

        logger.info(f"API Response: {response}")
        logger.info(f"Action completed for instance: {instance_id}")
        return {"status": shutdown_method, "instance": instance_id}

    except Exception as e:
        logger.error(f"Error processing instance {instance_id}: {str(e)}")
        return {"status": "error", "message": str(e)}
