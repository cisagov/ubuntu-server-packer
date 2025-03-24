module "iam_user" {
  source = "github.com/cisagov/ami-build-iam-user-tf-module"

  providers = {
    aws            = aws
    aws.images-ami = aws.images-ami
    aws.images-ssm = aws.images-ssm
  }

  user_name = "build-ubuntu-server-packer"
}
