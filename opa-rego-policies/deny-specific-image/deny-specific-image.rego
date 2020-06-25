match[{"msg": msg}] {
    input.request.operation == "CREATE"
    input.request.kind.kind == "Pod"
    input.request.resource.resource == "pods"
    input.request.object.spec.containers[_].image == "nginx"
    msg := "It's not allowed to use the nginx Image!"
}
