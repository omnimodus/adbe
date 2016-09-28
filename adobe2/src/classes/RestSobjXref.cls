@RestResource(urlMapping='/sobjxref/*')

global with sharing class RestSobjXref
{ 
/**
* Query the sobject with inbound payload and, if found, update the sobjects new_org... field with
* new org id and return old org id

* This returns something like this:
{
  "attributes" : {
    "type" : "Remote_Message_Log__c",
    "url" : "/services/data/v37.0/sobjects/Remote_Message_Log__c/a0041000001wrxeAAA"
  },
  "Rem_Msg_ID__c" : "test1",
  "Sobj_Type__c" : "Account",
  "External_ID__c" : "00000000000NEW",
  "Id" : "a0041000001wrxeAAA",
  "Status__c" : "Failure",
  "Detail__c" : "duplicate field selected: Id"
}
*/
    @HttpPost
    global static String post(   
    String strMsgID, 
    String strKey,
    String strValue,
    String strSoTypeName,
    String strNewOrgRecordID) 
    {     
        Remote_Message_Log__c rml = getRemoteMsgLogInstanceWithValidatedParams(
        strMsgID, 
        strKey,
        strValue,
        strSoTypeName,
        strNewOrgRecordID);
        
        if(rml.Status__c == 'Failure')
        {
            insert rml;
            System.debug('rsx: message log entry: ' + JSON.serializePretty(rml));
            return JSON.serializePretty(rml);
        } 

        RestRequest req;
        RestResponse res;  

        try 
        {
            
            // insert the messageLog, which will raise a DUPLICATE exception if:
            //- a corresponding message log record is already present
            //- the sobject type specified by inbound params is not on picklist
            insert rml;
            System.debug('rsx: message not a duplicate.');
            //if this far, then msg is new and with approved sobj type
            req = RestContext.request;
            res = RestContext.response;


            String strSoql = 'SELECT ';
            if(strKey != 'Id')
            {
                strSoql += 'Id, ';
            }
            strSoql += ' Record_Id_New_Org__c,' + strKey + ' FROM ' + strSoTypeName + ' WHERE ' + strKey +' = \'' + strValue + '\' LIMIT 1';

            System.debug('rsx: soql: ' + strSoql);

            SObject so = Database.query(strSoql);

            if(so == null)
            {
                rml.Detail__c = 'result list for httppatch was null or empty from this type/key/value: ' + strSoTypeName + '/' + strKey + '/' + strValue;
                rml.Status__c = 'Failure';
                throw new InvalidInputException('rsx: failed to retrieve record for update with this key/value: ' + strKey + '/' + strValue);
            }
            
            so.put('Record_Id_New_Org__c',strNewOrgRecordID);
            update so;
            rml.Status__c = 'Success';
            rml.Detail__c = so.ID;
            res.statusCode = 200;
        }
        catch (Exception ex) 
        {
            rml.Status__c = 'Failure';
            rml.Detail__c = ex.getMessage();
            res.statusCode = 500;
        }
        return JSON.serializePretty(rml);
    }

    @HttpGet
    global static List<SObject> get() 
    {      
        List<SObject> lso;

        try 
        {            
            //if this far, then msg is new and with approved sobj type
            RestRequest req = RestContext.request;

            Map<String, String> mParam = req.params;

            String strSoql = getSoqlString(req.params.get('sotype'),req.params.get('offset'));

            RestResponse res = RestContext.response;
            //String idAcct = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
      
            lso = getSoqlResult(strSoql);
        }
        catch (Exception ex) 
        {
            System.debug('rsx: Account get failed: ' + ex.getMessage());     
        }
      
        return lso;
    }

    @TestVisible
    private static String getSoqlString(
        String strSoTypeName,
        String strOffset)
    {
        if(strSoTypeName == null)
        {
            throw new InvalidInputException('rsx: no sobjecttype name specified for query.');
        }

        if(strOffset == null)
        {
            throw new InvalidInputException('rsx: no offset string specified for query.');
        }

        Integer offset = Integer.valueOf(strOffset);

        if(offset < 0)
        {
            throw new InvalidInputException('rsx: no valid query offset integer specified for query:' + offset);
        }

        String strSoql = 'SELECT Id '
        + ', Name '
        + ', Record_Id_New_Org__c '
        + ' FROM ' + strSoTypeName + ' '
        + ' ORDER BY Name ASC '
        + ' LIMIT 25 '
        + ' OFFSET ' + offset;

        return strSoql;
    }

    @TestVisible
    /**
    * have this extra bit since soql is not validated at compile time.
    * fail gracefully with an empty list so nothing to bad happens
    * down stream
    */
    private static List<SObject> getSoqlResult(String strSoql)
    {
        List<SObject> lso = new List<SObject>();

        if(strSoql == null)
        {
            throw new InvalidInputException('no soql found for query.');
        }

        System.debug('rsx: soql: ' + strSoql);
            
        try 
        {
            lso = Database.query(strSoql);
        } 
        catch(Exception ex) 
        {
            System.debug('rsx: ' + ex.getMessage());
        } 

        return lso;
    }

    public static Remote_Message_Log__c getRemoteMsgLogInstanceWithValidatedParams(
        String strMsgID, 
        String strKey,
        String strValue,
        String strSoTypeName,
        String strNewOrgRecordID
    )
    {
        Remote_Message_Log__c rml = new Remote_Message_Log__c();

        if(strMsgID == null) //don't do anything without a msg id to track activity
        {
            rml.Status__c = 'Failure';
            rml.Detail__c = 'httppatch strMsgID was null.';
        }
            
       //init a log object to identify if this is a duplicate call on a whitelisted sobj type
        rml.Rem_Msg_ID__c = strMsgID;
        
        if(strSoTypeName == null)
        {
            rml.Status__c = 'Failure';
            rml.Detail__c = 'no sobject type specified';
            return rml;
        }
        
        rml.Sobj_Type__c = strSoTypeName;

        if(strKey == null)
        {
            rml.Status__c = 'Failure';
            rml.Detail__c = 'no where key specified';
            return rml;
        }

        if(strValue == null)
        {
            rml.Status__c = 'Failure';
            rml.Detail__c = 'no where value specified';
            return rml;
        }

        if(strNewOrgRecordID == null)
        {
            rml.Status__c = 'Failure';
            rml.Detail__c = 'no new org record id specified';
            return rml;
        }
        
        rml.Ext_Org_Record_ID__c = strNewOrgRecordID;
        
        return rml;   
    } 

    public class InvalidInputException extends Exception {}     
}