import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'dart:convert';

import 'controller_ws.dart';

class ServeHandler {
  var controller = ControllerWs();

  Handler get handler {
    final router = Router();

    router.post("/solicitar", (Request req) async {
      var result = await req.readAsString();
      Map json = jsonDecode(result);
      var jsonMessage = jsonEncode(json);
      var idSend = json["idSend"] ?? "";

      if (idSend != "" && ControllerWs.connections.isNotEmpty) {
        bool contains = controller.containsId(idSend);
        if (contains != false) {
          controller.sendSolicitacao(ControllerWs.connections, jsonMessage.toString(), idSend);
          return Response.ok("Sucesso solicitação ennviada");
        } else {
          return Response.forbidden("Error O id: $idSend Não Está conectado ao Websocket");
        }
      } else {
        return Response.forbidden("Error (idSend não enviado)");
      }
    });
    return router;
  }
}