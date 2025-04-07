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
  bool _isFormValid = false;

  final ScrollController _scrollController = ScrollController();
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

    _emailFocus.addListener(() => _scrollToField(_emailFocus));
    _firstNameFocus.addListener(() => _scrollToField(_firstNameFocus));
    _lastNameFocus.addListener(() => _scrollToField(_lastNameFocus));
    _avatarFocus.addListener(() => _scrollToField(_avatarFocus));

    _emailController.addListener(_checkFormStatus);
    _firstNameController.addListener(_checkFormStatus);
    _lastNameController.addListener(_checkFormStatus);
    _avatarController.addListener(_checkFormStatus);
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
    _emailController.removeListener(_checkFormStatus);
    _firstNameController.removeListener(_checkFormStatus);
    _lastNameController.removeListener(_checkFormStatus);
    _avatarController.removeListener(_checkFormStatus);

    super.dispose();
  }

  void _scrollToField(FocusNode focusNode) {
    if (focusNode.hasFocus) {
      // Delay is needed to ensure the keyboard is fully shown before scrolling
      Future.delayed(Duration(milliseconds: 300)).then((_) {
        Scrollable.ensureVisible(
          focusNode.context!,
          duration: Duration(milliseconds: 300),
          alignment: 0.3,
        );
      });
    }
  }
  
  void _checkFormStatus() {
    final isValid = _emailController.text.trim().isNotEmpty &&
        _firstNameController.text.trim().isNotEmpty &&
        _lastNameController.text.trim().isNotEmpty &&
        _avatarController.text.trim().isNotEmpty;

    final isDirty = _emailController.text != (widget.initialEmail ?? '') ||
        _firstNameController.text != (widget.initialFirstName ?? '') ||
        _lastNameController.text != (widget.initialLastName ?? '') ||
        _avatarController.text != (widget.initialAvatar ?? '');

    setState(() {
      _isFormValid = isValid && isDirty;
    });
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
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
      ),
      body: SafeArea(
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 17.0, right: 10),
                    child: Icon(Icons.email),
                  ),
                  Expanded(
                    child: TextFormField(
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
                                message: 'Invalid Email',
                                child: const Icon(Icons.error, color: Colors.red),
                              )
                            : null,
                        errorText: null,
                        errorStyle: const TextStyle(height: -1),
                      ),
                      validator: (value) {
                        final hasError = value == null || value.isEmpty;
                        final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");

                        bool validEmail = emailRegex.hasMatch(value ?? '');

                        setState(() {
                          _emailHasError = hasError || !validEmail;
                        });

                        if (hasError) return ' ';
                        if (!validEmail) return ' ';

                        return null;
                      }
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 17.0, right: 10),
                    child: Icon(Icons.person),
                  ),
                  Expanded(
                    child: TextFormField(
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
                                child: const Icon(Icons.error, color: Colors.red),
                              )
                            : null,
                        errorText: null,
                        errorStyle: const TextStyle(height: -1),
                      ),
                      validator: (value) {
                        final hasError = value == null || value.isEmpty;
                        setState(() {
                          _firstNameHasError = hasError;
                        });
                        return hasError ? ' ' : null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 17.0, right: 10), 
                    child: SizedBox(width: 24,),
                  ),
                  Expanded(
                    child: TextFormField(
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
                                child: const Icon(Icons.error, color: Colors.red),
                              )
                            : null,
                        errorText: null,
                        errorStyle: const TextStyle(height: -1),
                      ),
                      validator: (value) {
                        final hasError = value == null || value.isEmpty;
                        setState(() {
                          _lastNameHasError = hasError;
                        });
                        return hasError ? ' ' : null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 17.0, right: 10),
                    child: Icon(Icons.link),
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: _avatarController,
                      focusNode: _avatarFocus,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _isFormValid ? _submit() : null,
                      decoration: InputDecoration(
                        labelText: 'Avatar URL',
                        border: const OutlineInputBorder(),
                        suffixIcon: _avatarHasError
                            ? Tooltip(
                                message: 'Avatar URL is required',
                                child: const Icon(Icons.error, color: Colors.red),
                              )
                            : null,
                        errorText: null,
                        errorStyle: const TextStyle(height: -1),
                      ),
                      validator: (value) {
                        final hasError = value == null || value.isEmpty;
                        setState(() {
                          _avatarHasError = hasError;
                        });
                        return hasError ? ' ' : null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _isSubmitting
                  ? const CircularProgressIndicator()
                  : Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isFormValid ? _submit : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            foregroundColor: Colors.white,
                          ),
                          child: Text(widget.userId != null ? 'Save' : 'Add User'),
                        ),
                      ),
                    ],
                  )
            ],
          ),
        ),
      ),
    ),
    );
  }
}
