$Global:Tfs_User='name'
$Global:Tfs_PAT='pat'
$Global:TfsHost='http://yourazuredevops';
$Global:SuccessCode=200,201,204;

$Global:Base64Token=[Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $Tfs_User,$Tfs_PAT)))
$Global:RestHeaders=@{
    Authorization=("Basic {0}" -f $Base64Token)
}

Function Add-TfsField{
Param(
    [Parameter(
    Mandatory=$true,
    ValueFromPipeline=$true,
    ValueFromPipelineByPropertyName=$true,
    HelpMessage="集合名称")]
    [string]$Organization,

    [Parameter(
    Mandatory=$true,
    ValueFromPipeline=$true,
    ValueFromPipelineByPropertyName=$true,
    HelpMessage="字段ID")]
    [string]$ReferenceName,

    [Parameter(
    Mandatory=$true,
    ValueFromPipeline=$true,
    ValueFromPipelineByPropertyName=$true,
    HelpMessage="字段显示名")]
    [string]$DisplayName,

    [Parameter(
    Mandatory=$false,
    ValueFromPipeline=$true,
    ValueFromPipelineByPropertyName=$true,
    HelpMessage="字段描述")]
    [string]$Description,

    [Parameter(
    Mandatory=$false,
    ValueFromPipeline=$true,
    ValueFromPipelineByPropertyName=$true,        
    HelpMessage='列表Id')]
    [ValidateSet("boolean","dateTime","double","html","identity","integer","picklistDouble","picklistInteger","picklistString","plainText","string")]
    [string]$FieldType,

    [Parameter(
    Mandatory=$false,
    ValueFromPipeline=$true,
    ValueFromPipelineByPropertyName=$true,
    HelpMessage="字段值列表，picklist类型时必选")]
    [array]$Items
)
# POST https://dev.azure.com/{organization}/{project}/_apis/wit/fields?api-version=5.0
$uri="$($TfsHost)/$($Organization)/_apis/wit/fields?api-version=5.0"

if($Description -eq $null){
    $Description="this is a customize filed";
}
$isIdentity=$false;
$isPicklist=$false;
$picklistId=$null;
$fieldValueType=$FieldType;
$pickListValueType=$null;
$picklistId=$null;

if($FieldType -eq "identity"){
    $isIdentity=$true;
    $fieldValueType="string";
}
elseif($FieldType -eq "picklistDouble"){
    $isPicklist=$true;
    $pickListValueType="double";
    $fieldValueType="double";
}
elseif($FieldType -eq "picklistInteger"){
    $isPicklist=$true;
    $pickListValueType="integer";
    $fieldValueType="integer";
}
elseif($FieldType -eq "picklistString"){
    $isPicklist=$true;
    $pickListValueType="string";
    $fieldValueType="string";
}

if($isPicklist -eq $true){
    $picklistName="picklist_"+$ReferenceName.Replace(".","")
    $picklistId=(Add-TfsPicklist -Organization $Organization -Name $picklistName -FieldType $pickListValueType -Items $Items).id
}

$reqBody=@{
    referenceName=$ReferenceName;
    name=$DisplayName;
    description=$Description;
    type=$fieldValueType;
    isIdentity=$isIdentity;
    isPicklist=$isPicklist;
    picklistId=$picklistId;
}

$response=Invoke-WebRequest -Uri $uri -Method POST -Body ($reqBody|ConvertTo-Json) -ContentType "application/json; charset=utf-8" -Headers $RestHeaders
if($SuccessCode -contains $response.StatusCode){
    $RetObject=$response.Content|ConvertFrom-Json
    $RetObject
}
else{
    Write-Warning "Add Field Failed"
}

}

