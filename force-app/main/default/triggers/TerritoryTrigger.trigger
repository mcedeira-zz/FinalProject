trigger TerritoryTrigger on Territory__c (before insert, before update) {

    if(Trigger.isBefore){
        if(Trigger.isInsert){
            // List<String> territoriesIds =
            HelperTerritoryTrigger.singleZipCodeAssigned(Trigger.new);
            // for(String Id : territoriesIds){
                // Trigger.newMap.get(Id).addError('Territory is already assigned to three Sales Reps');
            // }
            // system.debug(territoriesIds);
        }   
        if(Trigger.isUpdate){
            // List<String> territoriesIds =
            HelperTerritoryTrigger.singleZipCodeAssigned(Trigger.new);
            // for(String Id : territoriesIds){
            // Trigger.newMap.get(Id).addError('Territory is already assigned to three Sales Reps');
            // }
            // system.debug(territoriesIds);
        }
    }
}