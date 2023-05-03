# take $exportData and export to Excel Sheet
function exportToExcel {
# properties
    param(
        # export Data
        [Parameter(Mandatory = $True)]
            [PSCustomObject]$exportData,
        # default Title
        [Parameter(Mandatory = $False)]
            [string]$exportTitle = $defaultTitle,
        [Parameter(Mandatory = $False)]
            [string]$exportChartTitle = $defaultTitle,
        # default Worksheet Name
        [Parameter(Mandatory = $False)]
            [string]$exportWorksheetName = $defaultWorksheetName,
        # default Table Style
        [Parameter(Mandatory = $False)]
            [string]$exportTableStyle = $defaultTableStyle,
        # default Title Size
        [Parameter(Mandatory = $False)]
            [string]$exportTitleSize = $defaultTitleSize,
        # default Start Row
        [Parameter(Mandatory = $False)]
            [int]$exportStartRow = $defaultStartRow,
        # cik of company (for filename)
        [Parameter(Mandatory = $False)]
            [string]$exportFileName = $defaultFileName,
        # get default company cik
            [string]$cik = $defaultCIK,
        [Parameter(Mandatory = $False)]
            [string]$exportChartType = $defaultChartStyle    
         )

# export to excel
    $exportChartData = New-ExcelChartDefinition -XRange end -YRange val -YAxisNumberformat '#,##0 $;-#,##0 $' -ChartType $exportChartType -Title $exportChartTitle -ChartTrendLine MovingAvgerage -SeriesHeader Price -YAxisTitleText Price -XAxisTitleText Time -Column 0 -Row 0 -Width 790
    Export-Excel $xlTempFile -WorksheetName $exportWorksheetName -TargetData $exportData -StartRow $exportStartRow -Title $exportTitle -TableStyle $exportTableStyle -TitleSize $exportTitleSize -AutoSize -ExcelChartDefinition $exportChartData -AutoNameRange -ClearSheet

}