$f = "C:\Windows\Temp\win_02_promote.ps1"
Get-Item $f | Select-Object LastWriteTime,Length | Format-List
$line = (Get-Content $f | Where-Object {$_ -match "ConvertTo-SecureString"} | Select-Object -First 1)
Write-Output ("linea contiene placeholder: " + ($line -match "\{\{"))
Write-Output ("longitud de la linea: " + $line.Length)
Write-Output ("tiene simbolo: " + ($line -match "[!@#%^*_+=-]"))
Write-Output ("tiene mayus/minus/digito: " + (($line -cmatch "[A-Z]") -and ($line -cmatch "[a-z]") -and ($line -match "[0-9]")))
