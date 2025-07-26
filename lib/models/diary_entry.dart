class DiaryEntry {
  final String date;
  final String text;

  DiaryEntry({required this.date, required this.text});

  Map<String, dynamic> toJson() => {'date': date, 'text': text};

  factory DiaryEntry.fromJson(Map<String, dynamic> json) =>
      DiaryEntry(date: json['date'], text: json['text']);
}
