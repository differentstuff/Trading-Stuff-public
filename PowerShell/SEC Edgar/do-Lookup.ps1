function do-Lookup(){

    param(
        
    # default header by SEC
        [Parameter(Mandatory = $True)]
            [string]$inputData = "VTS"
        )

    # do webrequest
    $cikLookup = @{"company" = $inputData}
    [PSCustomObject]$responseGetCompanyConcept = Invoke-RestMethod "https://www.sec.gov/cgi-bin/cik_lookup" -Method "POST" -Headers $header -Body $cikLookup

    # the end
    return $responseGetCompanyConcept

# functions

    }

# https://www.sec.gov/edgar/searchedgar/cik