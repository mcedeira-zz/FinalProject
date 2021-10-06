trigger TerritoryTrigger on Territory__c (before insert, before update, after update) {

    if(Trigger.isBefore){
        if(Trigger.isInsert){
            HelperTerritoryTrigger.zipCodeAssignment(Trigger.new);
        }   
        if(Trigger.isUpdate){
            HelperTerritoryTrigger.zipCodeAssignment(Trigger.new);
        }
    }

    if(Trigger.isAfter){
        if(Trigger.isUpdate){
            HelperTerritoryTrigger.accountsUpdate(Trigger.old, Trigger.newMap);
        }
    }
}