import '../constants/user_role.dart';

/// Every path in the app. Screens navigate with these constants, never
/// string literals.
abstract final class AppRoutes {
  // Entry.
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const login = '/auth/login';
  static const signup = '/auth/signup';
  static const forgotPassword = '/auth/forgot-password';
  static String forgotPasswordFor(String email) => email.trim().isEmpty
      ? forgotPassword
      : '$forgotPassword?email=${Uri.encodeQueryComponent(email.trim())}';
  static const locationPermission = '/permissions/location';

  // Customer shell tabs.
  static const home = '/home';
  static const vehicles = '/vehicles';
  static const tracking = '/tracking';
  static const profile = '/profile';

  // Track tab children.
  static const liveTracking = '/tracking/live';
  static const trackHistory = '/tracking?tab=history';
  static String pastRequest(String id) => '/tracking/request/$id';

  // Profile tab children.
  static const editProfile = '/profile/edit';
  static const settings = '/profile/settings';
  static const helpSupport = '/profile/help';
  static const about = '/profile/about';

  // Customer pushed screens.
  static const addVehicle = '/vehicles/add';
  static const defaultVehicle = '/vehicles/default';
  static String vehicleDetails(String id) => '/vehicles/$id';
  static String editVehicle(String id) => '/vehicles/$id/edit';
  static const history = '/history';
  static const notifications = '/notifications';
  static String invoice(String requestId) => '/invoice/$requestId';
  static const invoicePattern = '/invoice/:requestId';

  // Request flow (full-screen, above the shell).
  static const requestService = '/request/service';
  static const requestVehicle = '/request/vehicle';
  static const requestLocation = '/request/location';
  static const requestDetails = '/request/details';
  static const requestConfirm = '/request/confirm';

  // Rescue journey (after the request is sent).
  static const rescueSubmitted = '/rescue/submitted';
  static const rescueFinding = '/rescue/finding';
  static const rescueAssigned = '/rescue/assigned';
  static const rescueProvider = '/rescue/provider';
  static const rescueArrived = '/rescue/arrived';
  static const rescueInProgress = '/rescue/in-progress';
  static const rescueCompleted = '/rescue/completed';
  static const rescueInvoice = '/rescue/invoice';
  static const rescueRate = '/rescue/rate';

  // Provider.
  static const providerRoot = '/provider';
  static const providerDashboard = '/provider/dashboard';
  static const providerJobs = '/provider/jobs';
  static const providerEarnings = '/provider/earnings';
  static const providerProfile = '/provider/profile';
  static String providerJob(String jobId) => '/provider/job/$jobId';
  static String providerJobComplete(String jobId) =>
      '/provider/job/$jobId/complete';

  // Admin.
  static const adminRoot = '/admin';
  static const adminDashboard = '/admin/dashboard';
  static const adminRequests = '/admin/requests';
  static const adminProviders = '/admin/providers';
  static const adminCustomers = '/admin/customers';
  static const adminReports = '/admin/reports';
  static const adminServices = '/admin/services';

  // Development only.
  static const designSystem = '/design-system';

  static String homeFor(UserRole role) => switch (role) {
    UserRole.customer => home,
    UserRole.provider => providerDashboard,
    UserRole.admin => adminDashboard,
  };

  /// Which role a location belongs to, or null for public/entry routes.
  static UserRole? roleFor(String location) {
    if (location.startsWith('$providerRoot/')) return UserRole.provider;
    if (location.startsWith('$adminRoot/')) return UserRole.admin;
    if (isPublic(location)) return null;
    return UserRole.customer;
  }

  static bool isPublic(String location) =>
      location == splash ||
      location == onboarding ||
      location.startsWith('/auth/') ||
      location == designSystem;
}
