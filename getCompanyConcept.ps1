# "The company-concept API returns all the XBRL disclosures from a single company (CIK) and concept (a taxonomy and tag) into a single JSON file"
# get specific tag for specific company
function getCompanyConcept(){

    param(
    # default header by SEC
        [Parameter(Mandatory = $False)]
        [PSCustomObject]$header = $defaultHeader,
    # cik of company
        [Parameter(Mandatory = $False)]
        [string]$cik = $defaultCIK,
    # tested with us-gaap
        [Parameter(Mandatory = $False)]
        [string]$taxonomy = $defaultTaxonomy,
    # statement you're looking for
        [Parameter (Mandatory = $true)]
        [string]$tag = ($anyTag.key)
        )
    
# modify tag
    [string]$newTag = $tag + ".json"

# modify cik
    [string]$newCIK = "CIK" + $cik

# create dummy
    $responseGetCompanyConcept = [PSCustomObject]@{}

# request
    try{
        $responseGetCompanyConcept = Invoke-RestMethod "https://data.sec.gov/api/xbrl/companyconcept/$newCIK/$taxonomy/$newTag" -Method "GET" -Headers $header
    }
    catch [System.Net.WebException],[System.IO.IOException] {
        Add-Member -InputObject $responseGetCompanyConcept -NotePropertyName "notFound" -NotePropertyValue "NoSuchKey: $tag - The specified key does not exist"
        continue
    }

# the end
    return $responseGetCompanyConcept
}