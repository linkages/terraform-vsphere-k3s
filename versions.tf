terraform {
  required_version = ">= 0.14.0"

  required_providers {
    vsphere = {
      source  = "hashicorp/vsphere"
      version = ">= 1.26.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.1.0"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.7.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 3.1.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.1.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.1.0"
    }
  }
}