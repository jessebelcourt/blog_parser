import 'package:blog_parser/src/conversion_utilities/id_map.dart';
import 'package:flutter/material.dart';
import 'package:blog_parser/src/conversion_utilities/style_values.dart';
import 'package:blog_parser/src/conversion_utilities/element_type.dart';
import 'package:flutter/gestures.dart';
import 'package:blog_parser/src/conversion_utilities/link_map.dart';
import 'package:blog_parser/src/conversion_utilities/id_map.dart';

class HRDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 2,
      color: Colors.black,
    );
  }
}

class Paragraph extends TextBasedElement {
  Paragraph({
    padding,
    margin,
    text,
    fontSize,
    type,
  }) : super(
          padding: padding,
          margin: margin,
          text: text,
          fontSize: fontSize,
          type: type,
        );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      margin: margin,
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            color: Colors.black,
            fontSize: fontSize,
          ),
          children: text,
        ),
      ),
    );
  }
}

mixin TextBasedElementWidgetMixin {
  static Map<ElementType, double> defaultFontSizes = {
    ElementType.h1: H1_FONT_SIZE,
    ElementType.h2: H2_FONT_SIZE,
    ElementType.h3: H3_FONT_SIZE,
    ElementType.h4: H4_FONT_SIZE,
    ElementType.h5: H5_FONT_SIZE,
    ElementType.h6: H6_FONT_SIZE,
    ElementType.p: P_FONT_SIZE,
  };

  final EdgeInsets defaultHeaderPadding = EdgeInsets.all(0);
  final EdgeInsets defaultHeaderMargin = EdgeInsets.all(0);
  final EdgeInsets defaultParPadding = EdgeInsets.all(0);
  final EdgeInsets defaultParMargin = EdgeInsets.only(top: 5, bottom: 5);

  LinkMap linkMap = LinkMap();
  IDMap idMap = IDMap();
  Key keyToId;
  EdgeInsets padding;
  EdgeInsets margin;
  List<TextSpan> text;
  double fontSize;
  ElementType type;
  TextStyle linkStyle;
  TextStyle defaultLinkStyle = TextStyle(
    color: Colors.blue,
    decoration: TextDecoration.underline,
  );

  void setDefaults(ElementType type) {
    switch (type) {
      case ElementType.h1:
      case ElementType.h2:
      case ElementType.h3:
      case ElementType.h4:
      case ElementType.h5:
      case ElementType.h6:
        padding = defaultHeaderPadding;
        margin = defaultHeaderMargin;
        fontSize = defaultFontSizes[type];
        break;
      case ElementType.p:
        padding = defaultParPadding;
        margin = defaultParMargin;
        fontSize = defaultFontSizes[type];
        break;
      default:
        padding = defaultParPadding;
        margin = defaultParMargin;
        fontSize = defaultFontSizes[type];
    }
  }

  List<TextSpan> buildContent(String textIn) {
    textIn = textIn ?? '';
    RegExp re = RegExp(r'\[FINDME_ID_(.*?)_ENDID_\]');
    String findMe;

    const String FINDME_END = '[/FINDME]';
    String temp = textIn;
    List<TextSpan> result = [];
    int indexStart;
    int indexEnd;

    if (re.hasMatch(temp)) {
      while (temp.isNotEmpty) {
        Match m = re.firstMatch(temp);
        String tag = (m != null ? m.group(0) : null);
        indexStart = (tag != null ? temp.indexOf(tag) : -1);
        indexEnd = temp.indexOf(FINDME_END);
        TextSpan input;

        if (indexStart > -1 && indexEnd > -1) {
          Match match = re.firstMatch(temp);
          findMe = match.group(0);
          String id = match.group(1);

          if (indexStart == 0) {
            // adding link
            input = TextSpan(
              text: temp.substring(findMe.length, indexEnd),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  String toId = linkMap.links[id]['to_id'];
                  if (toId.isNotEmpty) {
                    Key keyOfId = idMap.ids[toId];
                    print(keyOfId);
                    // print(_key.currentContext);
                    // MyNotification(title: 'test')..dispatch(context);
                  }
                },
              // ..onTap = () => handleClick,
              style: TextStyle(
                color: Colors.red,
              ),
            );
            result.add(input);
            temp = temp.substring(indexEnd + FINDME_END.length);
          } else if (indexStart > 0) {
            // Not a link
            input = TextSpan(text: temp.substring(0, indexStart));
            result.add(input);
            temp = temp.substring(indexStart);
          } else if (temp.isNotEmpty) {
            input = TextSpan(text: temp);
            result.add(input);
            temp = '';
          }
        } else if (temp.isNotEmpty) {
          input = TextSpan(text: temp);
          result.add(input);
          temp = '';
        }
      }
    } else {
      return [TextSpan(text: textIn)];
    }

    return result;
  }

  Widget cloneWithText(String textIn, dynamic key) {
    List<TextSpan> content = buildContent(textIn);

    switch (type) {
      case ElementType.h1:
      case ElementType.h2:
      case ElementType.h3:
      case ElementType.h4:
      case ElementType.h5:
      case ElementType.h6:
        return Header(
          padding: this.padding,
          margin: this.margin,
          fontSize: this.fontSize,
          text: content,
          type: type,
          key: key,
        );
        break;
      case ElementType.p:
        return Paragraph(
          padding: this.padding,
          margin: this.margin,
          fontSize: this.fontSize,
          type: type,
          text: content,
        );
        break;
      default:
        return Paragraph(
          padding: this.padding,
          margin: this.margin,
          fontSize: this.fontSize,
          type: type,
          text: content,
        );
    }
  }
}

