package in.dotapps.plugins.flutter_torrent_streamer;

public class TorrentStreamNotInitializedException extends Exception {

    public TorrentStreamNotInitializedException() {
        super("TorrentStream has not been initialized yet. Please start TorrentStream before starting a stream.");
    }
}
