$ErrorActionPreference = "Continue"
Write-Output "== EVENTOS DE AUTENTICACION NPS RECIENTES =="
Get-WinEvent -FilterHashtable @{LogName="Security"; Id=6272,6273,6274,6278} -MaxEvents 5 -ErrorAction SilentlyContinue |
  ForEach-Object {
    Write-Output ("==== " + $_.TimeCreated + "  ID=" + $_.Id)
    Write-Output $_.Message
    Write-Output ""
  }
