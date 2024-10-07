@echo off
REM Build the TypeScript project
@REM call npm run build

REM Build the SAM application
@REM call sam build

REM Create the deployment package
copy ..\app-utility\dist\function.zip temp\function.zip

REM Initialize Terraform
call terraform init

REM Apply Terraform configuration
call terraform apply -auto-approve