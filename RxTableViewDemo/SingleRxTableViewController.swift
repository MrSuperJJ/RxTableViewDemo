//
//  SingleRxTableViewController.swift
//  RxTableViewDemo
//
//  Created by 叶佳骏 on 2017/9/11.
//  Copyright © 2017年 Mr.JJ. All rights reserved.
//

import UIKit
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
    
    func rxSwiftFunc() {
        var str = "str"
        let label = UILabel(frame: .zero)
        Observable
            .of(str)
            .bind(to: label.rx.text)
            .disposed(by: disposeBag) // label.text = "str"
        str = "changed"               // label.text = "changed"
        
        Observable.of(str).subscribe(onNext: {
            label.text = $0
        }).disposed(by: disposeBag)
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
        // 1.自定义Model，遵循SectionModelType
        struct SectionModel<HeaderType, ItemType>: SectionModelType {
            var header: HeaderType
            var items: [ItemType]
            
            init(header: HeaderType, items: [ItemType]) {
                self.header = header
                self.items = items
            }
            
            init(original: SectionModel<HeaderType, ItemType>, items: [Item]) {
                self.header = original.header
                self.items = items
            }
        }
        // 2.创建DataSource
        let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, Int>>()
        // 3.配置TableViewCell
        dataSource.configureCell = { (section, tableView, indexPath, element) in
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
            cell.textLabel?.text = "row \(element)"
            return cell
        }
        // 4.配置HeaderView(可选)
        dataSource.titleForHeaderInSection = { dataSource, sectionIndex in
            return dataSource[sectionIndex].header
        }
        // 5.将数据绑定到TableView上
        let items = [SectionModel(header: "section 1", items: [1, 2, 3]), SectionModel(header: "section 2", items: [1, 2, 3])]
        Observable.just(items).bind(to: tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
        // 6.TableViewCell点击事件响应
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
