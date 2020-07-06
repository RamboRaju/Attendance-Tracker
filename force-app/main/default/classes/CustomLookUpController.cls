public class CustomLookUpController {
    @AuraEnabled
    public static List < sObject > fetchLookUpValues(String searchKeyWord, String ObjectName, String sessionType, String programRecordId) {
        system.debug('ObjectName-->' + ObjectName);
        system.debug('ObjectName-->' + programRecordId);
        String searchKey = searchKeyWord + '%';
        
        List < sObject > returnList = new List < sObject > ();
      
        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5 
        String sQuery;
        
        if(ObjectName == 'Program__c') {
               sQuery =  'select id, Name,Status__c,Session_Type__c from ' +ObjectName + ' where Status__c = \'Active\' and Session_Type__c INCLUDES(' + '\''+ sessionType + '\'' + ') and Name LIKE: searchKey order by NAME ASC';
        } else if( ObjectName == 'Subject__c') {
               sQuery =  'select id, Name from ' +ObjectName + ' where Status__c = \'Active\' AND Program__c = ' + '\''+programRecordId+ '\'' +' AND Name LIKE: searchKey order by NAME ASC ';//sessionType
        } else {
             sQuery =  'select id, Name from ' +ObjectName + ' where Name LIKE: searchKey order by NAME ASC';//sessionType
        }
		
        System.debug('sQuery '+sQuery);
        List < sObject > lstOfRecords = Database.query(sQuery);
        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
        }
        return returnList;
    }
}