Function Add-TfsPicklist{
Param(
    [Parameter(
    Mandatory=$true,
    ValueFromPipeline=$true,
    ValueFromPipelineByPropertyName=$true,
    HelpMessage="集合名称")]
    [string]$Organization,

    [Parameter(
    Mandatory=$true,
    ValueFromPipeline=$true,
    ValueFromPipelineByPropertyName=$true,
    HelpMessage="名字")]
    [string]$Name,

    [Parameter(
    Mandatory=$false,
    ValueFromPipeline=$true,
    ValueFromPipelineByPropertyName=$true,        
    HelpMessage='类型')]
    [ValidateSet("double","integer","string")]
    [string]$FieldType,

    [Parameter(
    Mandatory=$true,
    ValueFromPipeline=$true,
    ValueFromPipelineByPropertyName=$true,
    HelpMessage="列表")]
    [array]$Items
)
# POST https://dev.azure.com/{organization}/_apis/work/processes/lists?api-version=5.0-preview.1
$uri="$($TfsHost)/$($Organization)/_apis/work/processes/lists?api-version=5.0-preview.1"

if($Description -eq $null){
    $Description="this is a customize filed";
}

$reqBody=@{
    name=$Name;
    type=$FieldType;
    items=$Items
}

$response=Invoke-WebRequest -Uri $uri -Method POST -Body ($reqBody|ConvertTo-Json) -ContentType "application/json; charset=utf-8" -Headers $RestHeaders

if($SuccessCode -contains $response.StatusCode){
    $RetObject=$response.Content|ConvertFrom-Json
    $RetObject
}
else{
    Write-Warning "Queue Build Failed"
}

}


Function Get-TfsPicklist{
Param(
    [Parameter(
    Mandatory=$true,
    ValueFromPipeline=$true,
    ValueFromPipelineByPropertyName=$true,
    HelpMessage="集合名称")]
    [string]$Organization
)
# GET https://dev.azure.com/{organization}/_apis/work/processes/lists?api-version=5.0-preview.1
$uri="$($TfsHost)/$($Organization)/_apis/work/processes/lists?api-version=5.0-preview.1"

$response=Invoke-WebRequest -Uri $uri -Method GET -ContentType "application/json" -Headers $RestHeaders
if($SuccessCode -contains $response.StatusCode){
    $RetObject=$response.Content|ConvertFrom-Json
    $RetObject
}
else{
    Write-Warning "Get PickList Failed"
}

}

Function Remove-TfsPicklist{
Param(
    [Parameter(
    Mandatory=$true,
    ValueFromPipeline=$true,
    ValueFromPipelineByPropertyName=$true,
    HelpMessage="集合名称")]
    [string]$Organization,

    [Parameter(
    Mandatory=$true,
    ValueFromPipeline=$true,
    ValueFromPipelineByPropertyName=$true,        
    HelpMessage='PicklistID')]
    [string]$PicklistID
)
# DELETE https://dev.azure.com/{organization}/_apis/work/processes/lists/{listId}?api-version=5.0-preview.1
$uri="$($TfsHost)/$($Organization)/_apis/work/processes/lists/$($PicklistID)?api-version=5.0-preview.1"

$response=Invoke-WebRequest -Uri $uri -Method DELETE -ContentType "application/json" -Headers $RestHeaders
$response
if($SuccessCode -contains $response.StatusCode){
    $RetObject=$response.Content|ConvertFrom-Json
    $RetObject
}
else{
    Write-Warning "Delete PickList Failed"
}

}


