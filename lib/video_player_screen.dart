import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({super.key});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;
  bool _showControls = false;
  bool fullScreen = false;
  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(
        'https://storage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
      ),
      videoPlayerOptions: VideoPlayerOptions(
        allowBackgroundPlayback: true,
      ),
    );
    _initializeVideoPlayerFuture = _controller.initialize();
    _controller.setLooping(true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _skipForward() {
    final newPosition =
        _controller.value.position + const Duration(seconds: 10);
    _controller.seekTo(newPosition);
  }

  void _skipBackward() {
    final newPosition =
        _controller.value.position - const Duration(seconds: 10);
    _controller.seekTo(newPosition);
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });

    if (_showControls) {
      _resetControlVisibilityTimer();
    }
  }
  Timer? _controlVisibilityTimer;
  void _resetControlVisibilityTimer() {
    _controlVisibilityTimer?.cancel();
    _controlVisibilityTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: _toggleControls,
        child: RotatedBox(
          quarterTurns: fullScreen?1:4,
          child: Center(
            child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio+0.4,
              child: Stack(
                children: [
                  Center(
                    child: FutureBuilder(
                      future: _initializeVideoPlayerFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          return VideoPlayer(_controller);
                        } else {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      },
                    ),
                  ),
                  if (_showControls)
                    Center(
                      child: Column(
                        children: [
                          Expanded(
                            flex: fullScreen ?13 : 1,
                            child: Container(
                              color: Colors.grey.withOpacity(0.2),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        _skipBackward();
                                        _resetControlVisibilityTimer();
                                      },
                                      icon: const Icon(
                                        Icons.replay_10,
                                        size: 50,
                                        color: Colors.white,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          if (_controller.value.isPlaying) {
                                            _controller.pause();
                                            print("Paused");
                                          } else {
                                            _controller.play();
                                            print("Playing");
                                          }
                                        });
                                        _resetControlVisibilityTimer();
                                      },
                                      icon: Icon(
                                        _controller.value.isPlaying
                                            ? Icons.pause
                                            : Icons.play_arrow,
                                        size: 50,
                                        color: Colors.white,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        _skipForward();
                                        print("Skipped forward");
                                        _resetControlVisibilityTimer();
                                      },
                                      icon: const Icon(
                                        Icons.forward_10,
                                        size: 50,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: fullScreen ? 1 : 0,
                            child: Container(
                              color: Colors.grey.withOpacity(0.2),
                              child: VideoProgressIndicator(
                                _controller,
                                padding: fullScreen ?const EdgeInsets.symmetric(vertical: 10) : EdgeInsets.zero,
                                allowScrubbing: true,
                                colors: const VideoProgressColors(
                                  playedColor: Colors.red,
                                  bufferedColor: Colors.grey,
                                  backgroundColor: Colors.black,
                                ),

                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Center(
                      child: Column(
                        children: [
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      _toggleControls();
                                    },
                                    onDoubleTap: () {
                                      _skipBackward();
                                      _toggleControls();
                                      Future.delayed(const Duration(seconds: 2)).whenComplete(() => _toggleControls(),);
                                    },
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(onTap: () {
                                    print("here controls shown ");
                                    _toggleControls();

                                  },),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      _toggleControls();
                                    },
                                    onDoubleTap: () {
                                      _skipForward();
                                      _toggleControls();
                                      print("here skip hidden ");
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          !fullScreen ?VideoProgressIndicator(
                          _controller,
                          padding: fullScreen ?const EdgeInsets.symmetric(vertical: 10) : EdgeInsets.zero,
                          allowScrubbing: true,
                          colors: const VideoProgressColors(
                            playedColor: Colors.red,
                            bufferedColor: Colors.grey,
                            backgroundColor: Colors.black,
                          ),

                                                      ) : const SizedBox.shrink()



                        ],
                      ),
                    ),
                  Positioned(
                    bottom: 5,
                    right: 0,
                    child: IconButton(onPressed: () {
                      fullScreen=!fullScreen;
                      setState(() {
                      });
                    }, icon: const Icon(Icons.fullscreen,size: 30,color: Colors.white,)),
                  ),
                  fullScreen &&_showControls ? Positioned(
                    top: 10,
                    left: 15,
                    child: IconButton(onPressed: () {
                      fullScreen = false ;
                      setState(() {
                      });
                    }, icon: Icon(Icons.keyboard_arrow_down_sharp,size: 50,color: Colors.white,)),
                  ):SizedBox.shrink()


                ],
              ),
            ),
          ),
        ),
      ),

    );
  }
}
