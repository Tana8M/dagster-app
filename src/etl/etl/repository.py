from dagster import repository
from etl.pipelines.my_pipeline import my_pipeline, demo_pipeline
from etl.schedules.my_hourly_schedule import my_hourly_schedule
from etl.sensors.my_sensor import my_sensor


@repository
def etl_demo_repo():
    """
    The repository definition for this ppuptime Dagster repository.
    For hints on building your Dagster repository, see our documentation overview on Repositories:
    https://docs.dagster.io/overview/repositories-workspaces/repositories
    """
    pipelines = [my_pipeline, demo_pipeline]
    schedules = [my_hourly_schedule]
    sensors = [my_sensor]

    return pipelines