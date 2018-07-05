//
//  LogCell.swift
//  SwiftCoalaAgent
//
//  Created by Pavel Shatalov on 02.07.2018.
//  Copyright © 2018 NDMSystems. All rights reserved.
//

import Coala

class LogCell: UITableViewCell {

  @IBOutlet private weak var logLabel: UILabel!
  @IBOutlet private weak var incomingView: UIView!
  @IBOutlet private weak var directionLabel: UILabel!
  
  
  override func prepareForReuse() {
    super.prepareForReuse()
    logLabel.text = nil
    incomingView.backgroundColor = .clear
    directionLabel.text = nil
  }
  
  func configure(with log: CoalaLog) {
    logLabel.text = log.message
    incomingView.backgroundColor = log.isIncoming ? .blue : .green
    directionLabel.text = log.isIncoming ? ">>>" : "<<<"
  }
  
}
