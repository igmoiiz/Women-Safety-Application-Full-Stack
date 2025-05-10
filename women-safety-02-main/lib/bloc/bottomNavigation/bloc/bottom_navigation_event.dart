part of 'bottom_navigation_bloc.dart';

@immutable
sealed class BottomNavigationEvent {}

class HomeIconTapped extends BottomNavigationEvent {}

class AddIconTapped extends BottomNavigationEvent {}

class SOSIconTapped extends BottomNavigationEvent {}

class BubbleIconTapped extends BottomNavigationEvent {}

class PersonIconTapped extends BottomNavigationEvent {}
