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
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

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

if ($(Test-Path $env:ARTIFACTS_DIRECTORY) -eq $false) {
    Write-Host "Artifacts Directory $env:ARTIFACTS_DIRECTORY not found!"
}

$githubEvent = get-content -raw -path $env:GITHUB_EVENT_PATH | ConvertFrom-Json

$zippedArtifacts = Compress-Archive -Path $env:ARTIFACTS_DIRECTORY -DestinationPath ./MigrationTools-$($githubEvent.release.id).zip

write-host "DEBUG:ARTIFACTS_DIRECTORY = $env:ARTIFACTS_DIRECTORY"
write-host "DEBUG:GITHUB_EVENT_PATH = $env:GITHUB_EVENT_PATH"
write-host "DEBUG:GITHUB_REPOSITORY = $env:GITHUB_REPOSITORY"



$uri = "https://uploads.github.com/repos/$($env:GITHUB_REPOSITORY)/releases/$($githubEvent.release.id)/assets?name=MigrationTools-$($githubEvent.release.tag_name).zip"
$headers = @{'Authorization' = "token $($env:GITHUB_TOKEN)"}
$r = Invoke-RestMethod -Uri $uri -Headers $headers -Method POST -ContentType "application/zip" -Infile ./MigrationTools-$($githubEvent.release.id).zip