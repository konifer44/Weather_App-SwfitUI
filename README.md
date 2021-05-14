# SwiftUI-Weather-App

>At the start app locating user and download current weather conditions and twelve hour weather forecast from AccuWeather. All download data are coded in JSON and app decoding it to get all needed informations, also weather icons are download. User can choose location from map, it's easy and convenient. Tap on map to open location picker, drag map to specific location that weather forecast interest you and confirm that location. Current weather condidtions are presentet in top area of app, twelve hour forecast are presented in horizontal scrollview.

 <h3>Screenshots</h3>
  <p align="center">
  <img src="1.PNG" alt="drawing" width="200"/>
  <img src="3.PNG" alt="drawing" width="200"/>
  <img src="4.PNG" alt="drawing" width="200"/>
</p>

## Get Location Key
```swift
guard let locationKeyUrl = URL(string: "http://dataservice.accuweather.com/locations/v1/cities/geoposition/search?apikey=\(self.apiKey)&q=\(location.latitude)%2C\(location.longitude)") else {
            print("Cannot generate location key")
            return
        }
        var locationKeyRequest = URLRequest(url: locationKeyUrl)
        locationKeyRequest.httpMethod = "GET"
        let locationKeySession = URLSession(configuration: .default)
        locationKeySession.dataTask(with: locationKeyRequest) { (data, _, error) in
            guard let data = data else {
                print("Cannot read data")
                return
            }
            if let locationKeyJSON = try? JSON(data: data){
                //print(locationKeyJSON)
                DispatchQueue.main.async {
                    guard let temporaryLocationKey = locationKeyJSON["Key"].string
                        else {
                            let message = locationKeyJSON["Message"].string
                            print(message ?? "Unknown Message")
                            print("Invalid Location Key")
                            return
                    }
                    if let city = locationKeyJSON["SupplementalAdminAreas"][0]["EnglishName"].string{self.currentConditions.city = city}
                    self.locationKey = temporaryLocationKey
                }
            }
        }.resume()
```

## Get weather forecast
```swift 
 func getTwelveHourForecast(){
        guard let forecastUrl = URL(string: "http://dataservice.accuweather.com/forecasts/v1/hourly/12hour/\(self.locationKey)?apikey=\(self.apiKey)&metric=true") else {
            print("Invalid Forecast URL")
            return
        }
        var twelveHoursForecastRequest = URLRequest(url: forecastUrl)
        twelveHoursForecastRequest.httpMethod = "GET"
        let twelveHoursForecastSession = URLSession(configuration: .default)
        twelveHoursForecastSession.dataTask(with: twelveHoursForecastRequest) { (twelveHoursForecastData, _, error) in
            guard let twelveHoursForecastData = twelveHoursForecastData else {
                print("Cannot read data")
                return
            }
            if let twelveHoursForecastJSON = try? JSON(data: twelveHoursForecastData) {
                DispatchQueue.main.async {
                     // more to see in code 
                    }
                }
            }
        }.resume()
    }
```
## Tech
  - Core Location
  - SwiftUI
  - AccuWeather API
  - JSON
 
