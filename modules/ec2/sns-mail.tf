# SNS notification when instance starts or stops
# Make topic
resource "aws_sns_topic" "ec2_state_change_topic" {
  name = "${var.v_environment}-ec2_state_change_topic"
}

# make subscription to topic
resource "aws_sns_topic_subscription" "ec2_state_change_subscription" {
  topic_arn = aws_sns_topic.ec2_state_change_topic.arn
  protocol  = "email"
  endpoint  = var.v_email_addr_sns
  confirmation_timeout_in_minutes = 1440
}

# make state change rule in Cloudwatch
resource "aws_cloudwatch_event_rule" "ec2_state_change_rule" {
  name        = "${var.v_environment}-ec2_state_change_rule"
  description = "Trigger SNS alarm on EC2 instance state change"
  event_pattern = jsonencode({
        source = [ "aws.ec2" ]
        detail-type = [ "EC2 Instance State-change Notification" ]
        detail = {
          state = [ "stopped", "stopping", "running"]
          instance-id = [ "${aws_instance.jenkins_server.id}" ]
        }
    })
# event_pattern = <<PATTERN
# {
#   "source": ["aws.ec2"],
#   "detail-type": ["EC2 Instance State-change Notification"],
#   "detail": {
#     "state": ["running", "stopped"],
#     "instance-id": ["${aws_instance.jenkins-server.id}"]
#   }
# }
# PATTERN
}

resource "aws_cloudwatch_event_target" "sns_target" {
  rule      = aws_cloudwatch_event_rule.ec2_state_change_rule.name
  arn       = aws_sns_topic.ec2_state_change_topic.arn

  input_transformer {
    input_paths = {

      instance  = "$.detail.instance-id"
      status    = "$.detail.state"

      
    }
  }
  #run_command_targets {
  #  key    = "InstanceIds"
  #  values = ["${aws_instance.jenkins-server.id}"]
  #}
}

resource "aws_iam_role" "ec2_sns_publish_role" {
  name               = "ec2_sns_publish_role"
  assume_role_policy = jsonencode({
        Version = "2021-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Sid    = ""
                Principal = {
                    Service = "ec2.amazonaws.com"
                }
            },
        ]
    })
}

data "aws_iam_policy_document" "sns_publish_policy_data" {
  statement {
    effect    = "Allow"
    actions   = ["SNS:Publish"]
    resources = [aws_sns_topic.ec2_state_change_topic.arn]
  }
}

resource "aws_iam_policy" "sns_publish_policy" {
  name        = "${var.v_environment}-sns_publish_policy"
  description = "Allows publishing to the EC2 state change topic"
  policy      = data.aws_iam_policy_document.sns_publish_policy.json
}

resource "aws_iam_instance_profile" "ec2_sns_publish_profile" {
  name = "${var.v_environment}-ec2_sns_publish_profile"
  role = aws_iam_role.ec2_sns_publish_role.id
  depends_on = [ aws_iam_policy.sns_publish_policy ]
}

resource "aws_iam_policy_attachment" "ec2_policy_role" {
   name       = "ec2_attachment"
   roles      = [aws_iam_role.ec2_sns_publish_role.name]
   policy_arn = aws_iam_policy.sns_publish_policy.arn
}

resource "aws_iam_role_policy_attachment" "sns_publish_policy_attachment" {
  role       = aws_iam_role.ec2_sns_publish_role.name
  policy_arn = aws_iam_policy.sns_publish_policy.arn
}

