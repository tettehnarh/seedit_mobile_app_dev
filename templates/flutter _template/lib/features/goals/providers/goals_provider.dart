import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/goal_models.dart';
import '../services/goals_service.dart';
import '../../../core/api/api_exception.dart';
import 'dart:developer' as developer;

// Goals Service Provider
final goalsServiceProvider = Provider<GoalsService>((ref) {
  return GoalsService();
});

// Goals State
class GoalsState {
  final List<PersonalGoal> goals;
  final bool isLoading;
  final bool isInitialized;
  final String? error;

  const GoalsState({
    this.goals = const [],
    this.isLoading = false,
    this.isInitialized = false,
    this.error,
  });

  GoalsState copyWith({
    List<PersonalGoal>? goals,
    bool? isLoading,
    bool? isInitialized,
    String? error,
    bool clearError = false,
  }) {
    return GoalsState(
      goals: goals ?? this.goals,
      isLoading: isLoading ?? this.isLoading,
      isInitialized: isInitialized ?? this.isInitialized,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// Goals Provider
class GoalsNotifier extends StateNotifier<GoalsState> {
  final GoalsService _goalsService;
  final Ref _ref;

  GoalsNotifier(this._goalsService, this._ref) : super(const GoalsState());

  /// Load all goals
  Future<void> loadGoals() async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);

      developer.log('🎯 [GOALS_PROVIDER] Loading goals...');

      final goals = await _goalsService.getGoals();

      developer.log('🎯 [GOALS_PROVIDER] Loaded ${goals.length} goals');

      state = state.copyWith(
        goals: goals,
        isLoading: false,
        isInitialized: true,
      );

      // Also refresh dashboard
      _ref.read(goalsDashboardProvider.notifier).loadDashboard();
    } catch (e) {
      developer.log('🎯 [GOALS_PROVIDER] Error loading goals: $e');

      String errorMessage = 'Failed to load goals';
      if (e is NetworkException) {
        errorMessage = e.message;
      }

      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
        isInitialized: true,
      );
    }
  }

  /// Create a new goal
  Future<PersonalGoal?> createGoal(CreateGoalRequest request) async {
    try {
      developer.log('🎯 [GOALS_PROVIDER] Creating goal: ${request.name}');

      final newGoal = await _goalsService.createGoal(request);

      // Add the new goal to the current list
      final updatedGoals = [...state.goals, newGoal];
      state = state.copyWith(goals: updatedGoals);

      // Refresh dashboard
      _ref.read(goalsDashboardProvider.notifier).loadDashboard();

      developer.log(
        '🎯 [GOALS_PROVIDER] Goal created successfully: ${newGoal.id}',
      );

      return newGoal;
    } catch (e) {
      developer.log('🎯 [GOALS_PROVIDER] Error creating goal: $e');

      String errorMessage = 'Failed to create goal';
      if (e is NetworkException) {
        errorMessage = e.message;
      }

      state = state.copyWith(error: errorMessage);
      return null;
    }
  }

  /// Update an existing goal
  Future<PersonalGoal?> updateGoal(
    String goalId,
    CreateGoalRequest request,
  ) async {
    try {
      developer.log('🎯 [GOALS_PROVIDER] Updating goal: $goalId');

      final updatedGoal = await _goalsService.updateGoal(goalId, request);

      // Update the goal in the current list
      final updatedGoals = state.goals.map((goal) {
        return goal.id == goalId ? updatedGoal : goal;
      }).toList();

      state = state.copyWith(goals: updatedGoals);

      // Refresh dashboard
      _ref.read(goalsDashboardProvider.notifier).loadDashboard();

      developer.log('🎯 [GOALS_PROVIDER] Goal updated successfully: $goalId');

      return updatedGoal;
    } catch (e) {
      developer.log('🎯 [GOALS_PROVIDER] Error updating goal: $e');

      String errorMessage = 'Failed to update goal';
      if (e is NetworkException) {
        errorMessage = e.message;
      }

      state = state.copyWith(error: errorMessage);
      return null;
    }
  }

  /// Delete a goal
  Future<bool> deleteGoal(String goalId) async {
    try {
      developer.log('🎯 [GOALS_PROVIDER] Deleting goal: $goalId');

      await _goalsService.deleteGoal(goalId);

      // Remove the goal from the current list
      final updatedGoals = state.goals
          .where((goal) => goal.id != goalId)
          .toList();
      state = state.copyWith(goals: updatedGoals);

      // Refresh dashboard
      _ref.read(goalsDashboardProvider.notifier).loadDashboard();

      developer.log('🎯 [GOALS_PROVIDER] Goal deleted successfully: $goalId');

      return true;
    } catch (e) {
      developer.log('🎯 [GOALS_PROVIDER] Error deleting goal: $e');

      String errorMessage = 'Failed to delete goal';
      if (e is NetworkException) {
        errorMessage = e.message;
      }

      state = state.copyWith(error: errorMessage);
      return false;
    }
  }

  /// Contribute to a goal
  Future<bool> contributeToGoal(
    String goalId,
    ContributeToGoalRequest request,
  ) async {
    try {
      developer.log(
        '🎯 [GOALS_PROVIDER] Contributing to goal: $goalId, amount: ${request.amount}',
      );

      final result = await _goalsService.contributeToGoal(goalId, request);

      // Update the goal with new data from the response
      if (result['goal'] != null) {
        final updatedGoal = PersonalGoal.fromJson(result['goal']);
        final updatedGoals = state.goals.map((goal) {
          return goal.id == goalId ? updatedGoal : goal;
        }).toList();

        state = state.copyWith(goals: updatedGoals);

        // Refresh dashboard
        _ref.read(goalsDashboardProvider.notifier).loadDashboard();
      }

      developer.log('🎯 [GOALS_PROVIDER] Contribution added successfully');

      return true;
    } catch (e) {
      developer.log('🎯 [GOALS_PROVIDER] Error contributing to goal: $e');

      String errorMessage = 'Failed to add contribution';
      if (e is NetworkException) {
        errorMessage = e.message;
      }

      state = state.copyWith(error: errorMessage);
      return false;
    }
  }

  /// Update goal progress
  Future<bool> updateGoalProgress(String goalId) async {
    try {
      developer.log('🎯 [GOALS_PROVIDER] Updating goal progress: $goalId');

      final updatedGoal = await _goalsService.updateGoalProgress(goalId);

      // Update the goal in the current list
      final updatedGoals = state.goals.map((goal) {
        return goal.id == goalId ? updatedGoal : goal;
      }).toList();

      state = state.copyWith(goals: updatedGoals);

      // Refresh dashboard
      _ref.read(goalsDashboardProvider.notifier).loadDashboard();

      developer.log('🎯 [GOALS_PROVIDER] Goal progress updated successfully');

      return true;
    } catch (e) {
      developer.log('🎯 [GOALS_PROVIDER] Error updating goal progress: $e');

      String errorMessage = 'Failed to update goal progress';
      if (e is NetworkException) {
        errorMessage = e.message;
      }

      state = state.copyWith(error: errorMessage);
      return false;
    }
  }

  /// Clear error state
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

