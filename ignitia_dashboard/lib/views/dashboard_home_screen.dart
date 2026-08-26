import 'package:flutter/material.dart';
import 'package:ignitia_dashboard/components/textview_widget.dart';
import 'package:ignitia_dashboard/models/menu_item_model.dart';
import 'package:ignitia_dashboard/utils/colors.dart';
import 'package:ignitia_dashboard/utils/constants.dart';
import 'package:ignitia_dashboard/utils/navigation_utils.dart';
import 'package:ignitia_dashboard/utils/string.dart';
import 'package:ignitia_dashboard/views/admin/attendance/approve_overtime_page.dart';
import 'package:ignitia_dashboard/views/admin/leave/holiday_page.dart';
import 'package:ignitia_dashboard/views/employee/employee_list_page.dart';
import 'package:ignitia_dashboard/views/home/user_info_section.dart';
import 'package:ignitia_dashboard/views/menu_page.dart';
import 'package:ignitia_dashboard/views/shift/assign_shift_page.dart';
import 'package:ignitia_dashboard/views/shift/shift_page.dart';

class DashboardHomeScreen extends StatefulWidget {
  const DashboardHomeScreen({Key? key}) : super(key: key);

  @override
  State<DashboardHomeScreen> createState() => _DashboardHomeScreenState();
}

class _DashboardHomeScreenState extends State<DashboardHomeScreen> {
  List<MenuItemModel> _quickAccessList = [];

  @override
  void initState() {
    super.initState();
    _quickAccessList = [
      MenuItemModel(1, Strings.titleEmployeeListPage, [1], const EmployeeListPage()),
      MenuItemModel(2, Strings.titleApproveOvertimePage, [1], const ApproveOvertimePage()),
      MenuItemModel(3, Strings.titleHolidayPage, [1], const HolidayPage()),
      MenuItemModel(4, Strings.titleShiftPage, [1], const ShiftPage()),
      MenuItemModel(5, Strings.titleAssignShiftPage, [1], const AssignShiftPage()),
      MenuItemModel(99, Strings.titleSignOut, [1], null),
    ];
  }

  @override
  Widget build(BuildContext context) {
    var mediaSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: pageBGColor,
      appBar: _appBarUI(),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            mediaSize.width > webWidth
                ? Flexible(flex: 1, child: MenuPage())
                : Container(),
            Flexible(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TitleTextView("${Strings.titleGoTo}:", textSize: 14),
                    const SizedBox(height: 10),
                    Expanded(child: _quickAccessGrid(mediaSize)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _appBarUI() {
    var mediaSize = MediaQuery.of(context).size;
    return AppBar(
      leading: Transform.scale(
          scale: 2.5,
          child: IconButton(
            icon: Image.asset(
              'assets/images/eb_logo.png',
              height: 15,
            ),
            onPressed: () {},
          )),
      title: const Text(Strings.titleDashboardHomePage),
      centerTitle: false,
      flexibleSpace: Align(
        alignment: Alignment.centerRight,
        child: mediaSize.width > webWidth ? UserInfoWidget() : Container(),
      ),
    );
  }

  _quickAccessGrid(Size mediaSize) {
    var columns = mediaSize.width > webWidth ? 4 : 2;
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: _quickAccessList.length,
      itemBuilder: (BuildContext context, int index) {
        return _quickAccessItem(index);
      },
    );
  }

  Widget _quickAccessItem(int index) {
    var item = _quickAccessList[index];
    return Card(
      elevation: 1,
      color: Colors.white,
      child: InkWell(
        onTap: () {
          if (item.id == 99) {
            logout(context);
          } else {
            openNewUI(context, item.page!);
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(Icons.dashboard_outlined, size: 30, color: kPrimaryColor),
            const SizedBox(height: 10),
            TitleTextView(
              item.name,
              textAlign: TextAlign.center,
              fontFamily: Fonts.gilroy_regular,
            ),
          ],
        ),
      ),
    );
  }
}
