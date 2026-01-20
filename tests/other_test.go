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
		Region:             fmt.Sprint(permanentResources["mysqlPITRRegion"]),
		TerraformVars: map[string]interface{}{
			"mysql_version":         latestVersion,
			"existing_database_crn": permanentResources["mysqlPITRCrn"],
		},
		ImplicitDestroy: []string{
			"module.mysql_db.time_sleep.wait_for_authorization_policy",
			"module.restored_mysql_db.time_sleep.wait_for_authorization_policy",
		},
		CloudInfoService: sharedInfoSvc,
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
		Region:        fmt.Sprint(permanentResources["mysqlPITRRegion"]),
		ResourceGroup: resourceGroup,
		TerraformVars: map[string]interface{}{
			"pitr_id":       permanentResources["mysqlPITRCrn"],
			"pitr_time":     " ",
			"mysql_version": permanentResources["mysqlPITRVersion"],
		},
		ImplicitDestroy: []string{
			"module.mysql_db_pitr.time_sleep.wait_for_authorization_policy",
		},
		CloudInfoService: sharedInfoSvc,
	})

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}
