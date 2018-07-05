//
//  LogView.swift
//  SwiftCoalaAgent
//
//  Created by Pavel Shatalov on 02.07.2018.
//  Copyright © 2018 NDMSystems. All rights reserved.
//

import UIKit
import Coala

class LogView: UIView {

  func add(log: CoalaLog) {
    logs.append(log)
    logs = logs.sorted(by: { $0.timestamp < $1.timestamp })
    DispatchQueue.main.async { [weak self] in
      self?.tableView.reloadData()
    }
  }

  private var buttonStackView: UIStackView!
  private var tableView: UITableView!
  private var logs = [CoalaLog]()


  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUi()
  }


  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    configureUi()
  }


  func configureUi() {
    buttonStackView = UIStackView(frame: .zero)
    buttonStackView.translatesAutoresizingMaskIntoConstraints = false
    buttonStackView.alignment = .fill
    buttonStackView.distribution = .equalSpacing
    buttonStackView.axis = .horizontal
    addSubview(buttonStackView)

    let clearLogButton = UIButton(frame: .zero)
    clearLogButton.setTitle("Clear log", for: .normal)
    clearLogButton.setTitleColor(.red, for: .normal)
    clearLogButton.addTarget(self, action: #selector(clearLog(sender:)), for: .touchUpInside)
    buttonStackView.addArrangedSubview(clearLogButton)

    let copyLogButton = UIButton(frame: .zero)
    copyLogButton.setTitle("Copy log", for: .normal)
    copyLogButton.setTitleColor(.green, for: .normal)
    copyLogButton.addTarget(self, action: #selector(copyLog(sender:)), for: .touchUpInside)
    buttonStackView.addArrangedSubview(copyLogButton)

    tableView = UITableView(frame: .zero, style: .plain)
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 150.0
    tableView.translatesAutoresizingMaskIntoConstraints = false
    tableView.allowsSelection = false
    tableView.tableFooterView = UIView()
    addSubview(tableView)

    NSLayoutConstraint.activate([
      buttonStackView.heightAnchor.constraint(equalToConstant: 40.0),
      buttonStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.0),
      buttonStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.0),
      buttonStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
      tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
      tableView.topAnchor.constraint(equalTo: topAnchor),
      tableView.bottomAnchor.constraint(equalTo: clearLogButton.topAnchor)
    ])
    tableView.register(UINib(nibName: "LogCell", bundle: nil), forCellReuseIdentifier: "LogCell")
    tableView.delegate = self
    tableView.dataSource = self
  }

  @objc private func clearLog(sender: UIButton) {
    logs.removeAll()
    tableView.reloadData()
  }

  @objc private func copyLog(sender: UIButton) {
    let str = logs.map { $0.message }
    UIPasteboard.general.string = str.description
  }

  
}

extension LogView: UITableViewDelegate, UITableViewDataSource {

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return logs.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "LogCell") as! LogCell
    let log = logs[indexPath.row]
    cell.configure(with: log)
    return cell
  }
  
}
