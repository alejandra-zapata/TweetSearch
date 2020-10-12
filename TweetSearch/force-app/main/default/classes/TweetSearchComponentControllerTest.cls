@isTest
public with sharing class TweetSearchComponentControllerTest {

    @isTest
    static void testMakeCallout() {
        // Create the mock response based on a static resource
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('getTweetResource');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');

        // Associate the callout with a mock response
        Test.setMock(HttpCalloutMock.class, mock);

        // Call method to test
        HttpResponse result = TweetSearchComponentController.makeCallout('20');

        // Verify mock response is not null
        System.assertNotEquals(null, result, 'The callout returned a null response.');

        // Verify status code
        System.assertEquals(200, result.getStatusCode(), 'The status code is not 200.');

        // Verify content type
        System.assertEquals('application/json;charset=UTF-8', result.getHeader('Content-Type'), 'The content type value is not expected');

        // Verify body of response
        Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(result.getBody());
        List<Object> data = (List<Object>) results.get('data');

        // Test getTweet returns data
        List<Object> tweetData = TweetSearchComponentController.getTweet('20');
        System.assertEquals(data.size(), tweetData.size(), 'The response is incoherent.');
    }
}
