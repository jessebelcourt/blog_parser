import 'package:flutter/material.dart';
import 'package:html_interpreter/src/conversion_utilities/element_type.dart';
import 'package:html_interpreter/src/conversion_utilities/custom_components.dart';
import 'package:html/dom.dart' as dom;
import 'package:flutter_html/flutter_html.dart';
import 'package:html_interpreter/src/conversion_utilities/link_map.dart';
import 'package:html_interpreter/src/conversion_utilities/id_map.dart';
import 'package:html_interpreter/src/conversion_utilities/bus.dart';
import 'package:uuid/uuid.dart';

class RenderHtml extends StatefulWidget {
  final String text;
  final ScrollController scrollcontrol;
  final UnorderdList ul;
  final OrderedList ol;
  final Header h1;
  final Header h2;
  final Header h3;
  final Header h4;
  final Header h5;
  final Header h6;
  final Paragraph p;
  final HR hr;
  final String classToRemove;
  final bool stripEmptyElements;
  final String domain;
  final bool samePageLinking;
  final bool disableLinks;
  final bool followAbsoluteLinks;
  final RegExp omit;

  RenderHtml({
    this.text,
    this.scrollcontrol,
    this.h1,
    this.h2,
    this.h3,
    this.h4,
    this.h5,
    this.h6,
    this.p,
    this.ul,
    this.ol,
    this.hr,
    this.classToRemove,
    this.stripEmptyElements,
    this.domain,
    this.disableLinks,
    this.samePageLinking,
    this.followAbsoluteLinks,
    this.omit,
  });

  _RenderHtmlState createState() => _RenderHtmlState();
}

class _RenderHtmlState extends State<RenderHtml> {
  Bus bus = Bus();
  ScrollController _controller;
  UnorderdList ul;
  OrderedList ol;
  Header h1;
  Header h2;
  Header h3;
  Header h4;
  Header h5;
  Header h6;
  Paragraph p;
  HR hr;
  ConversionEngine engine;
  String classToRemove;
  String domain;
  bool samePageLinking;
  bool stripEmptyElements;
  bool followAbsoluteLinks;
  RegExp omit;

  @override
  void initState() {
    super.initState();

    engine = ConversionEngine(
      ul: widget.ul,
      ol: widget.ol,
      hr: widget.hr,
      p: widget.p,
      h1: widget.h1,
      h2: widget.h2,
      h3: widget.h3,
      h4: widget.h4,
      h5: widget.h5,
      h6: widget.h6,
      classToRemove: widget.classToRemove,
      stripEmptyElements: widget.stripEmptyElements,
      domain: widget.domain,
      samePageLinking: widget.samePageLinking,
      followAbsoluteLinks: widget.followAbsoluteLinks,
      omit: widget.omit,
    );

    _controller = widget.scrollcontrol;
    bus.screenPosition.stream.listen((offset) {
      _goToElement(offset + widget.scrollcontrol.offset - 100);
    });
  }

  void _goToElement(double offset) {
    Duration duration = Duration(milliseconds: 200);
    _controller.animateTo(offset, duration: duration, curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Html(
        data: widget.text ?? '',
        useRichText: false,
        customRender: engine.run,
      ),
    );
  }
}

class ConversionEngine {
  String classToRemove;
  bool stripEmptyElements;
  String domain;
  LinkMap linkMap = LinkMap();
  IDMap idMap = IDMap();
  Uuid uuid = Uuid();
  BuildContext context;
  bool samePageLinking;
  bool disableLinks;
  bool followAbsoluteLinks;
  RegExp omit;

  Header h1;
  Header h2;
  Header h3;
  Header h4;
  Header h5;
  Header h6;
  Paragraph p;
  HR hr;
  UnorderdList ul;
  OrderedList ol;
  TextStyle defaultLinkStyle;

  Function customRender;

