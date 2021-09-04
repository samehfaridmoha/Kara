//
//  Created by Max Desiatov on 04/09/2021.
//

enum Declaration {
  case binding(BindingDecl)
  case function(FunctionDecl)
  case `struct`(StructDecl)
  case trait(TraitDecl)
}