class Paragraph2 extends StatelessWidget with TextBasedElementWidgetMixin {
  
  Offset sizeBox;
  
  Paragraph2({
    padding,
    margin,
    text,
    fontSize,
    type,

  }) {
    print('yooooooo');
    this.type = type ?? ElementType.p;
    setDefaults(type);

    // over ride defaults is set by user
    if (padding != null) {
      this.padding = padding;
    }

    if (margin != null) {
      this.margin = margin;
    }

    if (fontSize != null) {
      this.fontSize = fontSize;
    }

    if (text == null) {
      text = <TextSpan>[TextSpan(text: '')];
    } else {
      this.text = text;
    }

    if (key != null) {
      this.keyToId = key;
    }
  }


  // @override
  // Paragraph2State createState() => Paragraph2State();

  @override
  Widget build(BuildContext context) {
    print('hereeerer');
    final RenderBox renderBox = context.findRenderObject();
    sizeBox = renderBox.localToGlobal(Offset.zero);
    print(sizeBox);
    return Container(
      key: key,
      padding: padding,
      margin: margin,
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            color: Colors.black,
            fontSize: fontSize,
          ),
          children: text,
        ),
      ),
    );
  }
}
// class Header extends TextBasedElement {
class Header extends TextBasedElement {
  Header({
    padding,
    margin,
    text,
    fontSize,
    type,
    key,
  }) : super(
          padding: padding,
          margin: margin,
          text: text,
          fontSize: fontSize,
          type: type,
          key: key,
        );

  @override
  Widget build(BuildContext context) {
    return Row(
      key: super.key,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Flexible(
          child: Container(
            padding: padding,
            margin: margin,
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  color: Colors.black,
                  fontSize: fontSize,
                ),
                children: text,
              ),
            ),
          ),
        )
      ],
    );
  }
}

class TextBasedElement extends StatelessWidget {

  static Map<ElementType, double> defaultFontSizes = {
    ElementType.h1: H1_FONT_SIZE,
    ElementType.h2: H2_FONT_SIZE,
    ElementType.h3: H3_FONT_SIZE,
    ElementType.h4: H4_FONT_SIZE,
    ElementType.h5: H5_FONT_SIZE,
    ElementType.h6: H6_FONT_SIZE,
    ElementType.p: P_FONT_SIZE,
  };

  final EdgeInsets defaultHeaderPadding = EdgeInsets.all(0);
  final EdgeInsets defaultHeaderMargin = EdgeInsets.all(0);
  final EdgeInsets defaultParPadding = EdgeInsets.all(0);
  final EdgeInsets defaultParMargin = EdgeInsets.only(top: 5, bottom: 5);

  LinkMap linkMap = LinkMap();
  IDMap idMap = IDMap();
  Key keyToId;
  EdgeInsets padding;
  EdgeInsets margin;
  List<TextSpan> text;
  double fontSize;
  ElementType type;
  TextStyle linkStyle;
  TextStyle defaultLinkStyle = TextStyle(
    color: Colors.blue,
    decoration: TextDecoration.underline,
  );

