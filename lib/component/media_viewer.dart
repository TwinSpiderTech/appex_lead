import 'dart:developer';

import 'package:appex_lead/component/shimmer_cards.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class MediaViewer extends StatefulWidget {
  final double aspectRatio;
  final double volume;
  final String contentType; // image | video | youtube
  final String url;
  final bool autoRatio;
  final bool autoPlay;
  final bool loop;
  final bool hideControls;
  final bool shortsEnabled;
  final bool mute;
  bool stopPlayer;
  // final double maxHeight;
  final double? maxWidth;

  MediaViewer({
    super.key,
    required this.contentType,
    required this.url,
    this.aspectRatio = 16 / 5,
    // this.maxHeight = 300,
    this.autoRatio = false,
    this.autoPlay = true,
    this.hideControls = true,
    this.mute = false,
    this.maxWidth,
    this.volume = .5,
    this.stopPlayer = false,
    this.shortsEnabled = true,
    this.loop = true,
  });

  @override
  State<MediaViewer> createState() => _MediaViewerState();
}

class _MediaViewerState extends State<MediaViewer> {
  VideoPlayerController? _videoController;
  YoutubePlayerController? _youtubeController;
  bool _showYoutubeEndOverlay = false;

  bool _isVideoInitialized = false;
  double? _videoAspect;

  @override
  void initState() {
    super.initState();

    // NORMAL VIDEO
    if (widget.contentType == "video") {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(widget.url))
        ..initialize().then((_) {
          setState(() {
            _videoController!.play();
            _videoController!.setVolume(widget.volume);
            _isVideoInitialized = true;
            _videoAspect = _videoController!.value.aspectRatio;
          });
        });
      _videoController!.setLooping(true);
    }
    // YOUTUBE VIDEO
    else if (widget.contentType == "youtube") {
      final videoId = YoutubePlayer.convertUrlToId(widget.url);
      if (videoId != null) {
        _youtubeController = YoutubePlayerController(
          initialVideoId: videoId,
          flags: YoutubePlayerFlags(
            autoPlay: widget.autoPlay,
            mute: widget.mute,
            hideControls: widget.hideControls,
          ),
        );
        // _videoAspect = _videoController!.value.aspectRatio;
        _videoAspect = 16 / 9;
        _youtubeController!.addListener(_youtubeListener);
      }
    }
  }

  void _youtubeListener() {
    final value = _youtubeController!.value;

    if (value.playerState == PlayerState.ended) {
      if (!_showYoutubeEndOverlay) {
        setState(() {
          _showYoutubeEndOverlay = true;
        });
      }
    }

    if (value.playerState == PlayerState.playing) {
      if (_showYoutubeEndOverlay) {
        setState(() {
          _showYoutubeEndOverlay = false;
        });
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    log("Get.currentRoute; ${Get.currentRoute}");
  }

  @override
  void dispose() {
    _youtubeController?.removeListener(_youtubeListener);
    _youtubeController?.dispose();
    _youtubeController = null;

    _videoController?.dispose();
    _videoController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // super.build(context);

    Widget mediaWidget;

    // IMAGE
    if (widget.contentType == "image") {
      mediaWidget = CachedNetworkImage(
        imageUrl: widget.url,
        // width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        placeholder: (context, url) => PlainShimmerCard(),
        errorWidget: (context, url, error) => Center(child: Icon(Icons.error)),
      );

      return _wrap(mediaWidget, widget.aspectRatio);
    }

    // NORMAL VIDEO
    if (widget.contentType == "video") {
      if (!_isVideoInitialized) {
        return _wrap(PlainShimmerCard(), widget.aspectRatio);
      }

      mediaWidget = Stack(
        alignment: Alignment.bottomCenter,
        children: [
          VideoPlayer(_videoController!),
          // _PlayPauseOverlay(controller: _videoController!),
          // VideoProgressIndicator(_videoController!, allowScrubbing: false),
        ],
      );

      return _wrap(
        mediaWidget,
        widget.autoRatio ? _videoAspect! : widget.aspectRatio,
      );
    }

    // YOUTUBE
    if (widget.contentType == "youtube") {
      if (_youtubeController == null) {
        return const Center(
          child: Text(
            "Invalid YouTube URL",
            style: TextStyle(color: Colors.red),
          ),
        );
      }

      mediaWidget = YoutubePlayer(
        controller: _youtubeController!,
        showVideoProgressIndicator: true,
        bottomActions: [
          CurrentPosition(),
          ProgressBar(isExpanded: true),
          RemainingDuration(),
          // FullScreenButton()
        ],
        onEnded: (_) {
          _youtubeController!.seekTo(Duration(seconds: 0));
          _youtubeController!.pause();
        },
      );

      return _wrap(
        mediaWidget,
        (widget.autoRatio
            ? (widget.shortsEnabled
                  ? isYoutubeShort(widget.url)
                        ? 9 / 16
                        : _videoAspect!
                  : _videoAspect!)
            : widget.aspectRatio),
      );
    }

    // UNSUPPORTED
    return const Center(child: Text("Unsupported media type"));
  }

  /// Wrap widget with AspectRatio + max height safety
  Widget _wrap(Widget child, double aspect) {
    // log(aspect);
    return LayoutBuilder(
      builder: (context, constraints) {
        var custom_height = constraints.maxWidth / aspect;
        var custom_width = widget.maxWidth ?? constraints.maxWidth;
        log('Custom height => ${custom_height}');
        log('Custom width => ${custom_width}');

        return ConstrainedBox(
          constraints: BoxConstraints(
            // maxHeight: widget.maxHeight,
          ),
          child: FittedBox(
            fit: BoxFit.contain,
            child: SizedBox(
              width: widget.maxWidth ?? constraints.maxWidth,
              height: constraints.maxWidth / aspect,
              child: VisibilityDetector(
                key: Key(widget.url),
                onVisibilityChanged: (info) {
                  if (_videoController != null) {
                    if (info.visibleFraction > 0.5) {
                      if (widget.contentType == 'youtube') {
                        _youtubeController!.play();
                        _youtubeController!.setVolume(widget.volume.toInt());
                      }
                      if (widget.contentType == 'video') {
                        _videoController!.play();
                        _videoController!.setVolume(widget.volume);
                      }
                      setState(() {
                        widget.stopPlayer = false;
                      });
                    } else {
                      if (_youtubeController != null &&
                          widget.contentType == 'youtube') {
                        _youtubeController!.setVolume(0);
                        _youtubeController!.pause();
                      }
                      if (_videoController != null &&
                          widget.contentType == 'video') {
                        _videoController!.setVolume(0);
                        _videoController!.pause();
                      }

                      setState(() {
                        widget.stopPlayer = true;
                      });
                    }
                  }
                },
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PlayPauseOverlay extends StatelessWidget {
  final VideoPlayerController controller;

  const _PlayPauseOverlay({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          controller.value.isPlaying ? controller.pause() : controller.play(),
      child: Container(
        color: Colors.black26,
        child: Center(
          child: Icon(
            controller.value.isPlaying ? Icons.pause_circle : Icons.play_circle,
            color: Colors.white,
            size: 50,
          ),
        ),
      ),
    );
  }
}

bool isYoutubeShort(String url) {
  return url.contains("/shorts/");
}
