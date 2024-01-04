//
//  Product.swift
//
//
//  Created by Moisés Neto on 04/01/24.
//

import Foundation

public struct Product: Equatable {
    var name: String
    var unitPrice: Double?
    var total: Double
    var amount: Int {
        unitPrice != nil ? Int(total / unitPrice!) : Int(total)
    }
}

extension Product {
    init(dirtyName: String, unitPrice: Double?, total: Double) {
        self.name = dirtyName.replacingOccurrences(of: "\n", with: " ")
        self.unitPrice = unitPrice
        self.total = total
    }
}
