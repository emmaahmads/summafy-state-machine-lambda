// Create 2 roles
// 1. step_function - allows any action on Cloudwatch
//                  - trust policy - only this AWS service can assume role 
// 2. cloudwatch_event - 


resource "aws_iam_role" "step_function_role" {
  name = "StepFunctionExecutionRole"
  
  // the following is a trust policy
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      /* The `Principal` attribute defines the entity that is allowed to assume the role. The `Service` sub-attribute is set to "states.amazonaws.com", which corresponds to the AWS Step Functions service. This means that only AWS Step Functions can assume this role. In summary, this Terraform resource creates an IAM role with a trust policy that allows AWS Step Functions to assume the role. This setup is essential for enabling Step Functions to execute state machines with the permissions granted to the role, ensuring that the state machines can interact with other AWS resources as needed.*/
      Principal = {
        Service = "states.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy" "step_function_policy" {
  name        = "StepFunctionPolicy"
  description = "Policy for Step Function to access resources"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = [
        "lambda:InvokeFunction",
        "logs:*"
      ]
      Effect   = "Allow"
      Resource = "*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "step_function_policy_attachment" {
  role       = aws_iam_role.step_function_role.name
  policy_arn = aws_iam_policy.step_function_policy.arn
}

resource "aws_iam_role" "cloudwatch_event_role" {
  name = "CloudWatchEventRole"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "events.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy" "cloudwatch_event_policy" {
  name = "CloudWatchEventPolicy"
  description = "Policy for CloudWatch Events to invoke Step Functions"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "states:StartExecution"
      ]
      Resource = [
        aws_sfn_state_machine.state_machine.arn
      ]
    }]
  })
}

resource "aws_iam_role_policy_attachment" "cloudwatch_event_policy_attachment" {
  role = aws_iam_role.cloudwatch_event_role.name
  policy_arn = aws_iam_policy.cloudwatch_event_policy.arn
}