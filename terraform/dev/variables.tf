variable "aws_region" {
  type    = string
  default = "ap-northeast-1"
}

variable "stage" {
  type    = string
  default = "dev" # prod 側は "prod"
}
