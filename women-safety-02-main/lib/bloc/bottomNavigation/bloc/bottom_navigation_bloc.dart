import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'bottom_navigation_event.dart';
part 'bottom_navigation_state.dart';

class BottomNavigationBloc
    extends Bloc<BottomNavigationEvent, BottomNavigationState> {
  BottomNavigationBloc() : super(HomeIconState()) {
    // Set initial state to HomeIconState
    on<BottomNavigationEvent>((event, emit) {
      if (event is HomeIconTapped) {
        emit(HomeIconState());
      } else if (event is AddIconTapped) {
        emit(AddIconState());
      } else if (event is SOSIconTapped) {
        emit(SOSIconState());
      } else if (event is BubbleIconTapped) {
        emit(BubbleIconState());
      } else if (event is PersonIconTapped) {
        emit(PersonIconState());
      }
    });
  }
}
