import 'package:community_app/services/auth_service.dart';
import 'package:flutter/material.dart';

class PostForm extends StatefulWidget {
  @override
  _PostFormState createState() => _PostFormState();
}

class _PostFormState extends State<PostForm> {
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  String _errorMsg = '';

  final _contentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          'Create new post',
          style:
              TextStyle(color: Theme.of(context).primaryColor, fontSize: 28.0),
        ),
        centerTitle: true,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Content',
                        ),
                        minLines: 1,
                        maxLines: 50,
                        maxLength: 300,
                        validator: (value) =>
                            value.isEmpty ? 'Enter content' : null,
                        controller: _contentController,
                        keyboardType: TextInputType.multiline,
                      ),
                      SizedBox(height: 20.0),
                      Text(_errorMsg, style: TextStyle(color: Colors.red)),
                      OutlineButton(
                        child: Container(
                          width: double.infinity,
                          child: Center(child: Text('Post')),
                        ),
                        onPressed: _submit,
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  _submit() {
    if (!_formKey.currentState.validate()) {
      return;
    }
    setState(() => _isLoading = true);
    authService
        .createPost(_contentController.text)
        .then((ref) {
      if (ref != null)
        Navigator.pop(context);
      else
        setState(() => _errorMsg = 'Network error');
    });
  }
}
