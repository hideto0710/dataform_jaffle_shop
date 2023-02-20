resource "google_service_account" "workflow" {
  account_id = "jaffle-shop-${random_string.suffix.id}-workflow"
}
