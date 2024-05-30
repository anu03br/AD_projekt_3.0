function umlaut {
    param (
        [array]$textArray
    )
    $ohneUmlaut
    $mitUmlaut
    $modifiedArray = @()

    # Replace umlauts in each string
    foreach ($line in $textArray) {
        $modifiedLine = $line -replace 'ä', 'ae' `
                               -replace 'ö', 'oe' `
                               -replace 'ü', 'ue'
        $modifiedArray += $modifiedLine
    }

    return $modifiedArray
}