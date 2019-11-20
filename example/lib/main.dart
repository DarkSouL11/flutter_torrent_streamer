import 'dart:async';

import 'package:drm_wv_fp_player/model/secured_video_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_torrent_streamer/flutter_torrent_streamer.dart';
import 'package:drm_wv_fp_player/drm_wv_fp_player.dart';

void main() async {
//  final Directory saveDir = await getExternalStorageDirectory();
  await TorrentStreamer.init();
  runApp(MyApp());
}

// Mp4 Link
var sampleMagnet =
    'magnet:?xt=urn:btih:125ecf134ddc651bc6ef58e6591495824446ffa4&dn=www.TamilMV.bid%20-%20Khamoshi%20(2019)%20Hindi%20Proper%20TRUE%20WEB-DL%20-%20720p%20-%20AVC%20-%20UNTOUCHED%20-%20AAC%20-%201GB.mp4&tr=udp%3a%2f%2ftracker.coppersurfer.tk%3a6969%2fannounce&tr=http%3a%2f%2fshare.camoe.cn%3a8080%2fannounce&tr=udp%3a%2f%2ftracker.pirateparty.gr%3a6969%2fannounce&tr=udp%3a%2f%2ftracker.tiny-vps.com%3a6969%2fannounce&tr=udp%3a%2f%2fopen.demonii.si%3a1337%2fannounce&tr=udp%3a%2f%2fipv4.tracker.harry.lu%3a80%2fannounce&tr=udp%3a%2f%2ftw.opentracker.ga%3a36920%2fannounce&tr=udp%3a%2f%2fdenis.stalker.upeer.me%3a6969%2fannounce&tr=http%3a%2f%2ft.nyaatracker.com%3a80%2fannounce&tr=udp%3a%2f%2ftracker.opentrackr.org%3a1337%2fannounce&tr=udp%3a%2f%2fopen.stealth.si%3a80%2fannounce&tr=udp%3a%2f%2fbt.xxx-tracker.com%3a2710%2fannounce&tr=udp%3a%2f%2ftracker.vanitycore.co%3a6969%2fannounce&tr=http%3a%2f%2ftracker.city9x.com%3a2710%2fannounce&tr=udp%3a%2f%2ftracker.internetwarriors.net%3a1337%2fannounce';

// Mp4 Link
var sampleMagnet1 =
    'magnet:?xt=urn:btih:60B101018A32FBDDC264C1A2EB7B7E9A99DBFB6A&dn=Mad%20Max%20Fury%20Road%20%282015%29&tr=udp%3a%2f%2ftracker.yify-torrents.com%2fannounce&tr=udp%3a%2f%2fopen.demonii.com%3a1337&tr=udp%3a%2f%2fexodus.desync.com%3a6969&tr=udp%3a%2f%2ftracker.istole.it%3a80&tr=udp%3a%2f%2ftracker.publicbt.com%3a80&tr=udp%3a%2f%2ftracker.openbittorrent.com%3a80&tr=udp%3a%2f%2ftracker.leechers-paradise.org%3a6969&tr=udp%3a%2f%2f9.rarbg.com%3a2710&tr=udp%3a%2f%2fp4p.arenabg.ch%3a1337&tr=udp%3a%2f%2fp4p.arenabg.com%3a1337&tr=udp%3a%2f%2ftracker.coppersurfer.tk%3a6969';

//mkv link
var sampleMagnet2 =
    'magnet:?xt=urn:btih:ad6ad71b31b60fe9e62a8084d05211b7b44e1652&dn=www.TamilMV.bid%20-%20Aame%20(2019)%20Telugu%20(Org%20Vers)%20Proper%20HDRip%20-%20200MB%20-%20x264%20-%20MP3%20-%20ESub.mkv&tr=udp%3a%2f%2ftracker.coppersurfer.tk%3a6969%2fannounce&tr=http%3a%2f%2fshare.camoe.cn%3a8080%2fannounce&tr=udp%3a%2f%2ftracker.pirateparty.gr%3a6969%2fannounce&tr=udp%3a%2f%2ftracker.tiny-vps.com%3a6969%2fannounce&tr=udp%3a%2f%2fopen.demonii.si%3a1337%2fannounce&tr=udp%3a%2f%2fipv4.tracker.harry.lu%3a80%2fannounce&tr=udp%3a%2f%2ftw.opentracker.ga%3a36920%2fannounce&tr=udp%3a%2f%2fdenis.stalker.upeer.me%3a6969%2fannounce&tr=http%3a%2f%2ft.nyaatracker.com%3a80%2fannounce&tr=udp%3a%2f%2ftracker.opentrackr.org%3a1337%2fannounce&tr=udp%3a%2f%2fopen.stealth.si%3a80%2fannounce&tr=udp%3a%2f%2fbt.xxx-tracker.com%3a2710%2fannounce&tr=udp%3a%2f%2ftracker.vanitycore.co%3a6969%2fannounce&tr=http%3a%2f%2ftracker.city9x.com%3a2710%2fannounce&tr=udp%3a%2f%2ftracker.internetwarriors.net%3a1337%2fannounce';

