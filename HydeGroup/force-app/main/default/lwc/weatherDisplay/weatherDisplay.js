import { LightningElement, api, wire, track  } from 'lwc';
import getWeatherData from '@salesforce/apex/WeatherDisplayController.getWeatherData';
import refresWeatherInfo  from '@salesforce/apex/WeatherDisplayController.refreshWeatherData';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class WeatherDisplay extends LightningElement {
    @track weatherData;
    @track hasData;
    @api recordId;
    @track hasError = false;
    @track errorMessage = '';
    @track isRefreshing = false;
    
   //wire to fetch weather data based on the recordId
    @wire(getWeatherData, { recordId: '$recordId' })
    wiredWeather({ error, data }) {
        if (data) {
            this.weatherData = data;
            this.hasData = true;
        } else if (error) {
            this.weatherData = null;
            this.hasData = false;
            this.errorMessage = error.body.message;
        }
    }

    //it will be triggered when refresh button is clicked
    handleRefresh() {
        this.isRefreshing = true;
        refresWeatherInfo({ recordId: this.recordId })
            .then(result => {
                this.weatherData = result;
                this.weatherIconValue = this.computeIconFromDescription(result.Weather_Description__c);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Weather data refreshed successfully',
                        variant: 'success',
                    }),
                );
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error refreshing weather data',
                        message: error.body.message,
                        variant: 'error',
                    }),
                );
            })
            .finally(() => {
                this.isRefreshing = false;
            });    
    }
}