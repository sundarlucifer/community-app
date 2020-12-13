import 'package:community_app/services/auth_service.dart';
import 'package:community_app/utils/drawer.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  static const TAG = 'profile-screen';

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isLoading = false;
  String _errorMsg = '';

  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = authService.user.displayName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: MyDrawer(),
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(12.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Display Name',
                  ),
                  minLines: 1,
                  maxLines: 1,
                  maxLength: 20,
                  validator: (value) => value.isEmpty ? 'Enter Name' : null,
                  controller: _nameController,
                  keyboardType: TextInputType.name,
                ),
                SizedBox(height: 20.0),
                Text(_errorMsg, style: TextStyle(color: Colors.red)),
                OutlineButton(
                  child: Container(
                    width: double.infinity,
                    child: Center(child: Text('Save Profile')),
                  ),
                  onPressed: () => _submit(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _submit(context) {
    if (!_formKey.currentState.validate()) {
      return;
    }
    setState(() => _isLoading = true);
    authService.updateDisplayName(_nameController.text).then((ref) {
      // Navigator.pop(context);
      setState(() => _isLoading = false);
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text('Profile saved'),
      ));
    });
  }
}
