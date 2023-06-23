import 'dart:io';
import 'package:dio/dio.dart' as http;
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'dart:convert';
import 'controller_ws.dart';

class ServeHandler {
  var controller = ControllerWs();
  final corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'POST, GET, PUT, DELETE',
    'Access-Control-Allow-Headers': 'Origin, Content-Type',
  };

  Handler get handler {
    final router = Router();
    final dio = http.Dio();

    router.post("/solicitar", (Request req) async {
      var result = await req.readAsString();
      Map json = jsonDecode(result);
      var jsonMessage = jsonEncode(json);
      var slug = json["slug"] ?? "";

      if (slug != "" && ControllerWs.connections.isNotEmpty) {
        bool contains = controller.containsId(slug);
        if (contains != false) {
          controller.sendSolicitacao(
              ControllerWs.connections, jsonMessage.toString(), slug);
          return Response.ok("Sucesso solicitação enviada",
              headers: corsHeaders);
        } else {
          return Response.forbidden(
              "Error O slug: $slug Não Está conectado ao Websocket",
              headers: corsHeaders);
        }
      } else {
        return Response.forbidden("Error (idSend não enviado)",
            headers: corsHeaders);
      }
    });

    router.post("/send_message", (Request req) async {
      var result = await req.readAsString();
      Map json = jsonDecode(result);
      var id = json["id"] ?? "";
      var message = json["message"] ?? "";
      var key = json["key"] ?? "";
      if (message != "") {
        try {
          dio.post("http://95.111.254.20:3132/message/text?key=$key",
              options:
                  http.Options(headers: {"Content-Type": "application/json"}),
              data: {"id": id, "message": message});
          return Response.ok("Mensagem enviada com Sucesso",
              headers: corsHeaders);
        } on Exception catch (_) {
          await Process.run(
              'sudo', ['supervisorctl', 'restart', 'whatsapp-node']);
          return Response.forbidden(
              "Error ao enviar mensagem, tente novamente daqui há alguns segundos",
              headers: corsHeaders);
        }
      } else {
        return Response.forbidden("Error ao enviar mensagem",
            headers: corsHeaders);
      }
    });

    return router;
  }
}
