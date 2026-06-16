import 'package:equatable/equatable.dart';
import 'package:flextime_mobile/data/models/tips/tips_model.dart';

abstract class TipsState extends Equatable {
  const TipsState();
  
  @override
  List<Object> get props => [];
}

class TipsInitial extends TipsState {}

class TipsLoading extends TipsState {}

class TipsLoaded extends TipsState {
  final List<TipsModel> tips; 
  const TipsLoaded(this.tips);

  @override
  List<Object> get props => [tips];
}

class TipsError extends TipsState {
  final String message;

  const TipsError(this.message);

  @override
  List<Object> get props => [message];
}