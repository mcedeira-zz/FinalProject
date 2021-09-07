public class HelperAccountTrigger {

    public static void accountUpdate(List<Account> triggerNew, Map<Id, Account> triggerOldMap){
        
        //Data
        Map<String, Territory__c> salesRep = new Map<String, Territory__c>();
        for(Territory__c t : [SELECT Name, Owner__c FROM Territory__c WITH SECURITY_ENFORCED]){
            salesRep.put(t.Name, t);
        }

        //Actual logic
        for(Account acct : triggerNew){
            Account oldAcct = triggerOldMap.get(acct.Id);
            if(acct.BillingPostalCode != oldAcct.BillingPostalCode){
                    Territory__c owner = salesRep.get(acct.BillingPostalCode);
                    if(owner != null){
                        acct.OwnerId = owner.Owner__c;
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