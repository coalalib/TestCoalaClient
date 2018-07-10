//
//  RemoteModel.swift
//  SwiftCoalaAgent
//
//  Created by Pavel Shatalov on 09.07.2018.
//  Copyright © 2018 NDMSystems. All rights reserved.
//

import Coala

class RemotePeersModel {
  typealias State = RemotePeersViewController.State
  
  private var remotePeers = Set<String>()
  
  var viewNotificationBlock: ((State) -> Void)?
  let coalaAgent: CoalaAgent
  var scheme: Scheme = .coaps {
    didSet {
      startSearch()
    }
  }
  
  init() {
    coalaAgent = CoalaAgent(with: scheme)
    initRemotePeers()
  }
  
  private func initRemotePeers() {
    remotePeers.insert("778a3cae-2b08-11e8-8000-9f0844d52589")
    remotePeers.insert("500aafb2-83ed-11e4-8029-ddf0f135c0c2")
    remotePeers.insert("20c495b2-a47d-11e6-8115-3b6e1b739cc7")
    remotePeers.insert("20c494d6-a47d-11e6-8115-41d813e4cedb")
    remotePeers.insert("d5af0f78-8b83-11e7-8115-19113c48d7de")
    remotePeers.insert("3cc340d2-5482-11e7-8f23-d7d35c148d64")
    remotePeers.insert("594b4096-0487-11e8-9396-8f421f9a7667")
    remotePeers.insert("4923d7d6-a9fd-11e6-8115-d7537af73775")
    remotePeers.insert("4928b526-a9fd-11e6-8115-1f289d3cda04")
    remotePeers.insert("594b408c-0487-11e8-9396-0dd3030097e0")
    remotePeers.insert("8e8c4cfa-5f82-11e7-8115-4105580783af")
    remotePeers.insert("500b25aa-83ed-11e4-8029-e1381750d7f4")
  }
  
  
  func startSearch() {
    var devices = [ArqDeviceViewModel]()
    remotePeers.forEach {
      let localDevice = LocalDeviceViewModel(address: "", peer: nil, cid: $0)
      let arqDevice = ArqDeviceViewModel(device: localDevice, transferedSpeed: nil, dataSize: nil)
      devices.append(arqDevice)
    }
    viewNotificationBlock?(.didFoundDevices(devices))
  }
  
  
  func addPeer(cid: String) {
    remotePeers.insert(cid)
  }
  
  
  public func getAddress(ofPeerWithCid peerCid: String, completion: ((Address?) -> Void)?) {
    var getMessage = CoAPMessage(type: .confirmable,
                                 method: .get,
                                 url: URL(string: "coaps://138.197.191.160:5683/get")!)
    getMessage.query = [
      URLQueryItem(name: "cid", value: "\(UUID().uuidString.lowercased())"),
      URLQueryItem(name: "peer_cid", value: peerCid)
    ]
    getMessage.onResponse = { response in
      switch response {
      case .message(let message, _):
        guard let payload = message.payload?.string, let address = Address(string: payload) else {
          completion?(nil)
          return
        }
        completion?(address)
      case .error(let error):
        completion?(nil)

      }
    }
    try? coalaAgent.coala.send(getMessage)
  }
  
  func getInfo(for device: ArqDeviceViewModel, proxyString: String?) {
    let proxy = Address(host: "138.197.191.160", port: 5683)

    guard let cid = device.device.cid else { return }
    getAddress(ofPeerWithCid: cid) { [weak self] address in
      guard let sSelf = self else { return }
      guard let address = address else {
        return
      }
      self?.coalaAgent.getInfo(for: address.description, scheme: sSelf.scheme, proxy: proxy) { [weak self] result in
        switch result {
        case .success(let peer):
          let deviceInfo = LocalDeviceViewModel(address: address.description, peer: peer, cid: cid)
          let viewModel = ArqDeviceViewModel(device: deviceInfo, transferedSpeed: nil, dataSize: nil)
          DispatchQueue.main.async {
            self?.viewNotificationBlock?(.didReceiveDeviceInfo(viewModel))
          }
        case .failure(let error):
          print(error)
        }
      }
    }
    
    
   
  }
  
  func startArq(with device: ArqDeviceViewModel, type: ArqType, proxyString: String?) {
    let proxyAddress = Address(host: "138.197.191.160", port: 5683)

    guard let cid = device.device.cid else { return }
    getAddress(ofPeerWithCid: cid) { [weak self] address in
      guard let sSelf = self else { return }
      guard let address = address else {
        return
      }
      let startDate = Date()
      let scheme = sSelf.scheme == .coaps ? "coaps" : "coap"
      let peerUrl = URL(string: "\(scheme)://\(address.description)/arq")
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
      try? self?.coalaAgent.coala.send(requestMessage)
    }
  }
  
  
}
