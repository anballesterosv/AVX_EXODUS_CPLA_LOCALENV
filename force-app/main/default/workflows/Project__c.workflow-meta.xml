<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Copy_Estimated_Margin_to_Actual</fullName>
        <field>AnnualMarginActual__c</field>
        <formula>AnnualMarginEstimated__c</formula>
        <name>Copy Estimated Margin to Actual</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Copy_Estimated_Volume_to_Actual</fullName>
        <field>AnnualVolumeActual__c</field>
        <formula>AnnualVolumeEstimated__c</formula>
        <name>Copy Estimated Volume to Actual</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Project_Phase</fullName>
        <field>Phase__c</field>
        <literalValue>Develop</literalValue>
        <name>Project Phase</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Cancelled_Date</fullName>
        <description>This will update Cancelled Date when Stage is &quot;Cancelled&quot;</description>
        <field>Cancelled_Date__c</field>
        <formula>IF( ISPICKVAL( Stage__c , &quot;Cancelled&quot;)&amp;&amp; ISBLANK(Cancelled_Date__c), Today(),  Cancelled_Date__c)</formula>
        <name>Update Cancelled Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Commercialization_Date1</fullName>
        <description>Commericalization Date 1 = Opportunity Start Date when Project Phase = &quot;Measure&quot;</description>
        <field>Commercialization_Date_at_Measure__c</field>
        <formula>IF(ISPICKVAL( Phase__c , &quot;Measure&quot;)&amp;&amp; ISBLANK(Commercialization_Date_at_Measure__c), TODAY() , Commercialization_Date_at_Measure__c )</formula>
        <name>Update Commercialization Date 1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Commercialization_Date_Implement</fullName>
        <field>Commercialization_Date_at_Implement__c</field>
        <formula>IF(ISPICKVAL( Phase__c , &quot;Implement&quot;)&amp;&amp; ISBLANK(Commercialization_Date_at_Implement__c), TODAY() , Commercialization_Date_at_Implement__c )</formula>
        <name>Update Commercialization Date Implement</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Commericalization_Date_at_Closed</fullName>
        <field>Commercialization_Date_at_Closed_Won__c</field>
        <formula>IF(ISPICKVAL( Opportunity__r.StageName , &quot;Closed Won&quot;)&amp;&amp; ISBLANK(Commercialization_Date_at_Closed_Won__c ), TODAY() , Commercialization_Date_at_Closed_Won__c )</formula>
        <name>Update Commericalization Date at Closed-</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Develop_Date</fullName>
        <description>This is will update Develop Date to Today when Stage is &quot;Go&quot;</description>
        <field>DevelopDate__c</field>
        <formula>IF( ISPICKVAL( Stage__c , &quot;Go&quot;)&amp;&amp; ISBLANK(DevelopDate__c), Today(),  DevelopDate__c)</formula>
        <name>Update Develop Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Measure_Date</fullName>
        <description>This is will update Measure Date to Today when Phase is Measure</description>
        <field>MeasureDate__c</field>
        <formula>IF( ISPICKVAL(  Phase__c  , &quot;Measure&quot;)&amp;&amp; ISBLANK(MeasureDate__c), Today(),  MeasureDate__c )</formula>
        <name>Update Measure Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_On_Hold_Date</fullName>
        <description>This will update On Hold Date to Today when Stage is &quot;On Hold&quot;</description>
        <field>On_Hold_Date__c</field>
        <formula>IF( ISPICKVAL( Stage__c , &quot;On Hold&quot;)&amp;&amp; ISBLANK(On_Hold_Date__c ), Today(),  On_Hold_Date__c )</formula>
        <name>Update On Hold Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Opportunity_stage</fullName>
        <field>opportunity_Stage1__c</field>
        <formula>TEXT(Opportunity__r.StageName)</formula>
        <name>Update Opportunity stage</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Phase_to_Explore</fullName>
        <description>After rejection, reset phase value to Explore</description>
        <field>Phase__c</field>
        <literalValue>Explore</literalValue>
        <name>Update Phase to Explore</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Record_Type_to_Approved</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Project_Approved</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Update Record Type to Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Stage_To_Go</fullName>
        <description>Update Stage value to &quot;Go&quot;</description>
        <field>Stage__c</field>
        <literalValue>Go</literalValue>
        <name>Update Stage To Go</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Stage_To_SubmittedForApproal</fullName>
        <description>Update stage value to &quot;Submit for Approal&quot;</description>
        <field>Stage__c</field>
        <literalValue>Submitted for Approval</literalValue>
        <name>Update_Stage_To_SubmittedForApproal</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Stage_to_Rejected</fullName>
        <description>Update the Stage to Rejected after approval rejection</description>
        <field>Stage__c</field>
        <literalValue>Rejected</literalValue>
        <name>Update Stage to Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_isApproved</fullName>
        <field>isApproved__c</field>
        <literalValue>1</literalValue>
        <name>Update isApproved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Updating_Activity_Date</fullName>
        <description>This is will update Activity Date to Today when Phase is Implement or Phase</description>
        <field>ActivityDate__c</field>
        <formula>IF(ISPICKVAL(Stage__c ,&quot;GO&quot;) &amp;&amp; ISBLANK(ActivityDate__c), TODAY(), ActivityDate__c )</formula>
        <name>Updating Activity Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Updating_Implement_Date</fullName>
        <description>This will update Implement Date to Today when Phase is Implement</description>
        <field>ImplementDate__c</field>
        <formula>IF( ISPICKVAL( Phase__c , &quot;Implement&quot;)&amp;&amp; ISBLANK(ImplementDate__c), Today(), ImplementDate__c )</formula>
        <name>Updating Implement Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Capturing the lifecycle of the Project</fullName>
        <actions>
            <name>Update_Cancelled_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Commercialization_Date1</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Commercialization_Date_Implement</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Commericalization_Date_at_Closed</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Develop_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Measure_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_On_Hold_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Updating_Activity_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Updating_Implement_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 OR 2 OR 3</booleanFilter>
        <criteriaItems>
            <field>Project__c.Phase__c</field>
            <operation>equals</operation>
            <value>Measure,Implement</value>
        </criteriaItems>
        <criteriaItems>
            <field>Project__c.Stage__c</field>
            <operation>equals</operation>
            <value>Go,On Hold,Cancelled</value>
        </criteriaItems>
        <criteriaItems>
            <field>Project__c.Opportunity_Stage__c</field>
            <operation>equals</operation>
            <value>Closed Won</value>
        </criteriaItems>
        <description>This will update and capture activity date, implement date, Measure Date, Develop Date, and commercialization date throughout the lifecycle of the Project.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update opportunity stage</fullName>
        <actions>
            <name>Update_Opportunity_stage</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update the Date Commercialized when Phase updates</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Project__c.Phase__c</field>
            <operation>equals</operation>
            <value>Measure</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
