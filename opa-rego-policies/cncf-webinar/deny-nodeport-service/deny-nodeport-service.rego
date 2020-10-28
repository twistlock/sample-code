# Rule name must be "match"
# "msg" is the string message returned. It is required
# "input" is the admission review json object
# 
# Prevent NodePort Services
 match[{"msg": msg}] {
  input.request.operation == "CREATE"
  input.request.object.kind == "Service"
  NP := input.request.object.spec.type
  NP == "NodePort"
  #input.request.object.spec.NodePort
  msg := "\n\nNo Services can be created with type NodePort\n\n"
 }
