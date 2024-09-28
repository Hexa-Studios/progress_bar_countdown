import 'package:flutter/material.dart';
import 'package:progress_bar_countdown/progress_bar_countdown.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Progress Bar Countdown',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Example Progress Bar Countdown'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ProgressBarCountdownController controller =
      ProgressBarCountdownController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          ProgressBarCountdown(
            initialDuration: const Duration(seconds: 20),
            height: 150,
            controller: controller,
            hideText: false,
            autoStart: false,
            progressColor: Colors.deepPurple,
            progressBackgroundColor: Colors.deepPurple.shade200,
            initialTextColor: Colors.deepPurple.shade100,
            revealedTextColor: Colors.white,
            countdownDirection: ProgressBarCountdownAlignment.right,
            textStyle:
                const TextStyle(fontSize: 48.0, fontWeight: FontWeight.w800),
            onStart: () => {debugPrint("Countdown Started")},
            onComplete: () => {debugPrint("Countdown Completed")},
            onChange: (changeValue) => debugPrint("Change Value: $changeValue"),
            timeFormatter: (Duration remainingTime) {
              final minutes = remainingTime.inMinutes
                  .remainder(60)
                  .toString()
                  .padLeft(2, '0');
              final seconds = remainingTime.inSeconds
                  .remainder(60)
                  .toString()
                  .padLeft(2, '0');
              final milliseconds = (remainingTime.inMilliseconds % 1000 ~/ 10)
                  .toString()
                  .padLeft(2, '0');
              return '$minutes:$seconds:$milliseconds';
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  IconButton(
                    onPressed: () => controller.start(),
                    icon: const Icon(
                      Icons.play_arrow_outlined,
                    ),
                  ),
                  const Text("Start")
                ],
              ),
              const SizedBox(width: 10),
              Column(
                children: [
                  IconButton(
                    onPressed: () => controller.pause(),
                    icon: const Icon(Icons.pause_circle),
                  ),
                  const Text("Pause")
                ],
              ),
              const SizedBox(width: 10),
              Column(
                children: [
                  IconButton(
                    onPressed: () => controller.resume(),
                    icon: const Icon(Icons.play_circle_fill),
                  ),
                  const Text("Resume")
                ],
              ),
              const SizedBox(width: 10),
              Column(
                children: [
                  IconButton(
                    onPressed: () =>
                        controller.reset(duration: const Duration(seconds: 10)),
                    icon: const Icon(Icons.restore_outlined),
                  ),
                  const Text("Reset")
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
