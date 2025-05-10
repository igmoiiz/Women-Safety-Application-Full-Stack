part of 'bottom_navigation_bloc.dart';

@immutable
sealed class BottomNavigationState {}

final class BottomNavigationInitial extends BottomNavigationState {}

final class HomeIconState extends BottomNavigationState {}

final class AddIconState extends BottomNavigationState {}

final class SOSIconState extends BottomNavigationState {}

final class BubbleIconState extends BottomNavigationState {}

final class PersonIconState extends BottomNavigationState {}
