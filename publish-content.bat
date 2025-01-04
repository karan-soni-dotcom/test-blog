@echo off
REM --- Simple Jekyll Blog Post Automation for GitHub Pages ---

REM Get GitHub username and repo name (set these manually to avoid re-entering)
set github_username=SimpliSoni
set github_repo=test-blog

REM Check if the repo folder exists. If the script is in the folder, we don't need to ask for the path.
IF EXIST "C:\Users\karan\OneDrive\Desktop\testblog\my-blog\publish-content.bat" (
    echo Found the batch file in the repo folder.
    REM Do not ask for the repo folder path if script is already in the folder
    set C:\Users\karan\OneDrive\Desktop\testblog\my-blog
) ELSE (
    REM Ask the user to enter the local repo folder path
    set /p repo_folder="Enter the full path to your local repo folder: "
)

REM Check if the repo folder exists, and clone if necessary
IF NOT EXIST %repo_folder% (
    echo Repository not found, cloning from GitHub...
    git clone https://github.com/%github_username%/%github_repo%.git %repo_folder%
)

REM Navigate to the repo folder
cd /d %repo_folder%

REM Pull the latest changes from GitHub
git pull origin main

REM Ensure the _posts folder exists
if not exist "_posts" (
    echo The _posts folder does not exist. Creating it now...
    mkdir _posts
)

REM Ask the user for the post title
set /p post_title="Enter the title of your post (use hyphens instead of spaces): "

REM Ask the user for the post content
echo Enter your content. Press Enter, then Ctrl+Z and Enter when done.
copy con temp_post.txt
REM User enters content manually, finishes with Ctrl+Z

REM Generate the filename with today's date
for /f "tokens=2-4 delims=/ " %%a in ('date /t') do set post_date=%%c-%%a-%%b
set post_file=_posts\%post_date%-%post_title%.md

REM Create a markdown file with the entered title and content
(
echo ---
echo layout: post
echo title: "%post_title%"
echo date: %post_date%
echo ---
type temp_post.txt
) > "%post_file%"

del temp_post.txt

REM Ensure the GitHub remote URL is correct
git remote set-url origin https://github.com/%github_username%/%github_repo%.git

REM Add and commit the new post
git add "%post_file%"
git commit -m "Add new post: %post_title%"

REM Push changes to GitHub
git push origin main

REM Confirm success
echo Your post has been successfully added and deployed to GitHub Pages!
pause