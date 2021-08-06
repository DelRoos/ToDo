import 'package:boilerplate/stores/error/error_store.dart';
import 'package:mobx/mobx.dart';
import 'package:validators/validators.dart';

part 'form_store.g.dart';

class FormStore = _FormStore with _$FormStore;

abstract class _FormStore with Store {
  // store for handling form errors
  final FormErrorStore formErrorStore = FormErrorStore();

  // store for handling error messages
  final ErrorStore errorStore = ErrorStore();

  _FormStore() {
    _setupValidations();
  }

  // disposers:-----------------------------------------------------------------
  late List<ReactionDisposer> _disposers;

  void _setupValidations() {
    _disposers = [
      reaction((_) => userName, validateUserName),
      reaction((_) => userEmail, validateUserEmail),
      reaction((_) => password, validatePassword),
      reaction((_) => userProfile, validateUserProfile),
      reaction((_) => confirmPassword, validateConfirmPassword),
    ];
  }

  // store variables:-----------------------------------------------------------
  // @observable
  // late PickedFile imageFile;

  @observable
  String userProfile = '';

  @observable
  String userEmail = '';

  @observable
  String userName = '';

  @observable
  String password = '';

  @observable
  String confirmPassword = '';

  @observable
  bool success = false;

  @observable
  bool loading = false;

  @computed
  bool get canLogin =>
      !formErrorStore.hasErrorsInLogin &&
      userEmail.isNotEmpty &&
      password.isNotEmpty;

  @computed
  bool get canRegister =>
      !formErrorStore.hasErrorsInRegister &&
      userProfile.isNotEmpty &&
      userName.isNotEmpty &&
      userEmail.isNotEmpty &&
      password.isNotEmpty &&
      confirmPassword.isNotEmpty;

  @computed
  bool get canForgetPassword =>
      !formErrorStore.hasErrorInForgotPassword && userEmail.isNotEmpty;

  // actions:-------------------------------------------------------------------
  @action
  void setUserProfile(String value) {
    userProfile = value;
  }

  @action
  void setUserId(String value) {
    userEmail = value;
  }

  @action
  void setUserName(String value) {
    userName = value;
  }

  @action
  void setPassword(String value) {
    password = value;
  }

  @action
  void setConfirmPassword(String value) {
    confirmPassword = value;
  }

  // @action
  // void setImageFile(PickedFile pickedFile) {
  //   imageFile = pickedFile;
  // }

  @action
  void validateUserProfile(String value) {
    if (value.isEmpty) {
      formErrorStore.userProfile = "Email can't be empty";
    } else {
      formErrorStore.userProfile = null;
    }
  }

  @action
  void validateUserEmail(String value) {
    if (value.isEmpty) {
      formErrorStore.userEmail = "Email can't be empty";
    } else if (!isEmail(value)) {
      formErrorStore.userEmail = 'Please enter a valid email address';
    } else {
      formErrorStore.userEmail = null;
    }
  }

  @action
  void validateUserName(String value) {
    if (value.isEmpty) {
      formErrorStore.userName = "Name can't be empty";
    } else if (value.length < 3) {
      formErrorStore.userName = "Name must be at-least 6 characters long";
    } else {
      formErrorStore.userName = null;
    }
  }

  @action
  void validatePassword(String value) {
    if (value.isEmpty) {
      formErrorStore.password = "Password can't be empty";
    } else if (value.length < 6) {
      formErrorStore.password = "Password must be at-least 6 characters long";
    } else {
      formErrorStore.password = null;
    }
  }

  @action
  void validateConfirmPassword(String value) {
    if (value.isEmpty) {
      formErrorStore.confirmPassword = "Confirm password can't be empty";
    } else if (value != password) {
      formErrorStore.confirmPassword = "Password doen't match";
    } else {
      formErrorStore.confirmPassword = null;
    }
  }

  @action
  Future register() async {
    loading = true;
  }

  @action
  Future login() async {
    loading = true;

    Future.delayed(Duration(milliseconds: 2000)).then((future) {
      loading = false;
      success = true;
    }).catchError((e) {
      loading = false;
      success = false;
      errorStore.errorMessage = e.toString().contains("ERROR_USER_NOT_FOUND")
          ? "Username and password doesn't match"
          : "Something went wrong, please check your internet connection and try again";
      print(e);
    });
  }

  @action
  Future forgotPassword() async {
    loading = true;
  }

  @action
  Future logout() async {
    loading = true;
  }

  // general methods:-----------------------------------------------------------
  void dispose() {
    for (final d in _disposers) {
      d();
    }
  }

  void validateAll() {
    validateUserName(userName);
    validatePassword(password);
    validateUserEmail(userEmail);
    validateConfirmPassword(confirmPassword);
    validateUserProfile(userProfile);
  }
}

class FormErrorStore = _FormErrorStore with _$FormErrorStore;

abstract class _FormErrorStore with Store {
  // @observable
  // PickedFile? imageFile;

  @observable
  String? userProfile;

  @observable
  String? userEmail;

  @observable
  String? userName;

  @observable
  String? password;

  @observable
  String? confirmPassword;

  @computed
  bool get hasErrorsInLogin => userEmail != null || password != null;

  @computed
  bool get hasErrorsInRegister =>
      userProfile != null ||
      userName != null ||
      userEmail != null ||
      password != null ||
      confirmPassword != null;

  @computed
  bool get hasErrorInForgotPassword => userEmail != null;
}
