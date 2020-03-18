<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Email_Opt_In</fullName>
        <field>Email_Opt_In__c</field>
        <name>Email Opt In</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Email_Opt_In_for_hr</fullName>
        <field>Email_Opt_In__c</field>
        <name>Email Opt In for ! hr</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Lead_Record_Type_to_Cargil_Lea</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Cargill_Lead</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Update Lead Record Type to Cargil Lea</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Lead_Record_Type_to_Qualfied_Lead</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Qualified_Lead</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Update Lead Record Type to Qualfied Lead</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Change Record Type for Qualified Leads</fullName>
        <actions>
            <name>Update_Lead_Record_Type_to_Qualfied_Lead</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.Status</field>
            <operation>equals</operation>
            <value>Qualified</value>
        </criteriaItems>
        <description>Change the Record Type to Qualified Lead to enable the CONVERT Button on the Page Layout.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
