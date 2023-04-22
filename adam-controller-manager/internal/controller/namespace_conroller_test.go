package controller

import (
	"context"
	// "reflect"
	// "time"

	. "github.com/onsi/ginkgo/v2"
	. "github.com/onsi/gomega"
	corev1 "k8s.io/api/core/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	// "k8s.io/apimachinery/pkg/types"
)

var _ = Describe("Namespace controller", func() {
	const (
		namespaceWithAnnotationName = "annotated-namespace"
	)

	var (
		ctx = context.Background()
	)

	Context("When a namespace with the right annotation is created", func() {
		ns := &corev1.Namespace{
			ObjectMeta: metav1.ObjectMeta{
				Name: namespaceWithAnnotationName,
				Annotations: map[string]string{
					namespaceAWSRoleEnabledAnnotation: "true",
				},
			},
		}

		It("creates the expected Terraform crossplane resource for the IAM Role", func() {
			Expect(k8sClient.Create(ctx, ns)).To(Succeed())
		})
	})
})
