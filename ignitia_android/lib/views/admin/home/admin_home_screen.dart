import 'package:flutter/foundation.dart';
import 'package:i_employment/components/button_widget.dart';
import 'package:i_employment/components/textview_widget.dart';
import 'package:i_employment/models/settings_model.dart';
import 'package:i_employment/utils/colors.dart';
import 'package:i_employment/utils/common_functions.dart';
import 'package:i_employment/utils/global_fields.dart';
import 'package:i_employment/utils/message.dart';
import 'package:i_employment/utils/navigation_utils.dart';
import 'package:i_employment/utils/shared_preference.dart';
import 'package:i_employment/utils/string.dart';
import 'package:i_employment/view_models/home_view_model.dart';
import 'package:i_employment/views/home/attedance_summary_section.dart';
import 'package:i_employment/views/home/leave_summary_section.dart';
import 'package:i_employment/views/home/quick_access_section.dart';
import 'package:i_employment/views/home/user_info_section.dart';
import 'package:i_employment/views/login_screen.dart';
import 'package:i_employment/views/settings_page.dart';
import 'package:i_employment/views/webview.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../components/error_popup_widget.dart';
import '../../../components/loading_widget.dart';
import '../../../utils/constants.dart';
import '../../life_cycle_event_handler.dart';
import '../../menu_page.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({Key? key}) : super(key: key);

  @override
  State<AdminHomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<AdminHomeScreen> {
  int _selectedIndex = 0;

  @override
  initState() {
    super.initState();

  }

  _pages<Widget>() {
    switch (_selectedIndex) {
      case 0:
        {
          return AdminHomePage();
        }
      case 4:
        {
          return MenuPage();
        }
    }
  }

  //logout function
  logout() async {
    // await auth.signOut();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBGColor,
      appBar: _appBarUI(),
      body: _pages(),
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
      title: const Text(Strings.titleHome),
      centerTitle: false,
      flexibleSpace: Align(alignment: Alignment.centerRight, child: mediaSize.width>webWidth ? UserInfoWidget() : Container(),),
      actions: mediaSize.width< webWidth ? _toolBar(mediaSize) : [Container()],
    );
  }
  
  _toolBar(Size mediaSize){
    List<Widget> actions = [_toolbarIcon(
        Icon(
          Icons.language,
          color: Colors.white,
        ),
        1),
      _toolbarIcon(
          Icon(
            Icons.settings,
            color: Colors.white,
          ),
          2),
      _toolbarIcon(
          Icon(
            Icons.menu,
            color: Colors.white,
          ),
          3)];
    return actions;
  }

  _toolbarIcon(Widget icon, int pos) {
    return Transform.scale(
      scale: 0.80,
      child: IconButton(
        icon: icon,
        onPressed: () {
          _toolbarIconClick(pos);
        },
      ),
    );
  }

  _toolbarIconClick(int pos) async {
    switch (pos) {
      case 1:
        {
          openNewUI(context, WebViewPage(targetURL: FieldValue.webAppAddress));
          return;
        }
      case 2:
        {
          var settingsModel = await CommonFunctions.getSettings();
          openNewUI(context, SettingsPage(settingsModel: settingsModel));
          return;
        }
      case 3:
        {
          _selectedIndex = 4;
          openNewUI(context, const MenuPage());
          return;
        }
    }
  }
}

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  late HomeViewModel viewModel;
  @override
  void initState() {
    super.initState();
    viewModel = Provider.of<HomeViewModel>(context, listen: false);

    WidgetsBinding.instance.addObserver(LifecycleEventHandler(
        resumeCallBack: () async => setState(() {
              viewModel.pullRefresh();
            }),
        suspendingCallBack: () async => () {}));

    _loadData();
  }

  _loadData() async {
    await viewModel.pullRefresh();
    //if (viewModel.userAttendanceSummaryModel != null) _showPopup(viewModel);
  }

  @override
  Widget build(BuildContext context) {
    var mediaSize = MediaQuery.of(context).size;
    if(kDebugMode){print('mediaSize: $mediaSize');}
    HomeViewModel viewModel = context.watch<HomeViewModel>();
    return SafeArea(
        child: RefreshIndicator(
      onRefresh: viewModel.pullRefresh,
      child: Stack(
        children: [
          _homeUI(viewModel, mediaSize),
          if (viewModel.loading) LoadingPage(msg: Messages.progressInProgress),
          if(viewModel.errorMsg.isNotEmpty)
            ErrorPopupPage(msg: viewModel.errorMsg, onOkPressed: (){
              viewModel.setErrorMsg("");
            },),
        ],
      ),
    ));
  }

  _homeUI(HomeViewModel viewModel, Size mediaSize) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 2, 0, 0),
      child: Row(
        children: [
          mediaSize.width > webWidth ? Flexible(flex: 1, child: MenuPage())  : Container(),
          Flexible(
            flex: 3,
            child: ListView(
              shrinkWrap: false,
              children: <Widget>[
                mediaSize.width <webWidth ? _userInfoWidget(viewModel) : Container(),
                mediaSize.width <webWidth ? _quickAccessWidget(viewModel) : Container(),
                _attendanceSummaryWidget(viewModel),
                _leaveSummaryWidget(viewModel),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _userInfoWidget<Widget>(HomeViewModel viewModel) {
    return UserInfoWidget();
  }

  _quickAccessWidget<Widget>(HomeViewModel viewModel) {
    if (viewModel.isQuickAccessLoaded) {
      return QuickAccessWidget();
    }
    return emptySpace();
  }

  _attendanceSummaryWidget<Widget>(HomeViewModel viewModel) {
    if (viewModel.userAttendanceSummaryModel != null) {
      return AttendanceSummarySectionWidget();
    }
    return emptySpace();
  }

  _leaveSummaryWidget<Widget>(HomeViewModel viewModel) {
    if (viewModel.leaveSummaryList.isNotEmpty) {
      return LeaveSummaryWidget();
    }
    return emptySpace();
  }
}

emptySpace<Widget>() {
  return const SizedBox(height: 0, width: double.infinity);
}
