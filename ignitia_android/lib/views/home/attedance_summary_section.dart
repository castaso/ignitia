import 'package:flutter/material.dart';
import 'package:i_employment/utils/common_functions.dart';
import 'package:i_employment/utils/constants.dart';
import 'package:i_employment/utils/string.dart';
import 'package:provider/provider.dart';

import '../../components/button_widget.dart';
import '../../components/textview_widget.dart';
import '../../models/attendance/user_attendance_summary_model.dart';
import '../../utils/colors.dart';
import '../../view_models/home_view_model.dart';
import 'home_screen.dart';

class AttendanceSummarySectionWidget extends StatefulWidget {
  const AttendanceSummarySectionWidget({Key? key}) : super(key: key);

  @override
  State<AttendanceSummarySectionWidget> createState() => _AttendanceSummarySectionWidgetState();
}

class _AttendanceSummarySectionWidgetState extends State<AttendanceSummarySectionWidget> {

  @override
  Widget build(BuildContext context) {
    HomeViewModel viewModel = context.watch<HomeViewModel>();
    return SizedBox(
      //height: 220,
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(2, 10, 2, 0),
        //only to left align the text
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 4, 0, 0),
              child: TitleTextView(Strings.titleAttendanceSummary,textSize: 14,),
            ),
            const SizedBox(height: 4),
            Row(
              //height: 180,
              children: [
                    Expanded(child: AttendanceSummaryItemWidget(viewModel.userAttendanceSummaryModel, 1)),
                    Expanded(child: AttendanceSummaryItemWidget(viewModel.userAttendanceSummaryModel, 2)),
                  ],
              ),

          ],
        ),
      ),
    );
  }

}

class AttendanceSummaryItemWidget extends StatelessWidget {
  UserAttendanceSummaryModel? item;
  var index = 1;

  AttendanceSummaryItemWidget(
      this.item, this.index,
      {Key? key,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      elevation: 1,
      color: Colors.white,
      child: SizedBox(
        //width: cardSize,
        child: Padding(
          padding: const EdgeInsets.all(0.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: index ==1 ? SubTitleTextView('${Strings.colHeaderTotalDays}: ${item!.total_days.toString()}',textAlign: TextAlign.center,textSize: 14,fontFamily: Fonts.gilroy_semibold,)
                : SubTitleTextView('${Strings.colHeaderPresentDays}: ${item!.present_days.toString()}',textAlign: TextAlign.center,textSize: 14,fontFamily: Fonts.gilroy_semibold,),
              ),
              const SizedBox(height: 16),
              index == 1 ? SubTitleTextView("${Strings.colHeaderWorkingDays}: ${(item!.getWorkingDays()).toString()}",textSize: 14,textAlign: TextAlign.center,fontFamily: Fonts.gilroy_semibold,)
              : SubTitleTextView("${Strings.colHeaderAbsentDays}: ${(item!.getAbsentDays()).toString()}",textSize: 14,textAlign: TextAlign.center,fontFamily: Fonts.gilroy_semibold,),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(child: index == 1 ? AttendanceSummaryProgressIndicatorWidget(Strings.colHeaderHolidays,item!.weekend_holiday.toString())
                      : AttendanceSummaryProgressIndicatorWidget(Strings.colHeaderLateDays,item!.late_days.toString())) ,
                  Expanded(child: index == 1 ? AttendanceSummaryProgressIndicatorWidget(Strings.colHeaderLeaves,item!.leave_days.toString())
                      : AttendanceSummaryProgressIndicatorWidget(Strings.colHeaderOvertimes, CommonFunctions.durationFormat(item!.overtime_duration))) ,
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AttendanceSummaryProgressIndicatorWidget extends StatelessWidget {
  String progressLabel;
  String progressValue;

  AttendanceSummaryProgressIndicatorWidget(
      this.progressLabel,
      this.progressValue,
      {Key? key}
      ) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      elevation: 0.5,
      color: Colors.white,
      child: Column(
        children: [
          Container(
            alignment: Alignment.center,
            decoration:  const BoxDecoration(
                color: kPrimaryLightColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8.0),
                  topRight: Radius.circular(8.0),
                )
            ),
            height: 24,
            child: TitleTextView(progressLabel,textSize: 12,textColor: Colors.white,fontFamily: Fonts.gilroy_semibold,),
          ),
          Container(
            alignment: Alignment.center,
            height: 24,
            child:Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TitleTextView(progressValue,textSize: 14,fontFamily: Fonts.gilroy_semibold,),

              ],
            ),
          ),
        ],
      ),
    );
  }
}
