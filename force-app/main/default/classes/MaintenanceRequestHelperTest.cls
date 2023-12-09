@isTest
private class MaintenanceRequestHelperTest {
    @TestSetup
    static void setup() {
        Product2 equipment = new Product2(
            IsActive = true,
            Name = 'Test Product',
            Maintenance_Cycle__c = 15,
            Replacement_Part__c = true
        );
        insert equipment;

        Vehicle__c vehicle = new Vehicle__c(name = 'Truck');
        insert vehicle;

        Case[] cases = new List<Case>();

        for (Integer i = 1; i <= 200; i++) {
            Case c = new Case(
                Status = 'New',
                Subject = 'Test',
                ProductId = equipment.Id,
                Vehicle__c = vehicle.Id
            );
            cases.add(c);
        }
        insert cases;

        insert new Equipment_Maintenance_Item__c(
            Maintenance_Request__c = cases[0].Id,
            Equipment__c = equipment.Id
        );
    }

    @IsTest
    static void testUpdatingCaseByRepairs() {
        Case[] cases = [
            SELECT Id, Status, Type, Subject, Vehicle__c, Product__c
            FROM Case
            LIMIT 200
        ];
        Assert.isFalse(
            [SELECT COUNT() FROM Case WHERE Type = 'Routine Maintenance'] > 0
        );
        Test.startTest();
        for (Case c : cases) {
            c.Status = 'Closed';
            c.Type = 'Repair';
        }
        update cases;
        Test.stopTest();
        Assert.isTrue(
            [SELECT COUNT() FROM Case WHERE Type = 'Routine Maintenance'] > 0
        );
        Assert.isTrue([SELECT COUNT() FROM Equipment_Maintenance_Item__c] > 1);
    }

    @IsTest
    static void testUpdatingCaseByRoutineMaintenance() {
        Case[] cases = [
            SELECT Id, Status, Type, Subject, Vehicle__c, Product__c
            FROM Case
            LIMIT 200
        ];
        Assert.isFalse(
            [SELECT COUNT() FROM Case WHERE Type = 'Routine Maintenance'] > 0
        );
        Test.startTest();
        for (Case c : cases) {
            c.Status = 'Closed';
            c.Type = 'Routine Maintenance';
        }
        update cases;
        Test.stopTest();
        Assert.isTrue(
            [SELECT COUNT() FROM Case WHERE Type = 'Routine Maintenance'] > 0
        );

        Assert.isTrue([SELECT COUNT() FROM Equipment_Maintenance_Item__c] > 1);
    }

    @IsTest
    static void testCatchBlock() {
        Product2 equipment = [
            SELECT Id, Maintenance_Cycle__c
            FROM Product2
            LIMIT 1
        ];
        equipment.Maintenance_Cycle__c = null;
        update equipment;
        Case[] cases = [
            SELECT Id, Status, Type, Subject, Vehicle__c, Product__c
            FROM Case
            LIMIT 200
        ];
        Assert.isFalse(
            [SELECT COUNT() FROM Case WHERE Type = 'Routine Maintenance'] > 0
        );
        Test.startTest();
        try {
            for (Case c : cases) {
                c.Status = 'Closed';
                c.Type = 'Routine Maintenance';
            }
            update cases;
        } catch (Exception e) {
            Assert.isNotNull(e);
        }
        Test.stopTest();
    }
}
