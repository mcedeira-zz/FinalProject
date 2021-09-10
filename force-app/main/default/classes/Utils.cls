public with sharing class Utils {
    
    public static String randomSalesRep(List<String> values) {
        
        Integer randomNumber = Integer.valueof((Math.random() * values.size()));
        String randomizedResult = values[randomNumber]; 

        return randomizedResult;
    }

    public static Map<Id, Territory__c> owners(List<Account> accounts){ 
        
        Map<Id, Territory__c> ownersMap = new Map<Id, Territory__c>();
        List<String> names = new List<String>();
        List<String> owners = new List<String>();
        
        for(Account a : accounts){
            names.add(a.BillingPostalCode);
            owners.add(a.OwnerId);
        }

        List<Territory__c> territories = [SELECT Id, Name, OwnerId, Owner.Name FROM Territory__c WHERE OwnerId IN :owners AND Name IN :names WITH SECURITY_ENFORCED];

        for(Territory__c t : territories){
            ownersMap.put(t.Id, t);
        }          
        return ownersMap;
    }

    public static Map<String, Territory__c> oldOwners(List<Account> oldAccounts){

        Map<String, Territory__c> oldOwnersMap = new Map<String, Territory__c>();
        List<String> names = new List<String>();
        List<String> owners = new List<String>();
        
        for(Account a : oldAccounts){
            names.add(a.BillingPostalCode);
            owners.add(a.OwnerId);
        }

        List<Territory__c> territories = [SELECT Id, Name, OwnerId, Owner.Name FROM Territory__c WHERE OwnerId IN :owners AND Name IN :names WITH SECURITY_ENFORCED];

        for(Account acc : oldAccounts){

            for(Territory__c t : territories){
                if(acc.OwnerId == t.OwnerId && acc.BillingPostalCode == t.Name){
                    oldOwnersMap.put(acc.Id, t);
                }
            }    
        }
                   
        return oldOwnersMap;
    }
}