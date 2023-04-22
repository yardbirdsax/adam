package aws

type aws struct {
	// The name of the namespace for all created resources
	namespaceName string
}

func newAWS(namespace string) *aws {
	return &aws{
		namespaceName: namespace,
	}
}
