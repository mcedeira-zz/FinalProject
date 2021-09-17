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

    public static void sendEmail(String OwnerId, String acctId){

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
        EmailTemplate emailTemplate = [SELECT Id, Subject, Description, HtmlValue, DeveloperName, Body FROM EmailTemplate WHERE Name = 'VF Billing Postal Code Change' WITH SECURITY_ENFORCED];

        User usr = [SELECT Id, Email FROM User WHERE Id = :OwnerId WITH SECURITY_ENFORCED];        
        List<String> address = new String[] {usr.Email};

        mail.setTemplateId(emailTemplate.Id);
        mail.setTargetObjectId(OwnerId); 

        mail.setWhatId(acctId);
        mail.setBccSender(false); 
        mail.setUseSignature(false); 
        mail.setSenderDisplayName('MatiaS'); 
        mail.setSaveAsActivity(false); 
        mail.setReplyTo('no-reply@company.com');

        Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

        if (results[0].success){
            System.debug('The email was sent successfully.');
        } 
        else {
            System.debug('The email failed to send: ' +results[0].errors[0].message);
        }
    }
}