/**
**************************************************************************************************************
* @company          Avanxo Brasil
* @author           Igor Novaes href=<igor.novaes@globant.com>
* @project          EXODUS - CPLA Cargill
* @name             AVX_DataGenerator_cls
* @description      Data Generator Class for Test Classes
* @dependencies     none
* @changes (Version)
* --------   ---   ----------   ---------------------------   ------------------------------------------------
*            No.   Date         Author                        Description
* --------   ---   ----------   ---------------------------   ------------------------------------------------
* @version   1.0   2020-02-17   Igor Novaes.                  Initial version.
**************************************************************************************************************/


public class AVX_DataGenerator_cls {
    
    //Create Custom Settings
    public static Integration_profile__c createCustomSettings (Boolean IsActive){
       Profile objProfile = [SELECT Id FROM Profile WHERE Id =: Userinfo.getProfileId()]; 
       Integration_profile__c csobj = new Integration_profile__c (
           SkipValidationProfiles__c = IsActive           
       );
       return csobj;
    }
    
    //Create User record
    public static User createUser(String name){
        Profile objProfile = [SELECT Id FROM Profile WHERE Id =: Userinfo.getProfileId()]; 

        User objUser = new User(
            ProfileId = objProfile.Id,
            FirstName = name,
            LastName = 'Last',
            Email = 'puser000@amamama.com',
            Username = 'puser000@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'Globant',
            Alias = 'TestUser',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        return objUser;
    }

    //Create Contact record
    public static Contact createContact(String lastName, Account account, String email){
        Contact objContact = new Contact(
            LastName = lastName,
            AccountId = account.Id,
            Email = email
        );
        return objContact;
    }

    //Create Ship To Contact Relation record - Junction between Ship To and Contact
    public static CS_Ship_To_Contact_Relation__c createShipToContactRelation(Contact contact, Ship_To__c shipTo, Boolean primary){
        CS_Ship_To_Contact_Relation__c objShipToContact = new CS_Ship_To_Contact_Relation__c(
            CS_Contact__c = contact.Id,
            CS_Ship_To__c = shipTo.Id,
            PrimaryContact__c = primary
        );
        return objShipToContact;
    }


    //Accounts hierarchy:  Global > Commercial > Payer
	//Create Global Account record
    public static Account createGlobalAccount(String name){
        Account objAccount = new Account(   
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('GlobalAccount').getRecordTypeId(),
            Name = name,
            Market_Channel__c = 'Food Service',
            Status__c = 'Active',
            BillingCity = 'São Paulo',
            BillingCountry = 'Brazil',       
            BillingPostalCode = '01539010',
            BillingState = 'São Paulo',
            BillingStreet = 'Av. Dr. Chucri Zaidan',
            ShippingCity = 'Riberâo Pirés',
            ShippingCountry = 'Brazil',        
            ShippingPostalCode = '09440190',
            ShippingState = 'São Paulo',
            ShippingStreet = 'Dos eucaliptos'
        );
        return objAccount;
    }

    //Create Commercial Account record
    public static Account createCommercialAccount(String name, Account parent){
        Account objAccount = new Account(   
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CommercialAccount').getRecordTypeId(),
            Name = name,
            ParentId = parent.Id,
            Market_Channel__c = 'Food Service',
            Status__c = 'Active',
            BillingCity = 'São Paulo',
            BillingCountry = 'Brazil',       
            BillingPostalCode = '01539010',
            BillingState = 'São Paulo',
            BillingStreet = 'Av. Dr. Chucri Zaidan',
            ShippingCity = 'Riberâo Pirés',
            ShippingCountry = 'Brazil',        
            ShippingPostalCode = '09440190',
            ShippingState = 'São Paulo',
            ShippingStreet = 'Dos eucaliptos'
        );
        return objAccount;
    }

    //Create Payer Account record
    public static Account createPayerAccount(String name, Account parent){
        Account objAccount = new Account(   
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Payer').getRecordTypeId(),
            Name = name,
            ParentId = parent.Id,
            Market_Channel__c = 'Food Service',
            Status__c = 'Active',
            BillingCity = 'São Paulo',
            BillingCountry = 'Brazil',       
            BillingPostalCode = '01539010',
            BillingState = 'São Paulo',
            BillingStreet = 'Av. Dr. Chucri Zaidan',
            ShippingCity = 'Riberâo Pirés',
            ShippingCountry = 'Brazil',        
            ShippingPostalCode = '09440190',
            ShippingState = 'São Paulo',
            ShippingStreet = 'Dos eucaliptos'
        );
        return objAccount;
    }

    //Create Product record
    public static Product2 createProduct(String name){
        Product2 objProduct = new Product2(
            Name = name,
            IsActive = true,
            Family = 'PRODUCTS DE POLLO',
            Family2__c = 'FORMADOS/PREFORMADOS',
            ProductCode = '123499',
            Brand__c = 'DELICIA',
            DEFAULT_PRICING_UOM__c = 'Bolsa (Bolsa)',
            Default_UOM__c = 'Bolsa (Bolsa)',
            StorageCode__c = '30',
            GrossWeight__c = 5.1,
            NetWeight__c = 5,
            Business__c = '	Food Service',
            MaterialType__c = 'ZMAT',
            Taxed__c = true,
            DurationConservation__c = 365,
            Description = 'It is a pollo',
            LEGACY_SYSTEM__c = 'SAP',
            GROUP_CODE__c = 'ZMCA'
        );
        return objProduct;
    }

    //Create Pricebook record
    public static Pricebook2 createPricebook(String name, Product2 product){
        Id pricebookId = Test.getStandardPricebookId();
        // PricebookEntry standardPrice = new PricebookEntry(
        //     Pricebook2Id = pricebookId, 
        //     Product2Id = product.Id,
        //     UnitPrice = 10000, 
        //     IsActive = true
        // );
        // insert standardPrice;

        Pricebook2 objPricebook2 = new Pricebook2(
            Name = name,
            Description = 'It is a pollo price book',
            IsActive = true
            
        );
        return objPricebook2;
    }

    //Create PricebookEntry record
    public static PricebookEntry createPricebookEntry(Pricebook2 pricebook, Product2 product){
        PricebookEntry objPricebookEntry = new PricebookEntry(
            Pricebook2Id = pricebook.id,
            Product2Id = product.id,
            UnitPrice = 5000, 
            IsActive = true
        ); 
        return objPricebookEntry;
    }
    
    //Create TeleSales Plan record
    public static TelesalesPlan__c createTeleSalesPlanContingency(User telemarketer, User supervisor){
        TelesalesPlan__c objTeleSalesPlan = new TelesalesPlan__c(
            RecordTypeid = Schema.SObjectType.TelesalesPlan__c.getRecordTypeInfosByDeveloperName().get('ContingencyPlan').getRecordTypeId(),
            Supervisor__c = supervisor.Id,
            Telemarketer__c = telemarketer.Id,
            StartDate__c = Date.today(),
            EndDate__c = Date.today() + 5,
            Description__c = 'Pollo TeleSalesPlan Contingency'
        );
        return objTeleSalesPlan;
    }

    //Create Telesales Plan Work Plan record
    public static TelesalesPlan__c createTeleSalesPlan(User telemarketer, User supervisor){
        TelesalesPlan__c objTeleSalesPlan = new TelesalesPlan__c(
            RecordTypeId = Schema.SObjectType.TelesalesPlan__c.getRecordTypeInfosByDeveloperName().get('WorkPlan').getRecordTypeId(),
            Supervisor__c = supervisor.Id,
            Telemarketer__c = telemarketer.Id,
            StartDate__c = Date.today(),
            EndDate__c = Date.today() + 5,
            Description__c = 'Pollo TeleSalesPlan'
        );
        return objTeleSalesPlan;
    }

    //Create TelesalesPlan Contingency Plan record
    public static TelesalesPlan__c createContingencyPlan(TelesalesPlan__c workPlan){
        TelesalesPlan__c objTeleSalesPlan = new TelesalesPlan__c(
            RecordTypeId =  Schema.SObjectType.TelesalesPlan__c.getRecordTypeInfosByDeveloperName().get('ContingencyPlan').getRecordTypeId(),
            Reason__c = 'Holidays',
            StartDate__c = Date.today(),
            EndDate__c = Date.today() + 5,
            Description__c = 'MegaPollo ',
            TelesalesWorkPlan__c = workPlan.Id
        );
        return objTeleSalesPlan;
    }
    
    //Create TeleSalesPlan Detail record
    public static TelesalesPlanDetail__c createTeleSalesPlanDetail(TelesalesPlan__c telesalesPlan, Account commercial, Ship_To__c shipTo){
        Time currentTime = Datetime.now().time();
        DateTime dt = DateTime.now();
        String dayOfWeekNow = dt.format('u');

        TelesalesPlanDetail__c objTeleSalesPlanDetail = new TelesalesPlanDetail__c(
            TelesalesPlan__c = telesalesPlan.Id,
            CommercialAccount__c = commercial.Id,
            Ship_To__c = shipTo.Id,
            DayOfTheWeek__c = dayOfWeekNow,
            Hours__c = currentTime + 5000,
            Priority__c = 'Medium'
        );
        return objTeleSalesPlanDetail;
    }

    //Create Bill To record (not completed)
    public static Bill_To__c createBillTo(String name, Account payer, Account commercial){
        Bill_To__c objBillTo = new Bill_To__c(
            Name = name,
            Payer__c = payer.Id,
            Commercial_Account__c = commercial.Id
        );
        return objBillTo;
    }

    //Create Ship To record
    public static Ship_To__c createShipTo(String name, Account payer, Bill_To__c billTo){
        Ship_To__c objShipTo = new Ship_To__c(
            Name = name,
            Payer__c = payer.Id,
            Sold_To__c = billTo.Id
        );
        return objShipTo;
    }

    //create Task
    public static Task createTask(Ship_To__c shipTo){
        Task objTask = new Task(
        ShipTo__c  = shipTo.Id
        );
        return objTask;
    }
    
    //Create Credit Limit record
    public static CreditLimit__c createCreditLimit(Account account){
        CreditLimit__c objCreditLimit = new CreditLimit__c(
            CommercialAccount__c = account.Id,
            DueDate__c = Date.today() + 7,
            LimitUsed__c = 5000.50,
            IsActive__c = true
        );
        return objCreditLimit;
    }

    //Create Task record
    public static Task createTask(String subject, User assignedTo){
        Task objTask = new Task(
            Subject = subject,
            OwnerId = assignedTo.Id,
            Priority = 'Medium',
            Status = 'Open'
        );
        return objTask;
    }
   
    public static Task createTaskOpen(String subject, User assignedTo, Date yesterday,String type, String status){
        Time myTime = Time.newInstance(23, 0,0, 0);
        Task objTask = new Task(
            Subject = subject,
            OwnerId = assignedTo.Id,
            Priority = 'Medium',
            Status = status,
            TypeTask__c = type,
            ActivityDate = yesterday,
            TimeToCall__c = myTime

        );
        return objTask;
    }
}