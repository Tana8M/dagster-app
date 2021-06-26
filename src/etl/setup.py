import setuptools
import os

# GETS ENV VARIABLE FOR DAGSTER VERSION
version = os.getenv("DAGSTER_VERSION", "0.11.11")

setuptools.setup(
    name="etl",
    version="0.0.1",
    author_email="tiri.georgiou@pod-point.com",
    packages=setuptools.find_packages(
        include=['etl'], exclude=["tests"]),
    install_requires=[
        f"dagster=={version}",
        f"dagster-aws=={version}",
        f"dagster-pandas=={version}",
        "pytest",
    ],
    python_requires=">=3.8"
)