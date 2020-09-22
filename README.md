# tfspscmdlet
customize powershell cmdlet for managing field in ads

# support version
- Azure DevOps 2019
- Azure DevOps 2019.1

# function list
- Add-TfsField
- Add-TfsPicklist
- Get-TfsPicklist
- Remove-TfsPicklist
- Export-TfsFieldsToCsv

## Add-TfsField
### description
add/create new field in specified collection
### example
``` powershell
Add-TfsField -Organization Default -ReferenceName "Contoso.RiskLevel" -DisplayName "风险等级" -Description "用于风险评估的自定义字段" -FieldType picklistString -Items "无","低","中","高"
```

## Export-TfsFieldsToCsv
### description
export all fields in specified collection
### example
``` powershell
Export-TfsFieldsToCsv -Organization Default -FilePath C:\Test\default_fields.csv
```
