# tfspscmdlet
customize powershell cmdlet for managing field in ads

# support version
- Azure DevOps 2019
- Azure DevOps 2019.1

# Prerequisites
run the below command in powershell console.
``` powershell
Set-ExecutionPolicy -ExecutionPolicy Unrestricted
```

# how to use
- config tfs information in line 2,3
``` powershell
$Global:Tfs_PAT='pat' # your pat
$Global:TfsHost='http://yourazuredevops'; # your azure devops hostname
```

- select total content, press F8

- read documents
[function list](https://github.com/niyw/tfspscmdlet/wiki/function-list)

