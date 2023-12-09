public with sharing class WarehouseCalloutService implements Queueable {
    public void execute(QueueableContext context) {
		Http http = new Http();
		HttpRequest req = new HttpRequest();
		req.setMethod('GET');
		req.setEndpoint('https://th-superbadge-apex.herokuapp.com/equipment?_ga=2.61238308.920603808.1701993310-792186094.1688594333');

		HttpResponse res = http.send(req);

		if(res.getStatusCode() == 200) {
			Map<String, Object> results = (Map<String,Object>) JSON.deserializeUntyped(res.getBody());

			System.debug(res.getBody());
		}

	}
}