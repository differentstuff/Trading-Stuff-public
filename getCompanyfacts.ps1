# "This API returns all the company concepts data for a company into a single API call"
function getCompanyfacts(){

    param(
    # default header by SEC
    [Parameter(Mandatory = $False)]
    [PSCustomObject]$header = $defaultHeader,
    # cik of company
    [Parameter(Mandatory = $False)]
    [string]$cik = $defaultCIK
    )


# modify cik
    [string]$newCIK = "CIK" + $cik + ".json"

# request
    [PSCustomObject]$responseGetCompanyfacts = Invoke-RestMethod "https://data.sec.gov/api/xbrl/companyfacts/$newCIK" -Method "GET" -Headers $header

# the end
    return $responseGetCompanyfacts
}