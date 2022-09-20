#1.
#Copy and txt creation for TrakEM2 import
#Getting path/to/data from user
#This will loop until actual path
##########################################
DO
{
$fileLocation = Read-Host -Prompt "Where is the data located?"
$pathtest = Test-Path -Path $fileLocation
} 
Until 
($pathtest -eq $true) 

#Import or rename files (import to TrakEM2 or Save-for-web export)

DO
{
$rename = Read-Host -Prompt "Do you want to create an import text file for TrakEM2 OR`nDo you want to rename items, to include their (grand)parent folder names?`nType import or rename"
}
Until
(($rename -match "(?<![\w\d])txtfile(?![\w\d])") -or ($rename -match "(?<![\w\d])import(?![\w\d])") -or ($rename -match "(?<![\w\d])rename(?![\w\d])") -or ($rename -match "(?<![\w\d])name(?![\w\d])"))

if($rename -match "(?<![\w\d])rename(?![\w\d])" -or $rename -match "(?<![\w\d])name(?![\w\d])")
{
DO
{
cd $fileLocation
$level = Read-Host -Prompt "Should the filename include the parent, grandparent or great grandparentfolder name?`nType parent or grandparent or greatgrand"
}
Until
(($level -match "(?<![\w\d])parent(?![\w\d])") -or ($level -match "(?<![\w\d])parentfolder(?![\w\d])") -or ($level -match "(?<![\w\d])grandparent(?![\w\d])") -or ($rename -match "(?<![\w\d])grandparentfolder(?![\w\d])")-or ($level -match "(?<![\w\d])greatgrand(?![\w\d])") -or ($rename -match "(?<![\w\d])greatgrandparentfolder(?![\w\d])"))
if($level -match "(?<![\w\d])parent(?![\w\d])" -or $level -match "(?<![\w\d])parentfolder(?![\w\d])")
{$level = "parent"}
elseif ($level -match "(?<![\w\d])grandparent(?![\w\d])" -or $rename -match "(?<![\w\d])grandparentfolder(?![\w\d])")
{
$level = "grandparent"
}
elseif (($level -match "(?<![\w\d])greatgrand(?![\w\d])") -or ($rename -match "(?<![\w\d])greatgrandparentfolder(?![\w\d])"))
{
$level = "greatgrand"
}

DO
{
	$extension = Read-Host -Prompt "Type the file extension of the files you want to rename.`nWorks for tif, jpeg, png, pdf, txt and some others. Omit the fullstop"
}
Until
(($extension -match "(?<![\w\d])tif(?![\w\d])") -or ($extension -match "(?<![\w\d])jpg(?![\w\d])") -or ($extension -match "(?<![\w\d])jpeg(?![\w\d])") -or ($extension -match "(?<![\w\d])png(?![\w\d])")-or ($extension -match "(?<![\w\d])pdf(?![\w\d])")-or ($extension -match "(?<![\w\d])txt(?![\w\d])")-or ($extension -match "(?<![\w\d])raw(?![\w\d])")-or ($extension -match "(?<![\w\d])ai(?![\w\d])")-or ($extension -match "(?<![\w\d])xlsx(?![\w\d])")-or ($extension -match "(?<![\w\d])mp3(?![\w\d])")-or ($extension -match "(?<![\w\d])wmf(?![\w\d])")-or ($extension -match "(?<![\w\d])gif(?![\w\d])")-or ($extension -match "(?<![\w\d])docx(?![\w\d])"))
if($level -match "(?<![\w\d])parent(?![\w\d])")
{
	$regextension = '*.'+ $extension
	Get-ChildItem -Recurse $regextension | Rename-Item -NewName {$_.Directory.Name +'-'+ $_.Name}
}
elseif($level -match "(?<![\w\d])grandparent(?![\w\d])")
{
	$regextension = '*.'+ $extension
	Get-ChildItem -Recurse $regextension | Rename-Item -NewName {$_.Directory.Parent.Name +'-'+ $_.Name}
}
elseif($level -match "(?<![\w\d])greatgrand(?![\w\d])")
{
	$regextension = '*.'+ $extension
	Get-ChildItem -Recurse $regextension | Rename-Item -NewName {$_.Directory.Parent.Parent.Name +'-'+ $_.Name}
}

}
elseif(($rename -match "(?<![\w\d])txtfile(?![\w\d])") -or ($rename -match "(?<![\w\d])import(?![\w\d])"))
{
cd $fileLocation

#######Get Dimensions
DO
{
$TileSizeX = Read-Host -Prompt "How wide are your tiles in the X dimension?`neg. Img size = 6000x4000 type 4000"
}
Until($TileSizeX -match "^[\d\.]+$")
DO
{
$TileSizeY = Read-Host -Prompt "How long are your tiles in the Y dimension?`neg. Img size = 6000x4000 type 6000"
}
Until($TileSizeY -match "^[\d\.]+$")
DO
{
$OverlapX = Read-Host -Prompt "How much X overlap in pixels? (eg. for 100 px type 100)"
}
Until($OverlapX -match "^[\d\.]+$")
DO
{
$OverlapY = Read-Host -Prompt "How much Y overlap in pixels? (eg. for 100 px type 100)"
}
Until($OverlapY -match "^[\d\.]+$")

#####Get Starting Section
DO
{
$StartingSection = Read-Host -Prompt "Z-location of substack: How many sections came before the current dataset?`nFor multiwafer projects which are to be combined later."
}
Until
($StartingSection -match "^[\d\.]+$")
$StartingSectionNum = $StartingSection/1

#####Get Bit Depth
DO
{
$ImageType = Read-Host -Prompt "Are the images 8bit or 16bit grayscale?"
}
Until
(($ImageType -match "(?<![\w\d])8bit(?![\w\d])") -or ($ImageType -match "(?<![\w\d])16bit(?![\w\d])") -or ($ImageType -match "(?<![\w\d])8(?![\w\d])") -or ($ImageType -match "(?<![\w\d])16(?![\w\d])"))

if ($ImageType -match "(?<![\w\d])8bit(?![\w\d])" -or $ImageType -match "(?<![\w\d])8(?![\w\d])")
{
	$ImageType= "0"
	$MinIntensity = "0"
	$MaxIntensity = "255"
}
elseif ($ImageType -match "(?<![\w\d])16bit(?![\w\d])" -or $ImageType -match "(?<![\w\d])16(?![\w\d])")
{
	$ImageType= "1"
	$MinIntensity = "0"
	$MaxIntensity = "65535"
}
else
{
}

#####Get FileExtension
DO
{
$extension = Read-Host -Prompt "Type the file extension of the files you want to list. `nWorks for tif, jpeg, png, pdf, txt and some others. Omit the fullstop!"
}
Until
(($extension -match "(?<![\w\d])tif(?![\w\d])") -or ($extension -match "(?<![\w\d])jpg(?![\w\d])") -or ($extension -match "(?<![\w\d])jpeg(?![\w\d])") -or ($extension -match "(?<![\w\d])png(?![\w\d])")-or ($extension -match "(?<![\w\d])pdf(?![\w\d])")-or ($extension -match "(?<![\w\d])txt(?![\w\d])")-or ($extension -match "(?<![\w\d])raw(?![\w\d])")-or ($extension -match "(?<![\w\d])ai(?![\w\d])")-or ($extension -match "(?<![\w\d])xlsx(?![\w\d])")-or ($extension -match "(?<![\w\d])mp3(?![\w\d])")-or ($extension -match "(?<![\w\d])wmf(?![\w\d])")-or ($extension -match "(?<![\w\d])gif(?![\w\d])")-or ($extension -match "(?<![\w\d])docx(?![\w\d])"))
$regextension = '*.'+ $extension

$UserTemplate = Read-Host -Prompt "Type the template name of your data. `nReplace digits with #x#, #y# or #z#. For varying random numbers add \d+ `nE.g. Filename: Sec-001_Tile01-03 -> Sec-#z#_Tile#x#-#y#`nAlternatively, use Zeiss or Thermo templates by typing Zeiss or Thermo"
if($UserTemplate -match "(?<![\w\d])Zeiss(?![\w\d])")
{$RegTemplate = "Tile_r(?<y>\d+)-c(?<x>\d+)_S_(?<z>\d+)_\d+"
	$Template = "Tile_r#y#-c#x#_S_#z#_\d+"}
elseif($UserTemplate -match "(?<![\w\d])T(?![\w\d])" -or $UserTemplate -match "(?<![\w\d])Thermo(?![\w\d])")
{$regTemplate = "Tile_(?<y>\d+)-(?<x>\d+)-\d+_0-000.s(?<z>\d+)_e00"
	$template = "Tile_#y#-#x#-\d+_0-000.s#z#_e00"}
else
{$regTemplate = $UserTemplate -replace '#x#','(?<x>\d+)' -replace '#y#','(?<y>\d+)' -replace '#z#','(?<z>\d+)'
	$Template = $UserTemplate}



$help2 = "..\RawImgList.txt"
$inc = 0
$txtFinal = $help2
if ((Test-Path $help2) -eq $true)
{    
	DO 
	{
    $inc ++
    $txtFinal = $help2.SubString(0,13)+ "_" + $inc + ".txt"
	} 
	until (-not (Test-path $txtFinal))
}
echo "Preparing txt-file..."
$txtfile = Get-ChildItem * -Include $regextension -Recurse -Name
New-Item -Path $txtFinal


$a=$txtfile|select-string -pattern $regtemplate
$positionsX=$a.matches.groups |select-object -property Name,Value|Where-Object {$_.name -like "x"}
$positionsY=$a.matches.groups |select-object -property Name,Value|Where-Object {$_.name -like "y"}
$positionsZ=$a.matches.groups |select-object -property Name,Value|Where-Object {$_.name -like "z"}


$xar = $positionsX.Value|%{($_/1)*($TileSizeX-$OverlapX)}
$yar = $positionsY.Value|%{($_/1)*($TileSizeY-$OverlapY)}
$zar = $positionsZ.Value|%{($_/1)+($StartingSectionNum) }
$tsX = ,$TileSizeX		* $a.count
$tsY = ,$TileSizeY		* $a.count
$Min = ,$MinIntensity	* $a.count
$Maxi = ,$MaxIntensity	* $a.count
$iT  = ,$ImageType		* $a.count
if($a.count -ne $yar.count)
{$yar = ,1 * $a.count}
if($a.count -ne $xar.count)
{$xar = ,1 * $a.count}
if($a.count -ne $zar.count)
{$zar = ,1 * $a.count}

[int]$max = $a.Count
$table = for ( $i = 0; $i -lt $max; $i++)
{
   Write-Verbose "$($a[$i]),$($xar[$i]),$($yar[$i]),$($zar[$i]),$($tsX[$i]),$($tsY[$i]),$($Min[$i]),$($Max[$i]),$($iT[$i]))"
    [PSCustomObject]@{
        FileName	= $a[$i]
        XPos		= $xar[$i]
		YPos		= $yar[$i]
		Section		= $zar[$i]
		TileSizeX	= $tsX[$i]
		TileSizeY	= $tsY[$i]
		MinItensity	= $Min[$i]
		MaxIntensity= $Maxi[$i]
		ImageType	= $iT[$i]
    }
}

$table|Export-Csv -delimiter "`t" -Path $txtFinal -NoTypeInformation
(Get-Content -path $txtFinal -Raw) -replace '"','' | Set-Content -Path $txtFinal


DO
{
$CopyFiles = Read-Host -Prompt "Want to copy all files to a single folder? Type Y or N"
}
Until(($CopyFiles -match "(?<![\w\d])Y(?![\w\d])") -or ($CopyFiles -match "(?<![\w\d])N(?![\w\d])") -or ($CopyFiles -match "(?<![\w\d])Yes(?![\w\d])") -or ($CopyFiles -match "(?<![\w\d])No(?![\w\d])"))

if($CopyFiles -match "Yes")
{
	$CopyFiles = "Y"
}
elseif($CopyFiles -match "No")
{
	$CopyFiles = "N"
}

if($CopyFiles -match "Y")
{
$copyregpre = $template -replace '#x#','\d+' -replace '#y#','\d+' -replace '#z#','\d+'
$copyreg = $copyregpre +'\.' + $extension
	$help = "..\copied_rawdata"
	$inc = 0
	$FolderPath = $help
	if ((Test-Path $help) -eq $true)
	{    
		DO 
		{
        $inc ++
        $FolderPath = $help + "_" + $inc
		} 
		until (-not (Test-path $FolderPath))
	}

	md $FolderPath
	echo "Copying Data..."
	$FileList= gci -file -recurse|select-object -expandproperty fullname|select-string $copyreg
	Copy-Item $FileList -Destination $FolderPath

}

}



#End
