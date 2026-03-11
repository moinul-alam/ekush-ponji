// convert_quotes.dart
// Run with: dart run convert_quotes.dart
//
// Place this file next to daily_quotes.dart and run from that directory.
// It will output quotes_en.json in the same folder.

import 'dart:convert';
import 'dart:io';

// ── Paste your EnQuote class here ──────────────────────────
class EnQuote {
  final String text;
  final String author;
  final String category;

  const EnQuote({
    required this.text,
    required this.author,
    required this.category,
  });
}

// ── Paste your dailyQuotesEn list here ─────────────────────
// (copy everything from `const List<EnQuote> dailyQuotesEn = [ ... ];`)

// ── Month boundary indices (0-based) ───────────────────────
// Adjust these if your list has different counts per month.
const List<String> _monthNames = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

// Days per month — matches how many quotes you assigned per month.
// Edit these counts to match your actual list sections.
const List<int> _quotesPerMonth = [
  31, // January
  29, // February  (you have 29 quotes in that section)
  31, // March
  31, // April
  31, // May
  31, // June
  31, // July
  31, // August
  30, // September
  30, // October
  30, // November
  31, // December
];

void main() {
  // ── Build the list with month + day ──────────────────────
  final List<Map<String, dynamic>> output = [];

  int index = 0;
  for (int m = 0; m < 12; m++) {
    final int daysInMonth = _quotesPerMonth[m];
    for (int d = 1; d <= daysInMonth; d++) {
      if (index >= dailyQuotesEn.length) {
        print('⚠️  Ran out of quotes at month ${m + 1}, day $d (index $index)');
        break;
      }
      final q = dailyQuotesEn[index];
      output.add({
        'month': m + 1,
        'day': d,
        'text': q.text,
        'author': q.author,
        'category': q.category,
      });
      index++;
    }
  }

  if (index < dailyQuotesEn.length) {
    print(
        '⚠️  ${dailyQuotesEn.length - index} quotes were not assigned a date.');
  }

  // ── Write JSON ────────────────────────────────────────────
  final Map<String, dynamic> json = {
    'version': '1.0.0',
    'language': 'en',
    'count': output.length,
    'quotes': output,
  };

  final file = File('quotes_en.json');
  file.writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert(json),
  );

  print('✅ Written ${output.length} quotes → quotes_en.json');
}

