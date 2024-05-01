# Mod Management

# ARK Survival Ascended Server PowerShell Mod Manager

This PowerShell script helps you manage mods for your ARK Survival Ascended server. You can add, remove, and reorder mods easily using this script.

## Prerequisites

- PowerShell installed on your system. 

## How to Use

1. Download or clone this repository to your local machine.
2. Open PowerShell.
3. Navigate to the directory where the script is located.
4. Copy your GameUserSettings.ini file into this same directory
5. Run the script using the following command:

    ```powershell
    .\Manage.ps1
    ```

5. Follow the on-screen instructions to perform various operations on your mods.
6. Copy your GameUserSettings.ini file back to it's previous location

## Mod IDs

You'll need the Mod IDs for the mods you want to manage. Mod IDs can be found on the CurseForge page for each mod.

## Functions

### Print-ModList

Prints a list of currently installed mods along with their Mod Name and Mod ID.

### Add-Mod

Adds a mod to the list of installed mods. You will be asked to provide the Mod ID of the mod you want to add and the index for where to insert it.

### Remove-Mod

Removes a mod from the list of installed mods. You can specify either the index of the mod or its Mod ID.

### Switch-ModOrder

Allows you to change the order of installed mods. You will be asked to provide the current index of the mod and the index where you want to move it.

## Add-CommaSeparatedModListToClipboard

Allows you to quickly extract and copy a comma-separated mod list from the GameUserSettings.ini, which you can then paste wherever needed.

## Example

![Screenshot of powershell window demonstrating the usage of the script](https://i.imgur.com/slIJtg9.png)