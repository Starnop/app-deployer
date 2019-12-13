package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

// An example of how to test the Terraform module in examples/terraform-aws-example using Terratest.
func TestTerraformBasicExample(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: "../../",
		// Variables to pass to our Terraform code using -var options
		Vars: map[string]interface{}{
			"identifier":        "master",
			"description":       "master node",
			"hostnamePrefix":    "master",
			"ecs_password":      "Example123",
			"image_id":          "",
			"image_owners":      "",
			"image_name_regex":  "",
			"instance_type":     nil,
			"cpu":               2,
			"memory":            4,
			"system_disk_size":  100,
			"data_disks":        nil,
			"max_bandwidth_out": 100,
			"security_groups":   nil,
			"vswitch_id":        "",
			"private_ip":        nil,
			"user_data":         nil,
			"temp_files":        []string{"temp_files/master_template.file"},
			"static_files":      []string{"static_files/master_static.file"},
			"entrypoint":        "echo SUCCESS",
			"size":              2,
		},
	}

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformOptions)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	// Run `terraform output` to get the value of an output variable
	instanceList := terraform.Output(t, terraformOptions, "this_instanceList")

	assert.Nil(t, instanceList)
}
