function Test-ByteArrayType {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0 )]
        $Object
    )

    begin {
        Write-Verbose "Cmdlet Test-ByteArrayType - Begin"
    }

    process {
        Write-Verbose "Cmdlet Test-ByteArrayType - Process"
        $Object.PSTypeNames -contains [System.Byte[]].ToString()
    }

    end {
        Write-Verbose "Cmdlet Test-ByteArrayType - End"
    }
}