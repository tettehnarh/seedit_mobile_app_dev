import 'dart:developer' as developer;
import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/constants/api_constants.dart';
import '../models/goal_models.dart';

/// Service for handling goals-related API calls
class GoalsService {
  final ApiClient _apiClient = ApiClient();

  /// Get user's personal goals
  Future<List<PersonalGoal>> getGoals() async {
    try {
      developer.log(
        'Fetching personal goals from: ${ApiConstants.baseUrl}/goals/goals/',
      );

      final response = await _apiClient.get('/goals/goals/');

      developer.log('Goals API response: $response');

      if (response is List) {
        final goals = response
            .map((goal) => PersonalGoal.fromJson(goal))
            .toList();
        developer.log('Successfully parsed ${goals.length} goals');
        return goals;
      } else if (response['results'] != null) {
        final List<dynamic> goalsData = response['results'];
        return goalsData.map((goal) => PersonalGoal.fromJson(goal)).toList();
      }

      developer.log('No goals found in response structure');
      return [];
    } catch (e) {
      developer.log('Error fetching goals: $e', error: e);
      if (e is ApiException) {
        developer.log('API Exception details: ${e.message}');
        rethrow;
      }
      throw NetworkException('Failed to fetch goals: $e');
    }
  }

  /// Get goals dashboard with summary statistics
  Future<GoalsDashboard> getDashboard() async {
    try {
      developer.log(
        'Fetching goals dashboard from: ${ApiConstants.baseUrl}/goals/dashboard/',
      );

      final response = await _apiClient.get('/goals/dashboard/');

      developer.log('Dashboard API response: $response');

      return GoalsDashboard.fromJson(response);
    } catch (e) {
      developer.log('Error fetching goals dashboard: $e', error: e);
      if (e is ApiException) {
        developer.log('API Exception details: ${e.message}');
        rethrow;
      }
      throw NetworkException('Failed to fetch goals dashboard: $e');
    }
  }

  /// Create a new personal goal
  Future<PersonalGoal> createGoal(CreateGoalRequest request) async {
    try {
      developer.log('Creating goal: ${request.name}');
      print('🚀 [GOALS_SERVICE] Starting goal creation: ${request.name}');

      // Validate request data before sending
      final requestData = request.toJson();
      developer.log('Request data: $requestData');

      // Check for any null values in required fields
      if (requestData['name'] == null ||
          requestData['name'].toString().trim().isEmpty) {
        throw NetworkException('Goal name is required');
      }
      if (requestData['target_amount'] == null ||
          requestData['target_amount'] <= 0) {
        throw NetworkException('Valid target amount is required');
      }
      if (requestData['target_date'] == null ||
          requestData['target_date'].toString().trim().isEmpty) {
        throw NetworkException('Target date is required');
      }
      if (requestData['investment_frequency'] == null ||
          requestData['investment_frequency'].toString().trim().isEmpty) {
        throw NetworkException('Investment frequency is required');
      }

      final response = await _apiClient.postWithAuth(
        '/goals/goals/',
        requestData,
      );

      // Use both developer.log and print to ensure visibility
      developer.log('🔍 [GOALS_SERVICE] Create goal API response: $response');
      print('🔍 [GOALS_SERVICE] Create goal API response: $response');

      developer.log(
        '🔍 [GOALS_SERVICE] Response type: ${response.runtimeType}',
      );
      print('🔍 [GOALS_SERVICE] Response type: ${response.runtimeType}');

      // Check ALL fields in the response before parsing
      if (response is Map<String, dynamic>) {
        developer.log('🔍 [GOALS_SERVICE] Detailed response fields analysis:');
        print('🔍 [GOALS_SERVICE] Detailed response fields analysis:');
        response.forEach((key, value) {
          developer.log('  - $key: $value (${value?.runtimeType})');
          print('  - $key: $value (${value?.runtimeType})');
        });

        developer.log('🔍 [GOALS_SERVICE] Critical fields check:');
        developer.log(
          '  - id: ${response['id']} (${response['id']?.runtimeType})',
        );
        developer.log(
          '  - name: ${response['name']} (${response['name']?.runtimeType})',
        );
        developer.log(
          '  - status: ${response['status']} (${response['status']?.runtimeType})',
        );
        developer.log(
          '  - target_date: ${response['target_date']} (${response['target_date']?.runtimeType})',
        );
        developer.log(
          '  - investment_frequency: ${response['investment_frequency']} (${response['investment_frequency']?.runtimeType})',
        );
        developer.log(
          '  - created_at: ${response['created_at']} (${response['created_at']?.runtimeType})',
        );
        developer.log(
          '  - updated_at: ${response['updated_at']} (${response['updated_at']?.runtimeType})',
        );
        developer.log(
          '  - linked_fund: ${response['linked_fund']} (${response['linked_fund']?.runtimeType})',
        );
        developer.log(
          '  - linked_fund_name: ${response['linked_fund_name']} (${response['linked_fund_name']?.runtimeType})',
        );
      }

      try {
        developer.log(
          '🔍 [GOALS_SERVICE] Attempting to parse PersonalGoal from JSON...',
        );
        print(
          '🔍 [GOALS_SERVICE] Attempting to parse PersonalGoal from JSON...',
        );

        final goal = PersonalGoal.fromJson(response);

        developer.log(
          '🔍 [GOALS_SERVICE] Successfully parsed PersonalGoal: ${goal.id}',
        );
        print(
          '🔍 [GOALS_SERVICE] Successfully parsed PersonalGoal: ${goal.id}',
        );
        return goal;
      } catch (parseError, stackTrace) {
        developer.log(
          '❌ [GOALS_SERVICE] Error parsing PersonalGoal from JSON: $parseError',
        );
        print(
          '❌ [GOALS_SERVICE] Error parsing PersonalGoal from JSON: $parseError',
        );

        developer.log('❌ [GOALS_SERVICE] Stack trace: $stackTrace');
        print('❌ [GOALS_SERVICE] Stack trace: $stackTrace');

        developer.log(
          '❌ [GOALS_SERVICE] Raw response that failed to parse: $response',
        );
        print('❌ [GOALS_SERVICE] Raw response that failed to parse: $response');

        // Try to identify which field is causing the issue
        if (parseError.toString().contains('type cast')) {
          developer.log('❌ [GOALS_SERVICE] Type casting error detected');
          if (parseError.toString().contains('int') &&
              parseError.toString().contains('String')) {
            developer.log(
              '❌ [GOALS_SERVICE] Integer to String casting issue detected',
            );
          }
        }

        // Provide a more user-friendly error message
        if (parseError.toString().contains('Null is not a subtype of type')) {
          throw NetworkException(
            'Invalid response format from server. Please try again or contact support if the issue persists.',
          );
        } else {
          throw NetworkException(
            'Failed to process server response: ${parseError.toString()}',
          );
        }
      }
    } catch (e) {
      developer.log('Error creating goal: $e', error: e);
      if (e is ApiException) {
        developer.log('API Exception details: ${e.message}');
        rethrow;
      }
      throw NetworkException('Failed to create goal: $e');
    }
  }

