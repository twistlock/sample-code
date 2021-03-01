match[{"msg": msg}] {
  input.request.kind.kind == "Service"
  externalIPs := {ip | ip := input.request.object.spec.externalIPs[_]}
  
  # List of Allowed IP addresses below:
  allowedIPs := {"8.8.8.8", "8.8.4.4"}
  forbiddenIPs := externalIPs - allowedIPs
  count(forbiddenIPs) > 0
  msg := sprintf("service has forbidden external IPs: %v", [forbiddenIPs])
}
