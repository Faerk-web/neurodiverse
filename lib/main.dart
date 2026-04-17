import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'features/emotions/emotional_thermometer.dart';
import 'features/timeline/visual_timeline.dart';

enum UserRole { child, parentTeacher }
enum SupportMode { adhd, autism }

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // Allows local UI execution before Firebase options are configured.
  }
  runApp(const AnkerApp());
}

class AnkerApp extends StatefulWidget {
  const AnkerApp({super.key});

  @override
  State<AnkerApp> createState() => _AnkerAppState();
}

class _AnkerAppState extends State<AnkerApp> {
  UserRole _role = UserRole.child;
  SupportMode _mode = SupportMode.autism;

  @override
  Widget build(BuildContext context) {
    final isAdhdMode = _mode == SupportMode.adhd;

    return MaterialApp(
      title: 'Anker',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: isAdhdMode ? Colors.deepPurple : Colors.teal,
          brightness: Brightness.light,
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Anker'),
          actions: [
            _ModeToggle(
              mode: _mode,
              onChanged: (mode) => setState(() => _mode = mode),
            ),
            const SizedBox(width: 12),
          ],
        ),
        body: SafeArea(
          child: _role == UserRole.child
              ? ChildHomeScreen(mode: _mode)
              : ParentTeacherDashboard(mode: _mode),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _role == UserRole.child ? 0 : 1,
          onDestinationSelected: (index) {
            setState(() {
              _role = index == 0 ? UserRole.child : UserRole.parentTeacher;
            });
          },
          destinations: const [
            NavigationDestination(icon: Icon(Icons.child_care), label: 'Child'),
            NavigationDestination(icon: Icon(Icons.school), label: 'Parent/Teacher'),
          ],
        ),
      ),
    );
  }
}

class _ModeToggle extends StatelessWidget {
  const _ModeToggle({required this.mode, required this.onChanged});

  final SupportMode mode;
  final ValueChanged<SupportMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<SupportMode>(
      segments: const [
        ButtonSegment(
          value: SupportMode.adhd,
          label: Text('ADHD'),
          tooltip: 'ADHD support mode',
        ),
        ButtonSegment(
          value: SupportMode.autism,
          label: Text('Autism'),
          tooltip: 'Autism support mode',
        ),
      ],
      selected: {mode},
      onSelectionChanged: (selection) => onChanged(selection.first),
    );
  }
}

class ChildHomeScreen extends StatelessWidget {
  const ChildHomeScreen({super.key, required this.mode});

  final SupportMode mode;

  @override
  Widget build(BuildContext context) {
    final tasks = [
      VisualTimelineTask(
        title: 'Morning Circle',
        description: 'Sit with class and review the day.',
        svgAsset: null,
        duration: const Duration(minutes: 20),
      ),
      VisualTimelineTask(
        title: 'Math Mission',
        description: 'Solve 5 fun challenges.',
        svgAsset: null,
        duration: const Duration(minutes: 25),
      ),
      VisualTimelineTask(
        title: 'Break + Sensory',
        description: 'Headphones and breathing card.',
        svgAsset: null,
        duration: const Duration(minutes: 10),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            mode == SupportMode.adhd ? 'Mission Control Mode' : 'Calm Routine Mode',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          const EmotionalThermometer(),
          const SizedBox(height: 16),
          Expanded(
            child: VisualTimeline(
              tasks: tasks,
              activeTaskIndex: 0,
              dopamineBoosted: mode == SupportMode.adhd,
            ),
          ),
        ],
      ),
    );
  }
}

class ParentTeacherDashboard extends StatelessWidget {
  const ParentTeacherDashboard({super.key, required this.mode});

  final SupportMode mode;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Parent / Teacher Dashboard', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          Text(
            'Realtime schedule sync: Firebase Firestore + Cloud Functions\n'
            'Current mode profile: ${mode.name.toUpperCase()}',
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.edit_calendar),
            label: const Text('Push Schedule Change'),
          ),
          const SizedBox(height: 8),
          FilledButton.tonalIcon(
            onPressed: () {},
            icon: const Icon(Icons.vibration),
            label: const Text('Send Help-Button Haptic Alert'),
          ),
        ],
      ),
    );
  }
}
