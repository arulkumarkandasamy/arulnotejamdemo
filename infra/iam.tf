resource "google_service_account" "gke_service_account" {
  account_id   = local.gke_service_account_id
  display_name = "Service Account for GKE"
  project      = var.project_name
}

resource "google_service_account_key" "gke_service_account_key" {
  count = local.generate_gke_service_account_key_count
  service_account_id = google_service_account.gke_service_account.name
}

resource "google_project_iam_member" "gke_service_account_role" {
  for_each = { for v in local.gke_service_account_iam_roles : v => v }
  project  = var.project_name
  role     = each.key
  member   = "serviceAccount:${google_service_account.gke_service_account.email}"
}

/*
resource "google_service_account_iam_binding" "iam_policy_binding" {
  service_account_id = google_service_account.gke_service_account.name
  role = "roles/iam.workloadIdentityUser"
  members = ["serviceAccount:${var.project_name}.svc.id.goog[notejam/notejam-sa"]
}
*/