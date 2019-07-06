# cfn

## Foreword - personal note from Andrei Neculau

CloudFormation, the way AWS advertises its usage, is way suboptimal, driving
people into writing hundreds if not thousands of lines of JSON, by hand, e.g.
https://github.com/widdix/aws-cf-templates/blob/master/wordpress/wordpress-ha.yaml .

Whenever JSON is short of logic
(of course it's short of logic, it's a structure format and a serializing standard!),
CloudFormation comes up with **parameters**, **conditions**, **mappings** and **functions** (see link in the "Refs" section)
to allow people to join strings, do substitutions, etc.

Whenever that is not enough, they push users into using [`Custom resources`](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/template-custom-resources.html)
i.e. deploying lambdas out-of-band, and calling them without any tracing,
literally making you build your own AWS CloudFormation layer.

The latest "improvement" from AWS is that they have added YAML support, making me to conclude that
AWS doesn't want to, or just cannot see the elephant in the room.

The AWS users are also in the same room, because they don't see the forest behind the trees.
They only thing they seem to do is come up with DSLs that add syntactic sugar.

The Google Cloud Platform has the solution, which is crazily simple:
run code to generate the "infra as code" configuration.
They do that via a templating framework called Jinja,
or via vanilla Python code that outputs YAML.
It's not that they have invented electricity, but they advertise it on their frontpage,
while AWS doesn't even mention it.

And this is what we do with CloudFormation as well.
We run JavaScript modules, that output partials,
which are then deep merged to form the final CloudFormation Stack template.

This has a few striking benefits, like:

* code always runs locally before CloudFormation is executed
* validation (syntax and some semantics) happens before CloudFormation is executed
* manual validation and inspection can be done via local JSON diffs
* ability to reference other stacks' variables, even if they are in other AWS accounts
* ability to reference any AWS data like AMI ID, or AWS Managed policy
* no need for CloudFormation **parameters**, **conditions**, **mappings**, **functions**
  * exception: `Ref` and `GetAtt` functions, which is sensible


## Overview of a bootstrapped repo

```
.
+-- cfn
    +-- env-web
        +-- s3.web.cfn.js
        +-- kms.web.cfn.js
    +-- infra
        +-- iam.cfn.js
    +-- .gitignore          ~  ../support-firecloud/repo/cfn/tpl.gitignore
    +-- Makefile            ~  ../support-firecloud/repo/cfn/tpl.Makefile
    +-- env-web.cfn.js      ~  ../support-firecloud/repo/cfn/tpl.stack-stem.cfn.js
    +-- env-web.inc.mk      ~  ../support-firecloud/repo/cfn/tpl.stack-stem.inc.mk
    +-- infra.cfn.js        ~  ../support-firecloud/repo/cfn/tpl.stack-stem.cfn.js
    +-- infra.inc.mk        ~  ../support-firecloud/repo/cfn/tpl.stack-stem.inc.mk
```

Above is an example of a folder structure in a repo with a `cfn` folder,
holding 2 stack templates: `env-web` and `infra`.

Each subfolder has `*.cfn.js` files that export partial CloudFormation templates.
By default, thanks to the `env-web.cfn.js` for instance,
they will all get deep merged to produce the final template.

The difference is that the `infra` stack is universal, 1 per AWS account,
while the `env-web` stack is per environment, n per AWS account.


## Bootstrapping a repo with AWS CloudFormation templates

```shell
path/to/support-firecloud/bin/repo-cfn-boostrap --stack-stem env-web
path/to/support-firecloud/bin/repo-cfn-boostrap --stack-stem infra
```


## General structure of the `path/to/repo/cfn` folder

* `/Makefile` drives the build in an abstract manner
* `/<stack-stem>.inc.mk` implements a few specific things required by the abstract Makefile, as well as
  * `<stack-stem>-lint` extra linting function called before generating the template/change-set
  * `<stack-stem>-pre` function called before generating the template/change-set
  * `<stack-stem>-pre-exec` function called after generating the template/change-set, but before executing it
  * `<stack-stem>-post-exec` function called after executing the template/change-set
  * `<stack-stem>-pre-rm` function called before tearing down the stack
  * `<stack-stem>-post-rm` function called after tearing down the stack
  * these targets allow us to execute actions outside of CloudFormation limitations/flaws
    * e.g. Amazon Elastic Transcoder doesn't have CloudFormation support, but we can make calls
      to create/update or delete one in the `<stack-stem>-post-exec` and `<stack-stem>-post-rm` functions
* `/<stack-stem>.cfn.js` is the JavaScript module that gets called to output the CloudFormation template as JSON
  * `/<stack-stem>/*.cfn.js` are JavaScript modules that get called to output partial CloudFormation templates as JSON
  It depends on the `/<stack-stem>cfn.js` code,
  but by convention, each of these partials are called to produce partial JSON,
  that are then deeply merged into the final output.


## Artifacts

* `/<stack-stem>.cfn.json` would be the latest generated CloudFormation template
* `/<stack-stem>.cfn.json.bak` would be the live CloudFormation template that defines the current stack
* `/<stack-stem>.cfn.json.err` would be the latest failed CloudFormation template
  * failed = invalid JSON or CloudFormation semantics

For stacks that are being updated:

* `/<stack-stem>.change-set.json` would be the CloudFormation changeset, as retrieved from AWS
* `/<stack-stem>.change-set.json.diff` would be the diff between
  the live CloudFormation template `/<stack-stem>.cfn.json.bak` and the newly generated `/<stack-stem>.cfn.json`


## Make targets

Running `make help` lists the important targets along with descriptions,
but here's a common workflow:

* new stack
  * `make <stack-stem>.cfn.json` to generate and validate the template
    * `make <stack-stem>.cfn.json/lint` to lint the template JS sources (runs automatically)
  * `make <stack-stem>.cfn.json/exec` to execute the template, and create the stack
  **NOTE**: if the stack already exists, this will actually end up executing a change-set.
* existing stack
  * `make <stack-stem>.change-set.json` to generate the template changeset and the diff
    * `/<stack-stem>.change-set.json.diff` is tremendously useful for manual inspection!!!
  * `make <stack-stem>.change-set.json/exec` to execute the changeset, and update the stack
  * `make <stack-stem>.cfn.json/rm` to remove the stack


## Misc refs

**NOTE**: by far the most handy resource is the printed CloudFormation manual available in our team.
Make use of it, or else if you create a new stack you can easily drown yourself in the AWS websites/PDFs.

* [CloudFormation](https://aws.amazon.com/documentation/cloudformation/)
  * [Limits](http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/cloudformation-limits.html)
  * [Functions](http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/intrinsic-function-reference.html)
    * [Condition Functions](http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/intrinsic-function-reference-conditions.html)
  * [Pseudo Parameters](http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/pseudo-parameter-reference.html)

* S3
  * [Access Policy Language](http://docs.aws.amazon.com/AmazonS3/latest/dev/amazon-s3-policy-keys.html)
    * Condition Keys
      * [General](http://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_elements.html#AvailableKeys)
      * [for object operations](http://docs.aws.amazon.com/AmazonS3/latest/dev/amazon-s3-policy-keys.html#object-keys-in-amazon-s3-policies)
      * [for key operations](http://docs.aws.amazon.com/AmazonS3/latest/dev/amazon-s3-policy-keys.html#bucket-keys-in-amazon-s3-policies)

* IAM
  * [Policy](http://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_elements.html)
