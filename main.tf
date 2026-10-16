variable "env" {
  type    = string
  default = "dev"
}

variable "log_level" {
  type    = string
  default = "debug"
}

# A local file stands in for a real resource so the pipeline can run with no cloud account.
resource "local_file" "app_config" {
  filename = "${path.module}/out/app-${var.env}.json"
  content = jsonencode({
    env        = var.env
    log_level  = var.log_level
    managed_by = "terraform"
  })
}

output "config_path" {
  value = local_file.app_config.filename
}
