output "k3s-Token" {
  description = "VM Names"
  value       = random_string.k3s_token.result
}