import 'dart:async';
import 'package:YOURDRS_FlutterAPP/common/app_colors.dart';
import 'package:audioplayer/audioplayer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../common/app_text.dart';

typedef void OnError(Exception exception);
enum PlayerState { stopped, playing, paused }
// ignore: must_be_immutable
class PlayAudio extends StatefulWidget {
  String displayFileName;
  var filePath;
  PlayAudio({@required this.filePath, @required this.displayFileName});
  @override
  _PlayAudioState createState() => _PlayAudioState();
}

class _PlayAudioState extends State<PlayAudio> {
  Duration duration;
  Duration position;
  var kUrl;
  AudioPlayer audioPlayer;
  String localFilePath;
  PlayerState playerState = PlayerState.stopped;
  get isPlaying => playerState == PlayerState.playing;
  get isPaused => playerState == PlayerState.paused;
  get durationText =>
      duration != null ? duration.toString().split('.').first : '';
  get positionText =>
      position != null ? position.toString().split('.').first : '';
  bool isMuted = false;
  StreamSubscription _positionSubscription;
  StreamSubscription _audioPlayerStateSubscription;
//initstate
  @override
  void initState() {
    super.initState();
    initAudioPlayer();
    kUrl = widget.filePath;
  }
//dispose
  @override
  void dispose() {
    _positionSubscription.cancel();
    _audioPlayerStateSubscription.cancel();
    audioPlayer.stop();
    super.dispose();
  }
//init for audio player
  void initAudioPlayer() {
    audioPlayer = AudioPlayer();
    _positionSubscription = audioPlayer.onAudioPositionChanged
        .listen((p) => setState(() => position = p));
    _audioPlayerStateSubscription =
        audioPlayer.onPlayerStateChanged.listen((s) {
          if (s == AudioPlayerState.PLAYING) {
            setState(() => duration = audioPlayer.duration);
          } else if (s == AudioPlayerState.STOPPED) {
            onComplete();
            setState(() {
              position = duration;
            });
          }
        }, onError: (msg) {
          setState(() {
            playerState = PlayerState.stopped;
            duration = Duration(seconds: 0);
            position = Duration(seconds: 0);
          });
        });
  }
// play for audio
  Future play() async {
    await audioPlayer.play(kUrl);
    setState(() {
      playerState = PlayerState.playing;
    });
  }
//pause for audio
  Future pause() async {
    await audioPlayer.pause();
    setState(() => playerState = PlayerState.paused);
  }
//stop for audio
  Future stop() async {
    await audioPlayer.stop();
    setState(() {
      playerState = PlayerState.stopped;
      position = Duration();
    });
  }
  void onComplete() {
    setState(() => playerState = PlayerState.stopped);
  }
//building the widget
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.only(top: 25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.displayFileName, style: TextStyle(fontSize: 18,fontFamily: AppFonts.regular,),),
            Material(child: _buildPlayer()),
            if (!kIsWeb)
              localFilePath != null ? Text(localFilePath,style: TextStyle(fontFamily: AppFonts.regular,),) : Container(),
            if (!kIsWeb)
              Padding(
                padding: const EdgeInsets.all(8.0),
              ),
          ],
        ),
      ),
    );
  }
//build player widget
  Widget _buildPlayer() => Container(
    padding: EdgeInsets.all(16.0),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(mainAxisSize: MainAxisSize.min, children: [
          IconButton(
            onPressed: isPlaying ? null : () => play(),
            iconSize: 64.0,
            icon: Icon(Icons.play_arrow),
            color: CustomizedColors.audioPlayerIconsColor,
          ),
          IconButton(
            onPressed: isPlaying ? () => pause() : null,
            iconSize: 64.0,
            icon: Icon(Icons.pause),
            color: CustomizedColors.audioPlayerIconsColor,
          ),
          IconButton(
            onPressed: isPlaying || isPaused ? () => stop() : null,
            iconSize: 64.0,
            icon: Icon(Icons.stop),
            color: CustomizedColors.audioPlayerIconsColor,
          ),
        ]),
        if (duration != null)
          Slider(
              activeColor: CustomizedColors.audioPlayerSliderColor,
              value: position?.inMilliseconds?.toDouble() ?? 0.0,
              onChanged: (double value) {
                return audioPlayer.seek((value / 1000).roundToDouble());
              },
              min: 0,
              max: duration.inMilliseconds.toDouble()),
        if (position != null) _buildProgressView()
      ],
    ),
  );
  /// build progress view for current time and total time
  Row _buildProgressView() => Row(mainAxisSize: MainAxisSize.min, children: [
    Padding(
      padding: EdgeInsets.all(12.0),
      child: Center(child: Icon(Icons.timer_sharp)),
    ),
    Text(
      position != null
          ? "${positionText ?? ''} / ${durationText ?? ''}"
          : duration != null
          ? durationText
          : '',
      style: TextStyle(fontSize: 24.0,fontFamily: AppFonts.regular,),
    )
  ]);
}