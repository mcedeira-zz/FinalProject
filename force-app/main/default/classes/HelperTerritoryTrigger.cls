public with sharing class HelperTerritoryTrigger {

    // List<String>
    public static void zipCodeAssignment(List<Territory__c> territories) {
        
        List<String> names = new List<String>();

        for(Territory__c terr : territories){           
            names.add(terr.Name);
        }
        List<Territory__c> existingTerritory = [SELECT Name, OwnerId FROM Territory__c WHERE Name IN :names WITH SECURITY_ENFORCED];

        for(Territory__c t : territories){
            Integer quantity = 0;

            for(Territory__c eT : existingTerritory){

                if(eT.Name == t.Name){
                    quantity++;
                    if(quantity == 3){
                        t.addError('Territory is already assigned to three Sales Reps');
                    }
                }
                else{
                    return;
                }
            }
        }
    }

    public static void accountsUpdate(List<Territory__c> oldTerritories, Map<Id, Territory__c> territoriesMap){

        List<Account> accountsToUpd = new List<Account>();
        List<String> zipList = new List<String>();
        
        for(Territory__c territory : oldTerritories){
            zipList.add(territory.Name);
        }
        List<Account> accountsList = [SELECT Id, Name, OwnerId, BillingPostalCode FROM Account WHERE BillingPostalCode IN :zipList WITH SECURITY_ENFORCED];

        for(Territory__c oT : oldTerritories){
            Territory__c newOwner = territoriesMap.get(oT.Id);
          
            for(Account a : accountsList){
                
                if(oT.Name == a.BillingPostalCode && oT.OwnerId == a.OwnerId){
                    a.OwnerId = newOwner.OwnerId;
                    accountsToUpd.add(a);
                }
            }
        }
        update accountsToUpd;
    } 
}