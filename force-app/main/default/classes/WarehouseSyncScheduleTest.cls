@isTest
private class WarehouseSyncScheduleTest {
    @isTest
    private static void testWarehouseSyncScheduleable() {
        Test.setMock(HttpCalloutMock.class, new getEquipmentMock());
        Assert.isFalse([SELECT COUNT() FROM Product2] > 0);

        String CRON_EXP = '0 0 13 * * ?';

        Test.startTest();
        String jobId = System.schedule(
            'WarehouseSyncScheduleJobTest',
            CRON_EXP,
            new WarehouseSyncSchedule()
        );

        CronTrigger ct = [
            SELECT Id, CronExpression, TimesTriggered, NextFireTime
            FROM CronTrigger
            WHERE id = :jobId
        ];

		System.assertEquals(CRON_EXP, 
		ct.CronExpression);
        Test.stopTest();
    }
}
