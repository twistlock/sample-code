match[{"msg": msg}] {
	input.request.operation == "CREATE"
	input.request.kind.kind == "Pod"
	input.request.resource.resource == "pods"
	hostPath := input.request.object.spec.volumes[_].hostPath.path
	res := [startswith(hostPath, "/etc"), startswith(hostPath, "/var"), hostPath == "/"]
	res[_]
	msg := "\n\nPod created with sensitive host file system mount\n\n"
}
