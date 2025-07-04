@echo off
echo.
echo =====================================================
echo    PUSH CLAUDIA FOR WINDOWS TO GITHUB
echo =====================================================
echo.
echo Before running this script, make sure you have:
echo 1. Created the repository on GitHub:
echo    https://github.com/Kirchlive/Claudia-For-Windows
echo 2. Set it as PUBLIC or PRIVATE as desired
echo 3. DO NOT initialize with README, license, or .gitignore
echo.
pause

echo.
echo Adding GitHub remote...
git remote add origin https://github.com/Kirchlive/Claudia-For-Windows.git

echo.
echo Pushing to GitHub...
git push -u origin main

echo.
echo =====================================================
echo    DONE! Your repository is now on GitHub!
echo =====================================================
echo.
echo View it at: https://github.com/Kirchlive/Claudia-For-Windows
echo.
pause