# upgradehelper
Applies registry changes to allow upgrading to Windows 11 and installing updates on unsupported systems.

## How to use
Just double-click on upgradehelper.cmd. Or, you can use it from the Command Prompt:
```
C:\>upgradehelper
```
You can then start Windows Setup from your installation media.

## Options

### /S [ONSTART | ONLOGON | ONUPDATE]
Set upgradehelper to run automatically on one of the following schedules:
- ONSTART: Whenever the system starts up.
- ONLOGON: Whenever a user logs on.
- ONUPDATE: Each time after Windows updates are installed.
This can be useful as the changes made by upgradehelper can sometimes be undone by themselves following updates.

### /R
Remove upgradehelper from your scheduled tasks; stop upgradehelper from running automatically on a schedule.

### /U
Undo the registry changes made by upgradehelper.

## License
upgradehelper is licensed under the GNU General Public License v3.0.