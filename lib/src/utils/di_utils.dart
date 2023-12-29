import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

T get<T extends Object>({
  String? instanceName,
}) {
  return getIt.get<T>(instanceName: instanceName);
}

Future<T> getAsync<T extends Object>({
  String? instanceName,
}) {
  return getIt.getAsync<T>(instanceName: instanceName);
}

T registerSingleton<T extends Object>(
  T value, {
  String? instanceName,
}) {
  return getIt.registerSingleton<T>(
    value,
    instanceName: instanceName,
  );
}

void registerLazySingleton<T extends Object>(
  T Function<T>() factoryFunc, {
  String? instanceName,
}) {
  return getIt.registerLazySingleton<T>(
    factoryFunc,
    instanceName: instanceName,
  );
}
