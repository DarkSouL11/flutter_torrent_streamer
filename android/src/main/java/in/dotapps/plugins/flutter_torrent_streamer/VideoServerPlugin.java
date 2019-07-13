package in.dotapps.plugins.flutter_torrent_streamer;

import com.frostwire.jlibtorrent.TorrentHandle;
import com.github.se_bastiaan.torrentstream.Torrent;
import com.github.se_bastiaan.torrentstream.TorrentStream;

import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Timer;
import java.util.TimerTask;
import java.util.concurrent.CountDownLatch;

import fi.iki.elonen.NanoHTTPD;
import fi.iki.elonen.NanoHTTPD.IHTTPSession;
import fi.iki.elonen.NanoHTTPD.Response;
import fi.iki.elonen.WebServerPlugin;

public class VideoServerPlugin implements WebServerPlugin {
  private String TAG = VideoServerPlugin.class.getCanonicalName();
  private TorrentStream stream;

  VideoServerPlugin(TorrentStream stream) {
    this.stream = stream;
  }

  @Override
  public boolean canServeUri(String uri, File rootDir) {
    final TorrentHandle th = getTorrentHandle();
    // We want to serve video file normally if it is downloaded completely
    return th.status().progress() != 1;
  }

  @Override
  public void initialize(Map<String, String> commandLineOptions) {}

  @Override
  public Response serveFile(String uri, Map<String, String> headers, IHTTPSession session, File file, String mimeType) {
    final Torrent torrent = getTorrent();
    Response response;

    try {
      String etag = Integer.toHexString((file.getAbsolutePath() + file.lastModified() + "" + file.length()).hashCode());
      String rangeHeader = headers.get("range");

      if (rangeHeader != null) {
        long[] range = getRange(rangeHeader);
        torrent.setInterestedBytes(range[0]);

        final LinkedHashMap<Integer, Boolean> requiredPieces = getRequiredPieceIndices(range);
        final CountDownLatch latch = new CountDownLatch(1);
        final Waiter waiter = new Waiter(latch, requiredPieces);
        waiter.start();
        latch.await();

        InputStream is = torrent.getVideoStream();
        byte[] content = new byte[(int) range[2]];
        is.skip(range[0]);
        is.read(content, 0, (int) range[2]);

        response = NanoHTTPD.newFixedLengthResponse(Response.Status.PARTIAL_CONTENT, mimeType, new ByteArrayInputStream(content), range[2]);
        response.addHeader("Accept-Ranges", "bytes");
        response.addHeader("Content-Length", range[2] + "");
        response.addHeader("Content-Range", "bytes " + range[0] + "-" + range[1] + "/" + file.length());
        response.addHeader("ETag", etag);

        is.close();
      } else {
        if (etag.equals(headers.get("if-none-match")))
          response = NanoHTTPD.newFixedLengthResponse(Response.Status.NOT_MODIFIED, mimeType, "");
        else {
          InputStream is = torrent.getVideoStream();

          response = NanoHTTPD.newFixedLengthResponse(Response.Status.OK, mimeType, is, file.length());
          response.addHeader("Content-Length", "" + file.length());
          response.addHeader("ETag", etag);

          is.close();
        }
      }
    } catch (IOException e) {
      response = NanoHTTPD.newFixedLengthResponse(Response.Status.CONFLICT, NanoHTTPD.MIME_PLAINTEXT, "Torrent not yet streaming");
    } catch (InterruptedException e) {
      response = NanoHTTPD.newFixedLengthResponse(Response.Status.REQUEST_TIMEOUT, NanoHTTPD.MIME_PLAINTEXT, "Torrent download interrupted");
    }

    return response;
  }

  /**
   * Returns all indices of all pieces that are requested in range header in the form of Map.
   */
  private LinkedHashMap<Integer, Boolean> getRequiredPieceIndices(long[] range) {
    final LinkedHashMap<Integer, Boolean> indices = new LinkedHashMap<>();
    long start = range[0], end = range[1];

    while (start <= end) {
      final int pieceIndex = getPieceIndexOfByte(start);
      // Value here indicates if that piece has been downloaded
      indices.put(pieceIndex, false);
      start += getPieceLength();
    }

    return indices;
  }

  /**
   * Parses range header and return an array say arr where
   * arr[0] - start
   * arr[1] - end
   * arr[2] - total no. of bytes i.e end - start + 1
   */
  private long[] getRange(String header) {
    final long[] range = new long[] {0, -1, 0};
    final Torrent torrent = getTorrent();

    try {
      if (header.startsWith("bytes=")) {
        header = header.substring("bytes=".length());
        int separatorIndex = header.indexOf("-");
        if (separatorIndex > 0) {
          range[0] = Long.parseLong(header.substring(0, separatorIndex));
          range[1] = Long.parseLong(header.substring(separatorIndex + 1));
        }
      }
    } catch (NumberFormatException e) {
      // Ignore Error
    }

    long fileLen = torrent.getVideoFile().length();
    if (range[1] >= fileLen) {
      range[1] = fileLen - 1;
    }

    // if range end not specified then lets send next 10 pieces
    if (range[1] == -1) {
      range[1] = Math.min(range[0] + getPieceLength() * 10 - 1, fileLen - 1);
    }

    range[2] = range[1] - range[0] + 1;
    return range;
  }

  private int getPieceIndexOfByte(long bytes) {
    return (int)(bytes / getPieceLength());
  }

  private long getPieceLength() {
    final TorrentHandle th = getTorrentHandle();
    return (long)th.torrentFile().pieceLength();
  }

  private Torrent getTorrent() {
    return stream.getCurrentTorrent();
  }

  private TorrentHandle getTorrentHandle() {
    return getTorrent().getTorrentHandle();
  }

  private class Waiter extends Thread {
    private CountDownLatch latch;
    private LinkedHashMap<Integer, Boolean> pieces;

    Waiter(CountDownLatch latch, LinkedHashMap<Integer, Boolean> pieces) {
      this.latch = latch;
      this.pieces = pieces;
    }

    @Override
    public void run() {
      final TorrentHandle th = getTorrentHandle();
      final Timer timer = new Timer();
      // TODO Add alert listener to SessionManager to get notified of [PieceDownloaded] alert
      timer.scheduleAtFixedRate(new TimerTask() {
        @Override
        public void run() {
          boolean allPiecesDownloaded = true;
          for(LinkedHashMap.Entry<Integer, Boolean> entry: pieces.entrySet()) {
            final int piece = entry.getKey();
            final boolean isDownloaded = entry.getValue();

            if (!isDownloaded) {
              if (th.havePiece(piece)) {
                pieces.put(piece, true);
              } else {
                allPiecesDownloaded = false;
                break;
              }
            }
          }
          if (allPiecesDownloaded) {
            latch.countDown();
            timer.cancel();
          }
        }
      }, 0, 3000);
    }
  }
}
