trigger TerritoryTrigger on Territory__c (before insert, before update) {

    if(Trigger.isBefore){
        if(Trigger.isInsert){
            HelperTerritoryTrigger.singleZipCodeAssigned(Trigger.new);
        }   
        if(Trigger.isUpdate){
            HelperTerritoryTrigger.singleZipCodeAssigned(Trigger.new);
        }
    }
}