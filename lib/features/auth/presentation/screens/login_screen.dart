import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth_bloc.dart';
import '../../../../core/errors/failures.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  Map<String, List<String>> _validationErrors = {};
  bool _isEmailValid = true;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateEmail);
    _passwordController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _emailController.removeListener(_validateEmail);
    _passwordController.removeListener(_validateForm);
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _validateEmail() {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() {
        _isEmailValid = false;
      });
      return false;
    }

    // Email regex pattern
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
      caseSensitive: false,
    );

    final isValid = emailRegex.hasMatch(email);
    setState(() {
      _isEmailValid = isValid;
    });
    _validateForm(); // Add this to trigger form validation after email validation
    return isValid;
  }

  void _validateForm() {
    setState(() {}); // This will trigger a rebuild to update button state
  }

  bool get _isFormValid {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    return email.isNotEmpty && password.isNotEmpty && _isEmailValid;
  }

  void _handleLogin() {
    setState(() {
      _validationErrors = {};
    });
    
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            LoginEvent(
              email: _emailController.text.trim(),
              password: _passwordController.text,
              rememberMe: _rememberMe,
            ),
          );
    }
  }

  String? _getFieldError(String fieldName) {
    if (_validationErrors.containsKey(fieldName)) {
      return _validationErrors[fieldName]?.join('\n');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            final failure = state.failure;

            if (failure is ValidationFailure) {
              final validationState = failure;
              setState(() {
                _validationErrors = validationState.errors;
              });
              
              _showErrorDialog(
                'Login Failed',
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      validationState.message,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (validationState.errors.length > 1) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Additional Details:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...validationState.errors.entries
                          .where((entry) => entry.value.first != validationState.message)
                          .map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('• '),
                              Expanded(
                                child: Text(
                                  entry.value.first,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ],
                ),
                Icons.error_outline,
              );
            } else if (failure is UnregisteredUserFailure) {
              final unregisteredState = failure;
              _showErrorDialog(
                'Account Not Found',
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      unregisteredState.message,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Would you like to create a new account?',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                Icons.account_circle_outlined,
                showSignUpButton: true,
                email: unregisteredState.email,
              );
            } else if (failure is NetworkFailure) {
              _showErrorDialog(
                'Network Error',
                Row(
                  children: [
                    const Icon(Icons.signal_wifi_off, size: 28),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            failure.message,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Please check your internet connection and try again.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Icons.signal_wifi_off,
                showRetryButton: true,
              );
            } else {
              _showErrorDialog(
                'Error',
                Text(
                  failure.message,
                  style: const TextStyle(fontSize: 16),
                ),
                Icons.error_outline,
              );
            }
          }
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E676),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text(
                        'E',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Welcome to XYZ',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Login to continue shopping.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF666666),
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _emailController,
                    onChanged: (_) => _validateEmail(),
                    decoration: InputDecoration(
                      labelText: 'Username/Email',
                      errorText: _getFieldError('email') ?? 
                               (!_isEmailValid && _emailController.text.isNotEmpty 
                                ? 'Please enter a valid email address' 
                                : null),
                      errorMaxLines: 2,
                      border: const UnderlineInputBorder(),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFE0E0E0)),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF00E676)),
                      ),
                      errorBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                      suffixIcon: _emailController.text.isNotEmpty
                          ? Icon(
                              _isEmailValid ? Icons.check_circle : Icons.error,
                              color: _isEmailValid 
                                  ? const Color(0xFF00E676)
                                  : Theme.of(context).colorScheme.error,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    onChanged: (_) => _validateForm(),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      errorText: _getFieldError('password'),
                      errorMaxLines: 2,
                      border: const UnderlineInputBorder(),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFE0E0E0)),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF00E676)),
                      ),
                      errorBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        onChanged: (value) {
                          setState(() {
                            _rememberMe = value ?? false;
                          });
                        },
                        activeColor: const Color(0xFF00E676),
                      ),
                      const Text(
                        'Remember me',
                        style: TextStyle(
                          color: Color(0xFF666666),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: ElevatedButton(
                          onPressed: (state is AuthLoading || !_isFormValid) 
                              ? null 
                              : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00E676),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                            disabledBackgroundColor: const Color(0xFF00E676).withOpacity(0.5),
                          ),
                          child: state is AuthLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor:
                                        AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text(
                                  'LOGIN',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Don\'t have an account? ',
                        style: TextStyle(
                          color: Color(0xFF666666),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Handle sign up
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF00E676),
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'Sign up',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showErrorDialog(
    String title, 
    Widget content, 
    IconData icon, {
    bool showRetryButton = false,
    bool showSignUpButton = false,
    String? email,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              icon,
              color: icon == Icons.signal_wifi_off 
                  ? Colors.orange 
                  : Theme.of(context).colorScheme.error,
            ),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: content,
        actions: [
          if (showSignUpButton)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: Navigate to sign up screen with pre-filled email
                // Navigator.of(context).pushNamed(
                //   '/signup',
                //   arguments: {'email': email},
                // );
              },
              child: const Text(
                'SIGN UP',
                style: TextStyle(
                  color: Color(0xFF00E676),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          if (showRetryButton)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _handleLogin();
              },
              child: const Text(
                'RETRY',
                style: TextStyle(
                  color: Color(0xFF00E676),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              showRetryButton || showSignUpButton ? 'CANCEL' : 'OK',
              style: const TextStyle(
                color: Color(0xFF00E676),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: Colors.white,
        elevation: 24,
      ),
    );
  }
} 