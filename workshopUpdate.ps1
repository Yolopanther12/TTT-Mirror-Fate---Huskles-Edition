$pwd = Get-Location
$scriptDir = $MyInvocation.MyCommand.Definition | Split-Path -Parent

if ("$pwd" -ne "$scriptDir") {
	Write-Output "Please run this from the addon's directory."
	exit 1
}

$prompt = "Creating or Updating? [c/U]"
$confirmation = Read-Host $prompt
while (($confirmation.ToLower() -ne "c") -and ($confirmation.ToLower() -ne "u")) {
	$confirmation = Read-Host $prompt
}

$option = 0

if ($confirmation.ToLower() -eq "c") {
	Write-Output "Creating new addon."
	$option = 1
}
else {
	Write-Output "Updating existing addon."
	$option = 2
}

$prompt = "Proceed? [Y/n]"
$confirmation = Read-Host $prompt
while ($confirmation.ToLower() -ne "y") {
	if ($confirmation.ToLower() -eq "n") { exit }
	$confirmation = Read-Host $prompt
}

& "G:\Program Files (x86)\Steam\steamapps\common\GarrysMod\bin\gmad.exe" create -folder . -out ttt_mirror_fate_huskles_edition.gma
if ($?) {
	Write-Output "Successfully created GMA file."
	if ($option -eq 1) {
		& "G:\Program Files (x86)\Steam\steamapps\common\GarrysMod\bin\gmpublish.exe" create -addon ttt_mirror_fate_huskles_edition.gma -icon logo.jpg
	}
	elseif ($option -eq 2) {
		& "G:\Program Files (x86)\Steam\steamapps\common\GarrysMod\bin\gmpublish.exe" update -addon ttt_mirror_fate_huskles_edition.gma -id ""
	}
}

Pause
