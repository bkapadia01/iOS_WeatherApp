# iOS_WeatherApp

### Weather App - TB Project 2
This is an iOS weather app built using the Open Weather API. The app displays the current forecast, hourly forecast and daily forecast and a picker view to select a city from the predefined selection of cities.

### Current Location: 
The app uses the current latitude and longitude of the device and identifies the city the device is in. The search icon presents a city picker that is pre-populated with several popular locations and provides the forecast for these locations. The background image is updated based on the city selected.

### Other Cities:
The app uses hardcoded long/lat to retrieve the weather of the location for the cities in the picker view.

### Layout: 
WeatherMainViewController - displays the current weather, hourly forecast and daily forecast
PickerView - selection of cities to select from including current location(default)

### Possible Future Enhancements:
- To separate the picker view into a separate view controller and pass information back to the main view controller instead of using pickerView only, this helps to reduce code dependency between picker view and displaying the forecast of the selected city
- Ability to search for a city
