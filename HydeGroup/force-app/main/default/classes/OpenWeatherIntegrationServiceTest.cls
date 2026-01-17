/*
1.Test class for OpenWeatherIntegrationService to test weather data fetching functionality
2.OpenWeatherIntegrationServiceTestSuccess for testing Successful ApiI response
3.fetchWeatherDataResponseFailureTest for testing failure scenario

*/
@isTest
private class OpenWeatherIntegrationServiceTestSuccess {
    @isTest
    private static void fetchWeatherDataResponseSuccessTest() {
        Test.setMock(HttpCalloutMock.class, new OpenWeatherCalloutMock(200));
        Test.startTest();
        OpenWeatherIntegrationService.WeatherInfo weatherInfo = OpenWeatherIntegrationService.fetchWeatherData(34.0522, -118.2437);
        Test.stopTest();

        // Validate the results
        System.assertEquals('clear sky', weatherInfo.description);
        System.assertEquals(298.15, weatherInfo.temperature);
        System.assertEquals(40, weatherInfo.humidity);
        System.assertEquals(278.8, weatherInfo.maxTemperature);
        System.assertEquals(274.94, weatherInfo.minTemperature);
        System.assertEquals(true, weatherInfo.isSuccessful);
    }

    @isTest
    private static void fetchWeatherDataResponseFailureTest() {
        Test.setMock(HttpCalloutMock.class, new OpenWeatherCalloutMock(401));
        Test.startTest();
        OpenWeatherIntegrationService.WeatherInfo weatherInfo = OpenWeatherIntegrationService.fetchWeatherData(34.0522, -118.2437);
        Test.stopTest();
        
        // Validate the results
        System.assertEquals(false, weatherInfo.isSuccessful);
        System.assertEquals('{ "message": "Invalid API key."}', weatherInfo.message);
    }
}