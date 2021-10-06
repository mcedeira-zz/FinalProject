trigger AccountTrigger on Account (before insert, before update, after update) {

   if(Trigger.isBefore){
        if(Trigger.isInsert){
            HelperAccountTrigger.accountsInsert(Trigger.new);
        }
        if(Trigger.isUpdate){
            HelperAccountTrigger.accountUpdate(Trigger.oldMap, Trigger.new);
        }    
    }
    
    if(Trigger.isAfter){
        if(Trigger.isUpdate){
            HelperAccountTrigger.contactsUpdate(Trigger.new);
            HelperAccountTrigger.oppsUpdate(Trigger.new);    
            HelperAccountTrigger.assignmentCreation(Trigger.oldMap, Trigger.new);
        }
    }
}