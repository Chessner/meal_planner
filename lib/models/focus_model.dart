import 'package:flutter/material.dart';

class FocusModel extends ChangeNotifier {
  late final List<FocusNode> _focusNodes;
  final FocusNode _title = FocusNode();


  FocusModel({required int nodeAmount}) {
    _focusNodes = List.generate(nodeAmount, (index) => FocusNode());
  }

  void add() {
    FocusNode focusNode = FocusNode();
    _focusNodes.add(focusNode);
  }

  FocusNode get titleFNode => _title;

  FocusNode get(int index) => _focusNodes[index];

  void remove(int index) {
    _focusNodes[index].dispose();
    _focusNodes.removeAt(index);
  }

  void unfocusAll() {
    _title.unfocus();
    for (FocusNode node in _focusNodes) {
      node.unfocus();
    }
  }

  @override
  void dispose(){
    super.dispose();
    _title.dispose();
    for(var node in _focusNodes){
      node.dispose();
    }
  }
}
