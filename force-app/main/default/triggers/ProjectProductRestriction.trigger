trigger ProjectProductRestriction on ProjectProduct__c (Before Insert,Before Update) {

If(Trigger.isBefore && Trigger.isInsert){
 projectProductHandler pp = new projectProducthandler(Trigger.new);
 pp.restrictionProduct();
 
}
If(Trigger.isBefore && Trigger.isUpdate){
 projectProductHandler pp = new projectProducthandler(Trigger.new);
 pp.restrictionProduct();
 
}

}