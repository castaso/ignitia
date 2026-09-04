import 'package:ignitia_dashboard/components/textview_widget.dart';
import 'package:ignitia_dashboard/models/menu_item_model.dart';
import 'package:ignitia_dashboard/utils/constants.dart';
import 'package:ignitia_dashboard/utils/string.dart';
import 'package:ignitia_dashboard/utils/colors.dart';
import 'package:ignitia_dashboard/utils/global_fields.dart';
import 'package:ignitia_dashboard/utils/menu_list.dart';
import 'package:ignitia_dashboard/utils/navigation_utils.dart';
import 'package:flutter/material.dart';
import 'package:ignitia_dashboard/views/dashboard_home_screen.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({Key? key}) : super(key: key);

  _menuItemTapped(BuildContext context, int position, Widget? page) async {
    if (position == 99) {
      logout(context);
    } else {
      openNewUI(context, page ?? const DashboardHomeScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    var mediaSize = MediaQuery.of(context).size;
    var menuList = MenuList()
        .getMenuList()
        .where((e) => e.typeId.contains(FieldValue.userTypeId))
        .toList();
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        automaticallyImplyLeading: mediaSize.width < webWidth,
        title: const Text(Strings.titleMenuPage),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Container(
          constraints: BoxConstraints(maxWidth: 500),
          color: pageBGColor,
          child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              itemCount: menuList.length,
              itemBuilder: (BuildContext context, int index) {
                final item = menuList[index];
                if (item.hasChildren) {
                  return _parentItem(context, item);
                }
                return ListTile(
                  contentPadding: const EdgeInsets.only(left: 0, right: 0),
                  title: _menuItem(item),
                  onTap: () {
                    _menuItemTapped(context, item.id, item.page);
                  },
                );
              }),
        ),
      ),
    );
  }

  Widget _parentItem(BuildContext context, MenuItemModel parent) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
      child: ExpansionTile(
        title: TitleTextView(parent.name, textSize: 15, fontFamily: Fonts.gilroy_semibold),
        childrenPadding: const EdgeInsets.only(left: 12, right: 0, bottom: 8),
        children: parent.children!.map((child) {
          return ListTile(
            contentPadding: const EdgeInsets.only(left: 0, right: 0),
            title: _childItem(child),
            onTap: () => _menuItemTapped(context, child.id, child.page),
          );
        }).toList(),
      ),
    );
  }

_menuItem(MenuItemModel menu) {
  return Container(
    height: 50,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(4),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          TitleTextView(
            menu.name,
            textSize: 15,
            fontFamily: Fonts.gilroy_semibold,
          ),
          const Spacer(),
          if (menu.id != 99)
            const Icon(
              Icons.arrow_forward_ios,
              size: 14,
            )
        ],
      ),
    ),
  );
}

_childItem(MenuItemModel menu) {
  return Container(
    height: 44,
    decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(4)),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          TitleTextView(menu.name, textSize: 14, fontFamily: Fonts.gilroy_medium),
          const Spacer(),
          const Icon(Icons.arrow_forward_ios, size: 12),
        ],
      ),
    ),
  );
}
}
