//
//  CoalaAgent.swift
//  SwiftCoalaAgent
//
//  Created by Pavel Shatalov on 29.06.2018.
//  Copyright © 2018 NDMSystems. All rights reserved.
//

import Coala
import NDMAPI

class CoalaAgent {
  private let scheme: Scheme
  private let cid = UUID().uuidString.lowercased()
  let coala = Coala()
  
  var didReceiveLog: ((CoalaLog) -> Void)?
  
  
  init(with scheme: Scheme) {
    self.scheme = scheme
    let logger = Logger { [weak self] log in
      self?.didReceiveLog?(log)
    }
    Coala.logger = logger
    setupResource()

  }
  
  typealias DiscoveredPeer = ResourceDiscovery.DiscoveredPeer
  func startLocalSearch(completion: @escaping (([DiscoveredPeer]) -> Void)) {
    coala.resourceDiscovery.run(completion: completion)
  }
  
  func getInfo(for address: String, scheme: Scheme = .coaps, completion: @escaping (Result<Peer>) -> Void) {
    var url = scheme == .coaps ?  URL(string: "coaps://\(address)") :  URL(string: "coap://\(address)")
    url?.appendPathComponent("/info")
    var message = CoAPMessage(type: .confirmable, method: .get, url: url)
    message.onResponse = { coalaResponse in
      switch coalaResponse {
      case .error(let error):
        completion(.failure(error))
      case .message(let responseMessage, _):
        let response: [String: Any]
        do {
          guard let json = try JSONSerialization.jsonObject(with: responseMessage.payload?.data ?? Data(), options: .allowFragments) as? [String: Any] else {
            print("ERROR!!")
            return
          }
          response = json
          
        } catch let error {
          completion(.failure(error))
          return
        }
        guard let cid = response["cid"] as? String, let name = response["name"] as? String else {
          print("Errpo")
          return
        }
        let peer = Peer(cid: cid,
                        name: name,
                        type: response["type"] as? String ?? "none",
                        publicKey: responseMessage.peerPublicKey,
                        message: response["message"] as? String)
        completion(.success(peer))
      }
    }
    try? coala.send(message)
  }
  
  func updateBlock2Resource(with size: Int) {
    coala.removeResources(forPath: "/arq")
    
    let resourceBlock1 = CoAPResource(method: .post, path: "/arq") { _, _ in
      return (.changed, nil)
    }
    let resourceBlock2 = CoAPResource(method: .get, path: "/arq") { _, _ in
      return (.content, Data.randomData(length: size))
    }
    
    coala.addResource(resourceBlock1)
    coala.addResource(resourceBlock2)
  }
  
  
  private func setupResource() {
    
    let resourceBlock1 = CoAPResource(method: .post, path: "/arq") { _, _ in
      return (.changed, nil)
    }
    let resourceBlock2 = CoAPResource(method: .get, path: "/arq") { _, _ in
      return (.content, Data.randomData(length: 25 * 1024))
    }
    
    
    let mirrorResource = CoAPResource(method: .post, path: "tests/mirror") { input in
      return (.content, input.payload)
    }
    
    
    let device = UIDevice.current.modelName
    let infoResource = CoAPResource(method: .get, path: "/info") { [weak self] _ in
      return (.content, [
        "cid": self?.cid ?? "",
        "name": "\(device)_swift_agent",
        "type": "mobile",
        "version": Coala.frameworkVersion,
        "message": "This is test /info output"
        ].toJSON())
    }
    coala.addResource(infoResource)
    coala.addResource(mirrorResource)
    coala.addResource(resourceBlock1)
    coala.addResource(resourceBlock2)
  }
}

public struct Peer {
  public let cid: String
  public let name: String
  public let type: String
  public let publicKey: Data?
  public let message: String?
}

extension Peer: Hashable {
  public var hashValue: Int {
    return cid.hashValue
  }
}

public func == (lhs: Peer, rhs: Peer) -> Bool {
  return lhs.cid == rhs.cid
}





