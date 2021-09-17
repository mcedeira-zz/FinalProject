global class ScheduledAccountsOwnerCheck implements Schedulable{
    
    global void execute(SchedulableContext SC) {

        AccountProperOwnerCheck.check();
    }
}
