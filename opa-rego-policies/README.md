# Even policy enforcement at all stages of the app lifecycle

As you think about how to apply Prisma Cloud to secure your apps, you'll want to ensure that policies are evenly enforced across the app lifecycle.
Prisma Cloud offers controls that can be deployed at different points: the developer's IDE, the CI/CD pipeline, the entry point to production, and the runtime environment.

The admission controller policies are written in Rego.
Admission controller policies are evaluated as resources are deployed.

This directory is meant to be a library of rules.
If you've written a rule, and you'd like to share it with the Prisma Cloud community, please submit your work as a pull request.

For more information about the Prisma Cloud admission controller, based on the Open Policy Agent, see https://docs.paloaltonetworks.com/prisma/prisma-cloud/prisma-cloud-admin-compute/access_control/open_policy_agent.html

