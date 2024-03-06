import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:myvtsproject/config/static.dart';
import 'package:myvtsproject/data/model/add_alert_request.dart';
import 'package:myvtsproject/provider/alert_provider.dart';
import 'package:provider/provider.dart';
import '../home/home_screen.dart';

class AddAlertScreen extends StatefulWidget {
  const AddAlertScreen({super.key});

  @override
  State<AddAlertScreen> createState() => _AddAlertScreenState();
}

class _AddAlertScreenState extends State<AddAlertScreen> {
  String? selectedevent;
  TextEditingController nameController = TextEditingController();

  TextEditingController speedController = TextEditingController();

  List<int> devicesIds = [];

  void addDevices(int id) {
    if (!devicesIds.contains(id)) {
      devicesIds.add(id);
    } else {
      devicesIds.remove(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Alert"),
        backgroundColor: HomeScreen.primaryDark,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name of Alert',
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 30),
            // Dropdown for selecting an event
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Select Alert Type',
                border: OutlineInputBorder(),
              ),
              value:
                  selectedevent, // This should be replaced by the actual value from the state
              onChanged: (String? newValue) {},
              items: context.watch<AlertProfivider>().alertEvent.map((event) {
                return DropdownMenuItem<String>(
                  value: event.id.toString(),
                  child: Text(event.message ?? ""),
                  onTap: () {
                    selectedevent = event.id.toString();
                    setState(() {});
                  },
                );
              }).toList(),
            ),
            SizedBox(height: 20),

            if (selectedevent == "0")
              TextField(
                  controller: speedController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Speed',
                    border: OutlineInputBorder(),
                  )),

            // TextField for the name of the alert

            ListView.builder(
                shrinkWrap: true,
                itemCount: StaticVarMethod.devicelist.length,
                itemBuilder: (context, index) {
                  return CheckboxListTile(
                      title: Text(StaticVarMethod.devicelist[index].name ?? ""),
                      value: devicesIds
                          .contains(StaticVarMethod.devicelist[index].id),
                      onChanged: (value) {
                        addDevices(StaticVarMethod.devicelist[index].id!);
                        setState(() {});
                      });
                })
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: SizedBox(
          height: 45,
          child: ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  devicesIds.isNotEmpty &&
                  selectedevent != null) {
                var request = AddAlertRequest(
                    name: nameController.text,
                    devices: devicesIds,
                    eventId: int.parse(selectedevent!),
                    speed: speedController.text.isNotEmpty
                        ? int.parse(speedController.text)
                        : null);
                context
                    .read<AlertProfivider>()
                    .addAlert(addAlertRequest: request, context: context);
              } else {
                Fluttertoast.showToast(msg: "Please fill all the fields");
              }
            },
            child: const Text("Add Alert"),
          ),
        ),
      ),
    );
  }
}
