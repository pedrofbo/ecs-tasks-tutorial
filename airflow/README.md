# Airflow server setup

To setup an Airflow server in Docker, using LocalExecutor, simply run
`./setup.sh` from within this directory. Note that this should be used
in an instance created from this project's Terraform code, since it
relies on a file that is created via the instance's "user data".

## Webserver credentials
Webserver username and password are set by default to `admin` and
`admin`. Make sure to override these before creating your stack by
exporting the environment variables `AIRFLOW_USERNAME` and
`AIRFLOW_PASSWORD`.
