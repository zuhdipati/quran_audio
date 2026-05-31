extension QoriNameFormatter on String {
  String get formatQoriName {
    if (isEmpty) return this;

    final words = [
      'abdul', 'bari', 'basit', 'aziz', 'rahman', 'rahim', 'muhammad', 
      'ahmed', 'ali', 'mahmoud', 'khalil', 'ibrahim', 'husary', 
      'minshawi', 'mujawwad', 'murattal', 'alafasy', 'sudais', 
      'shuraim', 'rifai', 'jaber', 'dossari', 'ghamdi', 'ajamy', 
      'shatri', 'maher', 'muaiqly', 'mishary', 'rashid', 'abdullah', 
      'juhany', 'matrud', 'ayyub', 'basfar', 'akhdar', 'hudhaify', 
      'salam', 'kareem', 'malik', 'hadi', 'wadood', 'fateh', 'zubair',
      'zahrani', 'thubaity', 'mohammed', 'hazmi'
    ];

    String formatted = toLowerCase();
    for (var word in words) {
      formatted = formatted.replaceAll(word, ' $word ');
    }
    
    formatted = formatted.replaceAll(RegExp(r'\s+'), ' ').trim();

    return formatted.split(' ').map((str) {
      if (str.isEmpty) return str;
      return '${str[0].toUpperCase()}${str.substring(1)}';
    }).join(' ');
  }
}