// ── PASTE YOUR LIST BELOW THIS LINE ────────────────────────
const List<EnQuote> dailyQuotesEn = [
  // ── January ───────────────────────────────────────────────
  EnQuote(
    text: 'The only way to do great work is to love what you do.',
    author: 'Steve Jobs',
    category: 'Motivation',
  ),
  EnQuote(
    text: 'In the middle of every difficulty lies opportunity.',
    author: 'Albert Einstein',
    category: 'Philosophy',
  ),
  EnQuote(
    text: 'It does not matter how slowly you go as long as you do not stop.',
    author: 'Confucius',
    category: 'Perseverance',
  ),
  EnQuote(
    text:
        'Success is not final, failure is not fatal: it is the courage to continue that counts.',
    author: 'Winston Churchill',
    category: 'Success',
  ),
  EnQuote(
    text: 'Believe you can and you are halfway there.',
    author: 'Theodore Roosevelt',
    category: 'Motivation',
  ),
  EnQuote(
    text:
        'The future belongs to those who believe in the beauty of their dreams.',
    author: 'Eleanor Roosevelt',
    category: 'Dreams',
  ),
  EnQuote(
    text: 'You miss 100% of the shots you do not take.',
    author: 'Wayne Gretzky',
    category: 'Motivation',
  ),
  EnQuote(
    text: 'Whether you think you can or you think you cannot, you are right.',
    author: 'Henry Ford',
    category: 'Mindset',
  ),
  EnQuote(
    text:
        'The only limit to our realization of tomorrow is our doubts of today.',
    author: 'Franklin D. Roosevelt',
    category: 'Motivation',
  ),
  EnQuote(
    text: 'The purpose of our lives is to be happy.',
    author: 'Dalai Lama',
    category: 'Philosophy',
  ),
  EnQuote(
    text: 'Life is what happens when you are busy making other plans.',
    author: 'John Lennon',
    category: 'Philosophy',
  ),
  EnQuote(
    text: 'You only live once, but if you do it right, once is enough.',
    author: 'Mae West',
    category: 'Philosophy',
  ),
  EnQuote(
    text:
        'Many of life\'s failures are people who did not realize how close they were to success when they gave up.',
    author: 'Thomas Edison',
    category: 'Perseverance',
  ),
  EnQuote(
    text:
        'If you want to live a happy life, tie it to a goal, not to people or things.',
    author: 'Albert Einstein',
    category: 'Philosophy',
  ),
  EnQuote(
    text: 'If you look at what you have in life, you will always have more.',
    author: 'Oprah Winfrey',
    category: 'Gratitude',
  ),
  EnQuote(
    text: 'Never let the fear of striking out keep you from playing the game.',
    author: 'Babe Ruth',
    category: 'Courage',
  ),
  EnQuote(
    text:
        'Your time is limited, so do not waste it living someone else\'s life.',
    author: 'Steve Jobs',
    category: 'Philosophy',
  ),
  EnQuote(
    text: 'Not how long, but how well you have lived is the main thing.',
    author: 'Seneca',
    category: 'Philosophy',
  ),
  EnQuote(
    text:
        'Take up one idea. Make that one idea your life — think of it, dream of it, live on that idea.',
    author: 'Swami Vivekananda',
    category: 'Focus',
  ),
  EnQuote(
    text: 'All our dreams can come true if we have the courage to pursue them.',
    author: 'Walt Disney',
    category: 'Dreams',
  ),
  EnQuote(
    text: 'I find that the harder I work, the more luck I seem to have.',
    author: 'Thomas Jefferson',
    category: 'Work',
  ),
  EnQuote(
    text:
        'Success usually comes to those who are too busy to be looking for it.',
    author: 'Henry David Thoreau',
    category: 'Success',
  ),
  EnQuote(
    text: 'Opportunities do not happen. You create them.',
    author: 'Chris Grosser',
    category: 'Motivation',
  ),
  EnQuote(
    text: 'Do not be afraid to give up the good to go for the great.',
    author: 'John D. Rockefeller',
    category: 'Ambition',
  ),
  EnQuote(
    text:
        'A successful man is one who can lay a firm foundation with the bricks others have thrown at him.',
    author: 'David Brinkley',
    category: 'Resilience',
  ),
  EnQuote(
    text: 'No one can make you feel inferior without your consent.',
    author: 'Eleanor Roosevelt',
    category: 'Self-worth',
  ),
  EnQuote(
    text: 'If you are going through hell, keep going.',
    author: 'Winston Churchill',
    category: 'Perseverance',
  ),
  EnQuote(
    text:
        'The ones who are crazy enough to think they can change the world are the ones that do.',
    author: 'Steve Jobs',
    category: 'Vision',
  ),
  EnQuote(
    text: 'Do what you can, with what you have, where you are.',
    author: 'Theodore Roosevelt',
    category: 'Action',
  ),
  EnQuote(
    text: 'It is not the mountain we conquer, but ourselves.',
    author: 'Edmund Hillary',
    category: 'Self-mastery',
  ),
  EnQuote(
    text:
        'Happiness is not something readymade. It comes from your own actions.',
    author: 'Dalai Lama',
    category: 'Happiness',
  ),

  // ── February ──────────────────────────────────────────────
  EnQuote(
    text:
        'If you want to go fast, go alone. If you want to go far, go together.',
    author: 'African Proverb',
    category: 'Teamwork',
  ),
  EnQuote(
    text: 'Keep your eyes on the stars and your feet on the ground.',
    author: 'Theodore Roosevelt',
    category: 'Balance',
  ),
  EnQuote(
    text: 'You are never too old to set another goal or to dream a new dream.',
    author: 'C. S. Lewis',
    category: 'Dreams',
  ),
  EnQuote(
    text:
        'Too many of us are not living our dreams because we are living our fears.',
    author: 'Les Brown',
    category: 'Courage',
  ),
  EnQuote(
    text:
        'I have not failed. I have just found 10,000 ways that will not work.',
    author: 'Thomas Edison',
    category: 'Perseverance',
  ),
  EnQuote(
    text:
        'Remember that not getting what you want is sometimes a wonderful stroke of luck.',
    author: 'Dalai Lama',
    category: 'Philosophy',
  ),
  EnQuote(
    text: 'Dream big and dare to fail.',
    author: 'Norman Vaughan',
    category: 'Ambition',
  ),
  EnQuote(
    text:
        'Our greatest glory is not in never falling, but in rising every time we fall.',
    author: 'Confucius',
    category: 'Resilience',
  ),
  EnQuote(
    text: 'Life is 10% what happens to us and 90% how we react to it.',
    author: 'Charles R. Swindoll',
    category: 'Mindset',
  ),
  EnQuote(
    text: 'An unexamined life is not worth living.',
    author: 'Socrates',
    category: 'Philosophy',
  ),
  EnQuote(
    text:
        'Spread love everywhere you go. Let no one ever come to you without leaving happier.',
    author: 'Mother Teresa',
    category: 'Kindness',
  ),
  EnQuote(
    text:
        'Do not judge each day by the harvest you reap but by the seeds that you plant.',
    author: 'Robert Louis Stevenson',
    category: 'Patience',
  ),
  EnQuote(
    text:
        'The best time to plant a tree was 20 years ago. The second best time is now.',
    author: 'Chinese Proverb',
    category: 'Action',
  ),
  EnQuote(
    text:
        'It is during our darkest moments that we must focus to see the light.',
    author: 'Aristotle',
    category: 'Hope',
  ),
  EnQuote(
    text: 'Whoever is happy will make others happy too.',
    author: 'Anne Frank',
    category: 'Happiness',
  ),
  EnQuote(
    text:
        'Do not go where the path may lead; go instead where there is no path and leave a trail.',
    author: 'Ralph Waldo Emerson',
    category: 'Leadership',
  ),
  EnQuote(
    text:
        'You will face many defeats in life, but never let yourself be defeated.',
    author: 'Maya Angelou',
    category: 'Resilience',
  ),
  EnQuote(
    text:
        'In the end, it is not the years in your life that count. It is the life in your years.',
    author: 'Abraham Lincoln',
    category: 'Philosophy',
  ),
  EnQuote(
    text: 'Life is either a daring adventure or nothing at all.',
    author: 'Helen Keller',
    category: 'Adventure',
  ),
  EnQuote(
    text:
        'You have power over your mind, not outside events. Realize this, and you will find strength.',
    author: 'Marcus Aurelius',
    category: 'Stoicism',
  ),
  EnQuote(
    text:
        'The impediment to action advances action. What stands in the way becomes the way.',
    author: 'Marcus Aurelius',
    category: 'Stoicism',
  ),
  EnQuote(
    text:
        'Very little is needed to make a happy life; it is all within yourself, in your way of thinking.',
    author: 'Marcus Aurelius',
    category: 'Stoicism',
  ),
  EnQuote(
    text: 'Waste no more time arguing about what a good man should be. Be one.',
    author: 'Marcus Aurelius',
    category: 'Stoicism',
  ),
  EnQuote(
    text:
        'Begin at once to live, and count each separate day as a separate life.',
    author: 'Seneca',
    category: 'Philosophy',
  ),
  EnQuote(
    text: 'Luck is what happens when preparation meets opportunity.',
    author: 'Seneca',
    category: 'Success',
  ),
  EnQuote(
    text: 'We suffer more in imagination than in reality.',
    author: 'Seneca',
    category: 'Stoicism',
  ),
  EnQuote(
    text: 'Difficulties strengthen the mind, as labor does the body.',
    author: 'Seneca',
    category: 'Growth',
  ),
  EnQuote(
    text: 'He who fears death will never do anything worthy of a living man.',
    author: 'Seneca',
    category: 'Courage',
  ),
  EnQuote(
    text:
        'The key is not to prioritize what is on your schedule, but to schedule your priorities.',
    author: 'Stephen Covey',
    category: 'Productivity',
  ),

  // ── March ─────────────────────────────────────────────────
  EnQuote(
    text: 'The secret of getting ahead is getting started.',
    author: 'Mark Twain',
    category: 'Action',
  ),
  EnQuote(
    text:
        'Twenty years from now you will be more disappointed by the things you did not do than by the ones you did.',
    author: 'Mark Twain',
    category: 'Action',
  ),
  EnQuote(
    text:
        'Courage is resistance to fear, mastery of fear — not absence of fear.',
    author: 'Mark Twain',
    category: 'Courage',
  ),
  EnQuote(
    text:
        'The two most important days in your life are the day you are born and the day you find out why.',
    author: 'Mark Twain',
    category: 'Purpose',
  ),
  EnQuote(
    text: 'Keep away from people who try to belittle your ambitions.',
    author: 'Mark Twain',
    category: 'Motivation',
  ),
  EnQuote(
    text: 'It always seems impossible until it is done.',
    author: 'Nelson Mandela',
    category: 'Motivation',
  ),
  EnQuote(
    text:
        'Education is the most powerful weapon which you can use to change the world.',
    author: 'Nelson Mandela',
    category: 'Education',
  ),
  EnQuote(
    text:
        'I am not a product of my circumstances. I am a product of my decisions.',
    author: 'Stephen Covey',
    category: 'Responsibility',
  ),
  EnQuote(
    text: 'Act as if what you do makes a difference. It does.',
    author: 'William James',
    category: 'Purpose',
  ),
  EnQuote(
    text:
        'Success is stumbling from failure to failure with no loss of enthusiasm.',
    author: 'Winston Churchill',
    category: 'Resilience',
  ),
  EnQuote(
    text: 'You must be the change you wish to see in the world.',
    author: 'Mahatma Gandhi',
    category: 'Leadership',
  ),
  EnQuote(
    text:
        'The weak can never forgive. Forgiveness is the attribute of the strong.',
    author: 'Mahatma Gandhi',
    category: 'Wisdom',
  ),
  EnQuote(
    text:
        'First they ignore you, then they laugh at you, then they fight you, then you win.',
    author: 'Mahatma Gandhi',
    category: 'Perseverance',
  ),
  EnQuote(
    text:
        'Strength does not come from physical capacity. It comes from an indomitable will.',
    author: 'Mahatma Gandhi',
    category: 'Willpower',
  ),
  EnQuote(
    text:
        'The best way to find yourself is to lose yourself in the service of others.',
    author: 'Mahatma Gandhi',
    category: 'Service',
  ),
  EnQuote(
    text: 'Imagination is more important than knowledge.',
    author: 'Albert Einstein',
    category: 'Creativity',
  ),
  EnQuote(
    text: 'A person who never made a mistake never tried anything new.',
    author: 'Albert Einstein',
    category: 'Growth',
  ),
  EnQuote(
    text:
        'Logic will get you from A to Z; imagination will get you everywhere.',
    author: 'Albert Einstein',
    category: 'Creativity',
  ),
  EnQuote(
    text:
        'Life is like riding a bicycle. To keep your balance you must keep moving.',
    author: 'Albert Einstein',
    category: 'Philosophy',
  ),
  EnQuote(
    text: 'Strive not to be a success, but rather to be of value.',
    author: 'Albert Einstein',
    category: 'Purpose',
  ),
  EnQuote(
    text: 'Darkness cannot drive out darkness; only light can do that.',
    author: 'Martin Luther King Jr.',
    category: 'Philosophy',
  ),
  EnQuote(
    text: 'The time is always right to do what is right.',
    author: 'Martin Luther King Jr.',
    category: 'Ethics',
  ),
  EnQuote(
    text:
        'Faith is taking the first step even when you do not see the whole staircase.',
    author: 'Martin Luther King Jr.',
    category: 'Faith',
  ),
  EnQuote(
    text:
        'If you cannot fly then run; if you cannot run then walk; if you cannot walk then crawl — but whatever you do, keep moving.',
    author: 'Martin Luther King Jr.',
    category: 'Perseverance',
  ),
  EnQuote(
    text:
        'I have learned that people will forget what you said, but never how you made them feel.',
    author: 'Maya Angelou',
    category: 'Wisdom',
  ),
  EnQuote(
    text: 'Nothing will work unless you do.',
    author: 'Maya Angelou',
    category: 'Work',
  ),
  EnQuote(
    text: 'My mission in life is not merely to survive, but to thrive.',
    author: 'Maya Angelou',
    category: 'Purpose',
  ),
  EnQuote(
    text:
        'To know what you know and what you do not know, that is true knowledge.',
    author: 'Confucius',
    category: 'Wisdom',
  ),
  EnQuote(
    text: 'Everything has beauty, but not everyone sees it.',
    author: 'Confucius',
    category: 'Philosophy',
  ),
  EnQuote(
    text:
        'He who learns but does not think is lost. He who thinks but does not learn is in great danger.',
    author: 'Confucius',
    category: 'Learning',
  ),
  EnQuote(
    text: 'The man who moves a mountain begins by carrying away small stones.',
    author: 'Confucius',
    category: 'Perseverance',
  ),
  EnQuote(
    text: 'When you reach the end of your rope, tie a knot in it and hang on.',
    author: 'Franklin D. Roosevelt',
    category: 'Resilience',
  ),
// ── April ─────────────────────────────────────────────────
  EnQuote(
    text:
        'In three words I can sum up everything I have learned about life: it goes on.',
    author: 'Robert Frost',
    category: 'Philosophy',
  ),
  EnQuote(
    text: 'No road is long with good company.',
    author: 'Turkish Proverb',
    category: 'Friendship',
  ),
  EnQuote(
    text: 'The mind is everything. What you think you become.',
    author: 'Buddha',
    category: 'Mindset',
  ),
  EnQuote(
    text:
        'Three things cannot be long hidden: the sun, the moon, and the truth.',
    author: 'Buddha',
    category: 'Truth',
  ),
  EnQuote(
    text: 'Peace comes from within. Do not seek it without.',
    author: 'Buddha',
    category: 'Inner Peace',
  ),
  EnQuote(
    text:
        'Do not dwell in the past, do not dream of the future, concentrate the mind on the present moment.',
    author: 'Buddha',
    category: 'Mindfulness',
  ),
  EnQuote(
    text:
        'You yourself, as much as anybody in the entire universe, deserve your love and affection.',
    author: 'Buddha',
    category: 'Self-love',
  ),
  EnQuote(
    text:
        'Health is the greatest gift, contentment the greatest wealth, faithfulness the best relationship.',
    author: 'Buddha',
    category: 'Wisdom',
  ),
  EnQuote(
    text:
        'To be yourself in a world that is constantly trying to make you something else is the greatest accomplishment.',
    author: 'Ralph Waldo Emerson',
    category: 'Authenticity',
  ),
  EnQuote(
    text:
        'What lies behind us and what lies before us are tiny matters compared to what lies within us.',
    author: 'Ralph Waldo Emerson',
    category: 'Inner Strength',
  ),
  EnQuote(
    text: 'For every minute you are angry you lose sixty seconds of happiness.',
    author: 'Ralph Waldo Emerson',
    category: 'Happiness',
  ),
  EnQuote(
    text: 'Nothing great was ever achieved without enthusiasm.',
    author: 'Ralph Waldo Emerson',
    category: 'Motivation',
  ),
  EnQuote(
    text: 'Write it on your heart that every day is the best day in the year.',
    author: 'Ralph Waldo Emerson',
    category: 'Gratitude',
  ),
  EnQuote(
    text: 'Once you choose hope, anything is possible.',
    author: 'Christopher Reeve',
    category: 'Hope',
  ),
  EnQuote(
    text: 'It is not what you look at that matters, it is what you see.',
    author: 'Henry David Thoreau',
    category: 'Perspective',
  ),
  EnQuote(
    text:
        'Go confidently in the direction of your dreams. Live the life you have imagined.',
    author: 'Henry David Thoreau',
    category: 'Dreams',
  ),
  EnQuote(
    text: 'Our life is frittered away by detail. Simplify, simplify.',
    author: 'Henry David Thoreau',
    category: 'Simplicity',
  ),
  EnQuote(
    text: 'Not until we are lost do we begin to find ourselves.',
    author: 'Henry David Thoreau',
    category: 'Self-discovery',
  ),
  EnQuote(
    text: 'I went to the woods because I wished to live deliberately.',
    author: 'Henry David Thoreau',
    category: 'Intentionality',
  ),
  EnQuote(
    text: 'Kind words do not cost much, yet they accomplish much.',
    author: 'Blaise Pascal',
    category: 'Kindness',
  ),
  EnQuote(
    text: 'The heart has its reasons which reason knows nothing of.',
    author: 'Blaise Pascal',
    category: 'Philosophy',
  ),
  EnQuote(
    text:
        'Excellence is never an accident. It is always the result of high intention and sincere effort.',
    author: 'Aristotle',
    category: 'Excellence',
  ),
  EnQuote(
    text:
        'We are what we repeatedly do. Excellence, then, is not an act, but a habit.',
    author: 'Aristotle',
    category: 'Habits',
  ),
  EnQuote(
    text: 'Knowing yourself is the beginning of all wisdom.',
    author: 'Aristotle',
    category: 'Wisdom',
  ),
  EnQuote(
    text: 'Patience is bitter, but its fruit is sweet.',
    author: 'Aristotle',
    category: 'Patience',
  ),
  EnQuote(
    text: 'The more you know, the more you realize you do not know.',
    author: 'Aristotle',
    category: 'Humility',
  ),
  EnQuote(
    text: 'Pleasure in the job puts perfection in the work.',
    author: 'Aristotle',
    category: 'Work',
  ),
  EnQuote(
    text: 'Quality is not an act, it is a habit.',
    author: 'Aristotle',
    category: 'Excellence',
  ),
  EnQuote(
    text: 'Hope is a waking dream.',
    author: 'Aristotle',
    category: 'Hope',
  ),
  EnQuote(
    text: 'Change your thoughts and you change your world.',
    author: 'Norman Vincent Peale',
    category: 'Mindset',
  ),
  EnQuote(
    text:
        'Shoot for the moon. Even if you miss, you will land among the stars.',
    author: 'Les Brown',
    category: 'Ambition',
  ),

  // ── May ───────────────────────────────────────────────────
  EnQuote(
    text: 'Well done is better than well said.',
    author: 'Benjamin Franklin',
    category: 'Action',
  ),
  EnQuote(
    text: 'An investment in knowledge pays the best interest.',
    author: 'Benjamin Franklin',
    category: 'Education',
  ),
  EnQuote(
    text:
        'Tell me and I forget. Teach me and I remember. Involve me and I learn.',
    author: 'Benjamin Franklin',
    category: 'Learning',
  ),
  EnQuote(
    text: 'By failing to prepare, you are preparing to fail.',
    author: 'Benjamin Franklin',
    category: 'Preparation',
  ),
  EnQuote(
    text: 'Energy and persistence conquer all things.',
    author: 'Benjamin Franklin',
    category: 'Perseverance',
  ),
  EnQuote(
    text: 'Either write something worth reading or do something worth writing.',
    author: 'Benjamin Franklin',
    category: 'Purpose',
  ),
  EnQuote(
    text: 'Lost time is never found again.',
    author: 'Benjamin Franklin',
    category: 'Time',
  ),
  EnQuote(
    text: 'Never leave that till tomorrow which you can do today.',
    author: 'Benjamin Franklin',
    category: 'Productivity',
  ),
  EnQuote(
    text:
        'Without continual growth and progress, such words as improvement and success have no meaning.',
    author: 'Benjamin Franklin',
    category: 'Growth',
  ),
  EnQuote(
    text: 'The best revenge is massive success.',
    author: 'Frank Sinatra',
    category: 'Success',
  ),
  EnQuote(
    text: 'I am not afraid of storms, for I am learning how to sail my ship.',
    author: 'Louisa May Alcott',
    category: 'Courage',
  ),
  EnQuote(
    text: 'There are no shortcuts to any place worth going.',
    author: 'Beverly Sills',
    category: 'Perseverance',
  ),
  EnQuote(
    text: 'The secret of success is to do the common thing uncommonly well.',
    author: 'John D. Rockefeller Jr.',
    category: 'Excellence',
  ),
  EnQuote(
    text:
        'If you genuinely want something, do not wait for it — teach yourself to be impatient.',
    author: 'Gurbaksh Chahal',
    category: 'Motivation',
  ),
  EnQuote(
    text: 'Do one thing every day that scares you.',
    author: 'Eleanor Roosevelt',
    category: 'Courage',
  ),
  EnQuote(
    text: 'With the new day comes new strength and new thoughts.',
    author: 'Eleanor Roosevelt',
    category: 'Motivation',
  ),
  EnQuote(
    text:
        'Great minds discuss ideas; average minds discuss events; small minds discuss people.',
    author: 'Eleanor Roosevelt',
    category: 'Wisdom',
  ),
  EnQuote(
    text:
        'Beautiful young people are accidents of nature, but beautiful old people are works of art.',
    author: 'Eleanor Roosevelt',
    category: 'Wisdom',
  ),
  EnQuote(
    text:
        'The purpose of life is to contribute in some way to making things better.',
    author: 'Robert F. Kennedy',
    category: 'Purpose',
  ),
  EnQuote(
    text:
        'It is not the strongest of the species that survives, nor the most intelligent; it is the most adaptable.',
    author: 'Charles Darwin',
    category: 'Adaptability',
  ),
  EnQuote(
    text: 'A journey of a thousand miles begins with a single step.',
    author: 'Lao Tzu',
    category: 'Action',
  ),
  EnQuote(
    text: 'When I let go of what I am, I become what I might be.',
    author: 'Lao Tzu',
    category: 'Growth',
  ),
  EnQuote(
    text: 'Nature does not hurry, yet everything is accomplished.',
    author: 'Lao Tzu',
    category: 'Patience',
  ),
  EnQuote(
    text: 'Knowing others is wisdom. Knowing yourself is enlightenment.',
    author: 'Lao Tzu',
    category: 'Self-awareness',
  ),
  EnQuote(
    text: 'To the mind that is still, the whole universe surrenders.',
    author: 'Lao Tzu',
    category: 'Inner Peace',
  ),
  EnQuote(
    text: 'Life is really simple, but we insist on making it complicated.',
    author: 'Confucius',
    category: 'Simplicity',
  ),
  EnQuote(
    text: 'Before you embark on a journey of revenge, dig two graves.',
    author: 'Confucius',
    category: 'Wisdom',
  ),
  EnQuote(
    text: 'It does not matter how slowly you go so long as you do not stop.',
    author: 'Confucius',
    category: 'Perseverance',
  ),
  EnQuote(
    text:
        'When it is obvious that the goals cannot be reached, do not adjust the goals, adjust the action steps.',
    author: 'Confucius',
    category: 'Adaptability',
  ),
  EnQuote(
    text: 'Wherever you go, go with all your heart.',
    author: 'Confucius',
    category: 'Commitment',
  ),
  EnQuote(
    text:
        'The will to win, the desire to succeed, the urge to reach your full potential — these are the keys that will unlock the door to personal excellence.',
    author: 'Confucius',
    category: 'Excellence',
  ),
  EnQuote(
    text:
        'Be not afraid of greatness. Some are born great, some achieve greatness, and some have greatness thrust upon them.',
    author: 'William Shakespeare',
    category: 'Greatness',
  ),

  // ── June ──────────────────────────────────────────────────
  EnQuote(
    text: 'We know what we are, but know not what we may be.',
    author: 'William Shakespeare',
    category: 'Potential',
  ),
  EnQuote(
    text: 'All the world is a stage, and all the men and women merely players.',
    author: 'William Shakespeare',
    category: 'Philosophy',
  ),
  EnQuote(
    text: 'There is nothing either good or bad, but thinking makes it so.',
    author: 'William Shakespeare',
    category: 'Mindset',
  ),
  EnQuote(
    text:
        'Our doubts are traitors, and make us lose the good we oft might win, by fearing to attempt.',
    author: 'William Shakespeare',
    category: 'Courage',
  ),
  EnQuote(
    text:
        'What\'s in a name? That which we call a rose by any other name would smell as sweet.',
    author: 'William Shakespeare',
    category: 'Philosophy',
  ),
  EnQuote(
    text: 'Love all, trust a few, do wrong to none.',
    author: 'William Shakespeare',
    category: 'Wisdom',
  ),
  EnQuote(
    text: 'Give every man thine ear, but few thy voice.',
    author: 'William Shakespeare',
    category: 'Wisdom',
  ),
  EnQuote(
    text: 'The robbed that smiles, steals something from the thief.',
    author: 'William Shakespeare',
    category: 'Resilience',
  ),
  EnQuote(
    text:
        'How sharper than a serpent\'s tooth it is to have a thankless child.',
    author: 'William Shakespeare',
    category: 'Gratitude',
  ),
  EnQuote(
    text: 'The course of true love never did run smooth.',
    author: 'William Shakespeare',
    category: 'Love',
  ),
  EnQuote(
    text: 'I am not bound to please thee with my answers.',
    author: 'William Shakespeare',
    category: 'Authenticity',
  ),
  EnQuote(
    text:
        'We are such stuff as dreams are made on, and our little life is rounded with a sleep.',
    author: 'William Shakespeare',
    category: 'Philosophy',
  ),
  EnQuote(
    text: 'Brevity is the soul of wit.',
    author: 'William Shakespeare',
    category: 'Wisdom',
  ),
  EnQuote(
    text:
        'The fool doth think he is wise, but the wise man knows himself to be a fool.',
    author: 'William Shakespeare',
    category: 'Humility',
  ),
  EnQuote(
    text: 'We know what we are, but know not what we may be.',
    author: 'William Shakespeare',
    category: 'Potential',
  ),
  EnQuote(
    text:
        'The quality of mercy is not strained; it droppeth as the gentle rain from heaven.',
    author: 'William Shakespeare',
    category: 'Compassion',
  ),
  EnQuote(
    text:
        'Cowards die many times before their deaths; the valiant never taste of death but once.',
    author: 'William Shakespeare',
    category: 'Courage',
  ),
  EnQuote(
    text: 'How poor are they that have not patience.',
    author: 'William Shakespeare',
    category: 'Patience',
  ),
  EnQuote(
    text: 'The pain of parting is nothing to the joy of meeting again.',
    author: 'Charles Dickens',
    category: 'Hope',
  ),
  EnQuote(
    text:
        'No one is useless in this world who lightens the burdens of another.',
    author: 'Charles Dickens',
    category: 'Service',
  ),
  EnQuote(
    text:
        'Have a heart that never hardens, a temper that never tires, a touch that never hurts.',
    author: 'Charles Dickens',
    category: 'Kindness',
  ),
  EnQuote(
    text:
        'It was the best of times, it was the worst of times — but it was always a time to keep going.',
    author: 'Charles Dickens',
    category: 'Resilience',
  ),
  EnQuote(
    text: 'Reflect upon your present blessings, of which every man has many.',
    author: 'Charles Dickens',
    category: 'Gratitude',
  ),
  EnQuote(
    text:
        'Whatever I have tried to do in life, I have tried with all my heart to do it well.',
    author: 'Charles Dickens',
    category: 'Commitment',
  ),
  EnQuote(
    text: 'A loving heart is the truest wisdom.',
    author: 'Charles Dickens',
    category: 'Love',
  ),
  EnQuote(
    text:
        'There is nothing I would not do for those who are really my friends.',
    author: 'Jane Austen',
    category: 'Friendship',
  ),
  EnQuote(
    text: 'I declare after all there is no enjoyment like reading.',
    author: 'Jane Austen',
    category: 'Learning',
  ),
  EnQuote(
    text: 'One half of the world cannot understand the pleasures of the other.',
    author: 'Jane Austen',
    category: 'Empathy',
  ),
  EnQuote(
    text:
        'Silly things do cease to be silly if they are done by sensible people in an impudent way.',
    author: 'Jane Austen',
    category: 'Wisdom',
  ),
  EnQuote(
    text: 'There is no charm equal to tenderness of heart.',
    author: 'Jane Austen',
    category: 'Kindness',
  ),
  EnQuote(
    text: 'To be fond of dancing was a certain step towards falling in love.',
    author: 'Jane Austen',
    category: 'Joy',
  ),
// ── July ──────────────────────────────────────────────────
  EnQuote(
    text:
        'The secret of change is to focus all of your energy not on fighting the old, but on building the new.',
    author: 'Socrates',
    category: 'Change',
  ),
  EnQuote(
    text: 'The only true wisdom is in knowing you know nothing.',
    author: 'Socrates',
    category: 'Humility',
  ),
  EnQuote(
    text:
        'Strong minds discuss ideas, average minds discuss events, weak minds discuss people.',
    author: 'Socrates',
    category: 'Wisdom',
  ),
  EnQuote(
    text:
        'He who is not contented with what he has, would not be contented with what he would like to have.',
    author: 'Socrates',
    category: 'Contentment',
  ),
  EnQuote(
    text:
        'Employ your time in improving yourself by other men\'s writings, so that you shall gain easily what others have labored hard for.',
    author: 'Socrates',
    category: 'Learning',
  ),
  EnQuote(
    text: 'To move the world, we must first move ourselves.',
    author: 'Socrates',
    category: 'Self-improvement',
  ),
  EnQuote(
    text: 'Contentment is natural wealth, luxury is artificial poverty.',
    author: 'Socrates',
    category: 'Contentment',
  ),
  EnQuote(
    text: 'I cannot teach anybody anything. I can only make them think.',
    author: 'Socrates',
    category: 'Learning',
  ),
  EnQuote(
    text: 'The measure of a man is what he does with power.',
    author: 'Plato',
    category: 'Character',
  ),
  EnQuote(
    text: 'At the touch of love, everyone becomes a poet.',
    author: 'Plato',
    category: 'Love',
  ),
  EnQuote(
    text:
        'Wise men talk because they have something to say; fools because they have to say something.',
    author: 'Plato',
    category: 'Wisdom',
  ),
  EnQuote(
    text:
        'You can discover more about a person in an hour of play than in a year of conversation.',
    author: 'Plato',
    category: 'Character',
  ),
  EnQuote(
    text: 'Courage is knowing what not to fear.',
    author: 'Plato',
    category: 'Courage',
  ),
  EnQuote(
    text:
        'No man should bring children into the world who is unwilling to persevere to the end in their nature and education.',
    author: 'Plato',
    category: 'Responsibility',
  ),
  EnQuote(
    text: 'The beginning is the most important part of the work.',
    author: 'Plato',
    category: 'Action',
  ),
  EnQuote(
    text:
        'Good actions give strength to ourselves and inspire good actions in others.',
    author: 'Plato',
    category: 'Virtue',
  ),
  EnQuote(
    text:
        'There are three classes of men: lovers of wisdom, lovers of honor, and lovers of gain.',
    author: 'Plato',
    category: 'Philosophy',
  ),
  EnQuote(
    text:
        'One of the penalties for refusing to participate in politics is that you end up being governed by your inferiors.',
    author: 'Plato',
    category: 'Leadership',
  ),
  EnQuote(
    text:
        'Never discourage anyone who continually makes progress, no matter how slow.',
    author: 'Plato',
    category: 'Encouragement',
  ),
  EnQuote(
    text:
        'Every heart sings a song, incomplete, until another heart whispers back.',
    author: 'Plato',
    category: 'Love',
  ),
  EnQuote(
    text: 'There is no harm in repeating a good thing.',
    author: 'Plato',
    category: 'Wisdom',
  ),
  EnQuote(
    text: 'The price of anything is the amount of life you exchange for it.',
    author: 'Henry David Thoreau',
    category: 'Time',
  ),
  EnQuote(
    text:
        'If you have built castles in the air, your work need not be lost; that is where they should be. Now put the foundations under them.',
    author: 'Henry David Thoreau',
    category: 'Dreams',
  ),
  EnQuote(
    text:
        'You must live in the present, launch yourself on every wave, find your eternity in each moment.',
    author: 'Henry David Thoreau',
    category: 'Mindfulness',
  ),
  EnQuote(
    text: 'Things do not change; we change.',
    author: 'Henry David Thoreau',
    category: 'Self-improvement',
  ),
  EnQuote(
    text:
        'Success is finding satisfaction in giving a little more than you take.',
    author: 'Christopher Reeve',
    category: 'Service',
  ),
  EnQuote(
    text: 'The only way to have a friend is to be one.',
    author: 'Ralph Waldo Emerson',
    category: 'Friendship',
  ),
  EnQuote(
    text:
        'Do not go where the path may lead; go instead where there is no path and leave a trail.',
    author: 'Ralph Waldo Emerson',
    category: 'Leadership',
  ),
  EnQuote(
    text: 'The earth laughs in flowers.',
    author: 'Ralph Waldo Emerson',
    category: 'Nature',
  ),
  EnQuote(
    text: 'Finish each day and be done with it. Tomorrow is a new day.',
    author: 'Ralph Waldo Emerson',
    category: 'Resilience',
  ),
  EnQuote(
    text:
        'Do not be too timid and squeamish about your actions. All life is an experiment.',
    author: 'Ralph Waldo Emerson',
    category: 'Courage',
  ),

  // ── August ────────────────────────────────────────────────
  EnQuote(
    text:
        'The greatest glory in living lies not in never falling, but in rising every time we fall.',
    author: 'Nelson Mandela',
    category: 'Resilience',
  ),
  EnQuote(
    text:
        'Real generosity toward the future lies in giving all to the present.',
    author: 'Albert Camus',
    category: 'Commitment',
  ),
  EnQuote(
    text:
        'In the depth of winter, I finally learned that within me there lay an invincible summer.',
    author: 'Albert Camus',
    category: 'Inner Strength',
  ),
  EnQuote(
    text:
        'You will never be happy if you continue to search for what happiness consists of.',
    author: 'Albert Camus',
    category: 'Happiness',
  ),
  EnQuote(
    text: 'Always go too far, because that is where you will find the truth.',
    author: 'Albert Camus',
    category: 'Truth',
  ),
  EnQuote(
    text: 'Blessed are the hearts that can bend; they shall never be broken.',
    author: 'Albert Camus',
    category: 'Resilience',
  ),
  EnQuote(
    text:
        'Don\'t walk behind me; I may not lead. Don\'t walk in front of me; I may not follow. Just walk beside me and be my friend.',
    author: 'Albert Camus',
    category: 'Friendship',
  ),
  EnQuote(
    text: 'Those who cannot change their minds cannot change anything.',
    author: 'George Bernard Shaw',
    category: 'Change',
  ),
  EnQuote(
    text:
        'Life is not about finding yourself. Life is about creating yourself.',
    author: 'George Bernard Shaw',
    category: 'Self-creation',
  ),
  EnQuote(
    text:
        'Progress is impossible without change, and those who cannot change their minds cannot change anything.',
    author: 'George Bernard Shaw',
    category: 'Progress',
  ),
  EnQuote(
    text:
        'The single biggest problem in communication is the illusion that it has taken place.',
    author: 'George Bernard Shaw',
    category: 'Communication',
  ),
  EnQuote(
    text:
        'A life spent making mistakes is not only more honorable, but more useful than a life spent doing nothing.',
    author: 'George Bernard Shaw',
    category: 'Growth',
  ),
  EnQuote(
    text:
        'You see things; and you say \'Why?\' But I dream things that never were; and I say \'Why not?\'',
    author: 'George Bernard Shaw',
    category: 'Vision',
  ),
  EnQuote(
    text:
        'The reasonable man adapts himself to the world; the unreasonable one persists in trying to adapt the world to himself.',
    author: 'George Bernard Shaw',
    category: 'Change',
  ),
  EnQuote(
    text:
        'We are made wise not by the recollection of our past, but by the responsibility for our future.',
    author: 'George Bernard Shaw',
    category: 'Responsibility',
  ),
  EnQuote(
    text: 'The secret to getting ahead is getting started.',
    author: 'Agatha Christie',
    category: 'Action',
  ),
  EnQuote(
    text:
        'I like living. I have sometimes been wildly, despairingly, acutely miserable, but through it all I still know quite certainly that just to be alive is a grand thing.',
    author: 'Agatha Christie',
    category: 'Gratitude',
  ),
  EnQuote(
    text:
        'Good advice is always certain to be ignored, but that is no reason not to give it.',
    author: 'Agatha Christie',
    category: 'Wisdom',
  ),
  EnQuote(
    text:
        'One is left with the horrible feeling now that war settles nothing; that to win a war is as disastrous as to lose one.',
    author: 'Agatha Christie',
    category: 'Peace',
  ),
  EnQuote(
    text: 'The best time to plan a book is while you are doing the dishes.',
    author: 'Agatha Christie',
    category: 'Creativity',
  ),
  EnQuote(
    text: 'To know is nothing at all; to imagine is everything.',
    author: 'Anatole France',
    category: 'Imagination',
  ),
  EnQuote(
    text:
        'If you want to go fast, go alone. If you want to go far, go together.',
    author: 'African Proverb',
    category: 'Teamwork',
  ),
  EnQuote(
    text:
        'Until the lion learns to write, every story will glorify the hunter.',
    author: 'African Proverb',
    category: 'Empowerment',
  ),
  EnQuote(
    text:
        'A child who is not embraced by the village will burn it down to feel its warmth.',
    author: 'African Proverb',
    category: 'Community',
  ),
  EnQuote(
    text: 'Rain does not fall on one roof alone.',
    author: 'African Proverb',
    category: 'Community',
  ),
  EnQuote(
    text: 'The axe forgets, but the tree remembers.',
    author: 'African Proverb',
    category: 'Empathy',
  ),
  EnQuote(
    text: 'When the music changes, so does the dance.',
    author: 'African Proverb',
    category: 'Adaptability',
  ),
  EnQuote(
    text: 'Smooth seas do not make skillful sailors.',
    author: 'African Proverb',
    category: 'Growth',
  ),
  EnQuote(
    text: 'He who does not know one thing knows another.',
    author: 'African Proverb',
    category: 'Wisdom',
  ),
  EnQuote(
    text: 'However long the night, the dawn will break.',
    author: 'African Proverb',
    category: 'Hope',
  ),
  EnQuote(
    text:
        'Not everything that is faced can be changed, but nothing can be changed until it is faced.',
    author: 'James Baldwin',
    category: 'Change',
  ),
  EnQuote(
    text:
        'Not everything that is faced can be changed, but nothing can be changed until it is faced.',
    author: 'James Baldwin',
    category: 'Courage',
  ),

  // ── September ─────────────────────────────────────────────
  EnQuote(
    text: 'I am not what happened to me. I am what I choose to become.',
    author: 'Carl Jung',
    category: 'Self-creation',
  ),
  EnQuote(
    text: 'The most terrifying thing is to accept oneself completely.',
    author: 'Carl Jung',
    category: 'Self-acceptance',
  ),
  EnQuote(
    text:
        'Your vision will become clear only when you can look into your own heart.',
    author: 'Carl Jung',
    category: 'Self-awareness',
  ),
  EnQuote(
    text:
        'Knowing your own darkness is the best method for dealing with the darknesses of other people.',
    author: 'Carl Jung',
    category: 'Self-awareness',
  ),
  EnQuote(
    text:
        'Even a happy life cannot be without a measure of darkness, and the word happy would lose its meaning if it were not balanced by sadness.',
    author: 'Carl Jung',
    category: 'Balance',
  ),
  EnQuote(
    text:
        'The meeting of two personalities is like the contact of two chemical substances: if there is any reaction, both are transformed.',
    author: 'Carl Jung',
    category: 'Relationships',
  ),
  EnQuote(
    text: 'In all chaos there is a cosmos, in all disorder a secret order.',
    author: 'Carl Jung',
    category: 'Philosophy',
  ),
  EnQuote(
    text:
        'Until you make the unconscious conscious, it will direct your life and you will call it fate.',
    author: 'Carl Jung',
    category: 'Self-awareness',
  ),
  EnQuote(
    text:
        'Life really does begin at forty. Up until then, you are just doing research.',
    author: 'Carl Jung',
    category: 'Philosophy',
  ),
  EnQuote(
    text: 'The privilege of a lifetime is to become who you truly are.',
    author: 'Carl Jung',
    category: 'Authenticity',
  ),
  EnQuote(
    text:
        'Show me a man or woman alone and I will show you a saint. Give them a family, and they will show you a devil.',
    author: 'Eugene O\'Neill',
    category: 'Human Nature',
  ),
  EnQuote(
    text: 'The secret of joy in work is contained in one word — excellence.',
    author: 'Pearl S. Buck',
    category: 'Excellence',
  ),
  EnQuote(
    text:
        'You cannot make yourself feel something you do not feel, but you can make yourself do right in spite of your feelings.',
    author: 'Pearl S. Buck',
    category: 'Character',
  ),
  EnQuote(
    text:
        'You can judge your age by the amount of pain you feel when you come in contact with a new idea.',
    author: 'Pearl S. Buck',
    category: 'Growth',
  ),
  EnQuote(
    text:
        'All things are possible until they are proved impossible — and even the impossible may only be so, as of now.',
    author: 'Pearl S. Buck',
    category: 'Possibility',
  ),
  EnQuote(
    text:
        'Daring ideas are like chessmen moved forward; they may be beaten, but they may start a winning game.',
    author: 'Johann Wolfgang von Goethe',
    category: 'Courage',
  ),
  EnQuote(
    text:
        'Whatever you can do, or dream you can, begin it. Boldness has genius, power, and magic in it.',
    author: 'Johann Wolfgang von Goethe',
    category: 'Action',
  ),
  EnQuote(
    text:
        'Knowing is not enough; we must apply. Willing is not enough; we must do.',
    author: 'Johann Wolfgang von Goethe',
    category: 'Action',
  ),
  EnQuote(
    text:
        'One ought, every day at least, to hear a little song, read a good poem, see a fine picture, and speak a few reasonable words.',
    author: 'Johann Wolfgang von Goethe',
    category: 'Culture',
  ),
  EnQuote(
    text: 'A man sees in the world what he carries in his heart.',
    author: 'Johann Wolfgang von Goethe',
    category: 'Perspective',
  ),
  EnQuote(
    text: 'As soon as you trust yourself, you will know how to live.',
    author: 'Johann Wolfgang von Goethe',
    category: 'Self-trust',
  ),
  EnQuote(
    text:
        'Treat people as if they were what they ought to be and you help them to become what they are capable of being.',
    author: 'Johann Wolfgang von Goethe',
    category: 'Leadership',
  ),
  EnQuote(
    text:
        'If children grew up according to early indications, we should have nothing but geniuses.',
    author: 'Johann Wolfgang von Goethe',
    category: 'Education',
  ),
  EnQuote(
    text:
        'The intelligent man finds almost everything ridiculous, the sensible man hardly anything.',
    author: 'Johann Wolfgang von Goethe',
    category: 'Wisdom',
  ),
  EnQuote(
    text: 'Difficulties increase the nearer we approach the goal.',
    author: 'Johann Wolfgang von Goethe',
    category: 'Perseverance',
  ),
  EnQuote(
    text: 'The soul that sees beauty may sometimes walk alone.',
    author: 'Johann Wolfgang von Goethe',
    category: 'Solitude',
  ),
  EnQuote(
    text: 'Nothing is worth more than this day.',
    author: 'Johann Wolfgang von Goethe',
    category: 'Mindfulness',
  ),
// ── October ───────────────────────────────────────────────
  EnQuote(
    text: 'The most common form of despair is not being who you are.',
    author: 'Søren Kierkegaard',
    category: 'Authenticity',
  ),
  EnQuote(
    text:
        'Life can only be understood backwards; but it must be lived forwards.',
    author: 'Søren Kierkegaard',
    category: 'Philosophy',
  ),
  EnQuote(
    text:
        'The most painful state of being is remembering the future, particularly the one you will never have.',
    author: 'Søren Kierkegaard',
    category: 'Philosophy',
  ),
  EnQuote(
    text: 'Anxiety is the dizziness of freedom.',
    author: 'Søren Kierkegaard',
    category: 'Philosophy',
  ),
  EnQuote(
    text:
        'To dare is to lose one\'s footing momentarily. To not dare is to lose oneself.',
    author: 'Søren Kierkegaard',
    category: 'Courage',
  ),
  EnQuote(
    text:
        'People demand freedom of speech as a compensation for the freedom of thought which they seldom use.',
    author: 'Søren Kierkegaard',
    category: 'Wisdom',
  ),
  EnQuote(
    text:
        'The function of prayer is not to influence God, but rather to change the nature of the one who prays.',
    author: 'Søren Kierkegaard',
    category: 'Spirituality',
  ),
  EnQuote(
    text: 'Once you label me you negate me.',
    author: 'Søren Kierkegaard',
    category: 'Identity',
  ),
  EnQuote(
    text:
        'What I really need is to get clear about what I must do, not what I must know.',
    author: 'Søren Kierkegaard',
    category: 'Purpose',
  ),
  EnQuote(
    text:
        'God creates out of nothing. Wonderful you say. Yes, to be sure, but He does what is still more wonderful: He makes saints out of sinners.',
    author: 'Søren Kierkegaard',
    category: 'Faith',
  ),
  EnQuote(
    text: 'The wound is the place where the Light enters you.',
    author: 'Rumi',
    category: 'Healing',
  ),
  EnQuote(
    text:
        'Out beyond ideas of wrongdoing and rightdoing, there is a field. I will meet you there.',
    author: 'Rumi',
    category: 'Philosophy',
  ),
  EnQuote(
    text: 'What you seek is seeking you.',
    author: 'Rumi',
    category: 'Spirituality',
  ),
  EnQuote(
    text:
        'Do not be satisfied with the stories that come before you. Unfold your own myth.',
    author: 'Rumi',
    category: 'Self-creation',
  ),
  EnQuote(
    text:
        'Raise your words, not voice. It is rain that grows flowers, not thunder.',
    author: 'Rumi',
    category: 'Communication',
  ),
  EnQuote(
    text: 'The quieter you become, the more you are able to hear.',
    author: 'Rumi',
    category: 'Mindfulness',
  ),
  EnQuote(
    text:
        'Yesterday I was clever, so I wanted to change the world. Today I am wise, so I am changing myself.',
    author: 'Rumi',
    category: 'Wisdom',
  ),
  EnQuote(
    text:
        'When you do things from your soul, you feel a river moving in you, a joy.',
    author: 'Rumi',
    category: 'Joy',
  ),
  EnQuote(
    text: 'Stop acting so small. You are the universe in ecstatic motion.',
    author: 'Rumi',
    category: 'Self-worth',
  ),
  EnQuote(
    text:
        'Let yourself be silently drawn by the strange pull of what you really love.',
    author: 'Rumi',
    category: 'Passion',
  ),
  EnQuote(
    text: 'Sell your cleverness and buy bewilderment.',
    author: 'Rumi',
    category: 'Humility',
  ),
  EnQuote(
    text: 'Be a lamp, or a lifeboat, or a ladder. Help someone\'s soul heal.',
    author: 'Rumi',
    category: 'Service',
  ),
  EnQuote(
    text: 'Live where you fear to live. Destroy your reputation. Be notorious.',
    author: 'Rumi',
    category: 'Courage',
  ),
  EnQuote(
    text:
        'Be grateful for whoever comes, because each has been sent as a guide from beyond.',
    author: 'Rumi',
    category: 'Gratitude',
  ),
  EnQuote(
    text:
        'Ignore those that make you fearful and sad, that degrade you back towards disease and death.',
    author: 'Rumi',
    category: 'Self-care',
  ),
  EnQuote(
    text: 'When I am silent, I have thunder hidden inside.',
    author: 'Rumi',
    category: 'Inner Strength',
  ),
  EnQuote(
    text: 'Travel brings power and love back into your life.',
    author: 'Rumi',
    category: 'Adventure',
  ),
  EnQuote(
    text:
        'Your task is not to seek for love, but merely to seek and find all the barriers within yourself that you have built against it.',
    author: 'Rumi',
    category: 'Love',
  ),
  EnQuote(
    text:
        'Work in the invisible world at least as hard as you do in the visible.',
    author: 'Rumi',
    category: 'Spirituality',
  ),
  EnQuote(
    text: 'Why do you stay in prison when the door is so wide open?',
    author: 'Rumi',
    category: 'Freedom',
  ),

  // ── November ──────────────────────────────────────────────
  EnQuote(
    text: 'He who has a why to live can bear almost any how.',
    author: 'Friedrich Nietzsche',
    category: 'Purpose',
  ),
  EnQuote(
    text: 'Without music, life would be a mistake.',
    author: 'Friedrich Nietzsche',
    category: 'Art',
  ),
  EnQuote(
    text: 'That which does not kill us makes us stronger.',
    author: 'Friedrich Nietzsche',
    category: 'Resilience',
  ),
  EnQuote(
    text:
        'In individuals, insanity is rare; but in groups, parties, nations, and epochs, it is the rule.',
    author: 'Friedrich Nietzsche',
    category: 'Society',
  ),
  EnQuote(
    text: 'The higher we soar, the smaller we appear to those who cannot fly.',
    author: 'Friedrich Nietzsche',
    category: 'Vision',
  ),
  EnQuote(
    text: 'There are no facts, only interpretations.',
    author: 'Friedrich Nietzsche',
    category: 'Philosophy',
  ),
  EnQuote(
    text:
        'One must still have chaos in oneself to be able to give birth to a dancing star.',
    author: 'Friedrich Nietzsche',
    category: 'Creativity',
  ),
  EnQuote(
    text:
        'The secret for harvesting from existence the greatest fruitfulness and the greatest enjoyment is to live dangerously.',
    author: 'Friedrich Nietzsche',
    category: 'Courage',
  ),
  EnQuote(
    text:
        'We love life, not because we are used to living but because we are used to loving.',
    author: 'Friedrich Nietzsche',
    category: 'Love',
  ),
  EnQuote(
    text:
        'The man of knowledge must be able not only to love his enemies but also to hate his friends.',
    author: 'Friedrich Nietzsche',
    category: 'Wisdom',
  ),
  EnQuote(
    text:
        'The surest way to corrupt a youth is to instruct him to hold in higher esteem those who think alike than those who think differently.',
    author: 'Friedrich Nietzsche',
    category: 'Education',
  ),
  EnQuote(
    text:
        'Blessed are the forgetful, for they get the better even of their blunders.',
    author: 'Friedrich Nietzsche',
    category: 'Forgiveness',
  ),
  EnQuote(
    text:
        'To live is to suffer, to survive is to find some meaning in the suffering.',
    author: 'Friedrich Nietzsche',
    category: 'Resilience',
  ),
  EnQuote(
    text: 'In every real man a child is hidden that wants to play.',
    author: 'Friedrich Nietzsche',
    category: 'Joy',
  ),
  EnQuote(
    text: 'Become who you are.',
    author: 'Friedrich Nietzsche',
    category: 'Authenticity',
  ),
  EnQuote(
    text:
        'The biggest adventure you can take is to live the life of your dreams.',
    author: 'Oprah Winfrey',
    category: 'Dreams',
  ),
  EnQuote(
    text: 'You get in life what you have the courage to ask for.',
    author: 'Oprah Winfrey',
    category: 'Courage',
  ),
  EnQuote(
    text:
        'The more you praise and celebrate your life, the more there is in life to celebrate.',
    author: 'Oprah Winfrey',
    category: 'Gratitude',
  ),
  EnQuote(
    text: 'Turn your wounds into wisdom.',
    author: 'Oprah Winfrey',
    category: 'Growth',
  ),
  EnQuote(
    text:
        'Create the highest, grandest vision possible for your life, because you become what you believe.',
    author: 'Oprah Winfrey',
    category: 'Vision',
  ),
  EnQuote(
    text:
        'Real integrity is doing the right thing, knowing that nobody is going to know whether you did it or not.',
    author: 'Oprah Winfrey',
    category: 'Integrity',
  ),
  EnQuote(
    text:
        'Surround yourself with only people who are going to lift you higher.',
    author: 'Oprah Winfrey',
    category: 'Relationships',
  ),
  EnQuote(
    text:
        'Passion is energy. Feel the power that comes from focusing on what excites you.',
    author: 'Oprah Winfrey',
    category: 'Passion',
  ),
  EnQuote(
    text: 'Be thankful for what you have; you will end up having more.',
    author: 'Oprah Winfrey',
    category: 'Gratitude',
  ),
  EnQuote(
    text:
        'The greatest discovery of all time is that a person can change his future by merely changing his attitude.',
    author: 'Oprah Winfrey',
    category: 'Mindset',
  ),
  EnQuote(
    text:
        'Doing the best at this moment puts you in the best place for the next moment.',
    author: 'Oprah Winfrey',
    category: 'Mindfulness',
  ),
  EnQuote(
    text:
        'My philosophy is that not only are you responsible for your life, but doing the best at this moment puts you in the best place for the next moment.',
    author: 'Oprah Winfrey',
    category: 'Responsibility',
  ),
  EnQuote(
    text:
        'Every time you state what you want or believe, you are the first to hear it. It is a message to both you and others about what you think is possible.',
    author: 'Oprah Winfrey',
    category: 'Self-talk',
  ),
  EnQuote(
    text:
        'With every experience, you alone are painting your own canvas, thought by thought, choice by choice.',
    author: 'Oprah Winfrey',
    category: 'Self-creation',
  ),
  EnQuote(
    text:
        'The greatest gift that you can give yourself is a little bit of your own attention.',
    author: 'Anthony J. D\'Angelo',
    category: 'Self-care',
  ),

  // ── December ──────────────────────────────────────────────
  EnQuote(
    text:
        'It is not how much we have, but how much we enjoy, that makes happiness.',
    author: 'Charles Spurgeon',
    category: 'Happiness',
  ),
  EnQuote(
    text: 'We must accept finite disappointment, but never lose infinite hope.',
    author: 'Martin Luther King Jr.',
    category: 'Hope',
  ),
  EnQuote(
    text:
        'Darkness cannot drive out darkness; only light can do that. Hate cannot drive out hate; only love can do that.',
    author: 'Martin Luther King Jr.',
    category: 'Love',
  ),
  EnQuote(
    text: 'The time is always right to do what is right.',
    author: 'Martin Luther King Jr.',
    category: 'Ethics',
  ),
  EnQuote(
    text: 'Every moment is a fresh beginning.',
    author: 'T. S. Eliot',
    category: 'Hope',
  ),
  EnQuote(
    text:
        'Only those who will risk going too far can possibly find out how far one can go.',
    author: 'T. S. Eliot',
    category: 'Courage',
  ),
  EnQuote(
    text: 'The journey not the arrival matters.',
    author: 'T. S. Eliot',
    category: 'Philosophy',
  ),
  EnQuote(
    text:
        'What we call the beginning is often the end. And to make an end is to make a beginning.',
    author: 'T. S. Eliot',
    category: 'Philosophy',
  ),
  EnQuote(
    text: 'Genuine poetry can communicate before it is understood.',
    author: 'T. S. Eliot',
    category: 'Art',
  ),
  EnQuote(
    text:
        'Where is the wisdom we have lost in knowledge? Where is the knowledge we have lost in information?',
    author: 'T. S. Eliot',
    category: 'Wisdom',
  ),
  EnQuote(
    text: 'Humankind cannot bear very much reality.',
    author: 'T. S. Eliot',
    category: 'Philosophy',
  ),
  EnQuote(
    text: 'Do I dare disturb the universe?',
    author: 'T. S. Eliot',
    category: 'Courage',
  ),
  EnQuote(
    text: 'In my beginning is my end.',
    author: 'T. S. Eliot',
    category: 'Philosophy',
  ),
  EnQuote(
    text:
        'You are the sum total of everything you have ever seen, heard, eaten, smelled, been told, forgot — it is all there.',
    author: 'Maya Angelou',
    category: 'Identity',
  ),
  EnQuote(
    text:
        'We delight in the beauty of the butterfly, but rarely admit the changes it has gone through to achieve that beauty.',
    author: 'Maya Angelou',
    category: 'Growth',
  ),
  EnQuote(
    text:
        'If you are always trying to be normal, you will never know how amazing you can be.',
    author: 'Maya Angelou',
    category: 'Authenticity',
  ),
  EnQuote(
    text: 'Try to be a rainbow in someone\'s cloud.',
    author: 'Maya Angelou',
    category: 'Kindness',
  ),
  EnQuote(
    text:
        'Success is liking yourself, liking what you do, and liking how you do it.',
    author: 'Maya Angelou',
    category: 'Success',
  ),
  EnQuote(
    text:
        'I\'ve learned that you can tell a lot about a person by the way he handles these three things: a rainy day, lost luggage, and tangled Christmas tree lights.',
    author: 'Maya Angelou',
    category: 'Character',
  ),
  EnQuote(
    text: 'When someone shows you who they are, believe them the first time.',
    author: 'Maya Angelou',
    category: 'Wisdom',
  ),
  EnQuote(
    text: 'You may encounter many defeats, but you must not be defeated.',
    author: 'Maya Angelou',
    category: 'Resilience',
  ),
  EnQuote(
    text: 'There is no greater agony than bearing an untold story inside you.',
    author: 'Maya Angelou',
    category: 'Expression',
  ),
  EnQuote(
    text:
        'I\'ve learned that people will forget what you said, people will forget what you did, but people will never forget how you made them feel.',
    author: 'Maya Angelou',
    category: 'Impact',
  ),
  EnQuote(
    text: 'Ask for what you want and be prepared to get it.',
    author: 'Maya Angelou',
    category: 'Intention',
  ),
  EnQuote(
    text: 'Nothing will work unless you do.',
    author: 'Maya Angelou',
    category: 'Work',
  ),
  EnQuote(
    text: 'We need much less than we think we need.',
    author: 'Maya Angelou',
    category: 'Simplicity',
  ),
  EnQuote(
    text: 'We are only as blind as we want to be.',
    author: 'Maya Angelou',
    category: 'Awareness',
  ),
  EnQuote(
    text:
        'Pursue some path, however narrow and crooked, in which you can walk with love and reverence.',
    author: 'Henry David Thoreau',
    category: 'Purpose',
  ),
  EnQuote(
    text:
        'You must live in the present, launch yourself on every wave, find your eternity in each moment.',
    author: 'Henry David Thoreau',
    category: 'Mindfulness',
  ),
  EnQuote(
    text:
        'The mass of men lead lives of quiet desperation. What is called resignation is confirmed desperation.',
    author: 'Henry David Thoreau',
    category: 'Authenticity',
  ),
  EnQuote(
    text:
        'I took a deep breath and listened to the old brag of my heart: I am, I am, I am.',
    author: 'Sylvia Plath',
    category: 'Existence',
  ),
  EnQuote(
    text: 'The worst enemy to creativity is self-doubt.',
    author: 'Sylvia Plath',
    category: 'Creativity',
  ),
  EnQuote(
    text:
        'I can never read all the books I want; I can never be all the people I want and live all the lives I want.',
    author: 'Sylvia Plath',
    category: 'Philosophy',
  ),
  EnQuote(
    text: 'Let me live, love and say it well in good sentences.',
    author: 'Sylvia Plath',
    category: 'Expression',
  ),
  EnQuote(
    text: 'The world is a beautiful place. You just have to look at it right.',
    author: 'Unknown',
    category: 'Perspective',
  ),
  EnQuote(
    text: 'A year from now you will wish you had started today.',
    author: 'Karen Lamb',
    category: 'Action',
  ),
  EnQuote(
    text: 'Do small things with great love.',
    author: 'Mother Teresa',
    category: 'Service',
  ),
  EnQuote(
    text: 'If you judge people, you have no time to love them.',
    author: 'Mother Teresa',
    category: 'Love',
  ),
  EnQuote(
    text: 'We shall never know all the good that a simple smile can do.',
    author: 'Mother Teresa',
    category: 'Kindness',
  ),
  EnQuote(
    text:
        'If you are humble nothing will touch you, neither praise nor disgrace, because you know what you are.',
    author: 'Mother Teresa',
    category: 'Humility',
  ),
  EnQuote(
    text:
        'Yesterday is gone. Tomorrow has not yet come. We have only today. Let us begin.',
    author: 'Mother Teresa',
    category: 'Action',
  ),
  EnQuote(
    text:
        'If we have no peace, it is because we have forgotten that we belong to each other.',
    author: 'Mother Teresa',
    category: 'Peace',
  ),
  EnQuote(
    text:
        'The most beautiful people we have known are those who have known defeat, suffering, struggle and loss, and have found their way out of the depths.',
    author: 'Elisabeth Kübler-Ross',
    category: 'Resilience',
  ),
  EnQuote(
    text:
        'The ultimate lesson all of us have to learn is unconditional love, which includes not only others but ourselves as well.',
    author: 'Elisabeth Kübler-Ross',
    category: 'Love',
  ),
  EnQuote(
    text:
        'People are like stained-glass windows. They sparkle and shine when the sun is out, but when the darkness sets in, their true beauty is revealed only if there is a light from within.',
    author: 'Elisabeth Kübler-Ross',
    category: 'Character',
  ),
  EnQuote(
    text:
        'Learn to get in touch with the silence within yourself and know that everything in life has a purpose.',
    author: 'Elisabeth Kübler-Ross',
    category: 'Purpose',
  ),
  EnQuote(
    text:
        'In the end, these things matter most: How well did you love? How fully did you live? How deeply did you let go?',
    author: 'Jack Kornfield',
    category: 'Philosophy',
  ),
  EnQuote(
    text:
        'The present moment is the only moment available to us, and it is the door to all moments.',
    author: 'Thich Nhat Hanh',
    category: 'Mindfulness',
  ),
  EnQuote(
    text: 'Because you are alive, everything is possible.',
    author: 'Thich Nhat Hanh',
    category: 'Hope',
  ),
  EnQuote(
    text: 'The most precious gift we can offer others is our presence.',
    author: 'Thich Nhat Hanh',
    category: 'Mindfulness',
  ),
  EnQuote(
    text:
        'Happiness is not something you postpone for the future; it is something you design for the present.',
    author: 'Jim Rohn',
    category: 'Happiness',
  ),
  EnQuote(
    text:
        'You are the average of the five people you spend the most time with.',
    author: 'Jim Rohn',
    category: 'Relationships',
  ),
  EnQuote(
    text: 'Don\'t wish it were easier; wish you were better.',
    author: 'Jim Rohn',
    category: 'Self-improvement',
  ),
  EnQuote(
    text: 'Discipline is the bridge between goals and accomplishment.',
    author: 'Jim Rohn',
    category: 'Discipline',
  ),
  EnQuote(
    text:
        'If you really want to do something, you will find a way. If you do not, you will find an excuse.',
    author: 'Jim Rohn',
    category: 'Motivation',
  ),
  EnQuote(
    text: 'Take care of your body. It is the only place you have to live.',
    author: 'Jim Rohn',
    category: 'Health',
  ),
  EnQuote(
    text:
        'The challenge of leadership is to be strong, but not rude; be kind, but not weak; be bold, but not bully; be humble, but not timid; be proud, but not arrogant.',
    author: 'Jim Rohn',
    category: 'Leadership',
  ),
  EnQuote(
    text: 'For every disciplined effort there is a multiple reward.',
    author: 'Jim Rohn',
    category: 'Discipline',
  ),
  EnQuote(
    text:
        'Formal education will make you a living; self-education will make you a fortune.',
    author: 'Jim Rohn',
    category: 'Education',
  ),
  EnQuote(
    text:
        'Let others lead small lives, but not you. Let others argue over small things, but not you.',
    author: 'Jim Rohn',
    category: 'Ambition',
  ),
  EnQuote(
    text:
        'If you don\'t design your own life plan, chances are you will fall into someone else\'s plan.',
    author: 'Jim Rohn',
    category: 'Intentionality',
  ),
  EnQuote(
    text: 'Start where you are. Use what you have. Do what you can.',
    author: 'Arthur Ashe',
    category: 'Action',
  ),
  EnQuote(
    text:
        'Every day may not be good, but there is something good in every day.',
    author: 'Alice Morse Earle',
    category: 'Gratitude',
  ),
  EnQuote(
    text: 'We do not remember days, we remember moments.',
    author: 'Cesare Pavese',
    category: 'Mindfulness',
  ),
  EnQuote(
    text: 'It always seems impossible until it is done.',
    author: 'Nelson Mandela',
    category: 'Motivation',
  ),
  EnQuote(
    text: 'The secret of getting ahead is getting started.',
    author: 'Mark Twain',
    category: 'Action',
  ),
  EnQuote(
    text: 'In the middle of difficulty lies opportunity.',
    author: 'Albert Einstein',
    category: 'Resilience',
  ),
  EnQuote(
    text: 'The best way out is always through.',
    author: 'Robert Frost',
    category: 'Perseverance',
  ),
  EnQuote(
    text:
        'Keep your face always toward the sunshine — and shadows will fall behind you.',
    author: 'Walt Whitman',
    category: 'Optimism',
  ),
  EnQuote(
    text: 'I am large; I contain multitudes.',
    author: 'Walt Whitman',
    category: 'Identity',
  ),
  EnQuote(
    text: 'Do anything, but let it produce joy.',
    author: 'Walt Whitman',
    category: 'Joy',
  ),
  EnQuote(
    text: 'Whatever satisfies the soul is truth.',
    author: 'Walt Whitman',
    category: 'Truth',
  ),
  EnQuote(
    text:
        'Give me your tired, your poor, your huddled masses yearning to breathe free.',
    author: 'Emma Lazarus',
    category: 'Freedom',
  ),
  EnQuote(
    text: 'This above all: to thine own self be true.',
    author: 'William Shakespeare',
    category: 'Authenticity',
  ),
  EnQuote(
    text: 'Not all those who wander are lost.',
    author: 'J. R. R. Tolkien',
    category: 'Adventure',
  ),
  EnQuote(
    text: 'Even the smallest person can change the course of the future.',
    author: 'J. R. R. Tolkien',
    category: 'Empowerment',
  ),
  EnQuote(
    text: 'All we have to decide is what to do with the time that is given us.',
    author: 'J. R. R. Tolkien',
    category: 'Choice',
  ),
  EnQuote(
    text:
        'The world is indeed full of peril and in it there are many dark places. But still there is much that is fair.',
    author: 'J. R. R. Tolkien',
    category: 'Hope',
  ),
  EnQuote(
    text: 'It does not do to dwell on dreams and forget to live.',
    author: 'J. K. Rowling',
    category: 'Balance',
  ),
  EnQuote(
    text:
        'It is our choices that show what we truly are, far more than our abilities.',
    author: 'J. K. Rowling',
    category: 'Character',
  ),
  EnQuote(
    text:
        'Happiness can be found even in the darkest of times, if one only remembers to turn on the light.',
    author: 'J. K. Rowling',
    category: 'Hope',
  ),
  EnQuote(
    text: 'We are only as strong as we are united, as weak as we are divided.',
    author: 'J. K. Rowling',
    category: 'Unity',
  ),
  EnQuote(
    text:
        'Do not pity the dead. Pity the living, and above all those who live without love.',
    author: 'J. K. Rowling',
    category: 'Love',
  ),
  EnQuote(
    text: 'The ones that love us never really leave us.',
    author: 'J. K. Rowling',
    category: 'Love',
  ),
  EnQuote(
    text: 'Give light, and the darkness will disappear of itself.',
    author: 'Desiderius Erasmus',
    category: 'Hope',
  ),
  EnQuote(
    text: 'In the land of the blind, the one-eyed man is king.',
    author: 'Desiderius Erasmus',
    category: 'Wisdom',
  ),
  EnQuote(
    text: 'The most disadvantageous peace is better than the most just war.',
    author: 'Desiderius Erasmus',
    category: 'Peace',
  ),
  EnQuote(
    text:
        'When I get a little money I buy books; and if any is left I buy food and clothes.',
    author: 'Desiderius Erasmus',
    category: 'Education',
  ),
  EnQuote(
    text: 'Fortune favors the audacious.',
    author: 'Desiderius Erasmus',
    category: 'Courage',
  ),
  EnQuote(
    text: 'It is wisdom to believe the heart.',
    author: 'George Santayana',
    category: 'Intuition',
  ),
  EnQuote(
    text: 'Those who cannot remember the past are condemned to repeat it.',
    author: 'George Santayana',
    category: 'History',
  ),
  EnQuote(
    text:
        'Almost every wise saying has an opposite one, no less wise, to balance it.',
    author: 'George Santayana',
    category: 'Philosophy',
  ),
  EnQuote(
    text: 'The earth has music for those who listen.',
    author: 'George Santayana',
    category: 'Nature',
  ),
  EnQuote(
    text:
        'To be interested in the changing seasons is a happier state of mind than to be hopelessly in love with spring.',
    author: 'George Santayana',
    category: 'Contentment',
  ),
  EnQuote(
    text:
        'The whole secret of life is to be interested in one thing profoundly and in a thousand other things well.',
    author: 'Horace Walpole',
    category: 'Curiosity',
  ),
  EnQuote(
    text:
        'The world is a book, and those who do not travel read only one page.',
    author: 'Saint Augustine',
    category: 'Adventure',
  ),
  EnQuote(
    text: 'Our heart is restless until it finds its rest in Thee.',
    author: 'Saint Augustine',
    category: 'Spirituality',
  ),
  EnQuote(
    text:
        'Thou hast made us for thyself, and our heart is restless until it finds rest in thee.',
    author: 'Saint Augustine',
    category: 'Faith',
  ),
  EnQuote(
    text: 'Do not despair of God\'s mercy.',
    author: 'Saint Augustine',
    category: 'Hope',
  ),
  EnQuote(
    text:
        'Count your age by friends, not years. Count your life by smiles, not tears.',
    author: 'John Lennon',
    category: 'Friendship',
  ),
  EnQuote(
    text:
        'A dream you dream alone is only a dream. A dream you dream together is reality.',
    author: 'John Lennon',
    category: 'Dreams',
  ),
  EnQuote(
    text: 'You may say I am a dreamer, but I am not the only one.',
    author: 'John Lennon',
    category: 'Hope',
  ),
  EnQuote(
    text: 'Imagine all the people living life in peace.',
    author: 'John Lennon',
    category: 'Peace',
  ),
  EnQuote(
    text: 'Time you enjoy wasting was not wasted.',
    author: 'John Lennon',
    category: 'Joy',
  ),
  EnQuote(
    text:
        'Everything will be okay in the end. If it is not okay, it is not the end.',
    author: 'John Lennon',
    category: 'Hope',
  ),
];
