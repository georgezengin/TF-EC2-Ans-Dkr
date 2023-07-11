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
}

resource "aws_iam_policy" "StartStopEc2" {
  name        = "StartStopEC2Policy"
  description = "IAM Policy for AWS EventBridge to start/stop EC2 instances"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
          "Effect": "Allow",
          "Action": [
              "logs:CreateLogGroup",
              "logs:CreateLogStream",
              "logs:PutLogEvents",
              "events:*"
          ],
          "Resource": "arn:aws:logs:*:*:*"
      },
      {
        "Sid" : "StartStopEc2",
        "Effect" : "Allow",
        "Action": [
            "ec2:RevokeSecurityGroupIngress",
            "ec2:RevokeSecurityGroupEgress",
            "ec2:AuthorizeSecurityGroupIngress",
            "ec2:AuthorizeSecurityGroupEgress",
            "ec2:DescribeInstances",
            "ec2:DescribeInstanceStatus",
            "ec2:DescribeInstanceEventNotificationAttributes",
            "ec2:Start*",
            "ec2:Stop*",
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
  schedule_expression           = var.start_ec2_cron
  schedule_expression_timezone  = data.external.userTimeInfo.timeZone ## var.ec2_timezone

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
  name       = "${var.v_environment}-jenkins-ec2-stop"
  group_name = "default"

  flexible_time_window {
    mode = "OFF"
  }

  # Stop it at 7PM
  schedule_expression           = var.stop_ec2_cron
  schedule_expression_timezone  = var.ec2_timezone

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