// Goals Provider Instance
final goalsProvider = StateNotifierProvider<GoalsNotifier, GoalsState>((ref) {
  final goalsService = ref.watch(goalsServiceProvider);
  return GoalsNotifier(goalsService, ref);
});

// Dashboard State
class DashboardState {
  final GoalsDashboard? dashboard;
  final bool isLoading;
  final String? error;

  const DashboardState({this.dashboard, this.isLoading = false, this.error});

  DashboardState copyWith({
    GoalsDashboard? dashboard,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return DashboardState(
      dashboard: dashboard ?? this.dashboard,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// Dashboard Provider
class DashboardNotifier extends StateNotifier<DashboardState> {
  final GoalsService _goalsService;

  DashboardNotifier(this._goalsService) : super(const DashboardState());

  /// Load dashboard data
  Future<void> loadDashboard() async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);

      developer.log('🎯 [DASHBOARD_PROVIDER] Loading dashboard...');

      final dashboard = await _goalsService.getDashboard();

      developer.log('🎯 [DASHBOARD_PROVIDER] Dashboard loaded successfully');

      state = state.copyWith(dashboard: dashboard, isLoading: false);
    } catch (e) {
      developer.log('🎯 [DASHBOARD_PROVIDER] Error loading dashboard: $e');

      String errorMessage = 'Failed to load dashboard';
      if (e is NetworkException) {
        errorMessage = e.message;
      }

      state = state.copyWith(isLoading: false, error: errorMessage);
    }
  }
}

// Dashboard Provider Instance
final goalsDashboardProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
      final goalsService = ref.watch(goalsServiceProvider);
      return DashboardNotifier(goalsService);
    });

// Computed Providers
final activeGoalsProvider = Provider<List<PersonalGoal>>((ref) {
  final goalsState = ref.watch(goalsProvider);
  return goalsState.goals.where((goal) => goal.status == 'active').toList();
});

final completedGoalsProvider = Provider<List<PersonalGoal>>((ref) {
  final goalsState = ref.watch(goalsProvider);
  return goalsState.goals.where((goal) => goal.status == 'completed').toList();
});

// Available Funds Provider
final availableFundsProvider = FutureProvider<List<Fund>>((ref) async {
  final goalsService = ref.watch(goalsServiceProvider);
  return goalsService.getAvailableFunds();
});

// User Fund Investments Provider
final userFundInvestmentsProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  final goalsService = ref.watch(goalsServiceProvider);
  return goalsService.getUserFundInvestments();
});

