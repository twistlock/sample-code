match[{"msg": msg}] {
    operations := {"CREATE", "UPDATE"}
    operations[input.request.operation]
    input.request.kind.kind == "Pod"

    required_label := ["owner", "env"]

    label := required_label[_]
    not input.request.metadata.labels[label]
    msg := sprintf("pod '%v' is missing label '%v'", [input.request.object.metadata.name, label])
}
