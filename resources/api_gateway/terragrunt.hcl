dependency "youtube_metadata" {
  config_path = "../youtube_metadata"
}

dependency "firebase_notification" {
  config_path = "../firebase_notification"
}



terraform {
  source = "../../terraform-modules/api_gateway"
}

inputs = {
  firebase_notification_arn  = dependency.firebase_notification.outputs.lambda_function_arn
  firebase_notification_name = dependency.firebase_notification.outputs.lambda_function_name
  youtube_metadata_arn  = dependency.youtube_metadata.outputs.lambda_function_arn
  youtube_metadata_name = dependency.youtube_metadata.outputs.lambda_function_name
}