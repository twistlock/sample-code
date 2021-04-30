match[{"msg": msg}] {
    operations := {"CREATE", "UPDATE"}
    operations[input.request.operation]
    input.request.kind.kind == "Pod"

    container_name := input.request.object.spec.containers[_].name
    security_context := input.request.object.spec.containers[_].securityContext

    not security_context.readOnlyRootFilesystem
    msg := sprintf("container '%v' does not have a read only root filesystem", [container_name])
}
