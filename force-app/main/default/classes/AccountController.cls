public with sharing class AccountController {

    @AuraEnabled
    public static void sendEmail(String acctId, String oldOwnerId, String newOwnerId){

        List<String> ownersList = new List<String>{oldOwnerId, newOwnerId};
        List<String> ownersEmailsList = new List<String>();

        for(User user : [SELECT Email FROM User WHERE Id IN :ownersList WITH SECURITY_ENFORCED]){
            ownersEmailsList.add(user.Email);
        } 

        List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail =  new Messaging.SingleEmailMessage();

        EmailTemplate emailTemplate = [SELECT Id, Subject, Description, HtmlValue, DeveloperName, Body FROM EmailTemplate WHERE Name = 'VF Billing Postal Code Change' WITH SECURITY_ENFORCED];

        mail.setTemplateId(emailTemplate.Id);
        mail.setTargetObjectId(newOwnerId); 
        mail.setToAddresses(ownersEmailsList);

        mail.setWhatId(acctId);
        mail.setBccSender(false); 
        mail.setUseSignature(false); 
        mail.setSenderDisplayName('Admin'); 
        mail.setSaveAsActivity(false); 
        mail.setReplyTo('no-reply@company.com');

        mails.add(mail);
        Messaging.sendEmail(mails);
    }
}