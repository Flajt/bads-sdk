import '../logic/AppIDManager.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ConnectionDialog extends StatelessWidget {
  const ConnectionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
        child: Container(
      height: 600,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
              child: Image.asset(
            "assets/bads-temp-icon.jpg",
            package: "bads_sdk",
          )),
          Text("This App is Powered by Bads",
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center),
          Text(
            "Privacy friendly mobile advertisment",
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          Text(
            "Please connect to Bads to enable privacy friendly ads, no data is shared or sold to third parties",
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          ElevatedButton(
              onPressed: () async {
                String id = await AppIDManager.getAppID();
                final Uri uri =
                    Uri.parse("submitt://de.triskalion.bads.app/fetch/$id");
                await launchUrl(uri);
              },
              child: const Text("Connect"))
        ],
      ),
    ));
  }
}
