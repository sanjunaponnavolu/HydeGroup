// Mock class to simulate OpenWeather API responses for testing purposes
global class OpenWeatherCalloutMock implements HttpCalloutMock {
    public Integer statusCode;

    public OpenWeatherCalloutMock(Integer statusCode) {
        this.statusCode = statusCode;
    }

    // Implement the respond method to return a mock response
    global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setStatusCode(statusCode);
        if (statusCode == 200) {
            response.setBody(getSuccessfulResponseBody());
        } else if (statusCode == 401) {
            response.setBody('{ "message": "Invalid API key."}');   
        }
        return response;
    }

    private String getSuccessfulResponseBody() {
        return '{' +
            '"weather":[{"description":"clear sky","icon":"01d"}],' +
            '"main":{"temp":298.15,"humidity":40,"temp_min": 274.94,"temp_max": 278.8},' +
            '"wind":{"speed":3.6},' +
            '"name":"Sample City"' +
        '}';
    }
    
}