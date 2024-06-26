import 'package:bads_sdk/logic/SecretService.dart';
import 'package:bads_sdk/widgets/ConnectionDialog.dart';
import 'package:flutter/material.dart';

class AdDialogBuilder extends StatelessWidget {
  const AdDialogBuilder({super.key});

  @override
  Widget build(BuildContext context) {
    final secretService = SecretService();

    return FutureBuilder(
        future: secretService.hasSecrets(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (!snapshot.data!) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const ConnectionDialog());
              });
            } else if (snapshot.hasError) {
              debugPrint(snapshot.error.toString());
            }
          }
          return Container();
        });
  }
}
