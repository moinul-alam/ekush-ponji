// lib/features/about/about_content.dart

class AboutContent {
  AboutContent._();

  // ── App description ───────────────────────────────────────────

  static String appDescription(bool isBn) => isBn
      ? 'বাংলা, ইংরেজি ও হিজরি ক্যালেন্ডার, সরকারি ছুটির তালিকা, ইভেন্ট, রিমাইন্ডার, ক্যালকুলেটর — সব এক জায়গায়।'
      : 'Bangla, Gregorian, and Hijri calendar, government holidays, events, reminders, calculator — all in one place.';

  // ── Website URL ───────────────────────────────────────────────

  static const String websiteUrl = 'https://ekushponji.ekushlabs.com';
  static const String privacyUrl =
      'https://ekushponji.ekushlabs.com/privacy.html';
  static const String termsUrl = 'https://ekushponji.ekushlabs.com/terms.html';

  // ── Privacy Policy ────────────────────────────────────────────

  static String privacyPolicy(bool isBn) => isBn
      ? '''একুশ পঞ্জি আপনার গোপনীয়তাকে সম্মান করে।

মূল বিষয়সমূহ:

• কোনো ব্যক্তিগত তথ্য সংগ্রহ করা হয় না
• আপনার ইভেন্ট, রিমাইন্ডার ও সেটিংস শুধুমাত্র আপনার ডিভাইসেই থাকে
• কোনো অ্যাকাউন্টের প্রয়োজন নেই
• সেটিংস থেকে যেকোনো সময় সব ডেটা মুছে ফেলতে পারবেন
• বিজ্ঞাপন পরিষেবায় Google AdMob ব্যবহার করা হয়

সম্পূর্ণ নীতি পড়ুন:
$privacyUrl'''
      : '''Ekush Ponji respects your privacy.

Key points:

• No personal data is collected by us
• Your events, reminders & settings stay on your device only
• No account required
• Delete all your data anytime from Settings
• Ads are served by Google AdMob

Read the full policy at:
$privacyUrl''';

  // ── Terms of Service ──────────────────────────────────────────

  static String termsOfService(bool isBn) => isBn
      ? '''একুশ পঞ্জি ব্যবহার করে আপনি নিচের শর্তাবলি মেনে নিচ্ছেন।

মূল বিষয়সমূহ:

• ব্যক্তিগত ও অ-বাণিজ্যিক উদ্দেশ্যে বিনামূল্যে ব্যবহারযোগ্য
• ক্যালেন্ডার বা ছুটির তারিখের নির্ভুলতার গ্যারান্টি দেওয়া হয় না — গুরুত্বপূর্ণ বিষয়ে সরকারি সূত্র থেকে যাচাই করুন
• অ্যাপটি "যেমন আছে" ভিত্তিতে সরবরাহ করা হয়
• আমরা যেকোনো সময় শর্তাবলি পরিবর্তন করার অধিকার রাখি

সম্পূর্ণ শর্তাবলি পড়ুন:
$termsUrl'''
      : '''By using Ekush Ponji, you agree to the following terms.

Key points:

• Free to use for personal, non-commercial purposes
• No guarantees on accuracy of calendar dates or holiday schedules — verify from official sources for critical matters
• The app is provided "as is" without warranty
• We reserve the right to modify these terms at any time

Read the full terms at:
$termsUrl''';
}
