library progress_bar_countdown;

import 'dart:async';

import 'package:flutter/material.dart';

/// Enum for the alignment of countdown
enum ProgressBarCountdownAlignment { left, right }

/// Controls (i.e Start, Pause, Resume, Restart) the Progress Countdown Timer.
class ProgressBarCountdownController {
  _ProgressBarCountdownState? _state;
  ValueNotifier<bool> isStarted = ValueNotifier<bool>(false);
  ValueNotifier<bool> isPaused = ValueNotifier<bool>(false);
  ValueNotifier<bool> isResumed = ValueNotifier<bool>(false);
  ValueNotifier<bool> isReset = ValueNotifier<bool>(false);

  /// This Method Starts the Progress Countdown Timer
  void start() {
    if (_state != null) {
      _state!._startTimer();
      isStarted.value = true;
      isPaused.value = false;
      isResumed.value = false;
      isReset.value = false;
    }
  }

  /// This Method Pauses the Progress Countdown Timer
  void pause() {
    if (_state != null) {
      _state!._pauseTimer();
      isPaused.value = true;
      isResumed.value = false;
    }
  }

  /// This Method Resumes the Progress Countdown Timer
  void resume() {
    if (_state != null) {
      _state!._resumeTimer();
      isResumed.value = true;
      isPaused.value = false;
    }
  }

  /// This Method Restarts the Progress Countdown Timer
  void reset({Duration? duration}) {
    if (_state != null) {
      _state!._resetTimer(duration: duration);
      isStarted.value = false;
      isReset.value = true;
      isPaused.value = false;
      isResumed.value = false;
    }
  }

  /// This Method returns the Current Time of Progress Countdown Timer
  String getTime() {
    if (_state != null) {
      return _state!._remainingDuration.inMilliseconds
          .toStringAsFixed(_state!._remainingDuration.inSeconds > 1 ? 0 : 1);
    }
    return "";
  }
}

/// Create a Progress Countdown Timer.
class ProgressBarCountdown extends StatefulWidget {
  /// Countdown Duration in Seconds.
  final Duration initialDuration;

  /// Progress Color for Countdown Widget
  final Color progressColor;

  /// Background for Countdown Widget
  final Color progressBackgroundColor;

  /// Text Color for the Progress Bar
  final Color? initialTextColor;

  /// Text Color for 'Behind' the Progress Bar
  final Color? revealedTextColor;

  /// Boolean to Show / Hide the Text
  final bool hideText;

  /// Height of the Progress Bar
  final double height;

  /// Text Style of the Countdown
  final TextStyle textStyle;

  /// Direction of the Progress Countdown
  final ProgressBarCountdownAlignment countdownDirection;

  /// Controls (i.e Start, Pause, Resume, Restart) the Progress Countdown Timer.
  final ProgressBarCountdownController? controller;

  /// Handles the timer start.
  final bool autoStart;

  /// This Callback will execute when the Countdown Ends.
  final VoidCallback? onComplete;

  /// This Callback will execute when the Countdown Starts.
  final VoidCallback? onStart;

  /// This Callback will execute when the Countdown Changes.
  final ValueChanged<String>? onChange;

  /// This function can be used to override the default time formatter.
  final String Function(Duration remainingTime)? timeFormatter;

  const ProgressBarCountdown(
      {super.key,
      required this.initialDuration,
      required this.progressColor,
      this.progressBackgroundColor = Colors.white,
      this.initialTextColor,
      this.revealedTextColor,
      this.hideText = false,
      this.textStyle = const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      this.height = 50.0,
      this.countdownDirection = ProgressBarCountdownAlignment.left,
      this.controller,
      this.autoStart = false,
      this.onComplete,
      this.onStart,
      this.onChange,
      this.timeFormatter});

  @override
  _ProgressBarCountdownState createState() => _ProgressBarCountdownState();
}

