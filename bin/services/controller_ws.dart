import 'dart:async';
import 'dart:io';

class ControllerWs {
  static List<ClientWS> connections = [];

  void addOrUpdateClient({required String idSave, required WebSocket webSocket}) {
    // Verifica se o idSave é válido
    if (idSave != "") {
      // Procura pelo cliente com o id desejado
      int index = _getClientIndexById(idSave);
      // Se o cliente existe, atualiza os dados
      if (index != -1) {
        var updatedClient = ClientWS(id: idSave, webSocket: webSocket);
        connections[index] = updatedClient;
      }
      // Se o cliente não existe, adiciona um novo cliente
      else {
        var newClient = ClientWS(id: idSave, webSocket: webSocket);
        connections.add(newClient);
      }
    }
  }

  int _getClientIndexById(String id) {
    for (int i = 0; i < connections.length; i++) {
      if (connections[i].id == id) {
        return i;
      }
    }
    return -1;
  }

  bool containsId(String id) {
    bool idExist = connections.any((i) => i.id == id);
    return idExist;
  }

  Future<void> sendSolicitacao(
    List<ClientWS> connections,
    String data,
    String idSend,
  ) async {
    final client = connections.firstWhere((cliente) => cliente.id == idSend);
    var conectado = client.webSocket.closeCode;
    if (conectado == null) {
      client.webSocket.add(data);
    } else {
      Timer timer = Timer.periodic(Duration(seconds: 3), (timer) {
        final clientReconnect = connections.firstWhere((cliente) => cliente.id == idSend);
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
  final String id;
  final WebSocket webSocket;

  ClientWS({
    required this.id,
    required this.webSocket,
  });

  @override
  String toString() => 'ClientWS(id: $id, webSocket: $webSocket)';
}
