variable vpc_cidr {
    default = "10.124.0.0/16"
}

variable pub_cidrs {
    default = ["10.124.1.0/24", "10.124.3.0/24"]
}

variable priv_cidrs {
    default = ["10.124.2.0/24", "10.124.4.0/24"]
}

variable access_ip {
    default = "159.146.55.159/32"
}

variable cloud9_ip {
    default = "18.203.81.47/32"
}


variable instance_type {
    default = "t2.micro"
}

variable main_vol_size {
    default = 8
}

variable main_vol_type {
    default = "gp2"
}

variable key_name {}

variable public_key_path {}