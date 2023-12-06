trigger MaintenanceRequest on Case (before update, after update) {
	if(Trigger.isUpdate && Trigger.isBefore) {
		MaintenanceRequestHelper.createNewMaintenanceRequest(Trigger.oldMap, Trigger.newMap);
	}
}