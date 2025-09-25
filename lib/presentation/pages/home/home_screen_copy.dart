// import 'package:flutter/material.dart';
// import 'package:table_calendar/table_calendar.dart';
// import 'package:intl/intl.dart';

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   late final ValueNotifier<List<Event>> _selectedEvents;
//   CalendarFormat _calendarFormat = CalendarFormat.month;
//   RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOff;
//   DateTime _focusedDay = DateTime.now();
//   DateTime? _selectedDay;
//   DateTime? _rangeStart;
//   DateTime? _rangeEnd;

//   // Sample Bangladesh Government Holidays for 2024
//   final Map<DateTime, List<Event>> _holidays = {
//     DateTime(2024, 2, 21): [
//       const Event('শহীদ দিবস ও আন্তর্জাতিক মাতৃভাষা দিবস', 'national'),
//     ],
//     DateTime(2024, 3, 26): [
//       const Event('স্বাধীনতা ও জাতীয় দিবস', 'national'),
//     ],
//     DateTime(2024, 4, 14): [
//       const Event('পহেলা বৈশাখ', 'cultural'),
//     ],
//     DateTime(2024, 5, 1): [
//       const Event('মে দিবস', 'national'),
//     ],
//     DateTime(2024, 8, 15): [
//       const Event('জাতীয় শোক দিবস', 'national'),
//     ],
//     DateTime(2024, 12, 16): [
//       const Event('মহান বিজয় দিবস', 'national'),
//     ],
//   };

//   @override
//   void initState() {
//     super.initState();
//     _selectedDay = DateTime.now();
//     _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
//   }

//   @override
//   void dispose() {
//     _selectedEvents.dispose();
//     super.dispose();
//   }

//   List<Event> _getEventsForDay(DateTime day) {
//     return _holidays[DateTime(day.year, day.month, day.day)] ?? [];
//   }

//   List<Event> _getEventsForRange(DateTime start, DateTime end) {
//     final days = daysInRange(start, end);
//     return [
//       for (final d in days) ..._getEventsForDay(d),
//     ];
//   }

//   void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
//     if (!isSameDay(_selectedDay, selectedDay)) {
//       setState(() {
//         _selectedDay = selectedDay;
//         _focusedDay = focusedDay;
//         _rangeStart = null; // Important to clean those
//         _rangeEnd = null;
//         _rangeSelectionMode = RangeSelectionMode.toggledOff;
//       });

//       _selectedEvents.value = _getEventsForDay(selectedDay);
//     }
//   }

//   void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
//     setState(() {
//       _selectedDay = null;
//       _focusedDay = focusedDay;
//       _rangeStart = start;
//       _rangeEnd = end;
//       _rangeSelectionMode = RangeSelectionMode.toggledOn;
//     });

