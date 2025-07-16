import 'dart:math';

class RecommendedListGenerator {
  final List<dynamic> laundrySpecialtyList;
  final List<dynamic> popularSpecialtyList;
  final List<dynamic> favoritesList;

  RecommendedListGenerator({
    required this.laundrySpecialtyList,
    required this.popularSpecialtyList,
    required this.favoritesList,
  });

  List<dynamic> generateRecommendedList() {
    // Combine all the lists
    List<dynamic> combinedList = [];
    combinedList.addAll(laundrySpecialtyList);
    combinedList.addAll(popularSpecialtyList);
    combinedList.addAll(favoritesList);

    // Shuffle the combined list
    combinedList.shuffle(Random());

    // Select the first 10 items or less if there aren't enough items
    return combinedList.take(10).toList();
  }
}
