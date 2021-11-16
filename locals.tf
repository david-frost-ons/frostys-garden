locals {

  scripts = {
    cloud_init = "${abspath("${path.module}/scripts/cloud_init.cfg.tpl")}"
  }
}
