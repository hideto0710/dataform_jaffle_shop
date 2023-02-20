resource "github_repository" "jaffle_shop" {
  name       = "dataform_jaffle_shop_${random_string.suffix.id}"
  visibility = "private"

  template {
    owner      = "hideto0710"
    repository = "dataform_jaffle_shop_template"
  }
}

resource "github_repository_file" "config" {
  repository = github_repository.jaffle_shop.name
  branch     = "main"
  file       = "dataform.json"
  content = templatefile("${path.module}/assets/dataform.json", {
    suffix     = random_string.suffix.id,
    project_id = data.google_project.current.project_id
  })
  commit_message      = "Managed by Terraform"
  overwrite_on_create = true
}

resource "google_secret_manager_secret" "github" {
  provider  = google-beta
  secret_id = "github-${random_string.suffix.id}"

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "github" {
  provider = google-beta
  secret   = google_secret_manager_secret.github.id

  secret_data = var.github_token
}

data "google_iam_policy" "secret_accessor" {
  binding {
    role = "roles/secretmanager.secretAccessor"
    members = [
      "serviceAccount:service-${data.google_project.current.number}@gcp-sa-dataform.iam.gserviceaccount.com",
    ]
  }
}

resource "google_secret_manager_secret_iam_policy" "github" {
  project     = google_secret_manager_secret.github.project
  secret_id   = google_secret_manager_secret.github.secret_id
  policy_data = data.google_iam_policy.secret_accessor.policy_data
}
