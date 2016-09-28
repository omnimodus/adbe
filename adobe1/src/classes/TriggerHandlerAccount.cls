/**
 * Class TriggerHandlerAccount
 *
 * Trigger Handler for the Account SObject. This class implements the ITrigger
 * interface to help ensure the trigger code is bulkified and all in one place.
 */
public with sharing class TriggerHandlerAccount
    implements TriggerHandlerInterface
{   
     
/**
 * bulkBefore
 * this signature only called for "before insert" triggers since they have no IDs
 * yet for a Trigger.newMap. 
*/
    public void bulkBefore(
        List<SObject> lSObjectNew,
        List<SObject> lSObjectOld)
    {
    }

    /**
     * bulkBefore
     *
     * This method is called prior to execution of a BEFORE trigger. Use this to cache
     * any data required into maps prior execution of the trigger.
     */    
    public void bulkBefore(Map<ID,SObject> mSObjectNew,Map<ID,SObject> mSObjectOld)
    {
    }
    
    public void bulkAfter(Map<ID,SObject> mSObjectNew,Map<ID,SObject> mSObjectOld)
    {
    }
        
    public void beforeInsert(SObject soNew)
    {
    
    }
    
    public void beforeUpdate(SObject soOld, SObject soNew)
    {
       
    }
    
    /**
     * beforeDelete
     *
     * This method is called iteratively for each record to be deleted during a BEFORE
     * trigger.
     */
    public void beforeDelete(SObject so)
    {   
      /**       */
    }
    
    public void afterInsert(SObject so)
    {
        setNewOrgAcctID(so); //put hear to ensure id has new
    }
    
    public void afterUpdate(SObject soOld, SObject soNew)
    {
    }
    
    public void afterDelete(SObject so)
    {
    }
    
    /**
     * andFinally
     *
     * This method is called once all records have been processed by the trigger. Use this 
     * method to accomplish any final operations such as creation or updates of other records.
     */
    public void andFinally()
    {
        // insert any audit records
        /**
        if (!m_audits.isEmpty())
        {
            insert m_audits;
        }
        */
    }
    
    public void setNewOrgAcctID(SObject soNew)
    {
        if(soNew.get('ID') == null)
        {
            System.debug('trigger: acct: skipping: record id found with which to update.');
            return;
        }

        if(soNew.get('Old_Org_Account_ID__c') == null)
        {
            System.debug('trigger: acct: skipping: No old org record id found.');
            return;
        }
 
        try
        {
            ID idJob = System.enqueueJob(new AsyncUpdateOldOrg(soNew));
        }
        catch(Exception ex)
        {
            System.debug('trigger: acct:' + ex.getMessage());
        } 
    }  
}