public with sharing class WarehouseCalloutService implements Queueable, Database.AllowsCallouts {

    public void execute(QueueableContext context) {
		Product2[] newEquipments = new Product2[]{};
		Http http = new Http();
		HttpRequest req = new HttpRequest();
		req.setMethod('GET');
		req.setEndpoint('https://th-superbadge-apex.herokuapp.com/equipment?_ga=2.61238308.920603808.1701993310-792186094.1688594333');

		HttpResponse res = http.send(req);

		if(res.getStatusCode() == 200) {
			List<Object> calloutEquipments = (List<Object>) JSON.deserializeUntyped(res.getBody());
            for(Object calloutEquipment: calloutEquipments) {
                Map<String, Object> data = (Map<String,Object>) calloutEquipment;
            	Product2 equipment = new Product2(
					Replacement_Part__c = (Boolean) data.get('replacement'),
					Cost__c = (Decimal) data.get('cost'),
					Current_Inventory__c = (Decimal) data.get('quantity'),
					Lifespan_Months__c = (Double) data.get('lifespan'),
					Maintenance_Cycle__c = (Double) data.get('maintenanceperiod'),
					Warehouse_SKU__c = (String) data.get('sku'),
					Name = (String) data.get('name')
				);
				newEquipments.add(equipment);
            }

			if(!newEquipments.isEmpty()) {
				upsert newEquipments;

				for(Product2 equipment : newEquipments) {
					System.debug('Equipment: ' + equipment);
					System.debug('Equipment External Id: ' + equipment.ExternalId);
				}
			}
		}


	}
}