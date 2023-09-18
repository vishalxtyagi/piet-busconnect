import 'package:flutter/material.dart';
import 'package:busconnect/Data/data_model.dart';
import 'package:busconnect/Values/values.dart';
import 'package:busconnect/widgets/Buttons/primary_buttons.dart';
import 'package:busconnect/widgets/DarkBackground/darkRadialBackground.dart';
import 'package:busconnect/widgets/Forms/search_box.dart';
import 'package:busconnect/widgets/Navigation/app_header.dart';
import 'package:busconnect/widgets/employee_card.dart';

class SetAssigneesScreen extends StatelessWidget {
  SetAssigneesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _searchController = new TextEditingController();
    final dynamic data = AppData.employeeData;
    List<Widget> cards = List.generate(
        AppData.employeeData.length,
        (index) => EmployeeCard(
              activated: data[index]['activated'],
              employeeImage: data[index]['employeeImage'],
              employeeName: data[index]['employeeName'],
              backgroundColor: data[index]["color"],
              employeePosition: data[index]["employeePosition"],
            ));
    return Scaffold(
        body: Stack(children: [
      DarkRadialBackground(
        color: HexColor.fromHex("#181a1f"),
        position: "topLeft",
      ),
      SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.only(right: 20, left: 20),
            child: BusConnectAppHeader(
              title: "Set Assignees",
              widget: AppPrimaryButton(
                buttonHeight: 40,
                buttonWidth: 70,
                buttonText: "Next",
              ),
            ),
          ),
          SizedBox(height: 40),
          Expanded(
              flex: 1,
              child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecorationStyles.fadingGlory,
                  child: Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: DecoratedBox(
                          decoration: BoxDecorationStyles.fadingInnerDecor,
                          child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SearchBox(
                                        placeholder: 'Search',
                                        controller: _searchController),
                                    AppSpaces.verticalSpace20,
                                    Expanded(
                                        child: MediaQuery.removePadding(
                                      context: context,
                                      removeTop: true,
                                      child: ListView(children: [...cards]),
                                    ))
                                  ]))))))
        ]),
      )
    ]));
  }
}
