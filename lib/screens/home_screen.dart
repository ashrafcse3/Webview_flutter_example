import 'package:flutter/cupertino.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

const String websiteUrl = 'https://bdcabs.com';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Completer<WebViewController> _completer = Completer<WebViewController>();
  WebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    Timer(
      Duration(seconds: 3),
      () {
        setState(() {
          stackToView = 1;
        });
      },
    );
  }

  num stackToView = 0;

  void _onItemTapped(int index) async {
    if (index == 0) {
      // bool canGoBackMine = _webViewController.canGoBack() ? true : false;
      if (await _webViewController.canGoBack()) {
        _webViewController.goBack();
        print('go back is working');
      } else {
        print('can not go back');
      }
    }
    if (index == 1) {
      if (await _webViewController.canGoForward()) {
        _webViewController.goForward();
        print('go forward is working');
      } else {
        print('can not go forward');
      }
    }
    if (index == 2) {
      // to reload the page
      await _webViewController.reload();
    }
    if (index == 3) {
      print('share');
      // print(await _webViewController.currentUrl());
      Share.share('Check out this website $websiteUrl');
    }
  }

  Future<bool> _onWillPop() async {
    if (await _webViewController.canGoBack()) {
      _webViewController.goBack();
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }

  @override
  void dispose() {
    _HomeScreenState();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            // leading: Padding(
            //   padding: const EdgeInsets.only(left: 8.0),
            //   child: Image.asset('assets/images/taxi.png'),
            // ),
            title: Text('BD cabs'),
            backgroundColor: Color(0xFF344955),
          ),
          drawer: Drawer(
              child: ListView(
            children: [
              DrawerHeader(
                child: Center(
                  child: Container(
                    child: Text(
                      "Sunflower 🌻",
                      style: TextStyle(fontSize: 32),
                    ),
                  ),
                ),
              ),
            ],
          )),
          bottomNavigationBar: BottomNavigationBar(
            showSelectedLabels: false,
            showUnselectedLabels: false,
            onTap: _onItemTapped,
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                backgroundColor: Colors.black87,
                icon: Icon(Icons.arrow_back_ios),
                title: Text('back'),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.arrow_forward_ios),
                title: Text('forward'),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.refresh),
                title: Text('reload'),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.share),
                title: Text('share'),
              ),
            ],
          ),
          body: IndexedStack(
            index: stackToView,
            children: <Widget>[
              Center(
                child: CircularProgressIndicator(),
              ),
              WebView(
                initialUrl: websiteUrl,
                javascriptMode: JavascriptMode.unrestricted,
                onWebViewCreated: (webViewController) {
                  _completer.complete(webViewController);
                  _webViewController = webViewController;
                },
                navigationDelegate: (request) async {
                  if (request.url.contains(websiteUrl, 0)) {
                    return NavigationDecision.navigate;
                  } else if (await canLaunch(request.url)) {
                    closeWebView();
                    launch(request.url);
                  }
                  return NavigationDecision.prevent;
                },
                onPageFinished: (_) async {
                  setState(() {
                    stackToView = 1;
                  });
                },
              ),
            ],
          )),
    );
  }
}
