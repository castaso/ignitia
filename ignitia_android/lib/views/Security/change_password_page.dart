import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:i_employment/components/loading_widget.dart';
import 'package:i_employment/utils/navigation_utils.dart';
import 'package:provider/provider.dart';

import '../../components/app_bar_widget.dart';
import '../../components/button_widget.dart';
import '../../components/custom_textfiled.dart';
import '../../components/error_popup_widget.dart';
import '../../utils/message.dart';
import '../../utils/string.dart';
import '../../view_models/login_view_model.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  TextEditingController oldPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  late LoginViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = Provider.of<LoginViewModel>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    LoginViewModel viewModel = context.watch<LoginViewModel>();

    return Scaffold(
        appBar: CustomAppBar(title: Strings.titleChangePasswordPage),
        body: Stack(children: [
          _uiSection(),
          if (viewModel.loading) LoadingPage(msg: Messages.progressInProgress),
          if (viewModel.errorMsg.isNotEmpty)
            ErrorPopupPage(
              msg: viewModel.errorMsg,
              onOkPressed: () {
                viewModel.setErrorMsg("");
              },
            ),
        ]));
  }

  _uiSection() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          SizedBox(
            height: 80,
          ),
          Expanded(
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: CustomTextField(
                      hintText: Strings.hintOldPassword,
                      textEditingController: oldPasswordController,
                      isPassword: true),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: CustomTextField(
                      hintText: Strings.hintNewPassword,
                      textEditingController: newPasswordController,
                      isPassword: true),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: CustomTextField(
                      hintText: Strings.hintConfirmPassword,
                      textEditingController: confirmPasswordController,
                      isPassword: true),
                ),
                Container(
                  height: 80,
                  padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
                  child: CustomButton(
                    onTap: () async {
                      if (viewModel.loading) return;
                      var isSuccess = await viewModel.changePassword(
                          oldPasswordController.text,
                          newPasswordController.text,
                          confirmPasswordController.text);
                      if (isSuccess) {
                        logout(context);
                      }
                    },
                    text: Strings.btnTextConfirm,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
