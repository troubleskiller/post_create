import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class ImageEmbedBuilderWeb implements EmbedBuilder {
  @override
  String get key => BlockEmbed.imageType;

  @override
  Widget build(
    BuildContext context,
    QuillController controller,
    Embed embed,
    bool readOnly,
  ) {
    final String imageUrl = embed.value.data;
    final size = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.only(right: size.width * 0.5),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.45,
        child: HtmlElementView(
          viewType: imageUrl,
        ),
      ),
    );
  }
}

List<EmbedBuilder> get defaultEmbedBuildersWeb => [
      ImageEmbedBuilderWeb(),
      // VideoEmbedBuilderWeb(),
    ];

class RTEHelper {
  Widget defaultEmbedBuilderWeb(
    BuildContext context,
    QuillController controller,
    Embed embed,
    bool readOnly,
  ) {
    switch (embed.value.type) {
      case 'image':
        final String imageUrl = embed.value.data;
        final size = MediaQuery.of(context).size;
        return Padding(
          padding: EdgeInsets.only(right: size.width * 0.5),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.45,
            child: HtmlElementView(
              viewType: imageUrl,
            ),
          ),
        );

      default:
        throw UnimplementedError(
          'Embeddable type "${embed.value.type}" is not supported by default embed '
          'builder of QuillEditor. You must pass your own builder function to '
          'embedBuilder property of QuillEditor or QuillField widgets.',
        );
    }
  }
}

class DeltaToHtml {
  Delta data = Delta();
  void loadDelta(Delta delta) {
    data = delta;
  }

  String applyStylingAttributeToOp(Operation ops, String tempblock) {
    if (ops.attributes != null) {
      ops.attributes!.forEach((key, value) {
        if (key == 'bold' && value == true) {
          tempblock = '<b>$tempblock</b>';
        }
        if (key == 'italic' && value == true) {
          tempblock = '<i>$tempblock</i>';
        }
        if (key == 'underline' && value == true) {
          tempblock = '<u>$tempblock</u>';
        }
        if (key == 'strike' && value == true) {
          tempblock = '<del>$tempblock</del>';
        }
        if (key == 'color') {
          tempblock = '<span style="color:$value">$tempblock</span>';
        }
        if (key == 'background') {
          tempblock = '<span style="background-color:$value">$tempblock</span>';
        }
        if (key == 'link') {
          if (value is String && value.substring(0, 4) != 'http') {
            value = 'https://$value';
          }
          tempblock = '<a href="$value">$tempblock</a>';
        }
      });
    }

    return tempblock;
  }

  // For detecting ul and ol since in the delta, they are always one object after the text
  List<String?> applyLookforwardWrapping(
    Operation ops,
    Operation lookforward,
    String tempblock,
    String? parentblock,
  ) {
    String? tempparentblock;
    RegExp delimiter = RegExp(r'<br/>');
    List<String> texts = tempblock.split(delimiter);
    tempblock = texts.removeLast();
    String nonListItem = texts.join('<br/>');

    if (lookforward.hasAttribute('list')) {
      tempblock = '<li>$tempblock</li>';
      if (lookforward.attributes!['list'] == 'ordered') {
        tempparentblock = 'ol';
      } else if (lookforward.attributes!['list'] == 'bullet') {
        tempparentblock = 'ul';
      }
    }
    if (lookforward.hasAttribute('header') &&
        !lookforward.hasAttribute('list')) {
      tempblock = tempblock.replaceAll('<br/>', '');
      int? headernumber = lookforward.attributes!['header'];
      String headerblock = 'h$headernumber';
      tempblock = '<$headerblock>$tempblock</$headerblock>';
    }

    if (tempparentblock != parentblock) {
      tempblock = '<$tempparentblock>$tempblock';
    }
    tempblock = '$nonListItem$tempblock';

    return [tempblock, tempparentblock];
  }

  String toHTML() {
    String html = '<p>';
    RegExp newline = RegExp(r'\n');
    List<String?> parents = [];
    List<Operation> opslist = data.toList();
    int currentTextOffset = 0;
    for (var i = 0; i < opslist.length; i++) {
      Operation ops = opslist[i];
      String stringData = ops.data as String;
      String tempblock = ops.data as String;
      // handle tags
      currentTextOffset += stringData.length;
      tempblock = tempblock.replaceAll(newline, '<br/>');
      if (tempblock == '<br/>' && ops.attributes != null) {
        continue;
      }
      // handle styling
      tempblock = applyStylingAttributeToOp(ops, tempblock);
      // handle parents
      if (i < opslist.length - 1) {
        String? parent;
        if (parents.isNotEmpty) {
          parent = parents.last;
        }
        // To handle ul and ol
        List<String?> returnData =
            applyLookforwardWrapping(ops, opslist[i + 1], tempblock, parent);
        tempblock = returnData[0]!;
        if (parent != returnData[1]) {
          if (parent != null) {
            tempblock = '</$parent>$tempblock';
          }
          // parents.add(returnData[1]);
          if (parents.isEmpty) {
            parents.add(returnData[1]);
          }
          parents[0] = returnData[1];
        }
      }
      html += tempblock;
    }
    // clean up open tags
    parents.reversed.forEach((parent) {
      html += '</$parent>';
    });
    html += '</p>';

    return html;
  }
}
