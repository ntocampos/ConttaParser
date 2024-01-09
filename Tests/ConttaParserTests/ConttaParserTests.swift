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
        1 COSMOPOLITAN HAPPY D (19,90)
        """)
        let current = try parser.parse()
        let expected: [Product] = [
            Product(name: "1 PIZZA DOG HAPPY D", unitPrice: 18.9, total: 18.9),
            Product(name: "1 NEGRONI HAPPY D", unitPrice: 19.9, total: 19.9),
            Product(name: "1 Soda Italiana", unitPrice: 16.0, total: 16.0),
            Product(name: "1 MOSCOW MULE HAPPY D", unitPrice: 19.9, total: 19.9),
            Product(name: "1 COSMOPOLITAN HAPPY D", total: 19.9),
        ]

        XCTAssertEqual(current, expected)
    }

    func testRecipeTemplate2() throws {
        let parser = MyParser("""
        DITNA DO FUTURO
        NFERENCIA 935555 DE =====≤===== PRODUTOS
        CUPOM PARA SIMPLES CONFERENCIA **** ==
        Atendente (s): IRAPUAN lesa : 109
        05/10/2023 13:49
        Caixa: 13 Cupon: 29
        VALOR
        PRODUTO QTDE VALOR UN. ======
        CHEESE CAKE 26, 90 53,80
        SHITAKE FLAM 0,01 0, 02
        HARUMAKI COM 0,01 0,01
        MISSO SHIRU 0,01 0,01
        SUCO DE LIMA
        AGUA MINALBA 21,90 19.80
        SUPERSUSHI C 69, 88 209, 00
        TEPPAN YAKIS 69, 88 69, 88
        PEPSI ZERO 10 90 10,90
        a=====
        SUBTOTAL
        SERVICO 385, 96
        38,59
        TOTAL 424,55
        No. DE PESSOAS 1
        TUTAL P/ PESSOA 424,55
        Primeiro Pedido: 12:32 hs
        ** Tempo de Permanencia: 01:17:54 hs AGUARDE A EMISSAO DO CUPOM FISCAL **
        ==================:
        10% DO GARCOM E CORRELATOS OPCIONAL DIGO ======≤===========
        NAO OBRIGATORIO PELOS BONS SERVICOS
        """)

        let current = try parser.parse()
        let expected: [Product] = []

        XCTAssertEqual(current, expected)
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
}
