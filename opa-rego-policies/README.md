# Rego policy examples

With [Prisma Cloud's admission controller](https://docs.paloaltonetworks.com/prisma/prisma-cloud/prisma-cloud-admin-compute/access_control/open_policy_agent.html), you can define and enforce policy for 
interacting with cluster resources.
You can take action on resource creation, sources and tags of images used in pods, external IPs used by services, and even specific users or groups that do these things.

The admission controller policies are written in Rego.
This directory is a library of _example_ policies, so not all of them may be suitable for use as they are provided.

If you've written a rule and would like to share it with the Prisma Cloud community, please submit your work as a pull request.

### Notes
#### Operations
Most examples only target the `CREATE` operation, but are structured to allow adding other operations easily.
To add other operations, insert it into the set.
```
operations := {"CREATE", "UPDATE"}
operations[input.request.operation]
```

#### Users and groups
The `user-group.rego` and `user-name.rego` examples aren't particularly useful by themselves, but you can combine them with other policies to narrow their scopes.
An example is alerting when a member of a particular group runs a command in or attaches to a container.

#### Multiple `match` rule definitions
A rule may be defined multiple times with the same name.
This is referred to as an incremental definition because each definition is additive.
An incrementally-defined rule can be understood as `<rule-1> OR <rule-2> OR ... OR <rule-N>`.

An example of this can be found in `image-tag.rego` in which the rules will match on the tag `latest` and no tag (which defaults to `latest`).