Function Export-TfsFieldsToCsv{
<#
    .SYNOPSIS
        更新列表字段的值清单

    .DESCRIPTION
        更新列表字段的值清单

    .PARAMETER Organization
        集合名称

    .PARAMETER FilePath
        输出文件路径

    .EXAMPLE
        # 导出集合内所有字段到CSV
        PS C:\> Export-TfsFieldsToCsv -Organization default
#>
Param(
    [Parameter(
    Mandatory=$true,
    ValueFromPipeline=$true,
    ValueFromPipelineByPropertyName=$true,
    HelpMessage="集合名称")]
    [string]$Organization,

    [Parameter(
    Mandatory=$true,
    ValueFromPipeline=$true,
    ValueFromPipelineByPropertyName=$true,        
    HelpMessage='输出的文件路径')]
    [string]$FilePath
)
# GET https://dev.azure.com/{organization}/_apis/wit/fields?api-version=5.1
$uri="$($TfsHost)/$($Organization)/_apis/wit/fields?api-version=5.1"

$response=Invoke-WebRequest -Uri $uri -Method GET -ContentType "application/json" -Headers $RestHeaders
if($SuccessCode -contains $response.StatusCode){
    $RetObject=$response.Content|ConvertFrom-Json
    $RetObject.value|Export-Csv -Path $FilePath -Encoding UTF8 -NoTypeInformation
}
else{
    Write-Warning "Export Fields to CSV Failed"
}

}

Function Find-TfsFields{
<#
    .SYNOPSIS
        按关键字在集合内查找特定字段

    .DESCRIPTION
        按关键字在集合内查找特定字段，支持按名字或ReferenceName

    .PARAMETER Organization
        集合名称

    .PARAMETER Keyword
        查询关键字

    .EXAMPLE
        # 按关键字查找字段
        PS C:\> Find-TfsFields -Organization default -Keyword test
#>
Param(
    [Parameter(
    Mandatory=$true,
    ValueFromPipeline=$true,
    ValueFromPipelineByPropertyName=$true,
    HelpMessage="集合名称")]
    [string]$Organization,

    [Parameter(
    Mandatory=$true,
    ValueFromPipeline=$true,
    ValueFromPipelineByPropertyName=$true,        
    HelpMessage='查询关键字')]
    [string]$Keyword
)
# GET https://dev.azure.com/{organization}/_apis/wit/fields?api-version=5.1
$uri="$($TfsHost)/$($Organization)/_apis/wit/fields?api-version=5.1"

$response=Invoke-WebRequest -Uri $uri -Method GET -ContentType "application/json" -Headers $RestHeaders
if($SuccessCode -contains $response.StatusCode){
    $RetObject=$response.Content|ConvertFrom-Json    
    $RetObject.value|Where-Object { $_.referenceName.ToLower().Contains($Keyword.ToLower()) -or $_.name.ToLower().Contains($Keyword.ToLower()) }
}
else{
    Write-Warning "Find field failed"
}

}


Function Find-TfsProcesses{
<#
    .SYNOPSIS
        根据关键字或ID查找进程信息

    .DESCRIPTION
        根据关键字或ID查找进程信息

    .PARAMETER Organization
        集合名称

    .PARAMETER Keyword
        进程关键字

    .EXAMPLE
        # 导出集合内所有字段到CSV
        PS C:\> Find-TfsProcesses -Organization default -Keyword Demo
#>
Param(
    [Parameter(
    Mandatory=$true,
    ValueFromPipeline=$true,
    ValueFromPipelineByPropertyName=$true,
    HelpMessage="集合名称")]
    [string]$Organization,

    [Parameter(
    Mandatory=$false,
    ValueFromPipeline=$true,
    ValueFromPipelineByPropertyName=$true,        
    HelpMessage='查询关键字')]
    [string]$Keyword=$null
)
# GET https://dev.azure.com/{organization}/_apis/work/processes?api-version=5.1
$uri="$($TfsHost)/$($Organization)/_apis/work/processes?api-version=5.1-preview.2"

$response=Invoke-WebRequest -Uri $uri -Method GET -ContentType "application/json" -Headers $RestHeaders
if($SuccessCode -contains $response.StatusCode){
    $RetObject=$response.Content|ConvertFrom-Json    
    if($Keyword -eq $null){
        $RetObject
    }
    else{
        $RetObject.value|Where-Object { $_.typeId.ToLower().Contains($Keyword.ToLower()) -or $_.name.ToLower().Contains($Keyword.ToLower()) }
    }
}
else{
    Write-Warning "Find field failed"
}

}

