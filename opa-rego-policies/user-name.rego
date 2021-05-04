# Matches when the user is a specified user

match[{"msg": msg}] {
    operations := {"CREATE"}
    operations[input.request.operation]
    
    denied_users := {"user1", "user2"}
    user := {input.request.userInfo.username}

    count(denied_users & user) == 1
    msg := sprintf("user %v created resource", [concat("", user)])
}