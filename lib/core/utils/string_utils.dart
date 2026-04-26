String getInitials(String name) {
  final List<String> parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((String part) => part.isNotEmpty)
      .toList();
  if (parts.isEmpty) return 'NA';
  return parts.length == 1
      ? parts.first[0].toUpperCase()
      : '${parts.first[0]}${parts.last[0]}'.toUpperCase();
}
