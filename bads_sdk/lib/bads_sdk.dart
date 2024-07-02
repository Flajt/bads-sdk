library bads_sdk;

export 'widgets/BannerAd.dart';
export 'widgets/AdDialogBuilder.dart';

import "dart:convert";
import "dart:math";

import "package:app_links/app_links.dart";
import "package:bads_sdk/logic/AppIDManager.dart";
import "logic/IDService.dart";
import "logic/SecretService.dart";
import "model/AdModel.dart";
import "package:flutter/material.dart";
import "package:flutter/widgets.dart";
import "package:http/http.dart" as http;

//Add
enum AdType {
  // Small Banner
  bannerSmall,
  // Medium size banner
  bannerMedium,
  // Large Banner
  bannerLarge,
  // Intersital
  intersital,
  // Rewarded Ad
  rewardedIntersital
}

class BadsSDK {
  final _idService = IDService();
  final _secretService = SecretService();
  String? serverURL;
  bool initialized = false;
  http.Client client = http.Client();
  BadsSDK._internal();
  factory BadsSDK() => _singleton;
  static final _singleton = BadsSDK._internal();

  Future<void> init(
      {required String serverURL, http.BaseClient? httpClient}) async {
    this.serverURL = serverURL;
    initialized = true;
    if (httpClient != null) {
      client = httpClient;
    }
    bool shouldUpdate = await this.shouldUpdate();
    bool hasSecrets = await _secretService.hasSecrets();
    if (hasSecrets && shouldUpdate) {
      DateTime now = DateTime.now();
      DateTime? lastUpdate = await _secretService.getLastUpdate();
      int dayDifference = 0;
      if (lastUpdate == null) {
        dayDifference = 1;
      } else {
        dayDifference = now.difference(lastUpdate).inDays;
      }
      if (dayDifference >= 1) {
        for (int i = 0; i < dayDifference; i++) {
          await _idService.generateIDs();
          await _idService.generateIDs(type: SecretType.INTERACTION);
        }
        await _secretService.setLastUpdate(DateTime.now());
      }
    }
  }

  Future<List<AdModel>> requestAd(BuildContext context, AdType adType) async {
    if (!initialized) {
      throw Exception("Bads SDK not initialized");
    }
    if (serverURL == null) {
      throw Exception("Server URL not set");
    }
    Locale local = Localizations.localeOf(context);
    String lang = local.languageCode;
    String userID = "";
    List<String> ids = await _idService
        .fetchAdProfileIDs(); // O(1) time and space complexity, since we only generate 3 IDs
    int index = Random.secure().nextInt(ids.length - 1);
    userID = ids[index];
    final uri = Uri.parse(
        "${serverURL!}/ad?user_id=$userID&lang=$lang&ad_type=${adType.index}");
    final resp =
        await client.get(uri); // O(1) time complexity, O(1) space complexity
    Map<String, dynamic> json = jsonDecode(resp.body); // Time O(1) worst O(k)
    if (resp.statusCode == 200) {
      List<dynamic> rawAds =
          json["ads"]; // O(1) time complexity, O(1) space complexity
      List<AdModel> models = rawAds
          .map((e) => AdModel.fromJson(e))
          .toList(); // O(1) time complexity, O(1) space complexity, since only 10 ads are fetched, otherwise O(n) time complexity
      return models;
    } else {
      throw json["error"];
    }
  }

  // In this demo we just fetch the first ad, in prod we would have a more complex selection logic and interaction notification would only happen after click or 1-2s view
  Future<AdModel> fetchAd(BuildContext context, AdType adType) async {
    List<AdModel> adModels = await requestAd(context, adType);
    AdModel ad = selectAd(adModels);
    return ad;
  }

  AdModel selectAd(List<AdModel> ads) {
    // A bit more logic in prod obviously xD
    return ads[0];
  }

  Future<String> calculateUserAdProfileID() async {
    // O(1) time and space complexity
    List<String> ids = await _idService.fetchInteractionIDs();
    Random random = Random.secure();
    return ids[random.nextInt(ids.length - 1)];
  }

  Future<void> nofitfyInteraction(String adID) async {
    // O(1) time and space complexity, worst case O(k) time complexity
    String userID =
        await calculateUserAdProfileID(); // O(1) time and space complexity
    String appID =
        await AppIDManager.getAppID(); // O(1) time and space complexity
    final resp = await client.put(
        Uri.parse(
            "${serverURL!}/interacted-ads"), // Normaly this would happen based via proxy or similar, or the proxy drops an auth token to validate the request
        body: jsonEncode({"ad_id": adID, "user_id": userID, "app_id": appID}),
        headers: {
          "Content-Type": "application/json"
        }); // O(1) best case, O(k) worst case time complexity, O(1) space complexity

    if (resp.statusCode != 201) {
      throw Exception("Failed to notify backend of interaction");
    }
  }

  // Please follow the setup instructions for the [https://pub.dev/packages/app_links](app_links) package
  Future<void> registerConnectionResponseHandler() async {
    final appLinks = AppLinks();
    appLinks.uriLinkStream.listen((event) async {
      debugPrint("Received event: ${event.host}");
      if (event.scheme == "submit") {
        //TODO: In prod replace with non custom scheme
        if (event.host == "de.triskalion.bads.sdk") {
          print(event.toString());
          if (event.queryParameters.containsKey("profile_secret") &&
              event.queryParameters.containsKey("interaction_secret") &&
              event.queryParameters.containsKey("interaction_counter") &&
              event.queryParameters.containsKey("profile_counter") &&
              event.queryParameters.containsKey("last_updated")) {
            final profileSecret = event.queryParameters["profile_secret"]!;
            final lastUpdated =
                DateTime.parse(event.queryParameters["last_updated"]!);
            final interactionSecret =
                event.queryParameters["interaction_secret"]!;
            int interactionCounter =
                int.parse(event.queryParameters["interaction_counter"]!);
            int profileCounter =
                int.parse(event.queryParameters["profile_counter"]!);
            if (profileCounter < 0 || interactionCounter < 0) {
              throw Exception("Invalid counter");
            }
            // The two lines below are required. If the app has already generated some profiles, the counters need to be adjusted to account for the last 3 generated profiles, not starting to generate three new profiles
            if (profileCounter > 0) {
              profileCounter -= 3;
            }
            if (interactionCounter > 0) {
              interactionCounter -= 3;
            }
            await _secretService.saveSecret(
                SecretType.PROFILE, profileSecret, profileCounter);
            await _secretService.saveSecret(
                SecretType.INTERACTION, interactionSecret, interactionCounter);
            await _secretService.setLastUpdate(lastUpdated);
          }
        }
      }
    });
  }

  Future<bool> shouldUpdate() async {
    DateTime now = DateTime.now();
    DateTime? lastUpdate = await _secretService.getLastUpdate();
    if (lastUpdate == null) {
      return true;
    }
    if (lastUpdate.difference(now).inDays >= 1) {
      return true;
    } else {
      return false;
    }
  }
}
