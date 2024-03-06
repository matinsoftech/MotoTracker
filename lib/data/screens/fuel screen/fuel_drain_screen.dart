import 'package:flutter/material.dart';
import 'package:myvtsproject/data/screens/home/home_screen.dart';
import 'package:myvtsproject/data/screens/singleDeviceSummary/single_fuel_summary.dart';

import '../../../ui/reusable/loader.dart';
import '../../data_sources.dart';

class FuelDrainScreen extends StatefulWidget {
  final List<FuelFillings>? fuelDrains;
  const FuelDrainScreen({Key? key, required this.fuelDrains}) : super(key: key);

  @override
  State<FuelDrainScreen> createState() => _FuelDrainScreenState();
}

class _FuelDrainScreenState extends State<FuelDrainScreen> {
  List<FuelFillings>? fuelDrains;

  getFuelThefts() async {
    fuelDrains = widget.fuelDrains;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getFuelThefts();
  }

  Future<String> getLocation(FuelFillings currentFuel) async {
    var currentLocation =
        await GPSAPIS.getGeocoder(currentFuel.lat, currentFuel.lng);
    return currentLocation.body;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Fuel Thefts"),
        centerTitle: true,
        backgroundColor: HomeScreen.primaryDark,
      ),
      body: fuelDrains == null
          ? const Loader()
          : fuelDrains!.isEmpty
              ? const Center(
                  child: Text(
                    "No fuel thefts",
                    style: TextStyle(
                      fontSize: 25,
                    ),
                  ),
                )
              : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    itemCount: fuelDrains?.length ?? 0,
                    itemBuilder: (context, index) {
                      FuelFillings currentFuelDrain = fuelDrains![index];
                      return Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Container(
                          padding: const EdgeInsets.all(15.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                  blurRadius: 10,
                                  offset: const Offset(3, 3),
                                  color: Colors.grey.shade300),
                            ],
                            color: Colors.white,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Date: ",
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(
                                        height: 7,
                                      ),
                                      Text(
                                        currentFuelDrain.date ?? "",
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 15),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "litres: ",
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(
                                        height: 7,
                                      ),
                                      Text(
                                        currentFuelDrain.diff ?? "",
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                              FutureBuilder(
                                future: getLocation(currentFuelDrain),
                                builder: (context, snapshot) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Location: ",
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(
                                        height: 7,
                                      ),
                                      SizedBox(
                                        width: 150,
                                        child: Text(
                                          snapshot.data ?? "",
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 4,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
