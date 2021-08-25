# --- Exceptions Start --- #

# Allow requests from certain users, e.g. "admin@company.com", "system:serviceaccount:my-priv-ns:my-priv-sa"
allowed_users := []  
# Allow requests from users in certain groups, e.g. "system:nodes"
allowed_groups := [] 
# Allow requests from serviceaccounts in the kube-system namespace
allow_kubesystem_serviceaccounts := false  

# --- Exceptions End --- #


match[{"msg": msg}] { 
  is_self_review(input.request.kind.kind)
  not_allowed_request(allowed_users, allowed_groups, allow_kubesystem_serviceaccounts, input.request.userInfo)
  user_suspicious[{"msg": msg}]
}

user_suspicious[{"msg": msg}] {
  startswith(input.request.userInfo.username, "system:serviceaccount:")
  msg := sprintf("Service account '%v' issued a suspicious %v request, querying its permissions", [input.request.userInfo.username, input.request.kind.kind])
} {
  startswith(input.request.userInfo.username, "system:node:")
  msg := sprintf("Node '%v' issued a suspicious %v request, querying its permissions", [input.request.userInfo.username, input.request.kind.kind])
}

is_self_review(kind) {
  kind == "SelfSubjectAccessReview"
} {
  kind == "SelfSubjectRulesReview"
}

not_allowed_request(allowed_users, allowed_groups, allow_kubesystem_serviceaccounts, userInfo) {
  not array_has_value(allowed_users, userInfo.username)
  groupNames := {grp | grp := userInfo.groups[_]}
  allowedGroupNames := {grp | grp := allowed_groups[_]}
  matching := groupNames & allowedGroupNames
  count(matching) == 0
  not allowed_kubesystem_sa(allow_kubesystem_serviceaccounts, userInfo.username)
}

allowed_kubesystem_sa(allow_kubesystem_serviceaccounts, username) {
  allow_kubesystem_serviceaccounts
  startswith(username, "system:serviceaccount:kube-system:")
}

array_has_value(arr, val) {
  arr_val := arr[_]
  val == arr_val
}
