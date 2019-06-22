package in.dotapps.plugins.flutter_torrent_streamer;

import com.github.se_bastiaan.torrentstream.Torrent;
import com.github.se_bastiaan.torrentstream.TorrentStream;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.util.Map;

import fi.iki.elonen.NanoHTTPD;
import fi.iki.elonen.NanoHTTPD.IHTTPSession;
import fi.iki.elonen.NanoHTTPD.Response;
import fi.iki.elonen.WebServerPlugin;

public class VideoServerPlugin implements WebServerPlugin {
    private TorrentStream stream;

    VideoServerPlugin(TorrentStream torrentStream) {
        stream = torrentStream;
    }

    @Override
    public boolean canServeUri(String uri, File rootDir) {
        return true;
    }

    @Override
    public void initialize(Map<String, String> commandLineOptions) {}

    @Override
    public Response serveFile(String uri, Map<String, String> headers, IHTTPSession session, File file, String mimeType) {
        final Torrent torrent = stream.getCurrentTorrent();
        Response response;
        try {
            long start = 0, end = -1;
            String range = headers.get("range");

            if (range != null && range.startsWith("bytes=")) {
                range = range.substring("bytes=".length());
                int minus = range.indexOf("-");
                if (minus > 0) {
                    try {
                        start = Long.parseLong(range.substring(0, minus));
                        end = Long.parseLong(range.substring(minus));
                    } catch (NumberFormatException e) {
                        // Ignored error
                    }
                }
            }

            long fileLen = torrent.getVideoFile().length();
            if ((end == -1) || (end > fileLen - 1)) {
                end = fileLen - 1;
            }

            torrent.setInterestedBytes(start);
            InputStream is = torrent.getVideoStream();
            is.skip(start);

            response = NanoHTTPD.newFixedLengthResponse(Response.Status.PARTIAL_CONTENT, mimeType, is, end - start + 1);
            response.addHeader("Accept-Ranges", "bytes");
            response.addHeader("Content-Length", (end - start + 1) + "");
            response.addHeader("Content-Range", "bytes " + start + "-" + end + "/" + fileLen);
        } catch (IOException e) {
            response = NanoHTTPD.newFixedLengthResponse(Response.Status.CONFLICT, NanoHTTPD.MIME_PLAINTEXT, "Torrent not yet streaming");
        }

        return response;
    }
}
