List<int> largestRemainderPercentages(List<int> counts) {
  final total = counts.fold<int>(0, (sum, item) => sum + item);
  if (total == 0) return List<int>.filled(counts.length, 0);
  final exact = counts.map((count) => count * 100 / total).toList();
  final result = exact.map((value) => value.floor()).toList();
  var remaining = 100 - result.fold<int>(0, (sum, item) => sum + item);
  final order = List<int>.generate(counts.length, (index) => index)
    ..sort((a, b) => (exact[b] - result[b]).compareTo(exact[a] - result[a]));
  for (var index = 0; index < order.length && remaining > 0; index++) {
    result[order[index]]++;
    remaining--;
  }
  return result;
}
