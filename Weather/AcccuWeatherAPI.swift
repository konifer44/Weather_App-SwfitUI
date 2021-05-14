//
//  AcccuWeatherAPI.swift
//  Weather
//
//  Created by Jan Konieczny on 24/08/2020.
//  Copyright © 2020 Jan Konieczny. All rights reserved.
//

import Foundation
import SwiftyJSON
import CoreLocation

class CurrentWeatherConditions: ObservableObject{
    @Published var currentConditions = currentConditionsDataType()
    @Published var twelveHoursForecast = [hourForecast]()
    @Published var temporaryForecast = hourForecast()
    
    var id = UUID()
    
    let apiKey: String = "enter api key"
    var locationKey = String()
    
    struct currentConditionsDataType : Identifiable {
        var id = UUID()
        var city: String?
        var weatherText : String?
        var weatherIcon : Int?
        var iconUrl: String?
        var isDayTime : Bool?
        var temperature: Double?
        var unit: String?
    }
    struct hourForecast: Identifiable {
        var id: Int?
        var dateTime: String?
        var epochDateTime: Double?
        var date: Date?
        var forecastHour: Int?
        var weatherIcon : Int?
        var iconUrl: String?
        var iconPhrase : String?
        var hasPrecipitation : Bool?
        var isDaylight : Bool?
        var temperature: Double?
        var unit: String?
        var precipitationProbability: Int?
    }
    
    func getLocationKey(for location: CLLocationCoordinate2D){
        print("Get locationKey")
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
    }
    func getTwelveHourForecast(){
        print("Get 12")
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
                    let forecast = twelveHoursForecastJSON[].arrayValue
                    self.twelveHoursForecast.removeAll()
                    for hour in 0..<forecast.count{
                        self.temporaryForecast.id = hour
                        if let dateTime = twelveHoursForecastJSON[hour]["DateTime"].string{
                            self.temporaryForecast.dateTime = dateTime
                        }
                        if let epochDateTime = twelveHoursForecastJSON[hour]["EpochDateTime"].double{
                            self.temporaryForecast.epochDateTime = epochDateTime
                            self.temporaryForecast.date = Date(timeIntervalSince1970: epochDateTime)
                            let components = Calendar.current.dateComponents([.hour, .minute], from: self.temporaryForecast.date ?? Date())
                            self.temporaryForecast.forecastHour = components.hour ?? 0
                        }
                        if let weatherIcon = twelveHoursForecastJSON[hour]["WeatherIcon"].int{
                            self.temporaryForecast.weatherIcon = weatherIcon
                            self.temporaryForecast.iconUrl = "https://developer.accuweather.com/sites/default/files/\(weatherIcon < 10 ? "0" : "")\(weatherIcon)-s.png"
                        }
                        if let iconPhrase = twelveHoursForecastJSON[hour]["IconPhrase"].string{
                            self.temporaryForecast.iconPhrase = iconPhrase
                        }
                        if let hasPrecipitation = twelveHoursForecastJSON[hour]["HasPrecipitation"].bool{
                            self.temporaryForecast.hasPrecipitation = hasPrecipitation
                        }
                        if let isDaylight = twelveHoursForecastJSON[hour]["IsDaylight"].bool{
                            self.temporaryForecast.isDaylight = isDaylight
                        }
                        if let temperature = twelveHoursForecastJSON[hour]["Temperature"]["Value"].double{
                            self.temporaryForecast.temperature = temperature
                        }
                        if let unit = twelveHoursForecastJSON[hour]["Temperature"]["Unit"].string{
                            self.temporaryForecast.unit = unit
                        }
                        self.twelveHoursForecast.append(self.temporaryForecast)
                    }
                }
            }
        }.resume()
    }
    
    func getCurrentWeatherConditions(){
        print("Get current")
        guard let currentConditionsURL = URL(string: "http://dataservice.accuweather.com/currentconditions/v1/\(self.locationKey)?apikey=\(self.apiKey)") else {
            print("Invalid Forecast URL")
            return
        }
        var currentConditionsRequest = URLRequest(url: currentConditionsURL)
        currentConditionsRequest.httpMethod = "GET"
        let currentConditionsSession = URLSession(configuration: .default)
        currentConditionsSession.dataTask(with: currentConditionsRequest) { (currentConditionsData, _, error) in
            guard let currentConditionsData = currentConditionsData else {
                print("Cannot read data")
                return
            }
            if let currentConditionsJSON = try? JSON(data: currentConditionsData) {
                DispatchQueue.main.async {
                    if let isDayTime = currentConditionsJSON[0]["IsDayTime"].bool{self.currentConditions.isDayTime = isDayTime}
                    if let weatherText = currentConditionsJSON[0]["WeatherText"].string{self.currentConditions.weatherText = weatherText}
                    if let weatherIcon = currentConditionsJSON[0]["WeatherIcon"].int{
                        self.currentConditions.weatherIcon = weatherIcon
                     self.currentConditions.iconUrl = "https://developer.accuweather.com/sites/default/files/\(weatherIcon < 10 ? "0" : "")\(weatherIcon)-s.png"
                    }
                    if let temperature = currentConditionsJSON[0]["Temperature"]["Metric"]["Value"].double{
                        self.currentConditions.temperature = temperature
                    }
                    if let unit = currentConditionsJSON[0]["Temperature"]["Metric"]["Unit"].string{self.currentConditions.unit = unit}
                }
            }
        }.resume()
    }
}
