public with sharing class TweetSearchComponentController {

    @AuraEnabled
    public static List<Object> getTweet(String tid) {
        HttpResponse res = makeCallout(tid); 
        
        if(res != null && res.getStatusCode() == 200) {
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            if(results.containsKey('data')){
            	List<Object> data = (List<Object>) results.get('data');
                return data;
            }
        }
        return null;
    }

    public static HttpResponse makeCallout(String tid) {
        String accessToken = getAuthToken();

        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://api.twitter.com/2/tweets?ids=' + tid + '&expansions=author_id&tweet.fields=created_at');
        request.setHeader('Authorization', 'Bearer ' + accessToken);
        request.setMethod('GET');

        Http http = new Http();
        HttpResponse response = new HttpResponse();

        try{
            response = http.send(request);
        } 
        catch(System.CalloutException e) {
            throw new AuraHandledException('Darn it! Something went wrong: ' + e.getMessage());
        }
        return response;
    }

    private static String getAuthToken() {
        String Twitter_API_Key = '';
        String Twitter_API_Secret_Key = '';
        List<Credential__c> cred = [SELECT Name, API_Key__c, API_Secret_Key__c FROM Credential__c WHERE Name = 'Twitter' LIMIT 1];

        for(Credential__c c: cred) {
            if(c.Name == 'Twitter') {
                Twitter_API_Key = c.API_Key__c;
                Twitter_API_Secret_Key = c.API_Secret_Key__c;
            }
        }
        String API_Key = EncodingUtil.urlEncode(Twitter_API_Key, 'UTF-8');
        String API_Secret_Key = EncodingUtil.urlEncode(Twitter_API_Secret_Key, 'UTF-8');

        String Consumer_API_Key = API_Key + ':' + API_Secret_Key;
        Blob httpRequestHeader = Blob.valueOf(Consumer_API_Key);
        String basicAuthorizationHeader = 'Basic ' + EncodingUtil.base64Encode(httpRequestHeader);

        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://api.twitter.com/oauth2/token');
        request.setMethod('POST');
        request.setHeader('Authorization', basicAuthorizationHeader);
        request.setBody('grant_type=client_credentials');

        Http http = new Http();
        HttpResponse response = new HttpResponse();
        try{
            response = http.send(request);
        }
        catch(System.CalloutException e) {
            throw new AuraHandledException('Darn it! Something went wrong: ' + e.getMessage());
        }

        if(response.getStatusCode() == 200) {
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            if(results.containsKey('access_token')){
            	String accessToken = (String) results.get('access_token');
                return accessToken;
            }
        }
        return null;
    }
}
