String formatTime(DateTime? time) {
  if (time == null) return 'Now';
  final int hour =
      time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
  final String minute = time.minute.toString().padLeft(2, '0');
  final String suffix = time.hour >= 12 ? 'PM' : 'AM';
  return '$hour:$minute $suffix';
}

String formatDate(DateTime date) {
  const List<String> months = <String>[
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}
