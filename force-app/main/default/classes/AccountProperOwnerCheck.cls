public with sharing class AccountProperOwnerCheck {
    
    public static void check(){

        List<Territory__c> territoriesList = new List<Territory__c>();
        // List<Territory__c> sharedZipRepsList = [SELECT Name, OwnerId FROM Territory__c GROUP BY Name HAVING Count(Name) > 1 WITH SECURITY_ENFORCED];
        Map<String, List<String>> sharedZipRepsMap = new Map<String, List<String>>(); 

        for(Territory__c territory : [SELECT Id, Name, OwnerId FROM Territory__c WITH SECURITY_ENFORCED]){

            // if(territoriesList.size() > 0){ // comentado por si tira error linea de abajo -- territoriesList = null
                for(Territory__c terr : territoriesList){ 
                    
                    if(territory.Name == terr.Name){

                        // if(sharedZipRepsMap.size() > 0) // comentado por si tira error linea de abajo -- sharedZipRepsMap = null
                        if(sharedZipRepsMap.containsKey(terr.Name)){
                            // List<String> owners = sharedZipRepsMap.get(terr.Name).add(terr.OwnerId);
                            List<String> owners = sharedZipRepsMap.get(terr.Name);
                            owners.add(terr.OwnerId);
                            sharedZipRepsMap.put(terr.Name, owners);
                        }
                        else {
                            List<String> firstOwnerAssigned = new List<String>{String.valueOf(terr.OwnerId)};
                            // firstOwnerAssigned.add(valueOf(terr.OwnerId));
                            sharedZipRepsMap.put(terr.Name, firstOwnerAssigned);                            
                        }
                    }
                }
            // }
            territoriesList.add(territory);
        }

        // List<Account> accountsIDs = new List<Account>();
        List<Account> accountsToUpdate = new List<Account>();

        for(Account acct : [SELECT Id, Name, OwnerId, BillingPostalCode FROM Account WHERE LastModifiedDate > YESTERDAY WITH SECURITY_ENFORCED]){            
                
            for(Territory__c t : territoriesList){

                if(acct.BillingPostalCode == t.Name){

                    if(sharedZipRepsMap.containsKey(t.Name)){

                        // if sharedZipRepsMap.get(t.Name).contains(acct.OwnerId) ? assa : saas;
                        List<String> ownersCheck = sharedZipRepsMap.get(t.Name);
                        if(!ownersCheck.contains(acct.OwnerId)){

                            acct.OwnerId = Utils.randomSalesRep(ownersCheck);
                        }
                    }
                    else if(acct.OwnerId != t.OwnerId){
    
                        acct.OwnerId = t.OwnerId;
                    }
                    // accountsToUpdate.add(acct);
                }
            }
            // accountsIDs.add(acct.Id);
            accountsToUpdate.add(acct);
        }

        update accountsToUpdate;
        // Update Account's contacts and opps
        HelperAccountTrigger.contactsUpdate(accountsToUpdate);
        HelperAccountTrigger.oppsUpdate(accountsToUpdate);
    }

}
