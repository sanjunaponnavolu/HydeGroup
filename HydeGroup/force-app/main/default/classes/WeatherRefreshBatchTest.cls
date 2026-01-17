/*
 * Test class for WeatherRefreshBatch to test batch processing of weather data refresh
 * setupTestData to create test Location__c records
 * testExecuteBatchSuccess to test successful batch execution
 * testExecuteBatchWithErrors to test error handling during batch execution
 */
@isTest
private class WeatherRefreshBatchTest {

    @TestSetup
     private static void setupTestData() {
        List<Location__c> locations = new List<Location__c>();
        for (Integer i = 0; i < 50; i++) {
            locations.add(new Location__c(
                Name = 'Test Location ' + i,
                Latitude__c = 30.0 + i,
                Longitude__c = -90.0 - i,
                is_Active__c = true
            ));
        }
        insert locations; 
    }

    @isTest
    private static void testExecuteBatchSuccess() {
        Test.setMock(HttpCalloutMock.class, new OpenWeatherCalloutMock(200));

        // Execute the batch
        WeatherRefreshBatch batch = new WeatherRefreshBatch();
        Test.startTest();
        Database.executeBatch(batch, 100);
        Test.stopTest();

        // Validate that weather data was created
        List<WeatherInfo__c> weatherInfo = [SELECT Id, Weather_Description__c, Temperature__c FROM WeatherInfo__c];
        System.assertEquals(50, weatherInfo.size());
    }

    @isTest
    private static void testExecuteBatchWithErrors() {
        Test.setMock(HttpCalloutMock.class, new OpenWeatherCalloutMock(401));   
        // Execute the batch
        WeatherRefreshBatch batch = new WeatherRefreshBatch();
        //batch.locationIdsWithErrors.add('Invalid Location Id'); // Simulate an error for testing
        Test.startTest();
        Database.executeBatch(batch, 100);
        Test.stopTest();

        // Validate that no weather data was created and errors were logged
        List<WeatherInfo__c> weatherInfo = [SELECT Id FROM WeatherInfo__c];
        System.assertEquals(0, weatherInfo.size());
    }
    
}