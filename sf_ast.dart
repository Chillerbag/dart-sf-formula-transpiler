// pseudo AST - no types, since we only care about this as a string
// we're not compiling or anything.
class SfNode {
  String? token;
  List<SfNode>? children;
}
