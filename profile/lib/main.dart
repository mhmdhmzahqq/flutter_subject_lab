import 'package:flutter/material.dart';

void main() {
  runApp(const CVApp());
}

class CVApp extends StatelessWidget {
  const CVApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(debugShowCheckedModeBanner: false, home: CVPage());
  }
}

class CVPage extends StatelessWidget {
  const CVPage({super.key});

  @override
  Widget build(BuildContext context) {
    // نجيب أبعاد الشاشة
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF333333),
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.05), // هامش نسبي
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  // الصورة
                  Padding(
                    padding: EdgeInsets.all(screenWidth * 0.02),
                    child: CircleAvatar(
                      radius: screenWidth * 0.15, // متجاوبة حسب العرض
                      backgroundColor: Colors.grey,
                      // backgroundImage: AssetImage('assets/my.jpg'),
                    ),
                  ),
                  // النصوص
                  Flexible(
                    child: Column(
                      children: [
                        Text(
                          "Mohammed Ben Hamzah",
                          style: TextStyle(
                            fontSize: screenWidth * 0.04, // نص متجاوب
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.006),
                        Text(
                          "Mobile App Developer",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenWidth * 0.03,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Divider أسفل كل العناصر
              Padding(
                padding: EdgeInsets.symmetric(vertical: screenHeight * 0.001),
                child: Divider(
                  color: Colors.yellow,
                  thickness: screenWidth * 0.003, // سماكة الخط حسب العرض
                  indent: screenWidth * 0.02, // مسافة البداية
                  endIndent: screenWidth * 0.02, // مسافة النهاية
                ),
              ),

              // القسم الثاني
              Padding(
                padding: EdgeInsets.fromLTRB(0, screenHeight * 0.02, 0, 0),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // الخط العمودي يمتد على طول النصوص
                      VerticalDivider(
                        color: Colors.yellow,
                        thickness: screenWidth * 0.003,
                      ),

                      // النصوص
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "About me",
                              style: TextStyle(
                                color: Colors.yellow,
                                fontSize: screenWidth * 0.035,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              "building high-quality apps for Flutter and Android/iOS platforms. I have experience creating smooth user interfaces, optimizing app performance, and integrating applications with databases and APIs. I am always eager to learn new technologies and transform ideas into practical, user-friendly applications.",
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // القسم الثالث
              Padding(
                padding: EdgeInsets.fromLTRB(0, screenHeight * 0.02, 0, 0),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // الخط العمودي يمتد على طول النصوص
                      VerticalDivider(
                        color: Colors.yellow,
                        thickness: screenWidth * 0.003,
                      ),

                      // النصوص
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Skills",
                            style: TextStyle(
                              color: Colors.yellow,
                              fontSize: screenWidth * 0.035,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "• Flutter Development",
                            style: TextStyle(color: Colors.white),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "• Dart Programming",
                            style: TextStyle(color: Colors.white),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "• Android/iOS App Development",
                            style: TextStyle(color: Colors.white),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "• UI/UX Design",
                            style: TextStyle(color: Colors.white),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "• API Integration",
                            style: TextStyle(color: Colors.white),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "• State Management (Provider, Bloc)",
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.fromLTRB(0, screenHeight * 0.02, 0, 0),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // الخط العمودي يمتد على طول النصوص
                      VerticalDivider(
                        color: Colors.yellow,
                        thickness: screenWidth * 0.003,
                      ),

                      // النصوص
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Experiences", // تم تغيير العنوان
                              style: TextStyle(
                                color: Colors.yellow,
                                fontSize: screenWidth * 0.035,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              "• Built e-commerce mobile apps",
                              style: TextStyle(color: Colors.white),
                            ),
                            SizedBox(height: 5),
                            Text(
                              "• Developed chat and messaging apps",
                              style: TextStyle(color: Colors.white),
                            ),
                            SizedBox(height: 5),
                            Text(
                              "• Optimized app performance and responsiveness",
                              style: TextStyle(color: Colors.white),
                            ),
                            SizedBox(height: 5),
                            Text(
                              "• Integrated apps with RESTful APIs and databases",
                              style: TextStyle(color: Colors.white),
                            ),
                            SizedBox(height: 5),
                            Text(
                              "• Collaborated with cross-functional teams on UI/UX",
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget bulletPoint(String text) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("• ", style: TextStyle(color: Colors.white, fontSize: 16)),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ],
    ),
  );
}
