resource "google_kms_key_ring" "key_ring" {
  name     = var.key_ring_name
  location = var.location

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_kms_crypto_key" "crypto_keys" {
  for_each = toset(var.crypto_key_names)

  name     = each.value
  key_ring = google_kms_key_ring.key_ring.id
  purpose  = var.purpose

  lifecycle {
    prevent_destroy = true
  }
}
