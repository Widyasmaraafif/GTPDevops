variable "subnet_cidr" {
  description = "CIDR untuk subnet"
  type        = string
  default     = "172.16.0.0/16"
}

variable "zones" {
  description = "Zona yang tersedia"
  type        = list(string)
  default     = ["us-central1-a", "us-central1-b", "us-central1-c"]
}