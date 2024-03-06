import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../../modelold/devices.dart';
import '../home/home_screen.dart';

class SingleVehicleExpiryScreen extends StatefulWidget {
  final DeviceItems vehicle;
  const SingleVehicleExpiryScreen({super.key, required this.vehicle});

  @override
  State<SingleVehicleExpiryScreen> createState() =>
      _SingleVehicleExpiryScreenState();
}

class _SingleVehicleExpiryScreenState extends State<SingleVehicleExpiryScreen> {
  late ValueNotifier<double> valueNotifier;
  double remainingDays = 0.0;
  double percent = 0.0;
  @override
  void initState() {
    DateTime remainingDate =
        DateTime.parse(widget.vehicle.deviceData!.expirationDate);
    remainingDays = double.parse(
        remainingDate.difference(DateTime.now()).inDays.toString());
    valueNotifier = ValueNotifier(remainingDays);
    percent = (remainingDays / 365) * 1;
    print(remainingDays);
    if (percent < 0.0) {
      percent = 0.0;
      remainingDays = 0;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.vehicle.name ?? ''),
        centerTitle: true,
        backgroundColor: HomeScreen.primaryDark,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  const SizedBox(
                    width: 140,
                    child: Text(
                      "Expiry Date:",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Text(
                    "${widget.vehicle.deviceData!.expirationDate}",
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  const SizedBox(
                    width: 140,
                    child: Text(
                      "IMEI Number:",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Text(
                    "${widget.vehicle.deviceData!.imei}",
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              CircularPercentIndicator(
                radius: 150.0,
                animation: true,
                animationDuration: 5,
                lineWidth: 20.0,
                startAngle: 180,
                percent: percent,
                center: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "$remainingDays",
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                    const Text(
                      "Day(s)",
                      style: TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                    const Text(
                      "Remaining",
                      style: TextStyle(
                        fontSize: 25,
                        color: Colors.black45,
                      ),
                    ),
                  ],
                ),
                progressColor: Colors.green,
              ),
            ],
          ),
        ),
        // child: SimpleCircularProgressBar(
        //   valueNotifier: valueNotifier,
        //   progressColors: const [Colors.green],
        //   progressStrokeWidth: 25,
        //   backStrokeWidth: 25,
        //   size: 250,
        //   startAngle: 180,
        //   animationDuration: 2,
        //   mergeMode: true,
        //   maxValue: 365,
        //   onGetText: (double value) {
        //     return Text(
        //       '${value.toInt()}',
        //       style: const TextStyle(
        //         fontSize: 40,
        //         fontWeight: FontWeight.bold,
        //         color: Colors.black87,
        //       ),
        //     );
        //   },
        // ),
      ),
    );
  }
}
