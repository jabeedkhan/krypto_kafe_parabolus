import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebviewContainer extends StatelessWidget {
  final url;

  WebviewContainer({Key key, this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: WebView(
                javascriptMode: JavascriptMode.unrestricted,
                initialUrl: url,
                navigationDelegate: (request) {
                  Navigator.pop(context, true);
                  return NavigationDecision.navigate;
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
