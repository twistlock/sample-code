# Even policy at all enforcement points

As you think about how to apply Prisma Cloud to secure your apps, you'll want to ensure that policies are evenly enforced across the app lifecycle.
Prisma Cloud offers controls that can be deployed at different points: the developer's IDE, the CI/CD pipeline, the entry point to production, and the runtime environment.

Currently, the Prisma Cloud DevOps plugin policies are written in JSON.
JSON policies target the developer's IDE and the CI/CD pipeline.
The admission controller policies are written in Rego.
Admission controller policies are evaluated at the moment apps are put in production.

Here we show examples of policies written in JSON, and the equivalent policies written in Rego.
They're designed to do the same thing, just at different points.

The policies are:

* Deny specific container images.images.
* Deny exposing specific container ports (for example, deny all apps that open port 80 for unsecured HTTP traffic).
* Deny privileged pods.
* Deny namespace creation.
