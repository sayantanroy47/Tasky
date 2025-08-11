# Claude Code Status Line Script for Windows
# This script provides a working alternative to the complex bash/jq command

param()

try {
    # Read JSON input from stdin
    $input = [Console]::In.ReadToEnd() | ConvertFrom-Json
    
    # Extract useful information
    $model = $input.model.display_name
    $currentDir = Split-Path -Leaf $input.workspace.current_dir
    $time = Get-Date -Format "HH:mm:ss"
    
    # Simple usage info (placeholder since ccusage isn't available)
    $sessionId = $input.session_id.Substring(0, 8)
    
    # Format output
    $output = "$model | $currentDir | $time | Session: $sessionId"
    
    Write-Host $output -NoNewline
}
catch {
    # Fallback display
    Write-Host "Claude Code | $(Get-Date -Format 'HH:mm:ss')" -NoNewline
}