public with sharing class Utils {
    
    public static String randomSalesRep(List<String> values) {
        
        Integer randomNumber = Integer.valueof((Math.random() * values.size()));
        String randomizedResult = values[randomNumber]; 

        return randomizedResult;
    }
}
