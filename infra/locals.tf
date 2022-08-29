locals {
  gke_service_account_id =  "notejam-sa"
  generate_gke_service_account_key_count = var.generate_gke_service_account_key ? 1 : 0
  gke_service_account_iam_roles = var.gke_service_account_iam_roles
  cloud_nat_name         = format("%s-%s", var.name_cloud_nat, var.name_suffix)
  created_nat_ips        = google_compute_address.external_nat_ips
  nat_ip_allocate_option = (
    var.num_of_external_nat_ips == 0 ? "AUTO_ONLY" : (
      var.nat_attach_manual_ips == "NONE" ? "AUTO_ONLY" : (
        "MANUAL_ONLY"
  )))
  selected_nat_ips = (
    local.nat_ip_allocate_option == "AUTO_ONLY" ? [] : (
      var.nat_attach_manual_ips == "ALL" ? local.created_nat_ips : (
        var.nat_attach_manual_ips == "NONE" ? [] : (
          slice(local.created_nat_ips, 0, tonumber(var.nat_attach_manual_ips))
  ))))

  all_networks = var.authorized_networks
  authorized_networks = flatten([
    for i, network in local.all_networks : [
      for j, cidr in network.cidr_ranges : {
        cidr_block   = cidr
        display_name = network.description
      }
    ]
  ])
}
