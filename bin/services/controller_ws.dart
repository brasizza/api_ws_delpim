import 'dart:async';
import 'dart:io';

class ControllerWs {
  static List<ClientWS> connections = [];

  void addOrUpdateClient({required String slug, required WebSocket webSocket}) {
    // Verifica se o idSave é válido
    if (slug != "") {
      // Procura pelo cliente com o id desejado
      int index = _getClientIndexById(slug);
      // Se o cliente existe, atualiza os dados
      if (index != -1) {
        var updatedClient = ClientWS(slug: slug, webSocket: webSocket);
        connections[index] = updatedClient;
      }
      // Se o cliente não existe, adiciona um novo cliente
      else {
        var newClient = ClientWS(slug: slug, webSocket: webSocket);
        connections.add(newClient);
      }
    }
  }

  int _getClientIndexById(String id) {
    for (int i = 0; i < connections.length; i++) {
      if (connections[i].slug == id) {
        return i;
      }
    }
    return -1;
  }

  bool containsId(String id) {
    bool idExist = connections.any((i) => i.slug == id);
    return idExist;
  }

  Future<void> sendSolicitacao(
    List<ClientWS> connections,
    String data,
    String slug,
  ) async {
    final client = connections.firstWhere((cliente) => cliente.slug == slug);
    var conectado = client.webSocket.closeCode;
    if (conectado == null) {
      client.webSocket.add(data);
    } else {
      Timer timer = Timer.periodic(Duration(seconds: 3), (timer) {
        final clientReconnect = connections.firstWhere((cliente) => cliente.slug == slug);
        if (clientReconnect.webSocket.closeCode == null) {
          clientReconnect.webSocket.add(data);
          print("data: $data");
          timer.cancel();
        }
      });
      Future.delayed(Duration(seconds: 40), () {
        timer.cancel();
      });
    }
  }
}

class ClientWS {
  final String slug;
  final WebSocket webSocket;

  ClientWS({
    required this.slug,
    required this.webSocket,
  });

  @override
  String toString() => 'ClientWS(slug: $slug, webSocket: $webSocket)';
}