  TextBasedElement({
    EdgeInsets padding,
    EdgeInsets margin,
    List<TextSpan> text,
    double fontSize,
    ElementType type,
    Key key,
  }) : super(key: key) {
    this.type = type ?? ElementType.p;
    setDefaults(type);

    // over ride defaults is set by user
    if (padding != null) {
      this.padding = padding;
    }

    if (margin != null) {
      this.margin = margin;
    }

    if (fontSize != null) {
      this.fontSize = fontSize;
    }

    if (text == null) {
      text = <TextSpan>[TextSpan(text: '')];
    } else {
      this.text = text;
    }

    if (key != null) {
      this.keyToId = key;
    }
  }

  void testMe(BuildContext context) {
    print('this works: $context');
  }

  List<TextSpan> buildContent(String textIn) {
    textIn = textIn ?? '';
    RegExp re = RegExp(r'\[FINDME_ID_(.*?)_ENDID_\]');
    String findMe;

    const String FINDME_END = '[/FINDME]';
    String temp = textIn;
    List<TextSpan> result = [];
    int indexStart;
    int indexEnd;

    if (re.hasMatch(temp)) {
      while (temp.isNotEmpty) {
        Match m = re.firstMatch(temp);
        String tag = (m != null ? m.group(0) : null);
        indexStart = (tag != null ? temp.indexOf(tag) : -1);
        indexEnd = temp.indexOf(FINDME_END);
        TextSpan input;

        if (indexStart > -1 && indexEnd > -1) {
          Match match = re.firstMatch(temp);
          findMe = match.group(0);
          String id = match.group(1);

          if (indexStart == 0) {
            // adding link
            input = TextSpan(
              text: temp.substring(findMe.length, indexEnd),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  String toId = linkMap.links[id]['to_id'];
                  if (toId.isNotEmpty) {
                    Key keyOfId = idMap.ids[toId];
                    
                    // print(_key.currentContext);

                    // MyNotification(title: 'test')..dispatch();
                  }
                },
              // ..onTap = () => print(linkMap.links[id]),
              style: TextStyle(
                color: Colors.red,
              ),
            );
            result.add(input);
            temp = temp.substring(indexEnd + FINDME_END.length);
          } else if (indexStart > 0) {
            // Not a link
            input = TextSpan(text: temp.substring(0, indexStart));
            result.add(input);
            temp = temp.substring(indexStart);
          } else if (temp.isNotEmpty) {
            input = TextSpan(text: temp);
            result.add(input);
            temp = '';
          }
        } else if (temp.isNotEmpty) {
          input = TextSpan(text: temp);
          result.add(input);
          temp = '';
        }
      }
    } else {
      return [TextSpan(text: textIn)];
    }

    return result;
  }

  Widget cloneWithText(String textIn, dynamic key) {
    List<TextSpan> content = buildContent(textIn);

    switch (type) {
      case ElementType.h1:
      case ElementType.h2:
      case ElementType.h3:
      case ElementType.h4:
      case ElementType.h5:
      case ElementType.h6:
        return Header(
          padding: this.padding,
          margin: this.margin,
          fontSize: this.fontSize,
          text: content,
          type: type,
          key: key,
        );
        break;
      case ElementType.p:
        return Paragraph(
          padding: this.padding,
          margin: this.margin,
          fontSize: this.fontSize,
          type: type,
          text: content,
        );
        break;
      default:
        return Paragraph(
          padding: this.padding,
          margin: this.margin,
          fontSize: this.fontSize,
          type: type,
          text: content,
        );
    }
  }

  void setDefaults(ElementType type) {
    switch (type) {
      case ElementType.h1:
      case ElementType.h2:
      case ElementType.h3:
      case ElementType.h4:
      case ElementType.h5:
      case ElementType.h6:
        padding = defaultHeaderPadding;
        margin = defaultHeaderMargin;
        fontSize = defaultFontSizes[type];
        break;
      case ElementType.p:
        padding = defaultParPadding;
        margin = defaultParMargin;
        fontSize = defaultFontSizes[type];
        break;
      default:
        padding = defaultParPadding;
        margin = defaultParMargin;
        fontSize = defaultFontSizes[type];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: key,
      padding: padding,
      margin: margin,
      child: RichText(
        text: TextSpan(
          children: text,
        ),
      ),
    );
  }
}

class TestElement extends StatefulWidget {
  TestElement({Key key}) : super(key: key);

  _TestElementState createState() => _TestElementState();
}

class _TestElementState extends State<TestElement> {
  @override
  Widget build(BuildContext context) {
    return Container(
       child: Text('THIS IS A TEST'),
    );
  }
}