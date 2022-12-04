import 'package:image_picker/image_picker.dart';

class BubbleImageAspectRatio {
  BubbleImageAspectRatio._();

  /// Standard - 3 / 2
  static const double STANDARD = 3 / 2;

  /// Landscape - 2 / 1
  static const double LANDSCAPE = 2 / 1;

  /// Landscape - 2 / 1.1
  static const double VIMEO = 2 / 1.1;
}

class BubblePostAttachedImageFileModel {
  BubblePostAttachedImageFileModel({this.url, this.title, this.localFile});
  String? url;
  String? title;
  XFile? localFile;
  factory BubblePostAttachedImageFileModel.fromJson(
    Map<String, dynamic> json,
  ) =>
      BubblePostAttachedImageFileModel(url: json['url'], title: json['title']);
}
