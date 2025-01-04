@echo off
setlocal EnableDelayedExpansion

REM --- Enhanced Jekyll Blog Post Automation for GitHub Pages ---
echo Jekyll Blog Post Automation Tool
echo ===============================

REM Configuration Variables
set "github_username=karan-soni-dotcom"
set "github_repo=test-blog"
set "default_repo_folder=C:\Users\karan\OneDrive\Desktop\test-blog"
set "remote_url=https://github.com/%github_username%/%github_repo%.git"

REM Get current date in YYYY-MM-DD format
for /f "tokens=1-3 delims=/" %%a in ('powershell -Command "Get-Date -Format 'yyyy-MM-dd'"') do (
    set "year=%%a"
    set "month=%%b"
    set "day=%%c"
)

REM Create properly formatted date (YYYY-MM-DD)
set "formatted_date=%year%-%month%-%day%"

REM Validate and set repository folder
if not defined repo_folder (
    if exist "%default_repo_folder%\" (
        set "repo_folder=%default_repo_folder%"
        echo Using default repository folder: %repo_folder%
    ) else (
        set /p "repo_folder=Enter the full path to your local repo folder: "
    )
)

REM Validate repository folder
:CHECK_REPO
if not exist "%repo_folder%\" (
    echo Repository folder not found. Attempting to clone...
    git clone "%remote_url%" "%repo_folder%"
    if errorlevel 1 (
        echo Failed to clone repository.
        set /p "retry=Would you like to try again? (Y/N): "
        if /i "!retry!"=="Y" goto CHECK_REPO
        exit /b 1
    )
)

REM Navigate to repo folder
pushd "%repo_folder%"
if errorlevel 1 (
    echo Failed to navigate to repository folder.
    pause
    exit /b 1
)

REM Verify and set correct remote URL
for /f "tokens=*" %%i in ('git remote get-url origin 2^>nul') do set "current_remote=%%i"
if not "%current_remote%"=="%remote_url%" (
    echo Updating remote URL to correct repository...
    git remote set-url origin "%remote_url%"
)

REM Pull latest changes
echo Pulling latest changes...
git pull origin main
if errorlevel 1 (
    echo Warning: Failed to pull latest changes. Continuing anyway...
)

REM Create _posts folder if it doesn't exist
if not exist "_posts\" (
    mkdir "_posts"
)

REM Get post title
echo Enter the title of your post
echo Note: Use normal text - spaces will be automatically converted to hyphens
set /p "post_title=Title: "

REM Create URL-friendly title
set "formatted_title=%post_title%"

REM Convert to lowercase and replace special characters using PowerShell
for /f "delims=" %%i in ('powershell -command "$title = '%formatted_title%'; $title = $title.ToLower(); $title = $title -replace '[^a-z0-9\s-]', ''; $title = $title -replace '\s+', '-'; $title = $title -replace '-+', '-'; $title = $title.Trim('-'); Write-Output $title"') do set "formatted_title=%%i"

REM Create filename with date format YYYY-MM-DD
set "post_file=_posts\%formatted_date%-%formatted_title%.md"

REM Check if file already exists
if exist "%post_file%" (
    echo Warning: A post with this title already exists for today.
    set /p "overwrite=Would you like to overwrite it? (Y/N): "
    if /i not "!overwrite!"=="Y" goto GET_TITLE
)

REM Create post content with proper YAML front matter
(
echo ---
echo layout: post
echo title: "%post_title%"
echo date: %formatted_date%
echo ---
echo.
) > "%post_file%"

REM Get post content
echo Enter your post content below.
echo Use Markdown formatting. Press Ctrl+Z and Enter when finished.
echo ----------------------------------------
type con >> "%post_file%"

REM Configure git if needed
git config user.name "%github_username%"
git config user.email "%github_username%@users.noreply.github.com"

REM Add and commit changes
echo Adding and committing changes...
git add "%post_file%"
git commit -m "Add new post: %post_title%"
if errorlevel 1 (
    echo Failed to commit changes.
    pause
    exit /b 1
)

REM Push changes
echo Pushing to GitHub...
git push origin main
if errorlevel 1 (
    echo Failed to push to GitHub. Checking remote URL...
    git remote -v
    echo.
    echo Please verify your GitHub credentials and repository permissions.
    echo Remote URL should be: %remote_url%
    pause
    exit /b 1
)

echo.
echo Success! Your post has been created and pushed to GitHub.
echo View your post at: https://%github_username%.github.io/%github_repo%
echo.

popd
pause
exit /b 0