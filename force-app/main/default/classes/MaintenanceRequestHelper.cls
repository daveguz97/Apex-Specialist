public with sharing class MaintenanceRequestHelper {
    public static void createNewMaintenanceRequest(
        Map<Id, Case> triggerOld,
        Map<Id, Case> triggerNew
    ) {
        Case[] newCases = new List<Case>();
        Id[] validCaseIds = new List<Id>();
        for (Id caseId : triggerNew.keySet()) {
            if (
                triggerNew.get(caseId).Status == 'Closed' &&
                (triggerNew.get(caseId).Type == 'Repair' ||
                triggerNew.get(caseId).Type == 'Routine Maintenance')
            ) {
                validCaseIds.add(caseId);
            }
        }

        if (!validCaseIds.isEmpty()) {
            Map<Id, Case> closedCases = new Map<Id, Case>(
                [
                    SELECT
                        Id,
                        Vehicle__c,
                        Subject,
                        Type,
                        Date_Due__c,
                        Date_Reported__c,
                        ProductId,
                        Product.Maintenance_Cycle__c,
                        (
                            SELECT Id, Equipment__c, Quantity__c
                            FROM Equipment_Maintenance_Items__r
                        )
                    FROM Case
                    WHERE Id IN :validCaseIds
                ]
            );

            Map<Id, Decimal> maintenanceCycles = new Map<ID, Decimal>();

            AggregateResult[] results = [
                SELECT
                    Maintenance_Request__c,
                    MIN(Equipment__r.Maintenance_Cycle__c) cycle
                FROM Equipment_Maintenance_Item__c
                WHERE Maintenance_Request__c IN :validCaseIds
                GROUP BY Maintenance_Request__c
            ];

            for (AggregateResult ar : results) {
                maintenanceCycles.put(
                    (Id) ar.get('Maintenance_Request__c'),
                    (Decimal) ar.get('cycle')
                );
            }

            for (Case c : closedCases.values()) {
                Case newMR = new Case(
                    ParentId = c.Id,
                    Status = 'New',
                    Vehicle__c = c.Vehicle__c,
                    ProductId = c.ProductId,
                    Type = 'Routine Maintenance',
                    Subject = c.Subject,
                    Date_Reported__c = Date.today(),
                    Date_Due__c = maintenanceCycles.containsKey(c.Id)
                        ? Date.today()
                              .addDays((Integer) maintenanceCycles.get(c.Id))
                        : Date.today()
                              .addDays((Integer) c.Product.maintenance_Cycle__c)
                );
                newCases.add(newMR);
            }
			if (!newCases.isEmpty()) {
				insert newCases;

				List<Equipment_Maintenance_Item__c> clonedWPs = new List<Equipment_Maintenance_Item__c>();
	
				for (Case nc : newCases){
	 
					 for (Equipment_Maintenance_Item__c wp : closedCases.get(nc.ParentId).Equipment_Maintenance_Items__r){
	 
						 Equipment_Maintenance_Item__c wpClone = wp.clone();
	 
						 wpClone.Maintenance_Request__c = nc.Id;
	 
						 ClonedWPs.add(wpClone);
	 
					 }
	 
				 }
	 
				 insert ClonedWPs;
			}

        }

    }
}
