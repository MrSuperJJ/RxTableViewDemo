//
//  SectionModel.swift
//  RxTableViewDemo
//
//  Created by 叶佳骏 on 2018/4/24.
//  Copyright © 2018年 Mr.JJ. All rights reserved.
//

import UIKit
import RxDataSources

struct SectionModel<HeaderType, ItemType>: SectionModelType {
    var header: HeaderType
    var items: [ItemType]
    
    init(header: HeaderType, items: [ItemType]) {
        self.header = header
        self.items = items
    }
    
    init(original: SectionModel<HeaderType, ItemType>, items: [ItemType]) {
        self.header = original.header
        self.items = items
    }
}
