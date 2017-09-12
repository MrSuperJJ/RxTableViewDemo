//
//  MainTableViewController.swift
//  RxTableViewDemo
//
//  Created by 叶佳骏 on 2017/9/11.
//  Copyright © 2017年 Mr.JJ. All rights reserved.
//

import UIKit

enum RxTableViewType: Int {
    case simplest
    case addSections
    case updateAll
    case updateOne
}

/// Simplest UITableView
class MainTableViewController: UITableViewController {
    
    let items = ["1. SimpleRxTableView",
                 "2. SimpleRxTableView + Sections",
                 "3. MultipleRxTableView + UpdateAll",
                 "4. MultipleRxTableView + UpdateOne"]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.title = "RxTableView"
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
    }

    // MARK: - UITableViewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1    // Section的数量
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count    // Section中Row的数量
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) // TableViewCell绘制
        cell.textLabel?.text = items[indexPath.row]
        return cell
    }
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)    // TableViewCell点击事件
        let viewController: UIViewController
        switch indexPath.row {
        case 0...1:
            viewController = SingleRxTableViewController()
            (viewController as! SingleRxTableViewController).type = RxTableViewType(rawValue: indexPath.row)!
        case 2...3:
            viewController = MultipleRxTableViewController()
            (viewController as! MultipleRxTableViewController).type = RxTableViewType(rawValue: indexPath.row)!
        default:
            viewController = UIViewController()
        }
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40    // TableViewCell高度
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
