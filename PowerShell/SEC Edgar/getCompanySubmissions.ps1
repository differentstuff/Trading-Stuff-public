# "This JSON data structure contains metadata such as current name, former name, and stock exchanges and ticker symbols of publicly-traded companies"
function getCompanySubmissions(){

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
    [PSCustomObject]$responseGetCompanySubmissions = Invoke-RestMethod "https://data.sec.gov/submissions/$newCIK" -Method "GET" -Headers $header

# the end
    return $responseGetCompanySubmissions
}