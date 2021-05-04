# Matches when a service uses an externalIP outside of the specified IP range

match[{"msg": msg}] {
    operations := {"CREATE"}
    operations[input.request.operation]
    input.request.kind.kind == "Service"

    external_ip := input.request.object.spec.externalIPs[_]
    allowed_cidr := "35.35.35.0/24"

    not net.cidr_contains(allowed_cidr, external_ip)
    msg := sprintf("service '%v' has IP '%v'", [input.request.object.metadata.name, external_ip])
}
