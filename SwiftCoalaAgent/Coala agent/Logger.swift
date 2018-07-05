//
//  CoalaLogger.swift
//  SwiftCoalaAgent
//
//  Created by Pavel Shatalov on 05.07.2018.
//  Copyright © 2018 NDMSystems. All rights reserved.
//

import Coala

struct CoalaLog {
  let message: String
  let timestamp: UInt64
  let isIncoming: Bool
}

class Logger: CoalaLogger {
  
  private var didReceiveLog: ((CoalaLog) -> Void)?
  init(logCallback: ((CoalaLog) -> Void)?) {
    self.didReceiveLog = logCallback
  }
  
  
  func log(_ message: String, level: LogLevel, asynchronous: Bool) {
    guard level != .verbose else { return }
    let isIncoming = message.contains("Receiving")
    let timestamp = UInt64(Date().timeIntervalSince1970)
    let log = CoalaLog(message: message, timestamp: timestamp, isIncoming: isIncoming)
    didReceiveLog?(log)
  }
}
