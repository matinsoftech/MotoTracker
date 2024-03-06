import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart';
import 'package:myvtsproject/config/static.dart';

import '../data/modelold/report_model.dart';
import '../data/screens/singleDeviceSummary/single_fuel_summary.dart';
import 'package:http/http.dart' as http;

class NotificationHandle {
  Future<List<FuelFillings>> getFuelRefills(String deviceId) async {
    try {
      List<Items>? fuelRefills = null;
      List<FuelFillings> newFuelRefills = [];

      // Your existing code to fetch fuel refills data
      Response response = await http.post(
        Uri.parse(
          "${StaticVarMethod.baseurlall}/reports/update?format=json&_=1679819543064&date_to=${StaticVarMethod.todate}&date_from=${StaticVarMethod.fromdate}&type=11&devices[]=$deviceId&json=1&title=dasdsad&from_time=${StaticVarMethod.fromtime}&to_time=${StaticVarMethod.totime}",
        ),
        body: {
          "user_api_hash": StaticVarMethod.userAPiHash,
        },
      );
      log(response.request!.url.toString());


      fuelRefills =
          ReportModel.fromJson(jsonDecode(response.body)["data"]).items;

      
      // if not null and not empty

      if (fuelRefills != null && fuelRefills.isNotEmpty) {
        // length of fuelRefills
        int dataCount = fuelRefills[0].fuelTankFillings?.sensor6?.length ?? 0;
        //no of refills
        double refills = 0.0;
        //total refills
        double totalRefills = 0.0;
        //last fuel  for checking last and next refill
        double? lastFuelCurrent;

        for (int i = 0; i < dataCount; i++) {
        
          Sensor6 currentRefill = fuelRefills[0].fuelTankFillings!.sensor6![i];
          Sensor6? nextRefill;
          if (i + 1 < dataCount) {
            nextRefill = fuelRefills[0].fuelTankFillings!.sensor6![i + 1];
          }

          if (currentRefill.last != nextRefill?.last) {
            refills = currentRefill.diff!.toDouble();
            totalRefills += refills;

            FuelFillings fuel = FuelFillings(
              date: currentRefill.time,
              lat: currentRefill.lat,
              lng: currentRefill.lng,
              diff: refills.toStringAsFixed(3),
            );
            newFuelRefills.add(fuel);

            lastFuelCurrent = double.tryParse(currentRefill.current!);
          }
        }
      }

      return newFuelRefills; // Return the processed data
    } catch (e) {
      log("Error fetching fuel refills: $e");
      return []; // Return an empty list on error
    }
  }

  Future<List<FuelFillings>> getFuelThefts(String deviceId) async {
    try {
      List<Items>? fuelDrains = null;
      List<FuelFillings> newFuelDrains = [];

      // Your existing code to fetch fuel theft data
      http.Response response = await http.post(
        Uri.parse(
          "${StaticVarMethod.baseurlall}/reports/update?format=json&_=1679819543064&date_to=${StaticVarMethod.todate}&date_from=${StaticVarMethod.fromdate}&type=12&devices[]=$deviceId&json=1&title=dasdsad&from_time=${StaticVarMethod.fromtime}&to_time=${StaticVarMethod.totime}",
        ),
        body: {
          "user_api_hash": StaticVarMethod.userAPiHash,
        },
      );

      fuelDrains =
          ReportModel.fromJson(jsonDecode(response.body)["data"]).items;

      if (fuelDrains != null &&
          fuelDrains.isNotEmpty &&
          fuelDrains[0].fuelTankThefts != null) {
        // Your existing logic to process fuel theft data
        int dataCount = fuelDrains[0].fuelTankThefts!.sensor6?.length ?? 0;
        double totalDrains = 0.0;
        String? lastDrain;

        for (int i = 0; i < dataCount; i++) {
          Sensor6 currentDrain = fuelDrains[0].fuelTankThefts!.sensor6![i];
          Sensor6? nextDrain;
          if (i < dataCount - 1) {
            nextDrain = fuelDrains[0].fuelTankThefts!.sensor6![i + 1];
          }

          if (currentDrain.last != nextDrain?.last) {
            totalDrains += currentDrain.diff!.toDouble();

            FuelFillings fuel = FuelFillings(
              date: currentDrain.time,
              lat: currentDrain.lat,
              lng: currentDrain.lng,
              diff: currentDrain.diff!.toStringAsFixed(3),
            );
            newFuelDrains.add(fuel);

            lastDrain = currentDrain.last;
          }
        }
      }

      return newFuelDrains; // Return the processed data
    } catch (e) {
      log("Error fetching fuel thefts: $e");
      return []; // Return an empty list on error
    }
  }
}
