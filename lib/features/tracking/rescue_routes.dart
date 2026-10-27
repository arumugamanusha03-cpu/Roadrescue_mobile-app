import '../../core/routing/app_routes.dart';
import 'rescue_job.dart';

/// The screen that best shows a job at [stage] — used by the home card so
/// tapping it always lands on the current step.
String rescueRouteFor(RescueStage stage) => switch (stage) {
  RescueStage.submitted || RescueStage.searching => AppRoutes.rescueFinding,
  RescueStage.assigned || RescueStage.onTheWay => AppRoutes.liveTracking,
  RescueStage.arrived => AppRoutes.rescueArrived,
  RescueStage.inProgress => AppRoutes.rescueInProgress,
  RescueStage.completed => AppRoutes.rescueCompleted,
  RescueStage.paid => AppRoutes.rescueRate,
};
