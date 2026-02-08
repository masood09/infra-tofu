variable "oci_tenancy_ocid" {
  type        = string
  description = "OCID of the tenancy. To get the value, see Where to Get the Tenancy's OCID and User's OCID (https://docs.oracle.com/iaas/Content/API/Concepts/apisigningkey.htm#five)"
}

variable "oci_compartment_ocid" {
  type        = string
  description = "The compartment to create the resources in"
}

variable "oci_user_ocid" {
  type        = string
  description = "OCID of the user calling the API. To get the value, see Where to Get the Tenancy's OCID and User's OCID (https://docs.oracle.com/iaas/Content/API/Concepts/apisigningkey.htm#five)"
}

variable "oci_private_key_path" {
  type        = string
  description = "The path (including filename) of the private key stored on the computer. Required if private_key isn't defined. For details on how to create and configure keys see How to Generate an API Signing Key (https://docs.oracle.com/iaas/Content/API/Concepts/apisigningkey.htm#two) and How to Upload the Public Key (https://docs.oracle.com/iaas/Content/API/Concepts/apisigningkey.htm#three)"
}

variable "oci_fingerprint" {
  type        = string
  description = "Fingerprint for the key pair being used. To get the value, see How to Get the Key's Fingerprint (https://docs.oracle.com/iaas/Content/API/Concepts/apisigningkey.htm#four)"
}

variable "oci_region" {
  type        = string
  description = "An OCI region. See Regions and Availability Domains (https://docs.oracle.com/iaas/Content/General/Concepts/regions.htm)"
}

variable "oci_object_storage_namespace" {
  type = string
}

variable "ssh_public_key" {
  type        = string
  description = "The SSH public key to use for connecting to the worker nodes"
}

variable "cloudflare_api_token" {
  description = "CloudFlare API Token"
  sensitive   = true
  type        = string
}

variable "cloudflare_zone_id" {
  description = "CloudFlare Zone ID"
  sensitive   = true
  type        = string
}
