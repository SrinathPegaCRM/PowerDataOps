﻿# Command : `Get-XrmQueryFromFetch` 

## Description

**Retrieve query expression from fetch Xml.** : Convert FetchXml to QueryExpression.

## Inputs

Name|Type|Position|Required|Default|Description
----|----|--------|--------|-------|-----------
XrmClient|CrmServiceClient|1|false|$Global:XrmClient|Xrm connector initialized to target instance. Use latest one by default. (CrmServiceClient)
FetchXml|String|2|true||FetchXML query string.


## Usage

```Powershell 
Get-XrmQueryFromFetch [[-XrmClient] <CrmServiceClient>] [-FetchXml] <String> [<CommonParameters>]
``` 


