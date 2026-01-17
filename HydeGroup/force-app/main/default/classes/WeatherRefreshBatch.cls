/**
 * Batch class to refresh weather information for active locations.
 * Fetches weather data from OpenWeather API and stores it in WeatherInfo__c records.
 * Sends email notifications for any errors encountered during the process.
 */
global class WeatherRefreshBatch  implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts
{
    private static final String WEATHER_INFO_REFRESH_ERROR_MESSAGE= 'Error inserting WeatherInfo record for Location Id: {0}. Error: {1}';
    private static final String WEATHER_INFO_INTEGRATION_ERROR_MESSAGE= 'Failed to fetch weather data for Location Id: {0}. Error: {1}';
    public Set<String> locationIdsWithErrors = new Set<String>();
    private static final String SETTINGS_NAME = 'OpenWeather';
    private static final String NOTIFICATION_SUBJECT = 'Weather Refresh Errors';
    private static final String NOTIFICATION_BODY_HEADER = 'The following errors occurred during weather refresh:';

    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, Latitude__c, Longitude__c FROM Location__c WHERE Is_Active__c = TRUE';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<SObject> scope) {
        List<WeatherInfo__c> weatherInfoList = new List<WeatherInfo__c>();
        for (Location__c location : (List<Location__c>)scope) {
            try {
                OpenWeatherIntegrationService.WeatherInfo weatherInfo = 
                    OpenWeatherIntegrationService.fetchWeatherData(location.Latitude__c, location.Longitude__c);
                if (weatherInfo.isSuccessful) {
                    WeatherInfo__c weatherInfoRecord = populateWeatherInfoRecord(location.Id, weatherInfo);
                    weatherInfoList.add(weatherInfoRecord);
                } else {
                    locationIdsWithErrors.add(
                        string.format(
                            WEATHER_INFO_INTEGRATION_ERROR_MESSAGE,
                            new List<String> {location.Id, weatherInfo.message}
                        )
                    );
                }
            } catch (Exception ex) {
                locationIdsWithErrors.add(string.format(
                    WEATHER_INFO_INTEGRATION_ERROR_MESSAGE,
                    new List<String> {location.Id, ex.getMessage()})
                );   
            }   
        }

        // Insert the WeatherInfo records in bulk and capture any insertion errors
        if (!weatherInfoList.isEmpty()) {
            Database.SaveResult[] results = Database.insert(weatherInfoList, false);
            for (Integer i = 0; i < results.size(); i++) {
                if (!results[i].isSuccess()) {
                    for (Database.Error error : results[i].getErrors()) {
                        locationIdsWithErrors.add(string.format(
                            WEATHER_INFO_REFRESH_ERROR_MESSAGE,
                            new List<String> {weatherInfoList[i].Location__c, error.getMessage()})
                        );
                    }
                }
            }    
        }
    }

    // Sends an email notification with the list of errors encountered during weather refresh.
    global void finish(Database.BatchableContext BC) {  
        if (!locationIdsWithErrors.isEmpty()) {
            OpenWeather_Settings__mdt settings = OpenWeather_Settings__mdt.getInstance(SETTINGS_NAME);
            String[] emailAddresses = new String[] {settings.Error_Notification_Email__c};

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(emailAddresses);
            mail.setSubject(NOTIFICATION_SUBJECT);
            mail.setPlainTextBody(NOTIFICATION_BODY_HEADER);
            for (String error : locationIdsWithErrors) {
                mail.setPlainTextBody(mail.getPlainTextBody() + '\n' + error);
            }
            if (!Test.isRunningTest()) {
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
            }
        }
    }

   //populate WeatherInfo__c record from  APIresponse weather data
    public static WeatherInfo__c populateWeatherInfoRecord(String locationId, OpenWeatherIntegrationService.WeatherInfo weatherInfo) {
        return new WeatherInfo__c(
            Location__c = locationId,
            Weather_Description__c = weatherInfo.description,
            Temperature__c = Math.Round(convertKelvinToCelsius(weatherInfo.temperature)),
            Humidity__c = weatherInfo.humidity,
            Maximum_Temperature__c = Math.Ceil(convertKelvinToCelsius(weatherInfo.maxTemperature)),
            Minimum_Temperature__c = Math.Floor(convertKelvinToCelsius(weatherInfo.minTemperature))
        );
    }

    // Convert temperature from Kelvin to Celsius
    private static Decimal convertKelvinToCelsius(Decimal kelvinTemp) {
        return kelvinTemp - 273.15;
    }
}