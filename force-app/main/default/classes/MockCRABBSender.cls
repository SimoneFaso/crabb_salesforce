/**
 * Created by MatteoSala on 18/06/2020.
 */

@isTest
public class MockCRABBSender implements HttpCalloutMock {

    protected Integer code;
    protected String status;
    protected String body;
    protected Map<String, String> responseHeaders;

    public static String mailupTOKEN;

    public MockCRABBSender(Integer code, String status, String body, Map<String, String> responseHeaders) {
        this.code = code;
        this.status = status;
        this.body = body;
        this.responseHeaders = responseHeaders;
    }

    public HTTPResponse respond(HTTPRequest req) {

        HttpResponse res = new HttpResponse();
        for (String key : this.responseHeaders.keySet()) {
            res.setHeader(key, this.responseHeaders.get(key));
        }
        res.setBody(this.body);
        res.setStatusCode(this.code);
        res.setStatus(this.status);
        if(String.isNotBlank(mailupTOKEN)){
            res.setStatusCode(200);
//            res.setBody('{ "Email":"prova@prova.it"  }');
        }
        return res;
    }

}