package aws

import (
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/upbound/provider-terraform/apis/v1beta1"
	v1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

func TestNewNamespaceRoleResource(t *testing.T) {
  expectedNamespaceName := "namespace"
  expectedRoleWorkspace := &v1beta1.Workspace{
    ObjectMeta: v1.ObjectMeta{
      Name: expectedNamespaceName + "-aws-role",
    },
    Spec: v1beta1.WorkspaceSpec{
      ForProvider: v1beta1.WorkspaceParameters{
        Module: namespaceModuleURL + "?ref=" + namespaceModuleVersion,
        Source: "Remote",
      },
    },
  }

  aws := newAWS(expectedNamespaceName)
  actualRoleWorkspace, err := aws.newNamespaceRoleResource()

  assert.Equal(t, expectedRoleWorkspace, actualRoleWorkspace)
  assert.NoError(t, err)
}