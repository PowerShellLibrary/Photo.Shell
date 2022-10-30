function Test-StreamType {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0 )]
        $Object
    )

    begin {
        Write-Verbose "Cmdlet Test-StreamType - Begin"
    }

    process {
        Write-Verbose "Cmdlet Test-StreamType - Process"
        $Object.PSTypeNames -contains [System.IO.Stream]
    }

    end {
        Write-Verbose "Cmdlet Test-StreamType - End"
    }
}