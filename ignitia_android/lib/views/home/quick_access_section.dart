
import 'package:i_employment/utils/navigation_utils.dart';
import 'package:i_employment/view_models/home_view_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:i_employment/views/leave/leave_page.dart';
import 'package:i_employment/views/overtime/overtime_list_page.dart';
import 'package:provider/provider.dart';

import '../../components/textview_widget.dart';
import '../../utils/string.dart';
import '../attendance/attendance_page.dart';
import '../payroll/payslip_page.dart';

class QuickAccessWidget extends StatefulWidget {
  const QuickAccessWidget({Key? key}) : super(key: key);

  @override
  State<QuickAccessWidget> createState() => _QuickAccessWidgetState();
}

class _QuickAccessWidgetState extends State<QuickAccessWidget> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    HomeViewModel viewModel = context.watch<HomeViewModel>();
    return Card(
      elevation: 0,
      color: Colors.transparent,
      child: SizedBox(
        //height: 180,
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 8, 0, 0),
                  child: TitleTextView("${Strings.titleGoTo}:",textSize: 14,),
                ),
                // const Spacer(),
                // IconButton(
                //     onPressed: (){
                //       openNewUI(context, const QuickAccessEditPage());
                //     },
                //     icon: const Icon(Icons.edit_outlined)
                // ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 100,
              child:  Center(
                child: ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: viewModel.quickAccessTitleList.length,
                    itemBuilder: (BuildContext context, int index){
                      return quickAccessItem(context,index,Key("$index"),viewModel);
                    }
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget quickAccessItem(BuildContext context, int index,Key? key, HomeViewModel viewModel,) {

  return Card(
    key: key,
    elevation: 1,
    color: Colors.white,
    child: SizedBox(
      width: 110,
      height: 110,
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.white)
        ),
        onPressed: (){
          _onQuickAccessPressed(context, index);
        },
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                "assets/icons/${viewModel.quickAccessIconList[index]}.png",
                width: 30,
                height: 30,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 10),
              TitleTextView(viewModel.quickAccessTitleList[index],textAlign: TextAlign.center, fontFamily: Fonts.gilroy_regular,)
            ],
          ),
        ),
      ),
    ),
  );
}

_onQuickAccessPressed(BuildContext context, index){
  switch(index){
    case 0:{
      openNewUI(context, AttendancePage());
      return;
    }
    case 1:{
      openNewUI(context, OvertimeListPage());
      return;
    }
    case 2:{
      openNewUI(context, LeavePage());
      return;
    }
    case 3:{
      openNewUI(context, PayslipPage());
      return;
    }
  }
}

class QuickAccessEditPage extends StatefulWidget {
  const QuickAccessEditPage({Key? key}) : super(key: key);

  @override
  State<QuickAccessEditPage> createState() => _QuickAccessEditPageState();
}

class _QuickAccessEditPageState extends State<QuickAccessEditPage> {

  late HomeViewModel viewModel;
  @override
  void initState() {
    super.initState();
    viewModel = Provider.of<HomeViewModel>(context,listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        title: const Text('Quick Access Edit'),
    ),
    body: _mainView()
    );
  }

  _mainView(){
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TitleTextView("Rearrange quick access items position by drag and drop"),
          const SizedBox(height: 20,),
          _reOrderAbleListview()
        ],
      ),
    );
  }

  _reOrderAbleListview(){
    return Expanded(
      child: ReorderableListView(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        onReorder: (int oldIndex, int newIndex) {
          setState(() {
            if (oldIndex < newIndex) {
              newIndex -= 1;
            }
            final String item = viewModel.quickAccessTitleList.removeAt(oldIndex);
            final String iconItem = viewModel.quickAccessIconList.removeAt(oldIndex);
            viewModel.quickAccessTitleList.insert(newIndex, item);
            viewModel.quickAccessIconList.insert(newIndex, iconItem);
            viewModel.setQuickAccessLoadingStatus(true);
            viewModel.updateListIndex();
          });
        },
        children: <Widget>[
          for (int index = 0; index < viewModel.quickAccessTitleList.length; index += 1)
            quickAccessItem(context, index,Key("$index"),viewModel)
        ],
      ),
    );
  }
}

