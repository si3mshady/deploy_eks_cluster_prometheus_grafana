


resource "aws_iam_role" "new_relic_metrics" {
  name = "new_relic_metrics"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "sts:AssumeRole",
            "Principal": {
                "AWS": "754728514883"
            },
            "Condition": {
                "StringEquals": {
                    "sts:ExternalId": "3564949"
                }
            }
        }
    ]
}
EOF

  tags = {
    tag-key = "new-relic"
  }
}


resource "aws_iam_policy_attachment" "new_relic_monitoring" {
  name       = "list s3 buckets policy to role"
  roles      = ["${aws_iam_role.new_relic_metrics.name}"]
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
 
}

# varn:aws:iam::aws:policy/ReadOnlyAccess
