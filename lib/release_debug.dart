class ReleaseDebug {
  static void logItem(String tag, dynamic item) {
    print('[$tag] Item Type: ${item.runtimeType}');
    print('[$tag] ID: ${item.id}');
    print('[$tag] Name: ${item.name}');
    print('[$tag] Price: ${item.price}');
    print('[$tag] Size: ${item.size}');
    print('[$tag] Image: ${item.img}');
  }
}
