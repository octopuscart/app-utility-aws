
call terraform init

call terraform plan -out=ssm-write-out 

call terraform apply ssm-write-out

