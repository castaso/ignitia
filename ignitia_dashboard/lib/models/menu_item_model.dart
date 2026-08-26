import 'package:flutter/material.dart';
class MenuItemModel{
  int id;
  String name;
  var typeId = [];
  Widget? page;

  MenuItemModel(this.id, this.name, this.typeId, this.page);
}