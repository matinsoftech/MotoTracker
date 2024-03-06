import 'package:flutter/material.dart';
import 'package:myvtsproject/data/screens/home/home_screen.dart';
import 'package:myvtsproject/data/screens/singleDeviceSummary/single_fuel_summary.dart';

import '../../../ui/reusable/loader.dart';
import '../../data_sources.dart';

class FuelRefillScreen extends StatefulWidget {
  final List<FuelFillings>? fuelRefills;
  const FuelRefillScreen({
    Key? key,
    required this.fuelRefills,
  }) : super(key: key);

  @override
  State<FuelRefillScreen> createState() => _FuelRefillScreenState();
}

class _FuelRefillScreenState extends State<FuelRefillScreen> {
  List<FuelFillings>? fuelRefills;

  getFuelRefills() async {
    fuelRefills = widget.fuelRefills;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getFuelRefills();
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
        title: const Text("Fuel Refills"),
        centerTitle: true,
        backgroundColor: HomeScreen.primaryDark,
      ),
      body: fuelRefills == null
          ? const Loader()
          : fuelRefills!.isEmpty
              ? const Center(
                  child: Text(
                    "No fuel refills",
                    style: TextStyle(
                      fontSize: 25,
                    ),
                  ),
                )
              : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: fuelRefills?.length ?? 0,
                    itemBuilder: (context, index) {
                      FuelFillings currentFuel = fuelRefills![index];
                      // getAddress(currentFuel);
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
                                        currentFuel.date ?? "",
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
                                        currentFuel.diff ?? "",
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
                                future: getLocation(currentFuel),
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
