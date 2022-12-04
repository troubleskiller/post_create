import 'package:flutter/material.dart';
import 'package:post_create/constant/constant_value.dart';
import 'package:post_create/model/image_model.dart';
import 'package:provider/provider.dart';

class CreatePostProviderController extends ChangeNotifier {
  List<BubblePostAttachedImageFileModel> images = [];
  List<BubblePostAttachedImageFileModel> attachedFiles = [];

  void refresh() {
    images = [];
    attachedFiles = [];
    notifyListeners();
  }

  void addFiles(List<BubblePostAttachedImageFileModel> newFiles) {
    // Only can set one file
    if (!(attachedFiles.length > uploadFileLimit)) {
      attachedFiles.addAll(newFiles);
      notifyListeners();
    }
  }

  List<BubblePostAttachedImageFileModel> getFiles() {
    return attachedFiles;
  }

  void removeFile(BubblePostAttachedImageFileModel file) {
    attachedFiles.remove(file);
    notifyListeners();
  }

  void addImages(List<BubblePostAttachedImageFileModel> newImages) {
    if ((attachedFiles.length + newImages.length) <= uploadImageLimit) {
      images.addAll(newImages);
      notifyListeners();
    }
  }

  List<BubblePostAttachedImageFileModel> getImages() {
    return images;
  }

  void removeImage(BubblePostAttachedImageFileModel image) {
    images.remove(image);
    notifyListeners();
  }
}

class WithCreatePostProvider {
  static Widget build({
    required Widget child,
  }) {
    return ChangeNotifierProvider(
        create: (context) => CreatePostProviderController(), child: child);
  }
}
