#keep only differences from 2 txt files
#for stepwise import during imaging

$setwd = read-host -prompt "Set working directory"
cd $setwd
$oldfilepath = read-host -prompt "Copy the old file name here. Include the extension"
$oldfile= Get-Content -Path $oldfilepath

$diff = Get-Content -Path (read-host -prompt "Copy the new file name here. Include the extension") | Where-Object {$_ -notin $oldfile}

$help2 = ".\Only_diff_import.txt"
$inc = 0
$txtFinal = $help2
if ((Test-Path $help2) -eq $true)
{    
	DO 
	{
    $inc ++
    $txtFinal = $help2.SubString(0,18)+ "_" + $inc + ".txt"
	} 
	until (-not (Test-path $txtFinal))
}
echo "Getting differences..."


$diff | Out-File -FilePath $txtFinal -encoding ASCII
