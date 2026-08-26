import 'package:flutter/material.dart';
import 'package:i_employment/utils/constants.dart';

import '../models/toolbar_item_model.dart';
import '../utils/navigation_utils.dart';
import '../views/home/user_info_section.dart';
import '../views/menu_page.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final List<ToolBarItemModel>? list;
  final bool withMenu;

  const CustomAppBar(
      {Key? key, required this.title, this.list, this.withMenu = true})
      : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(55);

  @override
  State<CustomAppBar> createState() =>
      _CustomAppBarState(title, list, withMenu);
}

class _CustomAppBarState extends State<CustomAppBar> {
  String title;
  List<ToolBarItemModel>? list;
  final bool withMenu;
  _CustomAppBarState(this.title, this.list, this.withMenu);

  @override
  initState() {
    super.initState();
    ToolBarItemModel item =
        ToolBarItemModel(1, const Icon(Icons.menu), MenuPage(), null);

    if (list == null) {
      if (withMenu) {
        list = [item];
      }
    } else {
      if (withMenu) {
        list?.add(item);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var mediaSize = MediaQuery.of(context).size;
    return AppBar(
        leading: mediaSize.width < webWidth ? null : ImageIcon(AssetImage('images/eb_logo.png')),
        automaticallyImplyLeading: mediaSize.width < webWidth,
        centerTitle: false,
        title: Text(title),
        flexibleSpace: Align(
          alignment: Alignment.centerRight,
          child: mediaSize.width > webWidth ? UserInfoWidget() : Container(),
        ),
        actions:
            mediaSize.width > webWidth ? null : _toolbarList() // <IconButton>[
        //_toolbarIcon(ToolBarItemModel(99, const Icon(Icons.menu), const MenuPage()))
        //],
        );
  }

  _toolbarList() {
    if (list == null)
      return SizedBox(
        width: 5,
      );
    List<Widget>? items = list
        ?.asMap()
        .entries
        .map((e) => Transform.scale(
              scale: 0.80,
              child: IconButton(
                icon: e.value.icon,
                onPressed: e.value.onTap != null
                    ? e.value.onTap
                    : () {
                        openNewUI(context, e.value.page!);
                      },
              ),
            ))
        .toList();

    return items;
  }
}
