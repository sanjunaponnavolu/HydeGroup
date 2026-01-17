/*
WeatherDisplayController used to fetch and refresh weather data for a given Location Id.
It interacts with OpenWeatherIntegrationService to get the weather data and manages WeatherInfo__c records.
and return the latest weather information for display in the Lightning component.
*/

public  class WeatherDisplayController {

    // Retrieves the latest weather information for a given Location Id.
    @AuraEnabled(cacheable=true) 
    public static WeatherInfo__c getWeatherData(String recordId) {
        return  getLatestWeatherInfo(recordId);
    }

    /* Refreshes the weather data for a given Location Id by calling the OpenWeatherIntegrationService
       and inserting a new WeatherInfo__c record.
    */
    @AuraEnabled
    public static WeatherInfo__c refreshWeatherData(String recordId) {
        Location__c location = getLocationById(recordId);
        if (location == null) {
            throw new WeatherDisplayControllerException('Location not found for Id: ' + recordId);
        }
          
        OpenWeatherIntegrationService.WeatherInfo weatherInfo = OpenWeatherIntegrationService.fetchWeatherData(location.Latitude__c, location.Longitude__c);
        if (weatherInfo.isSuccessful) {
            WeatherInfo__c weatherInfoRecord = WeatherRefreshBatch.populateWeatherInfoRecord(recordId, weatherInfo);
            insert weatherInfoRecord;
            return getLatestWeatherInfo(recordId);
        } else {
            throw new WeatherDisplayControllerException('Failed to fetch weather data: ' + weatherInfo.message);
        }
        
    }

    //method to get Location by Id
    private static Location__c getLocationById(String locationId) {
        return [
            SELECT 
                Id, 
                Name, 
                Latitude__c, 
                Longitude__c 
            FROM Location__c 
            WHERE Id = :locationId
            LIMIT 1
        ];
    }

    //method to get the latest WeatherInfo record for a given Location Id
    private static WeatherInfo__c getLatestWeatherInfo(String locationId) {
        return [
            SELECT 
                Id,
                Location__r.Name,
                Temperature__c, 
                Humidity__c, 
                Weather_Description__c, 
                Maximum_Temperature__c, 
                Minimum_Temperature__c 
            FROM WeatherInfo__c 
            WHERE Location__c = :locationId
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
    }

    public class WeatherDisplayControllerException extends Exception {} 
}