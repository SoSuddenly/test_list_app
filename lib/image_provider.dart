import 'package:flutter/widgets.dart';

ImageProvider getImageProvider(String avatarUrl, bool hasInternet) {
  if (hasInternet) {
    return NetworkImage(avatarUrl);
  } else {
    return const AssetImage('images/no_internet_icon.png');
  }
}
