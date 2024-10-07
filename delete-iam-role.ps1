# PowerShell script to detach policies and delete IAM role

$roleName = "lambda-role-youtube-metadata"

# List attached policies
$attachedPolicies = aws iam list-attached-role-policies --role-name $roleName | ConvertFrom-Json

# Detach each attached policy
foreach ($policy in $attachedPolicies.AttachedPolicies) {
    aws iam detach-role-policy --role-name $roleName --policy-arn $policy.PolicyArn
}

# List inline policies
$inlinePolicies = aws iam list-role-policies --role-name $roleName | ConvertFrom-Json

# Delete each inline policy
foreach ($policyName in $inlinePolicies.PolicyNames) {
    aws iam delete-role-policy --role-name $roleName --policy-name $policyName
}

# Delete the IAM role
aws iam delete-role --role-name $roleName