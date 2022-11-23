# adam

As an engineer who deploys and runs services on Kubernetes that required cloud resources, you likely
want to focus on getting really good at whatever language your code is already written in. As a
result, not needing to learn more languages would be good, especially ones that are only
tangentially related to your day to day job. Generally speaking, things around managing cloud
infrastructure fall into this category; even in today's DevOps heavy world, it's likely that many
engineers don't want to / would be better served to not worry about learning the intricacies of
Terraform modules, CloudFormation, Pulumi, etc.

On the other hand, there are likely folks whose bread and butter is writing infrastructure centric
code. It is far more efficient to have these individuals focused on writing composable pieces that
provision resources in scalable, efficient, and best practice following ways, and then finding a
method by which the individuals and teams writing applications can easily use these tools to ensure that the cloud resources they require are available.

`adam` is a project that seeks to bridge this gap by providing an easy interface for application developers to tell the platform what resources they require, in a method which they are likely at least somewhat familiar with, while using composable parts built by specialized cloud engineers behind the scenes. It is named after the 18th century Scottish philosopher and economist [Adam Smith](https://en.wikipedia.org/wiki/Adam_Smith), who is credited as one of the founders of the concept of [the division of labor](https://en.wikipedia.org/wiki/Division_of_labour), upon which the previous two paragraphs are based.

## Approach

If you are the maintainer of a service that is deployed in Kuberentes, chances are that you are at least somewhat familiar with the concept of [annotations](https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/). `adam` allows you to use annotations on your existing `Deployment` resources to indicate what kinds of cloud infrastructure you need, and then translate that into use of components provided by an infrastructure or platform engineering team.`
