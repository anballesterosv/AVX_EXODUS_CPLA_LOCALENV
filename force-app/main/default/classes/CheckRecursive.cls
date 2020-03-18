/**
   @Author - Sanhitha
   @name -  checkRecursive
   @Description - Restricts Recursive actions of Trigger
   @Revision- 1.0
*/
public Class CheckRecursive{
    public static boolean run = true;
     /*
    @methodname-runOnce
    @aurguments-null
    @description-Restricts Recursive actions of Trigger
    */
    public static boolean runOnce(){
        if(run){
         run=false;
         return true;
        }else{
            return run;
        }
    }
}