/* 
    OpenWeatherIntegrationService class is to integrate with  external System-OpenWeather API.
    It fetches weather data based on latitude and longitude, processes the response
    and return a WeatherInfo .
*/
public class OpenWeatherIntegrationService {
    private static final String METHOD_TYPE = 'GET';
    private static final String SETTINGS_NAME = 'OpenWeather';
    private static final String INTERGRATION_SETTINGS_NOT_FOUND = 'OpenWeather settings not found.';
    private static final String WEATHER_DATA_FETCH_SUCCESS = 'Weather data fetched successfully.';
    private static final Integer SUCCESS_STATUS_CODE = 200;

    public static WeatherInfo fetchWeatherData(Decimal latitude, Decimal longitude) {
        OpenWeather_Settings__mdt settings = OpenWeather_Settings__mdt.getInstance(SETTINGS_NAME); // Fetch integration settings from custom metadata
        if (settings == null) {
            throw new OpenWeatherIntegrationServiceException(INTERGRATION_SETTINGS_NOT_FOUND);
        }

        String endpoint = settings.Endpoint_URL__c + '?lat=' + latitude + '&lon=' + longitude + '&appid=' + settings.App_Id__c;
        WeatherInfo weatherInfo;
        try {
            HttpResponse response = sendRequest(buildRequest(endpoint, METHOD_TYPE));
            if (response.getStatusCode() == SUCCESS_STATUS_CODE) {
                weatherInfo = processResponse(response);  
            } else {
                String errorMessage = response.getBody();
                weatherInfo = new WeatherInfo('', '', null, null, null, null, false, errorMessage);
            }
        } catch (Exception ex) {
            String exceptionMessage = 'Error fetching weather data: ' + ex.getMessage();
            weatherInfo = new WeatherInfo('', '', null, null, null, null, false, exceptionMessage);
        }
        return weatherInfo;
    }

    // Build the HTTP request
    private static HttpRequest buildRequest(String endpoint, String method) {
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod(method);
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Accept', 'application/json');
        return request;
    }
   
    // Send the HTTP request and return the response
    private static HttpResponse sendRequest(HttpRequest request) {
        Http http = new Http();
        HttpResponse response = http.send(request);
        return response;
    }

    // Process the HTTP response and extract weather information
    private static WeatherInfo processResponse(HttpResponse response) {
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        List<Object> weatherList = (List<Object>) responseMap.get('weather');
        Map<String, Object> mainMap = (Map<String, Object>) responseMap.get('main');
        Map<String, Object> weatherMap = (Map<String, Object>) weatherList[0];

        String description = (String) weatherMap.get('description');
        String icon = (String) weatherMap.get('icon');
        Decimal temperature = Decimal.valueOf(mainMap.get('temp').toString());
        Decimal humidity = Decimal.valueOf(mainMap.get('humidity').toString());
        Decimal maxTemperature = Decimal.valueOf(mainMap.get('temp_max').toString());
        Decimal minTemperature = Decimal.valueOf(mainMap.get('temp_min').toString());
        return new WeatherInfo(description, icon, temperature, humidity, maxTemperature, minTemperature, true, WEATHER_DATA_FETCH_SUCCESS);
    }

    // wrapper class to hold weather information and success or failure message
    public class WeatherInfo {
        public String description;
        public String icon;
        public Decimal temperature;
        public Decimal humidity;
        public Decimal maxTemperature;
        public Decimal minTemperature;
        public Boolean isSuccessful;
        public String message;

        public WeatherInfo(
            String description,
            String icon, 
            Decimal temperature, 
            Decimal humidity, 
            Decimal maxTemperature, 
            Decimal minTemperature,
            Boolean isSuccessful,
            String message
        ) {

            this.description = description;
            this.icon = icon;
            this.temperature = temperature;
            this.humidity = humidity;
            this.maxTemperature = maxTemperature;
            this.minTemperature = minTemperature;
            this.isSuccessful = isSuccessful;
            this.message = message;
        }
    }

    public class OpenWeatherIntegrationServiceException extends Exception {}

}