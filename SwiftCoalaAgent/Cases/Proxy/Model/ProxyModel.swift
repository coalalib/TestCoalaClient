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
      var foundedDevies = peers.map {
        ArqDeviceViewModel(device: LocalDeviceViewModel(address: "\($0.address.host):\($0.address.port)"),
                           transferedSpeed: nil, dataSize: nil)
      }
      if let myIp = getWiFiAddress() {
        foundedDevies = foundedDevies.filter({!$0.device.address.contains(myIp)})
      }
      
      
      DispatchQueue.main.async {
        self?.viewNotificationBlock?(.didFoundDevices(foundedDevies))
      }
    }
  }
  
  func getInfo(for device: ArqDeviceViewModel, proxyString: String?) {
    guard let proxyStr = proxyString, let proxyAddress = Address(string: proxyStr) else { return }
    coalaAgent.getInfo(for: device.device.address, scheme: scheme, proxy: proxyAddress) { [weak self] result in
      switch result {
      case .success(let peer):
        let deviceInfo = LocalDeviceViewModel(address: device.device.address, peer: peer)
        let viewModel = ArqDeviceViewModel(device: deviceInfo, transferedSpeed: nil, dataSize: nil)
        DispatchQueue.main.async {
          self?.viewNotificationBlock?(.didReceiveDeviceInfo(viewModel))
        }
      case .failure(let error):
        print(error)
      }
    }
  }
  
  func startArq(with device: ArqDeviceViewModel, type: ArqType, proxyString: String?) {
    guard let proxyStr = proxyString, let proxyAddress = Address(string: proxyStr) else { return }

    let startDate = Date()
    
    let scheme = self.scheme == .coaps ? "coaps" : "coap"
    let peerUrl = URL(string: "\(scheme)://\(device.device.address)/arq")
    var requestMessage = CoAPMessage(type: .confirmable, method: type == .upload ? .post : .get, url: peerUrl)
    requestMessage.proxyViaAddress = proxyAddress
    switch type {
    case .upload:
      requestMessage.payload = Data.randomData(length: 25 * 1024)
    case .download: break
    }
    
    requestMessage.onResponse = { [weak self] response in
      switch response {
      case let .message(message, _):
        let endDate = Date()
        let bytesReceived = message.payload?.data.count ?? 0
        let timeInterval = endDate.timeIntervalSince(startDate)
        let bytesSent = requestMessage.payload?.data.count ?? 0
        let bytesTotal = bytesSent + bytesReceived
        let bytesPerSecond = Double(bytesTotal) / timeInterval
        let totalSpeed = (bytesPerSecond / 1024).rounded(places: 2)
        let viewModel = ArqDeviceViewModel(device: device.device, transferedSpeed: Int(totalSpeed), dataSize: Int(bytesTotal / 1024))
        DispatchQueue.main.async {
          self?.viewNotificationBlock?(.didFinishTransfer(viewModel))
        }
      case let .error(error):
        print(error)
      }
    }
    try? coalaAgent.coala.send(requestMessage)
  }
  
  
}
