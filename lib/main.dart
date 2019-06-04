import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:blog_parser/src/conversion_utilities/conversion_engine.dart';
import 'package:blog_parser/src/conversion_utilities/custom_components.dart';

void main() {
  runApp(ArticleViewApp());
}

class ArticleViewApp extends StatefulWidget {
  _ArticleViewAppState createState() => _ArticleViewAppState();
}

class _ArticleViewAppState extends State<ArticleViewApp> {
  ConversionEngine engine = ConversionEngine(
    classToRemove: 'hideme',
    domain: 'amchara.com',
    // customRender: (node, children) {
    //   if (node is dom.Element) {
    //     if (node.localName == 'h1') {
    //       return Text('tisk tisk tisk');
    //     }
    //   }
    // }
  );

  Widget filteredContent(BuildContext context, String rawString) {
    engine.setContext(context);

    return SingleChildScrollView(
      child: Html(
        data: rawString ?? '',
        useRichText: false,
        customRender: engine.run,
      ),
    );
  }

  Widget content(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 15, right: 15),
      child: FutureBuilder(
          future: DefaultAssetBundle.of(context)
              .loadString('assets/example-post.html'),
          builder: (context, snapshot) {
            return filteredContent(context, snapshot.data);
          }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Article View App'),
        ),
        body: content(context),
      ),
    );
  }
}
