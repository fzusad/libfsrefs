# Tests C library functions and types.
#
# Version: 20170911

$ExitSuccess = 0
$ExitFailure = 1
$ExitIgnore = 77

$LibraryTests = "block_descriptor block_descriptors directory error io_handle level0_metadata level1_metadata level2_metadata level3_metadata metadata_block metadata_table metadata_value notify volume_information volume_name"
$LibraryTestsWithInput = "support volume"

Function GetTestToolDirectory
{
	$TestToolDirectory = ""

	ForEach (${VSDirectory} in "msvscpp vs2008 vs2010 vs2012 vs2013 vs2015 vs2017" -split " ")
	{
		ForEach (${VSConfiguration} in "Release VSDebug" -split " ")
		{
			$TestToolDirectory = "..\${VSDirectory}\${VSConfiguration}"

			If (Test-Path ${TestToolDirectory})
			{
				Return ${TestToolDirectory}
			}
			ForEach (${VSPlatform} in "Win32 x64" -split " ")
			{
				$TestToolDirectory = "..\${VSDirectory}\${VSConfiguration}\${VSPlatform}"

				If (Test-Path ${TestToolDirectory})
				{
					Return ${TestToolDirectory}
				}
			}
		}
	}
	Return ${TestToolDirectory}
}

Function RunTest
{
	param( [string]$TestType )

	$TestDescription = "Testing: ${TestName}"
	$TestExecutable = "${TestToolDirectory}\fsrefs_test_${TestName}.exe"

	$Output = Invoke-Expression ${TestExecutable}
	$Result = ${LastExitCode}

	If (${Result} -ne ${ExitSuccess})
	{
		Write-Host ${Output} -foreground Red
	}
	Write-Host "${TestDescription} " -nonewline

	If (${Result} -ne ${ExitSuccess})
	{
		Write-Host " (FAIL)"
	}
	Else
	{
		Write-Host " (PASS)"
	}
	Return ${Result}
}

$TestToolDirectory = GetTestToolDirectory

If (-Not (Test-Path ${TestToolDirectory}))
{
	Write-Host "Missing test tool directory." -foreground Red

	Exit ${ExitFailure}
}

$Result = ${ExitIgnore}

Foreach (${TestName} in ${LibraryTests} -split " ")
{
	# Split will return an array of a single empty string when LibraryTests is empty.
	If (-Not (${TestName}))
	{
		Continue
	}
	$Result = RunTest ${TestName}

	If (${Result} -ne ${ExitSuccess})
	{
		Break
	}
}

Foreach (${TestName} in ${LibraryTestsWithInput} -split " ")
{
	# Split will return an array of a single empty string when LibraryTestsWithInput is empty.
	If (-Not (${TestName}))
	{
		Continue
	}
	# TODO: add RunTestWithInput
	$Result = RunTest ${TestName}

	If (${Result} -ne ${ExitSuccess})
	{
		Break
	}
}

Exit ${Result}