  /// Update an existing goal
  Future<PersonalGoal> updateGoal(
    String goalId,
    CreateGoalRequest request,
  ) async {
    try {
      developer.log('Updating goal: $goalId');

      final response = await _apiClient.putWithAuth(
        '/goals/goals/$goalId/',
        request.toJson(),
      );

      developer.log('Update goal API response: $response');

      return PersonalGoal.fromJson(response);
    } catch (e) {
      developer.log('Error updating goal: $e', error: e);
      if (e is ApiException) {
        developer.log('API Exception details: ${e.message}');
        rethrow;
      }
      throw NetworkException('Failed to update goal: $e');
    }
  }

  /// Delete a goal
  Future<void> deleteGoal(String goalId) async {
    try {
      developer.log('Deleting goal: $goalId');

      await _apiClient.deleteWithAuth('/goals/goals/$goalId/');

      developer.log('Goal deleted successfully');
    } catch (e) {
      developer.log('Error deleting goal: $e', error: e);
      if (e is ApiException) {
        developer.log('API Exception details: ${e.message}');
        rethrow;
      }
      throw NetworkException('Failed to delete goal: $e');
    }
  }

  /// Contribute to a goal
  Future<Map<String, dynamic>> contributeToGoal(
    String goalId,
    ContributeToGoalRequest request,
  ) async {
    try {
      developer.log('Contributing to goal: $goalId, amount: ${request.amount}');

      final response = await _apiClient.postWithAuth(
        '/goals/goals/$goalId/contribute/',
        request.toJson(),
      );

      developer.log('Contribute to goal API response: $response');

      return response;
    } catch (e) {
      developer.log('Error contributing to goal: $e', error: e);
      if (e is ApiException) {
        developer.log('API Exception details: ${e.message}');
        rethrow;
      }
      throw NetworkException('Failed to contribute to goal: $e');
    }
  }

  /// Get contributions for a specific goal
  Future<List<GoalContribution>> getGoalContributions(String goalId) async {
    try {
      developer.log('Fetching contributions for goal: $goalId');

      final response = await _apiClient.get(
        '/goals/goals/$goalId/contributions/',
      );

      developer.log('Goal contributions API response: $response');

      if (response is List) {
        return response
            .map((contribution) => GoalContribution.fromJson(contribution))
            .toList();
      }

      return [];
    } catch (e) {
      developer.log('Error fetching goal contributions: $e', error: e);
      if (e is ApiException) {
        developer.log('API Exception details: ${e.message}');
        rethrow;
      }
      throw NetworkException('Failed to fetch goal contributions: $e');
    }
  }

