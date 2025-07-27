@echo off
flutter build web
powershell -Command "(Get-Content build\web\index.html) -replace '<base href=\"/\">', '<base href=\"/myfirstproject/\">' | Set-Content build\web\index.html"
echo ✅ Done: index.html fixed for GitHub Pages
pause
