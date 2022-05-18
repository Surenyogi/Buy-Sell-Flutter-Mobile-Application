// get days/hour/time ago

String getTimeAgo(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);
  if (difference.inDays > 365) {
    return '${difference.inDays ~/ 365} years ago';
  } else if (difference.inDays > 30) {
    return '${difference.inDays ~/ 30} months ago';
  } else if (difference.inDays > 7) {
    return '${difference.inDays ~/ 7} weeks ago';
  } else if (difference.inDays > 0) {
    return '${difference.inDays} days ago';
  } else if (difference.inHours > 0) {
    return '${difference.inHours} hour ago';
  } else if (difference.inMinutes > 0) {
    return '${difference.inMinutes} minutes ago';
  } else {
    return '${difference.inSeconds} seconds ago';
  }
}
