import argparse
import json
import shutil

import boto3


def notify_disk_usage(threshold: float, sns_topic: str,
                      instance_name: str, instance_id: str):
    disk = shutil.disk_usage("/")
    if disk.used / disk.total > threshold:
        message = (
            f"Disk usage of instance {instance_name} ({instance_id}) "
            f"has exceeded the threshold of {threshold * 100}%\n"
            f"Total disk space = {disk.total / 10**9:.2f} GB\n"
            f"Used disk space = {disk.used / 10**9:.2f} GB\n"
            f"Disk usage = {disk.used / disk.total * 100:.2f}%"
        )

        sns = boto3.client("sns")
        sns.publish(
            TopicArn=sns_topic,
            Message=message,
            Subject="Disk Usage Notification"
        )
        print(message)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Check whether the disk usage is above a set threshold"
    )
    parser.add_argument(
        "-c", "--config", type=str,
        help=(
            "Path to a configuration file. Must have the sns_instance, "
            "instance_name and instance_id parameters and an optional "
            "threshold parameter."
        )
    )
    args = parser.parse_args()
    with open(args.config) as f:
        config = json.load(f)

    notify_disk_usage(
        threshold=config.get("threshold") or 0.9,
        sns_topic=config.get("sns_topic"),
        instance_name=config.get("instance_name"),
        instance_id=config.get("instance_id")
    )
