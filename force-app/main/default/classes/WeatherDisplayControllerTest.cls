/*
 * Test class for WeatherDisplayController to test weather data fetching and refreshing functionality
 * setupTestData to create test records
 * testGetWeatherData to test fetching weather data
 * testRefreshWeatherDataSuccess to test successful refresh of weather data
 * testRefreshWeatherDataFailure to test failure scenario during refresh
 */
@IsTest
private class WeatherDisplayControllerTest {

    @TestSetup
    private static void setupTestData() {
        Location__c location = new Location__c(
            Name = 'Test Location',
            Latitude__c = 34.0522,
            Longitude__c = -118.2437,
            is_Active__c = true
        );
        insert location;

        WeatherInfo__c weatherInfo = new WeatherInfo__c(
            Location__c = location.Id,
            Temperature__c = 295.15,
            Humidity__c = 50,
            Weather_Description__c = 'clear sky',
            Maximum_Temperature__c = 300.15,
            Minimum_Temperature__c = 290.15
        );
        insert weatherInfo;
    }

    @isTest
    private static void testGetWeatherData() {
        Location__c location = [SELECT Id FROM Location__c LIMIT 1];
        Test.startTest();
        WeatherInfo__c weatherInfo = WeatherDisplayController.getWeatherData(location.Id);
        Test.stopTest();

        System.assertEquals('clear sky', weatherInfo.Weather_Description__c);
    }

    @isTest
    private static void testRefreshWeatherDataSuccess() {
        Test.setMock(HttpCalloutMock.class, new OpenWeatherCalloutMock(200));
        Location__c loc = [SELECT Id FROM Location__c LIMIT 1];

        Test.startTest();
        WeatherInfo__c refreshedWeatherInfo = WeatherDisplayController.refreshWeatherData(loc.Id);
        Test.stopTest();

        List<WeatherInfo__c> latestWeatherInfo = [SELECT Id FROM WeatherInfo__c ];
        System.assertEquals(2, latestWeatherInfo.size());
    }

    @isTest
    private static void testRefreshWeatherDataFailure() {
        Test.setMock(HttpCalloutMock.class, new OpenWeatherCalloutMock(401));
        Location__c location = [SELECT Id FROM Location__c LIMIT 1];

        Test.startTest();
        try {
            WeatherDisplayController.refreshWeatherData(location.Id);
        } catch (Exception e) {
            System.assert(e.getMessage().contains('Failed to fetch weather data'));
        }
        Test.stopTest();
    }
}