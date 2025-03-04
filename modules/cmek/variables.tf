variable "key_ring_name" {
  type    = string
  default = "csye7125"
}

variable "location" {
  description = "The multi-region location for the KMS key ring."
  type        = string
  default     = "us" # Multi-region for all US regions
}

variable "crypto_key_names" {
  description = "A list of crypto key names to be created."
  type        = list(string)
  default     = ["sops_crypto_key"]
}

variable "purpose" {
  type    = string
  default = "ENCRYPT_DECRYPT"
}
