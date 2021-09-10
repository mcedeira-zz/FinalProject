trigger AccountTrigger on Account (after insert, after update, before update, before insert) {

   if(Trigger.isBefore){
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