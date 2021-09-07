public with sharing class HelperTerritoryTrigger {

    // List<String>
    public static void singleZipCodeAssigned(List<Territory__c> territories) {
        
        //Return list of Ids
        List<String> territoriesIds = new List<String>();

        List<String> names = new List<String>();
        for(Territory__c terr : territories){
            
            names.add(terr.Name);
        }

        List<Territory__c> existingTerritory = [SELECT Name, Owner__c FROM Territory__c WHERE Name IN :names WITH SECURITY_ENFORCED];
        for(Territory__c t : territories){
            
            Integer quantity = 0;
            for(Territory__c eT : existingTerritory){
    
                if(eT.Name == t.Name){
                    quantity++;
                    if(quantity >= 2){
                        t.addError('Territory ' +t.Name+ ' is already assigned to three Sales Reps');
                    }
                }
            }
        }
    // return territoriesIds;
    }
}