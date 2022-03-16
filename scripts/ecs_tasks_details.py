"""
    Simple Python program to get all the required details of the tasks
    to execute AWS commands.

    Note :- This python code is for just demo purpose and its not perfect python code. There is scope to improve this further.
"""
import boto3
import re
import botocore.exceptions
from typing import NamedTuple

client = boto3.client('ecs')


class Container(NamedTuple):
    name: str
    runtime_id: str


class Task(NamedTuple):
    task_id: str
    service_name: str
    required_container: Container


class Cluster(NamedTuple):
    name: str
    tasks: list


def get_name_from_arn(arn: str) -> str:
    regex = r'^.*/.*/(.*)$'
    return re.match(regex, arn).group(1)


def get_task_arns(cluster_name: str, desiredStatus='RUNNING') -> list:
    try:
        response = client.list_tasks(
            cluster=cluster_name,
            desiredStatus=desiredStatus
        )
        return response['taskArns']
    except botocore.exceptions.ClientError as e:
        print("ERROR: Error fetching ECS cluster tasks.")
        raise e


def get_task_details(cluster_name: str, tasks_arn: list[str]):
    try:
        response = client.describe_tasks(
            cluster=cluster_name,
            tasks=tasks_arn
        )
        return response['tasks']
    except botocore.exceptions.ClientError as e:
        print("ERROR: Error fetching ECS cluster tasks details.")
        raise e


def get_required_container_task_details(tasks: list, required_container_name: str) -> list:
    required_container_task_details = []
    for task in tasks:
        service_name = task['group'].split(':')[1]
        task_id = get_name_from_arn(task['taskArn'])
        required_container = None
        for container in task['containers']:
            container_name = container['name']
            if container_name == required_container_name:
                runtime_id = container['runtimeId']
                container = Container(
                    container_name, runtime_id)
                required_container = container
        task = Task(task_id, service_name, required_container)
        required_container_task_details.append(task)
    return required_container_task_details


def print_aws_commands(cluster: Cluster):
    for task in cluster.tasks:
        service_name = task.service_name
        task_id = task.task_id
        container_id = task.required_container.runtime_id
        print(f"{service_name}:{task_id}:{container_id}")


def main(cluster_name: str, required_container_name):
    task_arns = get_task_arns(cluster_name)
    tasks = get_task_details(cluster_name, task_arns)
    required_container_task_details = get_required_container_task_details(
        tasks, required_container_name)
    cluster = Cluster(cluster_name, required_container_task_details)
    print_aws_commands(cluster)


if __name__ == "__main__":
    cluster_name = 'poc_ecs_container_access'
    required_container_name = 'httpd'
    main(cluster_name, required_container_name)
