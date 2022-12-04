import 'package:flutter/material.dart';
import 'package:post_create/util_widget/gestures.dart';

import '../RTE/RTE_textfield.dart';
import '../RTE/RTE_textfield_consumer.dart';
import '../RTE/keyboard_toolbar.dart';
import '../controller/create_post_provider_controller.dart';
import 'create_post_attached_images.dart';

class PostCreate extends StatefulWidget {
  const PostCreate({Key? key}) : super(key: key);

  @override
  State<PostCreate> createState() => _PostCreateState();
}

class _PostCreateState extends State<PostCreate> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: WithRTE.build(
        WithCreatePostProvider.build(
            child: DismissKeyboardGesture(
                bodyContent: Column(
          children: [
            Expanded(
                flex: 1,
                child: CustomScrollView(
                  slivers: [
                    SliverList(
                        delegate: SliverChildListDelegate([
                      SizedBox(
                        height: 100,
                      ),
                      RTETextFieldConsumer(
                        placeholder: 'post here',
                      ),
                      CreatePostAttachedImageConsumer(
                        buildContext: context,
                        isCreatingPost: false,
                        existingImages: [],
                      ),
                    ]))
                  ],
                )),
            KeyboardToolbarConsumer(
              buildContext: context,
              isCreatingPost: true,
            ),
          ],
        ))),
      ),
    );
  }
}