//Avi Link(Cannot Play Format)
var sampleMagnet3 =
    'magnet:?xt=urn:btih:a89d1893c5b33ae79af8d5669b660cc2ced2629b&dn=www.TamilMV.bid%20-%20Khamoshi%20(2019)%20Hindi%20Proper%20HDRip%20-XviD%20-%20700MB%c2%a0-%20MP3%20-%20ESub.avi&tr=udp%3a%2f%2ftracker.coppersurfer.tk%3a6969%2fannounce&tr=http%3a%2f%2fshare.camoe.cn%3a8080%2fannounce&tr=udp%3a%2f%2ftracker.pirateparty.gr%3a6969%2fannounce&tr=udp%3a%2f%2ftracker.tiny-vps.com%3a6969%2fannounce&tr=udp%3a%2f%2fopen.demonii.si%3a1337%2fannounce&tr=udp%3a%2f%2fipv4.tracker.harry.lu%3a80%2fannounce&tr=udp%3a%2f%2ftw.opentracker.ga%3a36920%2fannounce&tr=udp%3a%2f%2fdenis.stalker.upeer.me%3a6969%2fannounce&tr=http%3a%2f%2ft.nyaatracker.com%3a80%2fannounce&tr=udp%3a%2f%2ftracker.opentrackr.org%3a1337%2fannounce&tr=udp%3a%2f%2fopen.stealth.si%3a80%2fannounce&tr=udp%3a%2f%2fbt.xxx-tracker.com%3a2710%2fannounce&tr=udp%3a%2f%2ftracker.vanitycore.co%3a6969%2fannounce&tr=http%3a%2f%2ftracker.city9x.com%3a2710%2fannounce&tr=udp%3a%2f%2ftracker.internetwarriors.net%3a1337%2fannounce';

//mkv link
var sampleMagnet4 =
    'magnet:?xt=urn:btih:b579b3599341f87d8f614f3446e7a37eeb197aac&dn=www.TamilMV.bid%20-%20Adrushyam%20(2019)%20Telugu%20HDRip%20-%20200MB%20-%20x264%20-%20MP3.mkv&tr=udp%3a%2f%2ftracker.coppersurfer.tk%3a6969%2fannounce&tr=http%3a%2f%2fshare.camoe.cn%3a8080%2fannounce&tr=udp%3a%2f%2ftracker.pirateparty.gr%3a6969%2fannounce&tr=udp%3a%2f%2ftracker.tiny-vps.com%3a6969%2fannounce&tr=udp%3a%2f%2fopen.demonii.si%3a1337%2fannounce&tr=udp%3a%2f%2fipv4.tracker.harry.lu%3a80%2fannounce&tr=udp%3a%2f%2ftw.opentracker.ga%3a36920%2fannounce&tr=udp%3a%2f%2fdenis.stalker.upeer.me%3a6969%2fannounce&tr=http%3a%2f%2ft.nyaatracker.com%3a80%2fannounce&tr=udp%3a%2f%2ftracker.opentrackr.org%3a1337%2fannounce&tr=udp%3a%2f%2fopen.stealth.si%3a80%2fannounce&tr=udp%3a%2f%2fbt.xxx-tracker.com%3a2710%2fannounce&tr=udp%3a%2f%2ftracker.vanitycore.co%3a6969%2fannounce&tr=http%3a%2f%2ftracker.city9x.com%3a2710%2fannounce&tr=udp%3a%2f%2ftracker.internetwarriors.net%3a1337%2fannounce';

