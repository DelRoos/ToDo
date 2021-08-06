import 'dart:io';

import 'package:another_flushbar/flushbar_helper.dart';
import 'package:boilerplate/constants/assets.dart';
import 'package:boilerplate/constants/colors.dart';
import 'package:boilerplate/data/sharedpref/constants/preferences.dart';
import 'package:boilerplate/stores/form/form_store.dart';
import 'package:boilerplate/stores/theme/theme_store.dart';
import 'package:boilerplate/utils/device/device_utils.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:boilerplate/utils/routes/routes.dart';
// import 'package:boilerplate/widgets/app_icon_widget.dart';
import 'package:boilerplate/widgets/empty_app_bar_widget.dart';
import 'package:boilerplate/widgets/progress_indicator_widget.dart';
import 'package:boilerplate/widgets/rounded_button_widget.dart';
import 'package:boilerplate/widgets/textfield_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterScreen extends StatefulWidget {
  // const RegisterScreen({ Key? key }) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  //text controllers:-----------------------------------------------------------
  TextEditingController _userEmailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _userNameController = TextEditingController();
  TextEditingController _passwordConfirmController = TextEditingController();
  // final ImagePicker _picker = ImagePicker();
  // late PickedFile _imageFile;
  // var _image;
  var imagePicker;
  var type;

  //stores:---------------------------------------------------------------------
  late ThemeStore _themeStore;

  //focus node:-----------------------------------------------------------------
  late FocusNode _passwordFocusNode;

  //stores:---------------------------------------------------------------------
  final _store = FormStore();

  @override
  void initState() {
    super.initState();
    _passwordFocusNode = FocusNode();
    imagePicker = ImagePicker();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _themeStore = Provider.of<ThemeStore>(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      primary: true,
      appBar: EmptyAppBar(),
      body: _buildBody(),
    );
  }

  // body methods:--------------------------------------------------------------
  Widget _buildBody() {
    return Material(
      child: Stack(
        children: <Widget>[
          MediaQuery.of(context).orientation == Orientation.landscape
              ? Row(
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: _buildLeftSide(),
                    ),
                    Expanded(
                      flex: 1,
                      child: _buildRightSide(context),
                    ),
                  ],
                )
              : Center(child: _buildRightSide(context)),
          Observer(
            builder: (context) {
              return _store.success
                  ? navigate(context)
                  : _showErrorMessage(_store.errorStore.errorMessage);
            },
          ),
          Observer(
            builder: (context) {
              return Visibility(
                visible: _store.loading,
                child: CustomProgressIndicatorWidget(),
              );
            },
          )
        ],
      ),
    );
  }

  Widget _buildLeftSide() {
    return SizedBox.expand(
      child: Image.asset(
        Assets.carBackground,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildRightSide(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // AppIconWidget(image: 'assets/icons/ic_appicon.png'),
            SizedBox(height: 24.0),
            _uploadImage(context),
            SizedBox(height: 24.0),
            _buildUserNameIdField(),
            _buildUserIdField(),
            _buildPasswordField(),
            _buildPasswordConfirmField(),
            SizedBox(
              height: 50,
            ),
            _buildSignUpButton(),
            _buildSignInButton(),
          ],
        ),
      ),
    );
  }

  void takePhoto(ImageSource source) async {
    XFile image = await imagePicker.pickImage(
      source: source,
      imageQuality: 50,
      preferredCameraDevice: CameraDevice.front,
    );
    setState(() {
      print(image.path);
      // _image = File();
      _store.setUserProfile(image.path);
    });
  }

  Widget _uploadImage(BuildContext context) {
    return Center(
        child: Stack(
      children: <Widget>[
        CircleAvatar(
          radius: 80.0,
          backgroundImage: _store.userProfile.isEmpty
              ? AssetImage('assets/icons/ic_appicon.png')
              : Image.file(
                  File(_store.userProfile),
                  fit: BoxFit.cover,
                ).image,
        ),
        Positioned(
          bottom: 20.0,
          right: 20.0,
          child: InkWell(
            child: Icon(
              Icons.camera_alt,
              color: AppColors.orange[500],
              size: 40.0,
            ),
            onTap: () {
              showModalBottomSheet(
                  context: context,
                  builder: ((builder) => _bottomSheet(context)));
            },
          ),
        ),
      ],
    ));
  }

  Widget _bottomSheet(BuildContext context) {
    return Container(
      height: 100.0,
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 20,
      ),
      child: Column(
        children: <Widget>[
          Text(
            AppLocalizations.of(context).translate('user_profile'),
            style: TextStyle(fontSize: 20.0),
          ),
          SizedBox(
            height: 20.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              FlatButton.icon(
                onPressed: () {
                  takePhoto(ImageSource.camera);
                  Navigator.of(context).pop();
                },
                icon: Icon(Icons.camera),
                label: Text("Camera"),
              ),
              FlatButton.icon(
                onPressed: () {
                  takePhoto(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
                icon: Icon(Icons.image),
                label: Text("Gallery"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserNameIdField() {
    return Observer(
      builder: (context) {
        return TextFieldWidget(
          hint: AppLocalizations.of(context).translate('login_et_user_name'),
          inputType: TextInputType.name,
          icon: Icons.person,
          iconColor: _themeStore.darkMode ? Colors.white70 : Colors.black54,
          textController: _userNameController,
          inputAction: TextInputAction.next,
          autoFocus: false,
          onChanged: (value) {
            _store.setUserName(_userNameController.text);
          },
          onFieldSubmitted: (value) {
            FocusScope.of(context).requestFocus(_passwordFocusNode);
          },
          errorText: _store.formErrorStore.userName,
        );
      },
    );
  }

  Widget _buildUserIdField() {
    return Observer(
      builder: (context) {
        return TextFieldWidget(
          hint: AppLocalizations.of(context).translate('login_et_user_email'),
          inputType: TextInputType.emailAddress,
          icon: Icons.email,
          iconColor: _themeStore.darkMode ? Colors.white70 : Colors.black54,
          textController: _userEmailController,
          inputAction: TextInputAction.next,
          autoFocus: false,
          onChanged: (value) {
            _store.setUserId(_userEmailController.text);
          },
          onFieldSubmitted: (value) {
            FocusScope.of(context).requestFocus(_passwordFocusNode);
          },
          errorText: _store.formErrorStore.userEmail,
        );
      },
    );
  }

  Widget _buildPasswordField() {
    return Observer(
      builder: (context) {
        return TextFieldWidget(
          hint:
              AppLocalizations.of(context).translate('login_et_user_password'),
          isObscure: true,
          padding: EdgeInsets.only(top: 16.0),
          icon: Icons.lock,
          iconColor: _themeStore.darkMode ? Colors.white70 : Colors.black54,
          textController: _passwordController,
          focusNode: _passwordFocusNode,
          errorText: _store.formErrorStore.password,
          onChanged: (value) {
            _store.setPassword(_passwordController.text);
          },
        );
      },
    );
  }

  Widget _buildPasswordConfirmField() {
    return Observer(
      builder: (context) {
        return TextFieldWidget(
          hint: AppLocalizations.of(context)
              .translate('login_et_user_confirm_password'),
          isObscure: true,
          padding: EdgeInsets.only(top: 16.0),
          icon: Icons.confirmation_num,
          iconColor: _themeStore.darkMode ? Colors.white70 : Colors.black54,
          textController: _passwordConfirmController,
          // focusNode: _passwordFocusNode,
          errorText: _store.formErrorStore.confirmPassword,
          onChanged: (value) {
            _store.setConfirmPassword(_passwordConfirmController.text);
          },
        );
      },
    );
  }

  Widget _buildSignUpButton() {
    return RoundedButtonWidget(
      buttonText: 'Sign Up',
      buttonColor: Colors.orangeAccent,
      textColor: Colors.white,
      // padding: ,
      onPressed: () async {
        if (_store.canLogin) {
          DeviceUtils.hideKeyboard(context);
          _store.login();
        } else {
          _showErrorMessage('Please fill in all fields');
        }
      },
    );
  }

  Widget _buildSignInButton() {
    return RoundedButtonWidget(
      buttonText: AppLocalizations.of(context).translate('login_btn_sign_in'),
      // buttonText: AppLocalizations.of(context).translate('login_btn_sign_in'),
      buttonColor: Colors.black87,
      textColor: Colors.white,
      onPressed: () {
        Navigator.of(context).pushNamedAndRemoveUntil(
            Routes.login, (Route<dynamic> route) => false);
        print('salut a tous');
      },
    );
  }

  Widget navigate(BuildContext context) {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool(Preferences.is_logged_in, true);
    });

    Future.delayed(Duration(milliseconds: 0), () {
      Navigator.of(context).pushNamedAndRemoveUntil(
          Routes.home, (Route<dynamic> route) => false);
    });

    return Container();
  }

  // General Methods:-----------------------------------------------------------
  _showErrorMessage(String message) {
    if (message.isNotEmpty) {
      Future.delayed(Duration(milliseconds: 0), () {
        if (message.isNotEmpty) {
          FlushbarHelper.createError(
            message: message,
            title: AppLocalizations.of(context).translate('home_tv_error'),
            duration: Duration(seconds: 3),
          )..show(context);
        }
      });
    }

    return SizedBox.shrink();
  }

  // dispose:-------------------------------------------------------------------
  @override
  void dispose() {
    // Clean up the controller when the Widget is removed from the Widget tree
    _userNameController.dispose();
    _userEmailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Container(
  //       child: Text("page de login",
  //           style: TextStyle(fontWeight: FontWeight.w800)));
  // }
}
