# Matches when the user is a member of a specified group

match[{"msg": msg}] {
    operations := {"CREATE"}
    operations[input.request.operation]
    
    denied_groups := {"group1", "group2"}
    present_groups := input.request.userInfo.groups[_]

    count(denied_users & present_groups) > 0
    msg := sprintf("a member of one of the following groups created resource: %v", [concat(", ", denied_groups)])
}