import 'package:equatable/equatable.dart';

abstract class TipsEvent extends Equatable {
  const TipsEvent();

  @override
  List<Object> get props => [];
}

// Event ini dipicu saat layar Tips pertama kali dibuka atau di-refresh
class FetchTipsRequested extends TipsEvent {}