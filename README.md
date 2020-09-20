# Taskwarrior to Apple Reminders sync
JXA script that syncs Taskwarrior with Apple Reminders

## Setup
The script depends on a User Defined Attribute that holds the ID of the reminder in Apple's Reminders app.
To make Taskwarrior aware of the UDA execute the following commands:

```
task config uda.remindersId.type string
task config uda.remindersId.label "Reminders Id"
```
