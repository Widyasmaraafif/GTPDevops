resource "google_compute_network" "custom_vpc" {
  name                    = "widyasmara-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "custom_subnet" {
  name          = "widyasmara-subnet"
  network       = google_compute_network.custom_vpc.id
  ip_cidr_range = var.subnet_cidr
  region        = "europe-north1"
}

resource "random_shuffle" "zone_vm1" {
  input        = ["europe-north1-a", "europe-north1-b", "europe-north1-c"]
  result_count = 1
}

resource "random_shuffle" "zone_vm2" {
  input        = ["europe-north1-a", "europe-north1-b", "europe-north1-c"]
  result_count = 1
}

resource "google_compute_instance" "vm1" {
  name         = "widyasmara-program"
  machine_type = "e2-small"
  zone         = random_shuffle.zone_vm1.result[0]
  tags         = ["widyasmara-program"]

  boot_disk {
    initialize_params {
      image = "ubuntu-2204-lts"
      size  = 30
    }
  }

  network_interface {
    network    = google_compute_network.custom_vpc.id
    subnetwork = google_compute_subnetwork.custom_subnet.id
    network_ip = "172.16.25.1"
  }

  metadata = {
    enable-oslogin = "FALSE"  # ✅ Mengaktifkan OS Login untuk SSH via IAP
  }
}

resource "google_compute_instance" "vm2" {
  name         = "widyasmara-webserver"
  machine_type = "e2-small"
  zone         = random_shuffle.zone_vm2.result[0]
  tags         = ["widyasmara-webserver"]

  boot_disk {
    initialize_params {
      image = "ubuntu-2204-lts"
      size  = 30
    }
  }

  network_interface {
    network    = google_compute_network.custom_vpc.id
    subnetwork = google_compute_subnetwork.custom_subnet.id
    network_ip = "172.16.25.2"
    access_config {}  # ✅ Hanya webserver yang punya external IP
  }
}

# 🔥 Firewall Rule untuk SSH via GCC (IAP)
resource "google_compute_firewall" "allow_ssh_gcc" {
  name    = "allow-ssh-gcc-widyasmara"
  network = google_compute_network.custom_vpc.id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["35.235.240.0/20"]  # ✅ Izinkan SSH via Google IAP
  target_tags   = ["widyasmara-program"]
}

# 🔥 Firewall Rule untuk komunikasi internal (ICMP + TCP)
resource "google_compute_firewall" "allow_internal_icmp_tcp" {
  name    = "allow-internal-icmp-tcp-widyasmara"
  network = google_compute_network.custom_vpc.id

  allow {
    protocol = "icmp"  # ✅ Izinkan Ping
  }

  allow {
    protocol = "tcp"
    ports    = ["22", "80","3000","8000"]  # ✅ Izinkan SSH & HTTP
  }

  source_ranges = ["172.16.25.0/24"]  # ✅ Hanya subnet internal yang bisa akses
  target_tags   = ["widyasmara-program", "widyasmara-webserver"]
}

# 🔥 Firewall Rule untuk HTTP dan SSH dari luar (hanya untuk webserver)
resource "google_compute_firewall" "allow_http_ssh_webserver" {
  name    = "allow-http-ssh-webserver"
  network = google_compute_network.custom_vpc.id

  allow {
    protocol = "tcp"
    ports    = ["22", "80"]
  }

  source_ranges = ["0.0.0.0/0"]  # ✅ Hanya untuk VM webserver
  target_tags   = ["widyasmara-webserver"]
}
