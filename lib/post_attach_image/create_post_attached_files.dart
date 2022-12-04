import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:post_create/model/image_model.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controller/create_post_provider_controller.dart';

class CreatePostAttachedFileConsumer extends StatelessWidget {
  final BuildContext? buildContext;
  final bool isCreatingPost;
  final List<BubblePostAttachedImageFileModel> existingFiles;
  const CreatePostAttachedFileConsumer({
    this.buildContext,
    this.isCreatingPost = false,
    this.existingFiles = const [],
  });
  @override
  Widget build(BuildContext context) {
    return Consumer<CreatePostProviderController>(builder:
        (createPostProviderControllerContext, createPostController, child) {
      return CreatePostAttachedFile(
        buildContext: createPostProviderControllerContext,
        createPostController: createPostController,
        existingFiles: existingFiles,
        isLoading: isCreatingPost,
      );
    });
  }
}

class CreatePostAttachedFile extends StatefulWidget {
  final BuildContext? buildContext;
  final CreatePostProviderController? createPostController;
  final List<BubblePostAttachedImageFileModel> existingFiles;
  final bool isLoading;
  const CreatePostAttachedFile({
    this.buildContext,
    this.createPostController,
    this.existingFiles = const [],
    this.isLoading = false,
  });
  @override
  _CreatePostAttachedFileState createState() => _CreatePostAttachedFileState(
      buildContext: buildContext, createPostController: createPostController);
}

class _CreatePostAttachedFileState extends State<CreatePostAttachedFile> {
  BuildContext? buildContext;
  CreatePostProviderController? createPostController;
  _CreatePostAttachedFileState({this.buildContext, this.createPostController});

  @override
  void initState() {
    super.initState();
    if (widget.existingFiles.isNotEmpty) {
      createPostController!.addFiles(widget.existingFiles);
    }
    createPostController!.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Offstage(
      offstage: createPostController!.attachedFiles.isEmpty,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: BubblePostAttachedFiles(
          attachedFiles: createPostController!.getFiles(),
          onDelete: (BubblePostAttachedImageFileModel file) {
            createPostController!.removeFile(file);
          },
          isDisabled: widget.isLoading,
        ),
      ),
    );
  }
}

class BubblePostAttachedFiles extends StatelessWidget {
  const BubblePostAttachedFiles({
    Key? key,
    this.onDelete,
    this.attachedFiles,
    this.isDisabled = false,
  }) : super(key: key);

  final List<BubblePostAttachedImageFileModel>? attachedFiles;
  final Function? onDelete;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    Color borderColor = Colors.black;

    return Column(
      children: attachedFiles!.map<Widget>((file) {
        return GestureDetector(
          onTap: () {
            if (!isDisabled) {
              if (file.localFile != null) {
                OpenFilex.open(file.localFile!.path);
              } else {
                if (file.url != null) {
                  // Encode url to handle spaces and other non-compliant characters to avoid the launch from crashing the app due to non-compliant characters
                  String encodedUrl = Uri.encodeComponent(file.url!);
                  launch(
                      'https://docs.google.com/gview?embedded=true&url=$encodedUrl');
                }
              }
            }
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
                border: Border.all(
                  color: borderColor,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
                color: Theme.of(context).backgroundColor),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.file_copy),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    file.title != null ? styleTextForEllipsis(file.title) : '',
                    style: isDisabled
                        ? Theme.of(context).textTheme.bodyText2
                        : TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Offstage(
                    offstage: onDelete == null || isDisabled,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                            onTap: () async {
                              onDelete!(file);
                            },
                            child: Icon(
                              Icons.cancel,
                              color: Theme.of(context).primaryColor,
                            ))
                      ],
                    )),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

String styleTextForEllipsis(String? text) {
  if (text == null) {
    return '';
  }

  return Characters(text)
      .replaceAll(Characters(''), Characters('\u{200B}'))
      .toString();
}
