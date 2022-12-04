import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:post_create/constant/constant_value.dart';
import 'package:post_create/controller/create_post_provider_controller.dart';
import 'package:post_create/model/image_model.dart';
import 'package:post_create/post_attach_image/view_image.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class BubblePostAttachedImages extends StatelessWidget {
  const BubblePostAttachedImages({
    this.attachedImages,
    this.onDelete,
    this.createPostController,
    this.hideCrossButton = false,
    this.postSearchKeyword,
    this.isRecommendedPost,
    Key? key,
  }) : super(key: key);
  final List<BubblePostAttachedImageFileModel>? attachedImages;
  final Function? onDelete;
  final CreatePostProviderController? createPostController;
  final bool? hideCrossButton;
  final String? postSearchKeyword; // For post search analytics

  final bool? isRecommendedPost;

  Widget singleImage(BubblePostAttachedImageFileModel imgUrl) => AspectRatio(
        aspectRatio: BubbleImageAspectRatio.STANDARD,
        child: BubbleImageContainer(
          imageList: [imgUrl],
          index: 0,
          onDelete: onDelete,
          hideCrossButton: hideCrossButton,
          postSearchKeyword: postSearchKeyword,
          isRecommendedPost: isRecommendedPost,
        ),
      );

  @override
  Widget build(BuildContext context) {
    if (attachedImages!.length == 1) {
      return singleImage(attachedImages![0]);
    } else if (attachedImages!.length > 1) {
      return BubblePostGridViewImages(
        imageList: attachedImages,
        onDelete: onDelete,
        hideCrossButton: hideCrossButton,
        postSearchKeyword: postSearchKeyword,
        isRecommendedPost: isRecommendedPost,
      );
    }

    return Container();
  }
}

class BubbleImagesOverviewScreen extends StatefulWidget {
  const BubbleImagesOverviewScreen({
    this.imageList,
    this.imageIndex,
    this.onDelete,
  });

  final List<BubblePostAttachedImageFileModel>? imageList;
  final int? imageIndex;
  final Function? onDelete;

  @override
  BubbleImagesOverviewScreenState createState() =>
      BubbleImagesOverviewScreenState(
        imageList: imageList,
        imageIndex: imageIndex,
        onDelete: onDelete,
      );
}

class BubbleImagesOverviewScreenState
    extends State<BubbleImagesOverviewScreen> {
  BubbleImagesOverviewScreenState({
    this.imageList,
    this.imageIndex,
    this.onDelete,
  });

  List<BubblePostAttachedImageFileModel>? imageList;
  int? imageIndex;
  Function? onDelete;

  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        bottom: false,
        child: ScrollablePositionedList.builder(
          initialScrollIndex: imageIndex ?? 0,
          itemPositionsListener: itemPositionsListener,
          itemCount: imageList!.length,
          itemBuilder: (context, index) {
            return Column(
              children: [
                AspectRatio(
                  aspectRatio: BubbleImageAspectRatio.STANDARD,
                  child: BubbleImageContainer(
                    index: index,
                    imageList: imageList,
                    navFromOverviewImages: true,
                    onDelete: onDelete == null
                        ? null
                        : (BubblePostAttachedImageFileModel deletedImage) {
                            imageList!.remove(deletedImage);
                            setState(() {});
                            onDelete!(deletedImage);
                          },
                  ),
                ),
                const SizedBox(height: 121)
              ],
            );
          },
        ),
      ),
    );
  }
}

class BubbleImageContainer extends StatelessWidget {
  const BubbleImageContainer({
    this.index,
    this.imageList,
    this.navFromOverviewImages = false,
    this.onDelete,
    this.hideCrossButton = false,
    this.postSearchKeyword,
    this.isRecommendedPost,
  });

  final Function? onDelete;
  final int? index;
  final List<BubblePostAttachedImageFileModel>? imageList;
  final bool navFromOverviewImages;
  final bool? hideCrossButton;
  final String? postSearchKeyword; // For post search analytics

  final bool? isRecommendedPost;

  @override
  Widget build(BuildContext context) {
    int imageLimit = IMAGE_LIST_MAX;

    return GestureDetector(
      onTap: () {
        if (!hideCrossButton!) {
          // If number of images <= imageLimit, direct to individual image view screen
          if (imageList!.isNotEmpty && imageList!.length <= imageLimit ||
              navFromOverviewImages) {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => BubbleViewImageScreen(
                imageList: imageList,
                imageIndex: index,
              ),
            ));
            // If number of images <= imageLimit, direct to images overview screen
          } else if (imageList!.length > imageLimit) {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => BubbleImagesOverviewScreen(
                imageList: imageList,
                imageIndex: index,
                onDelete: onDelete,
              ),
            ));
          }
        }
      },
      // A stack containing backdrop and the image
      child: ImageContainerWithBackdrop(
        image: imageList![index!],
        onDelete: onDelete,
        hideCrossButton: hideCrossButton,
      ),
    );
  }
}

