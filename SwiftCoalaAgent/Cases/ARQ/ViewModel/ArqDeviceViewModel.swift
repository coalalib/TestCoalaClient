//
//  ArqDeviceViewModel.swift
//  SwiftCoalaAgent
//
//  Created by Pavel Shatalov on 03.07.2018.
//  Copyright © 2018 NDMSystems. All rights reserved.
//

import Foundation

struct ArqDeviceViewModel: Hashable {
 
  var device: LocalDeviceViewModel
  var transferedSpeed: Int?
  var dataSize: Int?
  var hashValue: Int {
    if let cid = device.cid {
      return device.address.hashValue ^ cid.hashValue
    }
    return device.address.hashValue
  }
  
  
  
}
