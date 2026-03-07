[CmdletBinding()]
param(
    [Parameter(Mandatory=$true, HelpMessage="Enter the path to the directory containing the parsed CSVs.")]
    [string]$CollectionPath,

    [Parameter(Mandatory=$true, HelpMessage="Enter the path to save the final Master_Timeline.csv file.")]
    [string]$OutputPath
)
try {
    Write-Host "
************************************************************************************************************************
* *
* WWWWWWWW                           WWWWWWWW   AAAAAAAAAAAAAAAAAAA   RRRRRRRRRRRRRRRRR   NNNNNNNN        NNNNNNNN   *
* W::::::W                           W::::::W  A:::::::::::::::::A  R::::::::::::::::R  N:::::::N       N:::::N   *
* W::::::W                           W::::::W  A:::::::::::::::::A  R::::::RRRRRR:::::R N::::::::N      N:::::N   *
* W::::::W                           W::::::W  AA:::::AAAAA:::::AA  RR:::::R     R:::::RN:::::::::N     N:::::N   *
* W:::::W           WWWWW           W:::::W     A::::A     A::::A    R::::R     R:::::RN::::::::::N    N:::::N   *
* W:::::W         W:::::W         W:::::W      A::::A     A::::A    R::::R     R:::::RN:::::::::::N   N:::::N   *
* W:::::W       W:::::::W       W:::::W       A::::AAAAA:::::AA    R::::RRRRRR:::::R  N::::N:::::::N  N:::::N   *
* W:::::W     W:::::::::W     W:::::W        A::::::::::::::AA     R:::::::::::::RR   N::::N N:::::::N N:::::N   *
* W:::::W   W:::::W:::::W   W:::::W         A::::AAAAA:::::AA    R::::RRRRRR:::::R  N::::N  N::::::NN:::::N   *
* W:::::W W:::::W W:::::W W:::::W          A::::A     A::::A    R::::R     R:::::R N::::N   N:::::NN::::N   *
* W:::::W:::::W   W:::::W:::::W           A::::A     A::::A    R::::R     R:::::R N::::N    N::::N::::N   *
* W:::::::::W     W:::::::::W            A::::A     A::::A  RR:::::R     R:::::RN::::N     N::::::::N   *
* W:::::::W       W:::::::W           AA:::::       :::::AA R::::::R     R:::::RN::::N      N:::::::N   *
* W:::::W         W:::::W            A:::::::       ::::A R::::::R     R:::::RN::::N       N::::::N   *
* W:::W           W:::W             A::::::::       :::A RRRRRRRR     RRRRRRRNNNNNNN        NNNNNNN   *
* WWW             WWW              AAAAAAAAAA        AAA                                            *
* *
* The ScreenSharer is not allowed to continue an inspection until this scan is finished.                            *
* You are free to move your mouse and tap away.                                                                     *
* Do not close this window as that may get you penalized for tampering.                                             *
* You have the right to disable mouse access for the next 2 minutes.                                                *
* *
************************************************************************************************************************
" -ForegroundColor Red

    
    if (-not (Test-Path -Path $CollectionPath)) {
        throw "[!!!] The specified collection directory does not exist: $CollectionPath"
    }

    if (-not (Test-Path -Path $OutputPath)) {
        Write-Host "[*] Output directory not found. Creating it: $OutputPath" -ForegroundColor Yellow
        New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
    }

    Write-Host "`n--- STAGE 1: Discovering Parsed Artifacts ---" -ForegroundColor Cyan
    Write-Host "[*] Searching for .csv files in: $CollectionPath"
    $csvFiles = Get-ChildItem -Path $CollectionPath -Recurse -Filter "*.csv"
    if ($csvFiles.Count -eq 0) {
        throw "No .csv files were found in the specified path. Nothing to process."
    }
    Write-Host "[*] Found $($csvFiles.Count) total CSV files."

    
    $skippedFilesPath = Join-Path $OutputPath "Skipped_For_Manual_Review"
    New-Item -ItemType Directory -Path $skippedFilesPath -Force | Out-Null

    
    Write-Host "`nParsing Data" -ForegroundColor Cyan
    $masterTimeline = [System.Collections.Generic.List[object]]::new()
    
    
    $genericTimestampHeaders = @('Timestamp', 'TimeCreated', 'LastRun', 'StartTime', 'Modified', 'Created', 'Accessed', 'LastWriteTime', 'CreationTime', 'LastAccessTime', 'FileKeyLastWriteTimestamp', 'TargetCreated')

    foreach ($csv in $csvFiles) {
        Write-Host "    -> Processing $($csv.FullName)..."

        
        if ((Get-Item $csv.FullName).Length -lt 5) {
             Write-Warning "           [!] File appears to be empty or is just a header. Skipping."
             continue
        }
        
        
        if ($csv.Name -like '*EvtxECmd*') {
            Write-Host "           [INFO] EvtxECmd file found. Copying for manual review: $($csv.Name)" -ForegroundColor Yellow
            Copy-Item -Path $csv.FullName -Destination $skippedFilesPath -Force
            continue
        }
        
        $sourceType = "Unknown"
        $importData = $null
        
        
        switch -Wildcard ($csv.Name) {
            '*PECmd*' {
                $sourceType = "Prefetch (PECmd)"
                $importData = Import-Csv -Path $csv.FullName | ForEach-Object {
                    [PSCustomObject]@{
                        Timestamp    = $_.LastRun
                        ActivityType = "Program Execution"
                        Source       = $sourceType
                        Details      = "Application '$($_.ProcessExe)' run. Run count: $($_.RunCount)."
                        SourceFile   = $_.SourceFilename
                    }
                }
            }
            '*AmcacheParser*' {
                $sourceType = "Amcache"
                $importData = Import-Csv -Path $csv.FullName | Where-Object { $_.FileKeyLastWriteTimestamp -ne $null } | ForEach-Object {
                    [PSCustomObject]@{
                        Timestamp    = $_.FileKeyLastWriteTimestamp
                        ActivityType = "Program Execution"
                        Source       = $sourceType
                        Details      = "Program '$($_.Name)' with path '$($_.Path)'. SHA1: $($_.SHA1)."
                        SourceFile   = $csv.Name
                    }
                }
            }
            '*JLECmd*' {
                $sourceType = "JumpList"
                $importData = Import-Csv -Path $csv.FullName | ForEach-Object {
                    [PSCustomObject]@{
                        Timestamp    = $_.TargetCreated
                        ActivityType = "File/Folder Access"
                        Source       = $sourceType
                        Details      = "Accessed path '$($_.TargetFullPath)' via JumpList."
                        SourceFile   = $_.SourceFile
                    }
                }
            }
            'Activities.csv' {
                $sourceType = "Windows Timeline"
                $importData = Import-Csv -Path $csv.FullName | ForEach-Object {
                    [PSCustomObject]@{
                        Timestamp    = $_.StartTime
                        ActivityType = $_.ActivityType
                        Source       = $sourceType
                        Details      = "App: '$($_.AppId)'. Display text: '$($_.DisplayText)'."
                        SourceFile   = $csv.FullName
                    }
                }
            }
            '*PcaAppLaunchDic*' {
                $sourceType = "Program Compatibility Assistant"
                $importData = Import-Csv -Path $csv.FullName | ForEach-Object {
                    [PSCustomObject]@{
                        Timestamp    = $_.Timestamp
                        ActivityType = "Program Execution"
                        Source       = $sourceType
                        Details      = "PCA tracked execution of '$($_.Path)'."
                        SourceFile   = $csv.Name
                    }
                }
            }
            '*TaskScheduler_Execution*' {
                $sourceType = "Task Scheduler Log"
                $importData = Import-Csv -Path $csv.FullName | ForEach-Object {
                    [PSCustomObject]@{
                        Timestamp    = $_.TimeCreated
                        ActivityType = "Scheduled Task Execution"
                        Source       = $sourceType
                        Details      = "Task '$($_.TaskName)' started or completed. Event ID: $($_.Id)."
                        SourceFile   = $csv.Name
                    }
                }
            }
            '*ServiceControlManager*' {
                $sourceType = "Service Control Manager Log"
                $importData = Import-Csv -Path $csv.FullName | ForEach-Object {
                    [PSCustomObject]@{
                        Timestamp    = $_.TimeCreated
                        ActivityType = "Service Start/Stop"
                        Source       = $sourceType
                        Details      = $_.Message
                        SourceFile   = $csv.Name
                    }
                }
            }
            default {
                # Hello there
                try {
                    $csvData = Import-Csv -Path $csv.FullName -ErrorAction Stop
                    $headers = $csvData[0].PSObject.Properties.Name
                    $timestampColumn = $headers | Where-Object { $genericTimestampHeaders -contains $_ } | Select-Object -First 1

                    if ($timestampColumn) {
                        $sourceType = "Generic CSV ($($csv.Name))"
                        $importData = $csvData | ForEach-Object {
                            $row = $_
                            $detailsArray = $headers | ForEach-Object { if($_ -ne $timestampColumn) { "$_=$($row.$_)" } }
                            $detailsString = $detailsArray -join '; '
                            [PSCustomObject]@{
                                Timestamp    = $row.$timestampColumn
                                ActivityType = "Generic CSV Event"
                                Source       = $sourceType
                                Details      = $detailsString
                                SourceFile   = $csv.Name
                            }
                        }
                    } else {
                        Write-Host "           [INFO] No timestamp column found. Copying for manual review: $($csv.Name)" -ForegroundColor Yellow
                        Copy-Item -Path $csv.FullName -Destination $skippedFilesPath -Force
                    }
                } catch {
                     Write-Warning "           [!] Failed to generically parse $($csv.Name): $($_.Exception.Message)"
                }
            }
        }
        
        if ($null -ne $importData) {
            $addedCount = 0
            foreach($item in $importData){
                $masterTimeline.Add($item)
                $addedCount++
            }
            Write-Host "           [SUCCESS] Parsed $addedCount records from $sourceType." -ForegroundColor Green
        }
    }

    Write-Host "`n Exporting Master Timeline ---" -ForegroundColor Cyan
    if ($masterTimeline.Count -eq 0) {
        Write-Warning "⚠️ No data could be parsed for the main timeline."
    } else {
        Write-Host "✅ Parsed and wrote total of $($masterTimeline.Count) events for the main timeline."
        Write-Host "... Sorting timeline chronologically..."
        $sortedTimeline = $masterTimeline | Sort-Object -Property Timestamp
        
        $outputFile = Join-Path $OutputPath "Master_Timeline.csv"
        Write-Host "[*] Exporting to: $outputFile"
        $sortedTimeline | Export-Csv -Path $outputFile -NoTypeInformation
        Write-Host "    -> Final timeline saved to: $outputFile"
    }

    Write-Host "`nFinalizing Skipped Files" -ForegroundColor Cyan
    $finalSkippedCount = (Get-ChildItem -Path $skippedFilesPath).Count
    if ($finalSkippedCount -gt 0) {
        Write-Host "🪷 A total of $finalSkippedCount files were copied to the following directory for manual review:"
        Write-Host "    -> $skippedFilesPath"
    } else {
        Write-Host "🪷 No files were skipped or copied for manual review."
    }

    Write-Host "`n🪷 Master timeline generation complete!" -ForegroundColor Green
    
} catch {
    Write-Error "⚠️ A critical error occurred: $($_.Exception.Message) ⚠️"
    Write-Error "⚠️ Script execution halted.⚠️"
}
