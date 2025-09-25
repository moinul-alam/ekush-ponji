class AppLocalizationsBn {
  static const String appName = 'একুশ পঞ্জি';
  
  static const List<String> months = [
    'জানুয়ারি', 'ফেব্রুয়ারি', 'মার্চ', 'এপ্রিল', 'মে', 'জুন',
    'জুলাই', 'আগস্ট', 'সেপ্টেম্বর', 'অক্টোবর', 'নভেম্বর', 'ডিসেম্বর'
  ];
  
  static const List<String> numbers = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
  
  static const List<String> weekdays = [
    'সোমবার', 'মঙ্গলবার', 'বুধবার', 'বৃহস্পতিবার', 'শুক্রবার', 'শনিবার', 'রবিবার'
  ];
  
  static const List<String> weekdaysShort = ['সোম', 'মঙ্গল', 'বুধ', 'বৃহ', 'শুক্র', 'শনি', 'রবি'];
  
  static const Map<String, String> eventTypes = {
    'holiday': 'ছুটির দিন',
    'festival': 'উৎসব',
    'religious': 'ধর্মীয়',
    'national': 'জাতীয়',
  };
  
  static const Map<String, String> specialDays = {
    'independence_day': 'স্বাধীনতা দিবস',
    'victory_day': 'বিজয় দিবস',
    'language_day': 'ভাষা দিবস',
  };
  
  // Common UI texts
  static const String today = 'আজ';
  static const String tomorrow = 'আগামীকাল';
  static const String yesterday = 'গতকাল';
  
  // Actions
  static const String add = 'যোগ করুন';
  static const String edit = 'সম্পাদনা';
  static const String delete = 'মুছুন';
  static const String save = 'সংরক্ষণ';
  static const String cancel = 'বাতিল';
  static const String close = 'বন্ধ';
  
  // Navigation
  static const String home = 'হোম';
  static const String calendar = 'ক্যালেন্ডার';
  static const String reminders = 'স্মারক';
  static const String settings = 'সেটিংস';
  
  // Features
  static const String addReminder = 'স্মারক যোগ করুন';
  static const String reminderTitle = 'স্মারকের শিরোনাম';
  static const String selectDate = 'তারিখ নির্বাচন করুন';
  static const String selectTime = 'সময় নির্বাচন করুন';
  
  // Messages
  static const String noRemindersFound = 'কোন স্মারক পাওয়া যায়নি';
  static const String reminderAdded = 'স্মারক যোগ করা হয়েছে';
  static const String error = 'ত্রুটি';
  static const String loading = 'লোড হচ্ছে...';
  
  // Validation
  static const String titleRequired = 'শিরোনাম প্রয়োজন';
  static const String dateRequired = 'তারিখ প্রয়োজন';
  
  // Currency
  static const String currencySymbol = '৳';
}