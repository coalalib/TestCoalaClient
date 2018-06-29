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
  
  private let cid = UUID().uuidString.lowercased()
  private let coala = Coala(port: 5683)
  
  init() {
    setupResource()
    coala.resourceDiscovery.run { coapPeers in
      print(coapPeers)
    }
  }
  
  private func setupResource() {
    let infoResouce = CoAPResource(method: .get, path: "/info") { [weak self] _ in
      return (.content, [
        "cid": self?.cid ?? "",
        "name": "SwiftCoalaAgent",
        "type": "mobile",
        "version": Coala.frameworkVersion
        ].toJSON())
    }
    coala.addResource(infoResouce)
  }
  
  
}
