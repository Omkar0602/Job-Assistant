import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class RecentJobs extends StatefulWidget {
  const RecentJobs({super.key});

  @override
  State<RecentJobs> createState() => _RecentJobsState();
}

class _RecentJobsState extends State<RecentJobs> {
  InAppWebViewController? webView;

  Future<void> navigateBack() async {
  if (webView != null && await webView!.canGoBack()) {
    await webView!.goBack();
  }
}
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
    onWillPop: () async {
      if (await webView!.canGoBack()) {
        webView!.goBack();
        return false; // Prevent the app from popping the route
      }
      return true; // Allow the app to pop the route
    },
    child: Scaffold(
      
      body: InAppWebView(initialUrlRequest: URLRequest(url: Uri.parse('https://sites.google.com/view/jobassistant/home'),
      
      ),
      onWebViewCreated: (controller) {
          webView = controller;
        },
        
  )));
}
}
