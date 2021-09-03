trigger AccountTrigger on Account (before insert, before update) {

    if(Trigger.isBefore){
        if(Trigger.isInsert){
            
        }
        if(Trigger.isUpdate){
            
        }    
    }
}