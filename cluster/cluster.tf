resource "digitalocean_domain" "k8skoleni" {
  name = var.k8s_dns_zone
}

data "digitalocean_image" "fedora_coreos" {
  name = "fedora-coreos-32.20201104.3.0-digitalocean.x86_64.qcow2.gz"
}

module "k8s_cluster" {
  #source = "git::https://github.com/poseidon/typhoon//digital-ocean/fedora-coreos/kubernetes?ref=v1.19.4"
  source = "/home/stibi/dev/typhoon/digital-ocean/fedora-coreos/kubernetes"

  depends_on = [digitalocean_domain.k8skoleni]

  # Digital Ocean
  cluster_name = var.project_name
  region       = var.region
  dns_zone     = var.k8s_dns_zone

  # configuration
  os_image         = data.digitalocean_image.fedora_coreos.id
  ssh_fingerprints = ["1e:a0:95:84:96:41:8f:d6:0d:77:bf:85:00:42:18:56"]

  controller_count = 1
  worker_count     = 5
}

resource "digitalocean_loadbalancer" "k8s_public" {
  depends_on = [module.k8s_cluster]

  name     = var.project_name
  region   = var.region
  vpc_uuid = module.k8s_cluster.vpc_id

  forwarding_rule {
    entry_port     = 80
    entry_protocol = "http"

    target_port     = 30080
    target_protocol = "http"
  }

  forwarding_rule {
    entry_port     = 443
    entry_protocol = "https"

    target_port     = 30443
    target_protocol = "https"

    tls_passthrough = true
  }

  healthcheck {
    port     = 30080
    protocol = "http"
    path     = "/healthz"
  }

  droplet_tag = "${var.project_name}-worker"
}

resource "digitalocean_record" "apps_wildcard" {
  domain = digitalocean_domain.k8skoleni.name
  type   = "A"
  name   = "*.app"
  ttl    = 300
  value  = digitalocean_loadbalancer.k8s_public.ip
}

resource "local_file" "k8s_cluster_kubeconfig" {
  content  = module.k8s_cluster.kubeconfig-admin
  filename = "/home/stibi/.kube/k8skoleni.kubeconfig"
}
