/* Author:Latha
 * It is Generic class for returning all kinds of values from aura methods. */
public class Response {

    @auraenabled
    public Object data;//data to carry in response
    @auraenabled
    public String msg;//any particular message regarding reponse
    @auraenabled
    public Boolean isSuccess;//indecate if the request was success 
    public Response(Boolean isSuccess,String msg,Object data){
        this.isSuccess=isSuccess;
        this.msg=msg;
        this.data=data;
    }
    
}