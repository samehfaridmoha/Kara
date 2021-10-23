//
//  Created by Max Desiatov on 11/08/2021.
//

import CustomDump
import Parsing
import SnapshotTesting
@testable import Syntax
import XCTest

final class ParserTests: XCTestCase {
  func testNewline() {
    XCTAssertNil(newlineParser.parse("").output)
    XCTAssertNil(newlineParser.parse("foo").output)
    let parser = newlineParser.map { Substring($0.content) }
    XCTAssertEqual(parser.parse("\n").output, "\n")
    XCTAssertEqual(parser.parse("\r\n").output, "\r\n")
  }

  func testLiterals() throws {
    XCTAssertNoDifference(literalParser.parse("123"), 123)
    XCTAssertNoDifference(literalParser.parse("true"), true)
    XCTAssertNoDifference(literalParser.parse("false"), false)
    XCTAssertNoDifference(literalParser.parse(#""string""#), "string")
    XCTAssertNoDifference(literalParser.parse("3.14"), 3.14)
  }

  func testStructDecl() throws {
    assertSnapshot(structParser.parse("struct Foo {}"))
    assertSnapshot(structParser.parse("struct  Bar{}"))

    assertSnapshot(structParser.parse("""
    struct
    Baz
    {
    }
    """))

    assertSnapshot(structParser.parse("""
    struct Foo
    {
      struct Bar {}
    }
    """))

    XCTAssertNil(structParser.parse("structBlorg{}").output)

    assertSnapshot(structParser.parse("""
    struct StoredProperties {
      let a: Int    // `a` comment
      let b: Bool   // `b` comment
      let c: String // `c` comment
    }
    """))

    assertSnapshot(structParser.parse("""
    struct StoredProperties {
      struct Inner1 {
        let a: Double
      }
      let a: Int    // `a` comment
      let b: Bool   // `b` comment
      let c: String // `c` comment

      struct Inner2 {
        let a: Float
      }

      let inner1: Inner1
      let inner2: Inner2
    }
    """))
  }

  func testIdentifiers() {
    XCTAssertNil(identifierParser().parse("123abc").output)
    assertSnapshot(identifierParser().parse("abc123"))
    XCTAssertNil(identifierParser(requiresLeadingTrivia: true).parse("abc123").output)
    assertSnapshot(identifierParser().parse("_abc123"))
    assertSnapshot(identifierParser().parse("/* hello! */abc123"))
    assertSnapshot(
      identifierParser().parse(
        """
        // test
        _abc123
        """
      )
    )
  }

  func testTuple() {
    XCTAssertNil(exprParser.parse("(,)").output)
    assertSnapshot(exprParser.parse("()"))
    assertSnapshot(exprParser.parse("(1 ,2 ,3 ,)"))
    assertSnapshot(exprParser.parse("(1,2,3,)"))
    assertSnapshot(exprParser.parse("(1,2,3)"))

    assertSnapshot(exprParser.parse("(1)"))
    assertSnapshot(exprParser.parse(#"("foo")"#))

    assertSnapshot(exprParser.parse(#"("foo", ("bar", "baz"))"#))
    assertSnapshot(exprParser.parse(#"("foo", ("bar", "baz", (1, "fizz")))"#))

    XCTAssertNil(exprParser.parse(#"("foo", ("bar", "baz", (1, "fizz"))"#).output)

    XCTAssertNil(exprParser.parse(#"("foo", ("bar")"#).output)
  }

  func testIfThenElse() {
    assertSnapshot(exprParser.parse(#"if true { "true" } else { "false" }"#))
    assertSnapshot(exprParser.parse(#"if foo { bar } else { baz }"#))
    assertSnapshot(
      exprParser.parse(
        #"""
        if 42.isInteger {
          "is integer"
        } else {
          "is not integer"
        }
        """#
      )
    )
    assertSnapshot(
      exprParser.parse(
        #"""
        if 42.isInteger() {
          "is integer"
        } else {
          "is not integer"
        }
        """#
      )
    )
  }

  func testClosure() {
    assertSnapshot(exprParser.parse("{}"))
    assertSnapshot(exprParser.parse("{ 1 }"))
    assertSnapshot(exprParser.parse("{1}"))
    assertSnapshot(exprParser.parse("{ x in 1 }"))
    assertSnapshot(exprParser.parse("{x in 1}"))
    assertSnapshot(exprParser.parse("{xin1}"))

    assertSnapshot(exprParser.parse("{ x, y, z in 1 }"))
    assertSnapshot(exprParser.parse("{ x,y,z in 1 }"))
    assertSnapshot(exprParser.parse("{x,y,z in 1}"))
    assertSnapshot(
      exprParser.parse(
        """
        {x,y,z in
            let a = sum(x, y, z)
            a
        }
        """
      )
    )

    XCTAssertNil(exprParser.parse("{ x in y in 1 }").output)
    XCTAssertNil(exprParser.parse("{x in1}").output)
  }

  func testMemberAccess() {
    assertSnapshot(exprParser.parse("5.description"))
    assertSnapshot(exprParser.parse("5  .description"))
    assertSnapshot(
      exprParser.parse(
        """
        5
        .description
        """
      )
    )

    assertSnapshot(exprParser.parse("{x,y,z in 1}.description"))
    assertSnapshot(exprParser.parse("{x,y,z in 1}.description.description"))
    assertSnapshot(exprParser.parse("( 1 , 2, 3 ).description"))
    assertSnapshot(exprParser.parse("( 1, 2, 3 ).description"))
  }

  func testTupleMembers() {
    assertSnapshot(exprParser.parse("a.1"))
    assertSnapshot(exprParser.parse("f().42"))
  }

  func testApplication() {
    assertSnapshot(exprParser.parse("{x,y,z in x}(1,2,3)"))
    assertSnapshot(exprParser.parse("{x,y,z in x} ( 1 , 2, 3 )"))
    assertSnapshot(exprParser.parse("{x,y,z in x} ( 1 , 2, 3 ).description"))
  }

  func testTypeExpr() {
    assertSnapshot(exprParser.parse("Array"))
    assertSnapshot(exprParser.parse("Int32"))
  }

  func testStructLiteral() {
    assertSnapshot(exprParser.parse(#"S [a: 5, b: true, c: "c"]"#))
    assertSnapshot(exprParser.parse(#"S []"#))
    assertSnapshot(exprParser.parse(#"S[]"#))
  }

  func testFuncDecl() {
    assertSnapshot(funcDeclParser.parse("func f(x: Int) -> Int { x }"))
    assertSnapshot(funcDeclParser.parse(#"func f(x y: Bool) -> String { if y { "x" } else { "not x" } }"#))
    assertSnapshot(funcDeclParser.parse("private func f(x: Int) -> Int { x }"))
    assertSnapshot(funcDeclParser.parse(#"public func f(x y: Bool) -> String { if y { "x" } else { "not x" } }"#))
    assertSnapshot(funcDeclParser.parse("private public func f(x: Int) -> Int { x }"))
    assertSnapshot(
      funcDeclParser.parse(#"interop(JS, "fff") func f(x y: Bool) -> String"#)
    )
    assertSnapshot(
      funcDeclParser.parse(
        #"public interop(JS, "fff") func f(x y: Bool) -> String"#
      )
    )
    assertSnapshot(
      funcDeclParser.parse(
        """
        func f(x: Int) -> Int {
          struct S {}
          x
        }
        """
      )
    )
  }

  func testModuleFile() {
    assertSnapshot(
      moduleFileParser.parse(
        """
        struct String {}

        func f(condition: Bool) -> String {
          if condition {
            "true"
          } else {
            "false"
          }
        }
        """
      )
    )

    assertSnapshot(
      moduleFileParser.parse(
        """
        enum Bool {}

        func f(condition: Bool) -> Int { 42 }
        """
      )
    )
  }
}