class _ProgressBarCountdownState extends State<ProgressBarCountdown>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  Timer? _timer;
  Duration _remainingDuration = const Duration(seconds: 0);
  Duration _currentDuration = const Duration(seconds: 0);
  bool _isRunning = false;
  ProgressBarCountdownController? _countdownController;

  @override
  void initState() {
    super.initState();
    _currentDuration = widget.initialDuration;
    _remainingDuration = _currentDuration;
    _controller = AnimationController(
      vsync: this,
      duration:
          Duration(milliseconds: (_currentDuration.inMilliseconds).round()),
    );
    _animation = Tween<double>(begin: 1, end: 0).animate(_controller);

    _setController();

    if (widget.autoStart) {
      _startTimer();
    }
  }

  void _setController() {
    _countdownController =
        widget.controller ?? ProgressBarCountdownController();
    _countdownController!._state = this;
  }

  void _resetTimer({Duration? duration}) {
    _controller.stop();
    if (_timer != null && _timer!.isActive) {
      _timer!.cancel();
    }
    setState(() {
      _currentDuration = duration ?? widget.initialDuration;
      _remainingDuration = _currentDuration;
      _isRunning = false;
    });
    _controller.duration =
        Duration(milliseconds: (_currentDuration.inMilliseconds).round());
    _controller.reset();
  }

  String defaultTimeFormatter(Duration duration) {
    if (duration.inSeconds >= 1) {
      return duration.inSeconds.toString();
    } else {
      // Display milliseconds with 3 decimal places when less than 1 second
      return (duration.inMilliseconds / 1000).toStringAsFixed(3);
    }
  }

  String _formatTime(Duration duration) {
    if (widget.timeFormatter != null) {
      return widget.timeFormatter!(duration);
    } else {
      return defaultTimeFormatter(duration);
    }
  }

  void _startTimer() {
    if (_isRunning) return;
    widget.onStart?.call();
    _controller.forward(
        from: 1 -
            (_remainingDuration.inMilliseconds /
                _currentDuration.inMilliseconds));
    _isRunning = true;
    _timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      setState(() {
        _remainingDuration = _currentDuration * (1 - _controller.value);
        widget.onChange?.call(_formatTime(_remainingDuration)
            // _remainingDuration.inSeconds
            // .toStringAsFixed(_remainingDuration.inSeconds > 1 ? 0 : 1)
            );
        if (_remainingDuration.inMilliseconds <= 0) {
          _isRunning = false;
          timer.cancel();
          widget.onComplete?.call();
        }
      });
    });
  }

  void _pauseTimer() {
    if (_isRunning) {
      _controller.stop();
      _timer?.cancel();
      setState(() {
        _isRunning = false;
      });
    }
  }

  void _resumeTimer() {
    if (!_isRunning) {
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Alignment boxAlignment;
    switch (widget.countdownDirection) {
      case ProgressBarCountdownAlignment.left:
        boxAlignment = Alignment.centerLeft;
        break;
      case ProgressBarCountdownAlignment.right:
        boxAlignment = Alignment.centerRight;
        break;
    }

    return Stack(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          height: widget.height,
          color: widget.progressBackgroundColor,
        ),
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Align(
              alignment: boxAlignment,
              child: Container(
                height: widget.height,
                width: MediaQuery.of(context).size.width * _animation.value,
                color: widget.progressColor,
              ),
            );
          },
        ),
        widget.hideText
            ? const SizedBox.shrink()
            : AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return ShaderMask(
                    shaderCallback: (Rect bounds) {
                      switch (widget.countdownDirection) {
                        case ProgressBarCountdownAlignment.right:
                          return LinearGradient(
                            colors: [
                              widget.revealedTextColor ?? widget.progressColor,
                              widget.initialTextColor ?? Colors.white,
                            ],
                            stops: [
                              (1 - _animation.value),
                              (1 - _animation.value)
                            ],
                          ).createShader(bounds);
                        default:
                          return LinearGradient(
                            colors: [
                              widget.initialTextColor ?? Colors.white,
                              widget.revealedTextColor ?? widget.progressColor,
                            ],
                            stops: [_animation.value, _animation.value],
                          ).createShader(bounds);
                      }
                    },
                    child: SizedBox(
                      height: widget.height,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              _formatTime(_remainingDuration),
                              // _remainingDuration.inSeconds.toStringAsFixed(
                              //     _remainingDuration.inSeconds > 1 ? 0 : 1),
                              style: widget.textStyle
                                  .copyWith(color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ],
    );
  }
}
