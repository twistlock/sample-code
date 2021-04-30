match[{"msg": msg}] {
    operations := {"CREATE", "UPDATE"}
    operations[input.request.operation]
    input.request.kind.kind == "Pod"

    image := input.request.object.spec.containers[_].image
    disallowed_tag := "latest"
    
    endswith(image, disallowed_tag)
    msg := sprintf("image '%v' is using tag '%v'", [image, disallowed_tag])
 }
