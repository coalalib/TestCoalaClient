//
//  LocalDevicesModel.swift
//  SwiftCoalaAgent
//
//  Created by Pavel Shatalov on 30.06.2018.
//  Copyright © 2018 NDMSystems. All rights reserved.
//

import Coala

enum Scheme {
  case coap
  case coaps
}

class LocalDevicesModel {
  typealias State = LocalDeviceViewController.State
  
  var viewNotificationBlock: ((State) -> Void)?
  let coalaAgent: CoalaAgent
  var scheme: Scheme = .coaps {
    didSet {
      startSearch()
    }
  }
  
  init() {
    coalaAgent = CoalaAgent(with: scheme)
  }
  
  
  func startSearch() {
    DispatchQueue.main.async { [weak self] in
      self?.viewNotificationBlock?(.didFoundDevices([]))
    }
    coalaAgent.startLocalSearch { [weak self] peers in
      let foundedDevies = peers.map { LocalDeviceViewModel(address: "\($0.address.host):\($0.address.port)") }
      DispatchQueue.main.async {
        self?.viewNotificationBlock?(.didFoundDevices(foundedDevies))
      }
    }
  }

  func getInfo(for device: LocalDeviceViewModel) {
    coalaAgent.getInfo(for: device.address, scheme: scheme) { [weak self] result in
      switch result {
      case .success(let peer):
        let deviceInfo = LocalDeviceViewModel(address: device.address, peer: peer)
        DispatchQueue.main.async {
          self?.viewNotificationBlock?(.didReceiveDeviceInfo(deviceInfo))
        }
      case .failure(let error):
        print(error)
      }
      
    }
  }  
}
