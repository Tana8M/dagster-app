from dagster import solid, Field
import pandas as pd

@solid
def hello(_context):
    """
    A solid definition. This example solid outputs a single string.

    For more hints about writing Dagster solids, see our documentation overview on Solids:
    https://docs.dagster.io/overview/solids-pipelines/solids
    """
    return "Hello, Dagster!"

@solid(required_resource_keys={
    "s3"},
    config_schema={
    'file_key': Field(str, is_required=True, description="Path from bucket to file i.e. data/raw/smmt_raw.csv"),
    'bucket': Field(str, is_required=True, description="Bucket name i.e. data-team-staging")
}
)
def read_from_s3(context) -> pd.DataFrame:
    """read_from_s3 will load csv from s3.
    Configs:
        file_key (str): Path from bucket name to csv.
        bucket (str): Bucket name located in s3.
    Returns:
        (DataFrame): loaded csv as a pandas DataFrame.
    """
    import os
    result = os.getenv('AWS_ACCESS_KEY_ID')
    context.log.info(f"access key id - {result}")
    # Get response
    bucket_name = context.solid_config["bucket"]
    file_key = context.solid_config["file_key"]
    context.log.info(f"bucket name: {bucket_name}")
    context.log.info(f"file key: {file_key}")
    resp = context.resources.s3.get_object(
        Bucket=bucket_name, Key=file_key)
    context.log.info(f"resp: {resp}")
    # As dataframe
    df = pd.read_csv(resp['Body'])
    context.log.info(f"Columns of dataframe: {df.columns}")
    return df