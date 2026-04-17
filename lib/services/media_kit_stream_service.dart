// import 'package:flutter/material.dart';
// import 'package:media_kit/media_kit.dart';
// import 'package:media_kit_video/media_kit_video.dart' as mkv;
//
// class MediaKitStreamService {
//   MediaKitStreamService._();
//
//   static Future<void> play({
//     required BuildContext context,
//     required String url,
//     bool loop = false,
//     VoidCallback? onCompleted,
//   }) async {
//     debugPrint("🎬 PLAYING VIDEO URL => $url");
//
//     final player = Player();
//     final controller = mkv.VideoController(player);
//
//     await player.open(Media(url), play: true);
//
//     if (loop) {
//       player.setPlaylistMode(PlaylistMode.loop);
//     }
//
//     if (!loop && onCompleted != null) {
//       player.stream.completed.listen((done) {
//         if (done) {
//           onCompleted();
//         }
//       });
//     }
//
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) => WillPopScope(
//         onWillPop: () async {
//           player.dispose();
//           return true;
//         },
//         child: Dialog(
//           insetPadding: const EdgeInsets.all(10),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Column(
//             children: [
//               Expanded(
//                 child: mkv.Video(
//                   controller: controller,
//                   controls: mkv.AdaptiveVideoControls,
//                 ),
//               ),
//               ElevatedButton(
//                 onPressed: () {
//                   player.dispose();
//                   Navigator.pop(context);
//                 },
//                 child: const Text("Close"),
//               ),
//             ],
//           ),
//         ),
//       ),
//     ).then((_) => player.dispose());
//   }
// }
//
//
//
// ///
//
//
//
//
// class GemVideoPlayerScreen extends StatefulWidget {
//   final int abilityId;
//
//   const GemVideoPlayerScreen({super.key, required this.abilityId});
//
//   @override
//   State<GemVideoPlayerScreen> createState() =>
//       _GemVideoPlayerScreenState();
// }
//
// class _GemVideoPlayerScreenState extends State<GemVideoPlayerScreen> {
//   late final Player _player;
//   late final mkv.VideoController _controller;
//
//   bool isInitialized = false;
//   bool isBuffering = true;
//
//   @override
//   void initState() {
//     super.initState();
//
//     MediaKit.ensureInitialized();
//
//     _player = Player();
//     _controller = mkv.VideoController(_player);
//
//     final url =
//         "https://api.myocircle.com/api/api/auth/stream?videoId=${widget.abilityId}&type=skillVideos&playName=master.m3u8";
//
//     _player.setPlaylistMode(PlaylistMode.none);
//
//     /// ❌ Don't autoplay
//     _player.open(
//       Media(url),
//       play: false,
//     );
//
//     /// 🔥 BEST: Wait for duration (video ready)
//     _player.stream.duration.listen((duration) async {
//       if (duration > Duration.zero && !isInitialized) {
//         isInitialized = true;
//
//         setState(() => isBuffering = false);
//
//         /// ✅ Force reset BEFORE play
//         await _player.pause();
//         await _player.seek(Duration.zero);
//
//         /// Small delay ensures seek is applied
//         await Future.delayed(const Duration(milliseconds: 200));
//
//         await _player.play();
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     _player.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Stack(
//         children: [
//           Positioned.fill(
//             child: mkv.Video(
//               controller: _controller,
//               fit: BoxFit.cover,
//             ),
//           ),
//
//           /// ✅ Loader
//           if (isBuffering)
//             const Center(
//               child: CircularProgressIndicator(color: Colors.white),
//             ),
//
//           /// ❌ Close Button
//           Positioned(
//             top: 40,
//             right: 20,
//             child: GestureDetector(
//               onTap: () => Navigator.pop(context),
//               child: Container(
//                 decoration: const BoxDecoration(
//                   color: Colors.black54,
//                   shape: BoxShape.circle,
//                 ),
//                 padding: const EdgeInsets.all(8),
//                 child: const Icon(
//                   Icons.close,
//                   color: Colors.white,
//                   size: 28,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
///
///
///
///



import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:better_player_enhanced/better_player.dart';

class GemVideoPlayerScreen extends StatefulWidget {
  final int abilityId;

  const GemVideoPlayerScreen({super.key, required this.abilityId});

  @override
  State<GemVideoPlayerScreen> createState() =>
      _GemVideoPlayerScreenState();
}

class _GemVideoPlayerScreenState extends State<GemVideoPlayerScreen> {
  BetterPlayerController? _controller;
  bool isBuffering = true;

  @override
  void initState() {
    super.initState();

    /// 🔥 Fullscreen immersive mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    final url =
        "https://api.myocircle.com/api/api/auth/stream?videoId=${widget.abilityId}&type=skillVideos&playName=master.m3u8";
    print(url);

    final dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      url,
      videoFormat: BetterPlayerVideoFormat.hls,
    );

    _controller = BetterPlayerController(
      BetterPlayerConfiguration(
        autoPlay: false,

        fit: BoxFit.contain,
        expandToFill: false,

        /// ❌ Hide all controls
        controlsConfiguration: const BetterPlayerControlsConfiguration(
          showControls: false,
        ),
      ),
      betterPlayerDataSource: dataSource,
    );

    /// ✅ Wait until video is ready
    _controller!.addEventsListener((event) async {
      if (event.betterPlayerEventType ==
          BetterPlayerEventType.initialized) {
        setState(() => isBuffering = false);

        await _controller!.pause();
        await _controller!.seekTo(Duration.zero);

        await Future.delayed(const Duration(milliseconds: 200));

        await _controller!.play();
      }
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      body: Stack(
        children: [
          /// 🎥 FULLSCREEN VIDEO (NO FittedBox, NO SizedBox)
          if (_controller != null)
            Positioned.fill(
              child: Container(
                color: Colors.black,
                child: Center(
                  child: Builder(
                    builder: (context) {
                      final aspectRatio =
                          _controller!.videoPlayerController?.value.aspectRatio ?? 9 / 16;

                      final screenHeight = MediaQuery.of(context).size.height;
                      final videoWidth = screenHeight * aspectRatio;

                      return Transform.scale(
                        scale: 1.06, // 🔥 same as Avatar (slight zoom)
                        child: SizedBox(
                          height: screenHeight,
                          width: videoWidth,
                          child: BetterPlayer(
                            controller: _controller!,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

          /// ⏳ Loader
          if (isBuffering)
            const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),

          /// ❌ Close Button
          Positioned(
            top: 40,
            right: 20,
            child: GestureDetector(
              onTap: () {
                _controller?.pause();
                Navigator.pop(context);
              },
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(8),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}