List<String> magnets = [
  sampleMagnet,
  sampleMagnet1,
  sampleMagnet2,
  sampleMagnet3,
  sampleMagnet4,
];

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
              title: Text('Torrent Streamer'),
            ),
            body: TorrentStreamerView()),
        theme: ThemeData(primaryColor: Colors.blue));
  }
}

class MySpacer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(height: 8, width: 8);
  }
}

class TorrentStreamerView extends StatefulWidget {
  @override
  _TorrentStreamerViewState createState() => _TorrentStreamerViewState();
}

class _TorrentStreamerViewState extends State<TorrentStreamerView> {
  TextEditingController _controller;
  String torrentLink;

  bool isDownloading = false;
  bool isStreamReady = false;
  bool isFetchingMeta = false;
  bool hasError = false;
  Map<dynamic, dynamic> status;

  @override
  void initState() {
    super.initState();

    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    _controller = TextEditingController();
    _addTorrentListeners();
  }

  @override
  void dispose() {
    TorrentStreamer.stop();
    TorrentStreamer.removeEventListeners();

    super.dispose();
  }

  void resetState() {
    setState(() {
      isDownloading = false;
      isDownloadPressed = false;
      isStreamReady = false;
      isFetchingMeta = false;
      hasError = false;
      status = null;
    });
  }

  void _addTorrentListeners() {
    TorrentStreamer.addEventListener('started', (_) {
      resetState();
      setState(() {
        isDownloading = true;
        isFetchingMeta = true;
      });
    });

    TorrentStreamer.addEventListener('prepared', (_) {
      setState(() {
        isDownloading = true;
        isFetchingMeta = false;
      });
    });

    TorrentStreamer.addEventListener('progress', (data) {
      setState(() => status = data);
    });

    TorrentStreamer.addEventListener('ready', (_) {
      setState(() => isStreamReady = true);
    });

    TorrentStreamer.addEventListener('stopped', (_) {
      resetState();
    });

    TorrentStreamer.addEventListener('error', (_) {
      setState(() => hasError = true);
    });
  }

  int _toKBPS(double bps) {
    return (bps / (1024)).floor();
  }

  Future<void> _cleanDownloads(BuildContext context) async {
    await TorrentStreamer.clean();
    Scaffold.of(context)
        .showSnackBar(SnackBar(content: Text('Cleared torrent cache!')));
  }

  bool isDownloadPressed = false;

  Future<void> _startDownload() async {
    if (torrentLink == magnets[currentMovie]) {
      torrentLink = magnets[currentMovie];
    } else {
      torrentLink = magnets[currentMovie];
    }
    _controller.clear();
    if (!isFetchingMeta && isDownloading && progress > 0) {
      await TorrentStreamer.stop();
    }
    if (!(torrentLink != magnets[currentMovie] && isDownloadPressed)) {
      await TorrentStreamer.start(torrentLink);
      isDownloadPressed = true;
    }
    setState(() {});
  }

