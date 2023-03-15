import 'dart:io';

import 'package:flutter/material.dart';

class ImageWidget extends StatelessWidget {
  const ImageWidget(this.imgPath);
  final String imgPath;

  @override
  Widget build(BuildContext context) {
    return Image.file(
      File(imgPath),
      height: 200,
      isAntiAlias: true,
      filterQuality: FilterQuality.medium,
    );
  }
}
