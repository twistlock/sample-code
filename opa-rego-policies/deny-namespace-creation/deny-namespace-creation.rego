match[{"msg": msg}] {
    input.request.operation == "CREATE"
    input.request.kind.kind == "Namespace"
    msg := "It's not allowed to create new namespace!"
}
