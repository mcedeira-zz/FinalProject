public with sharing class Utils {
    
    public static String randomizer(List<String> values) {
        
        Integer randomNumber = Integer.valueof((Math.random() * values.size()));
        String randomizedResult = values[randomNumber]; 

        return randomizedResult;   
    }

    public static Map<Id, Territory__c> territoriesMap(List<Account> accounts){ 
        
        List<String> names = new List<String>();
        List<String> owners = new List<String>();
        
        for(Account a : accounts){
            names.add(a.BillingPostalCode);
            owners.add(a.OwnerId);
        }

        List<Territory__c> territoriesList = [SELECT Id, Name, OwnerId, Owner.Name FROM Territory__c WHERE OwnerId IN :owners AND Name IN :names WITH SECURITY_ENFORCED];
        Map<Id, Territory__c> ownersMap = new Map<Id, Territory__c>(territoriesList);

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

    public static List<User> existingUsers(){

        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Custom: Standard Platform User' WITH SECURITY_ENFORCED];
        List<User> usersList = [SELECT Id, Name FROM User WHERE ProfileId = :profile.Id WITH SECURITY_ENFORCED LIMIT 5];
 
        return usersList;
    }

    public static List<String> restOfUsers(List<Territory__c> territories){

        List<String> usersIds = new List<String>();
        for(Territory__c territory : territories){
            usersIds.add(territory.OwnerId);
        }

        List<User> filteredUsers = [SELECT Id, Name FROM User WHERE Id NOT IN :usersIds WITH SECURITY_ENFORCED];

        List<String> filteredUsersIds = new List<String>();
        for(User user : filteredUsers){
            filteredUsersIds.add(user.Id);
        }

        return filteredUsersIds;
    }

    public static String myUser(){
        
        User user = [SELECT Id FROM User WHERE Name = 'Matias Cedeira' WITH SECURITY_ENFORCED LIMIT 1];
        String userId = user.Id;

        return userId;
    }

    public static List<String> retrieveZIPs(List<Territory__c> territoriesList){

        List<String> zipList = new List<String>();

        for(Territory__c territory : territoriesList){
            zipList.add(territory.Name);
        }
        return zipList;
    }

    public static List<String> retrieveAccountsId(List<Account> accountsList){

        List<String> accountsIDsList = new List<String>();

        for(Account account : accountsList){
            accountsIDsList.add(account.Id);
        }
        return accountsIDsList;
    }

    public static List<String> retrieveOwnerIds(List<Territory__c> territoriesList){

        List<String> ownerIDsList = new List<String>();

        for(Territory__c territory : territoriesList){
            ownerIDsList.add(territory.OwnerId);
        }
        return ownerIDsList;
    }

    public static Map<String, List<String>> territoriesWithMultipleOwners(List<Territory__c> territoriesList){

        List<String> zipList = new List<String>();

        for(Territory__c territory : territoriesList){
            zipList.add(territory.Name);
        }
        List<Territory__c> existingTerritoriesList = [SELECT Id, Name, OwnerId FROM Territory__c WHERE Name IN :zipList WITH SECURITY_ENFORCED];
        List<Territory__c> territoriesAuxList = new List<Territory__c>(existingTerritoriesList); // aux list to check if territorieslist contains [0] 
        territoriesAuxList.remove(0); // remove [0] because contains = true if only 1 element exists

        Map<String, List<String>> territoriesMap = new Map<String, List<String>>();
        List<String> territories = new List<String>();

        for(Territory__c existingTerritory : existingTerritoriesList){

            String zip = existingTerritory.Name;

            if(territories.size() == 0){
                for(Territory__c t : territoriesAuxList){
                    if(t.Name == zip){
                        territoriesMap.put(zip, new List<String>{existingTerritory.OwnerId});
                        break;
                    }
                }
            }
            else if(territories.contains(zip)){
                
                if(territoriesMap.containsKey(zip)){
                    List<String> territoriesMapList = territoriesMap.get(zip);
                    territoriesMapList.add(existingTerritory.OwnerId); // add Id to values list
                    territoriesMap.put(zip, territoriesMapList);
                }
                else{
                    territoriesMap.put(zip, new List<String>{existingTerritory.OwnerId});
                }
            }
            territories.add(zip);
        }

        return territoriesMap;
    }    
}