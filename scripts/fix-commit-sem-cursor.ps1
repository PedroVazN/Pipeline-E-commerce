# Rode VOCÊ no PowerShell se precisar refazer o commit sem "Co-authored-by: Cursor"
# Uso: cd C:\Users\25170632\Documents\case4_rotaexpress
#      .\scripts\fix-commit-sem-cursor.ps1

Set-Location $PSScriptRoot\..

$msg = "feat: estrutura Case 4 RotaExpress com Docker e pipeline CI/CD"
$env:GIT_AUTHOR_NAME = "Pedro Vaz"
$env:GIT_AUTHOR_EMAIL = "vaznascimento23@gmail.com"
$env:GIT_COMMITTER_NAME = "Pedro Vaz"
$env:GIT_COMMITTER_EMAIL = "vaznascimento23@gmail.com"

git add -A
$tree = git write-tree
$new = git commit-tree $tree -m $msg
git reset --hard $new

Write-Host "`nCommit limpo:" -ForegroundColor Green
git log -1 --format=full

Write-Host "`nAgora envie (na sua conta, pelo terminal ou GitHub Desktop):" -ForegroundColor Yellow
Write-Host "  git push -u origin main --force" -ForegroundColor Cyan
