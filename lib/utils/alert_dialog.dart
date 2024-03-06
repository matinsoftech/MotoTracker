import 'consts.dart';
import 'package:flutter/material.dart';

class AlertDialog {
  String title = "", desc = "";
  AlertDialog();

  Widget showError(String title, String desc, BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.only(
          top: Consts.padding,
          bottom: Consts.padding,
          left: Consts.padding,
          right: Consts.padding,
        ),
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(Consts.padding),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10.0,
              offset: Offset(0.0, 10.0),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // To make the card compact
          children: <Widget>[
            Text(
              title,
              style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.w700,
                  color: Colors.red.shade800),
            ),
            const SizedBox(height: 16.0),
            Text(
              desc,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16.0,
              ),
            ),
            const SizedBox(height: 24.0),
            Align(
              alignment: Alignment.bottomRight,
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // To close the dialog
                },
                child: const Text("OK"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
