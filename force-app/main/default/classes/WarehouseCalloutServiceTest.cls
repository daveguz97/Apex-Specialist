
@isTest
private class WarehouseCalloutServiceTest {
    @IsTest
	static void testWarehouseCalloutServiceQueueable(){
		Test.setMock(HttpCalloutMock.class, new getEquipmentMock());
		Assert.isFalse([SELECT COUNT() FROM Product2] > 0);
		Test.startTest();
		System.enqueueJob(new WarehouseCalloutService());
		Test.stopTest();
		Assert.isNotNull([SELECT Id FROM Product2 WHERE Warehouse_SKU__c = '100007']);
		Assert.isTrue([SELECT COUNT() FROM Product2] > 0);
		
	}
}