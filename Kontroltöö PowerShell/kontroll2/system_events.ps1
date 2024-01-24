$startDateInput = Read-Host "Enter start date (e.g., 'MM/DD/YYYY')"
$endDateInput = Read-Host "Enter end date (e.g., 'MM/DD/YYYY')"
$filePathInput = Read-Host "Enter path to save the file (e.g., 'C:\path\to\file.txt')"

$startDateTime = [datetime]::ParseExact($startDateInput, 'MM/dd/yyyy', $null)
$endDateTime = [datetime]::ParseExact($endDateInput, 'MM/dd/yyyy', $null)

$logEvents = Get-WinEvent -FilterHashtable @{
    LogName = 'System'
    StartTime = $startDateTime
    EndTime = $endDateTime
    Level = @(1, 2, 3) 
} -ErrorAction SilentlyContinue

$groupedLogEvents = $logEvents | Group-Object { $_.ProviderName } | 
                    Sort-Object { $_.Count } -Descending | 
                    ForEach-Object {
                        $eventGroup = $_
                        $events = $eventGroup.Group | 
                                  Sort-Object TimeCreated -Descending | 
                                  Select-Object @{Name="Time"; Expression={$_.TimeCreated}}, 
                                                @{Name="Message"; Expression={$_.Message.Substring(0, [Math]::Min(100, $_.Message.Length))}}

                        "[ Title: $($eventGroup.Name) ]`n" + 
                        ($events | Format-Table -HideTableHeaders | Out-String).Trim()
                    }

if (!(Test-Path -Path $(Split-Path -Path $filePathInput -Parent))) {
    New-Item -ItemType Directory -Force -Path $(Split-Path -Path $filePathInput -Parent)
}

$groupedLogEvents | Out-File -FilePath $filePathInput

Write-Host "Logs saved to: $filePathInput"
