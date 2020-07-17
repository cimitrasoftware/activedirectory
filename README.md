# activedirectory
Document Author: Tay Kratzer **tay@cimitra.com**

[BIG PICTURE]
1. Create a method in which PowerShell script files read their configuration settings from a simple text file that anyone can understand. 
2. Make this method portable to anyone else who wants to use this method in their own PowerShell scripts

It should be very easy for you to take the **config_reader.ps1** script and user it in your own PowerShell scripts in order to store variables in an external file, rather than inside a PowerShell script. Enjoy!

[ARCHITECTURE]
All the PowerShell scripts use these two files:

1. **settings.cfg**
- A simple text file with a syntax of VARIABLE=VALUE, for example: **SERVER_ADDRESS=192.168.1.2**

2. **config_reader.ps1**
- The config_reader.ps1 script is sourced by all the other PowerShell scripts so that they can benefit from the ability of the config_reader.ps1 script to read from the settings.cfg file

[THE SCRIPTS]
This is a group of PowerShell scripts that use a common configuration file (**settings.cfg**) and common script (**config_reader.ps1**) to create on place to set variables in all of the scripts. If you edit the configuration file, then you need not change the scripts in any fashion.

The PowerShell scripts allow for the following: 

1. Creating an Active Directory User
2. Resetting an Active Directory User's password
3. Determining the last time a User's password was reset
4. Removing an Active Directory User
5. Listing all Active Directory Users in a specific context
6. Listing all Active Directory Users in an entire Active Directory Tree
7. Creating an Active Directory Computer object
8. Renaming an Active Directory Computer object
9. Removing an Active Directory Computer object
10. Listing all Active Directory Computer Objects in an a specific context
11. Listing all Active Directory Computer Objects in an entire Active Directory Tree

These scripts were made for the benefit of Cimitra customers, but they have broader application than that anyone can benefit from. These scripts are more fully explained at: 

https://www.cimitra.com/ad