  bool useLocalPlayer = true;
  bool useVideoExoPlayer = true;
  Future<void> _openVideo(BuildContext context) async {
    if (isCompleted) {
      await TorrentStreamer.launchVideo();
    } else {
      var url = await TorrentStreamer.getStreamUrl();

      if (useLocalPlayer) {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return (useVideoExoPlayer) ? VideoApp(url) : Home(); //VideoApp(url);
        })).then((onValue) {
          SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
          ]);
        });
      } else {
        TorrentStreamer.launchVideo();
      }
    }
  }

  int currentMovie = 0;

  Widget _buildInput(BuildContext context) {
    List<DropdownMenuItem> items = [];
    for (var m in magnets) {
      items.add(DropdownMenuItem(
        child: Text('movie ${magnets.indexOf(m)}'),
        value: magnets.indexOf(m),
      ));
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        // TextField(
        //   controller: _controller,
        //   decoration: new InputDecoration(
        //       border: OutlineInputBorder(),
        //       contentPadding: EdgeInsets.all(8),
        //       hintText: 'Enter torrent/magnet link'),
        //   onChanged: (String value) {
        //     setState(() {
        //       torrentLink = value;
        //     });
        //   },
        // ),

        DropdownButton(
          items: items,
          value: currentMovie,
          onChanged: (value) {
            currentMovie = value;
            setState(() {});
          },
        ),
        RaisedButton(
          child: Text(isDownloadPressed ? 'Downloading' : 'Download'),
          color: Colors.blue,
          onPressed: isDownloadPressed ? null : _startDownload,
        ),
        MySpacer(),
        Row(
          children: <Widget>[
            Checkbox(
              value: useLocalPlayer,
              onChanged: (value) {
                useLocalPlayer = value;
                setState(() {});
              },
            ),
            Text('Local Player'),
            if (useLocalPlayer)
              Checkbox(
                value: useVideoExoPlayer,
                onChanged: (value) {
                  useVideoExoPlayer = value;
                  setState(() {});
                },
              ),
            if (useLocalPlayer) Text('Video Exo Player'),
          ],
        ),
      ],
    );
  }

  Widget _buildTorrentStatus(BuildContext context) {
    if (hasError) {
      return Text('Failed to download torrent!');
    } else if (isDownloading) {
      String statusText = '';
      if (isFetchingMeta) {
        statusText = 'Fetching meta data';
      } else {
        statusText = 'Progress: ${progress.floor().toString()}% - ' +
            'Speed: ${_toKBPS(speed)} KB/s';
      }

      return Column(
        children: <Widget>[
          Text(statusText),
          MySpacer(),
          LinearProgressIndicator(
              value: !isFetchingMeta ? progress / 100 : null),
          MySpacer(),
          Row(
            children: <Widget>[
              RaisedButton(
                  child: Text('Play Video'),
                  color: Colors.blue,
                  onPressed: isStreamReady ? () => _openVideo(context) : null),
              MySpacer(),
              OutlineButton(
                child: Text('Pause Download'),
                onPressed: TorrentStreamer.stop,
              ),
              MySpacer(),
              OutlineButton(
                child: Text('Stop Download'),
                onPressed: TorrentStreamer.stop,
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.center,
          )
        ],
      );
    } else {
      return Container(height: 0, width: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          _buildInput(context),
          MySpacer(),
          MySpacer(),
          _buildTorrentStatus(context)
        ],
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
      ),
      padding: EdgeInsets.all(16),
    );
  }

  bool get isCompleted => progress == 100;

  double get progress => status != null ? status['progress'] : 0;

  double get speed => status != null ? status['downloadSpeed'] : 0;
}

class VideoApp extends StatefulWidget {
  final String url;
  VideoApp(this.url);
  @override
  _VideoAppState createState() => _VideoAppState();
}

