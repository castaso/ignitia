import 'package:flutter/material.dart';
import 'package:ignitia_dashboard/components/textview_widget.dart';
import 'package:ignitia_dashboard/utils/constants.dart';
import 'package:ignitia_dashboard/utils/global_fields.dart';
import 'package:ignitia_dashboard/utils/string.dart';

class UserInfoWidget extends StatefulWidget {
  UserInfoWidget({Key? key}) : super(key: key);

  @override
  State<UserInfoWidget> createState() => _UserInfoWidgetState();
}

class _UserInfoWidgetState extends State<UserInfoWidget> {

  @override
  Widget build(BuildContext context) {
    var mediaSize = MediaQuery.of(context).size;

    return Container(
      constraints: BoxConstraints(maxWidth: 500),
      child: Card(
        elevation: 2,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Column(
            children: <Widget>[
              Container(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 4, 0),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TitleTextView(FieldValue.userName),
                              const SizedBox(height: 6),
                              SubTitleTextView(FieldValue.userDesignation),
                            ],
                          ),
                          const Spacer(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              SubTitleTextView(FieldValue.employeeId),
                              const SizedBox(height: 6),
                              SubTitleTextView('${Strings.textLastLoginPrefix} @${FieldValue.lastLoginTime}'),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: mediaSize.width<webWidth ? 6 : 1),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
