import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:video_player/video_player.dart'; // Add this import
import 'package:flutter/material.dart';
import 'package:myocircle15screens/services/applife_cycle_manager.dart';
import '../../components/components_path.dart';

class PatientAvatarPreviewScreen extends StatefulWidget {
  final int index;
  final List<dynamic> refVideos;

  const PatientAvatarPreviewScreen(
      {super.key, required this.index, required this.refVideos});

  @override
  State<PatientAvatarPreviewScreen> createState() =>
      _PatientAvatarPreviewScreenState();
}

class _PatientAvatarPreviewScreenState
    extends State<PatientAvatarPreviewScreen> {
  late PageController _pageController;
  int _verticalIndex = 0;
  final Map<String, CachedVideoPlayerPlus> _videoPlayers = {}; // Changed type

  int activityCounts = 0;
  bool _isDisposed = false;

  Map<String, bool> _isPlaying = {}; // will now be true initially

  @override
  void initState() {
    super.initState();
    ActivityMonitor.start();
    activityCounts = ActivityMonitor.count;
    _verticalIndex = widget.index;
    _pageController = PageController(initialPage: _verticalIndex);
    _loadOnlyCurrentVideo(_verticalIndex);

  }

  Future<void> _loadController(int vIndex) async {
    final key = '$vIndex';
    if (_videoPlayers.containsKey(key)) return;

    final player = CachedVideoPlayerPlus.networkUrl(// Changed constructor
        Uri.parse(widget.refVideos[vIndex]!));
    await player.initialize();
    player.controller.setLooping(true); // Access underlying controller
print("*******");
print(widget.refVideos[vIndex]!);
print("*******");
    // NEW: video should start playing by default
    _isPlaying[key] = true;

    if (!_isDisposed && mounted) {
      _videoPlayers[key] = player;
      setState(() {});
    }
  }

  Future<void> _loadOnlyCurrentVideo(int vIndex) async {
    if (_isDisposed) return;
    if (vIndex >= widget.refVideos.length) return;

    await _loadController(vIndex);
    _playOnlyCurrentVideo(vIndex);
    _disposeFarControllers(vIndex);

    if (!_isDisposed && mounted) setState(() {});
  }

  void _playOnlyCurrentVideo(int vIndex) {
    final currentKey = '$vIndex';

    _videoPlayers.forEach((key, player) async {
      if (key == currentKey && _isPlaying[currentKey] == true) {
        await player.controller.play(); // Access underlying controller
      } else {
        await player.controller.pause(); // Access underlying controller
      }
    });
  }

  void _disposeFarControllers(int vIndex) {
    final currentKey = '$vIndex';

    final keysToRemove =
        _videoPlayers.keys.where((key) => key != currentKey).toList();

    for (final key in keysToRemove) {
      try {
        _videoPlayers[key]?.dispose();
      } catch (_) {}
      _videoPlayers.remove(key);
      _isPlaying.remove(key);
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    for (final player in _videoPlayers.values) {
      try {
        player.dispose();
      } catch (_) {}
    }

    _videoPlayers.clear();
    _pageController.dispose();
    ActivityMonitor.setCount(activityCounts - 1);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(widget.refVideos);

    return Stack(
      alignment: Alignment.center,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,

          // NEW: Tap anywhere -> pause + show play button
          onTap: () {
            final key = '$_verticalIndex';
            if (_isPlaying[key] == true) {
              setState(() {
                _isPlaying[key] = false;
              });
              _playOnlyCurrentVideo(_verticalIndex);
            }
          },

          child: PageView.builder(
            scrollDirection: Axis.vertical,
            controller: _pageController,
            onPageChanged: (vIndex) {
              if (_verticalIndex != vIndex) {
                final prevKey = '$_verticalIndex';
                _isPlaying[prevKey] = false;
              }
              if (_isDisposed) return;
              setState(() {
                _verticalIndex = vIndex;
              });
              _loadOnlyCurrentVideo(vIndex);
            },
            itemCount: widget.refVideos.length,
            itemBuilder: (context, vIndex) {
              return _videoPlayers["$vIndex"] == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Colors.white),
                      ],
                    )
                  : Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned(
                          top: 0,
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: VideoPlayer(
                            // Changed widget
                            _videoPlayers["$vIndex"]!
                                .controller, // Access controller
                          ),
                        ),

                        // PLAY BUTTON (visible only when paused)
                        if (!_isPlaying["$vIndex"]!)
                          IconButton(
                            iconSize: 64,
                            icon: Icon(Icons.play_circle_fill,
                                color: Colors.white),
                            onPressed: () {
                              setState(() {
                                _isPlaying["$vIndex"] = true;
                              });
                              _playOnlyCurrentVideo(vIndex);
                            },
                          ),
                      ],
                    );
            },
          ),
        ),

        // Vertical dots
        Positioned(
          right: 10,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.refVideos.length,
              (index) => Image.asset(
                _verticalIndex == index ? DOT_COLORED : DOT_WHITE,
                height: 30,
              ),
            ),
          ),
        ),

        Positioned(
          top: 20,
          right: 10,
          height: 50,
          width: 50,
          child: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Image.asset(EXERCISE_CLOSE2),
          ),
        ),
      ],
    );
  }
}
