// import 'package:cached_video_player_plus/cached_video_player_plus.dart';
// import 'package:flutter/material.dart';
// import 'package:myocircle15screens/services/api_service.dart';
// import 'package:myocircle15screens/services/applife_cycle_manager.dart';
// import 'package:provider/provider.dart';
// import 'package:scale_button/scale_button.dart';
// import 'package:video_player/video_player.dart'; // Keep this import
// import '../../components/components_path.dart';
// import '../../providers/avatar_provider.dart';
// import '../../providers/session_provider.dart';
//
// class AvatarPreviewScreen extends StatefulWidget {
//   final int index;
//   final List<dynamic> refVideos;
//
//   const AvatarPreviewScreen({super.key, required this.index, required this.refVideos});
//
//   @override
//   State<AvatarPreviewScreen> createState() => _AvatarPreviewScreenState();
// }
//
// class _AvatarPreviewScreenState extends State<AvatarPreviewScreen> {
//   late PageController _pageController;
//   int _verticalIndex = 0;
//   int _horizontalIndex = 0;
//   final Map<String, CachedVideoPlayerPlus> _videoPlayers = {}; // Changed type
//
//   final Map<String, String> _videoUrls = {};
//   int activityCounts = 0;
//   bool _isDisposed = false;
//
//   @override
//   void initState() {
//     super.initState();
//     ActivityMonitor.start();
//     activityCounts = ActivityMonitor.count;
//     _verticalIndex = widget.index;
//     _pageController = PageController(initialPage: _verticalIndex);
//     _fetchAllVideoUrlsSequentially();
//   }
//
//   Future<void> _fetchVideoUrl(int vIndex, int hIndex) async {
//     final key = '$vIndex-$hIndex';
//     if (_videoUrls.containsKey(key)) return;
//
//     try {
//       final idProvider = Provider.of<SessionProvider>(context, listen: false);
//       final id = widget.refVideos[vIndex][hIndex];
//       final response = await ApiService.getRefVideos(
//         idProvider.userData?['user_token']!,
//         id,
//         idProvider.userData?['profileId']!,
//         idProvider.userData?['userId']!,
//         context,
//       );
//       _videoUrls[key] = response['data']['url'];
//     } catch (e) {
//       debugPrint("Failed to get video URL for $key: $e");
//     }
//   }
//
//   Map<String, bool> _isPlaying = {};
//
//   Future<void> _fetchAllVideoUrlsSequentially() async {
//     final idProvider = Provider.of<SessionProvider>(context, listen: false);
//
//     for (int v = 0; v < widget.refVideos.length; v++) {
//       for (int h = 0; h < widget.refVideos[v].length; h++) {
//         final key = '$v-$h';
//         if (_videoUrls.containsKey(key)) continue;
//
//         try {
//           final id = widget.refVideos[v][h];
//           print("********************");
//           print(id);
//           print("********************");
//           final response = await ApiService.getRefVideos(
//             idProvider.userData?['user_token']!,
//             id,
//             idProvider.userData?['profileId']!,
//             idProvider.userData?['userId']!,
//             context,
//           );
//           _videoUrls[key] = response['data']['url'];
//         } catch (e) {
//           debugPrint("Failed to fetch video URL for $key: $e");
//         }
//       }
//     }
//     _loadOnlyCurrentVideo(_verticalIndex, 0);
//   }
//
//   Future<void> _loadController(int vIndex, int hIndex) async {
//     final key = '$vIndex-$hIndex';
//     if (_videoPlayers.containsKey(key)) return;
//
//     if (!_videoUrls.containsKey(key)) return;
//
//     final player = CachedVideoPlayerPlus.networkUrl(Uri.parse(_videoUrls[key]!)); // Changed constructor
//     await player.initialize();
//     player.controller.setLooping(true); // Access underlying controller
//     _isPlaying[key] = false;
//
//     if (!_isDisposed && mounted) {
//       _videoPlayers[key] = player;
//       setState(() {});
//     }
//   }
//
//   Future<void> _loadOnlyCurrentVideo(int vIndex, int hIndex) async {
//     if (_isDisposed) return;
//
//     if (vIndex >= widget.refVideos.length || hIndex >= widget.refVideos[vIndex].length) return;
//
//     // Load only the current video
//     await _loadController(vIndex, 0);
//     await _loadController(vIndex, 1);
//
//     // Play only the current video
//     _playOnlyCurrentVideo(vIndex, hIndex);
//
//     // Dispose of other controllers
//     _disposeFarControllers(vIndex, hIndex);
//
//     if (!_isDisposed && mounted) setState(() {});
//   }
//
//   void _playOnlyCurrentVideo(int vIndex, int hIndex) {
//     final currentKey = '$vIndex-$hIndex';
//     _videoPlayers.forEach((key, player) async {
//       if (key == currentKey && _isPlaying[currentKey] == true) {
//         await player.controller.play(); // Access underlying controller
//       } else {
//         await player.controller.pause(); // Access underlying controller
//       }
//     });
//   }
//
//   void _pauseOnlyCurrentVideo(int vIndex, int hIndex) {
//     final currentKey = '$vIndex-$hIndex';
//     _videoPlayers.forEach((key, player) async {
//       if (key == currentKey && _isPlaying[currentKey] == true) {
//         await player.controller.pause(); // Access underlying controller
//       }
//     });
//   }
//
//   bool isDisposing = false;
//   void _disposeFarControllers(int vIndex, int hIndex) {
//     if(isDisposing) return;
//     setState(() {
//       isDisposing = true;
//     });
//     final currentKey = '$vIndex-0';
//     final currentKey2 = '$vIndex-1';
//
//     final keysToRemove = _videoPlayers.keys.where((key) => (key != currentKey && key !=currentKey2)).toList();
//
//     for (final key in keysToRemove) {
//       if (_videoPlayers.containsKey(key))
//       {
//         try {
//           _videoPlayers[key]?.dispose();
//         } catch (_) {}
//         _videoPlayers.remove(key);
//         _isPlaying.remove(key);
//       }
//     }
//     setState(() {
//       isDisposing = false;
//     });
//   }
//
//   @override
//   void dispose() {
//     _isDisposed = true;
//     for (final player in _videoPlayers.values) {
//       try {
//         player.dispose();
//       } catch (_) {}
//     }
//
//     _videoPlayers.clear();
//     _pageController.dispose();
//     ActivityMonitor.setCount(activityCounts - 1);
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     print(isDisposing);
//     final screenWidth = MediaQuery.of(context).size.width;
//     return Stack(
//       alignment: Alignment.center,
//       children: [
//         PageView.builder(
//           scrollDirection: Axis.vertical,
//           controller: _pageController,
//           onPageChanged: (vIndex) {
//             if (_horizontalIndex != 0 || _verticalIndex != vIndex) {
//               // final prevKey = '$_verticalIndex-$_horizontalIndex';
//               // setState(() {
//               //   _isPlaying[prevKey] = false; // pause previous
//               // });
//               // _pauseOnlyCurrentVideo(_verticalIndex, _horizontalIndex);
//             }
//             if (_isDisposed) return;
//             setState(() {
//               _verticalIndex = vIndex;
//               _horizontalIndex = 0;
//             });
//             _loadOnlyCurrentVideo(vIndex, 0);
//           },
//           itemCount: widget.refVideos.length,
//           itemBuilder: (context, vIndex) {
//             return PageView.builder(
//               onPageChanged: (hIndex) {
//                 if (_horizontalIndex != hIndex || _verticalIndex != vIndex) {
//                   // final prevKey = '$_verticalIndex-$_horizontalIndex';
//                   // setState(() {
//                   //   _isPlaying[prevKey] = false; // pause previous
//                   // });
//                   // _pauseOnlyCurrentVideo(_verticalIndex, _horizontalIndex);
//
//                 }
//                 if (_isDisposed) return;
//                 setState(() => _horizontalIndex = hIndex);
//                 _loadOnlyCurrentVideo(vIndex, hIndex);
//               },
//               itemCount: widget.refVideos[vIndex].length,
//               itemBuilder: (context, hIndex) {
//                 final key = '$vIndex-$hIndex';
//                 final player = _videoPlayers[key];
//                 if (player != null && player.isInitialized) { // Use player.isInitialized
//                   return Stack(
//                     alignment: Alignment.center,
//                     children: [
//                       Positioned(
//                         top: 0,
//                         bottom: 0,
//                         left: 0,
//                         right: 0,
//                         child: VideoPlayer(player.controller) // Use VideoPlayer widget
//                       ),
//                       if (!_isPlaying[key]!)
//                         IconButton(
//                           iconSize: 64,
//                           icon: Icon(Icons.play_circle_fill, color: Colors.white),
//                           onPressed: () {
//                             setState(() {
//                               _isPlaying[key] = true;
//                             });
//                             _playOnlyCurrentVideo(vIndex, hIndex);
//                           },
//                         ),
//                     ],
//                   );
//                 }
//                 else {
//                   return const Center(child: CircularProgressIndicator(color: Colors.white));
//                 }
//               },
//             );
//           },
//         ),
//
//         // Vertical dots
//         Positioned(
//           right: 10,
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: List.generate(
//               widget.refVideos.length,
//                   (index) => Image.asset(
//                 _verticalIndex == index ? DOT_COLORED : DOT_WHITE,
//                 height: 30,
//               ),
//             ),
//           ),
//         ),
//
//         // Horizontal dots
//         Positioned(
//           bottom: 120,
//           child: Row(
//             children: List.generate(
//               widget.refVideos[_verticalIndex].length,
//                   (index) => Image.asset(
//                 _horizontalIndex == index ? DOT_COLORED : DOT_WHITE,
//                 height: 30,
//               ),
//             ),
//           ),
//         ),
//
//         // Select Button
//         Positioned(
//           bottom: 0,
//           child: Padding(
//             padding: EdgeInsets.only(left: screenWidth / 17),
//             child: SizedBox(
//               height: 120,
//               child: ScaleButton(
//                 onTap: () {
//                   if (_isDisposed) return;
//                   Provider.of<AvatarProvider>(context, listen: false).setAvatar(_verticalIndex);
//                   Navigator.pop(context);
//                 },
//                 child: Image.asset(SELECT_BTN, fit: BoxFit.contain),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
///
///



import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart' as mkv;
import 'package:provider/provider.dart';
import 'package:scale_button/scale_button.dart';

import 'package:myocircle15screens/services/applife_cycle_manager.dart';

import '../../components/components_path.dart';
import '../../providers/avatar_provider.dart';

class AvatarPreviewScreen extends StatefulWidget {
  final int index;
  final List<dynamic> refVideos;

  const AvatarPreviewScreen({
    super.key,
    required this.index,
    required this.refVideos,
  });

  @override
  State<AvatarPreviewScreen> createState() =>
      _AvatarPreviewScreenState();
}

class _AvatarPreviewScreenState extends State<AvatarPreviewScreen> {
  late PageController _pageController;
  final Map<int, PageController> _horizontalControllers = {};
  PageController _getHorizontalController(int vIndex) {
    if (!_horizontalControllers.containsKey(vIndex)) {
      _horizontalControllers[vIndex] = PageController();
    }
    return _horizontalControllers[vIndex]!;
  }

  int _verticalIndex = 0;
  int _horizontalIndex = 0;

  final Map<String, Player> _players = {};
  final Map<String, mkv.VideoController> _controllers = {};
  final Map<String, bool> _isPlaying = {};

  int activityCounts = 0;
  bool _isDisposed = false;
  bool isDisposing = false;

  @override
  void initState() {
    super.initState();

    MediaKit.ensureInitialized();

    ActivityMonitor.start();
    activityCounts = ActivityMonitor.count;

    _verticalIndex = widget.index;
    _pageController = PageController(initialPage: _verticalIndex);

    _loadOnlyCurrentVideo(_verticalIndex, 0);
  }

  // ================= PLAYER =================

  Future<void> _loadController(int vIndex, int hIndex) async {
    final key = '$vIndex-$hIndex';

    if (_players.containsKey(key)) return;

    final id = widget.refVideos[vIndex][hIndex];

    final url =
        "https://api.myocircle.com/api/api/auth/stream?videoId=$id&type=skillVideos&playName=master.m3u8";

    final player = Player();
    final controller = mkv.VideoController(player);

    player.setPlaylistMode(PlaylistMode.none);

    /// 🔥 IMPORTANT SETTINGS
    player.setVolume(100);

    /// ❌ No autoplay initially
    player.open(Media(url), play: false);

    bool initialized = false;

    player.stream.duration.listen((duration) async {
      if (duration > Duration.zero && !initialized) {
        initialized = true;

        /// ✅ Force start from 0
        await player.pause();
        await player.seek(Duration.zero);

        /// 🔥 EXTRA BUFFER TIME (important fix)
        await Future.delayed(const Duration(milliseconds: 300));

        /// ✅ ONLY PLAY CURRENT VIDEO
        final currentKey = '$_verticalIndex-$_horizontalIndex';

        if (key == currentKey) {
          await player.play();
          _isPlaying[key] = true;
        } else {
          await player.pause(); // 🔥 IMPORTANT
          _isPlaying[key] = false;
        }

        _isPlaying[key] = true;

        if (!_isDisposed && mounted) {
          setState(() {});
        }
      }
    });



    _players[key] = player;
    _controllers[key] = controller;
  }

  Future<void> _loadOnlyCurrentVideo(int vIndex, int hIndex) async {
    if (_isDisposed) return;

    /// ✅ Load current video
    await _loadController(vIndex, hIndex);

    /// ✅ Preload NEXT video (important for smoothness)
    if (hIndex + 1 < widget.refVideos[vIndex].length) {
      await _loadController(vIndex, hIndex + 1);
    }

    /// (optional) preload previous for back scroll smooth
    if (hIndex - 1 >= 0) {
      await _loadController(vIndex, hIndex - 1);
    }

    _playOnlyCurrentVideo(vIndex, hIndex);

    /// ✅ Dispose others (keep only 3 max)
    _disposeFarControllers(vIndex, hIndex);

    if (!_isDisposed && mounted) setState(() {});
  }

  void _playOnlyCurrentVideo(int vIndex, int hIndex) {
    final currentKey = '$vIndex-$hIndex';

    _players.forEach((key, player) async {
      if (key == currentKey) {
        await player.play();
        _isPlaying[key] = true;
      } else {
        await player.pause();
        _isPlaying[key] = false;
      }
    });
  }

  void _disposeFarControllers(int vIndex, int hIndex) {
    if (isDisposing) return;

    setState(() => isDisposing = true);

    final keepKeys = [
      '$vIndex-$hIndex',
      '$vIndex-${hIndex + 1}',
      '$vIndex-${hIndex - 1}',
    ];

    final keysToRemove =
    _players.keys.where((key) => !keepKeys.contains(key)).toList();

    for (final key in keysToRemove) {
      try {
        _players[key]?.dispose();
      } catch (_) {}

      _players.remove(key);
      _controllers.remove(key);
      _isPlaying.remove(key);
    }

    setState(() => isDisposing = false);
  }

  @override
  void dispose() {
    _isDisposed = true;

    for (final player in _players.values) {
      try {
        player.dispose();
      } catch (_) {}
    }

    _players.clear();
    _controllers.clear();

    _pageController.dispose();
    for (final controller in _horizontalControllers.values) {
      controller.dispose();
    }
    _horizontalControllers.clear();

    ActivityMonitor.setCount(activityCounts - 1);

    super.dispose();
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Stack(
      alignment: Alignment.center,
      children: [
        /// 🔥 VERTICAL SCROLL
        PageView.builder(
          scrollDirection: Axis.vertical,
          controller: _pageController,
          physics: const BouncingScrollPhysics(),
          onPageChanged: (vIndex) {
            if (_isDisposed) return;

            setState(() {
              _verticalIndex = vIndex;
              _horizontalIndex = 0;
            });

            _getHorizontalController(vIndex).jumpToPage(0);

            /// 🔥 Load only needed videos
            _loadOnlyCurrentVideo(vIndex, 0);
          },
          itemCount: widget.refVideos.length,
          itemBuilder: (context, vIndex) {
            return PageView.builder(
              controller: _getHorizontalController(vIndex),
              physics: const BouncingScrollPhysics(),
              onPageChanged: (hIndex) {
                if (_isDisposed) return;

                setState(() => _horizontalIndex = hIndex);

                /// 🔥 Load smart
                _loadOnlyCurrentVideo(vIndex, hIndex);
              },
              itemCount: widget.refVideos[vIndex].length,
              itemBuilder: (context, hIndex) {
                final key = '$vIndex-$hIndex';
                final controller = _controllers[key];

                if (controller != null) {
                  return SizedBox.expand(
                    child: mkv.Video(
                      controller: controller,
                      fit: BoxFit.cover,
                    ),
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }
              },
            );
          },
        ),

        /// 🔥 VERTICAL DOTS (CLICKABLE)
        Positioned(
          right: 10,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.refVideos.length,
                  (index) => GestureDetector(
                onTap: () {
                  _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Image.asset(
                    _verticalIndex == index ? DOT_COLORED : DOT_WHITE,
                    height: 30,
                  ),
                ),
              ),
            ),
          ),
        ),

        /// 🔥 HORIZONTAL DOTS (CLICKABLE)
        Positioned(
          bottom: 120,
          child: Row(
            children: List.generate(
              widget.refVideos[_verticalIndex].length,
                  (index) => GestureDetector(
                onTap: () {
                  _getHorizontalController(_verticalIndex).animateToPage(
                    index,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Image.asset(
                    _horizontalIndex == index ? DOT_COLORED : DOT_WHITE,
                    height: 30,
                  ),
                ),
              ),
            ),
          ),
        ),

        /// 🔥 SELECT BUTTON
        Positioned(
          bottom: 0,
          child: Padding(
            padding: EdgeInsets.only(left: screenWidth / 17),
            child: SizedBox(
              height: 120,
              child: ScaleButton(
                onTap: () {
                  if (_isDisposed) return;

                  Provider.of<AvatarProvider>(context, listen: false)
                      .setAvatar(_verticalIndex);

                  Navigator.pop(context);
                },
                child: Image.asset(SELECT_BTN, fit: BoxFit.contain),
              ),
            ),
          ),
        ),
      ],
    );
  }
}