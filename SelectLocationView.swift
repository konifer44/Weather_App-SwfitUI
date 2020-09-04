//
//  SelectLocationView.swift
//  Weather
//
//  Created by Jan Konieczny on 01/09/2020.
//  Copyright © 2020 Jan Konieczny. All rights reserved.
//

import SwiftUI
import MapKit

struct SelectLocationView: View {
    @EnvironmentObject var weather: CurrentWeatherConditions
    @EnvironmentObject var locationFetcher: LocationFetcher
    @State private var centerCoordinates = CLLocationCoordinate2D()
    @Binding var selectLocation: Bool
    @Binding var mapScale: CGFloat
    @Binding var offset: CGSize
    
    var body: some View {
        GeometryReader { screenSize in
            ZStack {
                VStack(spacing: 20){
                    Text("Drag on map to choose location")
                        .font(.headline)
                        .foregroundColor(Color.white)
                        .opacity(self.selectLocation ? 1 : 0)
                        .scaleEffect(self.selectLocation ? 1 : 1/4)
                    MapView(centerCoordinate: self.$centerCoordinates)
                        .frame(width: ((screenSize.size.width - 50) / self.mapScale), height: ((screenSize.size.width - 50) / self.mapScale), alignment: .center)
                        .clipShape(Circle())
                        .overlay(
                            Circle().stroke(Color.white, lineWidth: 4))
                        .shadow(radius: 10)
                   
                    Button(action: {
                        print("New location")
                        self.selectLocationMinimizeView()
                        self.weather.getLocationKey(for: self.centerCoordinates)
                        self.weather.getTwelveHourForecast()
                        self.weather.getCurrentWeatherConditions()
                    }) {
                        Text("Confirm this location")
                            .padding(5)
                    }
                    .frame(width: 250, height: 50)
                    .background(Color.green.opacity(0.9))
                    .foregroundColor(Color.white)
                    .cornerRadius(30)
                    .opacity(self.selectLocation ? 1 : 0)
                    .scaleEffect(self.selectLocation ? 1 : 1/4)
                }
                
                Button(action: {
                    
                   
                }) {
                    Image(systemName: "location")
                        .font(.system(size: 20))
                }
                .frame(width: 45, height: 45)
                .background(Color.blue.opacity(0.9))
                .foregroundColor(Color.white)
                .cornerRadius(12)
                .opacity(self.selectLocation ? 1 : 0)
                .scaleEffect(self.selectLocation ? 1 : 1/4)
                .offset(x: ((screenSize.size.width - 80) / 2 / self.mapScale), y: (-((screenSize.size.width - 80) / 2 / self.mapScale)))
                
            }
        }
    }
    func selectLocationMinimizeView() {
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
}
/*
 struct SelectLocationView_Previews: PreviewProvider {
 @State static var mapScale: CGFloat = 1
 @State static var selcectLocation: Bool = false
 @State static var location: CLLocationCoordinate2D = CLLocationCoordinate2D()
 static var previews: some View {
 SelectLocationView(weatherLocationFromMap: CLLocationCoordinate2D(), selectLocation: $selcectLocation, mapScale: $mapScale)
 }
 }
 */
