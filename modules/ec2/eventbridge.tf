resource "aws_iam_role" "scheduler_role" {
  name = "${var.v_environment}-scheduler-role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [ "sts:AssumeRole" ],
        "Principal" : {"Service" : [ "scheduler.amazonaws.com" ] }
      }
    ]
  })
  tags = {
    Name = "${var.v_environment}-scheduler-role"
    Environment = "${var.v_environment}"
  }
}

resource "aws_iam_policy" "StartStopEc2" {
  name        = "StartStopEC2Policy"
  description = "IAM Policy for AWS EventBridge to start/stop EC2 instances"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "StartStopEc2",
        "Effect" : "Allow",
        "Action": [
            "ec2:RevokeSecurityGroupIngress",
            "ec2:AuthorizeSecurityGroupEgress",
            "ec2:AuthorizeSecurityGroupIngress",
            "ec2:RevokeSecurityGroupEgress",
            "ec2:DescribeInstances",
            "ec2:StartInstances",
            "ec2:StopInstances",
            "ec2:RebootInstances"
        ],
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "scheduler_policy" {
  policy_arn = aws_iam_policy.StartStopEc2.arn
  role       = aws_iam_role.scheduler_role.name
}

resource "aws_scheduler_schedule" "start_ec2_sched" {
  name       = "${var.v_environment}-jenkins-ec2-start"
  group_name = "default"

  flexible_time_window {
    mode = "OFF"
  }

  # Run it at 7AM
  schedule_expression = local.start_ec2_cron

  target {
    # This indicates that the event should be send to EC2 API and startInstances action should be triggered
    arn      = "arn:aws:scheduler:::aws-sdk:ec2:startInstances"
    role_arn = aws_iam_role.scheduler_role.arn

    # And this block will be passed to startInstances API
    input = jsonencode({
      InstanceIds = [ aws_instance.jenkins_server.id ]
    })
  }
  depends_on = [ aws_instance.jenkins_server]
}

resource "aws_scheduler_schedule" "stop_ec2_sched" {
  name       = "${var.v_environment}-jenkins-scheduler-stop"
  group_name = "default"

  flexible_time_window {
    mode = "OFF"
  }

  # Stop it at 7PM
  schedule_expression = local.stop_ec2_cron

  target {
    # This indicates that the event should be send to EC2 API and stopInstances action should be triggered
    arn      = "arn:aws:scheduler:::aws-sdk:ec2:stopInstances"
    role_arn = aws_iam_role.scheduler_role.arn

    # And this block will be passed to stopInstances API
    input = jsonencode({
      InstanceIds = [ aws_instance.jenkins_server.id ]
    })
  }
  depends_on = [ aws_instance.jenkins_server]
}

# SNS notification when instance starts or stops

resource "aws_sns_topic" "ec2_state_change_topic" {
  name = "ec2_state_change_topic"
}

resource "aws_sns_topic_subscription" "ec2_state_change_subscription" {
  topic_arn = aws_sns_topic.ec2_state_change_topic.arn
  protocol  = "email"
  endpoint  = var.v_email_addr_sns
  confirmation_timeout_in_minutes = 1440
}

data "aws_iam_policy_document" "sns_publish_policy" {
  statement {
    effect    = "Allow"
    actions   = ["SNS:Publish"]
    resources = [aws_sns_topic.ec2_state_change_topic.arn]
  }
}

resource "aws_iam_policy" "sns_publish_policy" {
  name        = "sns_publish_policy"
  description = "Allows publishing to the EC2 state change topic"
  policy      = data.aws_iam_policy_document.sns_publish_policy.json
}

resource "aws_iam_instance_profile" "ec2_sns_publish_profile" {
  name = "ec2_sns_publish_profile"
  role = aws_iam_policy.sns_publish_policy.name
}

resource "aws_cloudwatch_event_rule" "ec2_state_change_rule" {
  name        = "ec2_state_change_rule"
  description = "Trigger SNS alarm on EC2 instance state change"
  event_pattern = <<PATTERN
{
  "source": ["aws.ec2"],
  "detail-type": ["EC2 Instance State-change Notification"],
  "detail": {
    "state": ["running", "stopped"]
  }
}
PATTERN
}

resource "aws_cloudwatch_event_target" "sns_target" {
  rule      = aws_cloudwatch_event_rule.ec2_state_change_rule.name
  arn       = aws_sns_topic.ec2_state_change_topic.arn
}
