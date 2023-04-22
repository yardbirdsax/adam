package aws

import (
	"github.com/upbound/provider-terraform/apis/v1beta1"
	v1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

const (
	namespaceModuleURL     = "https://github.com/cloudposse/terraform-aws-eks-iam-role"
	namespaceModuleVersion = "v1.2.0"
)

func (a *aws) newNamespaceRoleResource() (*v1beta1.Workspace, error) {
	w := &v1beta1.Workspace{
		ObjectMeta: v1.ObjectMeta{
			Name: a.namespaceName + "-aws-role",
		},
		Spec: v1beta1.WorkspaceSpec{
			ForProvider: v1beta1.WorkspaceParameters{
				Module: namespaceModuleURL + "?ref=" + namespaceModuleVersion,
        Source: "Remote",
			},
		},
	}

	return w, nil
}
