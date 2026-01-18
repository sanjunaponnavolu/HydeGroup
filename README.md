# OpenWeather Integration – Salesforce Deployment & Usage

This project integrates Salesforce with the **OpenWeather API** to fetch and display real-time weather information for Location__c records. It supports both **on-demand refresh** (via LWC button) and **high-volume scheduled refresh** (via Batch + Scheduler).

## Deployment Instructions

### Option A: Using Change Sets (Outbound → Inbound)
### 1) Create an Outbound Change Set in Source Org
Add the following components:

#### Custom Objects
- Location__c
- WeatherInfo__c

#### Lightning Web Component
- LightningWebComponentBundle → WeatherDisplay

#### Apex Classes
- OpenWeatherIntegrationService
- WeatherRefreshBatch
- WeatherRefreshScheduler
- WeatherDisplayController

#### Apex Test Classes / Mocks
- OpenWeatherIntegrationServiceTest
- WeatherRefreshBatchTest
- WeatherRefreshSchedulerTest
- WeatherDisplayControllerTest
- OpenWeatherCalloutMock *(and any mock classes used by tests)*

#### Custom Metadata
- Custom Metadata Type / Record: OpenWeather (example: OpenWeather_Settings__mdt record)

#### Remote Site Settings
- Add Remote Site setting for OpenWeather API domain (e.g. https://api.openweathermap.org)

### 2) Upload Change Set to Target Org
- Upload outbound change set
- In target org: deploy the inbound change set

### 3) Validate Deployment
- Validate by running **All Tests**
- Deploy after successful validation

### 4) Post Deployment (UI Setup)
- Add WeatherDisplay LWC to the **Location Lightning Record Page**
  - Setup → Object Manager → Location__c → Lightning Record Pages → Edit Page
  - Drag WeatherDisplay onto the layout
  - Save + Activate

## Option B: Using Salesforce CLI (VS Code / SFDX)

### Install & Verify Salesforce CLI
- Install Salesforce CLI
- Authorise org
- Deploy the project from root folder (force-app)

## Data Model

### Location__c
- Name (standard)
- Latitude__c
- Longitude__c
- Is_Active__c

### WeatherInfo__c
- Location__c (Lookup to Location__c)
- Humidity__c
- Maximum_Temperature__c
- Minimum_Temperature__c
- Temperature__c
- Description__c

> Note: WeatherInfo__c is created against each Location and the latest record is shown on the LWC of Location page.

## Solution Approach

### High-volume Refresh (Async)
1. Scheduler runs **hourly**
2. Scheduler executes WeatherRefreshBatch with a controlled batch size
3. Batch queries all Location__c where Is_Active__c = TRUE
4. For each location in scope, makes a callout and collects weather results
5. Inserts WeatherInfo__c records in bulk
6. Errors (if any) are sent via email notification

### UI / On-demand Refresh
1. User opens a Location__c record
2. LWC calls WeatherDisplayController.getWeatherData(recordId) to display the latest WeatherInfo__c
3. User clicks **Refresh**
4. Controller calls Integration Service and inserts a new WeatherInfo__c record
5. Component refreshes and displays the latest data

## References

- [Salesforce Extensions Documentation](https://developer.salesforce.com/tools/vscode/)
- [Salesforce CLI Setup Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_intro.htm)
- [Salesforce DX Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_intro.htm)
- [Salesforce CLI Command Reference](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference.htm)
