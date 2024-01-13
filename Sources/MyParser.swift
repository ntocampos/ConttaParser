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
    case unexpectedMissingPrice
}

@available(macOS 13.0, *)
@available(iOS 16.0, *)
public class MyParser {
    var text: String
    let priceRegex = /(\d+\s*[,|\.]\s*\d\d?)/
    let nonValidChars = /[^A-Za-z0-9\s]+/
    let whiteSpaceRegex = /[\n\r\s]+/

    public init(_ text: String) {
        self.text = text
    }

    public func parse() throws -> [Product] {
        let totalPriceRanges = findTotalPriceRanges()
        let productRanges = try getProductRanges(totalPriceRanges)
        let cleanProductRanges = removeEmptyRanges(productRanges)

        let products = try cleanProductRanges.map { try buildProduct($0) }

        return products
    }

    private func removeEmptyRanges(_ ranges: [Range<Substring.Index>]) -> [Range<Substring.Index>] {
        var cleanRanges: [Range<Substring.Index>] = []

        var i = 0
        while i < ranges.count - 1 {
            let current = ranges[i], currentText = String(text[current])
            let next = ranges[i + 1], nextText = String(text[next])

            let cleanCurrent = cleanText(currentText.replacing(priceRegex, with: ""))
            let cleanNext = cleanText(nextText.replacing(priceRegex, with: ""))

            if !cleanCurrent.isEmpty && cleanNext.isEmpty {
                cleanRanges.append(current.lowerBound..<next.upperBound)
                i += 2
            } else {
                cleanRanges.append(current)
                i += 1
            }
        }
        if let last = ranges.last, let cleanLast = cleanRanges.last {
            cleanRanges.append(cleanLast.upperBound..<last.upperBound)
        }

        return cleanRanges
    }

    private func cleanText(_ str: String) -> String {
        str
            .replacingOccurrences(of: "[^A-Za-z0-9\\s]+", with: "", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func findTotalPriceRanges() -> [Range<Substring.Index>] {
        text
            .split(separator: "\n")
            .compactMap { $0.ranges(of: priceRegex).last }
    }

    private func getProductRanges(_ totalPriceRanges: [Range<Substring.Index>]) throws -> [Range<Substring.Index>] {
        guard let firstRange = totalPriceRanges.first else {
            throw ProductParsingError.noPricesFound
        }

        var productRanges: [Range<Substring.Index>] = []
        let initialRange = findInitialRange(firstRange: firstRange)
        productRanges.append(initialRange.lowerBound..<firstRange.upperBound)

        for i in 0..<totalPriceRanges.count - 2 {
            let current = totalPriceRanges[i]
            let next = totalPriceRanges[i + 1]
            productRanges.append(current.upperBound..<next.upperBound)
        }

        if let lastPrice = totalPriceRanges.last, let lastProduct = productRanges.last {
            productRanges.append(lastProduct.upperBound..<lastPrice.upperBound)
        }

        return productRanges
    }

    private func findInitialRange(firstRange: Range<String.Index>) -> Range<String.Index> {
        let firstSection = String.Index(utf16Offset: 0, in: text)..<firstRange.lowerBound
        let rangeStart = text[firstSection]
            .replacing(priceRegex, with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lastIndex(of: "\n") ?? String.Index(utf16Offset: 0, in: text)

        return rangeStart..<firstRange.lowerBound
    }

    private func buildProduct(_ range: Range<Substring.Index>) throws -> Product {
        let productText = text[range]
        let name = productText
            .replacing(priceRegex, with: "")
            .replacing(whiteSpaceRegex, with: " ")
            .replacingOccurrences(of: "[^A-Za-z0-9\\s]+", with: "", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        var prices = productText.ranges(of: priceRegex)
            .map { String(productText[$0]) }
            .compactMap { strToDouble($0) }

        guard let total = prices.popLast() else {
            throw ProductParsingError.unexpectedMissingPrice
        }

        let unitPrice = prices.popLast()

        return Product(dirtyName: name, unitPrice: unitPrice, total: total)
    }

    private func strToDouble(_ str: String) -> Double? {
        let parsedStr = str
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: ",", with: ".")
        return Double(parsedStr)
    }
}