//     if (start != null && end != null) {
//       _selectedEvents.value = _getEventsForRange(start, end);
//     } else if (start != null) {
//       _selectedEvents.value = _getEventsForDay(start);
//     } else if (end != null) {
//       _selectedEvents.value = _getEventsForDay(end);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'একুশ পঞ্জি',
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.today),
//             onPressed: () {
//               setState(() {
//                 _focusedDay = DateTime.now();
//                 _selectedDay = DateTime.now();
//                 _selectedEvents.value = _getEventsForDay(DateTime.now());
//               });
//             },
//             tooltip: 'আজকের তারিখ',
//           ),
//           IconButton(
//             icon: const Icon(Icons.settings),
//             onPressed: () {
//               // TODO: Navigate to settings page
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text('সেটিংস শীঘ্রই আসছে')),
//               );
//             },
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           // Calendar Widget
//           Card(
//             margin: const EdgeInsets.all(12.0),
//             child: TableCalendar<Event>(
//               firstDay: DateTime.utc(2020, 1, 1),
//               lastDay: DateTime.utc(2030, 12, 31),
//               focusedDay: _focusedDay,
//               calendarFormat: _calendarFormat,
//               eventLoader: _getEventsForDay,
//               headerStyle: const HeaderStyle(
//                 formatButtonVisible: true,
//                 titleCentered: true,
//                 formatButtonShowsNext: false,
//                 formatButtonDecoration: BoxDecoration(
//                   color: Color(0xFF1B5E20),
//                   borderRadius: BorderRadius.all(Radius.circular(12.0)),
//                 ),
//                 formatButtonTextStyle: TextStyle(
//                   color: Colors.white,
//                 ),
//               ),
//               calendarStyle: const CalendarStyle(
//                 outsideDaysVisible: false,
//                 weekendTextStyle: TextStyle(color: Colors.red),
//                 holidayTextStyle: TextStyle(color: Colors.red),
//                 // Holiday decoration
//                 holidayDecoration: BoxDecoration(
//                   color: Colors.red,
//                   shape: BoxShape.circle,
//                 ),
//                 // Selected day decoration
//                 selectedDecoration: BoxDecoration(
//                   color: Color(0xFF1B5E20),
//                   shape: BoxShape.circle,
//                 ),
//                 // Today decoration
//                 todayDecoration: BoxDecoration(
//                   color: Color(0xFF4CAF50),
//                   shape: BoxShape.circle,
//                 ),
//                 // Event marker
//                 markerDecoration: BoxDecoration(
//                   color: Color(0xFFE53935),
//                   shape: BoxShape.circle,
//                 ),
//                 // Style for days with events
//                 markersMaxCount: 1,
//                 canMarkersOverflow: false,
//               ),
//               selectedDayPredicate: (day) {
//                 return isSameDay(_selectedDay, day);
//               },
//               rangeStartDay: _rangeStart,
//               rangeEndDay: _rangeEnd,
//               calendarBuilders: CalendarBuilders(
//                 // Custom builder for days with holidays
//                 defaultBuilder: (context, day, focusedDay) {
//                   final events = _getEventsForDay(day);
//                   if (events.isNotEmpty) {
//                     return Container(
//                       margin: const EdgeInsets.all(4.0),
//                       decoration: BoxDecoration(
//                         color: _getEventColor(events.first.type),
//                         shape: BoxShape.circle,
//                       ),
//                       child: Center(
//                         child: Text(
//                           '${day.day}',
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     );
//                   }
//                   return null;
//                 },
//               ),
//               onDaySelected: _onDaySelected,
//               onRangeSelected: _onRangeSelected,
//               onFormatChanged: (format) {
//                 if (_calendarFormat != format) {
//                   setState(() {
//                     _calendarFormat = format;
//                   });
//                 }
//               },
//               onPageChanged: (focusedDay) {
//                 _focusedDay = focusedDay;
//               },
//               rangeSelectionMode: _rangeSelectionMode,
//             ),
//           ),
          
//           // Current Date Display
//           Container(
//             width: double.infinity,
//             margin: const EdgeInsets.symmetric(horizontal: 12.0),
//             padding: const EdgeInsets.all(16.0),
//             decoration: BoxDecoration(
//               color: Theme.of(context).primaryColor.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(12.0),
//             ),
//             child: Column(
//               children: [
//                 Text(
//                   _getBengaliDate(DateTime.now()),
//                   style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                     color: Theme.of(context).primaryColor,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   DateFormat.yMMMMEEEEd('bn').format(DateTime.now()),
//                   style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                     color: Theme.of(context).primaryColor.withOpacity(0.8),
//                   ),
//                 ),
//               ],
//             ),
//           ),
          
//           const SizedBox(height: 8.0),
          
