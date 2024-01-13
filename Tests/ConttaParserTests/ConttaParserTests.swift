import XCTest
@testable import ConttaParser

final class ConttaParserTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testRecipeTemplate1() throws {
        let parser = MyParser("""
        CONTA DE CONSUMO
        1 PIZZA DOG HAPPY D (18,90)
        18,90
        1 NEGRONI HAPPY D (19,90)
        19,90
        1 Soda Italiana (16,00)
        16,00
        1 MOSCOW MULE HAPPY D (19,90)
        19,90
        1 COSMOPOLITAN HAPPY D (29,90)
        """)
        let current = try parser.parse()
        let expected: [Product] = [
            Product(name: "1 PIZZA DOG HAPPY D", unitPrice: 18.9, total: 18.9),
            Product(name: "1 NEGRONI HAPPY D", unitPrice: 19.9, total: 19.9),
            Product(name: "1 Soda Italiana", unitPrice: 16.0, total: 16.0),
            Product(name: "1 MOSCOW MULE HAPPY D", unitPrice: 19.9, total: 19.9),
            Product(name: "1 COSMOPOLITAN HAPPY D", total: 29.9),
        ]

        assertListsAreEqual(current, expected)
    }

    func testRecipeTemplate2() throws {
        let parser = MyParser("""
        RELATORIO DE CONSUMO
        CODIGO DESCRICAD PRECO QTD TOTAL
        000134 HEINEKEN LONG NECK (ESTAO NA MESA 15
        13,00 001 13,00
        000060 GIN TONICA 18,00 001 18.00
        000134 HEINEKEN LONG NECK 13,00 003 39,00
        000045 BAMBOO 24,00 001 24,00
        000073 JACK FIRE E GINGER 24,00 001 24,00
        000063 MOSCOW MULE 26,00 002 52,00
        000025 CHORI LOA 17,90 002 35.80
        000027 CHORI MIRANDA 18,90 001 18,90
        PRODUTOS R$ 224,70
        COMISSAO R$ 22,47
        TOTAL R$ 247,17
        """)

        let current = try parser.parse()
        let expected: [Product] = [
            Product(name: "001", unitPrice: 13.0, total: 13.0),
            Product(name: "000060 GIN TONICA 001", unitPrice: 18.0, total: 18.0),
            Product(name: "000134 HEINEKEN LONG NECK 003", unitPrice: 13.0, total: 39.0),
            Product(name: "000045 BAMBOO 001", unitPrice: 24.0, total: 24.0),
            Product(name: "000073 JACK FIRE E GINGER 001", unitPrice: 24.0, total: 24.0),
            Product(name: "000063 MOSCOW MULE 002", unitPrice: 26.0, total: 52.0),
            Product(name: "000025 CHORI LOA 002", unitPrice: 17.9, total: 35.8),
            Product(name: "000027 CHORI MIRANDA 001", unitPrice: 18.9, total: 18.9),
            Product(name: "PRODUTOS R", total: 224.7),
            Product(name: "COMISSAO R", total: 22.47),
            Product(name: "TOTAL R", total: 247.17)
        ]

        assertListsAreEqual(current, expected)
    }

    func testRecipeTemplate3() throws {
        let parser = MyParser("""
        RELATORIO DE CONSUMO
        CODIGO DESCRICAD PRECO QTD TOTAL
        PRODUTO 1
        10,00 30,00
        PRODUTO 2
        UND x 2 10,00 20,00
        PRODUTO 3
        UND x 1 10,00 10,00
        """)

        let current = try parser.parse()
        let expected: [Product] = [
            Product(name: "PRODUTO 1", unitPrice: 10, total: 30),
            Product(name: "PRODUTO 2 UND x 2", unitPrice: 10, total: 20),
            Product(name: "PRODUTO 3 UND x 1", unitPrice: 10, total: 10),
        ]

        assertListsAreEqual(current, expected)
    }

    func testJSONEncoding() throws {
        let products = [
            Product(name: "1 PIZZA DOG HAPPY D", unitPrice: 18.9, total: 18.9),
            Product(name: "1 NEGRONI HAPPY D", unitPrice: 19.9, total: 39.9),
            Product(name: "1 Soda Italiana", unitPrice: 16.0, total: 32.0),
            Product(name: "1 MOSCOW MULE HAPPY D", unitPrice: 19.9, total: 19.9),
            Product(name: "1 COSMOPOLITAN HAPPY D", total: 19.9),
        ]

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let encoded = try? encoder.encode(products)
        let current = String(data: encoded!, encoding: .utf8)
        let expected = """
        [
          {
            "amount" : 1,
            "lowConfidence" : false,
            "name" : "1 PIZZA DOG HAPPY D",
            "unitPrice" : 18.9
          },
          {
            "amount" : 2,
            "lowConfidence" : true,
            "name" : "1 NEGRONI HAPPY D",
            "unitPrice" : 19.9
          },
          {
            "amount" : 2,
            "lowConfidence" : false,
            "name" : "1 Soda Italiana",
            "unitPrice" : 16
          },
          {
            "amount" : 1,
            "lowConfidence" : false,
            "name" : "1 MOSCOW MULE HAPPY D",
            "unitPrice" : 19.9
          },
          {
            "amount" : 1,
            "lowConfidence" : false,
            "name" : "1 COSMOPOLITAN HAPPY D",
            "unitPrice" : 19.9
          }
        ]
        """

        XCTAssertEqual(current!, expected)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

    func assertListsAreEqual<T: Equatable>(_ list1: [T], _ list2: [T]) {
        XCTAssertEqual(list1.count, list2.count)
        zip(list1, list2).forEach { (elem1, elem2) in
            XCTAssertEqual(elem1, elem2)
        }
    }
}
