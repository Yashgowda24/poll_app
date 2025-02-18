import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String? recordedFilePath;

  const AudioPlayerWidget({Key? key, this.recordedFilePath}) : super(key: key);

  @override
  _AudioPlayerWidgetState createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      setState(() {
        _isPlaying = state == PlayerState.playing;
      });
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playRecordedFile() async {
    if (widget.recordedFilePath != null) {
      await _audioPlayer.play(DeviceFileSource(widget.recordedFilePath!));
    }
  }

  Future<void> _pauseRecordedFile() async {
    await _audioPlayer.pause();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Audio Player')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (widget.recordedFilePath != null)
              Text('Recorded file: ${widget.recordedFilePath}'),
            const SizedBox(height: 10),
            if (widget.recordedFilePath != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed:
                        _isPlaying ? _pauseRecordedFile : _playRecordedFile,
                    child: Text(_isPlaying ? 'Pause' : 'Play'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
