// Test class for WeatherRefreshScheduler
@isTest
private class WeatherRefreshSchedulerTest {
    @isTest
    private static void testExecute() {
        // corn expression for every hour
        String cronExp = '0  0 * * * ?'; // Every 1 hour
        Test.setMock(HttpCalloutMock.class, new OpenWeatherCalloutMock(200));
        Test.startTest();
        String jobId = System.schedule('Test Weather Refresh Job', cronExp, new WeatherRefreshScheduler());
        Test.stopTest();

        // Verify that the job was scheduled
        CronTrigger ct = [SELECT Id, CronExpression, State FROM CronTrigger WHERE Id = :jobId];
        System.assertEquals(cronExp, ct.CronExpression);
    }
}