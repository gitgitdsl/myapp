import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '학교 연간 시간표 생성기',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('학교 연간 시간표 생성기'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '학교 연간 시간표 생성 프로그램',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SubjectInputPage()),
                );
              },
              child: Text('시작하기'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 1. 과목 입력 페이지
class SubjectInputPage extends StatefulWidget {
  @override
  _SubjectInputPageState createState() => _SubjectInputPageState();
}

class _SubjectInputPageState extends State<SubjectInputPage> {
  List<String> subjects = [];
  TextEditingController subjectController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('과목 입력'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('월요일부터 금요일까지 사용할 과목명을 입력하세요', style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: subjectController,
                    decoration: InputDecoration(
                      labelText: '과목명',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    if (subjectController.text.isNotEmpty) {
                      setState(() {
                        subjects.add(subjectController.text);
                        subjectController.clear();
                      });
                    }
                  },
                  child: Text('추가'),
                ),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: subjects.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(subjects[index]),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          subjects.removeAt(index);
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: subjects.isEmpty
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AcademicCalendarPage(subjects: subjects),
                        ),
                      );
                    },
              child: Text('다음: 학사일정 입력'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 2. 학사일정 입력 페이지
class AcademicCalendarPage extends StatefulWidget {
  final List<String> subjects;

  AcademicCalendarPage({required this.subjects});

  @override
  _AcademicCalendarPageState createState() => _AcademicCalendarPageState();
}

class _AcademicCalendarPageState extends State<AcademicCalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  
  Map<DateTime, List<Event>> events = {};
  
  TextEditingController eventController = TextEditingController();
  String selectedEventType = '공휴일';
  
  List<String> eventTypes = ['공휴일', '대체휴업일', '재량휴업일', '방학 시작', '방학 종료'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('학사일정 입력'),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(DateTime.now().year, 1, 1),
            lastDay: DateTime.utc(DateTime.now().year + 1, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            eventLoader: (day) {
              final normalizedDay = DateTime(day.year, day.month, day.day);
              return events[normalizedDay] ?? [];
            },
          ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedEventType,
                    decoration: InputDecoration(
                      labelText: '일정 유형',
                      border: OutlineInputBorder(),
                    ),
                    items: eventTypes.map((String type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          selectedEventType = newValue;
                        });
                      }
                    },
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _selectedDay == null
                      ? null
                      : () {
                          if (_selectedDay != null) {
                            final normalizedDay = DateTime(
                              _selectedDay!.year,
                              _selectedDay!.month,
                              _selectedDay!.day,
                            );
                            
                            setState(() {
                              if (events[normalizedDay] == null) {
                                events[normalizedDay] = [];
                              }
                              
                              events[normalizedDay]!.add(
                                Event(title: selectedEventType),
                              );
                            });
                            
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('$selectedEventType 일정이 추가되었습니다: ${DateFormat('yyyy-MM-dd').format(normalizedDay)}'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                  child: Text('일정 추가'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _selectedDay == null
                ? Center(child: Text('날짜를 선택하세요'))
                : ListView(
                    children: _getEventsForDay(_selectedDay!).map((Event event) {
                      return ListTile(
                        title: Text(event.title),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              final normalizedDay = DateTime(
                                _selectedDay!.year,
                                _selectedDay!.month,
                                _selectedDay!.day,
                              );
                              events[normalizedDay]?.remove(event);
                              if (events[normalizedDay]?.isEmpty ?? false) {
                                events.remove(normalizedDay);
                              }
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WeeklySchedulePage(
                      subjects: widget.subjects,
                      academicEvents: events,
                    ),
                  ),
                );
              },
              child: Text('다음: 주간 시간표 입력'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Event> _getEventsForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return events[normalizedDay] ?? [];
  }
}

class Event {
  final String title;

  Event({required this.title});
}

// 3. 주간 시간표 입력 페이지
class WeeklySchedulePage extends StatefulWidget {
  final List<String> subjects;
  final Map<DateTime, List<Event>> academicEvents;

  WeeklySchedulePage({required this.subjects, required this.academicEvents});

  @override
  _WeeklySchedulePageState createState() => _WeeklySchedulePageState();
}

class _WeeklySchedulePageState extends State<WeeklySchedulePage> {
  // 요일별 교시 시간표
  Map<String, List<String>> weeklySchedule = {
    '월요일': [],
    '화요일': [],
    '수요일': [],
    '목요일': [],
    '금요일': [],
  };

  int periodsPerDay = 7; // 기본 교시 수
  String selectedDay = '월요일';
  String? selectedSubject;

  @override
  void initState() {
    super.initState();
    // 모든 요일에 빈 시간표 초기화
    weeklySchedule.forEach((day, schedule) {
      weeklySchedule[day] = List.filled(periodsPerDay, '');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('주간 시간표 입력'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('교시 수: $periodsPerDay', style: TextStyle(fontSize: 16)),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.remove),
                      onPressed: () {
                        if (periodsPerDay > 1) {
                          setState(() {
                            periodsPerDay--;
                            // 모든 요일의 교시 수 조정
                            weeklySchedule.forEach((day, schedule) {
                              if (schedule.length > periodsPerDay) {
                                weeklySchedule[day] = schedule.sublist(0, periodsPerDay);
                              }
                            });
                          });
                        }
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        setState(() {
                          periodsPerDay++;
                          // 모든 요일의 교시 수 조정
                          weeklySchedule.forEach((day, schedule) {
                            if (schedule.length < periodsPerDay) {
                              weeklySchedule[day]!.add('');
                            }
                          });
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            // 요일 선택 탭
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: weeklySchedule.keys.map((day) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedDay == day ? Colors.blue : Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          selectedDay = day;
                        });
                      },
                      child: Text(day),
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 20),
            // 선택한 요일의 시간표
            Expanded(
              child: ListView.builder(
                itemCount: periodsPerDay,
                itemBuilder: (context, index) {
                  // 현재 요일 및 교시의 과목
                  String currentSubject = 
                      weeklySchedule[selectedDay]!.length > index 
                          ? weeklySchedule[selectedDay]![index] 
                          : '';
                          
                  return ListTile(
                    title: Text('${index + 1}교시'),
                    subtitle: Text(currentSubject.isEmpty ? '과목 미지정' : currentSubject),
                    trailing: DropdownButton<String>(
                      hint: Text('과목 선택'),
                      value: currentSubject.isEmpty ? null : currentSubject,
                      items: [
                        // 빈 과목 선택지 추가
                        DropdownMenuItem<String>(
                          value: '',
                          child: Text('없음'),
                        ),
                        // 입력된 과목들
                        ...widget.subjects.map((subject) {
                          return DropdownMenuItem<String>(
                            value: subject,
                            child: Text(subject),
                          );
                        }).toList(),
                      ],
                      onChanged: (String? newValue) {
                        setState(() {
                          // 해당 교시의 과목 업데이트
                          if (weeklySchedule[selectedDay]!.length > index) {
                            weeklySchedule[selectedDay]![index] = newValue ?? '';
                          } else {
                            // 배열 크기가 부족한 경우 확장
                            while (weeklySchedule[selectedDay]!.length <= index) {
                              weeklySchedule[selectedDay]!.add('');
                            }
                            weeklySchedule[selectedDay]![index] = newValue ?? '';
                          }
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // 시간표 검증
                bool isScheduleComplete = true;
                String incompleteDay = '';
                
                weeklySchedule.forEach((day, schedule) {
                  if (schedule.length < periodsPerDay) {
                    isScheduleComplete = false;
                    incompleteDay = day;
                  }
                });
                
                if (!isScheduleComplete) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$incompleteDay의 시간표가 완성되지 않았습니다.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  return;
                }
                
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => YearlySchedulePage(
                      subjects: widget.subjects,
                      academicEvents: widget.academicEvents,
                      weeklySchedule: weeklySchedule,
                      periodsPerDay: periodsPerDay,
                    ),
                  ),
                );
              },
              child: Text('연간 시간표 생성하기'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 4. 연간 시간표 생성 및 결과 페이지
class YearlySchedulePage extends StatefulWidget {
  final List<String> subjects;
  final Map<DateTime, List<Event>> academicEvents;
  final Map<String, List<String>> weeklySchedule;
  final int periodsPerDay;

  YearlySchedulePage({
    required this.subjects, 
    required this.academicEvents,
    required this.weeklySchedule,
    required this.periodsPerDay,
  });

  @override
  _YearlySchedulePageState createState() => _YearlySchedulePageState();
}

class _YearlySchedulePageState extends State<YearlySchedulePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<DateTime, Map<int, String>> yearlySchedule = {};
  List<DateTime> schoolDays = [];
  
  DateTime firstSemesterStart = DateTime(DateTime.now().year, 3, 1);
  DateTime firstSemesterEnd = DateTime(DateTime.now().year, 7, 31);
  DateTime secondSemesterStart = DateTime(DateTime.now().year, 8, 20);
  DateTime secondSemesterEnd = DateTime(DateTime.now().year, 12, 31);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // 학기 시작/종료일 설정
    // 여기서는 기본값으로 설정했지만, 실제로는 방학 일정에서 가져와야 함
    widget.academicEvents.forEach((date, events) {
      for (Event event in events) {
        if (event.title == '방학 시작') {
          if (date.month < 8) {
            firstSemesterEnd = date.subtract(Duration(days: 1));
          } else {
            secondSemesterEnd = date.subtract(Duration(days: 1));
          }
        } else if (event.title == '방학 종료') {
          if (date.month < 8) {
            firstSemesterStart = date.add(Duration(days: 1));
          } else {
            secondSemesterStart = date.add(Duration(days: 1));
          }
        }
      }
    });
    
    // 연간 시간표 생성
    generateYearlySchedule();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void generateYearlySchedule() {
    // 1학기 시간표 생성
    _generateSemesterSchedule(firstSemesterStart, firstSemesterEnd);
    
    // 2학기 시간표 생성
    _generateSemesterSchedule(secondSemesterStart, secondSemesterEnd);
    
    setState(() {});
  }

  void _generateSemesterSchedule(DateTime startDate, DateTime endDate) {
    DateTime currentDate = startDate;
    
    while (currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate)) {
      // 주말 제외
      if (currentDate.weekday >= 1 && currentDate.weekday <= 5) {
        // 공휴일, 휴업일 등 학사일정 체크
        bool isSchoolDay = true;
        
        final normalizedDate = DateTime(
          currentDate.year,
          currentDate.month,
          currentDate.day,
        );
        
        if (widget.academicEvents.containsKey(normalizedDate)) {
          for (Event event in widget.academicEvents[normalizedDate]!) {
            if (['공휴일', '대체휴업일', '재량휴업일', '방학 시작', '방학 종료'].contains(event.title)) {
              isSchoolDay = false;
              break;
            }
          }
        }
        
        if (isSchoolDay) {
          // 요일에 맞는 시간표 적용
          String dayOfWeek;
          switch (currentDate.weekday) {
            case 1: dayOfWeek = '월요일'; break;
            case 2: dayOfWeek = '화요일'; break;
            case 3: dayOfWeek = '수요일'; break;
            case 4: dayOfWeek = '목요일'; break;
            case 5: dayOfWeek = '금요일'; break;
            default: dayOfWeek = ''; break;
          }
          
          if (dayOfWeek.isNotEmpty) {
            yearlySchedule[normalizedDate] = {};
            
            for (int period = 0; period < widget.periodsPerDay; period++) {
              if (widget.weeklySchedule[dayOfWeek]!.length > period) {
                yearlySchedule[normalizedDate]![period + 1] = 
                    widget.weeklySchedule[dayOfWeek]![period];
              }
            }
            
            schoolDays.add(normalizedDate);
          }
        }
      }
      
      // 다음 날짜로 이동
      currentDate = currentDate.add(Duration(days: 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1학기와 2학기 날짜 분리
    List<DateTime> firstSemesterDays = schoolDays.where(
      (date) => date.isAfter(firstSemesterStart.subtract(Duration(days: 1))) && 
                date.isBefore(firstSemesterEnd.add(Duration(days: 1)))
    ).toList();
    
    List<DateTime> secondSemesterDays = schoolDays.where(
      (date) => date.isAfter(secondSemesterStart.subtract(Duration(days: 1))) && 
                date.isBefore(secondSemesterEnd.add(Duration(days: 1)))
    ).toList();
    
    return Scaffold(
      appBar: AppBar(
        title: Text('연간 시간표'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: '1학기'),
            Tab(text: '2학기'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1학기 시간표
          _buildSemesterSchedule(firstSemesterDays),
          
          // 2학기 시간표
          _buildSemesterSchedule(secondSemesterDays),
        ],
      ),
    );
  }

  Widget _buildSemesterSchedule(List<DateTime> semesterDays) {
    // 날짜순으로 정렬
    semesterDays.sort((a, b) => a.compareTo(b));
    
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            '${semesterDays.isNotEmpty ? DateFormat('yyyy년 MM월 dd일').format(semesterDays.first) : ""} ~ '
            '${semesterDays.isNotEmpty ? DateFormat('yyyy년 MM월 dd일').format(semesterDays.last) : ""}',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: semesterDays.isEmpty
              ? Center(child: Text('해당 학기에 수업일이 없습니다.'))
              : ListView.builder(
                  itemCount: semesterDays.length,
                  itemBuilder: (context, index) {
                    DateTime day = semesterDays[index];
                    String dayOfWeek;
                    switch (day.weekday) {
                      case 1: dayOfWeek = '월요일'; break;
                      case 2: dayOfWeek = '화요일'; break;
                      case 3: dayOfWeek = '수요일'; break;
                      case 4: dayOfWeek = '목요일'; break;
                      case 5: dayOfWeek = '금요일'; break;
                      default: dayOfWeek = ''; break;
                    }
                    
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: ExpansionTile(
                        title: Text(
                          '${DateFormat('yyyy년 MM월 dd일').format(day)} ($dayOfWeek)',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Table(
                              border: TableBorder.all(),
                              children: [
                                TableRow(
                                  children: [
                                    TableCell(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text('교시', textAlign: TextAlign.center),
                                      ),
                                    ),
                                    TableCell(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text('과목', textAlign: TextAlign.center),
                                      ),
                                    ),
                                  ],
                                ),
                                ...List.generate(widget.periodsPerDay, (periodIndex) {
                                  int period = periodIndex + 1;
                                  String subject = yearlySchedule[day]?[period] ?? '';
                                  
                                  return TableRow(
                                    children: [
                                      TableCell(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text('$period', textAlign: TextAlign.center),
                                        ),
                                      ),
                                      TableCell(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(subject, textAlign: TextAlign.center),
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
