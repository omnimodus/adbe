public with sharing class OrgDtoCtrlr 
{
	public Integer offset {get; set;}
	public String strSoTypeName = 'Account';

	public OrgDtoCtrlr() 
	{
		if(offset == null || offset < 0)
		{
			this.offset = 0;
		}
	}

/**
* 'callout:adobe2/services/apexrest/sobjxref/'
*/
    public List<Account> getNextQueryOffset() 
    {   
        if(offset == null)
        {
        	throw new InvalidInputException('odt: no query offset found');
        }

        if(strSoTypeName == null)
        {
        	throw new InvalidInputException('odt: strSoTypeName');
        } 

        HttpRequest req = new HttpRequest();
        Http http = new Http();

		req.setEndpoint('callout:adobe2/services/apexrest/sobjxref?offset='+offset+'&sotype='+strSoTypeName);
        
        System.debug('req.getEndPoint: ' + req.getEndPoint());

        req.setMethod('GET');

        req.setHeader('Authorization', 'OAuth {!$Credential.OAuthToken}');
        req.setHeader('Accept', 'application/json');
        req.setHeader('content-type', 'application/json; charset=utf-8');
        HttpResponse response;
        try 
        {
            response = http.send(req);

            if ( response.getStatusCode() != 200 ) 
            {
                System.debug('Error response: ' + response.getBody());
            } 
            else 
            {
                System.debug('Successful response: ' + response.getBody());
            }

        }
        catch( exception ex)
        {
            system.debug('Exception caught: ' + ex.getMessage());
        }

        
		return (List<Account>)JSON.deserialize(response.getBody(), List<Account>.class);
    }

/**
* Generic method to post record id to matching record in old via OAuth
*/
    public static void postNewIdToOldOrg(
    	String strCalloutUri,
    	SObject so,
    	String strFieldName
    	) 
    {
        if(strCalloutUri == null)
        {
            throw new InvalidInputException('no strCalloutUri found.');
        }
        
        HttpRequest req = new HttpRequest();
        Http http = new Http();
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        System.debug('baseUrl: ' + baseUrl);
        //req.setEndpoint('callout:adobe2'+'/services/data/v37.0/query/?q=select+id,name+from+Account+where+name=\'Burlington Textiles Corp of America\'');
        req.setEndpoint('callout:adobe2/'+strCalloutUri);
        System.debug('req.getEndPoint: ' + req.getEndPoint());

        Map<String,String> mBody = new Map<String,String>();
        mBody.put('strMsgID',String.valueOf(System.now()));
        mBody.put('strKey',strFieldName);

        Schema.sobjecttype sot = so.getSObjectType();

        mBody.put('strSoTypeName',sot.getDescribe().getName());
        mBody.put('strValue',(String)so.get('strFieldName'));
        mBody.put('strNewOrgRecordID',(String)so.get('Record_Id_New_Org__c'));

        System.debug('http: req: ' + JSON.serializePretty(mBody));
        req.setBody(JSON.serializePretty(mBody));
        req.setMethod('POST');
        req.setHeader('Authorization', 'OAuth {!$Credential.OAuthToken}');
        req.setHeader('Accept', 'application/json');
        req.setHeader('content-type', 'application/json; charset=utf-8');
        try 
        {
            HttpResponse response = http.send(req);

            if ( response.getStatusCode() != 200 ) 
            {
                System.debug('Error response: ' + response.getBody());
            } 
            else 
            {
                System.debug('Successful response: ' + response.getBody());
            }

        }
        catch( exception ex)
        {
            system.debug('Exception caught: ' + ex.getMessage());
        }
    }
    public class InvalidInputException extends Exception {}   
}