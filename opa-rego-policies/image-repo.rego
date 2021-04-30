match[{"msg": msg}] {
    operations := {"CREATE", "UPDATE"}
    operations[input.request.operation]
    input.request.kind.kind == "Pod"

    image := input.request.object.spec.containers[_].image
    allowed_repo := "registry.example.com"

    not startswith(image, allowed_repo)
    msg := sprintf("image '%v' is not from '%v'", [image, allowed_repo])
}
