const kAppRepositoryUrl = "https://github.com/GAM3RG33K/steps_ahead";

const kStepDataPrefix = "StepData_";
const kPackageId = "com.happydevworks.steps_ahead";

// Color values used inside the app
const kGrayColorValue = "#FFE6E2D9";
const kCyanColorValue = "#FF4EE0FD";
const kDarkBlueColorValue = "#FF1B7BC3";
const kPrimaryColorValue = "#FF216E2F";

const kProjectName = "Steps Ahead";
const kLogoAsset = "assets/icons/logo.png";
const kLogoTransparentAsset = "assets/icons/logo-transparent.png";
const kLogoLottieAsset = "assets/icons/logo_lottie.json";

const kSettingsKeyDailyGoal = "daily_goal";
const kSettingsDefaultDailyGoal = 7500;

const kSettingsKeyHeightInCms = "user_height";
const kSettingsDefaultHeightInCms = 170;

const kSettingsKeyWeightInKGs = "user_weight";
const kSettingsDefaultWeightInKGs = 60.0;

const kSettingsKeyStepLengthInCms = "step_length";
const kAverageDefaultStepLength = 68.0;
const kAverageMultiplierForStepLength = 1 / 2.5;

const kSettingsKeySpeedIndex = "speed_index";
const kSettingsDefaultSpeedIndex = 1;

const kSettingsDefaultMetValue = 4.6;

const kSettingsKeyLastSensorOutput = "last_sensor_output";
const kSettingsDefaultLastSensorOutput = 0;

const kCustomProgressAssetPathPrefix = "assets/progress/tree-1";
const kCustomProgressAssetPathMultiplier = 2;

const Map<int, Map<String, dynamic>> speedInformationMap = {
  0: {
    "title": "slow",
    "value": 2.0,
    "met": 1.5,
  },
  1: {
    "title": "average",
    "value": 3.5,
    "met": 2.95,
  },
  2: {
    "title": "fast",
    "value": 5.0,
    "met": 4.6,
  },
};
