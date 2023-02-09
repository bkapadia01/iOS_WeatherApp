# iOS_WeatherApp

### Weather App - TB Project 2
This is an iOS weather app built using the Open Weather API. The app displays the current forecast, hourly forecast and daily forecast and a picker view to select a city from the predefined selection of cities.

<img src="https://user-images.githubusercontent.com/26723281/217882166-3d7f16ed-759c-41e8-8a5f-347bfbe0ad1d.gif" width="300" height="580">  <img src="https://user-images.githubusercontent.com/26723281/217882329-12c731d5-51f8-4bb6-9cd1-bd0b4fd67bbe.png" width="300" height="580">  <img src="https://user-images.githubusercontent.com/26723281/217882345-f0d99997-b6a6-424d-8167-ce33caae0cfd.png" width="300" height="580">




### Current Location: 
The app uses the current latitude and longitude of the device and identifies the city the device is in. The search icon presents a city picker that is pre-populated with several popular locations and provides the forecast for these locations. The background image is updated based on the city selected.

### Other Cities:
The app uses hardcoded long/lat to retrieve the weather of the location for the cities in the picker view.

### Layout: 
WeatherMainViewController - displays the current weather, hourly forecast and daily forecast
PickerView - selection of cities to select from including current location(default)

### Possible Future Enhancements:
- To separate the picker view into a separate view controller and pass information back to the main view controller instead of using pickerView only, this helps to reduce code dependency between picker view and displaying the forecast of the selected city
- Refactor how the cities long/lat are hardcoded and code is repeated for each city
- Ability to search for a city
- Ability to change language
- Use MVVM framework

