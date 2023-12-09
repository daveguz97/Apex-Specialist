public with sharing class WarehouseSyncSchedule implements Schedulable {
    private static void scheduleCallout() {
		System.enqueueJob(new WarehouseCalloutService());
    }

	public void execute(SchedulableContext sc) {
		scheduleCallout();
	}
}