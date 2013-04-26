ACS
===

Aetolian Curing System

### Install Git:
- https://code.google.com/p/msysgit/downloads/detail?name=Git-1.8.1.2-preview20130201.exe&can=2&q=
- On the components screen, select the 'git bash here' checkbox, leave the rest the same
- On the next screen, select 'git bash only'
- Finish installation

### Downloading ACS:
- In a folder where you will remember, right click and select "Git Bash"
- Enter the following command (replacing where neccissary):
git clone https://githubUsername:githubPassword@github.com/jnehl701/ACS.git
- ACS will download. Go into the ACS foloder and boot it up!

### To udpate:
- In the ACS folder, right click and select "Git Bash"
- Type the command:
git pull

### Getting Started with ACS:
- Go into "scripts/settings/" and make a copy of Defaults.lua.
- Paste it and rename it to be your characters name (CASE MATTERS)
- Modify your settings file.  Anything int his settings file will 'overwrite' the Defaults.  So, replace what you need to, or add onto it.
- Open a Git Bash window (right click in the ACS folder and select "Git Bash")
- Add, commit and push your file:
git pull
git add scripts/settings/Yourchar.lua
git commit -m "Adding settings file for my character"
git push origin master