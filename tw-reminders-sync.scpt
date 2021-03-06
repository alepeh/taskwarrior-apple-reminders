JsOsaDAS1.001.00bplist00�Vscript__
sync()

function sync(){
	let reminders = getRemindersData();
	let twTasks = getTaskwarriorData();
	syncRemindersToTaskwarrior(reminders, twTasks)
}

function syncRemindersToTaskwarrior(reminders, twTasks){
	for (var reminder of reminders){
		let twTask = findReminderInTaskwarrior(reminder, twTasks);
		if(twTask){
			console.log("Reminder " + reminder.id() + " exists in TaskWarrior - updating")
			updateReminderInTaskwarrior(reminder, twTask);
		}
		else {
			console.log("Creating Reminder in TaskWarrior");
			createReminderInTaskWarrior(reminder);
		}
	}
}

function parseTaskWarriorDateFormatAndConvertToLocalTimezone(twDate){
	let date = new Date();
	date.setYear(twDate.substring(0,4)); // YYYY
	date.setMonth(twDate.substring(4,6)-1); // MM
	date.setDate(twDate.substring(6,8)); // DD
	date.setHours(twDate.substring(9,11)); // HH
	date.setMinutes(twDate.substring(11,13)); // mm
	date.setSeconds(twDate.substring(13,15)); // ss
	return new Date(date.getTime() - (date.getTimezoneOffset()*60000));
}

function createReminderInTaskWarrior(reminder){
	let id = reminder.id();
	let description = reminder.name();
	executeCommandInTerminal("task add remindersId:\"" + id + "\" " + description); 
}

function updateReminderInTaskwarrior(reminder, twTask){
	if(isDifferent(reminder, twTask) && isReminderNewer(reminder, twTask)){
		console.log("Reminder is newer than TaskWarrior task");
		let updateCommand = "task " + twTask['id'] + " modify ";
		
		if(getDueDateFromReminderInTwFormat(reminder)){
			updateCommand += "due:" + getDueDateFromReminderInTwFormat(reminder) + " "
		}
		if(getListNameAsProjectName(reminder)){
			updateCommand += "project:" + getListNameAsProjectName(reminder) + " "
		}
		updateCommand += reminder.name();
		console.log(updateCommand)
		executeCommandInTerminal(updateCommand);
		
		if(reminder.completed()){
			executeCommandInTerminal("task " + twTask['id'] + " done");
		}
	}
}

function isDifferent(reminder, twTask){
	if(reminder.completed() ) {
		return true;
	}
	
	return false;
}

function getListNameAsProjectName(reminder){
	//Lists do not contain the x-apple-reminder scheme
	if((! reminder.completed()) && reminder.container().id().indexOf("x-apple-reminder") < 0){
		return reminder.container().name();
	}
	return null;
}

function getDueDateFromReminderInTwFormat(reminder){
	if(reminder.dueDate()){
		return reminder.dueDate().toISOString()
	}
	else if(reminder.alldayDueDate()){
		return reminder.alldayDueDate().toISOString()
	}
	return null;
}

function isReminderNewer(reminder, twTask){
	if(reminder.modificationDate() > parseTaskWarriorDateFormatAndConvertToLocalTimezone(twTask['modified'])) {
		return true;
	}
	return false;
}

function findReminderInTaskwarrior(reminder, twTasks){
	let reminderId = reminder.id();
	for(let twTask of twTasks){
		if(twTask['remindersId'] === reminderId){
			return twTask;
		}	
	}
	return null;
}

function getRemindersData(){
	var remindersApp = Application("Reminders")
	return remindersApp.reminders() 
	for (var reminderId of reminderIds) {
		//var reminder = remindersApp.reminders.byId(reminderId);
		var reminder = reminderId;
		console.log(reminder.name())
	}
}function getTaskwarriorData(){
	var TW_EXPORT_PATH = "/tmp/twexport.json"	executeCommandInTerminal("task export > " + TW_EXPORT_PATH)
	var app = Application.currentApplication()
	app.includeStandardAdditions = true
	return JSON.parse(app.read(Path(TW_EXPORT_PATH)))
}

function executeCommandInTerminal(command) {
	var terminal =  Application("Terminal")
	terminal.doScript(command)
	currentWindow = terminal.windows.at(0)
  	while(currentWindow.selectedTab().busy()){
		delay(0.5);
	}
	currentWindow.close() 
}                              u jscr  ��ޭ