  ConversionEngine({
    this.classToRemove,
    this.disableLinks,
    this.customRender,
    this.samePageLinking,
    this.domain,
    this.context,
    bool stripEmptyElements,
    bool followAbsoluteLinks,
    this.omit,
    Header h1,
    Header h2,
    Header h3,
    Header h4,
    Header h5,
    Header h6,
    Paragraph p,
    HR hr,
    UnorderdList ul,
    OrderedList ol,
  }) {
    this.h1 = h1 ?? Header(type: ElementType.h1);
    this.h2 = h2 ?? Header(type: ElementType.h2);
    this.h3 = h3 ?? Header(type: ElementType.h3);
    this.h4 = h4 ?? Header(type: ElementType.h4);
    this.h5 = h5 ?? Header(type: ElementType.h5);
    this.h6 = h6 ?? Header(type: ElementType.h6);
    this.p = p ?? Paragraph(type: ElementType.p);
    this.hr = hr ?? HR(type: ElementType.hr);
    this.ul = ul ?? UnorderdList(type: ElementType.ul);
    this.ol = ol ?? OrderedList(type: ElementType.ol);
    this.stripEmptyElements = stripEmptyElements ?? false;
    this.disableLinks = disableLinks ?? false;
    this.samePageLinking = samePageLinking ?? true;
    this.followAbsoluteLinks = followAbsoluteLinks ?? true;
  }

  bool containsOmission(String text) {
    if (omit != null && text.contains(omit)) {
      print('contains term!');
      return true;
    } else {
      return false;
    }
    // return (omit != null && text.contains(omit));
  }

  void linkInterpolation(dom.Element node) {
    if (!disableLinks) {
      List<dom.Element> els = node.getElementsByTagName('a');
      if (els != null && els.isNotEmpty) {
        els.forEach((link) {
          if (!link.text.contains(RegExp(r'\[FINDME_ID_(.*)_ENDID_\]'))) {
            String href =
                (link.attributes.isNotEmpty ? link.attributes['href'] : null);
            if (href != null && href != '') {
              String id = uuid.v5(Uuid.NAMESPACE_URL, href);
              Uri uri = Uri.parse(href);
              // absolute links
              if (uri.isAbsolute) {
                // does link go to outside source?
                if (domain != null &&
                    domain.isNotEmpty &&
                    !href.contains(domain)) {
                  linkMap.links[id] = {
                    'href': href,
                    'type': 'external',
                    'url_type': 'absolute',
                    'enabled': !disableLinks && followAbsoluteLinks,
                  };
                } else {
                  linkMap.links[id] = {
                    'href': href,
                    'type': 'internal',
                    'url_type': 'absolute',
                    'enabled': !disableLinks && followAbsoluteLinks,
                  };
                }
              } else {
                linkMap.links[id] = {
                  'href': href,
                  'type': 'internal',
                  'url_type': 'relative',
                  'enabled': !disableLinks && samePageLinking,
                };
              }

              if (samePageLinking) {
                RegExp re = RegExp(r'#(.*)$');
                Match m = re.firstMatch(href);
                linkMap.links[id]['to_id'] = (m != null ? m.group(1) : '');
              } else {
                linkMap.links[id]['to_id'] = '';
              }

              linkMap.links[id]['link_text'] = link.text.replaceAll(RegExp(r'\s+|\n'), ' ');
              link.text = '[FINDME_ID_${id}_ENDID_]';
            }
          }
        });
      }
    }
  }

  Widget copyWidgetWithText({dynamic inWidget, dynamic text, String index}) {
    switch (inWidget.type) {
      case ElementType.h1:
      case ElementType.h2:
      case ElementType.h3:
      case ElementType.h4:
      case ElementType.h5:
      case ElementType.h6:
        return Header(
          padding: inWidget.padding,
          margin: inWidget.margin,
          color: inWidget.color,
          fontSize: inWidget.fontSize,
          type: inWidget.type,
          text: text,
          index: index,
        );
      case ElementType.p:
        return Paragraph(
          padding: inWidget.padding,
          margin: inWidget.margin,
          color: inWidget.color,
          fontSize: inWidget.fontSize,
          type: inWidget.type,
          text: text,
          index: index,
        );
      case ElementType.hr:
        return HR(
          margin: inWidget.margin,
          color: inWidget.color,
          height: inWidget.height,
        );
      case ElementType.ul:
        return UnorderdList(
          listPadding: inWidget.listPadding,
          listMargin: inWidget.listMargin,
          listItemPadding: inWidget.listItemPadding,
          listItemMargin: inWidget.listItemMargin,
          fontSize: inWidget.fontSize,
          iconGap: inWidget.iconGap,
          iconSize: inWidget.iconSize,
          iconColor: inWidget.iconColor,
          color: inWidget.color,
          index: index,
          listItems: text,
        );
      case ElementType.ol:
        return OrderedList(
          listPadding: inWidget.listPadding,
          listMargin: inWidget.listMargin,
          listItemPadding: inWidget.listItemPadding,
          listItemMargin: inWidget.listItemMargin,
          fontSize: inWidget.fontSize,
          iconGap: inWidget.iconGap,
          iconSize: inWidget.iconSize,
          iconColor: inWidget.iconColor,
          color: inWidget.color,
          index: index,
          listItems: text,
        );
      default:
        return Container();
    }
  }

