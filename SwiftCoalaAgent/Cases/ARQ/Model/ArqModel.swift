//
//  ArqModel.swift
//  SwiftCoalaAgent
//
//  Created by Pavel Shatalov on 03.07.2018.
//  Copyright © 2018 NDMSystems. All rights reserved.
//

import Coala

enum ArqType {
  case upload
  case download
}

class ArqModel {
  typealias State = ArqViewController.State
  
  var scheme: Scheme = .coaps {
    didSet {
      startSearch()
    }
  }
  var viewNotificationBlock: ((State) -> Void)?
  var coalaAgent: CoalaAgent
  let arqType: ArqType
  init(with arqType: ArqType) {
    self.arqType = arqType
    coalaAgent = CoalaAgent(with: .coaps)
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
      foundedDevies.forEach { self?.getInfo(for: $0.device) }
    }
  }
  
  private func getInfo(for device: LocalDeviceViewModel) {
    coalaAgent.getInfo(for: device.address, scheme: scheme) { [weak self] result in
      switch result {
      case .success(let peer):
        let deviceInfo = LocalDeviceViewModel(address: device.address, peer: peer)
        let viewModel = ArqDeviceViewModel(device: deviceInfo, transferedSpeed: nil, dataSize: nil)
        DispatchQueue.main.async {
          self?.viewNotificationBlock?(.didReceiveDeviceInfo(viewModel))
        }
      case .failure(let error):
        print(error)
      }
    }
  }
  
  func setupBlockSize(size: Int) {
    coalaAgent.updateBlock2Resource(with: size * 1024)
  }
  
  func startArq(with device: LocalDeviceViewModel, size: Int) {
    let startDate = Date()
    let scheme = self.scheme == .coaps ? "coaps" : "coap"
    let peerUrl = URL(string: "\(scheme)://\(device.address)/arq")
    var requestMessage = CoAPMessage(type: .confirmable, method: arqType == .upload ? .post : .get, url: peerUrl)
    switch arqType {
    case .upload:
      requestMessage.payload = Data.randomData(length: size * 1024)
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
        let viewModel = ArqDeviceViewModel(device: device, transferedSpeed: Int(totalSpeed), dataSize: Int(bytesTotal / 1024))
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

extension Double {
  /// Rounds the double to decimal places value
  func rounded(places: Int) -> Double {
    let divisor = pow(10.0, Double(places))
    return (self * divisor).rounded() / divisor
  }
}


  


