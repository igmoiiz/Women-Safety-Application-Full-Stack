part of 'register_pages_bloc.dart';

@immutable
sealed class RegisterPagesEvent {}

class GoToPage1 extends RegisterPagesEvent {}

class GoToPage2 extends RegisterPagesEvent {}

class GoToPage3 extends RegisterPagesEvent {}

class GoToPage4 extends RegisterPagesEvent {}
