@isTest
private class TestScheduledAccountsOwnerCheck {

    // Dummy CRON expression: midnight on 10/10.
    // Because this is a test, job executes
    // immediately after Test.stopTest().
    public static String CRON_EXP = '0 0 0 10 10 ? 2021';

    @isTest
    static void testScheduledJob() {

        //Data
        // Create Accounts with ZIP Code e List<Territory__c> = []
        List<Territory__c> territoriesList = TestDataFactory.createTerritories(10, false);
        List<Account> accountsList = TestDataFactory.schedulableAccounts(territoriesList);

        List<String> ownersList = Utils.retrieveOwnerIds(territoriesList);
        // List<Account> acctsList = [SELECT Id, Name FROM Account WHERE Name LIKE 'Territory schedulable%'];
        List<String> accountsIdsList = Utils.retrieveAccountsId(accountsList);

        // Run Job
        Test.startTest();
        String jobId = System.schedule('ScheduledApexTest',
            CRON_EXP,
            new ScheduledAccountsOwnerCheck());
        CronTrigger ct = [SELECT Id, CronExpression, CronJobDetailId, CronJobDetail.Name, TimesTriggered, PreviousFireTime, NextFireTime, State
            FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(0, ct.TimesTriggered);
        Test.stopTest();

        // Assert
        System.assert(String.isNotBlank(jobId));
    }
}