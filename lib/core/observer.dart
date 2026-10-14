import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';

class AppBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    log('🟢 [CREATE] ${bloc.runtimeType} was created');
  }

  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    log('⚡ [EVENT] ${bloc.runtimeType} => $event');
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    log('🔄 [CHANGE] ${bloc.runtimeType} => $change');
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    log(
      '🚀 [TRANSITION] ${bloc.runtimeType} | '
      'event: ${transition.event} | '
      'from: ${transition.currentState} | '
      'to: ${transition.nextState}',
    );
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    log('❌ [ERROR] ${bloc.runtimeType} => $error');
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    log('🔴 [CLOSE] ${bloc.runtimeType} was closed');
  }
}
