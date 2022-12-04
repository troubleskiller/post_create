import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:post_create/helper/rte_helper.dart';

enum RTEControllerAction {
  NONE,
  REATTACHRTE,
  FOCUS,
}

class RTEController extends ChangeNotifier {
  QuillController controller = QuillController.basic();
  DeltaToHtml _converter = DeltaToHtml();
  String previousText = '';
  bool isDelete = false;
  String? searchTerm;
  RTEControllerAction? action;
  bool updatedInitialContent = false;

  void refresh() {
    controller.dispose();
    controller = QuillController.basic();
    setAction(RTEControllerAction.REATTACHRTE);
    attachListener();
    _converter = DeltaToHtml();
    previousText = '';
    isDelete = false;
    searchTerm = null;
    action = null;
    updatedInitialContent = false;
  }

  Future<List> checkValidDeltaContent(String data) async {
    var decodedDeltaContent = jsonDecode(data);
    List deltaContent = decodedDeltaContent.map((item) => item).toList();
    deltaContent.forEach((element) {
      // remove invalid color which doesnt start with #
      if ((element['attributes'] != null &&
              element['attributes']['color'] != null) &&
          !element['attributes']['color'].startsWith('#')) {
        element['attributes'].removeWhere((key, value) => key == 'color');
      }
    });

    return deltaContent;
  }

  /// To set RTE textfield initial content
  void setInitialContent(String? deltaContent) {
    controller = QuillController(
      document: Document.fromJson(
        jsonDecode(deltaContent ?? '[{"insert": "\\n"}]'),
      ),
      selection: const TextSelection.collapsed(offset: 0),
    );
    setAction(RTEControllerAction.REATTACHRTE);
    updatedInitialContent = true;
    notifyListeners();
  }

  void attachListener() {
    controller.addListener(() {
      String text = controller.document.toPlainText();
      int diff = text.length - previousText.length;
      isDelete = diff < 0;
    });
  }

  RTEController() {
    attachListener();
  }

  String toHTML() {
    Delta delta = controller.document.toDelta();
    _converter.loadDelta(delta);

    return _converter.toHTML();
  }

  String? getSearchTerm() {
    return searchTerm;
  }

  /// 'focus' - to focus keyboard
  RTEControllerAction? getAction() {
    return action;
  }

  void setAction(RTEControllerAction? new_action) {
    action = new_action;
    notifyListeners();
  }

  void setSearchTerm(String? newTerm) {
    if (searchTerm != newTerm) {
      searchTerm = newTerm;
      notifyListeners();
    }
  }

  int getCurrentOffset() {
    return controller.selection.baseOffset;
  }

  String getLastEntered() {
    String text = controller.document.toPlainText();
    int currentOffset = getCurrentOffset();
    int lastwordIndex;
    RegExp delimiter = RegExp(r'\s');
    if (currentOffset + 1 >= text.length) {
      lastwordIndex = currentOffset;
    } else {
      lastwordIndex = text.indexOf(delimiter, currentOffset);
    }
    if (lastwordIndex == -1) {
      return '';
    }

    return controller.document
        .toPlainText()
        .substring(0, lastwordIndex)
        .split(delimiter)
        .last;
  }
}
