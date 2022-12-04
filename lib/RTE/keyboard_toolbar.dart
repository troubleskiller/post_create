import 'dart:math' as math;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:post_create/constant/constant_value.dart';
import 'package:post_create/controller/create_post_provider_controller.dart';
import 'package:post_create/controller/rte_controller.dart';
import 'package:post_create/model/image_model.dart';
import 'package:provider/provider.dart';

class KeyboardToolbarConsumer extends StatelessWidget {
  final BuildContext? buildContext;
  final bool isCreatingPost;
  const KeyboardToolbarConsumer({
    this.buildContext,
    this.isCreatingPost = false,
  });
  @override
  Widget build(BuildContext context) {
    return Consumer<RTEController>(builder: (_, rteController, child) {
      return Consumer<CreatePostProviderController>(builder:
          (createPostProviderControllerContext, createPostController, child) {
        return Offstage(
          offstage: rteController.getSearchTerm() != null,
          child: KeyboardToolbar(
            buildContext: createPostProviderControllerContext,
            createPostController: createPostController,
            rteController: rteController,
            isCreatingPost: isCreatingPost,
          ),
        );
      });
    });
  }
}

class KeyboardToolbar extends StatefulWidget {
  final BuildContext? buildContext;
  final CreatePostProviderController? createPostController;
  final RTEController? rteController;
  final bool isCreatingPost;
  final bool isEditingComment;
  const KeyboardToolbar({
    this.buildContext,
    this.createPostController,
    this.rteController,
    this.isCreatingPost = false,
    this.isEditingComment = false,
  });
  @override
  _KeyboardToolbarState createState() => _KeyboardToolbarState(
        buildContext: buildContext,
        createPostController: createPostController,
        rteController: rteController,
      );
}

class _KeyboardToolbarState extends State<KeyboardToolbar> {
  BuildContext? buildContext;
  CreatePostProviderController? createPostController;
  RTEController? rteController;
  bool? isComment;
  int commentLength = 0;
  Function? onComment;
  bool isLoading = false;

  _KeyboardToolbarState({
    this.buildContext,
    this.createPostController,
    this.rteController,
  });
  final ImagePicker _picker = ImagePicker();
  Color get iconColor {
    if (widget.isCreatingPost) {
      return Theme.of(context).disabledColor;
    }

    return Theme.of(context).primaryColor;
  }

  @override
  void initState() {
    super.initState();
    rteController!.addListener(() {
      if (rteController!.getAction() == RTEControllerAction.REATTACHRTE) {
        attachRTEListener();
        setState(() {
          commentLength =
              rteController!.controller.document.toPlainText().trim().length;
        });
      }
    });
    attachRTEListener();
  }

  void attachRTEListener() {
    rteController!.controller.addListener(() {
      setState(() {
        commentLength =
            rteController!.controller.document.toPlainText().trim().length;
      });
    });
  }

  @override
  Widget build(BuildContext? context) {
    if (buildContext != null) {
      context = buildContext;
    }
    void uploadImage() async {
      print('1');
      List<XFile>? images = await _picker.pickMultiImage();
      print('0');
      print(images.length);
      // Focus keyboard
      rteController!.setAction(RTEControllerAction.FOCUS);
      if (images == null) {
        return;
      }
      List<BubblePostAttachedImageFileModel> imagesToBeAdded = [];
      for (var xfileImage in images) {
        imagesToBeAdded.add(BubblePostAttachedImageFileModel(
            title: '', url: xfileImage.path, localFile: xfileImage));
      }

      // 50 images limit
      if ((createPostController!.getImages().length + imagesToBeAdded.length) >
          uploadImageLimit) {
        // await InvokeDialog.show('','Only 50 images are allowed.');
        print('Only 50 images are allowed.');
        return;
      }

      createPostController!.addImages(imagesToBeAdded);
    }

    void uploadAttachedFile() async {
      FilePickerResult? result =
          await FilePicker.platform.pickFiles(allowMultiple: true);
      if (result != null) {
        List<BubblePostAttachedImageFileModel> imageToAdd = [];
        List<BubblePostAttachedImageFileModel> fileToAdd = [];

        if (result.files.isNotEmpty) {
          // For all the files from the file picker, map from the Platform file to Xfile format then to BubblePostAttachedImageFileModel format
          List<BubblePostAttachedImageFileModel> attachedImageFileToAdd = result
              .files
              .map((file) => XFile(file.path!,
                  name: file.name, bytes: file.bytes, length: file.size))
              .map((xfile) => BubblePostAttachedImageFileModel(
                  title: xfile.name, url: xfile.path, localFile: xfile))
              .toList();

          attachedImageFileToAdd.forEach((attachedFile) {
            // Ensure that the title is not null and it is at least 2 characters long due to index + 1
            if (attachedFile.title != null && attachedFile.title!.length > 1) {
              /// index of the suffix name
              int index = attachedFile.title!.lastIndexOf('.');
              String extension =
                  attachedFile.title!.substring(index + 1).toLowerCase();
              if (['png', 'jpg', 'jpeg', 'bmp', 'gif'].contains(extension)) {
                imageToAdd.add(attachedFile);
              } else {
                fileToAdd.add(attachedFile);
              }
            }
          });
        }

        // Limit 1 file
        if ((createPostController!.getFiles().length + fileToAdd.length) >
            uploadFileLimit) {
          // await InvokeDialog.show(
          //     '', tr('Only one non image file is allowed.'));
          print('Only one non image file is allowed.');
          return;
        }

        // File size check - cannot be larger than 20mb
        if (fileToAdd.length == 1 && result.files[0].size > 20000000) {
          // await InvokeDialog.show('', tr('File is larger than 20MB.'));
          print('File is larger than 20MB.');
          return;
        }

        createPostController!.addImages(imageToAdd);
        createPostController!.addFiles(fileToAdd);
      } else {
        // User canceled the picker
      }

      // Focus keyboard
      rteController!.setAction(RTEControllerAction.FOCUS);
    }

    return Container(
      // decoration: keyboardToolbarBoxDecoration(context!, shadow: true),
      padding: const EdgeInsets.all(6),
      child: Row(children: [
        // Upload Image
        GestureDetector(
          onTap: () {
            uploadImage();
          },
          child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 7,
              ),
              child: Icon(
                Icons.insert_photo,
                color: iconColor,
                size: 20,
              )),
        ),
        // Upload File
        GestureDetector(
          onTap: () {
            uploadAttachedFile();
          },
          child: Transform.rotate(
            angle: 135 * math.pi / 180,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
              ),
              child: Icon(
                Icons.attachment,
                color: iconColor,
                size: 20,
              ),
            ),
          ),
        ),
        // text count
        Expanded(child: Container(color: Colors.pinkAccent)),
      ]),
    );
  }
}

BoxDecoration keyboardToolbarBoxDecoration(
  BuildContext context, {
  bool shadow = true,
}) {
  return BoxDecoration(
    // color: ColoursBasedOnModes(context).appBarBgColour,
    boxShadow: shadow
        ? [
            const BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.16),
              spreadRadius: 0,
              blurRadius: 3,
              offset: Offset(0, 3),
            ),
            const BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.16),
              spreadRadius: 0,
              blurRadius: 3,
              offset: Offset(0, -3),
            ),
          ]
        : [],
  );
}
