import 'package:flutter/material.dart';

import '../../config/static.dart';
import '../../data/screens/home/home_screen.dart';

class CustomDateRangePickerCard extends StatelessWidget {
  var onTap;
  CustomDateRangePickerCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(3, 3),
            )
          ],
        ),
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
                "${StaticVarMethod.fromdate}:${StaticVarMethod.fromtime} - ${StaticVarMethod.todate}:${StaticVarMethod.totime}"),
            const SizedBox(
              width: 20,
            ),
            Icon(
              Icons.calendar_month_outlined,
              color: HomeScreen.primaryDark,
            )
          ],
        ),
      ),
    );
  }
}
