//
//  Created by Max Desiatov on 04/09/2021.
//

public struct TypeVariable: Hashable {
  let value: String
}

extension TypeVariable: ExpressibleByStringLiteral {
  public init(stringLiteral value: String) {
    self.value = value
  }
}

extension TypeVariable: CustomDebugStringConvertible {
  public var debugDescription: String {
    value
  }
}

extension TypeVariable: ExpressibleByStringInterpolation {
  public init(stringInterpolation: DefaultStringInterpolation) {
    value = stringInterpolation.description
  }
}
