//
//  Created by Max Desiatov on 16/04/2019.
//

@testable import Syntax
@testable import Types
import XCTest

final class InferenceTests: XCTestCase {
  func testTernary() throws {
    let string = Expr.ternary(
      .literal(true),
      .literal("then"),
      .literal("else")
    )
    let int = Expr.ternary(
      .literal(.bool(false)),
      .literal(0),
      .literal(42)
    )
    let error = Expr.ternary(
      .literal(true),
      .literal("then"),
      .literal(42)
    )

    XCTAssertEqual(try string.infer(), .string)
    XCTAssertEqual(try int.infer(), .int)
    XCTAssertThrowsError(try error.infer())
  }

//  func testLambdaApplication() throws {
//    let lambda = Expr.application(
//      .lambda(
//        .init(
//          identifiers: ["x"],
//          body: .ternary("x", .literal(1), .literal(0))
//        )
//      ),
//      [.literal(true)]
//    )
//
//    let error = Expr.application(
//      .lambda(.init(identifiers: ["x"], body: .ternary("x", .literal(1), .literal(0)))),
//      [.literal("blah")]
//    )
//
//    XCTAssertEqual(try lambda.infer(), .int)
//    XCTAssertThrowsError(try error.infer())
//  }
//
//
//  func testLambdaMember() throws {
//    let lambda = Expr.application(
//      .lambda(
//        .init(identifiers: ["x"], body: .ternary("x", .literal("one"), .literal("zero")))
//      ),
//      [.literal(true)]
//    )
//    let count = Expr.member(lambda, "count")
//    let error = Expr.member(lambda, "magnitude")
//
//    let m: Members = [
//      "String": [
//        "count": [.init(.int)],
//      ],
//      "Int": [
//        "magnitude": [.init(.int)],
//      ],
//    ]
//
//    XCTAssertEqual(try count.infer(members: m), .int)
//    XCTAssertThrowsError(try error.infer(members: m))
//  }

//  func testTupleMember() throws {
//    let tuple = Expr.tuple(.init([.literal(42), .literal("forty two")]))
//
//    XCTAssertEqual(try Expr.member(tuple, "0").infer(), .int)
//    XCTAssertEqual(try Expr.member(tuple, "1").infer(), .string)
//    XCTAssertThrowsError(try Expr.member(tuple, "2").infer())
//  }
//
//  func testNamedTupleMember() throws {
//    let namedTuple = Expr.tuple(.init(elements: [
//      .init(name: "text", expr: .literal("some text")),
//      .init(name: "count", expr: .literal(10)),
//    ]))
//    let tuple = Expr.tuple(.init([.literal("some text"), .literal(10)]))
//    let mixedTuple = Expr.tuple(.init(elements: [
//      .init(name: "text", expr: .literal("some text")),
//      .init(name: nil, expr: .literal(10)),
//    ]))
//    let mixedTuple2 = Expr.tuple(.init(elements: [
//      .init(name: nil, expr: .literal("some text")),
//      .init(name: "count", expr: .literal(10)),
//    ]))
//    let fewArguments = Expr.tuple(.init([.literal("some text")]))
//    let wrongOrder = Expr.tuple(.init([.literal(10), .literal("some text")]))
//
//    let e: Environment = [
//      "acceptNamedTuple": [.init(.namedTuple([
//        ("text", .string),
//        ("count", .int),
//      ]) --> .string)],
//      "acceptTuple": [.init(.namedTuple([
//        (nil, .string),
//        (nil, .int),
//      ]) --> .string)],
//      "acceptMixedTuple": [.init(.namedTuple([
//        ("text", .string),
//        (nil, .int),
//      ]) --> .string)],
//    ]
//
//    XCTAssertEqual(try Expr.member(namedTuple, "text").infer(), .string)
//    XCTAssertEqual(try Expr.member(namedTuple, "count").infer(), .int)
//    XCTAssertThrowsError(try Expr.member(namedTuple, "name").infer())
//
//    XCTAssertEqual(
//      try Expr.application("acceptNamedTuple", [namedTuple])
//        .infer(environment: e),
//      .string
//    )
//    XCTAssertEqual(
//      try Expr.application("acceptNamedTuple", [tuple])
//        .infer(environment: e),
//      .string
//    )
//    XCTAssertEqual(
//      try Expr.application("acceptNamedTuple", [mixedTuple])
//        .infer(environment: e),
//      .string
//    )
//    XCTAssertEqual(
//      try Expr.application("acceptNamedTuple", [mixedTuple2])
//        .infer(environment: e),
//      .string
//    )
//
//    XCTAssertEqual(
//      try Expr.application("acceptTuple", [namedTuple])
//        .infer(environment: e),
//      .string
//    )
//    XCTAssertEqual(
//      try Expr.application("acceptTuple", [tuple])
//        .infer(environment: e),
//      .string
//    )
//    XCTAssertEqual(
//      try Expr.application("acceptTuple", [mixedTuple])
//        .infer(environment: e),
//      .string
//    )
//    XCTAssertEqual(
//      try Expr.application("acceptTuple", [mixedTuple2])
//        .infer(environment: e),
//      .string
//    )
//
//    XCTAssertEqual(
//      try Expr.application("acceptMixedTuple", [namedTuple])
//        .infer(environment: e),
//      .string
//    )
//    XCTAssertEqual(
//      try Expr.application("acceptMixedTuple", [tuple])
//        .infer(environment: e),
//      .string
//    )
//    XCTAssertEqual(
//      try Expr.application("acceptMixedTuple", [mixedTuple])
//        .infer(environment: e),
//      .string
//    )
//    XCTAssertEqual(
//      try Expr.application("acceptMixedTuple", [mixedTuple2])
//        .infer(environment: e),
//      .string
//    )
//
//    XCTAssertThrowsError(
//      try Expr.application("acceptNamedTuple", [fewArguments])
//        .infer(environment: e)
//    )
//    XCTAssertThrowsError(
//      try Expr.application("acceptTuple", [fewArguments])
//        .infer(environment: e)
//    )
//    XCTAssertThrowsError(
//      try Expr.application("acceptMixedTuple", [fewArguments])
//        .infer(environment: e)
//    )
//
//    XCTAssertThrowsError(
//      try Expr.application("acceptNamedTuple", [wrongOrder])
//        .infer(environment: e)
//    )
//    XCTAssertThrowsError(
//      try Expr.application("acceptTuple", [wrongOrder])
//        .infer(environment: e)
//    )
//    XCTAssertThrowsError(
//      try Expr.application("acceptMixedTuple", [wrongOrder])
//        .infer(environment: e)
//    )
//  }
//
//  func testOverload() throws {
//    // FIXME: correctly handle overloads for default arguments, other overloads should be banned
//    let uint = Type.constructor("UInt", [])
//
//    let count = Expr.member(.application("f", []), "count")
//    let magnitude = Expr.member(.application("f", []), "magnitude")
//    let error = Expr.member(
//      .application(
//        "f",
//        [.tuple(
//          .init(
//            [.literal("blah")]
//          )
//        )]
//      ), "count"
//    )
//
//    let m: Members = [
//      "String": [
//        "count": [.init(.int)],
//      ],
//      "Int": [
//        "magnitude": [.init(uint)],
//      ],
//    ]
//    let e: Environment = [
//      "f": [
//        .init([] --> .int),
//        .init([] --> .string),
//      ],
//    ]
//
//    XCTAssertEqual(try count.infer(environment: e, members: m), .int)
//    XCTAssertEqual(try magnitude.infer(environment: e, members: m), uint)
//    XCTAssertThrowsError(try error.infer(environment: e, members: m))
//  }

//  func testNestedOverload() throws {
//    let uint = Type.constructor("UInt", [])
//    let a = Type.constructor("A", [])
//    let b = Type.constructor("B", [])
//
//    let magnitude = Expr.member(
//      .member(.application("f", []), "a"),
//      "magnitude"
//    )
//    let count = Expr.member(
//      .member(.application("f", []), "b"),
//      "count"
//    )
//    let ambiguousCount = Expr.member(
//      .member(.application("f", []), "ambiguous"),
//      "count"
//    )
//    let ambiguousMagnitude = Expr.member(
//      .member(.application("f", []), "ambiguous"),
//      "magnitude"
//    )
//    let ambiguous = Expr.member(.application("f", []), "ambiguous")
//    let error = Expr.member(
//      .member(.application("f", []), "ambiguous"),
//      "ambiguous"
//    )
//
//    let m: Members = [
//      "A": [
//        "a": [.init(.int)],
//        "ambiguous": [.init(.string)],
//      ],
//      "B": [
//        "b": [.init(.string)],
//        "ambiguous": [.init(.int)],
//      ],
//      "String": [
//        "count": [.init(.int)],
//      ],
//      "Int": [
//        "magnitude": [.init(uint)],
//      ],
//    ]
//    let e: Environment = [
//      "f": [
//        .init([] --> a),
//        .init([] --> b),
//      ],
//    ]
//
//    XCTAssertEqual(try count.infer(environment: e, members: m), .int)
//    XCTAssertEqual(try magnitude.infer(environment: e, members: m), uint)
//    XCTAssertEqual(try ambiguousCount.infer(environment: e, members: m), .int)
//    XCTAssertEqual(
//      try ambiguousMagnitude.infer(environment: e, members: m),
//      uint
//    )
//    XCTAssertThrowsError(try ambiguous.infer(environment: e, members: m))
//    XCTAssertThrowsError(try error.infer(environment: e, members: m))
//  }
}
