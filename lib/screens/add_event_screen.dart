import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:community_app/services/auth_service.dart';
import 'package:flutter/material.dart';

class EventForm extends StatefulWidget {
  @override
  _EventFormState createState() => _EventFormState();
}

class _EventFormState extends State<EventForm> {
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  String _errorMsg = '';

  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  DateTime _date = DateTime.now().add(Duration(days: 1));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          'Post new event',
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
                  decoration: InputDecoration(labelText: 'Title'),
                  maxLength: 30,
                  validator: (value) => value.isEmpty ? 'Enter a title' : null,
                  controller: _titleController,
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Content',
                  ),
                  maxLines: 10,
                  maxLength: 100,
                  validator: (value) => value.isEmpty ? 'Enter content' : null,
                  controller: _contentController,
                ),
                _getDateField(),
                SizedBox(height: 20.0),
                Text(_errorMsg),
                OutlineButton(
                  child: Container(
                    width: double.infinity,
                    child: Center(child: Text('Post event')),
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

  _getDateField() {
    return GestureDetector(
      onTap: () => _showDatePicker(),
      child: Row(
        children: [
          Text(
            'Date',
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w300),
          ),
          SizedBox(
            width: 40.0,
          ),
          Text(
            _date.toString().substring(0, 10),
          ),
        ],
      ),
    );
  }

  _showDatePicker() {
    showDatePicker(
            context: context,
            initialDate: DateTime.now().add(Duration(days: 1)),
            firstDate: DateTime.now().add(Duration(days: 1)),
            lastDate: DateTime.now().add(Duration(days: 365)))
        .then((date) {
      setState(() {
        _date = date ?? DateTime.now().add(Duration(days: 1));
      });
    });
  }

  _submit() {
    if(!_formKey.currentState.validate()) {
      return;
    }
    setState(() => _isLoading = true);
    authService.postEvent(_titleController.text, _contentController.text, Timestamp.fromDate(_date)).then((ref) {
      if(ref != null)
        Navigator.pop(context);
      else
        setState(() => _errorMsg = 'Network error');
    });
  }
}