class ImageContainerWithBackdrop extends StatelessWidget {
  const ImageContainerWithBackdrop({
    Key? key,
    required this.image,
    this.onDelete,
    this.hideCrossButton = false,
  }) : super(key: key);

  final BubblePostAttachedImageFileModel? image;
  final Function? onDelete;
  final bool? hideCrossButton;

  @override
  Widget build(BuildContext context) {
    if (image == null) {
      return Container();
    }

    BubblePostAttachedImageFileModel parsed = image!;
    // Return Container() if parsed.url is null so that it will not throw error when Network(parsed.url)
    if (parsed.localFile == null && parsed.url == null) {
      return Container();
    }
    Image parsedImage = parsed.localFile == null
        ? Image.network(parsed.url!,
            cacheWidth: MediaQuery.of(context).size.width.toInt(),
            fit: BoxFit.contain, errorBuilder: (BuildContext context,
                Object exception, StackTrace? stackTrace) {
            return Container();
          })
        : Image(image: FileImage(File(parsed.localFile!.path)));

    return Stack(
        fit: StackFit.expand,
        alignment: AlignmentDirectional.center,
        children: [
          // Background Image to act as backdrop
          ClipRRect(
            child: Transform.scale(
              scale: 2.0,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      Colors.grey.withOpacity(0.1),
                      BlendMode.hue,
                    ),
                    child: parsedImage,
                  ),
                ),
              ),
            ),
          ),
          // Actual Image to be displayed
          // Positioned left -1 is added to cover the aliasing issues
          Positioned(left: -1, child: parsedImage),
          // x icon
          Offstage(
            offstage: onDelete == null || hideCrossButton!,
            child: Align(
              alignment: Alignment.topRight,
              child: Container(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        onDelete!(image);
                      },
                      child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Icon(Icons.delete)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ]);
  }
}

class BubblePostGridViewImages extends StatelessWidget {
  const BubblePostGridViewImages({
    this.imageList,
    this.onDelete,
    this.hideCrossButton = false,
    this.postSearchKeyword,
    this.isRecommendedPost,
  });

  final Function? onDelete;
  final List<BubblePostAttachedImageFileModel>? imageList;
  final bool? hideCrossButton;

  /// this postId is used for record user tracking action purpose
  final String? postSearchKeyword; // For post search analytics
  final bool? isRecommendedPost;

  List<Widget> buildGridViewChildren(BuildContext context) {
    List<Widget> children = [];
    int imageLimit = IMAGE_LIST_MAX;
    // add BubbleImageContainer like normal for imageList length = 2,3,4
    if (imageList!.length >= 2 && imageList!.length <= imageLimit) {
      for (int i = 0; i < imageList!.length; i++) {
        children.add(BubbleImageContainer(
          index: i,
          imageList: imageList,
          onDelete: onDelete,
          hideCrossButton: hideCrossButton,
          postSearchKeyword: postSearchKeyword,
          isRecommendedPost: isRecommendedPost,
        ));
      }
    }
    // remove first index image for imageList.length = 3
    // the first index image will be display above the grid
    if (imageList!.length == 3) {
      children.removeAt(0);
    }
    // replace the 4th index image to with Stack
    if (imageList!.length > imageLimit) {
      for (int i = 0; i < imageLimit; i++) {
        if (i == imageLimit - 1) {
          // 4th Image (Last limit)
          children.add(
            GestureDetector(
              onTap: () {
                // hideCrossButton=true when it is loading
                // disable onTap when it is loading
                if (!hideCrossButton!) {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => BubbleImagesOverviewScreen(
                      imageList: imageList,
                      imageIndex: 3,
                      onDelete: onDelete,
                    ),
                  ));
                }
              },
              child: Stack(
                children: [
                  BubbleImageContainer(
                    index: imageLimit - 1,
                    imageList: imageList,
                    hideCrossButton: hideCrossButton,
                  ),
                  // If > imageLimit, to display the number of additional image
                  Container(
                    alignment: Alignment.center,
                    color: Colors.grey.withOpacity(0.6),
                    child: Text(
                      '+' + (imageList!.length - imageLimit).toString(),
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          // not 4th Image (Not last limit)
          children.add(BubbleImageContainer(
            index: i,
            imageList: imageList,
            onDelete: onDelete,
            hideCrossButton: hideCrossButton,
          ));
        }
      }
    }

    return children;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (imageList!.length == 3)
          Column(
            children: [
              AspectRatio(
                aspectRatio: BubbleImageAspectRatio.LANDSCAPE,
                child: BubbleImageContainer(
                  imageList: imageList,
                  index: 0,
                  onDelete: onDelete,
                  hideCrossButton: hideCrossButton,
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: imageList!.length > 2 ? 12 : 0.0,
          children: buildGridViewChildren(context),
        ),
      ],
    );
  }
}
