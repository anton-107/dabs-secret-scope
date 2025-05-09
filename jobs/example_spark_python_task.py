#!/usr/bin/env python
# Example Python job for Databricks
# This script demonstrates how to access secrets from a secret scope

import os
from datetime import datetime
from pyspark.sql import SparkSession

# Initialize SparkSession
spark = SparkSession.builder.appName("ExampleJob").getOrCreate()

def main():
    # Get current timestamp
    now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    
    # Print job information
    print(f"Example Python job started at: {now}")
    
    # Try to access a secret (this will work when deployed on Databricks)
    try:
        # This will access the secret created by the write-secret.sh script
        import argparse
        parser = argparse.ArgumentParser()
        parser.add_argument("-s", "--scope_name", help="Name of the secret scope")
        args = parser.parse_args()
        scope_name = args.scope_name
        
        secret_value = dbutils.secrets.get(scope=scope_name, key="example-key")
        print(f"Successfully retrieved secret. First few characters: {secret_value[:3]}***")
    except Exception as e:
        print(f"Could not access secret: {str(e)}")
    
    # Create a simple DataFrame
    data = [("Job", "Example"), ("Status", "Success"), ("Time", now)]
    df = spark.createDataFrame(data, ["Category", "Value"])
    
    # Show the DataFrame
    print("Job results:")
    df.show()
    
    print("Example Python job completed successfully")

if __name__ == "__main__":
    main() 