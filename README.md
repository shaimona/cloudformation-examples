# cloudformation-examples

This is a collection of cloudformation template examples.

Terraform directory:

           vpc.tf : Create AWS VPC
           
            variables.tf : Showing that you can use variables with terraform.


**AWS CloudFormation StackSets Templates**
CloudFormation StackSets enable an Admin account to deploy/create CloudFormation
stacks in multiple regions and multiple accounts. In order for StackSets to work,
it require a role to be created in the target accounts another one in Admin account.


For more information [CloudFormation StackSets](http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/stacksets-concepts.html)


AWSCloudFormationStackSetAdministrationRole.yaml template create the role in Admin account


AWSCloudFormationStackSetExecutionRole.yaml template create role in the target account


**Setup**
Admin Account: Run AWSCloudFormationStackSetAdministrationRole.yaml in the admin account
`aws cloudformation create-stack --stack-name <stack_name> --template-body <template_location>`

Target Accounts: Run AWSCloudFormationStackSetExecutionRole.yaml in the target account
`aws cloudformation create-stack --stack-name <stack_name> --template-body <template_location>
--parameters ParameterKey=AdminAccountNumber,ParameterValue=<AdminAccountNumber>`
