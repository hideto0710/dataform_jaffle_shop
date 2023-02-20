data "google_project" "current" {}

resource "google_project_iam_member" "bigquery_user_dataform" {
  project = data.google_project.current.project_id
  role    = "roles/bigquery.user"
  member  = "serviceAccount:service-${data.google_project.current.number}@gcp-sa-dataform.iam.gserviceaccount.com"
}

resource "google_project_iam_member" "bigquery_jobuser_loader" {
  project = data.google_project.current.project_id
  role    = "roles/bigquery.jobUser"
  member  = "serviceAccount:${google_service_account.loader.email}"
}
