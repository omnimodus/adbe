@isTest (seealldata=true)
private class RestSobjXrefTest
{
	@isTest
	static void testGetSuccess()
	{
		RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();
 
		req.requestURI = '/services/apexrest/sobjxref';
		req.httpMethod = 'GET';
		RestContext.request = req;
		req.params.put('sotype','Account');
		req.params.put('offset','0');
		RestContext.response = res;		
		List<SObject> lso = RestSobjXref.get();
		System.assertNotEquals(null,lso);
	}

	@isTest
	static void testPostSuccess()
	{
		RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();
 
		req.requestURI = '/services/apexrest/sobjxref';
		req.httpMethod = 'POST';
		RestContext.request = req;

		RestContext.response = res;		
		String str = RestSobjXref.post('test1','ID','00000000000OLD','Account','00000000000NEW');
		System.assertNotEquals(null,str);
		//Old_Org_Account_ID__c
	}
	@isTest
	static void testGetSoqlString()
	{
		String strSoql = RestSobjXref.getSoqlString('Account','0');
		System.assertNotEquals(null,strSoql);
		System.debug('rsx: test: soql: ' + strSoql);
	}

	@isTest
	static void testGetSoqlResult()
	{
		String strSoql = RestSobjXref.getSoqlString('Account','0');
		System.assertNotEquals(null,strSoql);
		System.debug('rsx: test: soql: ' + strSoql);
	}	
}