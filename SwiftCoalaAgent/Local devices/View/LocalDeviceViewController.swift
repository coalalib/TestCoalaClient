//
//  ViewController.swift
//  SwiftCoalaAgent
//
//  Created by Pavel Shatalov on 29.06.2018.
//  Copyright © 2018 NDMSystems. All rights reserved.
//

import UIKit
import Coala

class LocalDeviceViewController: UIViewController {

  enum State {
  case didReceiveDeviceInfo(LocalDeviceViewModel)
  case didFoundDevices([LocalDeviceViewModel])
  }
  
  private var devices = [LocalDeviceViewModel]() {
    didSet {
      showSearchButton()
      tableView.beginUpdates()
      tableView.reloadSections([0], with: .automatic)
      tableView.endUpdates()
    }
  }
  
  private var searchButton: UIBarButtonItem!
  @IBOutlet private weak var logView: LogView!
  @IBOutlet private weak var tableView: UITableView!
  var model: LocalDevicesModel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupTableView()
    showSearchButton()
    model.coalaAgent.didReceiveLog = { [weak self] log in
      self?.logView.add(log: log)
    }
    model.viewNotificationBlock = { [weak self] state in
      self?.populateUi(with: state)
    }
    title = "Simple /info request"

    
  }
  
  private func populateUi(with state: State) {
    switch state {
    case .didReceiveDeviceInfo(let deviceInfo):
      var devices = self.devices
      if let index = devices.index(where: {$0.address == deviceInfo.address}) {
        devices.remove(at: index)
        devices.insert(deviceInfo, at: index)
        self.devices = devices
        
      }
    case .didFoundDevices(let devices):
      self.devices = devices
    }
  }
  
  private func setupTableView() {
    tableView.dataSource = self
    tableView.delegate = self
    tableView.setContentInsetAdjustment(enabled: false, in: self)
  }
  
  private func showSearchSpinner() {
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    spinner.hidesWhenStopped = true
    navigationItem.rightBarButtonItem = UIBarButtonItem(customView: spinner)
    spinner.startAnimating()
  }

  func showSearchButton() {
    let searchButton = UIBarButtonItem(title: "Search", style: .plain, target: self, action: #selector(searchAction(sender:)))
    navigationItem.rightBarButtonItem = searchButton

  }
  
  
  @objc private func searchAction(sender: UIBarButtonItem) {
    showSearchSpinner()
    model.startSearch()
  }
  
  @IBAction func schemeChanged(_ sender: Any) {
    guard let segmentedControl = sender as? UISegmentedControl else {
      return
    }
    model.scheme = segmentedControl.selectedSegmentIndex == 0 ? .coaps : .coap
  }
  
}

extension LocalDeviceViewController: UITableViewDelegate, UITableViewDataSource {


  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return devices.count
  }


  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "LocalDeviceCell") as! LocalDeviceCell
    let viewModel = devices[indexPath.row]
    cell.configure(with: viewModel)
    return cell
  }


  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 100.0
  }
  
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let device = devices[indexPath.row]
    model.getInfo(for: device)
    tableView.deselectRow(at: indexPath, animated: true)
  }

}

//extension LocalDeviceViewController: CoalaLogable {
//
//  func didReceive(log: CoalaLog) {
//    logView.add(log: log)
//  }
//
//}

extension UIScrollView {
  func setContentInsetAdjustment(enabled: Bool, in viewController: UIViewController) {
    #if swift(>=3.2)
    if #available(iOS 11.0, *) {
      self.contentInsetAdjustmentBehavior = enabled ? .always : .never
    } else {
      viewController.automaticallyAdjustsScrollViewInsets = enabled
    }
    #else
    viewController.automaticallyAdjustsScrollViewInsets = enabled
    #endif
  }
}

