# Google Cloud APIs
# Summeryme AI Backend

# 必要なAPIの有効化
resource "google_project_service" "required_apis" {
  for_each = toset(local.required_apis)

  service = each.value

  disable_dependent_services = false
  disable_on_destroy         = false

  timeouts {
    create = "30m"
    update = "40m"
  }
}