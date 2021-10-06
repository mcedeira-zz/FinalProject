@isTest
private class TestHelperAccountTrigger {

    @isTest static void testAccountsInsert() {

        List<Territory__c> territoriesList = TestDataFactory.createTerritories(10, false);
        List<Account> accountsList = TestDataFactory.createAccountsWithZIP(territoriesList, false);

        HelperAccountTrigger.accountsInsert(accountsList);
        insert accountsList;

        List<String> zipList = Utils.retrieveZIPs(territoriesList);
        List<String> ownersIDsList = Utils.retrieveOwnerIds(territoriesList);
        List<String> accountsIDsList = Utils.retrieveAccountsId(accountsList);

        List<Account> accountsQueryList = [SELECT Name, BillingPostalCode, OwnerId FROM Account WHERE BillingPostalCode IN :zipList AND OwnerId IN :ownersIDsList WITH SECURITY_ENFORCED];
        system.assertEquals(10, accountsQueryList.size());
    }

    @isTest static void testAccountAndRelatedUpdates() {

        List<Territory__c> territoriesList = TestDataFactory.createTerritories(4, false);
        List<Account> accountsList = TestDataFactory.createAcctsWithContactsOpps(4);
        // "Trigger.oldMap"
        List<Account> auxAccountsList = accountsList.deepClone(true, false, false);
        Map<Id, Account> oldAccountsMap = new Map<Id,Account>(auxAccountsList);
        
        List<String> accountsIDsList = Utils.retrieveAccountsId(accountsList);
        Integer index = 0;

        for(Account acct : accountsList){
            // accountsMap.put(acct.Id, acct);
            acct.BillingPostalCode = territoriesList[index].Name;
            index += 1;

            if(index == territoriesList.size()){
                index = 0;
            }
        }
        HelperAccountTrigger.accountUpdate(oldAccountsMap, accountsList);
        update accountsList;

        List<Account> accountsUpdated = [SELECT Id, Name, OwnerId, BillingPostalCode FROM Account WHERE Name LIKE 'Test Account%'];
        Integer counter = 0;
        List<String> ownersIDsList = new List<String>();

        for(Account a : accountsUpdated){
            Account oldAcct = oldAccountsMap.get(a.Id);
        
            if(a.OwnerId != oldAcct.OwnerId){
                counter += 1;
                ownersIDsList.add(a.OwnerId);
            }
        }
        System.assertEquals(4, counter, 'Accounts');

        HelperAccountTrigger.contactsUpdate(accountsUpdated);
        List<Contact> contactsUpdateCheck = [SELECT LastName, OwnerId FROM Contact WHERE AccountId IN :accountsIDsList AND OwnerId IN :ownersIDsList];
        System.assertEquals(4, contactsUpdateCheck.size(), 'Contacts');

        HelperAccountTrigger.oppsUpdate(accountsUpdated);
        List<Opportunity> oppsUpdateCheck = [SELECT Name, OwnerId FROM Opportunity WHERE AccountId IN :accountsIDsList AND OwnerId IN :ownersIDsList];
        System.assertEquals(4, oppsUpdateCheck.size(), 'Opportunities');
    }
    // Special cases //
        // Multiple owners
    @isTest static void testMultipleSalesRepsInsert(){

        List<Territory__c> territoriesList = TestDataFactory.createTerritories(10, true);
        List<Account> accountsList = TestDataFactory.createAccountsWithZIP(territoriesList, true);
        
        HelperAccountTrigger.accountsInsert(accountsList);
        insert accountsList;
 
        List<String> ownersIDsList = Utils.retrieveOwnerIds(territoriesList);
        List<String> accountsIDsList = Utils.retrieveAccountsId(accountsList);
 
        List<Account> accountsQueryList = [SELECT Name, BillingPostalCode, OwnerId FROM Account WHERE Id IN :accountsIDsList AND OwnerId IN :ownersIDsList WITH SECURITY_ENFORCED];
        system.assertEquals(10, accountsQueryList.size());
    }