  Widget run(dom.Node node, List<Widget> children) {
    //Run customRender first if the user has defined it.
    if (customRender != null) {
      return customRender(node, children);
    }

    if (node is dom.Element) {
      var image = node.querySelector('img');
      if (image != null) {
        return null;
      }

      // Strip empty elements if stripEmptyElements is true
      if (stripEmptyElements && node.text.isEmpty) {
        return Container();
      }

      //Strip annoying unicode characters
      if (node.text.contains(RegExp(r'\u00A0'))) {
        print('node text before: ${node.text}');
        node.text = node.text.replaceAll(RegExp(r'\u00A0'), '');
        print('node text after: ${node.text}');

      }


      // Remove node if it's class is specified in classToRemove
      if (classToRemove != null && node.classes.contains(classToRemove)) {
        return Container();
      }

      // strip tabs

      switch (node.localName) {
        case 'h1':
          node.text = node.text.replaceAll(RegExp(r'\s+|\n'), ' ');
          if (containsOmission(node.text)) {
            return Container();
          }
          linkInterpolation(node);
          return copyWidgetWithText(
            inWidget: h1,
            text: node.text,
            index: node.id,
          );

        case 'h2':
          node.text = node.text.replaceAll(RegExp(r'\s+|\n'), ' ');
          if (containsOmission(node.text)) {
            return Container();
          }
          linkInterpolation(node);
          return copyWidgetWithText(
            inWidget: h2,
            text: node.text,
            index: node.id,
          );

        case 'h3':
          node.text = node.text.replaceAll(RegExp(r'\s+|\n'), ' ');
          if (containsOmission(node.text)) {
            return Container();
          }
          linkInterpolation(node);
          return copyWidgetWithText(
            inWidget: h3,
            text: node.text,
            index: node.id,
          );

        case 'h4':
          node.text = node.text.replaceAll(RegExp(r'\s+|\n'), ' ');
          if (containsOmission(node.text)) {
            return Container();
          }
          linkInterpolation(node);
          return copyWidgetWithText(
            inWidget: h4,
            text: node.text,
            index: node.id,
          );

        case 'h5':
          node.text = node.text.replaceAll(RegExp(r'\s+|\n'), ' ');
          if (containsOmission(node.text)) {
            return Container();
          }
          linkInterpolation(node);
          return copyWidgetWithText(
            inWidget: h5,
            text: node.text,
            index: node.id,
          );

        case 'h6':
          node.text = node.text.replaceAll(RegExp(r'\s+|\n'), ' ');
          if (containsOmission(node.text)) {
            return Container();
          }
          linkInterpolation(node);
          return copyWidgetWithText(
            inWidget: h6,
            text: node.text,
            index: node.id,
          );

        case 'p':
          node.text = node.text.replaceAll(RegExp(r'\s+|\n'), ' ');
          if (containsOmission(node.text)) {
            return Container();
          }
          linkInterpolation(node);
          return copyWidgetWithText(
            inWidget: p,
            text: node.text.replaceAll('\u00A0', ''),
            index: node.id,
          );
        case 'hr':
          return HR(
            height: hr.height,
            color: hr.color,
            margin: hr.margin,
          );

        case 'ul':
          if (containsOmission(node.text)) {
            return Container();
          }

          List<String> li = node.querySelectorAll('li').map((item) {
            linkInterpolation(item);
            item.text = item.text.replaceAll(RegExp(r'\s+|\n'), ' ');

            return item.text;
          }).toList();

          return copyWidgetWithText(
            inWidget: ul,
            text: li,
            index: node.id,
          );
        case 'ol':
          if (containsOmission(node.text)) {
            return Container();
          }

          List<String> li = node.querySelectorAll('li').map((item) {
            linkInterpolation(item);
            item.text = item.text.replaceAll(RegExp(r'\s+|\n'), ' ');

            return item.text;
          }).toList();

          return copyWidgetWithText(
            inWidget: ol,
            text: li,
            index: node.id,
          );

        default:
          return null;
      }
    }
  }
}
