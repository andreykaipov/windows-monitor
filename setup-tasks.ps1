# The keys in the following dictionaries correspond to flags for the New-ScheduledTaskAction cmdlet
$startupServices = @{
    OhmGraphite = @{
        Execute = "E:\windows-monitor\programs\OhmGraphite-0.16.0\OhmGraphite.exe"
        WorkingDirectory = "E:\windows-monitor\programs\OhmGraphite-0.16.0"
    }
    Prometheus = @{
        Execute = "E:\windows-monitor\programs\prometheus-2.23.0.windows-amd64\prometheus.exe"
        WorkingDirectory = "E:\windows-monitor\programs\prometheus-2.23.0.windows-amd64"
        Argument = "--config.file E:\windows-monitor\conf\prometheus.yml --storage.tsdb.path E:\windows-monitor\data --storage.tsdb.retention.time 180d"
    }
    Grafana = @{
        Execute ="E:\windows-monitor\programs\grafana-7.3.6\bin\grafana-server.exe"
        WorkingDirectory ="E:\windows-monitor\programs\grafana-7.3.6"
        Argument = "--config E:\windows-monitor\conf\grafana.ini"
    }
}

$tasksPath = "\Windows Monitor"

$user = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name

$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM"
$trigger = New-ScheduledTaskTrigger -AtStartup
$settings = New-ScheduledTaskSettingsSet `
    -DisallowHardTerminate `
    -DisallowStartOnRemoteAppSession `
    -ExecutionTimeLimit 0

$startupServices.GetEnumerator() | ForEach-Object {
    $name = $_.Name
    $service = $_.Value

    $action = New-ScheduledTaskAction @service

    $task = New-ScheduledTask `
        -Principal $principal `
        -Trigger $trigger `
        -Action $action `
        -Settings $settings

    Register-ScheduledTask `
        -InputObject $task `
        -TaskPath $tasksPath `
        -TaskName $name `
        -Force
}