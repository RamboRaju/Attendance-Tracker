public class ContactAuraController {
     
    @AuraEnabled
    Public static CustomObjectIcon getIconList(){
        CustomObjectIcon thisCustomObjectIcon = new CustomObjectIcon();
            thisCustomObjectIcon.communityIcon = getIconName('Community__c');
            thisCustomObjectIcon.schoolIcon = getIconName('Institution__c');
            thisCustomObjectIcon.programIcon = getIconName('Program__c');
            thisCustomObjectIcon.programCohortIcon = getIconName('Program_Cohort__c');
            thisCustomObjectIcon.subjectIcon = getIconName('Subject__c');
            thisCustomObjectIcon.theme = UserInfo.getUiThemeDisplayed();
        return thisCustomObjectIcon;
    }
    
    @AuraEnabled  
    public static List<PicklistWrapper> findPicklistOptions(string objAPIName, string fieldAPIname) {
        list<PicklistWrapper> returnValue = new list<PicklistWrapper>();
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.sObjectType objType = schemaMap.get(objAPIName);
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        map < String, Schema.SObjectField > fieldMap = objDescribe.fields.getMap();
        list < Schema.PicklistEntry > values = fieldMap.get(fieldAPIname).getDescribe().getPickListValues();
        // Add these values to the selectoption list.
        for (Schema.PicklistEntry a: values) {
            picklistWrapper aa = new picklistWrapper();
            aa.pickListLabel = a.getLabel();
            aa.pickListValue = a.getValue();
            returnValue.add(aa);
        }
        system.debug('*****returnValue'+returnValue);
        return returnValue;
        
        
    }
    
    @AuraEnabled
    Public static SessionAndContact getSessionAndContact(String communityRecordId, String programsRecordId, String schoolRecordId, String programCohortRecordId) {
        SessionAndContact thisSessionAndContact = new SessionAndContact();

        Program__c thisprogram = new Program__c();
        thisprogram = [select id,Show_Subject_Primary__c,Show_Subject_Secondary__c,Contact_Record_Types_Allowed__c, 
                       Status__c,Name from Program__c where Status__c = 'Active' AND id =:programsRecordId];
        System.debug('thisprogram '+thisprogram);
        List<String> contactRTList = thisprogram.Contact_Record_Types_Allowed__c.split(';');
        Set<String> sStrings = new Set<String>(contactRTList);
                         
        String proName = String.valueOf(thisprogram.Name);
        if(thisprogram.Show_Subject_Primary__c == true) {
            thisSessionAndContact.showPrimarySubject = true;
        }
        
        if(thisprogram.Show_Subject_Secondary__c == true) {
            thisSessionAndContact.showSecondarySubject = true;
        }
        List<Contact> conList = new  List<Contact>();
        if(schoolRecordId <> null && schoolRecordId <> '') {
            conList = [SELECT Id, Name, Account.Name,Nickname__c,Age__c,Gender__c,Community__c,School__c,Name_Age_Gender__c,
                       RecordType.Name,Phone,Program_Cohort__c, Email FROM Contact where 
                       School__c =: schoolRecordId   AND
                       RecordType.Name IN: sStrings order by Name_Age_Gender__c ASC ];
        }
         if(communityRecordId <> null && communityRecordId <> '') {
             if(thisprogram.Name == 'Smile Holidays'){
                 conList = [SELECT Id, Name, Account.Name,Nickname__c,Age__c,Gender__c,Community__c,School__c,Name_Age_Gender__c,
                        RecordType.Name,Phone,Program_Cohort__c, Email FROM Contact where  Community__c =: communityRecordId                       
                        AND Programs__c INCLUDES('Smile Holidays') AND RecordType.Name IN: sStrings order by Name_Age_Gender__c ASC ];
             }else {
                 conList = [SELECT Id, Name, Account.Name,Nickname__c,Age__c,Gender__c,Community__c,School__c,Name_Age_Gender__c,
                        RecordType.Name,Phone,Program_Cohort__c, Email FROM Contact where  Community__c =: communityRecordId                       
                        AND RecordType.Name IN: sStrings order by Name_Age_Gender__c ASC ];
             }      
        }
         if(programCohortRecordId <> null && programCohortRecordId <> '') {
             conList = [SELECT Id, Name, Account.Name,Nickname__c,Age__c,Gender__c,Community__c,School__c,Name_Age_Gender__c,
                        RecordType.Name,Phone,Program_Cohort__c, Email FROM Contact where 
                        Program_Cohort__c =: programCohortRecordId  AND
                        RecordType.Name IN: sStrings order by Name_Age_Gender__c ASC ];       
        }
        
        if(programsRecordId <> null && programsRecordId <> '' && (schoolRecordId == null 
            && communityRecordId == null && programCohortRecordId == null )) {
                if(thisprogram.Name == 'MEP - Not in Community'){
                    conList = [SELECT Id, Name, Account.Name,Nickname__c,Age__c,Gender__c,Community__c,School__c,Name_Age_Gender__c,
                        RecordType.Name,Phone,Program_Cohort__c, Email FROM Contact where 
                        Programs__c INCLUDES('MEP') AND
                        RecordType.Name IN: sStrings order by Name_Age_Gender__c ASC ]; 
                }else {
                   conList = [SELECT Id, Name, Account.Name,Nickname__c,Age__c,Gender__c,Community__c,School__c,Name_Age_Gender__c,
                        RecordType.Name,Phone,Program_Cohort__c, Email FROM Contact where 
                        Programs__c INCLUDES(:proName) AND
                        RecordType.Name IN: sStrings order by Name_Age_Gender__c ASC ]; 
                }
        }
		
        List<ContactWrapper> contactWrapperList = new List<ContactWrapper>(); 
		for(Contact con1 : conList){
            ContactWrapper thisContactWrapper = new  ContactWrapper();
            thisContactWrapper.selected = false;
            thisContactWrapper.con = con1;
            contactWrapperList.add(thisContactWrapper);
        }
        System.debug('conList '+contactWrapperList);
        thisSessionAndContact.conlist = contactWrapperList;
        thisSessionAndContact.staffList = findPicklistOptions('Session__c', 'Staff__c');
        System.debug('thisSessionAndContact '+thisSessionAndContact);
        return thisSessionAndContact;
    }
    
    @AuraEnabled
    public static String createParticipation(String sessionConatct){
        SessionAndContact theSessionAndContact = (SessionAndContact)JSON.deserialize(sessionConatct, SessionAndContact.class);
        
        System.debug('theSessionAndContact '+theSessionAndContact);
        Session__c  thisSession = new Session__c();
        thisSession.Program__c = theSessionAndContact.programId;
        thisSession.Community__c = theSessionAndContact.communityId;
        thisSession.School__c = theSessionAndContact.schoolId;
        thisSession.Date__c = theSessionAndContact.sessionDate;
        thisSession.Staff__c = theSessionAndContact.staff;
        thisSession.Submitted_By_Other__c = theSessionAndContact.submittedByOther;
        thisSession.Parents__c = theSessionAndContact.parents;
        thisSession.Comments__c = theSessionAndContact.comments;
        thisSession.Primary_Subject__c = theSessionAndContact.primarySubject;	 
        thisSession.Secondary_Subject__c = theSessionAndContact.secondarySubject;
        thisSession.Program_Cohort__c = theSessionAndContact.programCohortId;
        try{
            insert thisSession;
        }catch(Exception e){
            System.Debug('thisSession '+e);
        }
        
        
        System.debug('thisSession '+thisSession);
        
        List<Participation__c> participationList = new List<Participation__c>();
        for(ContactWrapper wrap : theSessionAndContact.conlist) {
            Participation__c thisParticipation = new Participation__c();
            if(wrap.selected == true){
                thisParticipation.Contact__c = wrap.con.id;
                thisParticipation.Session__c = thisSession.id;
                thisParticipation.Status__c = 'Attended';
                participationList.add(thisParticipation);
            }
            
        }
        
       System.debug('participationList '+participationList);  
        if(participationList.size() > 0){
            try{
               insert participationList; 
            }catch(Exception e){
                System.debug('participationList '+e);
            }
            
        }
        
        return thisSession.id;
    }
    
    public static String getIconName(String sObjectName) {
        
        String u;
        List<Schema.DescribeTabSetResult> tabSetDesc = Schema.describeTabs();
        List<Schema.DescribeTabResult> tabDesc = new List<Schema.DescribeTabResult>();
        List<Schema.DescribeIconResult> iconDesc = new List<Schema.DescribeIconResult>();

        for(Schema.DescribeTabSetResult tsr : tabSetDesc) { tabDesc.addAll(tsr.getTabs()); }

        for(Schema.DescribeTabResult tr : tabDesc) {
            if( sObjectName == tr.getSobjectName() ) {
                if( tr.isCustom() == true ) {
                    iconDesc.addAll(tr.getIcons());
                } else {
                    u = 'standard:' + sObjectName.toLowerCase();
                }
            }
        }
        for (Schema.DescribeIconResult ir : iconDesc) {
            if (ir.getContentType() == 'image/svg+xml'){
                u = 'custom:' + ir.getUrl().substringBetween('custom/','.svg').substringBefore('_');
                break;
            }
        }
        
        if(u == '' || u == null) {
            return 'standard:account';
        } else {
            return u;
        }
        
    }
    
    public class SessionAndContact {
        @AuraEnabled public Date sessionDate;
        @AuraEnabled public String staff;
        @AuraEnabled public String submittedByOther;
        @AuraEnabled public String comments;
        @AuraEnabled public Integer parents;
        @AuraEnabled public String primarySubject;
        @AuraEnabled public String secondarySubject;
        @AuraEnabled public Boolean showPrimarySubject;
        @AuraEnabled public Boolean showSecondarySubject;
        @AuraEnabled public String programId;
        @AuraEnabled public String communityId;
        @AuraEnabled public String schoolId;
        @AuraEnabled public String programCohortId;
        @AuraEnabled public List<ContactWrapper> conlist;
        @AuraEnabled public List<PicklistWrapper> staffList;
    }
    
    public class CustomObjectIcon {
        @AuraEnabled public String communityIcon;
        @AuraEnabled public String schoolIcon;
        @AuraEnabled public String programIcon;
        @AuraEnabled public String programCohortIcon;
        @AuraEnabled public String subjectIcon;
        @AuraEnabled public String theme;
    }
    
    public class ContactWrapper {
         @AuraEnabled 
         public boolean selected;
         @AuraEnabled 
         public Contact con;
    }
    
    public class PicklistWrapper{
        @AuraEnabled 
        public string pickListLabel;
        @AuraEnabled 
        public string pickListValue;
        
    }    
}