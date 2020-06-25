match[{"msg": msg}] {
    input.request.operation == "CREATE"
    input.request.kind.kind == "Pod"
    input.request.resource.resource == "pods"
    input.request.object.spec.containers[_].ports[_].containerPort == 80
    msg := "It's not allowed to use port 80 (HTTP) with a Pod configuration!"
}