    //update
    @isTest static void testMultipleSalesRepsUpdate(){

        // 'Trigger.new'
        List<Territory__c> territoriesList = TestDataFactory.createTerritories(3, true);
        Integer numOfAccounts = territoriesList.size() / 3;
        List<Account> accountsCreatedList = TestDataFactory.createAcctsWithContactsOpps(numOfAccounts); 
        // "Trigger.oldMap"
        List<Account> auxAccountsList = accountsCreatedList.deepClone(true, false, false);
        Map<Id, Account> oldAccountsMap = new Map<Id, Account>(auxAccountsList);
        // Map<Id, Account> oldAccountsMap = new Map<Id, Account>();

        List<String> accountsIDsList = new List<String>();
        Integer index = 0;

        for(Account account : accountsCreatedList){ 
            // oldAccountsMap.put(account.Id, account);
            String newZip = territoriesList[index].Name;
            account.BillingPostalCode = newZip; 
            accountsIDsList.add(account.Id);
            index += 3;
        }

        HelperAccountTrigger.accountUpdate(oldAccountsMap, accountsCreatedList);
        update accountsCreatedList;

        List<Account> accountsUpdated = [SELECT Name, OwnerId FROM Account WHERE Id IN :accountsIDsList];
        
        List<String> ownersList = new List<String>();
        for(Account acct : accountsUpdated){
            ownersList.add(acct.OwnerId);
        }

        List<Account> accountsUpdateCheck = [SELECT Id, Name, OwnerId FROM Account WHERE Id IN :accountsIDsList AND OwnerId IN :ownersList]; 
        System.assertEquals(numOfAccounts, accountsUpdateCheck.size());
        
        HelperAccountTrigger.contactsUpdate(accountsUpdated);   
        List<Contact> contactsUpdateCheck = [SELECT LastName, OwnerId FROM Contact WHERE AccountId IN :accountsIDsList AND OwnerId IN :ownersList];
        System.assertEquals(numOfAccounts, contactsUpdateCheck.size(), 'Contacts');

        HelperAccountTrigger.oppsUpdate(accountsUpdated);
        List<Opportunity> oppsUpdateCheck = [SELECT Name, OwnerId FROM Opportunity WHERE AccountId IN :accountsIDsList AND OwnerId IN :ownersList];
        System.assertEquals(numOfAccounts, oppsUpdateCheck.size(), 'Opportunities');

    }
    // Existing Owner associated to Territory__c record
    @isTest
    static void testAccountsWithOldOwnersUpdate(){

        // territories with Owners
        List<Territory__c> territoriesList = TestDataFactory.createTerritories(4, false);
        // accts witohout ZIP nor Owner
        List<Account> accountsList = TestDataFactory.accountsCreationFromHalfTerritories(territoriesList);
        // triggerOldMap
        List<Account> oldAccountsList = accountsList.deepClone(true, false, false);
        Map<Id, Account> oldAccountsMap = new Map<Id, Account>(oldAccountsList);
        // Map<Id, Account> oldAccountsMap = new Map<Id, Account>();

        List<String> ownersList = new List<String>();

        for(Integer i = 0; i < territoriesList.size(); i++){
            ownersList.add(territoriesList[i].OwnerId);
        }
        // Assign [2,3] zips to [0,1] (accounts)
        List<String> accountsIDsList = new List<String>();

        Integer index = (territoriesList.size() / 2) - 1;

        for(Account account : accountsList){
            // oldAccountsMap.put(account.Id, account);
            Territory__c territory = territoriesList[index];
            account.BillingPostalCode = territory.Name;
            accountsIDsList.add(account.Id);
            index += 1;
            if(index == territoriesList.size()){
                // middle index #
                index = 2;
            }
        }
        HelperAccountTrigger.accountUpdate(oldAccountsMap, accountsList);
        update accountsList;

        Integer numOfAccounts = accountsList.size();

        List<Account> accountsUpdateCheck = [SELECT Id, Name, OwnerId FROM Account WHERE Id IN :accountsIDsList AND OwnerId IN :ownersList]; 
        System.assertEquals(numOfAccounts, accountsUpdateCheck.size());

        HelperAccountTrigger.contactsUpdate(accountsList);   
        List<Contact> contactsUpdateCheck = [SELECT LastName, OwnerId FROM Contact WHERE AccountId IN :accountsIDsList AND OwnerId IN :ownersList];
        System.assertEquals(numOfAccounts, contactsUpdateCheck.size(), 'Contacts');

        HelperAccountTrigger.oppsUpdate(accountsList);
        List<Opportunity> oppsUpdateCheck = [SELECT Name, OwnerId FROM Opportunity WHERE AccountId IN :accountsIDsList AND OwnerId IN :ownersList];
        System.assertEquals(numOfAccounts, oppsUpdateCheck.size(), 'Opportunities');
    }

    @isTest
    public static void testEmail(){

        List<Territory__c> territoriesList = TestDataFactory.createTerritories(2, false);
        List<Account> accountsList = TestDataFactory.createAccountsWithZip(territoriesList, false); // List return but not inserted
        Account account = accountsList[0]; // ZIP = 1000
        List<Account> auxAccountList = new List<Account>{account};

        HelperAccountTrigger.accountsInsert(auxAccountList); // Sets OwnerId 
        insert account; // test performed only in [0] with [1].ZIP code

        String oldOwnerId = territoriesList[0].OwnerId;
        String newOwnerId = territoriesList[1].OwnerId;

        Test.startTest();

        System.assertEquals(0, Limits.getEmailInvocations(), 'No emails should be sent');
        AccountController.sendEmail(account.Id, oldOwnerId, newOwnerId);        
        System.assertEquals(1, Limits.getEmailInvocations(), 'Emails should be sent');

        Test.stopTest();
    }
}