class _VideoAppState extends State<VideoApp> {
  VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays([]);
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    _controller = VideoPlayerController.exoplayerMeidaFrameWork(MediaContent(
      name: "WV: Secure SD (cenc,MP4,H264)", //Can be null
      uri: widget.url, //Google Test Content
      extension: null, //Pending Work
      drm_scheme: 'widevine',
      drm_license_url:
          'https://proxy.uat.widevine.com/proxy?provider=widevine_test', //Google Test License
      ad_tag_uri: null, //Pending work
      spherical_stereo_mode: null, //Pending Work
      playlist: null, //Pending Work
    ))
      ..initialize().then((_) {
        _controller.play();
        Timer(Duration(seconds: 3), () {
          setState(() {
            showControls = false;
          });
        });
        setTotallength();
        setState(() {});
      })
      ..addListener(() {
        min = _controller.value.position.inMinutes;

        sec = _controller.value.position.inSeconds -
            (_controller.value.position.inMinutes * 60);
        setState(() {});
      });
  }

  int hrsTotal;
  int minTotal;
  int secTotal;
  setTotallength() {
    hrsTotal = _controller.value.duration.inHours;
    minTotal = _controller.value.duration.inMinutes -
        (_controller.value.duration.inHours * 60);
    secTotal = _controller.value.duration.inSeconds -
        (_controller.value.duration.inMinutes * 60);
  }

  int sec = 0;
  int min = 0;
  bool showControls = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Demo',
      home: Scaffold(
        body: Builder(
          builder: (context) {
            var width = MediaQuery.of(context).size.width;
            var height = MediaQuery.of(context).size.height;
            return Container(
              color: Colors.black,
              width: Orientation.landscape != null ? width : null,
              height: Orientation.landscape != null ? height : null,
              child: _controller.value.initialized
                  ? _buildVideoPlayer(height, width)
                  : Center(
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.grey[500].withOpacity(0.5),
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
            );
          },
        ),
      ),
    );
  }

  _buildVideoPlayer(double height, double width) {
    return Center(
      child: GestureDetector(
        onTap: () {
          showControls ? showControls = false : showControls = true;
          setState(() {});
        },
        child: AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: Stack(
              children: <Widget>[
                VideoPlayer(
                  _controller,
                ),
                if (showControls)
                  Container(
                    margin: EdgeInsets.only(
                      top: height - 120,
                      // top: 280,
                      left: 30,
                      right: 30,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Builder(builder: (context) {
                          String minStr;
                          String secStr;
                          if (min < 10) {
                            minStr = '0$min';
                          } else {
                            minStr = '$min';
                          }
                          if (sec < 10) {
                            secStr = '0$sec';
                          } else {
                            secStr = '$sec';
                          }
                          if (min == null) minStr = '00';
                          if (sec == null) secStr = '00';
                          return Text(
                            '$minStr : ' + '$secStr',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          );
                        }),
                        Padding(
                          padding: EdgeInsets.all(5.0),
                        ),
                        Container(
                          width: 550,
                          height: 20,
                          color: Colors.white.withOpacity(0.15),
                          padding: EdgeInsets.only(
                            left: 5,
                            right: 5,
                            bottom: 5,
                          ),
                          child: VideoProgressIndicator(
                            _controller,
                            allowScrubbing: false,
                            colors: VideoProgressColors(
                              playedColor: Colors.red.withOpacity(.75),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(5.0),
                        ),
                        Text(
                          '$hrsTotal:$minTotal:$secTotal',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (showControls)
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        FloatingActionButton(
                          heroTag: null,
                          child: Icon(
                            Icons.fast_rewind,
                          ),
                          backgroundColor: Colors.grey[500].withOpacity(0.5),
                          onPressed: () {
                            setState(() {
                              _controller.seekTo(
                                Duration(
                                  seconds:
                                      _controller.value.position.inSeconds - 10,
                                ),
                              );
                            });
                          },
                        ),
                        Padding(
                          padding: EdgeInsets.all(50),
                        ),
                        FloatingActionButton(
                          heroTag: null,
                          child: Icon(
                            _controller.value.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                          ),
                          backgroundColor: Colors.grey[500].withOpacity(0.5),
                          onPressed: () {
                            setState(() {
                              _controller.value.isPlaying
                                  ? _controller.pause()
                                  : _controller.play().then((_) {
                                      Timer(Duration(seconds: 3), () {
                                        setState(() {
                                          showControls = false;
                                        });
                                      });
                                    });
                            });
                          },
                        ),
                        Padding(
                          padding: EdgeInsets.all(50),
                        ),
                        FloatingActionButton(
                          heroTag: null,
                          child: Icon(
                            Icons.fast_forward,
                          ),
                          backgroundColor: Colors.grey[500].withOpacity(0.5),
                          onPressed: () {
                            setState(() {
                              var sec = _controller.value.position.inSeconds;
                              sec = sec + 10;
                              _controller.seekTo(
                                Duration(seconds: sec),
                              );
                            });
                          },
                        ),
                      ],
                    ),
                  )
              ],
            )),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Example',
      home: VideoExample(),
    );
  }
}

class VideoExample extends StatefulWidget {
  @override
  VideoState createState() => VideoState();
}

class VideoState extends State<VideoExample> {
  VideoPlayerController playerController;
  VoidCallback listener;

  @override
  void initState() {
    super.initState();
    listener = () {
      setState(() {});
    };
  }

  Future<void> createVideo() async {
    if (playerController == null) {
      playerController =
          VideoPlayerController.network(await TorrentStreamer.getStreamUrl())
            ..addListener(listener)
            ..setVolume(1.0)
            ..initialize()
            ..play();
    } else {
      if (playerController.value.isPlaying) {
        playerController.pause();
      } else {
        playerController.initialize();
        playerController.play();
      }
    }
  }

  @override
  void deactivate() {
    playerController.setVolume(0.0);
    playerController.removeListener(listener);
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video Example'),
      ),
      body: Center(
          child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                child: (playerController != null
                    ? VideoPlayer(
                        playerController,
                      )
                    : Container()),
              ))),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await createVideo();
          playerController.play();
        },
        child: Icon(Icons.play_arrow),
      ),
    );
  }
}
