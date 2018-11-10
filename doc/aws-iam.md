# aws (Amazon Web Services) iam (Identity Access Management)

## Concepts in short

* Policy
  * collection of allow/deny statements (n actions, m resources)
  * managed either by AWS or by the customer
* Role
  * collection of managed/inline policies
  * a role can be assumed by a service/user/another role
* Users
  * ~human being (should have multi factor authentication)
  * collection of managed/inline policies
  * part of groups
* Groups
  * collection of managed/inline policies
  * collection of users

**NOTE** inline policies should be considered only for **LAST-RESORT EMERGENCIES**.


## Setup

**NOTE** for security reasons, create a `dev` account and a `prod` account.
Access to the `prod` account should be limited (mainly to a CI/CD user only).

**NOTE** a 3rd account, a `user-only` account, can be used to handle only users,
while the `dev` and `prod` accounts handle anything but users.
When working with many projects, each with their own `dev` and `prod` account,
having a `user-only` account diminishes the duplication. Alternatively, the `dev` account
can act as a `user-only` stand-in account.

All users are created in a `user-only` account (except CI/CD users that go in both `dev` and `prod`)
and the only permission they have is to manage their own user resource,
and to assume a role by getting a session token.
See https://cloudonaut.io/improve-aws-security-protect-your-keys-with-ease/ .

These permissions are given by including the user in two groups

* infra-AssumeRoleG-*
* infra-ManageOwnUserG-*

Roles are created in both `dev` and `prod` accounts, and `user-only` users can assume roles in both.

Users/Groups are created in a CloudFormation stack called `infra`,
thus the policies/roles/groups are prefixed with `infra-`.


## Standardized Roles

* `infra-AdminR-*` role has FULL power over all services, but this role is **FOR EMERGENCIES ONLY**.
* `infra-OpsR-*` role has FULL power over specified services
  * this includes FULL IAM power, which means that an `infra-OpsR-*` user
    can actually assign higher permissions to themselves
  * this includes `infra-ReadR-*` role below
* `infra-ReadR-*` role has READ-ONLY power over all services

A permission for a user to assume a role can be done on account-basis 
(for example, can be an `AdminR` on dev, but `ReadR` on prod).

**NOTE** for safety reasons, a selected few are in a special `infra-PowerG-*` group,
which gives them FULL IAM power, without them needing to assume the `infra-OpsR-*` role.


## Onboarding a new user

* As an `infra-OpsR-*` (or `infar-AdminR-*` or `infra-PowerG-*`) user, create a user in the `user-only` account
  * with AWS console access (skip programmatic)
  * with temporary password
  * add them to the `infra-AssumeRoleG-*` and `infra-ManageOwnUserG-*` IAM groups
* Have the user log in
  * Go to `Services` -> `IAM`
  * Go to `Users` -> their own user
  * Go to `Security credentials`
  * Set the `Assigned MFA device`
  * `Create access key`
* Add the user to the `infra` stack by adding him to specific roles in `cfn/infra/users.js`,
  commit and push to the `infra` branch (no need to push manually, run 
  `make promote-infra` after comitting). 
* The CI/CD build of that commit will update the role(s) and their Trust Relationship
  to allow the user to assume the role(s)
* The user should now be able to
  * login in the AWS console
  * assume the role in the AWS console
  * assume a role in the CLI


### How to support support-firecloud's aws-iam-bootstrap

If you own a repository that you want to support [`aws-iam-bootstrap`](../bin/aws-iam-bootstrap),
you need the following in the root of the repository:

* a `CONST.inc` file with environment variables
* a `aws-cli.config.tpl` file with resembles `~/.aws/config`
  but can make use of `${SOME_VAR}` placeholder,
  where `SOME_VAR` is defined in `CONST.inc`
* a `aws-cli.credentials.tpl` file with resembles `~/.aws/credentials`
  but can make use of `${SOME_VAR}` placeholder,
  where `SOME_VAR` is defined in `CONST.inc`


Example of a `CONST.inc`:

```
GLOBAL_AWS_REGION=eu-west-1

DEV_AWS_ACCOUNT_ID=1234567890
DEV_AWS_ACCOUNT_NAME=myawsaccount
DEV_IAM_READ_ROLE=infra-ReadR-1234567890
```

Example of a `aws-cli.config.tpl`:

```
[default]
region = ${GLOBAL_AWS_REGION}
s3 =
  signature_version = s3v4
  max_concurrent_requests = 100
  max_queue_size = 1000
  multipart_threshold = 64MB
  multipart_chunksize = 16MB

[profile ${AWS_ACCOUNT_NAME}]
region = ${GLOBAL_AWS_REGION}
source_profile = ${AWS_ACCOUNT_NAME}

[profile ${DEV_AWS_ACCOUNT_NAME}_read]
region = ${GLOBAL_AWS_REGION}
role_arn = arn:aws:iam::${DEV_AWS_ACCOUNT_ID}:role/${DEV_IAM_READ_ROLE}
source_profile = ${AWS_ACCOUNT_NAME}
```

Example of a `aws-cli.credentials.tpl`:

```
[${AWS_ACCOUNT_NAME}]
aws_access_key_id = ${AWS_ACCESS_KEY_ID}
aws_secret_access_key = ${AWS_SECRET_ACCESS_KEY}

[${DEV_AWS_ACCOUNT_NAME}_read]
aws_access_key_id = ${AWS_ACCESS_KEY_ID}
aws_secret_access_key = ${AWS_SECRET_ACCESS_KEY}
```
