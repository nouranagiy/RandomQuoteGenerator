import 'dart:async';
import 'dart:io';

import 'debug_log.dart';

Future<void> diagnoseConnectivity(Uri uri) async {
  if (Platform.environment.containsKey('FLUTTER_TEST')) return;
  final host = uri.host;
  final port = uri.scheme == 'https' ? 443 : 80;
  try {
    final dns = Stopwatch()..start();
    final addresses = await InternetAddress.lookup(
      host,
    ).timeout(const Duration(seconds: 5));
    debugLog(
      'DictionaryApi',
      'DIAG DNS resolved "$host" in ${dns.elapsedMilliseconds} ms -> '
          '${addresses.map((a) => a.address).toList()}',
    );

    Socket? socket;
    Object? lastError;
    for (final address in addresses) {
      try {
        final tcp = Stopwatch()..start();
        socket = await Socket.connect(
          address,
          port,
          timeout: const Duration(seconds: 5),
        );
        debugLog(
          'DictionaryApi',
          'DIAG TCP connected to ${socket.remoteAddress.address}:${socket.remotePort} '
              'in ${tcp.elapsedMilliseconds} ms',
        );
        break;
      } catch (e) {
        lastError = e;
        debugLog(
          'DictionaryApi',
          'DIAG TCP failed for ${address.address}:$port: $e',
        );
      }
    }
    socket?.destroy();
    if (socket == null) {
      debugLog(
        'DictionaryApi',
        'DIAG no address accepted a TCP connection for "$host": $lastError',
      );
      return;
    }
    debugLog(
      'DictionaryApi',
      'DIAG TCP reachable for "$host"; the dictionary stall is above the TCP layer '
          '(TLS handshake or the remote server never sent response bytes)',
    );
  } on TimeoutException catch (e) {
    debugLog(
      'DictionaryApi',
      'DIAG probe timed out resolving/connecting to "$host": $e',
    );
  } on SocketException catch (e) {
    debugLog('DictionaryApi', 'DIAG probe failed for "$host": ${e.message}');
  } catch (e) {
    debugLog('DictionaryApi', 'DIAG probe unexpected error for "$host": $e');
  }
}
