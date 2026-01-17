// Scheduled Apex class to refresh weather data by executing the WeatherRefreshBatch
global class WeatherRefreshScheduler  implements Schedulable {
    
    global void execute(SchedulableContext sc) {
       // Execute the batch with a batch size of 100 to avoid hitting governor limits 
        Database.executeBatch(new WeatherRefreshBatch(), 100);   
    }
}