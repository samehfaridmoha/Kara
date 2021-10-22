//
//  Created by Max Desiatov on 22/08/2021.
//

import Parsing

public struct FuncApplication {
  public let function: SyntaxNode<Expr>
  public let arguments: DelimitedSequence<Expr>
}

let applicationArgumentsParser =
  delimitedSequenceParser(
    startParser: openParenParser,
    endParser: closeParenParser,
    separatorParser: commaParser,
    elementParser: Lazy { exprParser }
  )
  .map(ExprSyntaxTail.applicationArguments)
