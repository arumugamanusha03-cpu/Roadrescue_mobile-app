import 'package:flutter/material.dart';

import '../constants/request_status.dart';
import '../constants/service_type.dart';
import '../constants/vehicle_type.dart';

/// Icon conventions.
///
/// - One family only: Material Icons (bundled with Flutter).
/// - Outlined by default; the filled variant marks the selected/active state.
/// - Sizes come from AppSizes (16 / 18 / 20 / 24 / 28). Nothing larger
///   except the location-permission illustration.
/// - An icon is never the only carrier of meaning: pair it with a text label
///   or give it a semantic label.
///
/// Screens reference icons through this class rather than `Icons.*`
/// directly, so a swap (e.g. to Material Symbols) happens in one place.
abstract final class AppIcons {
  // Navigation (outlined / selected pairs).
  static const IconData home = Icons.home_outlined;
  static const IconData homeSelected = Icons.home_rounded;
  static const IconData vehicles = Icons.directions_car_outlined;
  static const IconData vehiclesSelected = Icons.directions_car_filled;
  static const IconData tracking = Icons.navigation_outlined;
  static const IconData trackingSelected = Icons.navigation;
  static const IconData profile = Icons.person_outline;
  static const IconData profileSelected = Icons.person;
  static const IconData history = Icons.history;
  static const IconData dashboard = Icons.space_dashboard_outlined;
  static const IconData dashboardSelected = Icons.space_dashboard;
  static const IconData jobs = Icons.assignment_outlined;
  static const IconData jobsSelected = Icons.assignment;
  static const IconData earnings = Icons.account_balance_wallet_outlined;
  static const IconData earningsSelected = Icons.account_balance_wallet;
  static const IconData customers = Icons.people_outline;
  static const IconData customersSelected = Icons.people;
  static const IconData providers = Icons.engineering_outlined;
  static const IconData providersSelected = Icons.engineering;
  static const IconData requests = Icons.list_alt_outlined;
  static const IconData requestsSelected = Icons.list_alt;
  static const IconData reports = Icons.insert_chart_outlined;
  static const IconData reportsSelected = Icons.insert_chart;

  /// Centre "Get Help" action. Not a tab, so it has no selected pair.
  static const IconData getHelp = Icons.add_rounded;

  // Home quick actions.
  static const IconData emergencyAction = Icons.sos_outlined;
  static const IconData trackRequest = Icons.pin_drop_outlined;
  static const IconData addVehicle = Icons.add_circle_outline;

  // Actions.
  static const IconData back = Icons.arrow_back;
  static const IconData close = Icons.close;
  static const IconData chevronRight = Icons.chevron_right;
  static const IconData notifications = Icons.notifications_none;
  static const IconData search = Icons.search;
  static const IconData clear = Icons.cancel_outlined;
  static const IconData call = Icons.call_outlined;
  static const IconData message = Icons.chat_bubble_outline;
  static const IconData camera = Icons.photo_camera_outlined;
  static const IconData addPhoto = Icons.add_photo_alternate_outlined;
  static const IconData mic = Icons.mic_none;
  static const IconData download = Icons.file_download_outlined;
  static const IconData share = Icons.share_outlined;
  static const IconData filter = Icons.tune;
  static const IconData edit = Icons.edit_outlined;
  static const IconData visibility = Icons.visibility_outlined;
  static const IconData visibilityOff = Icons.visibility_off_outlined;
  static const IconData myLocation = Icons.my_location;

  // Information.
  static const IconData location = Icons.location_on_outlined;
  static const IconData locationSelected = Icons.location_on;
  static const IconData emergency = Icons.emergency_outlined;
  static const IconData rating = Icons.star_rounded;
  static const IconData eta = Icons.schedule;
  static const IconData distance = Icons.route_outlined;
  static const IconData verified = Icons.verified_outlined;
  static const IconData success = Icons.check_circle_outline;
  static const IconData warning = Icons.warning_amber_rounded;
  static const IconData error = Icons.error_outline;
  static const IconData info = Icons.info_outline;
  static const IconData offline = Icons.cloud_off_outlined;
  static const IconData invoice = Icons.receipt_long_outlined;
  static const IconData email = Icons.mail_outline;
  static const IconData lock = Icons.lock_outline;
  static const IconData personName = Icons.badge_outlined;

  static IconData service(ServiceType type, {bool selected = false}) =>
      switch (type) {
        ServiceType.battery =>
          selected ? Icons.battery_alert : Icons.battery_alert_outlined,
        ServiceType.flatTyre =>
          selected ? Icons.tire_repair : Icons.tire_repair_outlined,
        ServiceType.fuel =>
          selected ? Icons.local_gas_station : Icons.local_gas_station_outlined,
        ServiceType.lockedOut => selected ? Icons.lock : Icons.lock_outline,
        ServiceType.engine => selected ? Icons.build : Icons.build_outlined,
        ServiceType.accident =>
          selected ? Icons.warning_rounded : Icons.warning_amber_rounded,
        ServiceType.towing =>
          selected ? Icons.local_shipping : Icons.local_shipping_outlined,
        ServiceType.other =>
          selected ? Icons.more_horiz : Icons.more_horiz_outlined,
      };

  static IconData vehicle(VehicleType type, {bool selected = false}) =>
      switch (type) {
        VehicleType.car =>
          selected
              ? Icons.directions_car_filled
              : Icons.directions_car_outlined,
        VehicleType.bike =>
          selected ? Icons.two_wheeler : Icons.two_wheeler_outlined,
        VehicleType.ev =>
          selected ? Icons.electric_car : Icons.electric_car_outlined,
        VehicleType.other => selected ? Icons.commute : Icons.commute_outlined,
      };

  static IconData status(RequestStatus status) => switch (status) {
    RequestStatus.searching => Icons.radar,
    RequestStatus.accepted => Icons.task_alt,
    RequestStatus.onTheWay => Icons.navigation_outlined,
    RequestStatus.arrived => Icons.where_to_vote_outlined,
    RequestStatus.inProgress => Icons.build_outlined,
    RequestStatus.completed => Icons.check_circle_outline,
    RequestStatus.cancelled => Icons.cancel_outlined,
  };
}
