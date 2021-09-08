public class HelperAccountTrigger {

    public static void accountUpdate(List<Account> triggerNew, Map<Id, Account> triggerOldMap){
        
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
                // Utils.randomSalesRep()
                String randomizedRep = Utils.randomSalesRep(salesReps);
                if(randomizedRep != null){
                    acct.OwnerId = randomizedRep;
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
}