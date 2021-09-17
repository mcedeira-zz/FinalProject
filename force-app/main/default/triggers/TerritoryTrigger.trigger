trigger TerritoryTrigger on Territory__c (before insert, before update, after update) {

    if(Trigger.isBefore){
        if(Trigger.isInsert){
            HelperTerritoryTrigger.singleZipCodeAssigned(Trigger.new);
        }   
        if(Trigger.isUpdate){
            HelperTerritoryTrigger.singleZipCodeAssigned(Trigger.new);
        }
    }

    if(Trigger.isAfter){
        if(Trigger.isUpdate){
            HelperTerritoryTrigger.accountsUpdate(Trigger.old, Trigger.newMap);
        }
    }
}