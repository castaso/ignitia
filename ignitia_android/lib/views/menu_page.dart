import 'package:i_employment/components/textview_widget.dart';
import 'package:i_employment/models/menu_item_model.dart';
import 'package:i_employment/utils/constants.dart';
import 'package:i_employment/utils/string.dart';
import 'package:i_employment/utils/colors.dart';
import 'package:i_employment/utils/global_fields.dart';
import 'package:i_employment/utils/menu_list.dart';
import 'package:i_employment/utils/navigation_utils.dart';
import 'package:flutter/material.dart';
import 'package:i_employment/views/admin/home/admin_home_screen.dart';
import 'package:i_employment/views/attendance/attendance_page.dart';
import 'package:i_employment/views/home/home_screen.dart';
import 'package:i_employment/views/login_screen.dart';
import 'package:i_employment/views/settings_page.dart';

import '../utils/common_functions.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({Key? key}) : super(key: key);

  _menuItemTapped(BuildContext context, int position, Widget? page, bool isWeb) async {
    if(position==99){
      logout(context);
    }else if(position==98){
      if(isWeb) return;

      var settingsModel = await CommonFunctions.getSettings();;
      openNewUI(context, SettingsPage(settingsModel: settingsModel));
    }else {
      openNewUI(context, page ?? (FieldValue.userTypeId == 2 ? HomeScreen() : AdminHomeScreen()));
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
                return ListTile(
                  contentPadding: const EdgeInsets.only(left: 0, right: 0),
                  title: _menuItem(menuList[index]),
                  onTap: () {
                    _menuItemTapped(context, menuList[index].id, menuList[index].page, mediaSize.width > webWidth);
                  },
                );
              }),
        ),
      ),
    );
  }
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
