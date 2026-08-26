import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';

import '../models/dropdown_model.dart';

Widget DropDown(List<DropDownModel> items, DropDownModel? selectedItem, String hintText, bool enableSearching, Function onChange){
  final void Function(int) callback;
    return DropdownSearch<DropDownModel>(
      items: items,
      itemAsString: (DropDownModel dropDownModel) => dropDownModel.name,
      selectedItem: selectedItem,
      onChanged: (DropDownModel? data){
        onChange(data);
      },
      dropdownDecoratorProps: dropDownStyle(hintText),
      popupProps: PopupProps.menu(
        fit: FlexFit.loose,
        showSearchBox: enableSearching,
        itemBuilder: customPopupItemBuilder,
      ),
    );
}

Widget customPopupItemBuilder(
    BuildContext context,
    DropDownModel? item,
    bool isSelected,
    ) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 8),
    decoration: !isSelected
        ? null
        : BoxDecoration(
      border: Border.all(color: Theme.of(context).primaryColor),
      borderRadius: BorderRadius.circular(5),
      color: Colors.white,
    ),
    child: ListTile(
      selected: isSelected,
      title: Text(item?.name ?? ''),
    ),
  );
}

dropDownStyle(String hintText) {
  return DropDownDecoratorProps(
    dropdownSearchDecoration: InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: Colors.transparent,
      border: const OutlineInputBorder(
          borderSide: BorderSide(width: 1, color: Colors.black87)),
      enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(width: 0, color: Colors.black87)),
      focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(width: 0, color: Colors.black87)),
      isDense: true, // Added this
      contentPadding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
    ),
  );
}