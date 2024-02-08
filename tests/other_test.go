// Tests in this file are NOT run in the PR pipeline. They are run in the continuous testing pipeline along with the ones in pr_test.go
package test

import (
	"fmt"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testhelper"
)

func TestRunRestoredDBExample(t *testing.T) {
	t.Parallel()

	options := testhelper.TestOptionsDefaultWithVars(&testhelper.TestOptions{
		Testing:            t,
		TerraformDir:       "examples/backup",
		Prefix:             "mysql-backup",
		BestRegionYAMLPath: regionSelectionPath,
		ResourceGroup:      resourceGroup,
		TerraformVars: map[string]interface{}{
			"mysql_version": "8.0",
		},
	})

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

func TestRunPointInTimeRecoveryDBExample(t *testing.T) {
	t.Parallel()

	options := testhelper.TestOptionsDefaultWithVars(&testhelper.TestOptions{
		Testing:       t,
		TerraformDir:  "examples/pitr",
		Prefix:        "mysql-pitr",
		ResourceGroup: resourceGroup,
		Region:        fmt.Sprint(permanentResources["mysqlPITRRegion"]),
		TerraformVars: map[string]interface{}{
			"pitr_id":       permanentResources["mysqlPITRCrn"],
			"pitr_time":     " ",
			"mysql_version": permanentResources["mysqlPITRVersion"],
			"members":       "3", // Lock members to 3 as the permanent mysql instances has 3 members
		},
	})

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

func TestRunBasicExample(t *testing.T) {
	t.Parallel()

	options := testhelper.TestOptionsDefaultWithVars(&testhelper.TestOptions{
		Testing:            t,
		TerraformDir:       "examples/basic",
		Prefix:             "mysql-basic",
		BestRegionYAMLPath: regionSelectionPath,
		ResourceGroup:      resourceGroup,
		TerraformVars: map[string]interface{}{
			"mysql_version": "8.0",
		},
	})

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}
