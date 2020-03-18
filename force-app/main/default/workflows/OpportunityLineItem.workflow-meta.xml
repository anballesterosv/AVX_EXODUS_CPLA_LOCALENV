<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Default_Price_Guidance_Floor_Price</fullName>
        <field>PricingGuildanceFloorPrice__c</field>
        <formula>PricebookEntry.PricingGuidanceFloorPrice__c</formula>
        <name>Default Price Guidance Floor Price</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Default_Price_Guidance_Start_Price</fullName>
        <field>PricingGuidanceStartPrice__c</field>
        <formula>PricebookEntry.PricingGuidanceStartPrice__c</formula>
        <name>Default Price Guidance Start Price</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Default_Price_Guidance_Target_Price</fullName>
        <field>PricingGuidanceTargetPrice__c</field>
        <formula>PricebookEntry.PricingGuidanceTargetPrice__c</formula>
        <name>Default Price Guidance Target Price</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Default PriceGuidance from Pricebook Entry</fullName>
        <actions>
            <name>Default_Price_Guidance_Floor_Price</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Default_Price_Guidance_Start_Price</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Default_Price_Guidance_Target_Price</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Default the Price Guidance fields (Start, Target, Flloor)</description>
        <formula>TRUE</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Port Unit of Measure from Product</fullName>
        <active>true</active>
        <description>Port the Unit of Measure from the Product object thru the Pricebook Entry onto the Opportunity Product Multi-Line Edit Layout.</description>
        <formula>TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
