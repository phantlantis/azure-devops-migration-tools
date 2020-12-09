#  Environment Variables:
#  
#  GitHub Default Environment Variables:
#  See: https://docs.github.com/en/free-pro-team@latest/actions/reference/environment-variables
#  GITHUB_TOKEN: Comes from Github secrets.
#  GITHUB_EVENT_PATH: path to GitHub Release Event, a JSON file.
#  GITHUB_REPOSITORY: Owner and Repository Name
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

#Comes from Github
if ([string]::IsNullOrWhiteSpace($env:GITHUB_TOKEN)) {
    Write-Host "Empty Github token!"
    Exit 1
}


$githubEvent = get-content -raw -path $env:GITHUB_EVENT_PATH | ConvertFrom-Json

$publishArtifactsDirs = @(
    "D:/a/azure-devops-migration-tools/azure-devops-migration-tools/src/MigrationTools.ConsoleFull/bin/Release/net472/publish/*",
    "D:/a/azure-devops-migration-tools/azure-devops-migration-tools/src/VstsSyncMigrator.Core/bin/Release/net472/publish/*"
)

$publishArtifactDlls = @(
    "Microsoft.WITDatastore32.dll",
    "Microsoft.WITDatastore64.dll"
)

#Create new Directory
$destDirName = "./MigrationTools-$($githubEvent.release.id)"
New-Item -Path "$destDirName" -ItemType "Directory" 
Copy-Item -Path $publishArtifactsDirs -Destination $destDirName -Recurse

foreach ($dll in $publishArtifactDlls) {
    $actualDllPath = gci "D:/a/azure-devops-migration-tools" -recurse | ? {$_.Name -eq $dll}
    if ($(Test-Path $actualDllPath) -eq $false) {
        Write-Host "DLL $dll Not found anywhere"
        Exit 1
    }
    Copy-Item -Path $actualDllPath -Destination $destDirName
}

$zippedArtifacts = Compress-Archive -Path $destDirName -DestinationPath ./MigrationTools-$($githubEvent.release.id).zip

write-host "DEBUG:GITHUB_EVENT_PATH = $env:GITHUB_EVENT_PATH"
write-host "DEBUG:GITHUB_REPOSITORY = $env:GITHUB_REPOSITORY"




$uri = "https://uploads.github.com/repos/$($env:GITHUB_REPOSITORY)/releases/$($githubEvent.release.id)/assets?name=MigrationTools-$($githubEvent.release.tag_name).zip"
$headers = @{'Authorization' = "token $($env:GITHUB_TOKEN)"}
$r = Invoke-RestMethod -Uri $uri -Headers $headers -Method POST -ContentType "application/zip" -Infile ./MigrationTools-$($githubEvent.release.id).zip