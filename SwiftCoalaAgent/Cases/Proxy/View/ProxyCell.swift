//
//  ProxyCell.swift
//  SwiftCoalaAgent
//
//  Created by Pavel Shatalov on 06.07.2018.
//  Copyright © 2018 NDMSystems. All rights reserved.
//

import UIKit

class ProxyCell: UITableViewCell {
  
  
  @IBOutlet private weak var nameLabel: UILabel!
  @IBOutlet private weak var cidLabel: UILabel!
  @IBOutlet private weak var messageLabel: UILabel!
  
  
  func configure(with viewModel: ProxyViewModel) {
    nameLabel.text = viewModel.device.peerInfo?.name ?? viewModel.device.address
    cidLabel.text = viewModel.device.peerInfo?.cid
    messageLabel.text = viewModel.device.peerInfo?.message
  }
  
}
