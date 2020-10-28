match[{"msg": msg}] {
	input.request.operation == "CREATE"
	input.request.kind.kind == "Pod"
	input.request.resource.resource == "pods"
	input.request.object.spec.containers[_].securityContext.allowPrivilegeEscalation
	msg := "\n\n Privilege escalation pod not allowed\n\n"
}
