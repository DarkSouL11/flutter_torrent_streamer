import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_torrent_streamer/flutter_torrent_streamer.dart';
import 'package:video_player/video_player.dart';

void main() async {
  await TorrentStreamer.init();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String downloadStatus = 'Not started!';
  bool isStreamReady = false;

  VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    attachListeners();
  }

  void attachListeners() {
    TorrentStreamer.addEventListener('prepared', (data) {
      setState(() {
        downloadStatus = 'Meta data fetched';
      });
    });

    TorrentStreamer.addEventListener('started', (data) {
      setState(() {
        downloadStatus = 'Download started';
      });
    });

    TorrentStreamer.addEventListener('stopped', (data) {
      setState(() {
        downloadStatus = 'Download stopped';
        isStreamReady = false;
        _controller.dispose();
        _controller = null;
      });
    });

    TorrentStreamer.addEventListener('progress', (data) {
      setState(() {
        downloadStatus = 'Progress: ${data['progress']}';
      });
    });

    TorrentStreamer.addEventListener('ready', (data) async {
      if (_controller == null) {
        final File videoFile = File(data['file']);
        _controller = VideoPlayerController.file(videoFile);
        await _controller.initialize();
        setState(() {
          downloadStatus = 'Download Complete: Ready to play!';
          isStreamReady = true;
        });
      }
    });

    TorrentStreamer.addEventListener('error', (data) {
      print('Stream errored: ' + data.toString());
      setState(() {
        downloadStatus = 'Download Errored';
      });
    });
  }

  void startDownload() {
    String uri = "https://yts.lt/torrent/download/FE6EB05072CFF4F2FC865AC4398C0C1914A2F99C";
    TorrentStreamer.start(uri);
  }

  void stopDownload() {
    TorrentStreamer.stop();
  }

  Widget _playerUi() {
    if (!isStreamReady) return Container();

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: VideoPlayer(_controller),
        ),
        Container(
          child: VideoProgressIndicator(_controller, allowScrubbing: true)
        ),
        Container(height: 16),
        RaisedButton(
          child: Text(_controller.value.isPlaying ? 'Pause' : 'Play'),
          onPressed: () {
            setState(() {
              _controller.value.isPlaying
                ? _controller.pause()
                : _controller.play();
            });
          }
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Plugin example app'),
        ),
        body: Center(
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    RaisedButton(
                      child: Text('Start Download'),
                      color: Colors.blue,
                      onPressed: startDownload,
                    ),
                    Container(width: 16),
                    OutlineButton(
                      child: Text('Stop Download'),
                      color: Colors.blue,
                      onPressed: stopDownload,
                    ),
                  ],
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                ),
                Container(height: 16),
                Text(downloadStatus),
                Expanded(
                  child: _playerUi()
                ),
              ]
            ),
            padding: EdgeInsets.all(8)
          )
        ),
      ),
    );
  }
}
