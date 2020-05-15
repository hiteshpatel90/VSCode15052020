public class soapAPICall{
    public static void callAPI(){
        
        docSampleComDocsample.DocSamplePort stub = new docSampleComDocsample.DocSamplePort();
        stub.inputHttpHeaders_x = new Map<String, String>();
        
        //Setting a basic authentication header
        
        stub.inputHttpHeaders_x.put('Authorization', 'Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ==');
        
        //Setting a cookie header
        stub.inputHttpHeaders_x.put('Cookie', 'name=value');
        
        //Setting a custom HTTP header
        stub.inputHttpHeaders_x.put('myHeader', 'myValue');
        
        String input = 'This is the input string';
        String output = stub.EchoString(input);
    }
}