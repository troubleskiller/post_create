import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:post_create/model/image_model.dart';
import 'package:post_create/util_widget/nagative_padding.dart';

class BubbleViewImageScreen extends StatefulWidget {
  const BubbleViewImageScreen({this.imageList, this.imageIndex = 0});
  final List<BubblePostAttachedImageFileModel>? imageList;
  final int? imageIndex;

  @override
  _BubbleViewImageScreenState createState() => _BubbleViewImageScreenState();
}

class _BubbleViewImageScreenState extends State<BubbleViewImageScreen> {
  int _currentIndex = 1;
  double closedBtnWidthHeight = 40;
  PageController? _pageController;

  Widget numOfImageScrolled() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6,
        ),
        child: Text(
          _currentIndex.toString() + '/' + widget.imageList!.length.toString(),
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget closedButton() {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
      },
      child: Container(
        width: closedBtnWidthHeight,
        height: closedBtnWidthHeight,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(
          Icons.close,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  void onPageChanged(int index) {
    setState(() {
      _currentIndex = index + 1;
    });
  }

  @override
  void initState() {
    super.initState();
    _currentIndex += widget.imageIndex!;
    _pageController = PageController(initialPage: widget.imageIndex!);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageList!.isEmpty || widget.imageList == null) {
      return Container();
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        // Container was not removed to reduce potential conflicts when the lint is initially added
        // TODO: Remove unnecessary container when editing the code below
        // ignore: avoid_unnecessary_containers
        child: Container(
          child: Stack(
            children: [
              // add -ve padding left due to aliasing issues
              AllowNegativePadding(
                padding: const EdgeInsets.only(left: -1),
                child: PhotoViewGallery.builder(
                  itemCount: widget.imageList!.length,
                  pageController: _pageController,
                  builder: (context, index) {
                    BubblePostAttachedImageFileModel parsed =
                        widget.imageList![index];

                    ImageProvider parsedImage = (parsed.localFile == null
                            ? NetworkImage(parsed.url!)
                            : FileImage(File(parsed.localFile!.path)))
                        as ImageProvider<Object>;

                    return PhotoViewGalleryPageOptions(
                      basePosition: Alignment.center,
                      imageProvider: parsedImage,
                      minScale: PhotoViewComputedScale.contained,
                      maxScale: PhotoViewComputedScale.covered * 2,
                    );
                  },
                  onPageChanged: (int index) => onPageChanged(index),
                  scrollPhysics: const BouncingScrollPhysics(),
                  backgroundDecoration: const BoxDecoration(
                    color: Colors.black,
                  ),
                  loadingBuilder: (context, event) => Center(
                    child: Icon(Icons.downloading),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.only(
                  top: 12,
                  left: 6,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Closed button
                    closedButton(),
                    // Number of images scrolled
                    numOfImageScrolled(),
                    // Added a sizedbox here to mimic the Closed button so that the text is display in center of the row
                    const SizedBox(width: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
