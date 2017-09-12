//
//  MultipleRxTableViewController.swift
//  RxTableViewDemo
//
//  Created by 叶佳骏 on 2017/9/12.
//  Copyright © 2017年 Mr.JJ. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources

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

class MultipleRxTableViewController: UIViewController {
    
    var type: RxTableViewType = .updateAll

    var tableViews = [UITableView]()
    var items = [SectionModel(header: "section 1", items: [1, 2, 3])]
    var variable: Variable<[SectionModel<String, Int>]>!
    let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, Int>>()
    
    var variables = [Variable<[SectionModel<String, Int>]>]()
    var dataSources = [RxTableViewSectionedReloadDataSource<SectionModel<String, Int>>]()
    var random =  Variable(0)
    var tableViewDispose: Disposable?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.title = "RxTableView"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "update", style: .plain, target: self, action: #selector(MultipleRxTableViewController.update))
        
        let frames = [CGRect(x: 0, y: 0, width: self.view.frame.width / 3, height: self.view.frame.height), CGRect(x: self.view.frame.width / 3, y: 64, width: self.view.frame.width / 3, height: self.view.frame.height), CGRect(x: self.view.frame.width / 3 * 2, y: 64, width: self.view.frame.width / 3, height: self.view.frame.height)]
        frames.forEach {
            let tableView = UITableView(frame: $0)
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
            self.view.addSubview(tableView)
            tableViews += [tableView]
        }
        
        addSectionsFunc()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension MultipleRxTableViewController {
    
    func addSectionsFunc() {
        switch type {
        case .updateAll:
            bindWithVariable()
        case .updateOne:
            bindWithVariables()
        default:
            break
        }
    }
    
    func bindWithVariable() {
        dataSource.configureCell = { (section, tableView, indexPath, element) in
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
            cell.textLabel?.text = "\(element)"
            return cell
        }
        dataSource.titleForHeaderInSection = { dataSource, sectionIndex in
            return dataSource[sectionIndex].header
        }
        variable = Variable(items)
        tableViews.forEach {
            variable.asObservable().bind(to: $0.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
        }
        tableViews.forEach {
            $0.rx.itemSelected.map { [unowned self] in
                return ($0, self.items[$0.section].header, self.dataSource[$0])
                }.subscribe(onNext: { indexPath, header, item in
                    print("\(header), row \(item)")    // "section 1, row 1"
                }).disposed(by: disposeBag)
        }
    }
    
    func bindWithVariables() {
        for _ in tableViews {
            dataSources += [RxTableViewSectionedReloadDataSource<SectionModel<String, Int>>()]
            variables += [Variable([])]
        }
        dataSources.forEach {
            $0.configureCell = { (section, tableView, indexPath, element) in
                let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
                cell.textLabel?.text = "\(element)"
                return cell
            }
            $0.titleForHeaderInSection = { dataSource, sectionIndex in
                return dataSource[sectionIndex].header
            }
        }
        for (index, tableView) in tableViews.enumerated() {
            variables[index].asObservable().debug().bind(to: tableView.rx.items(dataSource: dataSources[index])).disposed(by: disposeBag)
            tableView.rx.itemSelected.map { [unowned self] in
                return ($0, self.items[$0.section].header, self.dataSources[index][$0])
                }.subscribe(onNext: { indexPath, header, item in
                    print("\(header), row \(item)")    // "section 1, row 1"
                }).disposed(by: disposeBag)
        }
        
        random.asObservable().subscribe(onNext: { [unowned self] in
            self.variables[$0].value = self.items
        }).disposed(by: disposeBag)
    }
    
    func bindWithVariableArray1() {
        variable = Variable(items)
        tableViews.forEach {
            tableViewDispose = variable.asObservable().debug().bind(to: $0.rx.items(dataSource: dataSource))
        }
    }
}

extension MultipleRxTableViewController {
    
    func update() {
        items[0].items = (0...Int.random(1, 10)).map({ $0 })    // 重新生成数据
        switch type {
        case .updateAll:
            updateAll()
        case .updateOne:
            updateOne()
        default:
            break
        }
    }
    // 刷新所有TableView
    func updateAll() {
        variable.value = items
    }
    // 随机刷新一个TableView
    func updateOne() {
        random.value = Int.random(0, 2)
    }
    
    func updateOne1() {
        tableViewDispose?.dispose()
        let index = Int.random(0, 2)
//        tableViewDispose = variable.asObservable().bind(to: tableViews[index].rx.items(dataSource: dataSource))
    }
}

// MARK: - 生成随机整数
public extension Int {
    
    /// 生成Int型随机数
    ///
    /// - Parameters:
    ///   - lower: min
    ///   - upper: max
    /// - Returns: 随机数
    public static func random(_ lower: Int = 0, _ upper: Int = Int.max) -> Int {
        return lower + Int(arc4random_uniform(UInt32(upper - lower + 1)))
    }
    
    /// 生成Int型随机数
    ///
    /// - Parameter range: [min, max]
    /// - Returns: 随机数
    public static func random(_ range: CountableClosedRange<Int>) -> Int {
        return random(range.lowerBound, range.upperBound)
    }
}

