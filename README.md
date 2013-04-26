ACS
===

Aetolian Curing System

Install Git:
------------
- https://code.google.com/p/msysgit/downloads/detail?name=Git-1.8.1.2-preview20130201.exe&can=2&q=
- On the components screen, select the 'git bash here' checkbox, leave the rest the same
- On the next screen, select 'git bash only'
- Finish installation

Downloading ACS:
----------------
- In a folder where you will remember, right click and select "Git Bash"
- Enter the following command (replacing where neccissary):
git clone https://githubUsername:githubPassword@github.com/jnehl701/ACS.git
- ACS will download. Go into the ACS foloder and boot it up!

Extra Git Setup
---------------
You need to do two more commands at this point to set Git up.  This only needs to be done once after installing Git.
- *git config --global user.email "you@example.com"*
- *git config --global user.name "your name"*

To udpate:
----------
- In the ACS folder, right click and select "Git Bash"
- Type the command:
git pull

Getting Started with ACS:
-------------------------
- Go into "scripts/settings/" and make a copy of Defaults.lua.
- Paste it and rename it to be your characters name (CASE MATTERS)
- Modify your settings file.  Anything int his settings file will 'overwrite' the Defaults.  So, replace what you need to, or add onto it.
- Open a Git Bash window (right click in the ACS folder and select "Git Bash")
- Add, commit and push your file:
git pull
git add scripts/settings/Yourchar.lua
git commit -m "Adding settings file for my character"
git push origin master

Git TL;DR
---------
Git is a fairly complex VCS, but thankfully there are only a handful of commands you really need to know.  I will provide a very brief overview, but more details can be found on git's website or on this blog post: *http://www.vogella.com/articles/Git/article.html*

### git pull
Git STATUS updates your local files with whatever has been saved on the server.  Run this before you login, after any significant changes, and before you push.  Pull often.  It helps prevent complications later.

### git status
GIT STATUS gives you an overview of the status of your local repository.  This will tell you where your files sit, if they have been modified, and some help if you need to reset files.

### Commiting files
There are a couple different steps to commiting files and putting them on the server.

modify files-> add files -> commit files -> push files

### git add
This will prepare a file to be commited.  You can either add indivdual changed files, directories of files, or ALL files.
- *git add scripts/settings/Kaed.lua*  --  This will only add Kaed's settings file
- *git add scripts/settings/* -- This will add all modified files in the settings directory
- *git add -A* -- This will add ALL modified, deleted, added files.  This is also the easiest way to add a 'deleted' file to actually be deleted in the repository.

### git commit
GIT COMMIT is used to actually save added files to your LOCAL repository.  After using git commit, your files are saved into your local git reposity, but NOT on the server.
- *git commit -m "Your commit message goes here.  It should be descritive enough to tell what you did."*

### git push
GIT PUSH is used to move all of the changes you have committed to the server.  Make sure you do a GIT PULL before actually pushing
- *git push origin master*