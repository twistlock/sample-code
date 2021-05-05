# Matches when a container in a pod adds a specified capability

match[{"msg": msg}] {
    operations := {"CREATE"}
    operations[input.request.operation]
    input.request.kind.kind == "Pod"

    containers := input.request.object.spec.containers[_]
    denied_capabilities := {"CAP_SYS_ADMIN", "CAP_SYS_CHROOT"}
    present_capabilities := {containers.securityContext.capabilities.add[_]}

    count(denied_capabilities & present_capabilities) > 0
    msg := sprintf("container '%v' is adding one of the following capabilities: %v", [containers.name, concat(", ", denied_capabilities)])
}
