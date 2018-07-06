//
//  ProxyModel.swift
//  SwiftCoalaAgent
//
//  Created by Pavel Shatalov on 06.07.2018.
//  Copyright © 2018 NDMSystems. All rights reserved.
//

import Coala

class ProxyModel {
  typealias State = ProxyViewController.State
  
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
      
      let foundedDevies = peers.map { ProxyViewModel(device: LocalDeviceViewModel(address: "\($0.address.host):\($0.address.port)")) }
      DispatchQueue.main.async {
        self?.viewNotificationBlock?(.didFoundDevices(foundedDevies))
      }
    }
  }
  
  func getInfo(for device: ProxyViewModel, proxyString: String?) {
    guard let proxyStr = proxyString, let proxyAddress = Address(string: proxyStr) else { return }
    coalaAgent.getInfo(for: device.device.address, scheme: scheme, proxy: proxyAddress) { [weak self] result in
      switch result {
      case .success(let peer):
        let deviceInfo = LocalDeviceViewModel(address: device.device.address, peer: peer)
        let viewModel =  ProxyViewModel(device: deviceInfo)
        DispatchQueue.main.async {
          self?.viewNotificationBlock?(.didReceiveDeviceInfo(viewModel))
        }
      case .failure(let error):
        print(error)
      }
    }
  }
}
