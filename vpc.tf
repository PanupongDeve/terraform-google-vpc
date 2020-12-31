provider "google" {
  credentials = file("./credentials.json")

  project = "seed-iam"
  region  = "asia-southeast1"
  zone    = "asia-southeast1-a"
}



module "network" {
  source  = "terraform-google-modules/network/google"
  version = "3.0.0"
  # insert the 3 required variables here

  project_id   = "seed-iam"
  network_name = "terraform-vpc"

  subnets = [
        {
            subnet_name           = "subnet-01"
            subnet_ip             = "10.10.10.0/24"
            subnet_region         = "asia-southeast1"
        },
        {
            subnet_name           = "subnet-02"
            subnet_ip             = "10.10.20.0/24"
            subnet_region         = "asia-southeast1"
            subnet_private_access = "true"
            subnet_flow_logs      = "true"
            description           = "This subnet has a description"
        }
    ]

}



resource "google_compute_firewall" "default" {
    name    = "ssh-terraform"
    network = module.network.network_name

    allow {
        protocol = "tcp"
        ports    = ["22"]
    }

    priority = 65534
    source_ranges = [ "0.0.0.0/0" ]

}

resource "google_compute_firewall" "internal" {
    name    = "allow-internal-terraform"
    network = module.network.network_name

    allow {
        protocol = "tcp"
        ports    = ["0-65535"]
    }

    allow {
        protocol = "udp"
        ports    = ["0-65535"]
    }

    allow {
        protocol = "icmp"
    }

    priority = 65534
    source_ranges = [ "10.0.0.0/16" ]

}
