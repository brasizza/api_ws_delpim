// ignore_for_file: no_leading_underscores_for_local_identifiers, unused_import
// https://github.com/Delpim-Automacao/api_ws_delpim
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'dart:convert';
import 'dart:io' as io;
import 'services/server_handler.dart';
import 'services/controller_ws.dart';
import 'package:dotenv/dotenv.dart';

void main() async {
  var env = DotEnv(includePlatformEnvironment: true)..load();
  String _ip = env["IP"].toString();
  int _portHttp = int.parse(env["PORTHTTP"] ?? "0");
  int _portWs = int.parse(env["PORTWS"] ?? "0");

  print("ip: $_ip, http: $_portHttp, ws: $_portWs, ");
  final controllerWs = ControllerWs();
  var _server = ServeHandler();
  final server = await shelf_io.serve(_server.handler, _ip, _portHttp);
  print("Nosso servidor foi iniciado http://localhost:$_portHttp");
//-----------------divisor < http e websocket >
  var serverWs = await io.HttpServer.bind(_ip, _portWs);
  print('Servidor iniciado na porta ws://localhost:$_portWs.');
  await for (io.HttpRequest request in serverWs) {
    if (io.WebSocketTransformer.isUpgradeRequest(request)) {
      io.WebSocket webSocket = await io.WebSocketTransformer.upgrade(request);

      webSocket.listen((data) async {
        var json = await jsonDecode(data);
        var idSave = json["idSave"];
        controllerWs.addOrUpdateClient(slug: idSave, webSocket: webSocket);
        print("Conexões atualizadas: ${ControllerWs.connections}");
      });
    } else {
      request.response.statusCode = io.HttpStatus.forbidden;
      request.response.reasonPhrase = 'WebSocket connections only';
      request.response.close();
    }
  }
}
