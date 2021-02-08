# variables.tf

#------------------------------------------------------------------------------
# ENVIRONMENT VARIABLES
# Define these secrets as environment variables
#------------------------------------------------------------------------------

# --- These are used for minio / backend config
# AWS_ACCESS_KEY_ID
# AWS_SECRET_ACCESS_KEY


#------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults
#------------------------------------------------------------------------------

variable "network_cidr_block" {
  description = "The CIDR block for the windows lab network."
  type        = string
  default     = "10.0.10.0/24"
}

variable "libvirt_server" {
  description = "The connection string used for a libvirt server"
  type        = string
  default     = "qemu:///system"
}


variable "iso_win10" {
  description = "The URL for a qcow2 image for windows 10"
  type        = string
  default     = "https://s3.ap-southeast-2.amazonaws.com/pentesterwtf/qemu/windows-10-1904.qcow2"
}

variable "iso_win2019" {
  description = "The URL for a qcow2 image for windows server 2019"
  type        = string
  default     = "https://s3.ap-southeast-2.amazonaws.com/pentesterwtf/qemu/windows-server-2019-17763.qcow2"
}

variable "iso_kali" {
  description = "The URL for a qcow2 image for kali linux"
  type        = string
  default     = "https://s3.ap-southeast-2.amazonaws.com/pentesterwtf/qemu/kali.qcow2"
}

variable "libvirt_storage_pool" {
  description = "The storage pool to use for storing images"
  type        = string
  default     = "default"
}

variable "count_win10_machines" {
  description = "The number of win10 machines to provision"
  type        = number
  default     = "1"
}

variable "count_win2019_machines" {
  description = "The number of windows server 2019 machines to provision"
  type        = number
  default     = "1"
}
variable "count_kali_machines" {
  description = "The number of kali machines to provision"
  type        = number
  default     = "0"
}
