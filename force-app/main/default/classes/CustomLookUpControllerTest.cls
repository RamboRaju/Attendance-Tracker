@isTest
public class CustomLookUpControllerTest {
	@isTest
    public static void fetchLookUpValuesTest(){
        Test.startTest();
           CustomLookUpController.fetchLookUpValues('searchKeyWord', 'Program__c', 'sessionType', 'programRecordId');
           CustomLookUpController.fetchLookUpValues('searchKeyWord', 'Subject__c', 'sessionType', 'programRecordId');
           CustomLookUpController.fetchLookUpValues('searchKeyWord', 'Community__c', 'sessionType', 'programRecordId');
        Test.stopTest();
    }
}