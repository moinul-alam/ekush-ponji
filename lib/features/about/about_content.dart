// lib/features/about/about_content.dart

class AboutContent {
  AboutContent._();

  // ── App description ───────────────────────────────────────────

  static String appDescription(bool isBn) => isBn
      ? 'বাংলা, ইংরেজি ও হিজরি ক্যালেন্ডার, সরকারি ছুটির তালিকা, ইভেন্ট, রিমাইন্ডার, ক্যালকুলেটর — সব এক জায়গায়।'
      : 'Bangla, Gregorian, and Hijri calendar, government holidays, events, reminders, calculator — all in one place.';

  // ── Privacy Policy ────────────────────────────────────────────

  static String privacyPolicy(bool isBn) => isBn
      ? '''একুশ পঞ্জি আপনার গোপনীয়তাকে সম্মান করে।

আমরা কী সংগ্রহ করি
আপনার ব্যক্তিগত পরিচয় সংক্রান্ত কোনো তথ্য সংগ্রহ করা হয় না। আপনার তৈরি ইভেন্ট, রিমাইন্ডার ও সেটিংস শুধুমাত্র আপনার ডিভাইসেই সংরক্ষিত থাকে।

অ্যানালিটিক্স
অ্যাপের উন্নতির জন্য বেনামী ব্যবহার পরিসংখ্যান সংগ্রহ করা হতে পারে। এতে কোনো ব্যক্তিগত তথ্য থাকে না।

তৃতীয় পক্ষ
আমরা কোনো তৃতীয় পক্ষের সাথে আপনার তথ্য বিক্রি বা ভাগ করি না।

যোগাযোগ
কোনো প্রশ্ন বা পরামর্শ থাকলে আমাদের ইমেইল করুন ekushponji@gmail.com'''
      : '''Ekush Ponji respects your privacy.

What We Collect
We do not collect any personally identifiable information. Events, reminders, and settings you create are stored locally on your device only.

Analytics
Anonymous usage statistics may be collected to improve the app. No personal data is included.

Third Parties
We do not sell or share your data with any third parties.

Contact
If you have any questions or suggestions, please email as at ekushponji@gmail.com.''';

  // ── Terms of Service ──────────────────────────────────────────

  static String termsOfService(bool isBn) => isBn
      ? '''একুশ পঞ্জি ব্যবহার করে আপনি নিচের শর্তাবলি মেনে নিচ্ছেন।

ব্যবহারের অনুমতি
এই অ্যাপটি ব্যক্তিগত ও অ-বাণিজ্যিক উদ্দেশ্যে ব্যবহারের জন্য আপনাকে বিনামূল্যে লাইসেন্স প্রদান করা হয়।

দায়মুক্তি
অ্যাপটি "যেমন আছে" ভিত্তিতে সরবরাহ করা হয়। ক্যালেন্ডার বা প্রার্থনার সময়সূচির নির্ভুলতার কোনো গ্যারান্টি দেওয়া হয় না। গুরুত্বপূর্ণ বিষয়ে দাপ্তরিক সূত্র থেকে তথ্য যাচাই করুন।

পরিবর্তন
আমরা যেকোনো সময় এই শর্তাবলি পরিবর্তন করার অধিকার রাখি।

যোগাযোগ
কোনো প্রশ্ন থাকলে আমাদের সাথে যোগাযোগ করুন।'''
      : '''By using Ekush Ponji, you agree to the following terms.

License
You are granted a free, non-exclusive license to use this app for personal, non-commercial purposes.

Disclaimer
The app is provided "as is". We make no guarantees about the accuracy of calendar dates or prayer times. Please verify critical information from official sources.

Changes
We reserve the right to modify these terms at any time. Continued use of the app after changes constitutes your acceptance of the updated terms.

Contact
If you have any questions, please reach out to us.''';
}
