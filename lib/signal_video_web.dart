import 'dart:js_interop';

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

Widget buildVideo(String url) => HtmlElementView.fromTagName(
  tagName: 'video',
  onElementCreated: (element) {
    final video = element as web.HTMLVideoElement;
    video
      ..src = url
      ..controls = true
      ..loop = true
      ..muted = true
      ..preload = 'metadata'
      ..setAttribute('playsinline', '')
      ..setAttribute(
        'aria-label',
        'Vídeo do sinal. Use os controles para reproduzir ou repetir.',
      );
    video.style
      ..width = '100%'
      ..height = '100%'
      ..objectFit = 'contain'
      ..borderRadius = '20px'
      ..backgroundColor = '#e7e0fa';
    video.addEventListener(
      'error',
      ((web.Event event) {
        final message = web.document.createElement('p')
          ..textContent =
              'Não foi possível carregar o vídeo. Verifique sua conexão e recarregue a página.';
        video.replaceWith(message);
      }).toJS,
    );
  },
);
