# Matches when a pod does not have all specified labels

match[{"msg": msg}] {
    operations := {"CREATE"}
    operations[input.request.operation]
    input.request.kind.kind == "Pod"

    pod_metadata := input.request.object.metadata
    present_labels := {label | pod_metadata.labels[label]}
    required_labels := {"env", "owner"}

    count(required_labels - present_labels) > 0
    msg := sprintf("pod '%v' is missing one or more of the following labels: %v", [pod_metadata.name, concat(", ", required_labels)])
}
