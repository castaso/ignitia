import 'package:flutter/material.dart';
class MenuItemModel{
  int id;
  String name;
  var typeId = [];
  Widget? page;
  List<MenuItemModel>? children;
  bool isParent;

  MenuItemModel(this.id, this.name, this.typeId, this.page, {this.children, this.isParent = false});
  bool get hasChildren => children != null && children!.isNotEmpty;
}