//           // Events List
//           Expanded(
//             child: ValueListenableBuilder<List<Event>>(
//               valueListenable: _selectedEvents,
//               builder: (context, value, _) {
//                 return ListView.builder(
//                   padding: const EdgeInsets.all(12.0),
//                   itemCount: value.length,
//                   itemBuilder: (context, index) {
//                     final event = value[index];
//                     return Card(
//                       child: ListTile(
//                         leading: CircleAvatar(
//                           backgroundColor: _getEventColor(event.type),
//                           child: Icon(
//                             _getEventIcon(event.type),
//                             color: Colors.white,
//                           ),
//                         ),
//                         title: Text(
//                           event.title,
//                           style: const TextStyle(
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         subtitle: Text(
//                           _getEventTypeText(event.type),
//                           style: TextStyle(
//                             color: _getEventColor(event.type),
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                         trailing: Icon(
//                           Icons.info_outline,
//                           color: Theme.of(context).primaryColor,
//                         ),
//                         onTap: () {
//                           _showEventDetails(context, event);
//                         },
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
      
//       // Floating Action Button for adding reminders
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           // TODO: Navigate to add reminder page
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('স্মারক যোগ করার ফিচার শীঘ্রই আসছে'),
//             ),
//           );
//         },
//         tooltip: 'স্মারক যোগ করুন',
//         child: const Icon(Icons.add),
//       ),
//     );
//   }

//   // Helper methods
//   Color _getEventColor(String type) {
//     switch (type) {
//       case 'national':
//         return const Color(0xFFE53935); // Red
//       case 'cultural':
//         return const Color(0xFF1B5E20); // Green
//       case 'religious':
//         return const Color(0xFF6A1B9A); // Purple
//       default:
//         return const Color(0xFF424242); // Grey
//     }
//   }

//   IconData _getEventIcon(String type) {
//     switch (type) {
//       case 'national':
//         return Icons.flag;
//       case 'cultural':
//         return Icons.celebration;
//       case 'religious':
//         return Icons.mosque;
//       default:
//         return Icons.event;
//     }
//   }

//   String _getEventTypeText(String type) {
//     switch (type) {
//       case 'national':
//         return 'জাতীয় দিবস';
//       case 'cultural':
//         return 'সাংস্কৃতিক দিবস';
//       case 'religious':
//         return 'ধর্মীয় দিবস';
//       default:
//         return 'অন্যান্য';
//     }
//   }

//   String _getBengaliDate(DateTime date) {
//     final bengaliMonths = [
//       'জানুয়ারি', 'ফেব্রুয়ারি', 'মার্চ', 'এপ্রিল', 'মে', 'জুন',
//       'জুলাই', 'আগস্ট', 'সেপ্টেম্বর', 'অক্টোবর', 'নভেম্বর', 'ডিসেম্বর'
//     ];
    
//     final bengaliNumbers = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    
//     String convertToBengaliNumber(int number) {
//       return number.toString().split('').map((digit) {
//         return bengaliNumbers[int.parse(digit)];
//       }).join('');
//     }
    
//     return '${convertToBengaliNumber(date.day)} ${bengaliMonths[date.month - 1]}, ${convertToBengaliNumber(date.year)}';
//   }

//   void _showEventDetails(BuildContext context, Event event) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text(event.title),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(
//                   _getEventIcon(event.type),
//                   color: _getEventColor(event.type),
//                 ),
//                 const SizedBox(width: 8),
//                 Text(
//                   _getEventTypeText(event.type),
//                   style: TextStyle(
//                     color: _getEventColor(event.type),
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             const Text(
//               'এই দিবসটি বাংলাদেশের একটি গুরুত্বপূর্ণ দিন। আরও বিস্তারিত তথ্য শীঘ্রই যোগ করা হবে।',
//               style: TextStyle(fontSize: 14),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text('বন্ধ করুন'),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // Event class
// class Event {
//   final String title;
//   final String type;

//   const Event(this.title, this.type);

//   @override
//   String toString() => title;
// }

// // Utility function for date ranges
// List<DateTime> daysInRange(DateTime first, DateTime last) {
//   final dayCount = last.difference(first).inDays + 1;
//   return List.generate(
//     dayCount,
//     (index) => DateTime.utc(first.year, first.month, first.day + index),
//   );
// }