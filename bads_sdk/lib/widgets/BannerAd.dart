import 'dart:async';

import 'package:bads_sdk/bads_sdk.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class BannerAd extends StatefulWidget {
  final AdType adType;
  const BannerAd({super.key, required this.adType});

  @override
  State<BannerAd> createState() => _BannerAdState();
}

class _BannerAdState extends State<BannerAd> with TickerProviderStateMixin {
  late final BadsSDK sdk;
  bool timerRunning = false;
  Timer? _timer;
  @override
  void initState() {
    super.initState();
    sdk = BadsSDK();
    if (!sdk.initialized) {
      throw Exception("Bads SDK not initialized");
    }
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) async {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox.fromSize(
          size: getSize(widget.adType),
          child: FutureBuilder(
              future: sdk.fetchAd(context, widget.adType),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (timerRunning) {
                    _timer?.cancel();
                    timerRunning = false;
                    _timer = Timer.periodic(const Duration(minutes: 1),
                        (timer) async {
                      setState(() {});
                    });
                  }
                  final ad = snapshot.data!;
                  return GestureDetector(
                      onTap: () async {
                        await sdk.nofitfyInteraction(ad.adID);
                        await launchUrl(Uri.parse(ad.targetURL));
                      },
                      child: Image.network(ad.assetUrl));
                } else if (snapshot.hasError) {
                  print(snapshot.error.toString());
                  timerRunning = true;
                  startTimer();
                  return const Text("Error loading ad");
                } else {
                  return const CircularProgressIndicator();
                }
              })),
    );
  }

  void startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 15), (timer) async {
      setState(() {
        print("setState");
      });
    });
  }

  Size getSize(AdType adType) {
    if (adType == AdType.bannerSmall) {
      return const Size(120, 20);
    } else if (adType == AdType.bannerMedium) {
      return const Size(168, 28);
    } else if (adType == AdType.bannerLarge) {
      return const Size(216, 36);
    } else {
      return const Size(120, 20);
    }
  }
}
