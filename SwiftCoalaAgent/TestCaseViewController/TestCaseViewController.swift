//
//  TestCaseViewController.swift
//  SwiftCoalaAgent
//
//  Created by Pavel Shatalov on 03.07.2018.
//  Copyright © 2018 NDMSystems. All rights reserved.
//

import UIKit

class TestCaseViewController: UITableViewController {
  
  private let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)

  private func showInfoTest() {
    let model = LocalDevicesModel()
    let vc = mainStoryboard.instantiateViewController(withIdentifier: "LocalDeviceViewController") as! LocalDeviceViewController
    vc.model = model
    navigationController?.pushViewController(vc, animated: true)
  }
  
  private func showArqTest(arqType: ArqType) {
    let model = ArqModel(with: arqType)
    let vc = mainStoryboard.instantiateViewController(withIdentifier: "ArqViewController") as! ArqViewController
    vc.model = model
    navigationController?.pushViewController(vc, animated: true)
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    switch indexPath.row {
    case 0: showInfoTest()
    case 1: showArqTest(arqType: .upload)
    case 2: showArqTest(arqType: .download)
    default: break
    }
  }
}
