terraform {
  cloud {
    organization = "theo-terransible"

    workspaces {
      name = "terransible"
    }
  }
}
