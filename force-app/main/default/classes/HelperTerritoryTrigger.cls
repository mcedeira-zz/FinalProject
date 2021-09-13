public with sharing class HelperTerritoryTrigger {

    // List<String>
    public static void singleZipCodeAssigned(List<Territory__c> territories) {
        
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
                    if(quantity > 2){
                        t.addError('Territory ' +t.Name+ ' is already assigned to three Sales Reps');
                    }
                }
            }
        }
    }

    public static void accountsUpdate(List<Territory__c> oldTerritories, Map<Id, Territory__c> territoriesMap){

        List<String> names = new List<String>();
        List<String> owners = new List<String>();
        for(Territory__c terr : oldTerritories){           
            names.add(terr.Name);
            owners.add(terr.OwnerId);
        }

        List<Account> acctsToUpd = new List<Account>();
        List<Account> accountsList = [SELECT Id, OwnerId, BillingPostalCode FROM Account WHERE OwnerId IN :owners AND BillingPostalCode IN :names WITH SECURITY_ENFORCED];

        for(Territory__c oT : oldTerritories){
            Territory__c newOwner = territoriesMap.get(oT.Id);
            // system.debug('HELPER= '+newOwner);
            // system.debug('HELPER old= '+oT);
            // system.debug(accountsList.size());
            // system.debug(accountsList[0]);

            for(Account a : accountsList){
                system.debug('1= '+a);
                system.debug('oldTerritory ownerId= ' +oT.OwnerId+ ' / acct ownerId= '+a.OwnerId+' / oldTerritory BillingAddr= '+oT.Name+ ' / acct Name= '+a.BillingPostalCode);

                if(oT.OwnerId == a.OwnerId && oT.Name == a.BillingPostalCode){
                    a.OwnerId = newOwner.OwnerId;
                    // system.debug(newOwner.Owner.Name);
                    acctsToUpd.add(a);
                }
            }
        }
        update acctsToUpd;
    } 

    public static void contactsUpdate(List<Territory__c> oldTerritories, Map<Id, Territory__c> territoriesMap){


    }
}