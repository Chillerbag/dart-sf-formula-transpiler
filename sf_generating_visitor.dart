import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

// so, we need to know where we are when walking the tree .
// for example, when we enter an AnnotationImpl, we need to find the
// SimpleStringLiteralImpl, and the NamedTypeImpl and map those, so that we
// can replace them as we walk.
// the dumb idea here, is when constructing an SfNode that is a LiteralFieldNameNode
// check the map. However, need to ensure this map persists through recursion.
// we also need to know, that outside of the annotaitonImpl, we only want to start building
// for what is in the BlockFunctionBodyImpl or BlockImpl.

// note, it seems the NamedTypeImpl is bugged. Only prints String. May submit PR

// TODO: Dart says we should NOT rely on the toString or toSource. What can we do instead?

// if passing the values through the recursion becomes too hard, then lets do multiple loops.

class SfGeneratingVisitor<SfNode> extends GeneralizingAstVisitor {
  @override
  visitNode(AstNode node) {
    print("NODETYPE: ${node.runtimeType}");
    print(
      "Visiting node that begins at ${node.beginToken.type}, and ends at ${node.endToken.type} String is: ${node.toSource()}, Length is ${node.length}",
    );
    print('\n');
    super.visitNode(node);
  }
}
