public with sharing class AsyncUpdateOldOrg implements Queueable
{
    private final SObject so;  


    public void execute(QueueableContext context) 
    {
        try
        {
        	if(so == null)
        	{
        		throw new InvalidInputException('auoo: sobject was null');
        	}
         	if(so.get('ID') == null)
        	{
        		throw new InvalidInputException('auoo: new value org record id to update');
        	}

         	if(so.get('Old_Org_Account_ID__c') == null)
        	{
        		throw new InvalidInputException('auoo: new record id to update');
        	} 

            RestClientOldOrg.post('/services/apexrest/sobjxref/',
        	'ID',
        	(String)so.get('Old_Org_Account_ID__c'), //load the old id AS ID for the post back to the old org
    		'Account',
    		(ID)so.get('ID')); //load the new id as new org id for post back to old org   
        }
        catch(Exception ex)
        {
            System.debug('auoo: ' + ex.getMessage());
        }
    }

    public AsyncUpdateOldOrg(SObject so) 
    {  
        if(so == null)
        {
            throw new InvalidInputException('auoo: sobject was null');
        }


        this.so = so;
    }

    public class InvalidInputException extends Exception{}
}