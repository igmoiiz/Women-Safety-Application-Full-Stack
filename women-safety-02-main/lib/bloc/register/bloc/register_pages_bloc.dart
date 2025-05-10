import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'register_pages_event.dart';
part 'register_pages_state.dart';

class RegisterPagesBloc extends Bloc<RegisterPagesEvent, RegisterPagesState> {
  RegisterPagesBloc() : super(RegisterPage1()) {
    on<GoToPage1>((event, emit) {
      emit(RegisterPage1());
    });
    on<GoToPage2>((event, emit) {
      emit(RegisterPage2());
    });
    on<GoToPage3>((event, emit) {
      emit(RegisterPage3());
    });
    on<GoToPage4>((event, emit) {
      emit(RegisterPage4());
    });
  }
}
