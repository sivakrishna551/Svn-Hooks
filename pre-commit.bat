 @echo off
 rem This pre-commit hook will block commits with no log messages and blocks commits on tags.
 rem Users may create tags, but not modify them.
 rem If the user is an Administrator the commit will succeed.

 rem Specify the username of the repository administrator
 rem commits by this user are not checked for comments or tags
 rem Recommended to change the Administrator only when an admin commit is neccessary
 rem then reset the Administrator after the admin commit is complete
 rem this way the admin user is only an administrator when neccessary
 set Administrator=Administrator

 setlocal

 rem Subversion sends through the path to the repository and transaction id.
 set REPOS=%1%
 set TXN=%2%

 :Main
 rem check if the user is an Administrator
 svnlook author %REPOS% -t %TXN% | findstr /r "^%Administrator%$" >nul
 if %errorlevel%==0 (exit 0)

 rem Check if the commit has an empty log message
 svnlook log %REPOS% -t %TXN% | findstr ............... > nul
 if %errorlevel% gtr 0 (goto CommentError)
 

 rem Block deletion of Bhalu-Charts
 rem svnlook changed %REPOS% -t %TXN% | findstr /r "^D.*Bhalu-Charts/*/*/*/*/*/*/*/*/*/*/*/*" >nul
 rem if %errorlevel%==0 (goto DeleteBranchTrunkError)
 rem Block adding of Bhalu-Charts
 rem svnlook changed %REPOS% -t %TXN% | findstr /r "^A.*Bhalu-Charts/*/*/*/*/*/*/*/*/*/*/*/*" >nul
 rem if %errorlevel%==0 (goto AddingError)
 


 

 rem Check if the commit is to a tag
 svnlook changed %REPOS% -t %TXN% | findstr /r "^.*tags/" >nul
 if %errorlevel%==0 (goto TagCommit)
 exit 0

 :DeleteBranchTrunkError
 echo. 1>&2
 echo Trunk/Branch Delete Error: 1>&2
 echo     Only an Administrator may delete the Files and Folders. 1>&2
 echo Commit details: 1>&2
 svnlook changed %REPOS% -t %TXN% 1>&2
 exit 1
 :AddingError
 echo. 1>&2
 echo Trunk/Branch Adding Error: 1>&2
 echo     Only an Administrator may add the Files and Folders. 1>&2
 echo Commit details: 1>&2
 svnlook changed %REPOS% -t %TXN% 1>&2
  exit 1
 :TagCommit
 rem Check if the commit is creating a subdirectory under tags/ (tags/v1.0.0.1)
 svnlook changed %REPOS% -t %TXN% | findstr /r "^A.*tags/[^/]*/$" >nul
 if %errorlevel% gtr 0 (goto CheckCreatingTags)
 exit 0

 :CheckCreatingTags
 rem Check if the commit is creating a tags/ directory
 svnlook changed %REPOS% -t %TXN% | findstr /r "^A.*tags/$" >nul
 if %errorlevel% == 0 (exit 0)
 goto TagsCommitError

 :CommentError
 echo. 1>&2
 echo Comment Error: 1>&2
 echo     Your commit has been blocked because you didn't enter a comment. 1>&2
 echo     Write a log message describing your changes and try again. 1>&2
 exit 1

 :TagsCommitError
 echo. 1>&2
 echo %cd% 1>&2
 echo Tags Commit Error: 1>&2
 echo     Your commit to a tag has been blocked. 1>&2
 echo     You are only allowed to create tags. 1>&2
 echo     Tags may only be modified by an Administrator. 1>&2
 echo Commit details: 1>&2
 svnlook changed %REPOS% -t %TXN% 1>&2
 exit 1
