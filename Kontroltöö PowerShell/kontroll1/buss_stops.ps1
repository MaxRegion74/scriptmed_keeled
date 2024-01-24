function Get-Distance($lat1, $lon1, $lat2, $lon2) {
    $earthRadius = 6371 
    $dLat = ($lat2 - $lat1) * [Math]::PI / 180
    $dLon = ($lon2 - $lon1) * [Math]::PI / 180
    $a = [Math]::Sin($dLat/2) * [Math]::Sin($dLat/2) +
         [Math]::Cos($lat1 * [Math]::PI / 180) * [Math]::Cos($lat2 * [Math]::PI / 180) *
         [Math]::Sin($dLon/2) * [Math]::Sin($dLon/2)
    $c = 2 * [Math]::Atan2([Math]::Sqrt($a), [Math]::Sqrt(1-$a))
    return $earthRadius * $c 
}

$stops = Import-Csv -Path './kontroll1/stops.txt'

$stopName = Read-Host "Enter the name of the bus stop"
$searchRadius = [double](Read-Host "Enter the search radius in kilometers")

$matchingStops = $stops | Where-Object { $_.stop_name -eq $stopName }

if ($matchingStops.Count -gt 1) {
    Write-Host "Multiple stops found with the name $stopName. Please select the stop:"
    $matchingStops | ForEach-Object { Write-Host "Area: $($_.stop_area), Stop ID: $($_.stop_id)" }
    $selectedStopId = Read-Host "Enter the stop ID of the stop you mean"
    $selectedStop = ($matchingStops | Where-Object { $_.stop_id -eq $selectedStopId })[0]
} elseif ($matchingStops.Count -eq 1) {
    $selectedStop = $matchingStops[0]
} else {
    Write-Host "No stops found with the name $stopName."
    return
}

$selectedLat = [double]$selectedStop.stop_lat
$selectedLon = [double]$selectedStop.stop_lon

$results = @()

$stops | ForEach-Object {
    $lat = [double]$_.stop_lat
    $lon = [double]$_.stop_lon

    $distance = Get-Distance $selectedLat $selectedLon $lat $lon
    if ($distance -le $searchRadius) {
        $results += [PSCustomObject]@{
            Name = $_.stop_name
            Area = $_.stop_area
            Distance = $distance
        }
    }
}

$results | Sort-Object Distance | ForEach-Object {
    Write-Host "Stop Name: $($_.Name), Area: $($_.Area), Distance: $($_.Distance) km"
}
