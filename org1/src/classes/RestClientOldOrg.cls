
public class RestClientOldOrg 
{
    public class InvalidInputException extends Exception {}
/**
* Retrieve get results, currently a list of unfiltered 
* accounts from old org in sets of 25 
*/
    public static String get() 
    {   
        HttpRequest req = new HttpRequest();
        Http http = new Http();
        String requestURI = RestContext.request.requestURI;
        System.debug('requestURI: ' + requestURI);
        String resourcePath = RestContext.request.resourcePath;
        System.debug('resourcePath: ' + resourcePath);        
        //req.setEndpoint('callout:adobe2'+'/services/data/v37.0/query/?q=select+id,name+from+Account+where+name=\'Burlington Textiles Corp of America\'');
        req.setEndpoint('callout:adobe2/'+resourcePath);
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

        //return response.getBody();
        return response.getBody();

    }

/**
* Post a new record id to its peer in the old org
*/
    @Future(callout=true)
    public static void post(
        String strCalloutUri,
        String strKey,
        String strValue,
        String strSoTypeName,
        String strNewOrgRecordID
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
        req.setEndpoint('callout:adobe2/'+strCalloutUri);
        System.debug('req.getEndPoint: ' + req.getEndPoint());

        Map<String,String> mBody = new Map<String,String>();
        mBody.put('strMsgID',String.valueOf(System.now()));
        mBody.put('strKey',strKey);
        mBody.put('strValue',strValue);
        mBody.put('strSoTypeName',strSoTypeName);
        mBody.put('strNewOrgRecordID',strNewOrgRecordID);

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
}