import 'package:bads_sdk/bads_sdk.dart';

class AdModel {
  final String title;
  final String adID;
  final String assetUrl;
  final String previewUrl;
  final String adDescription;
  final double budget;
  final AdType adType;
  final List<dynamic> keywords;
  final List<int> bloomFilter;
  final String lang;
  final String publisherID;
  final String targetURL;

  AdModel(
      this.title,
      this.adID,
      this.assetUrl,
      this.previewUrl,
      this.adDescription,
      this.budget,
      this.adType,
      this.keywords,
      this.bloomFilter,
      this.lang,
      this.publisherID,
      this.targetURL);

  AdModel.fromJson(Map<String, dynamic> json)
      : title = json["title"],
        adID = json["ad_id"],
        assetUrl = json["asset_url"],
        previewUrl = json["preview_url"] ?? "",
        adDescription = json["ad_description"],
        budget = json["budget"].toDouble(),
        adType = AdType.values.elementAt(json["ad_type"]),
        keywords = List<dynamic>.from(json["keywords"]),
        bloomFilter = List<int>.from(json["bloom_filter"]),
        lang = json["lang"][0],
        publisherID = json["publisher_id"],
        targetURL = json["target_url"];
}
