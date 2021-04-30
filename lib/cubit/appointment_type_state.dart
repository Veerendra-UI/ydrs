part of 'appointment_type_cubit.dart';
class AppointmentTypeCubitState extends BaseBlocState {
  final bool isLoading;
  final String errorMsg;
  final List<AppointmentTypeList> documentType;

  factory AppointmentTypeCubitState.initial() => AppointmentTypeCubitState(
    errorMsg: null,
    isLoading:false,
    documentType:null,
  );
  AppointmentTypeCubitState reset() => AppointmentTypeCubitState.initial();

  AppointmentTypeCubitState({
    this.isLoading=false,
    this.documentType,
    this.errorMsg,
  });

  List<Object> get props => [
    this.isLoading,
    this.errorMsg,
    this.documentType,
  ];

  AppointmentTypeCubitState copyWith(
      {
        bool isLoading,
        String errorMsg,
        List<AppointmentTypeList> documentType
      }
      )
  {
    return new AppointmentTypeCubitState(
      isLoading: isLoading ?? this.isLoading,
      errorMsg: errorMsg ?? this.errorMsg,
      documentType: documentType ?? this.documentType,
    );
  }

  @override
  String toString() {
    return 'DocumentTypeCubitState{isLoading: $isLoading, errorMsg: $errorMsg, documentType: $documentType}';
  }
}