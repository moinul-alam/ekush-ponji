import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeViewModel extends Notifier<HomeState> {
  @override
  HomeState build() {
    // Return initial state immediately
    final initialState = const HomeState();
    
    // Schedule the data loading for after initialization
    Future.microtask(() => _loadHomeData());
    
    return initialState;
  }

  Future<void> _loadHomeData() async {
    try {
      state = state.copyWith(isLoading: true);
      
      // Simulate loading delay (remove this in production)
      // await Future.delayed(const Duration(seconds: 1));
      
      // Set greeting based on time of day
      final greeting = _getGreeting();
      
      state = state.copyWith(
        isLoading: false,
        greetingMessage: greeting,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load home data: $e',
      );
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning!';
    } else if (hour < 17) {
      return 'Good Afternoon!';
    } else if (hour < 21) {
      return 'Good Evening!';
    } else {
      return 'Good Night!';
    }
  }

  Future<void> refreshHomeData() async {
    await _loadHomeData();
  }
}

// HomeState class remains the same
class HomeState {
  final String greetingMessage;
  final bool isLoading;
  final String? errorMessage;

  const HomeState({
    this.greetingMessage = '',
    this.isLoading = false,
    this.errorMessage,
  });

  HomeState copyWith({
    String? greetingMessage,
    bool? isLoading,
    String? errorMessage,
  }) {
    return HomeState(
      greetingMessage: greetingMessage ?? this.greetingMessage,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}