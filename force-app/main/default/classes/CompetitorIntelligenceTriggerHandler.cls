/*
*    @descrciption:    Trigger Handler for Competitive Intelligence object.
*    @author:          Sharee Mae Ingatan (sharee.mae.r.ingatan@accenture.com)
*    @createddate:     April 12, 2016
*/
public class CompetitorIntelligenceTriggerHandler {

    /*
    *    @descrciption:    Autopost to Chatter for every record created on the Competitive Intelligence object
    *    @author:          Sharee Mae Ingatan (sharee.mae.r.ingatan@accenture.com)
    *    @createddate:     April 12, 2016
    */
    public static void autoCreateChatterPost(List<Competitor_Intelligence__c> competitorIntelligenceList) {
        //get the group ids to mention from the custom setting
        Map<Id, String> mapGroupSetting = new Map<Id, String>();
        for(ChatterPostGroupMention__c chatterGroupSetting : [SELECT Id, Name, Group_Id__c, Competitive_Intelligence_Type__c FROM ChatterPostGroupMention__c]) {
            mapGroupSetting.put(chatterGroupSetting.Group_Id__c, chatterGroupSetting.Competitive_Intelligence_Type__c);
        }
    
        //get the competitor info
        Set<Id> competitorIds = new Set<Id>();
        Map<Id, String> mapCompetitor = new Map<Id, String>();
        for(Competitor_Intelligence__c competitorIntelligence : competitorIntelligenceList) {
            competitorIds.add(competitorIntelligence.Competitor__c);
        }
        for(Account competitor : [SELECT Id, Name FROM Account WHERE Id IN :competitorIds]) {
            mapCompetitor.put(competitor.Id, competitor.Name);
        }
        
        if(mapGroupSetting.size() > 0) {
            for(Competitor_Intelligence__c competitorIntelligence : competitorIntelligenceList) {
                mentionTextPost(mapGroupSetting, mapCompetitor.get(competitorIntelligence.Competitor__c), UserInfo.getName(), competitorIntelligence.Id, competitorIntelligence.Name, competitorIntelligence.Type__c);
            }
        }
    }
    
    // make a simple chatter text post to the specified user from the running user 
    public static void mentionTextPost(Map<Id, String> mapGroupsToMention, String competitorName, String currentUserName, Id competitorIntelligenceId, String competitorIntelligenceName, String competitorIntelligenceType) {

        ConnectApi.MessageBodyInput messageInput = new ConnectApi.MessageBodyInput();
        messageInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
        
        // add the mention/s
        Boolean toPost = false;
        for(ChatterPostGroupMention__c chatterGroupSetting : [SELECT Id, Name, Group_Id__c, Competitive_Intelligence_Type__c FROM ChatterPostGroupMention__c WHERE Group_Id__c IN :mapGroupsToMention.keySet()]) {
            if(chatterGroupSetting.Competitive_Intelligence_Type__c == competitorIntelligenceType) {
                toPost = true;
                Id groupId = chatterGroupSetting.Group_Id__c;
                ConnectApi.MentionSegmentInput mentionSegment = new ConnectApi.MentionSegmentInput();
                mentionSegment.id = groupId;
                messageInput.messageSegments.add(mentionSegment);
            }
        }
        
        // add some text after the mention
        ConnectApi.TextSegmentInput textSegment = new ConnectApi.TextSegmentInput();
        textSegment.text = ', a new piece of competitive intelligence has been recorded for ' + competitorName + ', by ' + currentUserName + '. Please validate this intelligence in the link below.';
        messageInput.messageSegments.add(textSegment);
        
        ConnectApi.FeedItemInput input = new ConnectApi.FeedItemInput();
        input.body = messageInput;
        
        //add the link
        ConnectApi.LinkAttachmentInput linkIn = new ConnectApi.LinkAttachmentInput();
        linkIn.urlName = competitorIntelligenceName;
        linkIn.url = '/' + competitorIntelligenceId;
        input.attachment = linkIn;
        
        Id userId = UserInfo.getUserId();
        
        if(toPost) {
            ConnectApi.ChatterFeeds.postFeedItem(null, ConnectApi.FeedType.Record, UserInfo.getUserId(), input, null);
        }
    }
}