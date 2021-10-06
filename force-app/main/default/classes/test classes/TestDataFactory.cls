@isTest
public class TestDataFactory {

    // territories with Owners
    public static List<Territory__c> createTerritories(Integer numTerritories, Boolean multipleOwners){ 

        List<User> usersList = Utils.existingUsers();
        List<String> salesReps = new List<String>();

        for(User user : usersList){
            salesReps.add(user.Id);
        }
        List<Territory__c> newTerritories = new List<Territory__c>();
        Integer numZip = 1000;

        // singleOwner / multipleOwner logic
        if(!multipleOwners){
            for(Integer z=0; z < numTerritories; z++){
                String salesRep = Utils.randomizer(salesReps);
                newTerritories.add(new Territory__c(Name = String.valueOf(numZip),
                    OwnerId = salesRep
                ));
                numZip = numZip + 10;
            }
        }
        else{
            for(Integer z=0; z < numTerritories; z++){
                for(Integer m = 0; m < 3; m++){
                    String salesRep = Utils.randomizer(salesReps);
                    newTerritories.add(new Territory__c(Name = String.valueOf(numZip),
                        OwnerId = salesRep
                    ));
                }
                numZip = numZip + 10;
            }
        }
        insert newTerritories;

        return newTerritories; 
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////////
    public static List<Account> createAcctsWithContactsOpps(Integer numAccts){

        List<Account> acctsList = new List<Account>();

        for(Integer i=0; i < numAccts; i++){
            acctsList.add(new Account(Name = 'Test Account ' + i));
        }

        insert acctsList;
    
        List<Contact> contactsList = new List<Contact>();
        List<Opportunity> oppsList = new List<Opportunity>();

        for(Account a : acctsList){
                // Contact
                contactsList.add(new Contact(LastName = a.Name + ' Contact Test',
                    AccountId = a.Id));
                // Opp
                oppsList.add(new Opportunity(Name = a.Name + ' Opportunity Test',
                    StageName = 'Prospecting',
                    CloseDate = System.today().addMonths(1),
                    AccountId = a.Id));
        }
        insert contactsList;
        insert oppsList;
        
        return acctsList;
    }
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    public static List<Account> createAccountsWithZipAndOwner(List<Territory__c> territoriesList, Boolean areMultiple){

        // Territories
        Integer listSize = territoriesList.size();
        Integer numOfAccounts;

        Integer index = 0;
        Integer num;
        if(areMultiple){
            num = 3;
            numOfAccounts = listSize / 3;
        }
        else{
            num = 1;
            numOfAccounts = listSize;
        }
        List<Account> accountsList = new List<Account>();
 
        for(Integer i=0; i < numOfAccounts; i++){

            Account acct = new Account(Name = 'Test Account "N ZIP" '+i,
                BillingPostalCode = territoriesList[index].Name,
                OwnerId = territoriesList[index].OwnerId
            );
            accountsList.add(acct);
            index += num;
        }
        return accountsList;
    }

    public static List<Account> accountsCreationFromHalfTerritories(List<Territory__c> territoriesList){

        List<String> ownersList = new List<String>();
        List<String> zipList = new List<String>();
        Integer halfList = territoriesList.size() / 2;

        for(Integer i = 0; i < halfList; i++){
            zipList.add(territoriesList[i].Name);
            ownersList.add(territoriesList[i].OwnerId);
        }        
        List<Account> accountsList = new List<Account>();
        Integer numOfAccounts = territoriesList.size();
        Integer index = 0;
        Integer maxIndex = halfList - 1;

        for(Integer k = 0; k < numOfAccounts; k++){
            accountsList.add(new Account(Name = 'Test Account ' +k,
                BillingPostalCode = zipList[index],
                OwnerId = ownersList[index]));
            index += 1;
            if(index == maxIndex){
                index = 0;
            }
        }
        insert accountsList;

        List<Contact> contactsList = new List<Contact>();
        List<Opportunity> oppsList = new List<Opportunity>();

        for(Account a : accountsList){
            // Contact
            contactsList.add(new Contact(LastName = a.Name + ' Contact Test',
                AccountId = a.Id));
            // Opp
            oppsList.add(new Opportunity(Name = a.Name + ' Opportunity Test',
                StageName = 'Prospecting',
                CloseDate = System.today().addMonths(1),
                AccountId = a.Id));
        }
        insert contactsList;
        insert oppsList;
    
        return accountsList;
    }

    public static List<Account> createAccountsWithZip(List<Territory__c> territoriesList, Boolean areMultiple){

        // Territories
        Integer listSize = territoriesList.size();
        Integer numOfAccounts;

        Integer index = 0;
        Integer num;
        if(areMultiple){
            num = 3;
            numOfAccounts = listSize / 3;
        }
        else{
            num = 1;
            numOfAccounts = listSize;
        }
        List<Account> accountsList = new List<Account>();

        for(Integer i=0; i < numOfAccounts; i++){

            Account acct = new Account(Name = 'Test Account "N ZIP" '+i,
                BillingPostalCode = territoriesList[index].Name
            );
            accountsList.add(acct);
            index += num;
        }
        
        return accountsList;
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    public static List<Account> schedulableAccounts(List<Territory__c> territoriesList){

        Integer numOfAccounts = territoriesList.size();

        List<String> zipList = new List<String>();
    
        for(Territory__c territory : territoriesList){
            zipList.add(territory.Name);
        }
        List<Account> accountsToReturn = new List<Account>();

        for(Integer i = 0; i < numOfAccounts; i++){
            accountsToReturn.add(new Account(Name = 'Territory schedulable #'+i,
                BillingPostalCode = zipList[i]
            ));
        }
        insert accountsToReturn;

        return accountsToReturn;
    }

    // public static List<Account> accountsForAssignmentHistory(List<Territory__c> territoriesList, Boolean hasOldOwner){

    //     List<Account> accountsList = new List<Account>();
        
    //     if(hasOldOwner){

    //     }
    //     else{
    //         for(Territory__c territory : territoriesList){

    //         }
    //     }
    // }
}