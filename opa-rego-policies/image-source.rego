# Matches when an image used in a pod is not from an allowed source
# This is virtually a copycat of the trusted images feature
# https://docs.paloaltonetworks.com/prisma/prisma-cloud/prisma-cloud-admin-compute/compliance/trusted_images.html

match[{"msg": msg}] {
    operations := {"CREATE"}
    operations[input.request.operation]
    input.request.kind.kind == "Pod"

    # Example of using list of allowed or expected items
    # See image-tag for an example of the opposite
    allowed_sources := {"registry.example.com"}
    image := input.request.object.spec.containers[_].image

    # Read as "add image to set if image starts with an allowed source"
    compliant_images := [i | src := allowed_sources[_] ; i := startswith(image, src)]
    not all(compliant_images)
    msg := sprintf("image '%v' is not from one of the following sources: %v", [image, concat(", ", allowed_sources)])
}
