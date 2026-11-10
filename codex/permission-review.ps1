# PermissionRequest hook: auto-approve everything except file edits,
# so in the "review" profile only apply_patch reaches the user with a diff.
$payload = [Console]::In.ReadToEnd() | ConvertFrom-Json
if ($payload.tool_name -eq 'apply_patch') { exit 0 }
'{"hookSpecificOutput":{"hookEventName":"PermissionRequest","decision":{"behavior":"allow"}}}'
