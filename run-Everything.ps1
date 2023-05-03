
# do a complete run
function run-Everything(){

    param(
    # default header by SEC
    [Parameter(Mandatory = $True)]
    [string]$defaultCIK
    )

# should be permanent parameter
[PSCustomObject]$defaultHeader = @{"User-Agent" =  "EZ Financial Services ezadminAAB@ezfinancials.com"} #modify as needed => must comply SEC & Laws
[string]$defaultTaxonomy = "us-gaap" # only tested with us-gaap
[string]$defaultCurrecy = "USD" # only tested with USD
[string]$PWDonStart = "C:\Temp\Results"

# should be variable parameter
[string]$defaultFileName = "Report" # will append: "-cik000123456"
[int]$defaultAppendDateToFilename = 1 # 0=no 1=DDMMYYYY 2=DDMMYYYY-hhmm // will append: "-20042022-0815"
[string]$defaultTitle = "Title"
[string]$defaultWorksheetName = "Report"
[string]$defaultTableStyle = "Medium6"
[string]$defaultChartStyle = "Line"
[int]$defaultTitleSize = 30
[int]$defaultStartRow = 20
[bool]$defaultdeleteExcelFileBeforeFirstRun = 1 # 0=off 1=on //recommanded:0


# settings
## All Tags needed
$listOfAllTags = @{
  "UnamortizedDebtIssuanceExpense" = "Unamortized Debt Issuance Expense"
  "StockholdersEquity" = "Stockholders Equity"
  "ShareBasedCompensation" = "ShareBased Compensation"
  "SellingGeneralAndAdministrativeExpense" = "Selling General And Administrative (Expense)"
  "Revenues" = "Revenue"
  "ResearchAndDevelopmentExpense" = "Research And Development (or Expense)"
  "ProductWarrantyExpense" = "Product Warranty Expense"
  "OtherNonoperatingIncomeExpense" = "Other Nonoperating Income (or Expense)"
  "OtherNoncashIncomeExpense" = "Other Noncash Income (or Expense)"
  "OperatingIncomeLoss" = "Operating Income (or Loss)"
  "OperatingExpenses" = "Operating Expenses"
  "NetIncomeLoss" = "Net Income (or Loss)"
  "NetCashProvidedByUsedInOperatingActivities" = "Net Cash Provided By (Used In) Operating Activities"
  "NetCashProvidedByUsedInContinuingOperations" = "Net Cash Provided By (Used In) Continuing Operations"
  "MarketingAndAdvertisingExpense" = "Marketing And Advertising Expense"
  "LitigationSettlementExpense" = "Litigation Settlement Expense"
  "InterestPaid" = "Interest Paid"
  "InterestExpense" = "Interest Expense"
  "IncomeTaxExpenseBenefit" = "Income Tax Expense (Benefit)"
  "EmployeeServiceShareBasedCompensationAllocationOfRecognizedPeriodCostsCapitalizedAmount" = "Employee Service ShareBased Compensation (Allocation Of) Recognized Period Costs Capitalized Amount"
  "CommonStockValue" = "Common Stock Value"
  "AllocatedShareBasedCompensationExpense" = "Allocated ShareBased Compensation (Expense)"
}

## all Filing Formats
$listOfAllFilings = @{
  "One" = "10-K"
  #"Two" = "10-Q"
  #"Three" = "10-k/A"
  #"Four" = "10-A"
}

# options
# option: remove local file
    if($defaultdeleteExcelFileBeforeFirstRun -eq $True){
        if($xlTempFile){
    # remove file
            Remove-Item $xlTempFile -ErrorAction SilentlyContinue
    }}
    if($defaultdeleteExcelFileBeforeFirstRun -eq $False){

    # do nothing
        continue

    }

# option: append date to filename
    if($defaultAppendDateToFilename -eq 2){
        [string]$xlTempFile = "$PWDonStart\$defaultFileName-" + "cik" + $defaultCIK + "-" + (Get-Date -Format "ddMMyyyy-HHmm") + ".xlsx"
        }
    if($defaultAppendDateToFilename -eq 1){
        [string]$xlTempFile = "$PWDonStart\$defaultFileName-" + "cik" + $defaultCIK + "-" + (Get-Date -Format "ddMMyyyy") + ".xlsx"
        }
    if($defaultAppendDateToFilename -eq 0){
        [string]$xlTempFile = "$PWDonStart\$defaultFileName-" + "cik" + $defaultCIK + ".xlsx"
        }

# Runtime
# create dummy
$resultOfAllTags = [PSCustomObject]{}
$allResultOfAllTags = [PSCustomObject]@()

# request all data
foreach($anyTag in $listOfAllTags.GetEnumerator()){

    # create dummy
    $getCompanyConceptResult = [PSCustomObject]@()

    # get data
    $getCompanyConceptResult = getCompanyConcept -tag ($anyTag.key) -header $defaultHeader -cik $defaultCIK -taxonomy $defaultTaxonomy

    # add to final object
    Add-Member -InputObject $resultOfAllTags -NotePropertyName ($getCompanyConceptResult.tag) -NotePropertyValue ($getCompanyConceptResult) -Force

    }

# stop, if no results
if((Get-Member -InputObject $resultOfAllTags -MemberType NoteProperty).count -eq 0){
    foreach($tempKey in $allCIKs.GetEnumerator()){ if($tempKey.Key -eq $defaultCIK){$name = $tempKey.Value}}
    Write-Host -ForegroundColor DarkBlue -BackgroundColor Cyan "Not a single Results captured for:" , $name
    break
    }

# get all results
$allResultOfAllTags = (Get-Member -InputObject $resultOfAllTags -MemberType NoteProperty)

# export everything per page
foreach($oneResultOfAllTags in $allResultOfAllTags){

    # create dummy
    $sortedObject = [PSCustomObject]@()

    # sort data by filing date
    $sortedObject = $resultOfAllTags.($oneResultOfAllTags.Name).units.$defaultCurrecy | Sort-Object -Descending filed

    # filter out unique
    $uniqueResult = [PSCustomObject]@()
    $uniqueResult = getUnique -inputObject $sortedObject

    # sort data by end date ascending (for chart to work well in excel)
    $exportData = ($uniqueResult | Select -Property end, val, accn, fy, fp, form, filed | sort end)

    # shorten Name if necessary
    if($oneResultOfAllTags.Name.Length -ge 21){
        [array]$chars = "abcdefghijkmnopqrstuvwxyzABCEFGHJKLMNPQRSTUVWXYZ1234567890".ToCharArray()
        [string]$randomString = ((Get-Random -InputObject $chars)+(Get-Random -InputObject $chars))
        [string]$oneNameForThisResult = ($oneResultOfAllTags.Name.Substring(0,15)) + "-" + $randomString
        }
    else{
        [string]$oneNameForThisResult = ($oneResultOfAllTags.Name)
        }

    # export to excel
    try{
        $exportChartTitle = ($resultOfAllTags.($oneResultOfAllTags.Name).entityName)
        $exportTitle = ($resultOfAllTags.($oneResultOfAllTags.Name).label)
        exportToExcel -exportFileName $xlTempFile -exportTitle $exportTitle -exportWorksheetName $oneNameForThisResult -exportData $exportData -exportChartTitle $exportChartTitle
        }
    catch{
         Write-Host -ForegroundColor red -BackgroundColor DarkBlue $exportChartTitle , "not ok:" , $exportTitle
        }
    finally{
        Write-Host -ForegroundColor green -BackgroundColor DarkBlue $exportChartTitle , "ok for:" , $exportTitle
        }
}

}

# put all CIK numbers in here // => https://www.sec.gov/edgar/searchedgar/cik 
# ("CIK-Number" = "Company-Name")
<#
$allCIKs = @{
    "0001439047" = "Vitesse Energy"
    "0001559720" = "AirBNB"
    "0000796343" = "Adobe"
    "0001045810" = "NVIDIA CORP"
    "0001535527" = "CROWDSTRIKE HOLDINGS, INC."
    "0001018724" = "AMAZON com inc"
    "0001640147" = "SNOWFLAKE"
    "0001886785" = "TSMC ARIZONA CORP"
    "0001800227" = "IAC INC."
    "0001677576" = "INNOVATIVE INDUSTRIAL PROPERTIES INC"
    }
    #>

$allCIKs = @{
    "0001944558" = "Vitesse Energy"
    }


# run for every CIK number
    foreach($everyCIK in $allCIKs.GetEnumerator()){
        # run for every CIK number
        run-Everything -defaultCIK $everyCIK.Key
        }





# === testing ===
# do an auto-request
$abc = Read-Host "Please enter a Company Name you're looking for"

run-Everything -defaultCIK $abc