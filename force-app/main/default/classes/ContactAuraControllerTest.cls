@isTest
public class ContactAuraControllerTest {
	@isTest
    public static void getIconListTest(){
        Test.startTest();
           ContactAuraController.getIconList();
        Test.stopTest();
    }
    
    @isTest
    public static void findPicklistOptionsTest(){
        Test.startTest();
           ContactAuraController.findPicklistOptions('Session__c', 'Staff1__c');
        Test.stopTest();
    }
    
    @isTest
    public static void getSessionAndContactTest(){
        Program__c thisProgram = new Program__c();
        thisProgram.Name = 'Test program';
        thisProgram.Status__c = 'Active';
        thisProgram.Session_Type__c = 'Community;Programs;Institution;Program Cohort';
        thisProgram.Show_Subject_Primary__c = true;
        thisProgram.Show_Subject_Secondary__c = true;
        thisProgram.Contact_Record_Types_Allowed__c = 'Beneficiary;Adult';
        insert thisProgram;
        
        Community__c thisCommunity = new Community__c();
		thisCommunity.Name = 'Test thisCommunity';
		thisCommunity.Active__c = true;
        insert thisCommunity;
        
        Program__c thisProgram1 = new Program__c();
        thisProgram1.Name = 'Smile Holidays';
        thisProgram1.Status__c = 'Active';
        thisProgram1.Session_Type__c = 'Community;Programs;Institution;Program Cohort';
        thisProgram1.Show_Subject_Primary__c = true;
        thisProgram1.Show_Subject_Secondary__c = true;
        thisProgram1.Contact_Record_Types_Allowed__c = 'Beneficiary;Adult';
        insert thisProgram1;
        
        Id contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Beneficiary').getRecordTypeId();
        Contact thisContact = new Contact();
        thisContact.LastName = 'TestContact';
        thisContact.Community__c = thisCommunity.Id;
        thisContact.RecordTypeId = contactRecordTypeId;
        thisContact.Programs__c = 'Smile Holidays;Blueprints';
        insert thisContact;
        
        Test.startTest();
           ContactAuraController.getSessionAndContact('communityRecordId', thisProgram.Id, 'schoolRecordId', 'programCohortRecordId');
           ContactAuraController.getSessionAndContact(null, thisProgram.Id, null, null);
           ContactAuraController.getSessionAndContact(thisCommunity.Id, thisProgram1.Id, '', '');

        Test.stopTest();
    }
    
    @isTest
    public static void createParticipationTest(){
        
        Community__c thisCommunity = new Community__c();
		thisCommunity.Name = 'Test thisCommunity';
		thisCommunity.Active__c = true;
        insert thisCommunity;
        
        Program__c thisProgram1 = new Program__c();
        thisProgram1.Name = 'Smile Holidays';
        thisProgram1.Status__c = 'Active';
        thisProgram1.Session_Type__c = 'Community;Programs;Institution;Program Cohort';
        thisProgram1.Show_Subject_Primary__c = true;
        thisProgram1.Show_Subject_Secondary__c = true;
        thisProgram1.Contact_Record_Types_Allowed__c = 'Beneficiary;Adult';
        insert thisProgram1;
        
        Id contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Beneficiary').getRecordTypeId();
        Contact thisContact = new Contact();
        thisContact.LastName = 'TestContact';
        thisContact.Community__c = thisCommunity.Id;
        thisContact.RecordTypeId = contactRecordTypeId;
        thisContact.Programs__c = 'Smile Holidays;Blueprints';
        insert thisContact;
        
        ContactAuraController.ContactWrapper thisContactWrapper = new ContactAuraController.ContactWrapper();
        thisContactWrapper.selected = true;
        thisContactWrapper.con = thisContact;
        
        List<ContactAuraController.ContactWrapper> contactList = new List<ContactAuraController.ContactWrapper>();
        contactList.add(thisContactWrapper);
        
        ContactAuraController.SessionAndContact thisSessionAndContact = new ContactAuraController.SessionAndContact();
        thisSessionAndContact.sessionDate = Date.today();
        thisSessionAndContact.staff = 'Tim';
        thisSessionAndContact.submittedByOther = 'Andrea';
        thisSessionAndContact.comments = 'Hello';
        thisSessionAndContact.parents = 2;
        thisSessionAndContact.programId = thisProgram1.id;
        thisSessionAndContact.communityId = thisCommunity.id;
        thisSessionAndContact.conlist = contactList;
        String sessionConatct = JSON.serialize(thisSessionAndContact);
        Test.startTest();
        	ContactAuraController.createParticipation(sessionConatct);
        Test.stopTest();
    }
}