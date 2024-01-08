//
//  File.swift
//  
//
//  Created by Moisés Neto on 04/01/24.
//

import Foundation

enum ProductParsingError: Error {
    case noPricesFound
    case noProductsFound
}

@available(macOS 13.0, *)
@available(iOS 16.0, *)
public class MyParser {
    var text: String
    let nameRegex = /(.)(.)/
    let priceRegex = /(\d+\s*[,|\.]\s*\d\d?)/
    let whiteSpaceRegex = /[\n\r\s]*/

    public init(_ text: String) {
        self.text = text
    }

    public func parse() throws -> [Product] {
        let anchors = findAnchors()
        guard anchors.count > 0 else { throw ProductParsingError.noPricesFound }

        let dirtyStrings = getStrings(anchors)
        let strings = cleanStrings(dirtyStrings)

        return buildProducts(strings)
    }

    private func findAnchors() -> [Range<String.Index>] {
        text.ranges(of: priceRegex)
    }

    private func getStrings(_ anchors: [Range<String.Index>]) -> [String] {
        let initialRange = findInitialRange(firstRange: anchors[0])
        var ranges = intersperseRanges(ranges: anchors)
        ranges.insert(initialRange, at: 0)

        return ranges.map { String(text[$0]) }
    }

    private func cleanStrings(_ dirty: [String]) -> [String] {
        let regex = Regex(/[^a-zA-Z0-9\s,\.]/)
        return dirty.map { str in
            var newStr = str
            newStr.replace(regex, with: "")
            return String(newStr).trimmingCharacters(in: .whitespacesAndNewlines)
        }.filter {
            !$0.isEmpty
        }
    }

    private func findInitialRange(firstRange: Range<String.Index>) -> Range<String.Index> {
        let firstSection = String.Index(utf16Offset: 0, in: text)..<firstRange.lowerBound
        let rangeStart = text[firstSection].lastIndex(of: "\n") ?? String.Index(utf16Offset: 0, in: text)

        return rangeStart..<firstRange.lowerBound
    }

    private func intersperseRanges(ranges: [Range<String.Index>]) -> [Range<String.Index>] {
        var output: [Range<String.Index>] = []
        guard ranges.count > 0 else { return [] }

        output.append(ranges[0])

        for i in 0..<ranges.count - 1 {
            let current = ranges[i], next = ranges[i + 1]
            output.append(current.upperBound..<next.lowerBound)
            output.append(next)
        }

        return output
    }

    private func buildProducts(_ strings: [String]) -> [Product] {
        var products: [Product] = []

        var tempName = ""
        var tempUnitPrice = ""
        var tempTotal = ""

        for str in strings {
            if isName(str) {
                if let product = buildProduct(name: tempName, unitPriceStr: tempUnitPrice, totalStr: tempTotal) {
                    products.append(product)
                    tempName = ""
                    tempUnitPrice = ""
                    tempTotal = ""
                }
                tempName = str
            } else if isPrice(str) {
                if tempTotal.isEmpty { tempTotal = str }
                else {
                    tempUnitPrice = tempTotal
                    tempTotal = str
                }
            }
        }

        if let product = buildProduct(name: tempName, unitPriceStr: tempUnitPrice, totalStr: tempTotal) {
            products.append(product)
        }

        products.forEach { debugPrint($0) }
        return products
    }

    private func isPrice(_ str: String) -> Bool {
        str.contains(priceRegex)
    }

    private func isName(_ str: String) -> Bool {
        !isPrice(str)
    }

    private func buildProduct(name: String, unitPriceStr: String, totalStr: String) -> Product? {
        guard
            !name.isEmpty,
            !totalStr.isEmpty,
            let total = strToDouble(totalStr)
        else {
            return nil
        }

        let unitPrice = strToDouble(unitPriceStr)
        return Product(dirtyName: name, unitPrice: unitPrice, total: total)
    }

    private func strToDouble(_ str: String) -> Double? {
        let parsedStr = str.replacingOccurrences(of: ",", with: ".")
        return Double(parsedStr)
    }
}
