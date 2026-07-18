import 'package:flutter/material.dart';
import 'widgets/app_theme.dart';
import 'screens/disclaimer_screen.dart';
import 'screens/main_shell.dart';
import 'screens/result_screen.dart';
import 'services/data_loader.dart';
import 'services/preferences_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DoseGptApp());
}

class DoseGptApp extends StatelessWidget {
  const DoseGptApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DoseGPT',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const AppEntry(),
      onGenerateRoute: (settings) {
        if (settings.name == '/result') {
          final args = settings.arguments as Map<String, dynamic>;
          final screen = ResultScreen.fromArguments(args);
          if (screen != null) {
            return MaterialPageRoute(builder: (_) => screen);
          }
        }
        return null;
      },
    );
  }
}

/// Entry point widget that checks whether the disclaimer
/// has been seen and loads data before showing the app.
class AppEntry extends StatefulWidget {
  const AppEntry({super.key});

  @override
  State<AppEntry> createState() => _AppEntryState();
}

class _AppEntryState extends State<AppEntry> {
  late Future<ClinicalData> _dataFuture;
  late Future<bool> _disclaimerFuture;
  late Future<void> _imagePrecacheFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = DataLoader.load();
    _disclaimerFuture = PreferencesService.getHasSeenDisclaimer();
    _imagePrecacheFuture = _precacheAllImages();
  }

  /// Pre-load all asset images so they display instantly on the home screen.
  Future<void> _precacheAllImages() async {
    // Wait for the widget tree to be ready
    await WidgetsBinding.instance.endOfFrame;

    if (!mounted) return;

    // Precache the background image
    await precacheImage(
      const AssetImage('assets/images/background/baby_photo.jpg'),
      context,
      size: null,
    );

    if (!mounted) return;

    // Precache all condition card images
    const conditionIds = [
      'asthma', 'diarrhea', 'ear_infection', 'fever', 'malaria',
      'pneumonia', 'skin_infection', 'tonsillitis', 'uti', 'worms',
    ];
    await Future.wait(
      conditionIds.map((id) => precacheImage(
        AssetImage('assets/images/conditions/$id.jpg'),
        context,
        size: null,
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait([_dataFuture, _disclaimerFuture, _imagePrecacheFuture]),
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: AppTheme.surface,
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.medical_services_outlined,
                      color: AppTheme.primary,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                  const Text(
                    'DoseGPT',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.ink,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingSm),
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: AppTheme.surface,
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingLg),
                child: Text(
                  'Failed to load app data: ${snapshot.error}',
                  style: AppTheme.body,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        final data = snapshot.data![0] as ClinicalData;
        final hasSeenDisclaimer = snapshot.data![1] as bool;

        if (!hasSeenDisclaimer) {
          return DisclaimerScreen(
            onDismissed: () => MainShell(data: data),
          );
        }

        return MainShell(data: data);
      },
    );
  }
}
