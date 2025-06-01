## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 5.45 |
| <a name="requirement_google-beta"></a> [google-beta](#requirement\_google-beta) | ~> 5.45 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 5.45.2 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.7.2 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_artifact_registry_repository.backend](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/artifact_registry_repository) | resource |
| [google_artifact_registry_repository_iam_member.cloud_run_reader](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/artifact_registry_repository_iam_member) | resource |
| [google_artifact_registry_repository_iam_member.github_actions_writer](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/artifact_registry_repository_iam_member) | resource |
| [google_cloud_run_service_iam_member.public_access](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_run_service_iam_member) | resource |
| [google_cloud_run_v2_job.migrate](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_run_v2_job) | resource |
| [google_cloud_run_v2_service.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_run_v2_service) | resource |
| [google_compute_global_address.private_ip_address](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_global_address) | resource |
| [google_compute_network.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network) | resource |
| [google_compute_router.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router) | resource |
| [google_compute_router_nat.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router_nat) | resource |
| [google_compute_subnetwork.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork) | resource |
| [google_project_iam_member.cloud_run_secret_accessor](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.cloud_run_sql_client](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.github_actions_editor](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.github_actions_run_admin](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.github_actions_secret_admin](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.github_actions_sql_admin](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_service.required_apis](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |
| [google_secret_manager_secret.db_password](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret) | resource |
| [google_secret_manager_secret_iam_member.db_password_access](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret_iam_member) | resource |
| [google_secret_manager_secret_version.db_password](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret_version) | resource |
| [google_service_account.cloud_run](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_account.github_actions](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_networking_connection.private_vpc_connection](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_networking_connection) | resource |
| [google_sql_database.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database) | resource |
| [google_sql_database_instance.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database_instance) | resource |
| [google_sql_user.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_user) | resource |
| [google_vpc_access_connector.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/vpc_access_connector) | resource |
| [random_password.db_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allow_public_access"></a> [allow\_public\_access](#input\_allow\_public\_access) | Allow unauthenticated public access to Cloud Run service | `bool` | `true` | no |
| <a name="input_container_image"></a> [container\_image](#input\_container\_image) | Container image URL to deploy to Cloud Run | `string` | n/a | yes |
| <a name="input_cpu_limit"></a> [cpu\_limit](#input\_cpu\_limit) | CPU limit for Cloud Run service (e.g., '1000m' = 1 vCPU) | `string` | `"1000m"` | no |
| <a name="input_db_disk_size"></a> [db\_disk\_size](#input\_db\_disk\_size) | Cloud SQL disk size in GB (minimum 10GB for MySQL) | `number` | `10` | no |
| <a name="input_db_tier"></a> [db\_tier](#input\_db\_tier) | Cloud SQL instance machine type (affects performance and cost) | `string` | `"db-f1-micro"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (affects resource naming and configuration) | `string` | `"production"` | no |
| <a name="input_log_level"></a> [log\_level](#input\_log\_level) | Application log level (affects verbosity of logs) | `string` | `"info"` | no |
| <a name="input_max_instances"></a> [max\_instances](#input\_max\_instances) | Maximum number of Cloud Run instances | `number` | `10` | no |
| <a name="input_memory_limit"></a> [memory\_limit](#input\_memory\_limit) | Memory limit for Cloud Run service (e.g., '1Gi', '512Mi') | `string` | `"1Gi"` | no |
| <a name="input_min_instances"></a> [min\_instances](#input\_min\_instances) | Minimum number of Cloud Run instances (0 = scale to zero) | `number` | `0` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Google Cloud Project ID where resources will be created | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Google Cloud Region for resource deployment | `string` | `"asia-northeast1"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_artifact_registry_repository_name"></a> [artifact\_registry\_repository\_name](#output\_artifact\_registry\_repository\_name) | Name of the Artifact Registry repository |
| <a name="output_artifact_registry_repository_url"></a> [artifact\_registry\_repository\_url](#output\_artifact\_registry\_repository\_url) | URL of the Artifact Registry repository |
| <a name="output_backend_configuration"></a> [backend\_configuration](#output\_backend\_configuration) | GCS backend configuration for Terraform state management |
| <a name="output_cloud_run_service_account_email"></a> [cloud\_run\_service\_account\_email](#output\_cloud\_run\_service\_account\_email) | Email address of the Cloud Run service account |
| <a name="output_cloud_run_service_account_id"></a> [cloud\_run\_service\_account\_id](#output\_cloud\_run\_service\_account\_id) | Unique ID of the Cloud Run service account |
| <a name="output_cloud_run_service_id"></a> [cloud\_run\_service\_id](#output\_cloud\_run\_service\_id) | Full resource ID of the Cloud Run service |
| <a name="output_cloud_run_service_location"></a> [cloud\_run\_service\_location](#output\_cloud\_run\_service\_location) | Location/region of the Cloud Run service |
| <a name="output_cloud_run_service_name"></a> [cloud\_run\_service\_name](#output\_cloud\_run\_service\_name) | Name of the Cloud Run service |
| <a name="output_cloud_run_service_url"></a> [cloud\_run\_service\_url](#output\_cloud\_run\_service\_url) | Public URL of the Cloud Run service |
| <a name="output_cloud_sql_instance_connection_name"></a> [cloud\_sql\_instance\_connection\_name](#output\_cloud\_sql\_instance\_connection\_name) | Connection name for Cloud SQL Proxy (format: project:region:instance) |
| <a name="output_cloud_sql_instance_ip_address"></a> [cloud\_sql\_instance\_ip\_address](#output\_cloud\_sql\_instance\_ip\_address) | Private IP address of the Cloud SQL instance |
| <a name="output_cloud_sql_instance_name"></a> [cloud\_sql\_instance\_name](#output\_cloud\_sql\_instance\_name) | Name of the Cloud SQL instance |
| <a name="output_cloud_sql_instance_public_ip_address"></a> [cloud\_sql\_instance\_public\_ip\_address](#output\_cloud\_sql\_instance\_public\_ip\_address) | Public IP address of the Cloud SQL instance (if enabled) |
| <a name="output_container_image_url"></a> [container\_image\_url](#output\_container\_image\_url) | Full URL of the container image used for deployment |
| <a name="output_database_name"></a> [database\_name](#output\_database\_name) | Name of the application database |
| <a name="output_database_url_template"></a> [database\_url\_template](#output\_database\_url\_template) | Database URL template (replace DB\_PASSWORD with actual password) |
| <a name="output_database_user"></a> [database\_user](#output\_database\_user) | Database user name for application connections |
| <a name="output_db_password_secret_id"></a> [db\_password\_secret\_id](#output\_db\_password\_secret\_id) | Secret Manager secret ID for database password |
| <a name="output_db_password_secret_name"></a> [db\_password\_secret\_name](#output\_db\_password\_secret\_name) | Full resource name of the database password secret |
| <a name="output_environment"></a> [environment](#output\_environment) | Environment name (development, staging, production) |
| <a name="output_github_actions_service_account_email"></a> [github\_actions\_service\_account\_email](#output\_github\_actions\_service\_account\_email) | Email address of the GitHub Actions service account |
| <a name="output_github_actions_service_account_id"></a> [github\_actions\_service\_account\_id](#output\_github\_actions\_service\_account\_id) | Unique ID of the GitHub Actions service account |
| <a name="output_migration_job_location"></a> [migration\_job\_location](#output\_migration\_job\_location) | Location of the Cloud Run migration job |
| <a name="output_migration_job_name"></a> [migration\_job\_name](#output\_migration\_job\_name) | Name of the Cloud Run migration job |
| <a name="output_project_id"></a> [project\_id](#output\_project\_id) | Google Cloud Project ID where resources are deployed |
| <a name="output_region"></a> [region](#output\_region) | Google Cloud Region where resources are deployed |
| <a name="output_resource_summary"></a> [resource\_summary](#output\_resource\_summary) | Summary of all created resources |
| <a name="output_useful_commands"></a> [useful\_commands](#output\_useful\_commands) | Useful commands for managing the deployed resources |
| <a name="output_vpc_connector_name"></a> [vpc\_connector\_name](#output\_vpc\_connector\_name) | Name of the VPC access connector |
| <a name="output_vpc_network_id"></a> [vpc\_network\_id](#output\_vpc\_network\_id) | ID of the VPC network |
| <a name="output_vpc_network_name"></a> [vpc\_network\_name](#output\_vpc\_network\_name) | Name of the VPC network |
| <a name="output_vpc_subnet_cidr"></a> [vpc\_subnet\_cidr](#output\_vpc\_subnet\_cidr) | CIDR range of the VPC subnet |
| <a name="output_vpc_subnet_name"></a> [vpc\_subnet\_name](#output\_vpc\_subnet\_name) | Name of the VPC subnet |
