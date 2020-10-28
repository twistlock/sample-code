match[{"msg": msg}] {
	
    input.request.operation == "CREATE"
    input.request.kind.kind == "Pod"
	input.request.resource.resource == "pods"
    name := input.request.object.spec.containers[_].name
	sc := input.request.object.spec.containers[_].securityContext
    not sc.readOnlyRootFilesystem
	msg := sprintf("\n\ncontainer %s  must have a read-only root filesystem defined\n\n", [name] )

    
}
