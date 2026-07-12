// pseudo AST - no types, since we only care about this as a string
// we're not compiling or anything.
enum SfNodeType {
  IF, // technically also a function but easier to recognise in walking.
  FUNCTION,
  FIELD_LITERAL, // only diff from STRING_LITERAL is we know it has been subbed from dart var.
  BRACKET, // look this is not really what a AST node is, but its fine.
  STRING_LITERAL,
  INT_LITERAL,
}

// note for the FUNCTION type, we wont make commas a node, so just call the visitor
// recursively on children, and join on the returned children with commas

// also note, stirng literals need to be wrapped with double quotes when outputting

// i know this isnt a super valid AST. I want this to work,
// then very last thing can be making this more like nodes a compiler would use.
// ( like after release )
class SfNode {
  final SfNodeType sfNodeType;
  final String? token;
  final List<SfNode> children;

  const SfNode(this.sfNodeType, {this.token, this.children = const []});
}
