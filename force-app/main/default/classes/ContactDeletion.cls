public class ContactDeletion {
    Public static void deleteprevention(List<Contact> Condelete){
      //  id uid = userinfo.getuserid();
        string profileID = UserInfo.getProfileId();
        Profile SysAdmin =[select id,name from Profile p WHERE Profile.Name='System Administrator'];
        for(Contact con : Condelete){
            if( ProfileId!=SysAdmin.Id){
                con.AddError('Please contact System Admin for deleting any contact');
            }
        }
    }
}