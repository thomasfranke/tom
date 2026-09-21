/// Frame timings, collected while the spike does something worth timing.
library;

import 'package:flutter/scheduler.dart';

/// What a run of frames cost.
///
/// Build and raster are kept apart because they fail differently: a slow
/// build is our widget tree, a slow raster is the GPU work the editor asked
/// for. An editor that is slow on one is a different problem from an editor
/// that is slow on the other.
class FrameStats {
  /// Creates a summary.
  const FrameStats({
    required this.frames,
    required this.buildP50,
    required this.buildP95,
    required this.buildMax,
    required this.rasterP50,
    required this.rasterP95,
    required this.rasterMax,
    required this.janky,
    required this.budget,
  });

  /// How many frames were measured.
  final int frames;

  /// Median time spent building.
  final Duration buildP50;

  /// The 95th percentile of build time.
  final Duration buildP95;

  /// The worst build.
  final Duration buildMax;

  /// Median time spent rasterising.
  final Duration rasterP50;

  /// The 95th percentile of raster time.
  final Duration rasterP95;

  /// The worst raster.
  final Duration rasterMax;

  /// Frames whose build plus raster ran past [budget].
  ///
  /// The number that decides the spike. A p50 well inside the budget with
  /// one frame in twenty missing it is an editor that stutters while
  /// someone types, and typing is the whole job.
  final int janky;

  /// The frame budget of the display this ran on.
  final Duration budget;

  /// [janky] as a share of [frames].
  double get jankRatio => frames == 0 ? 0 : janky / frames;

  @override
  String toString() =>
      'frames $frames · build p50 ${_ms(buildP50)} p95 ${_ms(buildP95)} '
      'max ${_ms(buildMax)} · raster p50 ${_ms(rasterP50)} '
      'p95 ${_ms(rasterP95)} max ${_ms(rasterMax)} · '
      'over ${_ms(budget)}: $janky (${(jankRatio * 100).toStringAsFixed(1)}%)';

  static String _ms(Duration duration) =>
      '${(duration.inMicroseconds / 1000).toStringAsFixed(1)}ms';
}

/// Collects [FrameTiming]s between [start] and [stop].
///
/// A callback on the scheduler rather than a stopwatch around the code: what
/// a user feels is the frame that missed its budget, and only the engine
/// knows when that happened.
class FrameRecorder {
  /// Creates a recorder for a display with the given [budget].
  ///
  /// The default is one 60Hz frame. A display that refreshes faster has a
  /// smaller budget, and the harness passes the real one.
  FrameRecorder({this.budget = const Duration(microseconds: 16667)});

  /// The frame budget to count misses against.
  final Duration budget;

  final List<FrameTiming> _timings = <FrameTiming>[];
  bool _recording = false;

  /// Whether frames are being collected right now.
  bool get isRecording => _recording;

  /// Starts collecting, discarding anything collected before.
  void start() {
    _timings.clear();
    if (!_recording) {
      _recording = true;
      SchedulerBinding.instance.addTimingsCallback(_onTimings);
    }
  }

  /// Stops collecting and summarises what was collected.
  FrameStats stop() {
    if (_recording) {
      SchedulerBinding.instance.removeTimingsCallback(_onTimings);
      _recording = false;
    }
    return _summarise();
  }

  void _onTimings(List<FrameTiming> timings) => _timings.addAll(timings);

  FrameStats _summarise() {
    final List<Duration> builds =
        _timings.map((FrameTiming timing) => timing.buildDuration).toList()
          ..sort();
    final List<Duration> rasters =
        _timings.map((FrameTiming timing) => timing.rasterDuration).toList()
          ..sort();
    final int janky = _timings
        .where(
          (FrameTiming timing) =>
              timing.buildDuration + timing.rasterDuration > budget,
        )
        .length;
    return FrameStats(
      frames: _timings.length,
      buildP50: _percentile(builds, 0.50),
      buildP95: _percentile(builds, 0.95),
      buildMax: builds.isEmpty ? Duration.zero : builds.last,
      rasterP50: _percentile(rasters, 0.50),
      rasterP95: _percentile(rasters, 0.95),
      rasterMax: rasters.isEmpty ? Duration.zero : rasters.last,
      janky: janky,
      budget: budget,
    );
  }

  static Duration _percentile(List<Duration> sorted, double fraction) {
    if (sorted.isEmpty) {
      return Duration.zero;
    }
    final int index = ((sorted.length - 1) * fraction).round();
    return sorted[index];
  }
}
