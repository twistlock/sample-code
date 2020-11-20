#For example, the following rule checks if a pod created contains the "owner" label:

match[{"msg": msg}] {
input.request.operation == "CREATE"
input.request.kind.kind == "Pod"
input.request.resource.resource == "pods"
not input.request.metadata.labels.owner
msg := "Pod does not contain the owner label"
}
