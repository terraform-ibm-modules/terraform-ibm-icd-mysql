// Tests in this file are NOT run in the PR pipeline. They are run in the continuous testing pipeline along with the ones in pr_test.go
package test

import (
	"fmt"
	"github.com/stretchr/testify/assert"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testhelper"
	"testing"
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
			"mysql_version":         "8.0",
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
		ResourceGroup: resourceGroup,
		Region:        fmt.Sprint(permanentResources["mysqlPITRRegion"]),
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

func testPlanICDVersions(t *testing.T, version string) {
	t.Parallel()

	options := testhelper.TestOptionsDefaultWithVars(&testhelper.TestOptions{
		Testing:      t,
		TerraformDir: "examples/basic",
		TerraformVars: map[string]interface{}{
			"mysql_version": version,
		},
		CloudInfoService: sharedInfoSvc,
	})
	output, err := options.RunTestPlan()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

func TestPlanICDVersions(t *testing.T) {
	t.Parallel()

	// This test will run a terraform plan on available stable versions of mysql
	versions, _ := sharedInfoSvc.GetAvailableIcdVersions("mysql")
	for _, version := range versions {
		t.Run(version, func(t *testing.T) { testPlanICDVersions(t, version) })
	}
}
