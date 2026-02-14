import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connectivity_service.g.dart';

enum NetworkStatus { online, offline }

@riverpod
Stream<NetworkStatus> networkStatus(NetworkStatusRef ref) async* {
  final connectivity = Connectivity();
  final checker = InternetConnectionChecker();

  // 1. Estado inicial
  yield await _checkStatus(connectivity, checker);

  // 2. Escuta mudanças
  await for (final result in connectivity.onConnectivityChanged) {
    yield await _checkStatus(connectivity, checker, result);
  }
}

Future<NetworkStatus> _checkStatus(
  Connectivity connectivity,
  InternetConnectionChecker checker, [
  ConnectivityResult? resultFromStream,
]) async {
  // Se veio do Stream, usa ele. Se não, busca o atual.
  final result = resultFromStream ?? await connectivity.checkConnectivity();
  
  if (result == ConnectivityResult.none) {
    return NetworkStatus.offline;
  }
  // ---------------------

  // Verificação real de dados (Ping)
  // Nota: InternetConnectionChecker pode demorar um pouco, 
  // em apps reais idealmente usamos um timeout aqui.
  final hasInternet = await checker.hasConnection;
  return hasInternet ? NetworkStatus.online : NetworkStatus.offline;
}