# Matches namespace creation events

match[{"msg": msg}] {
    input.request.operation == "CREATE"
    input.request.kind.kind == "Namespace"

    msg := sprintf("namespace '%v' created", [input.request.object.metadata.name])
}
