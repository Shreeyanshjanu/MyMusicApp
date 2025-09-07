// import 'package:flutter/material.dart';
// import '../models/song_model.dart';
// import 'home_page.dart';
// import 'library_page.dart';
// import 'upload_page.dart';
// import 'settings_page.dart';

// class ColorPalette {
//   static const Color backgroundColor = Color.fromARGB(255, 226, 227, 237);
//   static const Color primaryTextColor = Color(0xFF6B7280);
//   static const Color hintTextColor = Color(0xFF9CA3AF);
//   static const Color darkShadowColor = Color.fromARGB(255, 188, 190, 195);
//   static const Color lightShadowColor = Colors.white;
//   static const double darkShadowOpacity = 0.5;
//   static const double lightShadowOpacity = 0.7;
//   static const Color accentColor = Color(0xFF6366F1);
// }

// class MainPage extends StatefulWidget {
//   final Song? initialSong;

//   const MainPage({super.key, this.initialSong});

//   @override
//   State<MainPage> createState() => _MainPageState();
// }

// class _MainPageState extends State<MainPage> {
//   int _currentIndex = 0;
//   Song? _currentSong;

//   @override
//   void initState() {
//     super.initState();
//     if (widget.initialSong != null) {
//       _currentSong = widget.initialSong;
//     }
//   }

//   List<Widget> get _pages => [
//     HomePage(initialSong: _currentSong),
//     const LibraryPage(),
//     const UploadPage(),
//     const SettingsPage(),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: ColorPalette.backgroundColor,
//       body: _pages[_currentIndex],
//       bottomNavigationBar: _buildBottomNavigationBar(),
//     );
//   }

//   Widget _buildBottomNavigationBar() {
//     final screenWidth = MediaQuery.of(context).size.width;
    
//     return Container(
//       height: screenWidth * 0.2,
//       margin: EdgeInsets.all(screenWidth * 0.05),
//       decoration: BoxDecoration(
//         color: ColorPalette.backgroundColor,
//         borderRadius: BorderRadius.circular(25),
//         boxShadow: [
//           BoxShadow(
//             color: ColorPalette.darkShadowColor.withOpacity(ColorPalette.darkShadowOpacity),
//             offset: const Offset(5, 5),
//             blurRadius: 10,
//           ),
//           BoxShadow(
//             color: ColorPalette.lightShadowColor.withOpacity(ColorPalette.lightShadowOpacity),
//             offset: const Offset(-5, -5),
//             blurRadius: 10,
//           ),
//         ],
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: [
//           _buildNavItem(Icons.home, 0),
//           _buildNavItem(Icons.favorite, 1),
//           _buildNavItem(Icons.add_circle, 2),
//           _buildNavItem(Icons.settings, 3),
//         ],
//       ),
//     );
//   }

//   Widget _buildNavItem(IconData icon, int index) {
//     final isSelected = _currentIndex == index;
//     final screenWidth = MediaQuery.of(context).size.width;
    
//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           _currentIndex = index;
//         });
//       },
//       child: Container(
//         width: screenWidth * 0.12,
//         height: screenWidth * 0.12,
//         decoration: BoxDecoration(
//           color: ColorPalette.backgroundColor,
//           shape: BoxShape.circle,
//           boxShadow: isSelected ? [
//             BoxShadow(
//               color: ColorPalette.darkShadowColor.withOpacity(0.3),
//               offset: const Offset(3, 3),
//               blurRadius: 6,
//             ),
//             BoxShadow(
//               color: ColorPalette.lightShadowColor.withOpacity(0.8),
//               offset: const Offset(-3, -3),
//               blurRadius: 6,
//             ),
//           ] : null,
//         ),
//         child: Icon(
//           icon,
//           size: screenWidth * 0.06,
//           color: isSelected ? ColorPalette.accentColor : ColorPalette.hintTextColor,
//         ),
//       ),
//     );
//   }
// }