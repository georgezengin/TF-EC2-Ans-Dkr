# SNS notification when instance starts or stops
# Make topic
resource "aws_sns_topic" "ec2_state_change_sns_topic" {
  name = "${var.v_environment}-ec2_state_change_topic"
}

resource "aws_sns_topic_policy" "ec2_state_change_sns_topic_policy" {
  arn = aws_sns_topic.ec2_state_change_sns_topic.arn
  policy = jsonencode(
    {
      Id = "ID-GD-Topic-Policy"
      Statement = [
        {
          Action = "sns:Publish"
          Effect = "Allow"
          Principal = {
            Service = "events.amazonaws.com"
          }
          Resource = aws_sns_topic.ec2_state_change_sns_topic.arn
          Sid      = "SID-GD-Example"
        },
      ]
      Version = "2012-10-17"
    }
  )
}

# make subscription to topic
resource "aws_sns_topic_subscription" "ec2_state_change_subscription" {
  topic_arn = aws_sns_topic.ec2_state_change_sns_topic.arn
  protocol  = "email"
  endpoint  = var.v_email_addr_sns
  endpoint_auto_confirms = true
  #confirmation_timeout_in_minutes = 1440
}

# make state change rule in Cloudwatch
resource "aws_cloudwatch_event_rule" "ec2_state_change_rule" {
  name        = "${var.v_environment}-ec2_state_change_rule"
  description = "Trigger SNS alarm on EC2 instance state change"
  # event_pattern = jsonencode({
  #       source = [ "aws.ec2" ]
  #       detail-type = [ "EC2 Instance State-change Notification" ]
  #       detail = {
  #         state = [ "stopped", "stopping", "running"]
  #         instance-id = [ "${aws_instance.jenkins_server.id}" ]
  #       }
  #   })
  event_pattern = <<PATTERN
  {
    "source": ["aws.ec2"],
    "detail-type": ["EC2 Instance State-change Notification"],
    "detail": {
      "state": ["running", "stopped"],
      "instance-id": ["${aws_instance.jenkins_server.id}"]
    }
  }
  PATTERN

  depends_on = [ aws_instance.jenkins_server]
}

resource "aws_cloudwatch_event_target" "sns_target" {
  rule      = aws_cloudwatch_event_rule.ec2_state_change_rule.name
  arn       = aws_sns_topic.ec2_state_change_sns_topic.arn
  target_id = aws_instance.jenkins_server.id

  input_transformer {
    input_paths = {
      instance  = "$.detail.instance",
      status    = "$.detail.status",
      arn       = "$.resources[0]",
      detail    = "$.detail-type",
      acct      = "$.account",
      when      = "$.time",
      region    = "$.region",
    }
    input_template = <<EOF
    {
      "instance_id"     : <instance>,
      "instance_status" : <status>,
      "arn"             : <arn>,
      "detail"          : <detail>,
      "acct"            : <acct>,
      "when"            : <when>,
      "region"          : <region>
    }
    EOF
  }
  depends_on = [ aws_instance.jenkins_server]
}

# resource "aws_iam_role" "ec2_sns_publish_role" {
#   name               = "${var.v_environment}-ec2_sns_publish_role"
#   assume_role_policy = jsonencode({
#         Version = "2012-10-17"
#         Statement = [
#             {
#                 Action = "sts:AssumeRole"
#                 Effect = "Allow"
#                 Sid    = ""
#                 Principal = {
#                     Service = "ec2.amazonaws.com"
#                 }
#             },
#         ]
#     })
# }

# data "aws_iam_policy_document" "sns_publish_policy_data" {
#   statement {
#     effect    = "Allow"
#     actions   = ["SNS:Publish"]
#     resources = [aws_sns_topic.ec2_state_change_topic.arn]
#   }
# }

# resource "aws_iam_policy" "sns_publish_policy" {
#   name        = "${var.v_environment}-sns_publish_policy"
#   description = "Allows publishing to the EC2 state change topic"
#   policy      = data.aws_iam_policy_document.sns_publish_policy.json
# }

# resource "aws_iam_instance_profile" "ec2_sns_publish_profile" {
#   name = "${var.v_environment}-ec2_sns_publish_profile"
#   role = aws_iam_role.ec2_sns_publish_role.id
#   depends_on = [ aws_iam_policy.sns_publish_policy ]
# }

# resource "aws_iam_policy_attachment" "ec2_policy_role" {
#    name       = "ec2_attachment"
#    roles      = [aws_iam_role.ec2_sns_publish_role.name]
#    policy_arn = aws_iam_policy.sns_publish_policy.arn
# }

# resource "aws_iam_role_policy_attachment" "sns_publish_policy_attachment" {
#   role       = aws_iam_role.ec2_sns_publish_role.name
#   policy_arn = aws_iam_policy.sns_publish_policy.arn
# }
