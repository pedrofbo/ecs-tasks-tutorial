from datetime import datetime
import uuid

from airflow import DAG
from airflow.contrib.operators.ecs_operator import ECSOperator
from airflow.models import Variable
from airflow.operators.python_operator import PythonOperator


default_args = {
    "owner": "airflow"
}

with DAG("test", default_args=default_args, schedule_interval=None,
         start_date=datetime(2021, 1, 1)) as dag:

    generate_id = PythonOperator(
        task_id="generate_id",
        python_callable=lambda: str(uuid.uuid4())
    )

    ecs_task = ECSOperator(
        task_id="ecs_task",
        cluster="ecs-tasks-tutorial",
        task_definition="ecs-tasks-tutorial",
        launch_type="FARGATE",
        overrides={
            "containerOverrides": [
                {
                    "name": "ecs-tasks-tutorial",
                    "environment": [
                        {
                            "name": "EXECUTION_ID",
                            "value": "{{ task_instance.xcom_pull(task_ids='generate_id') }}"  # noqa: E501
                        }
                    ]
                }
            ]
        },
        network_configuration={
            "awsvpcConfiguration": {
                "securityGroups": [Variable.get("security_group_id")],
                "subnets": [Variable.get("subnet_id")],
                "assignPublicIp": "ENABLED"
            }
        },
        awslogs_group="ecs-tasks-tutorial",
        awslogs_stream_prefix="tasks/ecs-tasks-tutorial"
    )

    generate_id >> ecs_task
