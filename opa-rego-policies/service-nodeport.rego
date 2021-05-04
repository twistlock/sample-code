# Matches when a service is of type NodePort

match[{"msg": msg}] {
    operations := {"CREATE", "UPDATE"}
    operations[input.request.operation]
    input.request.kind.kind == "Service"

    input.request.object.spec.type == "NodePort"
    msg := sprintf("service '%v' is of type NodePort", [input.request.object.metadata.name])
}
