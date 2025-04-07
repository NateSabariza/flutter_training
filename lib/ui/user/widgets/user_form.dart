import 'package:flutter/material.dart';
import '../../../data/services/user_service.dart';

class UserFormScreen extends StatefulWidget {
  final int? userId;
  final String? initialEmail;
  final String? initialFirstName;
  final String? initialLastName;
  final String? initialAvatar;

  const UserFormScreen({
    super.key,
    this.userId,
    this.initialEmail,
    this.initialFirstName,
    this.initialLastName,
    this.initialAvatar,
  });

  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _emailController;
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _avatarController;
  late FocusNode _emailFocus;
  late FocusNode _firstNameFocus;
  late FocusNode _lastNameFocus;
  late FocusNode _avatarFocus;

  bool _isSubmitting = false;
  bool _emailHasError = false;
  bool _firstNameHasError = false;
  bool _lastNameHasError = false;
  bool _avatarHasError = false;


  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail ?? '');
    _firstNameController = TextEditingController(text: widget.initialFirstName ?? '');
    _lastNameController = TextEditingController(text: widget.initialLastName ?? '');
    _avatarController = TextEditingController(text: widget.initialAvatar ?? '');
    _emailFocus = FocusNode();
    _firstNameFocus = FocusNode();
    _lastNameFocus = FocusNode();
    _avatarFocus = FocusNode();

  }

  @override
  void dispose() {
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _avatarController.dispose();
    _emailFocus.dispose();
    _firstNameFocus.dispose();
    _lastNameFocus.dispose();
    _avatarFocus.dispose();

    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);

      final userData = {
        'email': _emailController.text.trim(),
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'avatar': _avatarController.text.trim(),
      };

      Map<String, dynamic>? response;

      if(widget.userId != null){
        response = await _userService.updateUser(widget.userId!, userData);
      } else {
        response = await _userService.createUser(
          email: userData['email']!, 
          firstName: userData['firstName']!, 
          lastName: userData['lastName']!, 
          avatar: userData['avatar']!
        );
      }

      setState(() => _isSubmitting = false);

      if (response != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.userId != null
              ? 'User Successfully Updated'
              : 'User Successfully Created')),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.userId != null
            ? 'Failed to update user.'
            : 'Failed to create user.')),
      );
    }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.userId != null ? 'Edit User' : 'Add User'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                focusNode: _emailFocus,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_firstNameFocus);
                },
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: const OutlineInputBorder(),
                  suffixIcon: _emailHasError
                    ? Tooltip(
                        message: 'Email is required',
                        child: const Icon(Icons.warning_amber_rounded, color: Colors.red),
                      )
                    : null,
                  errorText: null, // Prevent default error text
                  errorStyle: const TextStyle(height: -1), // Hide space below
                ),
                validator: (value) {
                  final hasError = value == null || value.isEmpty;
                  setState(() {
                    _emailHasError = hasError;
                  });
                  return hasError ? ' ' : null;
                }
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _firstNameController,
                focusNode: _firstNameFocus,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_lastNameFocus);
                },
                decoration: InputDecoration(
                  labelText: 'First Name',
                  border: const OutlineInputBorder(),
                  suffixIcon: _firstNameHasError
                    ? Tooltip(
                        message: 'First Name is required',
                        child: const Icon(Icons.warning_amber_rounded, color: Colors.red),
                      )
                    : null,
                  errorText: null, // Prevent default error text
                  errorStyle: const TextStyle(height: -1), // Hide space below
                ),
                validator: (value) {
                  final hasError = value == null || value.isEmpty;
                  setState(() {
                    _firstNameHasError = hasError;
                  });
                  return hasError ? ' ' : null;
                }
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _lastNameController,
                focusNode: _lastNameFocus,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_avatarFocus);
                },
                decoration: InputDecoration(
                  labelText: 'Last Name',
                  border: const OutlineInputBorder(),
                  suffixIcon: _lastNameHasError
                    ? Tooltip(
                        message: 'Last Name is required',
                        child: const Icon(Icons.warning_amber_rounded, color: Colors.red),
                      )
                    : null,
                  errorText: null, // Prevent default error text
                  errorStyle: const TextStyle(height: -1), // Hide space below
                ),
                validator: (value) {
                  final hasError = value == null || value.isEmpty;
                  setState(() {
                    _lastNameHasError = hasError;
                  });
                  return hasError ? ' ' : null;
                }
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _avatarController,
                focusNode: _avatarFocus,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  labelText: 'Avatar URL',
                  border: const OutlineInputBorder(),
                  suffixIcon: _avatarHasError
                    ? Tooltip(
                        message: 'Avatar is required',
                        child: const Icon(Icons.warning_amber_rounded, color: Colors.red),
                      )
                    : null,
                  errorText: null, // Prevent default error text
                  errorStyle: const TextStyle(height: -1), // Hide space below
                ),
                validator: (value) {
                  final hasError = value == null || value.isEmpty;
                  setState(() {
                    _avatarHasError = hasError;
                  });
                  return hasError ? ' ' : null;
                }
              ),
              const SizedBox(height: 32),
              _isSubmitting
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white
                      ),
                      child: Text(widget.userId != null ? 'Save' : 'Add User'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
