# compare (end date), get most recent (filing date) per date, drop old values
# this helps to filter out re-reports of the same numbers by only keeping the newest one
# idea is: the most recent number should be the most correct one, as "errors by calculation" only get caught afterwards (and rarely to the up-side)
function getUnique{

    param(        
        [Parameter(Mandatory = $True)]
            [PSCustomObject]$inputObject
        )

    # create dummy
    $sortedInputObject = [PSCustomObject]@()
    $tempObject = [PSCustomObject]@()
    $exportObject = [PSCustomObject]@()

    # group and sort
    $sortedInputObject = $inputObject | Group-Object end | sort -Descending Count

    # get newest result per line
    foreach($tempObject in $sortedInputObject){

        # sort values by date
        $tempObject = $tempObject.Group | sort -Descending filed

        # get newest date
        $exportObject += $tempObject[0]

    }

    return $exportObject
}