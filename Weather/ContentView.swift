//
//  ContentView.swift
//  Weather
//
//  Created by Jan Konieczny on 18/08/2020.
//  Copyright © 2020 Jan Konieczny. All rights reserved.
//

import SwiftUI
import MapKit
import Combine
import SDWebImageSwiftUI

struct ContentView: View {
    @EnvironmentObject var weather: CurrentWeatherConditions
    @EnvironmentObject var locationFetcher: LocationFetcher
    
    @State private var currentLocation = CLLocationCoordinate2D()
    @State private var mapScale: CGFloat = 3
    @State private var selectLocation = false
    @State private var offset: CGSize = CGSize(width: -120, height: 350)
    
    var body: some View {
        GeometryReader { screenSize in
            ZStack {
                Image("skyBackground")
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                VStack{
                    Text("\(self.weather.currentConditions.city ?? "Locating user")")
                        .font(.largeTitle)
                        .padding(.bottom, 10)
                    Text("\(self.weather.currentConditions.weatherText ?? "--")")
                        .font(.headline)
                    
                    if self.weather.currentConditions.temperature != nil {
                        Text("\(self.weather.currentConditions.temperature ?? 0, specifier: "%.1f")°\(self.weather.currentConditions.unit ?? "C")")
                            .font(.system(size: 65))
                            .fontWeight(.light)
                            .padding(.top, 10)
                            .padding(.bottom, 10)
                    }
                    if !self.weather.twelveHoursForecast.isEmpty{
                        ScrollView(.horizontal, showsIndicators: false){
                            HStack(){
                                VStack{
                                    Text("Now")
                                        .bold()
                                    AnimatedImage(url: URL(string: self.weather.currentConditions.iconUrl ?? "https://developer.accuweather.com/sites/default/files/01-s.png")!).resizable().frame(width: 80, height: 45)
                                    Text("\(self.weather.currentConditions.temperature ?? 0, specifier: "%.0f")°\(self.weather.currentConditions.unit ?? "C")")
                                        .bold()
                                }
                                .padding(10)
                                ForEach(self.weather.twelveHoursForecast, id: \.id){ hour in
                                    VStack{
                                        Text("\(hour.forecastHour ?? 0)")
                                            .bold()
                                        AnimatedImage(url: URL(string: hour.iconUrl ?? "https://developer.accuweather.com/sites/default/files/01-s.png")!).resizable().frame(width: 67.5, height: 40.5)
                                        
                                        Text("\(hour.temperature ?? 0, specifier: "%.0f")°\(hour.unit ?? "C")")
                                            .bold()
                                    }
                                    .padding(10)
                                }
                            }.frame(height: 115)
                        }
                        .frame(width: screenSize.size.width + 2, height: 115)
                        .border(Color.white)
                        .opacity(self.selectLocation ? 0 : 1)
                    }
                    Spacer()
                }
                .foregroundColor(.white)
                .padding(.top, 100)
                
                SelectLocationView(selectLocation: self.$selectLocation, mapScale: self.$mapScale, offset: self.$offset)
                    .frame(width: screenSize.size.width, alignment: .center)
                    .offset(self.offset)
                    .onTapGesture {
                        withAnimation(.linear){
                            self.selectLocation.toggle()
                            if self.selectLocation {
                                self.mapScale = 1
                                self.offset = CGSize(width: 0, height: 175)
                            } else {
                                self.mapScale = 3
                                self.offset = CGSize(width: -120, height: 350)
                            }
                        }
                }
            }.onAppear{
                DispatchQueue.main.async {
                    self.locationFetcher.start()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        let location = self.locationFetcher.lastKnownLocation
                        self.weather.getLocationKey(for: location ?? CLLocationCoordinate2D(latitude: 52.397723, longitude: 16.924809))
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            self.weather.getTwelveHourForecast()//for: self.currentLocation)
                            self.weather.getCurrentWeatherConditions()//for: self.currentLocation)
                        }
                    }
                }
            }
        }//geo
    }//body
}//view

struct ContentView_Previews: PreviewProvider {
    @State static var mapScale: CGFloat = 3
    static var previews: some View {
        ContentView()
    }
}
