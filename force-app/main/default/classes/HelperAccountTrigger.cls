public with sharing class HelperAccountTrigger {

    public static void accountUpdate(Map<Id, Account> triggerOldMap, List<Account> triggerNew){
        
        List<Territory__c> territoriesList = [SELECT Name, OwnerId FROM Territory__c WITH SECURITY_ENFORCED];

        //Actual logic
        for(Account acct : triggerNew){

            Account oldAcct = triggerOldMap.get(acct.Id);
            if(acct.BillingPostalCode != oldAcct.BillingPostalCode){
                List<String> salesReps = new List<String>();
      
                for(Territory__c sR : territoriesList){

                    if(sR.Name == acct.BillingPostalCode){
                        salesReps.add(sR.OwnerId);
                    }
                }
                // system.debug(salesReps.size());
                // system.debug(salesReps);

                if(salesReps.size() > 1){
                    String randomizedRep = Utils.randomSalesRep(salesReps);
                    if(randomizedRep != null){
                        acct.OwnerId = randomizedRep;
                    }
                }
                else{
                    acct.OwnerId = salesReps[0]; 
                }
            } 
        }
    }

    public static void contactsUpdate(List<Account> acctsForContacts){

        List<Contact> contactsToUpd = new List<Contact>();
        List<Contact> contactsList = [SELECT AccountId, OwnerId FROM Contact WHERE AccountId IN :acctsForContacts WITH SECURITY_ENFORCED];

        for(Account acct : acctsForContacts){

            for(Contact c : contactsList){
            
                if(c.AccountId == acct.Id){
                    c.OwnerId = acct.OwnerId;
                    contactsToUpd.add(c);
                }
            }
        }
        update contactsToUpd;
    } 

    public static void oppsUpdate(List<Account> acctsForOpps){

        List<Opportunity> oppsToUpd = new List<Opportunity>();
        List<Opportunity> opportunitiesList = [SELECT AccountId, OwnerId, StageName FROM Opportunity WHERE AccountId IN :acctsForOpps WITH SECURITY_ENFORCED];

        for(Account acct : acctsForOpps){
            
            for(Opportunity o : opportunitiesList){
                if(o.AccountId == acct.Id){
                    if(o.StageName != 'Closed Won' && o.StageName != 'Closed Lost'){
                        o.OwnerId = acct.OwnerId;
                        oppsToUpd.add(o);
                    }
                }
            }
        }
        update oppsToUpd;
    }

    public static void assignmentCreation(Map<Id, Account> oldAcctsMap, List<Account> newAcctsList){
        
        List<Assignment_History__c> recordsToCreate = new List<Assignment_History__c>();
        
        Map<String, Territory__c> oldOwnersMap = Utils.oldOwners(oldAcctsMap.values());
        Map<Id, Territory__c> newOwnersMap = Utils.owners(newAcctsList);
        
        for(Account acct : newAcctsList){
            Account oldAcct = oldAcctsMap.get(acct.Id);
            if(acct.BillingPostalCode != oldAcct.BillingPostalCode){
                
                for(Territory__c newOwner : newOwnersMap.values()){
                    if(acct.OwnerId == newOwner.OwnerId && acct.BillingPostalCode == newOwner.Name){                       
                        // system.debug(newOwner);
                        // system.debug(oldOwnersMap.get(acct.Id));
                        Territory__c oldOwner = oldOwnersMap.get(acct.Id);

                        Assignment_History__c newAssignment = new Assignment_History__c();
                            
                        if(oldOwner != null){
                            newAssignment.Name = 'Assignment of ' +acct.Name+ ' from: ' +oldOwner.Owner.Name+ ' to: ' +newOwner.Owner.Name;
                            newAssignment.Previous_Territory__c = oldOwner.Id; //Old Territory Id  
                        }
                        else{
                            newAssignment.Name = 'Assignment of ' +acct.Name+ ' to: ' +newOwner.Owner.Name;
                            newAssignment.Previous_Territory__c = null;
                        }
                            newAssignment.Account__c = acct.Id;
                            newAssignment.Previous_Owner__c = oldAcct.OwnerId;	
                            newAssignment.New_Owner__c = acct.OwnerId;
                            newAssignment.New_Territory__c = newOwner.Id; //New Territory Id
                            newAssignment.Changed_By__c = UserInfo.getUserId();
                            
                        recordsToCreate.add(newAssignment);
                    }
                }
            }
        }
        insert recordsToCreate;
    }
}