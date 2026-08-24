import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/syntactic_entity.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';

// so, we need to know where we are when walking the tree .
// for example, when we enter an AnnotationImpl, we need to find the
// SimpleStringLiteralImpl, and the NamedTypeImpl and map those, so that we
// can replace them as we walk.
// the dumb idea here, is when constructing an SfNode that is a LiteralFieldNameNode
// check the map. However, need to ensure this map persists through recursion.
// we also need to know, that outside of the annotaitonImpl, we only want to start building
// for what is in the BlockFunctionBodyImpl or BlockImpl.

// also need to keep track of if we are insde the if statement, so we can form else statements
// in the SF function.

// also need to kknow if we're in MethodInvocationImpl or whatever the function one is,
// as well as what we are calling on and the method name, so we can for example, turn productType.contains into CONTAINS()...
// at a certain point, gotta wonder if we need a custom AST.

// TODO: how do we know we are inside an IfStatementImpl ? i guess the function does, and
// can pass that into its children. yeah thats right actually.
// we does else go? // else is a child of if, so we can visit it and build.
// note, it seems the NamedTypeImpl is bugged. Only prints String. May submit PR

// TODO: Dart says we should NOT rely on the toString or toSource. What can we do instead?

// if passing the values through the recursion becomes too hard, then lets do multiple loops.

// 24-08 progress - we are hitting the annotation after the formal param... probably because the node
// children are of the same hierarchy here, or alternatively, because its part of the formalParameterList node.
// need to investigate further.

// TODO change string typechecks to actual
class SfGeneratingVisitor<SfNode> extends GeneralizingAstVisitor {
  Map<String, String> sfNameToVariableName = {};
  String? fileTitle;

  @override
  visitNode(AstNode node) {
    // skip string literal of imports.
    if (node is ImportDirective) {
      return;
    }
    print("NODETYPE: ${node.runtimeType}:, NODESTRING: ${node.toString()}");
    super.visitNode(node);
  }

  @override
  visitSimpleIdentifier(SimpleIdentifier node) {
    // TODO: implement visitSimpleIdentifier
    return super.visitSimpleIdentifier(node);
  }

  // TODO moe this to functionDeclarationsImpl
  @override
  visitSimpleStringLiteral(SimpleStringLiteral node) {
    // TODO handle the error case here
    if (fileTitle == null) {
      print('setting filename...');
      fileTitle = node.toString();
    }
    // TODO: implement visitSimpleStringLiteral
    return super.visitSimpleStringLiteral(node);
  }

  @override
  visitRegularFormalParameter(RegularFormalParameter node) {
    // TODO kill for loop, we can use name.
    print('formal param');
    print(node.name);

    // the problem is we are parsing this early to get the token at the end of the formal parameter
    // however we need to visit the annotation first. A solution would be:
    // check if the formalParameterListImpl has an annotation, and if it does, then mess with the visiting order by
    // calling accept on the nodes etc.

    // alternatively, we can try and add these nodes to some kind of queue to deal with later.

    // or, we assume the first time we hit sfAnnotation, that is the title (for this function)
    // and dont do the inSfFieldAnnotation setting.
    // that seems to make the most sense at this stage.

    switch (node.childEntities) {
      case [SyntacticEntity first, SyntacticEntity _, SyntacticEntity third]:
        if (first.runtimeType.toString() != 'AnnotationImpl') {
          // raise unnanotated error
        } else {
          // extract the simpleStringLiteral ?
          // eg call visitor recursively down til when we get the SimpleStirngLiteralImpl.
          // this means we need to define the behaviour for annotationImpl to desc its children
          // until it reaches a SimpleStringLiteralIml
          print('PRITING ANNOTATION STRING');
          //TODO should no longer visit nodesvisitied here
          String? sfVal = visitAndFindLiteralForAnnotation(node, []);
          print(third.runtimeType);
          // now we can just add the record here!
          // and first annotation is just the title of the file.
          // TODO handle sfVal being null here
          sfNameToVariableName[third.toString()] = sfVal!;
        }
    }
    return super.visitRegularFormalParameter(node);
  }

  @override
  visitIfStatement(IfStatement node) {
    // the list of nodes attached here will be important.
    // since one will be condition, true, and then else.
    if (node.elseStatement != null) {
      // add else node to the sf tree
    }
    return super.visitIfStatement(node);
  }

  // TODO optimise by removing tokens from the child list, wastes an iteration. current thing im not sure type is right
  // this is recursive
  String? visitAndFindLiteralForAnnotation(
    SyntacticEntity node,
    List<SyntacticEntity> remainingNodes,
  ) {
    if (node is AstNode) {
      remainingNodes.addAll(node.childEntities);
    }
    remainingNodes = remainingNodes.where((e) => (e is! Token)).toList();

    if (node.runtimeType.toString() == 'SimpleStringLiteralImpl') {
      return node.toString();
    }
    while (remainingNodes.length != 0) {
      return visitAndFindLiteralForAnnotation(
        remainingNodes.removeAt(0),
        remainingNodes,
      );
    }
    return null;
  }
}
