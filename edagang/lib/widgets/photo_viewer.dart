import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class PhotoViewer extends StatelessWidget {
  final String imej;
  PhotoViewer({this.imej});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        backgroundColor: Colors.black.withAlpha(240),
      ),
      backgroundColor: Colors.black.withAlpha(240),
      body: PhotoView(
        imageProvider: NetworkImage(imej),
        minScale: PhotoViewComputedScale.contained * 0.8,
        maxScale: PhotoViewComputedScale.covered * 2,
        enableRotation: false,
        backgroundDecoration: BoxDecoration(
          color: Colors.black.withAlpha(240),
        ),
        /*loadingBuilder: (context, event) => Center(
          child: Container(
            width: 20.0,
            height: 20.0,
            child: CircularProgressIndicator(
              value: event == null
                  ? 0
                  : event.cumulativeBytesLoaded / event.expectedTotalBytes,
            ),
          ),
        ),*/
        loadingChild: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            strokeWidth: 1.5,
          ),
        ),
      ),
    );
  }
}