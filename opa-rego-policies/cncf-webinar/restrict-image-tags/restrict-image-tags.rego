match[{"msg": msg}] {
    input.request.kind.kind == "Pod"
    image := input.request.object.spec.containers[_].image
    res := [ endswith(image, "latest"), endswith(image, "master"), endswith(image, "dev")]
    res[_]
    msg := sprintf("\n\n The image \"%v\" is tagged dev, prod, or latest which are not allowed.\n\n", [image])
 }
