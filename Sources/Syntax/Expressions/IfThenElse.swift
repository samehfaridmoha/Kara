//
//  Created by Max Desiatov on 04/09/2021.
//

import Parsing

public struct IfThenElse {
  public let ifKeyword: SyntaxNode<()>
  public let condition: SyntaxNode<Expr>
  public let thenBlock: ExprBlock

  // FIXME: handle multiple `else if` branches
  public let elseBranch: ElseBranch?
}

public struct ElseBranch {
  public let elseKeyword: SyntaxNode<()>
  public let elseBlock: ExprBlock
}

private let elseBranchParser = SyntaxNodeParser(Terminal("else"))
  .take(Lazy { exprBlockParser })
  .map {
    ElseBranch(
      elseKeyword: $0,
      elseBlock: $1
    )
  }

let ifThenElseParser = SyntaxNodeParser(Terminal("if"))
  .take(Lazy { exprParser })
  .take(Lazy { exprBlockParser })
  .take(Optional.parser(of: elseBranchParser))
  .map { tuple -> SyntaxNode<IfThenElse> in
    let (ifKeyword, condition, thenBlock, elseBranch) = tuple
    return SyntaxNode(
      leadingTrivia: ifKeyword.leadingTrivia,
      content: SourceRange(
        start: ifKeyword.content.start,
        end: elseBranch?.elseBlock.closeBrace.content.end ?? thenBlock.closeBrace.content.end,
        content: IfThenElse(
          ifKeyword: ifKeyword,
          condition: condition,
          thenBlock: thenBlock,
          elseBranch: elseBranch
        )
      )
    )
  }
