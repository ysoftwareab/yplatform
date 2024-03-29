# aws (Amazon Web Services)

## iam (Identity Access Management)

From a user perspective, if you were [onboarded by an admin/ops](aws-iam.md),
you may want to setup your AWS console and maybe even your shell via [aws-cli](https://github.com/aws/aws-cli/).
This would allow you to select a role in AWS console,
or to run `yp::aws-iam-login <profile-name>` in your terminal
in order to assume the credentials for a certain AWS role.

To set this up run the following from within
a repository that supports `yp::aws-iam-bootstrap` e.g. `aws*-dev-prod`:

```
~/git/yplatform/bin/aws-iam-boostrap \
  --user <your-aws-username> \
  --access-key-id <your-aws-access-key-id> \
  --secret-access-key <your-aws-secret-access-key>
```

and follow the instructions in the terminal to

* setup your AWS console
  * role shortcuts
* setup your aws-cli
  * set credentials
  * set config
