#  Environment Variables:
#  User Provided:
#  ARTIFACTS_DIRECTORY: Source Directory to compress artifacts. Only accepts a single dir
#  
#  
#  GitHub Default Environment Variables:
#  See: https://docs.github.com/en/free-pro-team@latest/actions/reference/environment-variables
#  GITHUB_TOKEN: Comes from Github secrets.
#  GITHUB_EVENT_PATH: path to GitHub Release Event, a JSON file.
#  GITHUB_REPOSITORY: Owner and Repository Name

#Comes from Github
if ([string]::IsNullOrWhiteSpace($env:GITHUB_TOKEN)) {
    Write-Host "Empty Github token!"
    Exit 1
}

#Artifacts dir to zip up and add
if ([string]::IsNullOrWhiteSpace($env:ARTIFACTS_DIRECTORY)) {
    Write-Host "Please Specify Artifacts Directory!"
    Exit 1
}

if ($(Test-Path $ARTIFACTS_DIRECTORY) -eq $false) {
    Write-Host "Artifacts Directory $env:ARTIFACTS_DIRECTORY not found!"
}

$githubEvent = ConvertFrom-Json -Path $env:GITHUB_EVENT_PATH

$zippedArtifacts = Compress-Archive -Path $env:ARTIFACTS_DIRECTORY -DestinationPath ./MigrationTools-$($githubEvent.release.id).zip

$r = iwr "https://uploads.github.com/repos/$env:GITHUB_REPOSITORY/releases/$env:RELEASE_ID/assets?name=MigrationTools-$($githubEvent.release.id).zip -Headers @{'Authorization' = "token $env:GITHUB_TOKEN", 'Content-Type' = "application/octet-stream"} -Method POST -Infile ./MigrationTools-$($githubEvent.release.id).zip