import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nhac_lojas/routes/go_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  static const Color coral = Color(0xFFFF6961);
  static const Color fundo = Color(0xFFFFE7E5);
  static const Color marrom = Color(0xFF5D201C);

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => MaterialApp.router(
        routerConfig: appRouter,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          fontFamily: 'Roboto',
          scaffoldBackgroundColor: fundo,
          colorScheme: ColorScheme.fromSeed(
            seedColor: coral,
            primary: coral,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: marrom,
            error: const Color(0xFFC63F35),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: fundo,
            foregroundColor: marrom,
            elevation: 0,
          ),
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: marrom),
            bodyMedium: TextStyle(color: marrom),
            bodySmall: TextStyle(color: marrom),
            titleLarge: TextStyle(color: marrom, fontWeight: FontWeight.w700),
            titleMedium: TextStyle(color: marrom, fontWeight: FontWeight.w600),
          ),
          cardTheme: CardThemeData(
            color: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            hintStyle: const TextStyle(color: Color(0xFF9B7774)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFF5C4C1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFF5C4C1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: coral, width: 1.5),
            ),
          ),
          bottomSheetTheme: const BottomSheetThemeData(
            backgroundColor: Colors.white,
            dragHandleColor: Color(0xFFC9BCBC),
            showDragHandle: true,
          ),
          snackBarTheme: SnackBarThemeData(
            behavior: SnackBarBehavior.floating,
            backgroundColor: marrom,
            contentTextStyle: const TextStyle(color: Colors.white),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }
}
