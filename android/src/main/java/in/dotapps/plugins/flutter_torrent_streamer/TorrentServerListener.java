package in.dotapps.plugins.flutter_torrent_streamer;

import com.github.se_bastiaan.torrentstream.listeners.TorrentListener;

public interface TorrentServerListener extends TorrentListener {

    void onServerReady(String url);

}
