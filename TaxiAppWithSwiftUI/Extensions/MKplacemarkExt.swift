//
//  MKplacemarkExt.swift
//  TaxiAppWithSwiftUI
//
//  Created by shimizu  yusuke on 2025/11/04.
//

import Foundation
import MapKit

extension MKPlacemark {
    
    var addressString: String {
        let administrativeArea = self.administrativeArea ?? ""
        let locality = self.locality ?? ""
        let subLocality = self.subLocality ?? ""
        let throughfare = self.thoroughfare ?? ""
        let subThroughfare = self.subThoroughfare ?? ""
        
        return "\(administrativeArea)\(locality)\(subLocality)\(throughfare)\(subThroughfare)"
    }

}
