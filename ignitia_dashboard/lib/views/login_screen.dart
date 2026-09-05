import 'package:ignitia_dashboard/components/button_widget.dart';
import 'package:ignitia_dashboard/components/custom_textfiled.dart';
import 'package:ignitia_dashboard/components/loading_widget.dart';
import 'package:ignitia_dashboard/components/logo_widget.dart';
import 'package:ignitia_dashboard/components/toast_widget.dart';
import 'package:ignitia_dashboard/utils/colors.dart';
import 'package:ignitia_dashboard/utils/navigation_utils.dart';
import 'package:ignitia_dashboard/view_models/login_view_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../utils/message.dart';
import '../utils/string.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LoginScreen();
}

class _LoginScreen extends State<LoginScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  late LoginViewModel viewModel;
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, ()
    {
      initialization();
    });
  }

  void initialization() async {
    viewModel = Provider.of<LoginViewModel>(context, listen: false);
    _listenChangeFromViewModel();
    await viewModel.completePendingGoogleLogin();
  }

  @override
  void dispose() {
    super.dispose();
    viewModel.removeListener(() {});
  }

  void _listenChangeFromViewModel() {
    viewModel.addListener(() {
      if (viewModel.isLoginSuccess) {
        openHomeUI(context);
      }
      if (!viewModel.loading && viewModel.errorMsg.isNotEmpty) {
        _showMsg(viewModel.errorMsg, true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    LoginViewModel viewModel = context.watch<LoginViewModel>();
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(children: [
        SafeArea(child: _loginUI(viewModel)),
        if (viewModel.loading) LoadingPage(msg: Messages.progressCheckAuth)
      ]),
    );
  }

  _loginUI(LoginViewModel viewModel) {
    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              SizedBox(height: 80,),
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  children: <Widget>[
                    Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(10),
                        child: const LogoWidget()),
                    Container(
                      padding: const EdgeInsets.all(10),
                      child: CustomTextField(
                        hintText: Strings.hintEmailAddress,
                        textEditingController: nameController,
                        textInputType: TextInputType.emailAddress,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                      child: CustomTextField(
                          hintText: Strings.hintPassword,
                          textEditingController: passwordController,
                          isPassword: true),
                    ),
                    Container(
                      height: 80,
                      padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
                      child: CustomButton(
                        onTap: () {
                          if(kDebugMode) {
                            if (nameController.text.isEmpty)
                              nameController.text = "admin1@sslebd.com";
                            if (passwordController.text.isEmpty)
                              passwordController.text = "#Ssle768";
                          }
                          if(viewModel.loading) return;
                          var status = viewModel.validateUserInformation(
                              nameController.text, passwordController.text);
                          if (status) {
                            viewModel.doLogin(nameController.text.trim(),
                                passwordController.text.trim());
                          } else {
                            _showMsg(viewModel.errorMsg, true);
                          }
                        },
                        text: Strings.btnTextLogin,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child: Row(children: const [
                        Expanded(child: Divider()),
                        Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text("OR", style: TextStyle(color: Colors.grey))),
                        Expanded(child: Divider()),
                      ]),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(10, 12, 10, 0),
                      child: OutlinedButton.icon(
                        onPressed: viewModel.loading
                            ? null
                            : () => viewModel.doGoogleLogin(),
                        icon: const Icon(Icons.g_mobiledata, size: 24),
                        label: const Text("Sign in with Google"),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                        ),
                      ),
                    ),
                    Container(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.all(4),
                          child: TextButton(
                            onPressed: () async {
                              if(viewModel.loading) return;
                              if(nameController.text.isEmpty){
                                _showMsg(Messages.errorUserNameEmpty, true);
                                return;
                              }else {
                                var status = await viewModel.forgetPassword(nameController.text);
                                if (status) {
                                  _showMsg(Messages.successForgetPasswordRequest, false);
                                } else {
                                  _showMsg(viewModel.errorMsg, true);
                                }
                              }
                            },
                            child: Text(
                              "${Strings.btnTextForgetPassword}?",
                              style:
                              const TextStyle(fontSize: 16, color:buttonEnableBgColor ),
                            ),
                          ),
                        )),
                    Container(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(0,16,2,0),
                          child: Text(
                            viewModel.appName,
                            style:
                                const TextStyle(fontSize: 16, color: Colors.orange),
                          ),
                        )),
                    Container(
                      alignment: Alignment.center,
                      child: Text(
                        "v${viewModel.versionName}",
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMsg(String msg, bool isError) {
    if(isError) {
      CustomToast.showErrorToast(msg);
    }else{
      CustomToast.showSuccessToast(msg);
    }
  }
}
