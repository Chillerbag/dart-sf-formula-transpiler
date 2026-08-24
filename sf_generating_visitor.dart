import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/syntactic_entity.dart';
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

class SfGeneratingVisitor<SfNode> extends GeneralizingAstVisitor {
  Map<String, String> sfNameToVariableName = {};
  String? recordName;
  ({String sfName, String? dartName})? tempSfToDartMapping;

  bool inSfFieldAnnotation = false;

  @override
  visitNode(AstNode node) {
    print("NODETYPE: ${node.runtimeType}");
    super.visitNode(node);
  }

  @override
  visitSimpleIdentifier(SimpleIdentifier node) {
    if (node.toSource() == 'SfFieldAnnotation') {
      print('here1');
      print(inSfFieldAnnotation);
      if (inSfFieldAnnotation) {
        print('are we here?');
        // we must be in the recordName, and must already have an sfname.
        recordName = tempSfToDartMapping!.sfName;
        tempSfToDartMapping = null;
      }
      inSfFieldAnnotation = true;
    }
    // TODO: implement visitSimpleIdentifier
    return super.visitSimpleIdentifier(node);
  }

  @override
  visitSimpleStringLiteral(SimpleStringLiteral node) {
    if (inSfFieldAnnotation) {
      // TODO handle the error case here
      if (tempSfToDartMapping == null && inSfFieldAnnotation) {
        print('setting temp...');
        tempSfToDartMapping = (sfName: node.toString(), dartName: null);
      }
    }
    // TODO: implement visitSimpleStringLiteral
    return super.visitSimpleStringLiteral(node);
  }

  @override
  visitRegularFormalParameter(RegularFormalParameter node) {
    // TODO kill for loop, we can use name.
    print('formal param');
    print(node.name);
    for (SyntacticEntity childNode in node.childEntities) {
      if (childNode.runtimeType.toString() == 'StringTokenImpl' &&
          inSfFieldAnnotation &&
          tempSfToDartMapping != null) {
        print('will set to false');
        // TODO record is obvs pointless here
        tempSfToDartMapping = (
          sfName: tempSfToDartMapping!.sfName,
          dartName: node.name.toString(),
        );
        sfNameToVariableName[tempSfToDartMapping!.sfName] =
            tempSfToDartMapping!.dartName!;
        inSfFieldAnnotation = false;
        tempSfToDartMapping = null;
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
}
