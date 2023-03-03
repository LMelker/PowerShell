$pass = ''

$user = 'api-iam'
$pair = "$($user):$($pass)"
$encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($pair))
$basicAuthValue = "Basic $encodedCreds"
$Headers = @{Authorization = $basicAuthValue}
$jiraHost = "192.168.218.131"  #test

<# $OmbordStigningsMatrosen = [PSCustomObject]@{
    tilltal    = 'Lars'
    efternamn  = 'Melker'
    namn       = 'Lars Melker'
    enhet      = 'Enheten för Drift & Förvaltningen'
    avdelning  = 'Avdelningen för Digitaliseringen'
    Resurstyp  = 'Konsult'
    Resursnr   = '1234'
    Kostnad    = '450'
    chef       = 'larmel'
}

$OmbordStigningsMatrosen.namn #>


    $OmbordStigningsMatrosen_tilltal    = 'Lars'
    $OmbordStigningsMatrosen_efternamn  = 'Melker'
    $OmbordStigningsMatrosen_namn       = 'Lars Melker'
    $OmbordStigningsMatrosen_enhet      = 'Enheten för Drift & Förvaltningen'
    $OmbordStigningsMatrosen_avdelning  = 'Avdelningen för Digitaliseringen'
    $OmbordStigningsMatrosen_Resurstyp  = 'Konsult'
    $OmbordStigningsMatrosen_Resursnr   = '1234'
    $OmbordStigningsMatrosen_Kostnad    = '450'
    $OmbordStigningsMatrosen_chef       = 'larmel'



$jiraStatus = '-'
$Response = '-'
$CreatedEpicKey = '-'
$CreatedIssueKe = '-'

echo "Host:   $jiraHost"
echo "Status: $jiraStatus"
echo "Res:    $Response"
echo "Epic:   $CreatedEpicKey"
echo "Issue:  $CreatedIssueKey"


$Response = Invoke-WebRequest -Uri "https://$JiraHost/jira/status" -Headers $Headers -ContentType "application/json; charset=utf-8" -Method Get -SkipCertificateCheck
$Response

$jiraStatus = ($Response.content | ConvertFrom-Json).state

$jiraStatus
echo "Status: $jiraStatus"


# https://developer.atlassian.com/server/jira/platform/jira-rest-api-examples/
# https://jiratest.havochvatten.se/jira/rest/api/2/issue/HR-60


echo "Host:   $jiraHost"
echo "Status: $jiraStatus"
echo "Res:    $Response"
echo "Epic:   $CreatedEpicKey"
echo "Issue:  $CreatedIssueKey"



 $CreateHRpayload = @"
 {
    "fields": {
       "project":
       {
          "key": "HR"
       },
       "assignee":{"name":"$user"},
       "summary": "Ombordstigning av $OmbordStigningsMatrosen_namn",
       "description": "Övergripande Epic för Ombordstigning av $OmbordStigningsMatrosen_namn",
       "customfield_10251":"Ombordstigning av $OmbordStigningsMatrosen_namn", 
       "customfield_11451":"$OmbordStigningsMatrosen_tilltal",        
       "customfield_11452":"$OmbordStigningsMatrosen_efternamn",     
       "customfield_11454": "$OmbordStigningsMatrosen_enhet",          
       "customfield_15350":"$OmbordStigningsMatrosen_avdelning",
       "customfield_15351":"$OmbordStigningsMatrosen_resurstyp",
       "customfield_15352":"$OmbordStigningsMatrosen_resursnr",
       "customfield_15353": $OmbordStigningsMatrosen_kostnad,
       "customfield_15354":"$OmbordStigningsMatrosen_chef",

       "issuetype": {
          "name": "Epic"
       }
   }
}
"@

$CreateHRpayload = ($CreateHRpayload) -replace '^//.*' | ConvertFrom-Json |ConvertTo-Json -Depth 3

# /rest/api/2/issue/
$Response = Invoke-WebRequest -Uri "https://$JiraHost/jira/rest/api/2/issue/" -Headers $Headers -Body $CreateHRpayload -ContentType "application/json; charset=utf-8" -Method Post -SkipCertificateCheck 
$Response

$CreatedEpicKey = ($Response.content | ConvertFrom-Json).key

$CreatedEpicKey


# https://developer.atlassian.com/server/jira/platform/jira-rest-api-examples/
echo "Host:   $jiraHost"
echo "Status: $jiraStatus"
echo "Res:    $Response"
echo "Epic:   $CreatedEpicKey"
echo "Issue:  $CreatedIssueKey"


 $CreateHRpayload = @"
 {
    "fields": {
       "project":
       {
          "key": "HR"
       },
       "assignee":{"name":"$user"},
       "summary": "Tekniska resurser för ${OmbordStigningsMatrosen_namn}",
       "description": "Skapar tekniska resurser för ombordstigningen av ${OmbordStigningsMatrosen_namn}",
       "customfield_10250": "$CreatedEpicKey",  
       "customfield_11451":"$OmbordStigningsMatrosen_tilltal",        
       "customfield_11452":"$OmbordStigningsMatrosen_efternamn",     
       "customfield_11454": "$OmbordStigningsMatrosen_enhet",          
       "customfield_15350":"$OmbordStigningsMatrosen_avdelning",
       "customfield_15351":"$OmbordStigningsMatrosen_resurstyp",
       "customfield_15352":"$OmbordStigningsMatrosen_resursnr",
       "customfield_15353": $OmbordStigningsMatrosen_kostnad,
       "customfield_15354":"$OmbordStigningsMatrosen_chef",
       "issuetype": {
          "name": "Ombordstigning"
       }
   }
}
"@

$CreateHRpayload = ($CreateHRpayload) -replace '^//.*' | ConvertFrom-Json |ConvertTo-Json -Depth 3

# /rest/api/2/issue/
$Response = Invoke-WebRequest -Uri "https://$JiraHost/jira/rest/api/2/issue/" -Headers $Headers -Body $CreateHRpayload -ContentType "application/json; charset=utf-8" -Method Post -SkipCertificateCheck 
$Response

$CreatedIssueKey = ($Response.content | ConvertFrom-Json).key

$CreatedIssueKey


$CreateHRpayload = @"
{
    "update": {
        "comment": [
            {
                "add": {
                    "body": "Starta detta ärende."
                }
            }
        ]
    },
    "fields": {
    },
    "transition": {
        "id": "11"
    }
}
"@

# /rest/api/2/issue/
$Response = Invoke-WebRequest -Uri "https://$JiraHost/jira/rest/api/2/issue/$CreatedIssueKey/transitions" -Headers $Headers -Body $CreateHRpayload -ContentType "application/json; charset=utf-8" -Method Post -SkipCertificateCheck 
$Response

$CreatedIssueKey = ($Response.content | ConvertFrom-Json).key

$CreatedIssueKey



