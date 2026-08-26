import 'package:flutter/material.dart';
class ToolBarItemModel{
  int id;
  Icon icon;
  Widget? page;
  VoidCallback? onTap;

  ToolBarItemModel(this.id, this.icon, this.page, this.onTap);
}