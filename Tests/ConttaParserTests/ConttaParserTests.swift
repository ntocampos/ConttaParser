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
        MESA/CARTÃO/BOX: 0009 (PARCIAL)
        Atendente: MOISES
        Chave..: 011989
        Entrada: 14/12/2023
        20:36
        Saida..:
        14/12/2023 21:36
        Tempo. •
        59min
        DESCRICAO QTDE
        COPO LIMONADA
        1
        1222
        TOTAL
        -+2822
        300 ML
        12,00
        PR. UNI
        LIBANESA
        12,00
        ESFIRAS (UN) SEM CARNE
        12,50
        ESFIRAS COM CARNE (UN)
        12,50
        12,50
        3
        KAFTAS BOVINA
        1
        26,00
        KIBE (UN)
        1
        12,50
        REFRIGERANTE COCA
        2
        7,90
        REFRIGERANTE
        COCA
        1
        ZERO
        7,90
        SHAWARMAS BOVINA
        2
        32,00
        TABUA RIHAN
        1
        38,00
        Valor Total
        Pedido:
        Taxa de Servico..
        Valor a Pagar:
        Pessoas na Mesa:
        Valor Por Pessoa:
        EM VALOR
        37,50
        26,00
        12,50
        15,80
        7,90
        64,00
        38,00
        226,20
        22,62(*)
        248, 82
        004
        62,21
        """)

        let current = try parser.parse()
        let expected: [Product] = [
            Product(name: "PR. UNI LIBANESA", unitPrice: Optional(12.0), total: 12.0),
            Product(name: "ESFIRAS UN SEM CARNE", unitPrice: nil, total: 12.5),
            Product(name: "ESFIRAS COM CARNE UN", unitPrice: Optional(12.5), total: 12.5),
            Product(name: "3 KAFTAS BOVINA 1", unitPrice: nil, total: 26.0),
            Product(name: "KIBE UN 1", unitPrice: nil, total: 12.5),
            Product(name: "REFRIGERANTE COCA 2", unitPrice: nil, total: 7.9),
            Product(name: "REFRIGERANTE COCA 1 ZERO", unitPrice: nil, total: 7.9),
            Product(name: "SHAWARMAS BOVINA 2", unitPrice: nil, total: 32.0),
            Product(name: "TABUA RIHAN 1", unitPrice: nil, total: 38.0),
            Product(name: "Valor Total Pedido Taxa de Servico.. Valor a Pagar Pessoas na Mesa Valor Por Pessoa EM VALOR", unitPrice: Optional(226.2), total: 22.62),
            Product(name: "248, 82 004", unitPrice: nil, total: 62.21)
        ]

        XCTAssertEqual(current, expected)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
}