  /// Update goal progress based on actual investments
  Future<PersonalGoal> updateGoalProgress(String goalId) async {
    try {
      developer.log('Updating goal progress: $goalId');

      final response = await _apiClient.postWithAuth(
        '/goals/goals/$goalId/update-progress/',
        {},
      );

      developer.log('Update goal progress API response: $response');

      return PersonalGoal.fromJson(response);
    } catch (e) {
      developer.log('Error updating goal progress: $e', error: e);
      if (e is ApiException) {
        developer.log('API Exception details: ${e.message}');
        rethrow;
      }
      throw NetworkException('Failed to update goal progress: $e');
    }
  }

  /// Get available funds for goal linking
  Future<List<Fund>> getAvailableFunds() async {
    try {
      developer.log('Fetching available funds for goal linking');

      final response = await _apiClient.get('/goals/available-funds/');

      developer.log('Available funds API response: $response');

      if (response is List) {
        return response.map((fund) => Fund.fromJson(fund)).toList();
      }

      return [];
    } catch (e) {
      developer.log('Error fetching available funds: $e', error: e);
      if (e is ApiException) {
        developer.log('API Exception details: ${e.message}');
        rethrow;
      }
      throw NetworkException('Failed to fetch available funds: $e');
    }
  }

  /// Get user's fund investments for progress calculation
  Future<Map<String, dynamic>> getUserFundInvestments() async {
    try {
      developer.log(
        '🎯 [GOALS_SERVICE] Fetching user fund investments from: ${ApiConstants.baseUrl}/goals/user-fund-investments/',
      );

      final response = await _apiClient.get('/goals/user-fund-investments/');

      developer.log(
        '🎯 [GOALS_SERVICE] Fund investments API response: $response',
      );

      if (response is Map<String, dynamic>) {
        developer.log(
          '🎯 [GOALS_SERVICE] Successfully fetched fund investments data',
        );
        return response;
      }

      developer.log('🎯 [GOALS_SERVICE] No fund investments found in response');
      return {'fund_investments': {}, 'total_funds': 0};
    } catch (e) {
      developer.log(
        '🎯 [GOALS_SERVICE] Error fetching fund investments: $e',
        error: e,
      );
      if (e is ApiException) {
        developer.log('🎯 [GOALS_SERVICE] API Exception details: ${e.message}');
        rethrow;
      }
      throw NetworkException('Failed to fetch fund investments: $e');
    }
  }

  /// Get goals that need investment reminders
  Future<List<PersonalGoal>> getGoalReminders() async {
    try {
      developer.log(
        '🔔 [GOALS_SERVICE] Fetching goal reminders from: ${ApiConstants.baseUrl}/goals/reminders/',
      );

      final response = await _apiClient.get('/goals/reminders/');

      developer.log(
        '🔔 [GOALS_SERVICE] Goal reminders API response: $response',
      );

      if (response['reminders'] != null) {
        final List<dynamic> remindersData = response['reminders'];
        final reminders = remindersData
            .map((reminder) => PersonalGoal.fromJson(reminder))
            .toList();
        developer.log(
          '🔔 [GOALS_SERVICE] Successfully parsed ${reminders.length} goal reminders',
        );
        return reminders;
      }

      developer.log(
        '🔔 [GOALS_SERVICE] No reminders found in response structure',
      );
      return [];
    } catch (e) {
      developer.log(
        '🔔 [GOALS_SERVICE] Error fetching goal reminders: $e',
        error: e,
      );
      if (e is ApiException) {
        developer.log('🔔 [GOALS_SERVICE] API Exception details: ${e.message}');
        rethrow;
      }
      throw NetworkException('Failed to fetch goal reminders: $e');
    }
  }

  /// Dismiss a goal reminder temporarily
  Future<void> dismissGoalReminder(String goalId) async {
    try {
      developer.log(
        '🔔 [GOALS_SERVICE] Dismissing goal reminder for goal: $goalId',
      );

      final response = await _apiClient.post(
        '/goals/$goalId/dismiss-reminder/',
        {},
      );

      developer.log(
        '🔔 [GOALS_SERVICE] Dismiss reminder API response: $response',
      );
    } catch (e) {
      developer.log(
        '🔔 [GOALS_SERVICE] Error dismissing goal reminder: $e',
        error: e,
      );
      if (e is ApiException) {
        developer.log('🔔 [GOALS_SERVICE] API Exception details: ${e.message}');
        rethrow;
      }
      throw NetworkException('Failed to dismiss goal reminder: $e');
    }
  }
}
