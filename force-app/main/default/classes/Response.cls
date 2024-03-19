/**
 * Created by Noopur.
 */

public with sharing class Response
{
	@AuraEnabled
	public Boolean isSuccess;
	@AuraEnabled
	public Object Data;
	@AuraEnabled
	public String Message;

	public Response(Boolean isSuccess, Object data, String message){
		this.isSuccess = isSuccess;
		this.Data = data;
		this.Message = message;
	}
}