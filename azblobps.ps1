#your source folder
$srcPath="C:\test"
$bsas="?sv=2019-12-12&ss=b&srt=co&sp=rwdlac&se=2020-09-30T09:42:00Z&st=2020-09-28T01:40:15Z&spr=https&sig=lX0LJbiZtCEPKpvBDQmf8fp%2BKQzDqSL8iqC1%2FJEWRW4%3D";
#your blob container url
$containderUrl="https://xxxxxxx.blob.core.windows.net/xxxx/";

$headers = @{
    'x-ms-blob-type' = 'BlockBlob'
}
(Get-ChildItem -Path $srcPath)|ForEach-Object{
    $fName=$_.Name;
    $fPath=$_.FullName;
    $bUri=$containderUrl+$fName+$bsas
    Invoke-RestMethod -Uri $bUri -Method Put -Headers $headers -InFile $fPath
}
