//
//  Created by Max Desiatov on 16/10/2021.
//

import Syntax

enum NormalForm: Equatable {
  case identifier(Identifier)
  // FIXME: use a different closure type separate from the `Syntax` type
  case closure(Closure)
  case literal(Literal)
  indirect case ifThenElse(condition: Identifier, then: NormalForm, else: NormalForm)
  case tuple([NormalForm])
  case structLiteral(Identifier, [Identifier: NormalForm])
  case typeConstructor(TypeIdentifier, [NormalForm])
  indirect case arrow([NormalForm], NormalForm)
}

extension Type {
  func eval(_ environment: DeclEnvironment) -> NormalForm {
    switch self {
    case let .tuple(types):
      return .tuple(types.map { $0.eval(environment) })

    case let .arrow(head, tail):
      return .arrow(head.map { $0.eval(environment) }, tail.eval(environment))

    case let .constructor(id, args):
      return .typeConstructor(id, args.map { $0.eval(environment) })

    case .variable:
      fatalError()
    }
  }
}

extension Expr {
  func eval(_ environment: DeclEnvironment) throws -> NormalForm {
    switch self {
    case let .identifier(i):
      let evaluatedIdentifier = try (
        environment.bindings[i]?.value ??
          environment.functions[i]?.body.flatMap(Expr.block)
      )?.eval(environment)

      return evaluatedIdentifier ?? .identifier(i)

    case let .application(a):
      let arguments = a.arguments.elementsContent

      switch try a.function.content.content.eval(environment) {
      case let .closure(c):
        guard
          let body = c.body?.content.content,
          // FIXME: cache or avoid this inference call
          case let .arrow(typesOfArguments, _) = try Expr.closure(c).infer(environment)
        else {
          return .tuple([])
        }

        var modifiedEnvironment = environment

        let argumentsWithTypes = zip(arguments, typesOfArguments.map { Scheme($0) })
        let parameterIdentifiers: [Identifier] = c.parameters.map(\.identifier.content.content)
        let sequence = Array(zip(parameterIdentifiers, argumentsWithTypes))
        modifiedEnvironment.insert(bindings: sequence)
        return try body.eval(modifiedEnvironment)

      default:
        fatalError()
      }

    case let .closure(c):
      return .closure(c)

    case let .literal(l):
      return .literal(l)

    case let .ifThenElse(i):
      switch try i.condition.content.content.eval(environment) {
      case let .literal(.bool(condition)):
        return try condition ? i.thenBlock.eval(environment) : (
          i.elseBranch?.elseBlock.eval(environment) ?? .tuple([])
        )

      case let .identifier(id):
        return try .ifThenElse(
          condition: id,
          then: i.thenBlock.eval(environment),
          else: i.elseBranch?.elseBlock.eval(environment) ?? .tuple([])
        )

      default:
        fatalError()
      }

    case let .member(m):
      return try m.eval(environment)

    case let .tuple(t):
      return try .tuple(t.elementsContent.map { try $0.eval(environment) })

    case let .block(b):
      return try b.eval(environment)

    case let .structLiteral(s):
      // FIXME: should we get rid of `TypeIdentifier` and use `Identifier` everywhere instead?
      guard case let .typeConstructor(i, _) = s.type.content.content.eval(environment) else {
        fatalError()
      }

      return try .structLiteral(
        Identifier(stringLiteral: i.value),
        .init(
          uniqueKeysWithValues: s.elements.elementsContent.map {
            try ($0.property.content.content, $0.value.content.content.eval(environment))
          }
        )
      )

    case let .type(t):
      return t.eval(environment)

    case .unit:
      return .tuple([])
    }
  }
}

extension ExprBlock {
  func eval(_ environment: DeclEnvironment) throws -> NormalForm {
    var modifiedEnvironment = environment

    for (i, element) in elements.enumerated() {
      switch element.content.content {
      case let .expr(e) where i == elements.count - 1:
        return try e.eval(environment)

      case let .binding(b):
        try modifiedEnvironment.insert(.binding(b))

      default:
        fatalError()
      }
    }

    fatalError()
  }
}

extension MemberAccess {
  func eval(_ environment: DeclEnvironment) throws -> NormalForm {
    let base = try base.content.content.eval(environment)
    switch (base, member.content.content) {
    case let (.tuple(elements), .tupleElement(i)):
      return elements[i]

    case let (.structLiteral(_, args), .identifier(member)):
      return args[member]!

    default:
      fatalError()
    }
  }
}