trigger AccountTrigger on Account (after insert, after update, before update, before insert) {

   if(Trigger.isBefore){
        if(Trigger.isUpdate){
            HelperAccountTrigger.accountUpdate(Trigger.new, Trigger.oldMap);
        }    
    }
    
    if(Trigger.isAfter){
        if(Trigger.isUpdate){
            HelperAccountTrigger.contactsUpdate(Trigger.new);
            HelperAccountTrigger.oppsUpdate(Trigger.new);    
        }
    }
}