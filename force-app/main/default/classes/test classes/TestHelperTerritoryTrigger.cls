@isTest
private class TestHelperTerritoryTrigger {

    @isTest static void testzipCodeAssignmentInsert(){
        
        List<Territory__c> territoriesWithMultipleOwners = TestDataFactory.createTerritories(15, true);
        List<String> ownerIdList = Utils.restOfUsers(territoriesWithMultipleOwners);
        String ownerId = ownerIdList[0];

        List<Territory__c> territoriesToInsert = new List<Territory__c>();

        for(Integer i = 0; i < territoriesWithMultipleOwners.size(); i+=3){
            territoriesToInsert.add(new Territory__c(Name = territoriesWithMultipleOwners[i].Name,
                OwnerId = ownerId
            ));
        }
        try{
            HelperTerritoryTrigger.zipCodeAssignment(territoriesToInsert);
            insert territoriesToInsert;
        }
        catch(exception e){
            Boolean expectedExceptionThrown = e.getMessage().contains('Territory is already assigned to three Sales Reps') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }
    }

    @isTest static void testzipCodeAssignmentUpdate() {
        
        List<Territory__c> territoriesList = TestDataFactory.createTerritories(10, true);
        Integer counterBackwards = 9;
        Integer x = 0;
        // List to update only first '5' records
        List<Territory__c> territoriesToUpdate = new List<Territory__c>(territoriesList);

        for(Territory__c territory : territoriesList){
            if(x < 5){
                territory.Name = territoriesList[counterBackwards].Name;
                territoriesToUpdate.remove(counterBackwards);
                x += 1;
                counterBackwards -= 1;
            }
            else{
                break;
            }
        }
        try{
            HelperTerritoryTrigger.zipCodeAssignment(territoriesToUpdate);
            update territoriesToUpdate;
        }
        catch(exception e){
            Boolean expectedExceptionThrown = e.getMessage().contains('Territory is already assigned to three Sales Reps') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
           }
    }

    @isTest static void testAccountUpdate(){

        List<Territory__c> territoriesList = TestDataFactory.createTerritories(10, false);
        List<Account> accountsList = TestDataFactory.createAccountsWithZipAndOwner(territoriesList, false);
        insert accountsList;

        String myOwnerId = Utils.myUser(); 
        List<String> accountsIdList = Utils.retrieveAccountsId(accountsList); 

        // Accounts records exist
        for(Account acct : [SELECT Id, Name, OwnerId FROM Account WHERE Name LIKE 'Test Account "N ZIP"%']){  
            accountsIdList.add(acct.Id);
        }
        List<Territory__c> oldTerritoriesList = territoriesList.deepClone(true, false, false); // 'Trigger.old'
        Map<Id, Territory__c> territoriesMapToUpdate = new Map<Id, Territory__c>();

        for(Territory__c territory : territoriesList){
            territory.OwnerId = myOwnerId;
            territoriesMapToUpdate.put(territory.Id, territory);
        }
        // Method to test
        HelperTerritoryTrigger.accountsUpdate(oldTerritoriesList, territoriesMapToUpdate);
        update territoriesList;

        List<Account> accountsUpdateCheck = [SELECT Id, Name, OwnerId, BillingPostalCode FROM Account WHERE LastModifiedDate > YESTERDAY AND OwnerId = :myOwnerId WITH SECURITY_ENFORCED];
        System.assertEquals(10, accountsUpdateCheck.size());
    } 
}