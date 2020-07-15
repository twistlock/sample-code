# Even policy enforcement at all stages of the app lifecycle

As you think about how to apply Prisma Cloud to secure your apps, you'll want to ensure that policies are evenly enforced across the app lifecycle.
Prisma Cloud offers controls that can be deployed at different points: the developer's IDE, the CI/CD pipeline, the entry point to production, and the runtime environment.

Currently, the Prisma Cloud DevOps plugin policies are written in JSON.
JSON policies target the developer's IDE and the CI/CD pipeline.
The admission controller policies are written in Rego.
Admission controller policies are evaluated at the moment apps are put in production.

Here we show examples of policies written in JSON, and the equivalent policies written in Rego.
They're designed to do the same thing, just at different stages of the app lifecycle.

The policies are:

* Deny specific container images.
* Deny containers from exposing specific ports (for example, deny all apps that open port 80 for unsecured HTTP traffic).
* Deny privileged pods.
* Deny namespaces from being created.

This repository is meant to be a library of rules.
If you've written a rule, and you'd like to share it with the Prisma Cloud community, please submit your work as a pull request.

For more information about the Prisma Cloud DevOps plugin policies, see https://docs.paloaltonetworks.com/prisma/prisma-cloud/prisma-cloud-policy-reference/configuration-policies/configuration-policies-build-phase/kubernetes-configuration-policies.html

For more information about the Prisma Cloud admission controller, based on the Open Policy Agent, see https://docs.paloaltonetworks.com/prisma/prisma-cloud/prisma-cloud-admin-compute/access_control/open_policy_agent.html

