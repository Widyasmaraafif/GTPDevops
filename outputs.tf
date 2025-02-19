output "instance_info" {
  value = {
    vm1 = {
      name       = google_compute_instance.vm1.name
      zone       = google_compute_instance.vm1.zone
      private_ip = google_compute_instance.vm1.network_interface[0].network_ip
    }
    vm2 = {
      name       = google_compute_instance.vm2.name
      zone       = google_compute_instance.vm2.zone
      private_ip = google_compute_instance.vm2.network_interface[0].network_ip
      public_ip  = google_compute_instance.vm2.network_interface[0].access_config[0].nat_ip
    }
  }
}
