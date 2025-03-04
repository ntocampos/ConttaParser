//
//  Product.swift
//
//
//  Created by Moisés Neto on 04/01/24.
//

import Foundation

public struct Product: Equatable, Encodable {
    var name: String
    var unitPrice: Double?
    var total: Double
    var amount: Int {
        unitPrice == nil || unitPrice == 0 ? 1 : Int(ceil(total / unitPrice!))
    }
    var lowConfidence: Bool {
        guard let uPrice = unitPrice else { return false }
        return total.remainder(dividingBy: uPrice) != 0
    }
    var finalUnitPrice: Double {
        if let uPrice = unitPrice { return uPrice }
        return total
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(name, forKey: .name)
        try container.encode(amount, forKey: .amount)
        try container.encode(finalUnitPrice, forKey: .unitPrice)
        try container.encode(lowConfidence, forKey: .lowConfidence)
    }

    enum CodingKeys: String, CodingKey {
        case name, amount, unitPrice, lowConfidence
    }
}

extension Product {
    init(dirtyName: String, unitPrice: Double?, total: Double) {
        self.name = dirtyName.replacingOccurrences(of: "\n", with: " ")
        self.unitPrice = unitPrice
        self.total = total
    }
}
