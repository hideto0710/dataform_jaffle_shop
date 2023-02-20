resource "google_service_account" "loader" {
  account_id = "jaffle-shop-${random_string.suffix.id}-loader"
}

data "google_iam_policy" "service_account_loader" {
  binding {
    role = "roles/iam.serviceAccountUser"

    members = [
      "serviceAccount:${google_service_account.workflow.email}",
    ]
  }
}

resource "google_service_account_iam_policy" "loader" {
  service_account_id = google_service_account.loader.name
  policy_data        = data.google_iam_policy.service_account_loader.policy_data
}

resource "google_storage_bucket" "loader" {
  name          = "${data.google_project.current.project_id}-jaffle-shop-${random_string.suffix.id}"
  location      = "US"
  force_destroy = true

  public_access_prevention    = "enforced"
  uniform_bucket_level_access = true
}

locals {
  targets = jsondecode(file("${path.module}/assets/targets.json"))
}

resource "google_storage_bucket_object" "raw" {
  for_each = toset(local.targets)
  name     = "raw/${each.key}.csv"
  source   = "${path.module}/assets/${each.key}.csv"
  bucket   = google_storage_bucket.loader.name
}

resource "google_storage_bucket_iam_binding" "loader_bucketreader" {
  bucket = google_storage_bucket.loader.name
  role   = "roles/storage.legacyBucketReader"
  members = [
    "serviceAccount:${google_service_account.loader.email}"
  ]
}

resource "google_storage_bucket_iam_binding" "loader_objectviewer" {
  bucket = google_storage_bucket.loader.name
  role   = "roles/storage.objectViewer"
  members = [
    "serviceAccount:${google_service_account.loader.email}"
  ]
}

resource "google_cloud_run_v2_job" "loader" {
  name         = "jaffle-shop-${random_string.suffix.id}-loader"
  location     = "us-central1"
  launch_stage = "BETA"

  template {
    parallelism = 3
    task_count  = length(local.targets)

    template {
      containers {
        image   = "asia.gcr.io/google.com/cloudsdktool/google-cloud-cli:411.0.0-slim"
        command = ["bash", "-c"]
        args = [
          <<-EOT
          TARGETS=(${join(" ", [for t in local.targets : format("%q", t)])}) && \
          TABLE_NAME="$${TARGETS[CLOUD_RUN_TASK_INDEX]}" && \
          TABLE_ID="${google_bigquery_dataset.raw.project}:${google_bigquery_dataset.raw.dataset_id}.$${TABLE_NAME}" && \
          bq load --project_id="${data.google_project.current.project_id}" \
            --replace --allow_quoted_newlines \
            --source_format=CSV \
            --skip_leading_rows=1 \
            --autodetect \
            "$${TABLE_ID}" \
            "gs://${google_storage_bucket.loader.name}/raw/$${TABLE_NAME}.csv"
          EOT
        ]
      }

      timeout     = "600s"
      max_retries = 0

      service_account = google_service_account.loader.email
    }
  }
}

data "google_iam_policy" "job_loader" {
  binding {
    role = "roles/run.invoker"

    members = [
      "serviceAccount:${google_service_account.workflow.email}",
    ]
  }

  binding {
    role = "roles/run.viewer"

    members = [
      "serviceAccount:${google_service_account.workflow.email}",
    ]
  }
}

resource "google_cloud_run_v2_job_iam_policy" "loader" {
  project     = google_cloud_run_v2_job.loader.project
  location    = google_cloud_run_v2_job.loader.location
  name        = google_cloud_run_v2_job.loader.name
  policy_data = data.google_iam_policy.job_loader.policy_data
}

resource "google_bigquery_dataset" "raw" {
  dataset_id = "jaffle_shop_${random_string.suffix.id}_raw"
  location   = "US"

  delete_contents_on_destroy = true

  max_time_travel_hours = "168"
}

resource "google_bigquery_dataset_iam_binding" "raw_writer" {
  dataset_id = google_bigquery_dataset.raw.dataset_id
  role       = "roles/bigquery.dataEditor"

  members = [
    "serviceAccount:${google_service_account.loader.email}",
  ]
}

resource "google_bigquery_dataset_iam_binding" "raw_viewer" {
  dataset_id = google_bigquery_dataset.raw.dataset_id
  role       = "roles/bigquery.dataViewer"

  members = [
    "serviceAccount:service-${data.google_project.current.number}@gcp-sa-dataform.iam.gserviceaccount.com",
  ]
}
