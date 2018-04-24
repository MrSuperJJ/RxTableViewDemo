//
//  SingleRxTableViewController.swift
//  RxTableViewDemo
//
//  Created by 叶佳骏 on 2017/9/11.
//  Copyright © 2017年 Mr.JJ. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxDataSources

let disposeBag = DisposeBag()

class SingleRxTableViewController: UIViewController {
    
    var type: RxTableViewType = .simplest
    var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // TableView初始化
        tableView = UITableView(frame: self.view.frame)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.view .addSubview(tableView)
        
        switch type {
        case .simplest:
            simplestFuc()
        case .addSections:
            addSectionsFunc()
        default:
            break
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension SingleRxTableViewController {
    
    func simplestFuc() {
        // 1.将数据绑定到TableView上
        let items = Observable.just((0..<30).map({ "\($0)"}))
        items.bind(to: tableView.rx.items(cellIdentifier: "Cell", cellType: UITableViewCell.self)) { (row, element, cell) in
            cell.textLabel?.text = "row \(element)"
            }.disposed(by: disposeBag)
        // 2.TableViewCell点击事件响应
        tableView.rx.modelSelected(String.self).subscribe(onNext: { (item) in
            print(item)    // "1"
        }).disposed(by: disposeBag)
    }
    
    func addSectionsFunc() {
        // 1.创建DataSource
        let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String,Int>>(configureCell: { (section, tableView, indexPath, element) in
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
            cell.textLabel?.text = "row \(element)"
            return cell
        })
        // 2.设置HeaderTitle（可选）
        dataSource.titleForHeaderInSection = { (dataSource, sectionIndex) -> String? in
            return dataSource[sectionIndex].header
        }
        // 3.将数据绑定到TableView上
        let items = [SectionModel(header: "section 1", items: [1, 2, 3]), SectionModel(header: "section 2", items: [1, 2, 3])]
        Observable.just(items).bind(to: tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
        // 4.TableViewCell点击事件响应
        tableView.rx.itemSelected.map {
            return ($0, items[$0.section].header, dataSource[$0])
        }.subscribe(onNext: { indexPath, header, item in
            print("\(header), row \(item)")    // "section 1, row 1"
        }).disposed(by: disposeBag)
//        tableView.rx.modelSelected(Int.self).subscribe(onNext: { (item) in
//            print(item)    // "1"
//        }).disposed(by: disposeBag)
    }
}
