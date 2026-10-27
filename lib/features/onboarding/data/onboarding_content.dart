/// One onboarding slide. The headline is split so the second part can be
/// set in the brand cyan, as in the approved design.
class OnboardingContent {
  const OnboardingContent({
    required this.headline,
    required this.highlight,
    required this.description,
    this.image,
  });

  final String headline;
  final String highlight;
  final String description;

  /// Asset path. Null until the photo for that slide is supplied.
  final String? image;
}

const onboardingPages = [
  OnboardingContent(
    headline: 'Roadside Help,',
    highlight: 'Anytime',
    description: 'Get fast assistance when your vehicle breaks down.',
    image: 'assets/images/onboarding/onboarding_1.png',
  ),
  OnboardingContent(
    headline: 'Find Verified',
    highlight: 'Experts Nearby',
    description: 'Connect with trusted and verified service providers.',
    image: 'assets/images/onboarding/onboarding_2.png',
  ),
  OnboardingContent(
    headline: 'Track Your Rescue',
    highlight: 'in Real-Time',
    description: 'Know exactly when help is arriving with live tracking.',
    image: 'assets/images/onboarding/onboarding_3.png',
  ),
  // Final page is all white in the approved design, with no cyan word.
  OnboardingContent(
    headline: 'Get Back\non the Road',
    highlight: '',
    description: "Request. Track. Resolve. It's that simple.",
    image: 'assets/images/onboarding/onboarding_4.png',
  ),
];
