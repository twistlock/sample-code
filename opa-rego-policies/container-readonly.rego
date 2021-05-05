# Matches when a container in a pod does not have a read-only root filesystem

match[{"msg": msg}] {
    operations := {"CREATE"}
    operations[input.request.operation]
    input.request.kind.kind == "Pod"

    containers := input.request.object.spec.containers[_]

    not containers.securityContext.readOnlyRootFilesystem
    msg := sprintf("container '%v' does not have a read only root filesystem", [containers.name])
}
