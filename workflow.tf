resource "google_service_account" "workflow" {
  account_id = "jaffle-shop-${random_string.suffix.id}-workflow"
}

resource "google_workflows_workflow" "load" {
  name            = "jaffle-shop-${random_string.suffix.id}-load"
  region          = "us-central1"
  service_account = google_service_account.workflow.id
  source_contents = templatefile("${path.module}/assets/workflow.load.yaml", {
    project_id              = data.google_project.current.project_id
    job_name                = google_cloud_run_v2_job.loader.name
    job_location            = google_cloud_run_v2_job.loader.location
    repository_id           = google_dataform_repository.jaffle_shop.id
    compilation_result_name = var.compilation_result_name
  })
}

resource "google_workflows_workflow" "transform" {
  name            = "jaffle-shop-${random_string.suffix.id}-transform"
  region          = "us-central1"
  service_account = google_service_account.workflow.id
  source_contents = templatefile("${path.module}/assets/workflow.transform.yaml", {
    project_id              = data.google_project.current.project_id
    repository_id           = google_dataform_repository.jaffle_shop.id
    compilation_result_name = var.compilation_result_name
  })
}
