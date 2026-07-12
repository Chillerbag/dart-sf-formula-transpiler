import "../salesforce_annotations.dart";

@SfFieldAnnotation('Does_Contain_Part__c')
String ifContains(@SfFieldAnnotation("Product_Type__c") String productType) {
  if (productType.contains("part")) {
    // if (condition branch too)
    return "Parts"; // sf literal node
  } else {
    // doesnt map to sf ?
    return "Service"; //sf literal node
  }
}

// sfConditionNode(SfExpressionNode, SfLiteralNode|SfExpression, SfLiteralNode)
//SfExpression : SfFunction | SfLiteralNode, SFOperator, SfLiteral