Function Find-TfsWorkItemTypes{
<#
    .SYNOPSIS
        根据关键字或ID查找工作项类型信息

    .DESCRIPTION
        根据关键字或ID查找工作项类型信息

    .PARAMETER Organization
        集合名称

    .PARAMETER Keyword
        进程关键字

    .EXAMPLE
        # 导出集合内所有字段到CSV
        PS C:\> Find-TfsWorkItemTypes -Organization default -ProcessName test -Keyword Demo
#>
Param(
    [Parameter(
    Mandatory=$true,
    ValueFromPipeline=$true,
    ValueFromPipelineByPropertyName=$true,
    HelpMessage="集合名称")]
    [string]$Organization,

    [Parameter(
    Mandatory=$true,
    ValueFromPipeline=$true,
    ValueFromPipelineByPropertyName=$true,        
    HelpMessage='进程名')]
    [string]$ProcessName,

    [Parameter(
    Mandatory=$false,
    ValueFromPipeline=$true,
    ValueFromPipelineByPropertyName=$true,        
    HelpMessage='查询关键字')]
    [string]$Keyword=$null
)

$processId = (Find-TfsProcesses -Organization $Organization -Keyword $ProcessName).typeId

# GET https://dev.azure.com/{organization}/_apis/work/processes/{processId}/workitemtypes?api-version=5.1-preview.2
$uri="$($TfsHost)/$($Organization)/_apis/work/processes/$($processId)/workitemtypes?api-version=5.1-preview.2"

$response=Invoke-WebRequest -Uri $uri -Method GET -ContentType "application/json" -Headers $RestHeaders
if($SuccessCode -contains $response.StatusCode){
    $RetObject=$response.Content|ConvertFrom-Json    
    if($Keyword -eq $null){
        $RetObject
    }
    else{
        $RetObject.value|Where-Object { $_.referenceName.ToLower().Contains($Keyword.ToLower()) -or $_.name.ToLower().Contains($Keyword.ToLower()) }
    }
}
else{
    Write-Warning "Find tfs WorkItemTypes failed"
}

}

Function Get-TfsWorkItemFields{
<#
    .SYNOPSIS
        更新列表字段的值清单

    .DESCRIPTION
        更新列表字段的值清单

    .PARAMETER Organization
        集合名称

    .PARAMETER FilePath
        输出文件路径

    .EXAMPLE
        # 导出集合内所有字段到CSV
        PS C:\> Export-TfsFieldsToCsv -Organization default
#>
Param(
    [Parameter(
    Mandatory=$true,
    ValueFromPipeline=$true,
    ValueFromPipelineByPropertyName=$true,
    HelpMessage="集合名称")]
    [string]$Organization,

    [Parameter(
    Mandatory=$true,
    ValueFromPipeline=$true,
    ValueFromPipelineByPropertyName=$true,        
    HelpMessage='进程名')]
    [string]$ProcessName,

    [Parameter(
    Mandatory=$true,
    ValueFromPipeline=$true,
    ValueFromPipelineByPropertyName=$true,        
    HelpMessage='工作项名')]
    [string]$WitName
)

$processId = (Find-TfsProcesses -Organization $Organization -Keyword $ProcessName).typeId
$witTypeRefName=(Find-TfsWorkItemTypes -Organization $Organization -ProcessName $ProcessName -Keyword $WitName ).referenceName
# GET https://dev.azure.com/{organization}/_apis/work/processes/{processId}/workItemTypes/{witRefName}/fields?api-version=5.1-preview.2
$uri="$($TfsHost)/$($Organization)/_apis/work/processes/$($processId)/workItemTypes/$($witTypeRefName)/fields?api-version=5.1-preview.2"

$response=Invoke-WebRequest -Uri $uri -Method GET -ContentType "application/json" -Headers $RestHeaders
if($SuccessCode -contains $response.StatusCode){
    $RetObject=$response.Content|ConvertFrom-Json    
    $RetObject.value
}
else{
    Write-Warning "Get TfsWorkItemFields failed"
}

}
