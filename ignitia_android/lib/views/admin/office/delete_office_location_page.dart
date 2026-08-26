import 'package:flutter/material.dart';
import 'package:i_employment/components/toast_widget.dart';
import 'package:i_employment/models/office/office_location_model.dart';
import 'package:i_employment/utils/navigation_utils.dart';
import 'package:provider/provider.dart';

import '../../../components/app_bar_widget.dart';
import '../../../components/button_widget.dart';
import '../../../components/custom_textfiled.dart';
import '../../../components/error_popup_widget.dart';
import '../../../components/loading_widget.dart';
import '../../../components/textview_widget.dart';
import '../../../utils/constants.dart';
import '../../../utils/message.dart';
import '../../../utils/string.dart';
import '../../../view_models/office_location_view_model.dart';
import '../../menu_page.dart';
import 'office_location_page.dart';

class DeleteOfficeLocationPage extends StatefulWidget {
  final OfficeLocationModel officeLocationModel;
  const DeleteOfficeLocationPage({Key? key, required this.officeLocationModel})
      : super(key: key);

  @override
  State<DeleteOfficeLocationPage> createState() =>
      _DeleteOfficeLocationPageState(this.officeLocationModel);
}

class _DeleteOfficeLocationPageState extends State<DeleteOfficeLocationPage> {
  OfficeLocationModel officeLocationModel;
  _DeleteOfficeLocationPageState(this.officeLocationModel);

  TextEditingController nameController = TextEditingController();
  TextEditingController latitudeController = TextEditingController();
  TextEditingController longitudeController = TextEditingController();
  TextEditingController radiusController = TextEditingController();

  late OfficeLocationViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = Provider.of<OfficeLocationViewModel>(context, listen: false);

    nameController.text = officeLocationModel.name;
    latitudeController.text = officeLocationModel.latitude.toString();
    longitudeController.text = officeLocationModel.longitude.toString();
    radiusController.text = officeLocationModel.radiusMeters.toString();
  }

  @override
  Widget build(BuildContext context) {
    var viewModel = context.watch<OfficeLocationViewModel>();
    var mediaSize = MediaQuery.of(context).size;

    return Scaffold(
        appBar: CustomAppBar(
          title: Strings.titleDeleteOfficeLocationPage,
        ),
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 2, 0, 0),
              child: Row(
                children: [
                  mediaSize.width > webWidth
                      ? Flexible(flex: 1, child: MenuPage())
                      : Container(),
                  Flexible(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ListView(
                        shrinkWrap: false,
                        children: [
                          _nameWidget(),
                          const SizedBox(
                            height: 20,
                          ),
                          _latitudeWidget(),
                          const SizedBox(
                            height: 20,
                          ),
                          _longitudeWidget(),
                          const SizedBox(
                            height: 20,
                          ),
                          _radiusWidget(),
                          const SizedBox(
                            height: 20,
                          ),
                          CustomButton(
                            onTap: () async {
                              if (viewModel.loading) return;
                              var isSuccess = await viewModel
                                  .deleteOfficeLocation(officeLocationModel);
                              if (isSuccess) {
                                openNewUI(context, const OfficeLocationPage());
                                CustomToast.showSuccessToast(
                                    Messages.successRequestDelete);
                              }
                            },
                            text: Strings.btnTextDelete,
                            textSize: 16,
                            buttonColor: Colors.red,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (viewModel.loading) LoadingPage(msg: Messages.progressInProgress),
            if(viewModel.errorMsg.isNotEmpty)
              ErrorPopupPage(msg: viewModel.errorMsg, onOkPressed: (){
                viewModel.setErrorMsg("");
              },),
          ],
        )
    );
  }

  _nameWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          flex: 30,
          child: TitleTextView("${Strings.textOfficeName}: ", textSize: 16),
        ),
        Flexible(
          flex: 70,
          child: CustomTextField(
            isDisable: true,
            hintText: Strings.hintOfficeName,
            floatingLabelBehavior: FloatingLabelBehavior.never,
            textEditingController: nameController,
          ),
        )
      ],
    );
  }

  _latitudeWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          flex: 30,
          child: TitleTextView("${Strings.textLatitude}: ", textSize: 16),
        ),
        Flexible(
          flex: 70,
          child: CustomTextField(
            isDisable: true,
            hintText: Strings.hintLatitude,
            floatingLabelBehavior: FloatingLabelBehavior.never,
            textEditingController: latitudeController,
          ),
        )
      ],
    );
  }

  _longitudeWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          flex: 30,
          child: TitleTextView("${Strings.textLongitude}: ", textSize: 16),
        ),
        Flexible(
          flex: 70,
          child: CustomTextField(
            isDisable: true,
            hintText: Strings.hintLongitude,
            floatingLabelBehavior: FloatingLabelBehavior.never,
            textEditingController: longitudeController,
          ),
        )
      ],
    );
  }

  _radiusWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          flex: 30,
          child: TitleTextView("${Strings.textRadiusMeters}: ", textSize: 16),
        ),
        Flexible(
          flex: 70,
          child: CustomTextField(
            isDisable: true,
            hintText: Strings.hintRadiusMeters,
            floatingLabelBehavior: FloatingLabelBehavior.never,
            textEditingController: radiusController,
          ),
        )
      ],
    );
  }
}
