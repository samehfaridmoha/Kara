//
//  Created by Max Desiatov on 14/10/2021.
//

@testable import Driver
@testable import Syntax
@testable import TypeChecker
import XCTest

final class TypeCheckerTests: XCTestCase {
  func testConflictingDeclarations() {
    assertError(
      try driverPass(
        """
        let x: Int = 5
        let x: Bool = false
        """
      ),
      TypeError.bindingDeclAlreadyExists("x")
    )
    assertError(
      try driverPass(
        """
        func f() {}
        func f() -> Int { 5 }
        """
      ),
      TypeError.funcDeclAlreadyExists("f")
    )
    assertError(
      try driverPass(
        """
        struct S {}
        struct S { let a: Int }
        """
      ),
      TypeError.typeDeclAlreadyExists("S")
    )
    assertError(
      try driverPass(
        """
        enum E {}
        enum E { func f() {} }
        """
      ),
      TypeError.typeDeclAlreadyExists("E")
    )
  }
}
