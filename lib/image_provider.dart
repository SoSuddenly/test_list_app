import 'package:flutter/widgets.dart';

ImageProvider getImageProvider(String avatarUrl, bool hasInternet) {
  if (hasInternet) {
    return NetworkImage(avatarUrl); // Зображення з Інтернету
  } else {
    return AssetImage('images/no_internet_icon.png'); // Зображення з ресурсів
  }
}
