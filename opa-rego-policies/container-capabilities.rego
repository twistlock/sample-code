# Matches when a container adds a specified capability

match[{"msg": msg}] {
    spec := get_pod_spec(input.request.object)
    containers := array.concat(object.get(spec, "initContainers", []), object.get(spec, "containers", []))
    container := containers[_]
    
    denied_capabilities := {"SYS_ADMIN", "NET_ADMIN"}
    
    present_capabilities := {container.securityContext.capabilities.add[_]}
    count(denied_capabilities & present_capabilities) > 0
    msg := sprintf("container '%v' is adding one of the following capabilities: %v", [container.name, concat(", ", denied_capabilities)])
}

get_pod_spec(obj) = spec {
  obj.kind == "Pod"
  spec := obj.spec
} {
  obj.kind == "CronJob"
  spec := obj.spec.jobTemplate.spec.template.spec
} {
  obj.kind == "ReplicaSet"
  spec := obj.spec.template.spec
} {
  obj.kind == "ReplicationController"
  spec := obj.spec.template.spec
} {
  obj.kind == "Deployment"
  spec := obj.spec.template.spec
} {
  obj.kind == "StatefulSet"
  spec := obj.spec.template.spec
} {
  obj.kind == "DaemonSet"
  spec := obj.spec.template.spec
} {
  obj.kind == "Job"
  spec := obj.spec.template.spec
}
