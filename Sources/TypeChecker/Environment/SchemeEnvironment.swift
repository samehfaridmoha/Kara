//
//  Created by Max Desiatov on 25/10/2021.
//

import Syntax

/// Environment that maps available identifiers to their `Scheme` signatures together with optional definitions.
struct SchemeEnvironment {
  typealias Bindings = [Identifier: (value: Expr<EmptyAnnotation>?, scheme: Scheme)]
  typealias Functions = [Identifier: (parameters: [Identifier], body: ExprBlock<EmptyAnnotation>?, scheme: Scheme)]

  init(bindings: Bindings = .init(), functions: Functions = .init()) {
    self.bindings = bindings
    self.functions = functions
  }

  private(set) var bindings: Bindings
  private(set) var functions: Functions

  mutating func insert(_ b: BindingDecl<EmptyAnnotation>, _ topLevel: ModuleEnvironment) throws {
    let identifier = b.identifier.content.content
    guard let scheme = try b.scheme(topLevel) else {
      throw TypeError.topLevelAnnotationMissing(identifier)
    }

    guard bindings[identifier] == nil else {
      throw TypeError.bindingDeclAlreadyExists(identifier)
    }

    bindings[identifier] = (b.value?.expr.content.content, scheme)
  }

  mutating func insert(_ f: FuncDecl<EmptyAnnotation>, _ topLevel: ModuleEnvironment) throws {
    let identifier = f.identifier.content.content
    guard functions[identifier] == nil else {
      throw TypeError.funcDeclAlreadyExists(identifier)
    }

    functions[identifier] = try (
      f.parameters.elementsContent.map(\.internalName.content.content),
      f.body,
      f.scheme(topLevel)
    )
  }

  mutating func insert<T>(bindings sequence: T) where T: Sequence,
    T.Element == (Identifier, (Expr<EmptyAnnotation>?, Scheme))
  {
    for (id, (value, scheme)) in sequence {
      bindings[id] = (value, scheme)
    }
  }
}