//
//  SingaporeMapViewModel.swift
//  sgairquality
//
//  Created by Stuart Breckenridge on 19/02/2026.
//

import Foundation
import SwiftUI
import MapKit

@Observable
class SingaporeMapViewModel {

    var mapCameraPosition: MapCameraPosition = MapCameraPosition.region(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 1.3521, longitude: 103.8198), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)))

    var showLatestDataView: Bool = false
    var showHistoricalDataView: Bool = false
    var showExplanationView: Bool = false

}
