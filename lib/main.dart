import 'package:xplorion_ai/views/edit_your_interests.dart';
import 'package:xplorion_ai/views/your_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:xplorion_ai/providers/ci_date_provider.dart';
import 'package:xplorion_ai/views/account_setup.dart';
import 'package:xplorion_ai/views/choose_your_interests.dart';
import 'package:xplorion_ai/views/continue_planning.dart';
import 'package:xplorion_ai/views/create_itinerary.dart';
import 'package:xplorion_ai/views/explore_road_map.dart';
import 'package:xplorion_ai/views/feedback.dart';
import 'package:xplorion_ai/views/forgot_password.dart';
import 'package:xplorion_ai/views/friends.dart';
import 'package:xplorion_ai/views/home_page.dart';
import 'package:xplorion_ai/views/home_page_trip.dart';
import 'package:xplorion_ai/views/itinerary_generating_screen.dart';
import 'package:xplorion_ai/views/login.dart';
import 'package:xplorion_ai/views/password_reset_success.dart';
import 'package:xplorion_ai/views/profile.dart';
import 'package:xplorion_ai/views/saved_indetailed_itinerary.dart';
import 'package:xplorion_ai/views/saved_itineraries.dart';
import 'package:xplorion_ai/views/set_password.dart';
import 'package:xplorion_ai/views/sign_up.dart';
import 'package:xplorion_ai/views/similar_restuarants.dart';
import 'package:xplorion_ai/views/splash_screen.dart';
import 'package:xplorion_ai/views/trip_settings.dart';
import 'package:xplorion_ai/views/verify_otp.dart';
import 'package:xplorion_ai/views/welcome_screen.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CIDateProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Xplorion AI',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: const [
        Locale('en', ''),
        Locale('zh', ''),
        Locale('he', ''),
        Locale('es', ''),
        Locale('ru', ''),
        Locale('ko', ''),
        Locale('hi', ''),
      ],
      home: const SpalshScreen(),
      routes: {
        '/login': (context) => const LogIn(),
        '/sign_up': (context) => const SignUp(),
        '/choose_your_interests': (context) => const ChooseYourInterests(),
        '/account_setup': (context) => const AccountSetup(),
        '/welcome_page': (context) => const WelcomePage(),
        '/home_page': (context) => const HomePage(),
        '/continue_planning': (context) => const ContinuePlanning(),
        '/create_itinerary': (context) => const CreateItinerary(),
        '/itinerary_generating_screen': (context) =>
            const ItineraryGeneratingScreen(),
        '/home_page_trip': (context) => const HomePageTrip(),
        '/explore_road_map': (context) => const ExploreRoadMap(),
        '/profile': (context) => const Profile(),
        '/Saved': (context) => const SavedItineraries(),
        '/detailed_saved_itinerary': (context) =>
            const SavedInDetailedItinerary(),
        '/Feedback': (context) => const FeedBack(),
        '/trip_settings': (context) => const TripSettings(),
        '/friends': (context) => const Friends(),
        '/forgot_password': (context) => const ForgotPassword(),
        '/verify_otp': (context) => const VerifyOtp(),
        '/set_password': (context) => const SetPassword(),
        '/password_reset_successful': (context) => const PasswordResetSuccess(),
        '/similar_restuarant': (context) => const SimilarRestuarants(),
        '/your_profile': (context) => const YourProfile(),
        '/edit_your_interests': (context) => const EditYourInterests(),
      },
    );
  }
}

// Maps API KEY : AIzaSyDEJx-EbYbqRixjZ0DvwuPd3FKVKtvv_OY
