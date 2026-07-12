import 'dart:io';
import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import 'sf_generating_visitor.dart';

// NOTE we will need to figure out how to extract the top level function.
// for now, process whole file, assuming its one function.
// actually, we should probably be able to compile both files containing one function
// and files containing multiple.

abstract class SfNode {
  dynamic data;
  SfNode? lNode;
  SfNode? rNode;
}

// TODO function which collects file paths.

void parseDartAst({List<String>? files}) {
  if (files == null || files.isEmpty) {
    // TODO make this specific
    throw Exception('No files found');
  }
  for (String file in files) {
    ParseStringResult parsed = parseFile(
      path: file,
      featureSet: FeatureSet.latestLanguageVersion(),
    );
    // print(parsed);
    // print(parsed.unit.beginToken.type);
    // print(parsed.unit.beginToken);
    // print(parsed.content);
    parsed.unit.visitChildren(SfGeneratingVisitor());
    print('parsed!');
  }
}

main() {
  parseDartAst(files: ['./examples/if_contains_basic.dart']);
}


// build ast nodes for sf formulas
// build recursiveastvistor postorder depth first that reutnrs ast node s
// when we enter a node that has the sf annotation, make sure we know as we recurse,
// so we can pass the node to replace. 
// make sure we except and kill recursion if we find a node that we dont support. s
// make visit methods return ast nodes, and call the accepts of relevant children.
// no more calling visitChildren
// build printer ast for sf nodes 
// build map of valid functions and replace function names in first visit (astnode for sf knows its function name)
// build file reader for functions and handle them one by one 
// build outputter. 
