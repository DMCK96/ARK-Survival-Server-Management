# Function to get mod information from API
function Get-ModInfo {
    param (
        [string]$modID
    )
    if (-not $modID) {
        Write-Host "Mod ID is null or empty."
        return
    }
    $url = "https://api.curse.tools/v1/cf/mods/$modID"
    $response = Invoke-RestMethod -Uri $url -Method Get -ErrorAction SilentlyContinue
    if ($response) {
        return $response
    } else {
        Write-Host "Failed to retrieve mod information for mod ID: $modID"
    }
}


# Function to print mod list
function Print-ModList {
    param (
        [string]$GameUserSettingsPath
    )

    $modsLine = Get-Content $GameUserSettingsPath | Where-Object { $_ -like "Mods=*" }
    $modIDs = ($modsLine -split "=")[1] -split ","
    $index = 0

    # Output table header with borders
    Write-Host "╔════════╦══════════════════════════════════════════════════════════════════════╗"
    Write-Host "║ Index  ║ Mod Name                                                  ║ Mod ID   ║"
    Write-Host "╠════════╬═══════════════════════════════════════════════════════════╣══════════╣"

    foreach ($modID in $modIDs) {
        $modInfo = Get-ModInfo -modID $modID
        if ($modInfo) {
            # Output each row with borders
            $indexFormatted = "{0,-6}" -f $index
            $modNameFormatted = "{0,-55}" -f $modInfo.data.name
            $modIDFormatted = "{0,-9}" -f $modID
            Write-Host "║ $indexFormatted ║ $modNameFormatted   ║ $modIDFormatted║"
        }
        $index++
    }

    # Output table footer with borders
    Write-Host "╚════════╩════════════════════════════════==═════════════════════════╩══════════╝"
}


# Function to add a mod by ID with optional index
function Add-Mod {
    param (
        [string]$GameUserSettingsPath,
        [string]$modID
    )

    $modsLine = Get-Content $GameUserSettingsPath | Where-Object { $_ -like "Mods=*" }
    $modIDs = ($modsLine -split "=")[1] -split ","
    
    $indexInput = Read-Host "Enter the index where you would like to add the mod (leave blank to add to the end)"
    if ([string]::IsNullOrWhiteSpace($indexInput)) {
        # Insert the mod ID at the end of the list
        $modIDs += $modID
    }
    elseif ($indexInput -match "^\d+$") {
        $index = [int]$indexInput
        
        if ($index -ge 0 -and $index -lt $modIDs.Count) {
            Write-Host "Shifting mods to accommodate insertion at index $index..."
            # Shift mod IDs to accommodate the new insertion
            $modIDs = $modIDs[0..$index] + $modID + $modIDs[$index..($modIDs.Count - 1)]
        }
        else {
            Write-Host "Index $index is out of range. Adding mod to the end of the list."
            # Insert the mod ID at the end of the list
            $modIDs += $modID
        }
    }
    else {
        Write-Host "Invalid index input. Adding mod to the end of the list."
        # Insert the mod ID at the end of the list
        $modIDs += $modID
    }
    
    $newModsLine = "Mods=" + ($modIDs -join ",")
    (Get-Content $GameUserSettingsPath) -replace $modsLine, $newModsLine | Set-Content $GameUserSettingsPath
    Write-Host "Mod added successfully."
    Print-ModList -GameUserSettingsPath $GameUserSettingsPath
}


# Function to remove a mod by index or ID
function Remove-Mod {
    param (
        [string]$GameUserSettingsPath,
        [string]$modIdentifier
    )
    $modsLine = Get-Content $GameUserSettingsPath | Where-Object { $_ -like "Mods=*" }
    $modIDs = ($modsLine -split "=")[1] -split ","
    if ($modIdentifier -match "^\d+$") {
        $modIDToRemove = $modIDs[$modIdentifier]
    } else {
        $modIDToRemove = $modIdentifier
    }
    $modIDs = $modIDs | Where-Object { $_ -ne $modIDToRemove }
    $newModsLine = "ActiveMods=" + ($modIDs -join ",")
    (Get-Content $GameUserSettingsPath) -replace $modsLine, $newModsLine | Set-Content $GameUserSettingsPath
    Write-Host "Mod removed successfully."
    Print-ModList -GameUserSettingsPath $GameUserSettingsPath
}

# Function to switch mod order with specified index
function Switch-ModOrder {
    param (
        [string]$GameUserSettingsPath
    )
    
    $modsLine = Get-Content $GameUserSettingsPath | Where-Object { $_ -like "Mods=*" }
    $modIDs = ($modsLine -split "=")[1] -split ","
    
    $existingIndex = Read-Host "Provide the index of the mod you would like to move"
    $newIndex = Read-Host "Provide the index of where you would like this mod moved to"
    
    if ($existingIndex -ge 0 -and $existingIndex -lt $modIDs.Count -and $newIndex -ge 0 -and $newIndex -lt $modIDs.Count) {
        $modIDToMove = $modIDs[$existingIndex]
        
        # Remove the mod ID from its existing index
        $modIDs = $modIDs | Where-Object { $_ -ne $modIDToMove }
        
        # Insert the mod ID at the new index
        $modIDs = $modIDs[0..($newIndex - 1)] + $modIDToMove + $modIDs[$newIndex..($modIDs.Count - 1)]
        
        $newModsLine = "Mods=" + ($modIDs -join ",")
        (Get-Content $GameUserSettingsPath) -replace $modsLine, $newModsLine | Set-Content $GameUserSettingsPath
        Write-Host "Mod order switched successfully."
        Print-ModList -GameUserSettingsPath $GameUserSettingsPath
    }
    else {
        Write-Host "Invalid existing or new index provided."
    }
}


# Main script
$GameUserSettingsPath = "GameUserSettings.ini"
Print-ModList -GameUserSettingsPath $GameUserSettingsPath

# Output menu options in a bordered table format
Write-Host "Options:"
Write-Host "╔════════════════════════════════════════════════════════════╗"
Write-Host "║ 1. Add a mod by ID                                         ║"
Write-Host "║ 2. Remove a mod by index or ID                             ║"
Write-Host "║ 3. Switch mod order                                        ║"
Write-Host "╚════════════════════════════════════════════════════════════╝"

$option = Read-Host "Enter option number"

switch ($option) {
    '1' {
        $modID = Read-Host "Enter mod ID to add"
        Add-Mod -GameUserSettingsPath $GameUserSettingsPath -modID $modID
    }
    '2' {
        $modIdentifier = Read-Host "Enter mod index or ID to remove"
        Remove-Mod -GameUserSettingsPath $GameUserSettingsPath -modIdentifier $modIdentifier
    }
    '3' {
        Switch-ModOrder -GameUserSettingsPath $GameUserSettingsPath
    }
    default {
        Write-Host "Invalid option."
    }
}
