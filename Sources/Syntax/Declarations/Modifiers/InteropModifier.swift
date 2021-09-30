//
//  Created by Max Desiatov on 21/09/2021.
//

public struct InteropModifier {
  public enum Language: String {
    case js = "JS"
    case c = "C"
    case swift = "Swift"
  }

  let interopKeyword: SyntaxNode<()>
  let openParen: SyntaxNode<()>
  public let language: SyntaxNode<Language>
  let comma: SyntaxNode<()>
  public let externalName: SyntaxNode<String>
  let closeParen: SyntaxNode<()>
}

let interopModifierParser = SyntaxNodeParser(Terminal("interop"))
  .take(SyntaxNodeParser(openParenParser))
  .take(SyntaxNodeParser(identifierSequenceParser.stateful()))
  .take(SyntaxNodeParser(commaParser))
  .take(SyntaxNodeParser(singleQuotedStringParser.stateful()))
  .take(SyntaxNodeParser(closeParenParser))
  .compactMap { interopKeyword, openParen, rawLanguage, comma, externalName, closeParen -> SyntaxNode<DeclModifier>? in
    guard let language = InteropModifier.Language(rawValue: rawLanguage.content.content) else {
      return nil
    }

    return
      SyntaxNode(
        leadingTrivia: interopKeyword.leadingTrivia,
        content: SourceRange(
          start: interopKeyword.content.start,
          end: closeParen.content.end,
          content:
          DeclModifier.interop(
            InteropModifier(
              interopKeyword: interopKeyword,
              openParen: openParen,
              language: rawLanguage.map { _ in language },
              comma: comma,
              externalName: externalName.map { String(Substring($0)) },
              closeParen: closeParen
            )
          )
        )
      )
  }