// Refresh Goals Provider - used to trigger refresh of goals data
final refreshGoalsProvider = StateProvider<int>((ref) => 0);

// Refresh Fund Investments Provider - used to trigger refresh of fund investments data
final refreshFundInvestmentsProvider = StateProvider<int>((ref) => 0);

// Enhanced Goals Provider with refresh capability
final goalsWithRefreshProvider = FutureProvider<List<PersonalGoal>>((
  ref,
) async {
  // Watch refresh trigger
  ref.watch(refreshGoalsProvider);

  final goalsService = ref.watch(goalsServiceProvider);
  return goalsService.getGoals();
});

// Enhanced Fund Investments Provider with refresh capability
final fundInvestmentsWithRefreshProvider = FutureProvider<Map<String, dynamic>>(
  (ref) async {
    // Watch refresh trigger
    ref.watch(refreshFundInvestmentsProvider);

    final goalsService = ref.watch(goalsServiceProvider);
    return goalsService.getUserFundInvestments();
  },
);

// Goal Reminders State
class GoalRemindersState {
  final List<PersonalGoal> reminders;
  final bool isLoading;
  final String? error;
  final Set<String> dismissedReminders; // Track temporarily dismissed reminders

  const GoalRemindersState({
    this.reminders = const [],
    this.isLoading = false,
    this.error,
    this.dismissedReminders = const {},
  });

  GoalRemindersState copyWith({
    List<PersonalGoal>? reminders,
    bool? isLoading,
    String? error,
    Set<String>? dismissedReminders,
    bool clearError = false,
  }) {
    return GoalRemindersState(
      reminders: reminders ?? this.reminders,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      dismissedReminders: dismissedReminders ?? this.dismissedReminders,
    );
  }

  /// Get active reminders (not dismissed)
  List<PersonalGoal> get activeReminders {
    return reminders
        .where((reminder) => !dismissedReminders.contains(reminder.id))
        .toList();
  }
}

// Goal Reminders Provider
final goalRemindersProvider =
    StateNotifierProvider<GoalRemindersNotifier, GoalRemindersState>((ref) {
      final goalsService = ref.read(goalsServiceProvider);
      return GoalRemindersNotifier(goalsService);
    });

class GoalRemindersNotifier extends StateNotifier<GoalRemindersState> {
  final GoalsService _goalsService;

  GoalRemindersNotifier(this._goalsService) : super(const GoalRemindersState());

  /// Load goal reminders
  Future<void> loadReminders() async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);

      developer.log('🔔 [GOAL_REMINDERS_PROVIDER] Loading goal reminders...');

      final reminders = await _goalsService.getGoalReminders();

      developer.log(
        '🔔 [GOAL_REMINDERS_PROVIDER] Loaded ${reminders.length} reminders',
      );

      state = state.copyWith(reminders: reminders, isLoading: false);
    } catch (e) {
      developer.log('🔔 [GOAL_REMINDERS_PROVIDER] Error loading reminders: $e');

      String errorMessage = 'Failed to load reminders';
      if (e is NetworkException) {
        errorMessage = e.message;
      }

      state = state.copyWith(isLoading: false, error: errorMessage);
    }
  }

  /// Dismiss a reminder temporarily (client-side only)
  void dismissReminderLocally(String goalId) {
    final updatedDismissed = Set<String>.from(state.dismissedReminders)
      ..add(goalId);
    state = state.copyWith(dismissedReminders: updatedDismissed);

    developer.log(
      '🔔 [GOAL_REMINDERS_PROVIDER] Dismissed reminder locally for goal: $goalId',
    );
  }

  /// Dismiss a reminder on the server
  Future<void> dismissReminder(String goalId) async {
    try {
      developer.log(
        '🔔 [GOAL_REMINDERS_PROVIDER] Dismissing reminder for goal: $goalId',
      );

      // First dismiss locally for immediate UI feedback
      dismissReminderLocally(goalId);

      // Then dismiss on server
      await _goalsService.dismissGoalReminder(goalId);

      developer.log(
        '🔔 [GOAL_REMINDERS_PROVIDER] Successfully dismissed reminder on server',
      );
    } catch (e) {
      developer.log(
        '🔔 [GOAL_REMINDERS_PROVIDER] Error dismissing reminder: $e',
      );

      // Revert local dismissal if server call failed
      final updatedDismissed = Set<String>.from(state.dismissedReminders)
        ..remove(goalId);
      state = state.copyWith(dismissedReminders: updatedDismissed);

      // Set error state
      String errorMessage = 'Failed to dismiss reminder';
      if (e is NetworkException) {
        errorMessage = e.message;
      }
      state = state.copyWith(error: errorMessage);
    }
  }

  /// Clear all dismissed reminders (for refresh)
  void clearDismissedReminders() {
    state = state.copyWith(dismissedReminders: {});
  }
}
