import 'package:flutter/material.dart';

import 'signal_video_stub.dart'
    if (dart.library.js_interop) 'signal_video_web.dart'
    as platform;

class SignalVideo extends StatelessWidget {
  final String url;
  const SignalVideo({super.key, required this.url});
  @override
  Widget build(BuildContext context) => platform.buildVideo(url);
}
