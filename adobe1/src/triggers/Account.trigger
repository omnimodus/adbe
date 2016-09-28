trigger Account on Account 

    //only those events implemented in the handler method are run but the trigger should capture each event
    (before insert, before update, after insert, after update, before delete, after delete) 
{
    TriggerFactory.createHandler(Account.sObjectType);
}