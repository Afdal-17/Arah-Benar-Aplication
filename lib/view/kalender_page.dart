import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:google_fonts/google_fonts.dart';

class KalenderPage extends StatefulWidget {
  const KalenderPage({super.key});

  @override
  State<KalenderPage> createState() => _KalenderPageState();
}

class _KalenderPageState extends State<KalenderPage> {
  DateTime selectedDate = DateTime.now();

  void nextMonth() {
    setState(() {
      selectedDate = DateTime(
        selectedDate.year,
        selectedDate.month + 1,
      );
    });
  }

  void prevMonth() {
    setState(() {
      selectedDate = DateTime(
        selectedDate.year,
        selectedDate.month - 1,
      );
    });
  }

  List<Widget> buildCalendar() {
    List<Widget> days = [];

    DateTime firstDayOfMonth =
        DateTime(selectedDate.year, selectedDate.month, 1);

    int weekday = firstDayOfMonth.weekday;
    int totalDays =
        DateTime(selectedDate.year, selectedDate.month + 1, 0).day;

    for (int i = 1; i < weekday; i++) {
      days.add(const SizedBox());
    }

    for (int i = 1; i <= totalDays; i++) {
      DateTime day = DateTime(
        selectedDate.year,
        selectedDate.month,
        i,
      );

      bool isToday = day.day == DateTime.now().day &&
          day.month == DateTime.now().month &&
          day.year == DateTime.now().year;

      bool isFriday = day.weekday == 5;

      days.add(
        Container(
          margin: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: isToday
                ? const Color(0xFFD4AF37)
                : const Color(0xFF152238),
            borderRadius: BorderRadius.circular(12),
            border: isToday
                ? null
                : Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Center(
            child: Text(
              "$i",
              style: GoogleFonts.poppins(
                color: isToday
                    ? const Color(0xFF0D1B2A)
                    : isFriday
                        ? const Color(0xFF00BFA6)
                        : Colors.white70,
                fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                fontSize: 13,
              ),
            ),
          ),
        ),
      );
    }

    return days;
  }

  @override
  Widget build(BuildContext context) {
    String bulan =
        DateFormat('MMMM yyyy', 'id_ID').format(selectedDate);

    HijriCalendar hijri = HijriCalendar.now();

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: Text("Kalender",
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// Hijriyah date card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1B3A4B), Color(0xFF152238)],
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: const Color(0xFFD4AF37).withOpacity(0.2),
                ),
              ),
              child: Column(
                children: [
                  const Icon(Icons.nightlight_round,
                      color: Color(0xFFD4AF37), size: 28),
                  const SizedBox(height: 8),
                  Text(
                    "${hijri.hDay} ${hijri.longMonthName} ${hijri.hYear} H",
                    style: GoogleFonts.amiri(
                      color: const Color(0xFFD4AF37),
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('EEEE, dd MMMM yyyy', 'id_ID')
                        .format(DateTime.now()),
                    style: GoogleFonts.poppins(
                      color: Colors.white54,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// Month navigation
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: prevMonth,
                  icon: const Icon(Icons.chevron_left,
                      color: Color(0xFFD4AF37), size: 28),
                ),
                Text(
                  bulan,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  onPressed: nextMonth,
                  icon: const Icon(Icons.chevron_right,
                      color: Color(0xFFD4AF37), size: 28),
                ),
              ],
            ),

            const SizedBox(height: 12),

            /// Day labels
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min']
                  .map((d) => SizedBox(
                        width: 38,
                        child: Text(
                          d,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: d == 'Jum'
                                ? const Color(0xFF00BFA6)
                                : Colors.white38,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ))
                  .toList(),
            ),

            const SizedBox(height: 10),

            /// Calendar grid
            Expanded(
              child: GridView.count(
                crossAxisCount: 7,
                physics: const NeverScrollableScrollPhysics(),
                children: buildCalendar(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}