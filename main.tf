resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
  numeric = false
}

resource "google_dataform_repository" "dataform_respository" {
  provider = google-beta
  name     = "jaffle_shop_${random_string.suffix.id}"

  git_remote_settings {
    url                                 = github_repository.jaffle_shop.http_clone_url
    default_branch                      = "main"
    authentication_token_secret_version = google_secret_manager_secret_version.github.id
  }

  depends_on = [
    google_secret_manager_secret_iam_policy.github
  ]
}

resource "google_bigquery_dataset" "mart" {
  dataset_id = "jaffle_shop_${random_string.suffix.id}_mart"
  location   = "US"

  max_time_travel_hours = "168"
}

resource "google_bigquery_dataset_iam_binding" "mart_writer" {
  dataset_id = google_bigquery_dataset.mart.dataset_id
  role       = "roles/bigquery.dataEditor"

  members = [
    "serviceAccount:service-${data.google_project.current.number}@gcp-sa-dataform.iam.gserviceaccount.com",
  ]
}
