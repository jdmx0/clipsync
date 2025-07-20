# === CONFIG ===
$source = "C:\VideoFolder"
$destination = "C:\CloudSyncedFolder"
$cpuThreshold = 40
$gpuThreshold = 40

function Get-CPUUsage {
    (Get-Counter '\Processor(_Total)\% Processor Time').CounterSamples.CookedValue
}

function Get-GPUUsage {
    $gpu = Get-Counter '\GPU Engine(*)\Utilization Percentage' -ErrorAction SilentlyContinue |
           Select-Object -ExpandProperty CounterSamples |
           Where-Object { $_.InstanceName -match 'engtype_3D' } |
           Measure-Object -Property CookedValue -Average
    return $gpu.Average
}

$cpu = Get-CPUUsage
$gpu = Get-GPUUsage

if (($cpu -lt $cpuThreshold) -and ($gpu -lt $gpuThreshold)) {
    Get-ChildItem -Path $source -File | ForEach-Object {
        Move-Item -Path $_.FullName -Destination $destination -Force
    }
}
