String formatReportDate(String? createdAt) {
  if (createdAt == null || createdAt.isEmpty) {
    return 'Tanggal tidak diketahui';
  }

  try {
    DateTime parsedDate = DateTime.parse(createdAt);
    return "${parsedDate.toLocal().toIso8601String().split('T')[0]} ${parsedDate.toLocal().hour.toString().padLeft(2, '0')}:${parsedDate.toLocal().minute.toString().padLeft(2, '0')}";
  } catch (e) {
    // Handle any parsing error or return a default value
    return 'Invalid Date';
  }
}
