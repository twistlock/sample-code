# Rule name must be "match"
# "msg" is the string message returned. It is required
# "input" is the admission review json object
# 
# Example: capture creation of namespaces
 match[{"msg": msg}] {
    input.request.kind.kind == "Pod"
    image := input.request.object.spec.containers[_].image
    not startswith(image, "hooli.com")
    Cport := input.request.object.spec.containers[_].ports[_].containerPort
    msg := sprintf("\n\nImage \"%v\" fails to come from a trusted registry\n\n", [image])
 }
