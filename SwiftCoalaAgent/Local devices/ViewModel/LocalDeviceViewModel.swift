//
//  LocalDeviceViewModel.swift
//  SwiftCoalaAgent
//
//  Created by Pavel Shatalov on 30.06.2018.
//  Copyright © 2018 NDMSystems. All rights reserved.
//

import Foundation

struct LocalDeviceViewModel: Hashable {
  var hashValue: Int {
    return address.hashValue
  }
  
  let address: String
  var peerInfo: Peer?
  
  init(address: String) {
    self.address = address
    peerInfo = nil
  }
  
  init(address: String, peer: Peer) {
    self.address = address
    self.peerInfo = peer
  }
  
  
}
