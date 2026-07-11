import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class OtpSentSuccess extends AuthState {
  final String verificationId;

  const OtpSentSuccess({required this.verificationId});

  @override
  List<Object> get props => [verificationId]; // Equatable
}

class AuthSuccess extends AuthState {}

class AuthError extends AuthState {
  final String errorMessage;

  const AuthError({required this.errorMessage});

  @override
  List<Object> get props => [errorMessage];
}