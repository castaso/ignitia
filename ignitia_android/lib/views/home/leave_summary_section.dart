import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../components/textview_widget.dart';
import '../../models/leave/leave_summary_model.dart';
import '../../utils/colors.dart';
import '../../utils/string.dart';
import '../../view_models/home_view_model.dart';

class LeaveSummaryWidget extends StatefulWidget {
  const LeaveSummaryWidget({Key? key}) : super(key: key);

  @override
  State<LeaveSummaryWidget> createState() => _LeaveSummaryWidgetState();
}

class _LeaveSummaryWidgetState extends State<LeaveSummaryWidget> {
  @override
  Widget build(BuildContext context) {
    HomeViewModel viewModel = context.watch<HomeViewModel>();

    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 10, 2, 0),
      //only to left align the text
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
            child: TitleTextView(
              Strings.titleLeaveSummary,
              textSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                  child:
                      leaveSummaryItem(context, viewModel.leaveSummaryList[0])),
              Expanded(
                  child:
                      leaveSummaryItem(context, viewModel.leaveSummaryList[1]))
            ],
          )
        ],
      ),
    );
  }
}

Widget leaveSummaryItem(BuildContext context, LeaveSummaryModel item) {
  //return LeaveSummaryCardViewWidget(item);
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: SizedBox(
                    height: 30,
                    child: Center(
                        child: TitleTextView(
                      '${item.leaveShortName} : ${item.entitlement}',
                      textAlign: TextAlign.center,
                      textSize: 14,
                      fontFamily: Fonts.gilroy_semibold,
                      textColor: subTitleTextColor,
                      maxLines: 2,
                    ))),
              ),
            ],
          ),
          Center(
            child:
              //const Spacer(),
              _leaveSummaryProgressBar(item),
              //const Spacer(),

          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LeaveSummaryProgressIndicatorWidget(
                  Strings.leaveTaken, item.taken.toString()),
              Spacer(),
              LeaveSummaryProgressIndicatorWidget(
                  Strings.leaveBalance, item.balance.toString())
            ],
          )
        ],
      ),
    ),

  );
}

_leaveSummaryProgressBar(LeaveSummaryModel item) {
  return CircularPercentIndicator(
    radius: 50.0,
    lineWidth: 4.0,
    backgroundColor: Colors.grey.shade100,
    animation: true,
    percent: (item.taken / item.entitlement),
    center: SubTitleTextView(
      "${((item.taken / item.entitlement) * 100).floor()}%",
      textSize: 18,
      textAlign: TextAlign.center,
      fontFamily: Fonts.gilroy_bold,
    ),
    circularStrokeCap: CircularStrokeCap.round,
    progressColor: blYellowColor,
  );
}

class LeaveSummaryProgressIndicatorWidget extends StatelessWidget {
  String progressLabel;
  String progressValue;

  LeaveSummaryProgressIndicatorWidget(this.progressLabel, this.progressValue,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TitleTextView(progressLabel,
            textSize: 12, fontFamily: Fonts.gilroy_medium),
        const SizedBox(
          width: 4,
        ),
        TitleTextView(
          progressValue,
          textSize: 12,
          fontFamily: Fonts.gilroy_medium,
          textColor:
              progressLabel == Strings.leaveTaken ? successColor : Colors.blue,
        )
      ],
    );
  }
}
