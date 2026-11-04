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
			"existing_database_crn": permanentResources["mysqlPITRCrn"],
		},
		ImplicitDestroy: []string{
			"module.mysql_db.time_sleep.wait_for_authorization_policy",
			"module.restored_mysql_db.time_sleep.wait_for_authorization_policy",
		},
		CloudInfoService: sharedInfoSvc,
	})

	region := options.Region
	latestVersion, _ := GetRegionVersions(region)
	options.TerraformVars["mysql_version"] = latestVersion

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

func TestRunRestoredDBGen2Example(t *testing.T) {
	t.Parallel()

	// Requires a permanent MySQL gen2 instance (with at least one backup) defined in the common permanent resources yaml
	gen2Crn, ok := permanentResources["mysqlGen2Crn"]
	if !ok {
		t.Skip("mysqlGen2Crn not defined in permanent resources, skipping gen2 restore test")
	}

	// ResourceGroup is intentionally not set so a unique group is created per run for this test.
	// Independent backup policies may not be destroyed on failure, causing conflicts on re-runs within the same group.
	options := testhelper.TestOptionsDefaultWithVars(&testhelper.TestOptions{
		Testing:      t,
		TerraformDir: "examples/backup",
		Prefix:       "mysql-g2-restored",
		TerraformVars: map[string]interface{}{
			"plan":                  "standard-gen2",
			"disk_mb":               permanentResources["mysqlGen2DiskMb"],
			"mysql_version":         fmt.Sprint(permanentResources["mysqlGen2Version"]),
			"region":                permanentResources["mysqlGen2Region"],
			"existing_database_crn": gen2Crn,
		},
		CloudInfoService: sharedInfoSvc,
	})

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}
