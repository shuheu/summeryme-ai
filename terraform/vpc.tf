# VPC Network
# Summaryme AI Backend

# VPCネットワーク
resource "google_compute_network" "main" {
  name                    = "${local.service_name}-vpc"
  auto_create_subnetworks = false
  description             = "VPC network for ${local.service_name}"

  depends_on = [google_project_service.required_apis]
}

# サブネット
resource "google_compute_subnetwork" "main" {
  name          = "${local.service_name}-subnet"
  ip_cidr_range = "10.0.0.0/24"
  region        = var.region
  network       = google_compute_network.main.id
  description   = "Subnet for ${local.service_name}"

  # プライベートGoogleアクセスを有効化
  private_ip_google_access = true
}

# Cloud SQLプライベート接続用のIPアドレス範囲
resource "google_compute_global_address" "private_ip_address" {
  name          = "${local.service_name}-private-ip"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.main.id
}

# プライベートサービス接続
resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.main.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]

  depends_on = [google_project_service.required_apis]
}

# Cloud NATゲートウェイ用のルーター
resource "google_compute_router" "main" {
  name    = "${local.service_name}-router"
  region  = var.region
  network = google_compute_network.main.id
}

# Cloud NAT（アウトバウンドインターネットアクセス用）
resource "google_compute_router_nat" "main" {
  name                               = "${local.service_name}-nat"
  router                             = google_compute_router.main.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}