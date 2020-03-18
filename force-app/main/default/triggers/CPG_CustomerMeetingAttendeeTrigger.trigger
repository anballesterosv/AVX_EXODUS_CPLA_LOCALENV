trigger CPG_CustomerMeetingAttendeeTrigger on Customer_Meeting_Attendee__c (After insert, After Delete) {
    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isDelete)){
        set<id> setCMR = new set<id>();
        list<Customer_Meeting_Attendee__c> lstAttendees = new list<Customer_Meeting_Attendee__c>();
        if(Trigger.isInsert){
            lstAttendees = Trigger.New;
        }
        else if (Trigger.isDelete){
            lstAttendees = Trigger.Old;
        }
        for(Customer_Meeting_Attendee__c att:lstAttendees){
            setCMR.add(att.customer_meeting_report__c);
        }
        map<id, string> mapAttendees = new map<id, string>();
        if(!setCMR.isEmpty()){
            for(Customer_Meeting_Attendee__c att:[select cargill_attendee__r.Name, customer_meeting_report__c from Customer_Meeting_Attendee__c where customer_meeting_report__c in :setCMR]){
                if(mapAttendees.isEmpty() || !mapAttendees.containsKey(att.customer_meeting_report__c)){
                    string temp = att.cargill_attendee__r.Name;
                    mapAttendees.put(att.customer_meeting_report__c, temp);
                 }        
                 else {
                     string temp = mapAttendees.get(att.customer_meeting_report__c)+', '+att.cargill_attendee__r.Name;
                     mapAttendees.put(att.customer_meeting_report__c, temp);   
                 }
            }
            list<Customermeetingreport__c> lstCMR = new list<Customermeetingreport__c>();
            for(id idCMR :setCMR){
                customermeetingreport__c iCMR = new customermeetingreport__c (id=idCMR, cargill_attendees__c='');
                if(!mapAttendees.isEmpty() && mapAttendees.containsKey(idCMR)){
                    iCMR.cargill_attendees__c= mapAttendees.get(idCMR);
                }    
                lstCMR.add(iCMR);
            }
            if(!lstCMR .isEmpty()){
                update lstCMR ;
            }
        }
    }
}