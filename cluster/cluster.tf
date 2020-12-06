data "digitalocean_image" "fedora_coreos" {
  name = "fedora-coreos-32.20201104.3.0-digitalocean.x86_64.qcow2.gz"
}

module "k8s_cluster" {
  source = "git::https://github.com/poseidon/typhoon//digital-ocean/fedora-coreos/kubernetes?ref=v1.19.4"

  # Digital Ocean
  cluster_name = "test"
  region       = "fra1"
  dns_zone     = "k8skoleni.cz"

  # configuration
  os_image         = data.digitalocean_image.fedora_coreos.id
  ssh_fingerprints = ["1e:a0:95:84:96:41:8f:d6:0d:77:bf:85:00:42:18:56"]

  controller_count = 1
  worker_count     = 2
}

resource "local_file" "k8s_cluster_kubeconfig" {
  content  = module.k8s_cluster.kubeconfig-admin
  filename = "/home/stibi/.kube/k8skoleni.kubeconfig"
}
