import 'package:xplorion_ai/views/about.dart';
import 'package:xplorion_ai/views/edit_your_interests.dart';
import 'package:xplorion_ai/views/privacy_policy.dart';
import 'package:xplorion_ai/views/shared_itinerary.dart';
import 'package:xplorion_ai/views/splash_screen.dart';
import 'package:xplorion_ai/views/terms_and_condition.dart';
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
import 'package:xplorion_ai/views/splash_screen_two.dart';
import 'package:xplorion_ai/views/trip_settings.dart';
import 'package:xplorion_ai/views/verify_otp.dart';
import 'package:xplorion_ai/views/welcome_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_microsoft_clarity/flutter_microsoft_clarity.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterMicrosoftClarity().init(projectId: 'ri7ug1xgjk');
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CIDateProvider()),
        ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  String _platformVersion = 'Unknown';
  final _flutterMicrosoftClarityPlugin = FlutterMicrosoftClarity();
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  @override
  void initState() {
    super.initState();
    _initConnectivity();
    _setupConnectivityListener();
    initPlatformState();
  }

  Future<void> _initConnectivity() async {
    final connectivityProvider =
        Provider.of<ConnectivityProvider>(context, listen: false);
    await connectivityProvider.checkConnectivity();
  }

  void _setupConnectivityListener() {
    Connectivity().onConnectivityChanged.listen((results) {
      final connectivityProvider =
          Provider.of<ConnectivityProvider>(context, listen: false);
      final isOffline =
          results.any((result) => result == ConnectivityResult.none);

      connectivityProvider.setOffline(isOffline);

      // Navigate to NoInternetScreen if offline
      if (isOffline) {
        _navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => NoInternetScreen()),
          (route) => false,
        );
      } else {
        // Navigate back to SplashScreen if online
        _navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => SplashScreen()),
          (route) => false,
        );
      }
    });
  }

  Future<void> initPlatformState() async {
    String platformVersion;

    try {
      platformVersion =
          await _flutterMicrosoftClarityPlugin.getPlatformVersion() ??
              'Unknown platform version';
    } catch (e) {
      print('Error: $e');
      platformVersion = 'Failed to get platform version.';
    }
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
    print(
        'Platform version: $_platformVersion +++++++++++++++++++++++++++++++++++++++++++++++++++++++');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'Xplorion Ai',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF0099FF)),
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
      home: Consumer<ConnectivityProvider>(
        builder: (context, connectivityProvider, child) {
          return connectivityProvider.isOffline
              ? NoInternetScreen()
              : SplashScreen();
        },
      ),
      routes: {
        '/splash_screen_two': (context) => const SplashScreenTwo(),
        '/login': (context) => const LogIn(),
        '/sign_up': (context) => const SignUp(),
        '/choose_your_interests': (context) => const ChooseYourInterests(),
        '/account_setup': (context) => const AccountSetup(),
        '/welcome_page': (context) => const WelcomePage(),
        '/home_page': (context) => HomePage(),
        '/continue_planning': (context) => const ContinuePlanning(),
        '/shared_itinerarys': (context) => const SharedItinerary(),
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
        // '/friends': (context) => const Friends(),
        '/forgot_password': (context) => const ForgotPassword(),
        '/verify_otp': (context) => const VerifyOtp(),
        '/set_password': (context) => const SetPassword(),
        '/password_reset_successful': (context) => const PasswordResetSuccess(),
        '/similar_restuarant': (context) => const SimilarRestuarants(),
        '/your_profile': (context) => const YourProfile(),
        '/edit_your_interests': (context) => const EditYourInterests(),
        '/about': (context) => AboutPage(),
        '/privacy_policy': (context) => PrivacyPolicyPage(),
        '/terms_and_conditions': (context) => TermsAndConditionsPage(),
      },
      navigatorObservers: [
        CustomNavigatorObserver(
          onPopNext: () {
            print("Navigated back to HomePage");
            // Call fetchItineraries when HomePage is shown again
            homePageKey.currentState?.fetchItineraries();
          },
        ),
        FirebaseAnalyticsObserver(analytics: analytics),
      ],
    );
  }
}

class ConnectivityProvider with ChangeNotifier {
  bool _isOffline = false;

  bool get isOffline => _isOffline;

  Future<void> checkConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    _isOffline =
        connectivityResult.any((result) => result == ConnectivityResult.none);
    notifyListeners();
  }

  void setOffline(bool offline) {
    print("offline : $offline");
    _isOffline = offline;
    notifyListeners();
  }
}

// Maps API KEY : AIzaSyDEJx-EbYbqRixjZ0DvwuPd3FKVKtvv_OY

class NoInternetScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, size: 80, color: Colors.grey),
            const SizedBox(height: 20),
            const Text(
              "No Internet Connection",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Check your network and try again.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                var connectivityResult =
                    await Connectivity().checkConnectivity();
                print('Connectivity result: $connectivityResult');

                if (!connectivityResult
                    .any((result) => result == ConnectivityResult.none)) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => SplashScreen()),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          "Still no internet connection. Please try again."),
                    ),
                  );
                }
              },
              child: const Text("Retry"),
            ),
          ],
        ),
      ),
    );
  }
}
