
# Flutter Torrent Streamer  
  
A flutter plugin to stream videos directly from torrent&#x2F;magnet links.  
  
This plugin is still under development and pull requests to make it better are heavily appreciated  
  
## Few Important points to note before using this plugin  
- Has only android support for now. (Help to implement iOS support is highly appreciated)  
- Is still under development and APIs may go through breaking changes.  
- Supports streaming and seeking videos while still being downloaded but is still experimental and has been tested to work on MX Player but does not work with `video_player` plugin.    
  
## Installation  
  
Add below line to your `pubspec.yaml` and run `flutter packages get`  
```  
flutter_torrent_streamer: ^0.0.1+1  
```  
  
## Example  
```  
import 'package:flutter_torrent_streamer/flutter_torrent_streamer.dart';  
  
class TorrentStreamerView extends StatefulWidget {
  @override _TorrentStreamerViewState createState() => _TorrentStreamerViewState();
}  
  
class _TorrentStreamerViewState extends State<TorrentStreamerView> {
  bool isStreamReady = false;
  int progress = 0;
  
  @override  
  void initState() {
    super.initState();
    _addTorrentListeners();
  }
  
  void _addTorrentListeners() {
    TorrentStreamer.addEventListener('progress', (data) {
      setState(() => progress = data['progress']);
    });
    
    TorrentStreamer.addEventListener('ready', (_) {
      setState(() => isStreamReady = true);
    });
  }
    
  Future<void> _startDownload() async {
    await TorrentStreamer.start('torrent-link-here');
  }
  
  Future<void> _openVideo(BuildContext context) async {
    if (progress == 100) {
      await TorrentStreamer.launchVideo();
    } else {
      showDialog(
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text('Are You Sure?'),
            content: new Text('Playing video while it is still downloading is experimental and only works on limited set of apps.'),
            actions: <Widget>[
              FlatButton(
               child: new Text("Cancel"),
                onPressed: () {
                  Navigator.of(context).pop();
                }
              ),
              FlatButton(
                child: new Text("Yes, Proceed"),
                onPressed: () async {
                  await TorrentStreamer.launchVideo();
                  Navigator.of(context).pop();
                }
              )
            ]
          );
        },
        context: context
      );
    }
  }
 
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          RaisedButton(
            child: Text('Start Download'),
            onPress: _startDownload
          ),
          Container(height: 8),
          RaisedButton(
	        child: Text('Play Video'),
	        onPress: () => _openVideo(context)
	      )
	    ],
	    crossAxisAlignment: CrossAxisAlignment.center,
	    mainAxisAlignment: MainAxisAlignment.start,
	    mainAxisSize: MainAxisSize.max
	  ),
	  padding: EdgeInsets.all(16)
    );
  }
}  
```

See [example](/example) app for more detailed usage.

## TODO
- Add support for `video_player` flutter plugin.
- Make streaming and seeking more robust for while download still in progress.
- Run torrent streamer server on local network instead of localhost.
- Add support for iOS.