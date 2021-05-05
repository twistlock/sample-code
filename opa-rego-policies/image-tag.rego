# Matches when an image used in a pod use a specified tag or is not tagged

match[{"msg": msg}] {
    operations := {"CREATE"}
    operations[input.request.operation]
    input.request.kind.kind == "Pod"

    # Example of using list of denied or anomalous items
    # See image-repo for an example of the opposite
    denied_tags := {"latest", "bad"}
    image := input.request.object.spec.containers[_].image

    # Read as "add image to set if image ends with a denied tag"
    noncompliant_images := [i | tag := denied_tags[_] ; i := endswith(image, concat(":", ["", tag]))]
    any(noncompliant_images)
    msg := sprintf("image '%v' is using one of the following tags: %v", [image, concat(", ", denied_tags)])
 }

match[{"msg": msg}] {
    operations := {"CREATE"}
    operations[input.request.operation]
    input.request.kind.kind == "Pod"

    image := input.request.object.spec.containers[_].image

    not re_match("^.+:[-._0-9A-Za-z]+$", image)
    msg := sprintf("image '%v' does not have a tag", [image])
 }