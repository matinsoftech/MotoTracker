import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

import '../../../config/static.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../model/new_report_model.dart';
import '../home/home_screen.dart';

class NewFuelReport extends StatefulWidget {
  NewFuelReport({super.key});

  @override
  State<NewFuelReport> createState() => _NewFuelReportState();
}

class _NewFuelReportState extends State<NewFuelReport> {
  NewModelItem? fuelData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getFuelReport();
  }

  getFuelReport() async {
    isLoading = true;

    http.Response response = await http.post(
      Uri.parse(
          "${StaticVarMethod.baseurlall}/fuel-reports?format=json&_=1679819543064&date_to=${StaticVarMethod.todate}&date_from=${StaticVarMethod.fromdate}&type=10&devices[]=${StaticVarMethod.deviceId}&json=1&title=dasdsad&from_time=00:00&to_time=23:59"),
      body: {
        "user_api_hash": StaticVarMethod.userAPiHash,
      },
    );
    log("Fuel Report Request ${response.request}");
    // log("Fuel Report Response ${response.body}");

    if (response.statusCode == 200) {
      log('success');
      fuelData =
          NewReport.fromJson(jsonDecode(response.body)["data"]).items!.first;

      log("fuel data $fuelData");
      log("fuel data ${fuelData?.fuelReport![0].startDate}");

      isLoading = false;
      setState(() {});
      // } catch (e) {
      //   print(e);
      // }
    } else {
      log('failed');
    }
  }

  double calculateFuelConsumption(
      {double? startFuel,
      double? totalRefills,
      double? currentFuel,
      double? totalThefts}) {
    double fuelConsumption =
        (startFuel! + totalRefills!) - (currentFuel! + totalThefts!);
    return double.parse(fuelConsumption.toStringAsFixed(2));
  }

  //Mileage
  double calculateMileage({double? distanceTravelled, double? fuelConsumed}) {
    log("mileage $fuelConsumed");
    if (distanceTravelled != 0.0 && fuelConsumed != 0.0) {
      return double.parse(
          (distanceTravelled! / fuelConsumed!).toStringAsFixed(2));
    }
    return 0.0;
  }

  Future<Uint8List?> generatePdfFile(List<List<String>> data) async {
    try {
      final pw.Document pdf = pw.Document();

      pdf.addPage(pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              //App name in bold
              pw.SizedBox(height: 10),
              pw.Text(
                'Mero Gadi',
                textAlign: pw.TextAlign.center,
                style:
                    pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 20),
              ),
              pw.SizedBox(height: 10),
              pw.Text('Device Name: ${StaticVarMethod.deviceName}',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text(
                  'Fuel Report from ${StaticVarMethod.fromdate} to ${StaticVarMethod.todate}',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(context: context, data: data),
            ],
          );
        },
      ));

      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String appDocPath = appDocDir.path;
      final String fileName =
          // date for name
          '${StaticVarMethod.fromdate} - ${StaticVarMethod.todate} - ${StaticVarMethod.deviceName}.pdf';
      final String filePath = '$appDocPath/$fileName';

      final Uint8List bytes = await pdf.save();

      await File(filePath).writeAsBytes(bytes);

      print('PDF file saved at: $filePath');

      return bytes;
    } catch (error) {
      print('Error generating PDF file: $error');
      return null;
    }
  }

  Future<void> downloadPdfFile(Uint8List pdfBytes) async {
    try {
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String appDocPath = appDocDir.path;
      final String fileName =
          // date for name
          '${StaticVarMethod.fromdate} - ${StaticVarMethod.todate} - ${StaticVarMethod.deviceName}.pdf';
      final String filePath = '$appDocPath/$fileName';

      await File(filePath).writeAsBytes(pdfBytes);

      // Download the PDF
      print('PDF saved at: $filePath');
      await OpenFile.open(filePath);
    } catch (error) {
      print('Error downloading PDF: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Fuel Summary"),
        centerTitle: true,
        backgroundColor: HomeScreen.primaryDark,
      ),
      body: (isLoading && fuelData == null)
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: HomeScreen.primaryDark.withOpacity(0.2),
                            ),
                            padding: const EdgeInsets.all(10),
                            child: Icon(
                              Icons.local_gas_station_rounded,
                              color: HomeScreen.primaryDark,
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Text(
                            StaticVarMethod.deviceName.toUpperCase(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    border: TableBorder.all(color: Colors.grey.shade300),
                    columnSpacing: 10,
                    columns: const [
                      DataColumn(
                        label: Text(
                          "Date",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "Start Fuel",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "Fuel Refills",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "Fuel Thefts",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "Fuel Consumed",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "End Fuel",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "Distance",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          "Mileage",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ],
                    rows: [
                      for (var item in fuelData!.fuelReport!)
                        DataRow(
                          cells: [
                            DataCell(
                              Text(
                                item.startDate!.toString().split(" ").first,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                item.startValue!.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                item.totalRefill!.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                item.totalTheft!.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                calculateFuelConsumption(
                                        startFuel: item.startValue,
                                        totalRefills: item.totalRefill,
                                        currentFuel: item.endValue,
                                        totalThefts: item.totalTheft)
                                    .toStringAsFixed(1),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                item.endValue!.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                item.totalDistanceTravelled!.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                calculateMileage(
                                        distanceTravelled:
                                            item.totalDistanceTravelled,
                                        fuelConsumed: calculateFuelConsumption(
                                            startFuel: item.startValue,
                                            totalRefills: item.totalRefill,
                                            currentFuel: item.endValue,
                                            totalThefts: item.totalTheft))
                                    .toStringAsFixed(1),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : ListTile(
                        onTap: () {
                          //Make list from ReportDataItem
                          List<List<String>> data = [
                            [
                              "Date",
                              "Start Fuel",
                              "Fuel Refills",
                              "Fuel Thefts",
                              "Fuel Consumed",
                              "End Fuel",
                              "Distance",
                              "Mileage",
                            ],
                            for (var item in fuelData!.fuelReport!)
                              [
                                item.startDate!.toString().split(" ").first,
                                item.startValue!.toStringAsFixed(1),
                                item.totalRefill!.toStringAsFixed(1),
                                item.totalTheft!.toStringAsFixed(1),
                                calculateFuelConsumption(
                                        startFuel: item.startValue,
                                        totalRefills: item.totalRefill,
                                        currentFuel: item.endValue,
                                        totalThefts: item.totalTheft)
                                    .toStringAsFixed(1),
                                item.endValue!.toStringAsFixed(1),
                                item.totalDistanceTravelled!.toStringAsFixed(1),
                                calculateMileage(
                                        distanceTravelled:
                                            item.totalDistanceTravelled,
                                        fuelConsumed: calculateFuelConsumption(
                                            startFuel: item.startValue,
                                            totalRefills: item.totalRefill,
                                            currentFuel: item.endValue,
                                            totalThefts: item.totalTheft))
                                    .toStringAsFixed(1)
                              ],
                          ];

                          //generate and download pdf
                          generatePdfFile(data).then((pdfBytes) {
                            if (pdfBytes != null) {
                              downloadPdfFile(pdfBytes);
                            }
                          });
                        },
                        leading: Icon(
                          Icons.report_outlined,
                          color: HomeScreen.primaryDark,
                        ),
                        title: const Text("Download Report"),
                        trailing: const Icon(Icons.download_outlined),
                      ),
              ],
            ),
    );
  }
}
