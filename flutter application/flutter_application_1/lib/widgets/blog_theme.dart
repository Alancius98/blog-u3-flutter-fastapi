import 'package:flutter/material.dart';

const blogOrange = Color(0xFFC54B17);
const blogInk = Color(0xFF302820);
const blogPaper = Color(0xFFFBF8F3);
const blogMuted = Color(0xFF73675D);

ThemeData buildBlogTheme() => ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: blogPaper,
  colorScheme: ColorScheme.fromSeed(
    seedColor: blogOrange,
    primary: blogOrange,
    surface: blogPaper,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: blogPaper,
    foregroundColor: blogInk,
    centerTitle: false,
    elevation: 0,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFDED5CA)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: blogOrange, width: 2),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: blogOrange,
      foregroundColor: Colors.white,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: blogOrange,
    foregroundColor: Colors.white,
  ),
  chipTheme: ChipThemeData(
    selectedColor: const Color(0xFFFBE4D5),
    backgroundColor: Colors.white,
    side: const BorderSide(color: Color(0xFFE1D7CC)),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  ),
  snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
);

class BlogBrand extends StatelessWidget {
  final bool light;
  const BlogBrand({super.key, this.light = false});
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: light ? Colors.white : blogOrange,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Icon(
          Icons.edit_note_rounded,
          color: light ? blogOrange : Colors.white,
          size: 24,
        ),
      ),
      const SizedBox(width: 10),
      Flexible(
        child: Text(
          'Mi Blog',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: light ? Colors.white : blogInk,
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
      ),
    ],
  );
}
