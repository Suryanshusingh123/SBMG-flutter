import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
  ];

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get goodEvening;

  /// No description provided for @goodNight.
  ///
  /// In en, this message translates to:
  /// **'Good night'**
  String get goodNight;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @myComplaint.
  ///
  /// In en, this message translates to:
  /// **'My Complaints'**
  String get myComplaint;

  /// No description provided for @schemes.
  ///
  /// In en, this message translates to:
  /// **'Schemes'**
  String get schemes;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @raiseComplaint.
  ///
  /// In en, this message translates to:
  /// **'Raise complaint'**
  String get raiseComplaint;

  /// No description provided for @callUsMessage.
  ///
  /// In en, this message translates to:
  /// **'Call us at 0141-2204880 for any complaint'**
  String get callUsMessage;

  /// No description provided for @featuredScheme.
  ///
  /// In en, this message translates to:
  /// **'Featured Scheme'**
  String get featuredScheme;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAll;

  /// No description provided for @noSchemesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No schemes available'**
  String get noSchemesAvailable;

  /// No description provided for @surveyDetails.
  ///
  /// In en, this message translates to:
  /// **'Gp Master Data details'**
  String get surveyDetails;

  /// No description provided for @getContractorDetails.
  ///
  /// In en, this message translates to:
  /// **'Get your contractor details'**
  String get getContractorDetails;

  /// No description provided for @events.
  ///
  /// In en, this message translates to:
  /// **'Event'**
  String get events;

  /// No description provided for @eventsPlural.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get eventsPlural;

  /// No description provided for @noEventsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No events available'**
  String get noEventsAvailable;

  /// No description provided for @locationServicesRequired.
  ///
  /// In en, this message translates to:
  /// **'Location Services Required'**
  String get locationServicesRequired;

  /// No description provided for @locationServicesMessage.
  ///
  /// In en, this message translates to:
  /// **'This app needs location services to geotag your complaint images. Please enable location services in your device settings.'**
  String get locationServicesMessage;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @locationPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Location Permission Required'**
  String get locationPermissionRequired;

  /// No description provided for @locationPermissionMessage.
  ///
  /// In en, this message translates to:
  /// **'This app needs location permission to geotag your complaint images. This helps us verify the location of your complaints.'**
  String get locationPermissionMessage;

  /// No description provided for @grantPermission.
  ///
  /// In en, this message translates to:
  /// **'Grant Permission'**
  String get grantPermission;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @hindi.
  ///
  /// In en, this message translates to:
  /// **'हिंदी (Hindi)'**
  String get hindi;

  /// No description provided for @languageChanged.
  ///
  /// In en, this message translates to:
  /// **'Language changed successfully'**
  String get languageChanged;

  /// No description provided for @gpMasterDataNotFilled.
  ///
  /// In en, this message translates to:
  /// **'GP Master data is not filled by the respective VDO yet. Kindly contact VDO or helpline number for further assistance.'**
  String get gpMasterDataNotFilled;

  /// No description provided for @contractorDetailsNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Contractor details are not available for this Gram Panchayat yet. Kindly contact VDO or helpline number for further assistance.'**
  String get contractorDetailsNotAvailable;

  /// No description provided for @bookmarks.
  ///
  /// In en, this message translates to:
  /// **'Bookmarks'**
  String get bookmarks;

  /// No description provided for @bookmarkedSchemes.
  ///
  /// In en, this message translates to:
  /// **'Bookmarked schemes'**
  String get bookmarkedSchemes;

  /// No description provided for @noBookmarkedSchemes.
  ///
  /// In en, this message translates to:
  /// **'No bookmarked schemes'**
  String get noBookmarkedSchemes;

  /// No description provided for @bookmarkSchemesToSeeHere.
  ///
  /// In en, this message translates to:
  /// **'Bookmark schemes to see them here'**
  String get bookmarkSchemesToSeeHere;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @closed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get closed;

  /// No description provided for @updates.
  ///
  /// In en, this message translates to:
  /// **'Updates'**
  String get updates;

  /// No description provided for @latestUpdate.
  ///
  /// In en, this message translates to:
  /// **'(latest update)'**
  String get latestUpdate;

  /// No description provided for @complaintResolved.
  ///
  /// In en, this message translates to:
  /// **'Complaint resolved'**
  String get complaintResolved;

  /// No description provided for @underProcess.
  ///
  /// In en, this message translates to:
  /// **'Under Process'**
  String get underProcess;

  /// No description provided for @waitingFromYourEnd.
  ///
  /// In en, this message translates to:
  /// **'Waiting from your end'**
  String get waitingFromYourEnd;

  /// No description provided for @timeline.
  ///
  /// In en, this message translates to:
  /// **'Timeline'**
  String get timeline;

  /// No description provided for @notSatisfied.
  ///
  /// In en, this message translates to:
  /// **'Not satisfied'**
  String get notSatisfied;

  /// No description provided for @markCompleted.
  ///
  /// In en, this message translates to:
  /// **'Mark Completed'**
  String get markCompleted;

  /// No description provided for @resolveNow.
  ///
  /// In en, this message translates to:
  /// **'Resolve now'**
  String get resolveNow;

  /// No description provided for @seeResolution.
  ///
  /// In en, this message translates to:
  /// **'See resolution'**
  String get seeResolution;

  /// No description provided for @uploadImage.
  ///
  /// In en, this message translates to:
  /// **'Upload image'**
  String get uploadImage;

  /// No description provided for @selectTypeOfComplaint.
  ///
  /// In en, this message translates to:
  /// **'Select Type of Complaint'**
  String get selectTypeOfComplaint;

  /// No description provided for @describeComplaint.
  ///
  /// In en, this message translates to:
  /// **'Describe complaint'**
  String get describeComplaint;

  /// No description provided for @inputText.
  ///
  /// In en, this message translates to:
  /// **'Input Text'**
  String get inputText;

  /// No description provided for @nextAddLocation.
  ///
  /// In en, this message translates to:
  /// **'Next: Add location'**
  String get nextAddLocation;

  /// No description provided for @selectOption.
  ///
  /// In en, this message translates to:
  /// **'Select option'**
  String get selectOption;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @requestComplaint.
  ///
  /// In en, this message translates to:
  /// **'Request Complaint'**
  String get requestComplaint;

  /// No description provided for @toRequestComplaint.
  ///
  /// In en, this message translates to:
  /// **'To request a complaint,\nplease login'**
  String get toRequestComplaint;

  /// No description provided for @maximumImagesAllowed.
  ///
  /// In en, this message translates to:
  /// **'Maximum 2 images allowed'**
  String get maximumImagesAllowed;

  /// No description provided for @errorPickingImage.
  ///
  /// In en, this message translates to:
  /// **'Error picking image'**
  String get errorPickingImage;

  /// No description provided for @pleaseFillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill all fields'**
  String get pleaseFillAllFields;

  /// No description provided for @noComplaintTypesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No complaint types available'**
  String get noComplaintTypesAvailable;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @loadingComplaintTypes.
  ///
  /// In en, this message translates to:
  /// **'Loading complaint types...'**
  String get loadingComplaintTypes;

  /// No description provided for @district.
  ///
  /// In en, this message translates to:
  /// **'District'**
  String get district;

  /// No description provided for @block.
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get block;

  /// No description provided for @gramPanchayat.
  ///
  /// In en, this message translates to:
  /// **'Gram Panchayat'**
  String get gramPanchayat;

  /// No description provided for @village.
  ///
  /// In en, this message translates to:
  /// **'Village'**
  String get village;

  /// No description provided for @wardArea.
  ///
  /// In en, this message translates to:
  /// **'Ward/Area'**
  String get wardArea;

  /// No description provided for @selectDistrict.
  ///
  /// In en, this message translates to:
  /// **'Select District'**
  String get selectDistrict;

  /// No description provided for @selectBlock.
  ///
  /// In en, this message translates to:
  /// **'Select Block'**
  String get selectBlock;

  /// No description provided for @selectGramPanchayat.
  ///
  /// In en, this message translates to:
  /// **'Select Gram Panchayat'**
  String get selectGramPanchayat;

  /// No description provided for @enterVillage.
  ///
  /// In en, this message translates to:
  /// **'Enter Village'**
  String get enterVillage;

  /// No description provided for @enterWardArea.
  ///
  /// In en, this message translates to:
  /// **'Enter Ward/Area'**
  String get enterWardArea;

  /// No description provided for @submitComplaint.
  ///
  /// In en, this message translates to:
  /// **'Submit Complaint'**
  String get submitComplaint;

  /// No description provided for @authenticationRequired.
  ///
  /// In en, this message translates to:
  /// **'Authentication required. Please login.'**
  String get authenticationRequired;

  /// No description provided for @complaintSubmittedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Complaint submitted successfully!'**
  String get complaintSubmittedSuccessfully;

  /// No description provided for @failedToSubmitComplaint.
  ///
  /// In en, this message translates to:
  /// **'Failed to submit complaint'**
  String get failedToSubmitComplaint;

  /// No description provided for @myCollection.
  ///
  /// In en, this message translates to:
  /// **'My Collection'**
  String get myCollection;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @faqs.
  ///
  /// In en, this message translates to:
  /// **'FAQs'**
  String get faqs;

  /// No description provided for @giveUsFeedback.
  ///
  /// In en, this message translates to:
  /// **'Give us Feedback'**
  String get giveUsFeedback;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @loginAsAdmin.
  ///
  /// In en, this message translates to:
  /// **'Login as Admin'**
  String get loginAsAdmin;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'This feature is coming soon!'**
  String get comingSoon;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @enterYourName.
  ///
  /// In en, this message translates to:
  /// **'Enter your name.'**
  String get enterYourName;

  /// No description provided for @selectGender.
  ///
  /// In en, this message translates to:
  /// **'Select Gender'**
  String get selectGender;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @profileSavedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Profile saved successfully'**
  String get profileSavedSuccessfully;

  /// No description provided for @notification.
  ///
  /// In en, this message translates to:
  /// **'Notification'**
  String get notification;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get clearAll;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get noNotifications;

  /// No description provided for @notificationsWillAppearHere.
  ///
  /// In en, this message translates to:
  /// **'You\'ll see notifications here when they arrive'**
  String get notificationsWillAppearHere;

  /// No description provided for @allNotificationsCleared.
  ///
  /// In en, this message translates to:
  /// **'All notifications cleared'**
  String get allNotificationsCleared;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @validTill.
  ///
  /// In en, this message translates to:
  /// **'Valid till'**
  String get validTill;

  /// No description provided for @noSchemesAvailableMessage.
  ///
  /// In en, this message translates to:
  /// **'No Schemes Available'**
  String get noSchemesAvailableMessage;

  /// No description provided for @checkBackLater.
  ///
  /// In en, this message translates to:
  /// **'Check back later for new schemes'**
  String get checkBackLater;

  /// No description provided for @errorLoadingSchemes.
  ///
  /// In en, this message translates to:
  /// **'Error Loading Schemes'**
  String get errorLoadingSchemes;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @benefits.
  ///
  /// In en, this message translates to:
  /// **'Benefits'**
  String get benefits;

  /// No description provided for @eligibility.
  ///
  /// In en, this message translates to:
  /// **'Eligibility'**
  String get eligibility;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @noDescriptionAvailable.
  ///
  /// In en, this message translates to:
  /// **'No description available'**
  String get noDescriptionAvailable;

  /// No description provided for @noBenefitsListed.
  ///
  /// In en, this message translates to:
  /// **'No benefits listed'**
  String get noBenefitsListed;

  /// No description provided for @eligibilityCriteria.
  ///
  /// In en, this message translates to:
  /// **'Eligibility Criteria'**
  String get eligibilityCriteria;

  /// No description provided for @noEligibilityCriteriaListed.
  ///
  /// In en, this message translates to:
  /// **'No eligibility criteria listed'**
  String get noEligibilityCriteriaListed;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @enterMobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter Mobile Number'**
  String get enterMobileNumber;

  /// No description provided for @verifyOtp.
  ///
  /// In en, this message translates to:
  /// **'Verify OTP'**
  String get verifyOtp;

  /// No description provided for @enterOtpSentTo.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit verification code sent to mobile number'**
  String get enterOtpSentTo;

  /// No description provided for @weWillSendOtp.
  ///
  /// In en, this message translates to:
  /// **'We will send you a one-time password'**
  String get weWillSendOtp;

  /// No description provided for @mobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Mobile Number'**
  String get mobileNumber;

  /// No description provided for @enterMobileNumberPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'00000 00000'**
  String get enterMobileNumberPlaceholder;

  /// No description provided for @enterOtp.
  ///
  /// In en, this message translates to:
  /// **'Enter OTP'**
  String get enterOtp;

  /// No description provided for @enterOtpPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Enter 6-digit OTP'**
  String get enterOtpPlaceholder;

  /// No description provided for @resendOtp.
  ///
  /// In en, this message translates to:
  /// **'Resend OTP'**
  String get resendOtp;

  /// No description provided for @otpSentSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'OTP sent successfully'**
  String get otpSentSuccessfully;

  /// No description provided for @loginSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Login successful!'**
  String get loginSuccessful;

  /// No description provided for @pleaseEnterValidOtp.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid 6-digit OTP'**
  String get pleaseEnterValidOtp;

  /// No description provided for @pleaseEnterMobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter mobile number'**
  String get pleaseEnterMobileNumber;

  /// No description provided for @mobileNumberMustBe10Digits.
  ///
  /// In en, this message translates to:
  /// **'Mobile number must be 10 digits'**
  String get mobileNumberMustBe10Digits;

  /// No description provided for @sendOtp.
  ///
  /// In en, this message translates to:
  /// **'Send OTP'**
  String get sendOtp;

  /// No description provided for @verifyAndLogin.
  ///
  /// In en, this message translates to:
  /// **'Verify & Login'**
  String get verifyAndLogin;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @knowYourAreasContractor.
  ///
  /// In en, this message translates to:
  /// **'Know your areas contractor'**
  String get knowYourAreasContractor;

  /// No description provided for @contractorDetails.
  ///
  /// In en, this message translates to:
  /// **'Contractor details'**
  String get contractorDetails;

  /// No description provided for @agencyInformation.
  ///
  /// In en, this message translates to:
  /// **'Agency Information'**
  String get agencyInformation;

  /// No description provided for @agencyName.
  ///
  /// In en, this message translates to:
  /// **'Agency Name'**
  String get agencyName;

  /// No description provided for @agencyPhone.
  ///
  /// In en, this message translates to:
  /// **'Agency Phone'**
  String get agencyPhone;

  /// No description provided for @agencyEmail.
  ///
  /// In en, this message translates to:
  /// **'Agency Email'**
  String get agencyEmail;

  /// No description provided for @agencyAddress.
  ///
  /// In en, this message translates to:
  /// **'Agency Address'**
  String get agencyAddress;

  /// No description provided for @personName.
  ///
  /// In en, this message translates to:
  /// **'Person Name'**
  String get personName;

  /// No description provided for @personPhone.
  ///
  /// In en, this message translates to:
  /// **'Person Phone'**
  String get personPhone;

  /// No description provided for @contractInformation.
  ///
  /// In en, this message translates to:
  /// **'Contract Information'**
  String get contractInformation;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get endDate;

  /// No description provided for @getDetails.
  ///
  /// In en, this message translates to:
  /// **'Get details'**
  String get getDetails;

  /// No description provided for @pleaseSelectAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please select all fields'**
  String get pleaseSelectAllFields;

  /// No description provided for @failedToLoadDistricts.
  ///
  /// In en, this message translates to:
  /// **'Failed to load districts'**
  String get failedToLoadDistricts;

  /// No description provided for @failedToLoadBlocks.
  ///
  /// In en, this message translates to:
  /// **'Failed to load blocks'**
  String get failedToLoadBlocks;

  /// No description provided for @failedToLoadVillages.
  ///
  /// In en, this message translates to:
  /// **'Failed to load villages'**
  String get failedToLoadVillages;

  /// No description provided for @failedToLoadContractorDetails.
  ///
  /// In en, this message translates to:
  /// **'Failed to load contractor details'**
  String get failedToLoadContractorDetails;

  /// No description provided for @toViewYourComplaintStatus.
  ///
  /// In en, this message translates to:
  /// **'To view your lodged complaint status,\nplease login'**
  String get toViewYourComplaintStatus;

  /// No description provided for @noImagesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No images available'**
  String get noImagesAvailable;

  /// No description provided for @enterYourPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get enterYourPhoneNumber;

  /// No description provided for @toRaiseComplaint.
  ///
  /// In en, this message translates to:
  /// **'To raise a complaint, you need to login first.'**
  String get toRaiseComplaint;

  /// No description provided for @loginRequired.
  ///
  /// In en, this message translates to:
  /// **'Login Required'**
  String get loginRequired;

  /// No description provided for @complaintLocation.
  ///
  /// In en, this message translates to:
  /// **'Complaint Location'**
  String get complaintLocation;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @enterLocation.
  ///
  /// In en, this message translates to:
  /// **'Enter Location'**
  String get enterLocation;

  /// No description provided for @yourComplaintHasBeenSubmittedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Your Complaint has\nbeen submitted successfully'**
  String get yourComplaintHasBeenSubmittedSuccessfully;

  /// No description provided for @enterFeedback.
  ///
  /// In en, this message translates to:
  /// **'Enter Feedback'**
  String get enterFeedback;

  /// No description provided for @howWasYourExperience.
  ///
  /// In en, this message translates to:
  /// **'How was your experience?'**
  String get howWasYourExperience;

  /// No description provided for @chooseYourExperience.
  ///
  /// In en, this message translates to:
  /// **'Choose your experience'**
  String get chooseYourExperience;

  /// No description provided for @yourFeedbackIsSuccessfullySubmitted.
  ///
  /// In en, this message translates to:
  /// **'Your feedback is successfully submitted'**
  String get yourFeedbackIsSuccessfullySubmitted;

  /// No description provided for @masterDataDetails.
  ///
  /// In en, this message translates to:
  /// **'Master Data Details'**
  String get masterDataDetails;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @pleaseSelectAllFieldsForMasterData.
  ///
  /// In en, this message translates to:
  /// **'Please select all fields'**
  String get pleaseSelectAllFieldsForMasterData;

  /// No description provided for @villageMasterDataForm.
  ///
  /// In en, this message translates to:
  /// **'GP Master Data Form'**
  String get villageMasterDataForm;

  /// No description provided for @sentOTP.
  ///
  /// In en, this message translates to:
  /// **'Send OTP'**
  String get sentOTP;

  /// No description provided for @verifyOTP.
  ///
  /// In en, this message translates to:
  /// **'Verify OTP'**
  String get verifyOTP;

  /// No description provided for @didntReceiveCode.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive the code?'**
  String get didntReceiveCode;

  /// No description provided for @resend.
  ///
  /// In en, this message translates to:
  /// **'Resend'**
  String get resend;

  /// No description provided for @searchDistricts.
  ///
  /// In en, this message translates to:
  /// **'Search districts...'**
  String get searchDistricts;

  /// No description provided for @searchBlocks.
  ///
  /// In en, this message translates to:
  /// **'Search blocks...'**
  String get searchBlocks;

  /// No description provided for @searchVillages.
  ///
  /// In en, this message translates to:
  /// **'Search villages...'**
  String get searchVillages;

  /// No description provided for @searchComplaintTypes.
  ///
  /// In en, this message translates to:
  /// **'Search complaint types...'**
  String get searchComplaintTypes;

  /// No description provided for @selectComplaintType.
  ///
  /// In en, this message translates to:
  /// **'Select Complaint Type'**
  String get selectComplaintType;

  /// No description provided for @noSurveyDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No survey data available for this GP'**
  String get noSurveyDataAvailable;

  /// No description provided for @languageSavedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Language saved successfully'**
  String get languageSavedSuccessfully;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @darkModeComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode coming soon'**
  String get darkModeComingSoon;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @alreadyInLightMode.
  ///
  /// In en, this message translates to:
  /// **'Already in Light Mode'**
  String get alreadyInLightMode;

  /// No description provided for @feedbackSavedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Feedback saved successfully'**
  String get feedbackSavedSuccessfully;

  /// No description provided for @invalidOTP.
  ///
  /// In en, this message translates to:
  /// **'Invalid OTP. Please try again.'**
  String get invalidOTP;

  /// No description provided for @pleaseEnterCompleteOTP.
  ///
  /// In en, this message translates to:
  /// **'Please enter complete OTP'**
  String get pleaseEnterCompleteOTP;

  /// No description provided for @loginRequiredForRaise.
  ///
  /// In en, this message translates to:
  /// **'To raise a complaint, you need to login first.'**
  String get loginRequiredForRaise;

  /// No description provided for @loginRequiredForComplaints.
  ///
  /// In en, this message translates to:
  /// **'To view your complaints, you need to login first.'**
  String get loginRequiredForComplaints;

  /// No description provided for @pleaseRateYourExperience.
  ///
  /// In en, this message translates to:
  /// **'Please rate your experience'**
  String get pleaseRateYourExperience;

  /// No description provided for @workOrderDate.
  ///
  /// In en, this message translates to:
  /// **'Work order date'**
  String get workOrderDate;

  /// No description provided for @annualContractAmount.
  ///
  /// In en, this message translates to:
  /// **'Annual contract amount'**
  String get annualContractAmount;

  /// No description provided for @durationOfWork.
  ///
  /// In en, this message translates to:
  /// **'Duration of work'**
  String get durationOfWork;

  /// No description provided for @frequencyOfWork.
  ///
  /// In en, this message translates to:
  /// **'Frequency of work'**
  String get frequencyOfWork;

  /// No description provided for @genderMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get genderMale;

  /// No description provided for @genderFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get genderFemale;

  /// No description provided for @genderOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get genderOther;

  /// No description provided for @complaintResolvedDescription.
  ///
  /// In en, this message translates to:
  /// **'Complaint id XYZ resolved by supervisor, please confirm if you are satisfied'**
  String get complaintResolvedDescription;

  /// No description provided for @newSchemeAdded.
  ///
  /// In en, this message translates to:
  /// **'New scheme added'**
  String get newSchemeAdded;

  /// No description provided for @newSchemeAddedDescription.
  ///
  /// In en, this message translates to:
  /// **'New scheme added, might be helpful to you'**
  String get newSchemeAddedDescription;

  /// No description provided for @upcomingEvents.
  ///
  /// In en, this message translates to:
  /// **'Upcoming events'**
  String get upcomingEvents;

  /// No description provided for @upcomingEventsDescription.
  ///
  /// In en, this message translates to:
  /// **'New event coming, checkout more details'**
  String get upcomingEventsDescription;

  /// No description provided for @fiveMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'5 min ago'**
  String get fiveMinutesAgo;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @setPassword.
  ///
  /// In en, this message translates to:
  /// **'Set Password'**
  String get setPassword;

  /// No description provided for @enterNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter new password'**
  String get enterNewPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @setNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Set new password'**
  String get setNewPassword;

  /// Sort option to show newest complaints first
  ///
  /// In en, this message translates to:
  /// **'Newest First'**
  String get newestFirst;

  /// Sort option to show oldest complaints first
  ///
  /// In en, this message translates to:
  /// **'Oldest First'**
  String get oldestFirst;

  /// Title for date filter modal
  ///
  /// In en, this message translates to:
  /// **'Filter by'**
  String get filterBy;

  /// Day filter option
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get day;

  /// Week filter option
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get week;

  /// Month filter option
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// Year filter option
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get year;

  /// Custom date range filter option
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get custom;

  /// Apply filter button text
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// Start date input placeholder
  ///
  /// In en, this message translates to:
  /// **'Select Start Date*'**
  String get selectStartDate;

  /// End date input placeholder
  ///
  /// In en, this message translates to:
  /// **'Select End Date*'**
  String get selectEndDate;

  /// No description provided for @complaintCreated.
  ///
  /// In en, this message translates to:
  /// **'Complaint created'**
  String get complaintCreated;

  /// No description provided for @resolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get resolved;

  /// No description provided for @verified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verified;

  /// No description provided for @complaintClosed.
  ///
  /// In en, this message translates to:
  /// **'Disposed complaints'**
  String get complaintClosed;

  /// No description provided for @waitingForSupervisorToResolve.
  ///
  /// In en, this message translates to:
  /// **'Waiting for supervisor to resolve'**
  String get waitingForSupervisorToResolve;

  /// No description provided for @verificationPending.
  ///
  /// In en, this message translates to:
  /// **'Verification Pending'**
  String get verificationPending;

  /// No description provided for @waitingForVdoToVerify.
  ///
  /// In en, this message translates to:
  /// **'Waiting for VDO to verify'**
  String get waitingForVdoToVerify;

  /// No description provided for @feedbackRequired.
  ///
  /// In en, this message translates to:
  /// **'Feedback Required'**
  String get feedbackRequired;

  /// No description provided for @feedback.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedback;

  /// No description provided for @writeYourFeedbackHere.
  ///
  /// In en, this message translates to:
  /// **'Write your feedback here...'**
  String get writeYourFeedbackHere;

  /// No description provided for @formSubmittedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Form submitted successfully!'**
  String get formSubmittedSuccessfully;

  /// No description provided for @supervisor.
  ///
  /// In en, this message translates to:
  /// **'Supervisor'**
  String get supervisor;

  /// No description provided for @complaints.
  ///
  /// In en, this message translates to:
  /// **'Complaints'**
  String get complaints;

  /// No description provided for @attendance.
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get attendance;

  /// No description provided for @totalReportedComplaint.
  ///
  /// In en, this message translates to:
  /// **'Total Reported Complaint'**
  String get totalReportedComplaint;

  /// No description provided for @openComplaint.
  ///
  /// In en, this message translates to:
  /// **'Open Complaint'**
  String get openComplaint;

  /// No description provided for @disposedComplaints.
  ///
  /// In en, this message translates to:
  /// **'Disposed complaints'**
  String get disposedComplaints;

  /// No description provided for @todayComplaints.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Complaints'**
  String get todayComplaints;

  /// No description provided for @tooltipTotalReportedComplaintDescription.
  ///
  /// In en, this message translates to:
  /// **'Total number of complaints reported in the selected date range. Includes open, resolved, verified, and closed complaints.'**
  String get tooltipTotalReportedComplaintDescription;

  /// No description provided for @tooltipOpenComplaintDescription.
  ///
  /// In en, this message translates to:
  /// **'Complaints that are not yet resolved. These are pending action from the concerned officer.'**
  String get tooltipOpenComplaintDescription;

  /// No description provided for @tooltipResolvedComplaintsDescription.
  ///
  /// In en, this message translates to:
  /// **'Resolved count includes: Resolved + Verified + Closed complaints.'**
  String get tooltipResolvedComplaintsDescription;

  /// No description provided for @tooltipTodayComplaintsDescription.
  ///
  /// In en, this message translates to:
  /// **'Number of complaints reported today.'**
  String get tooltipTodayComplaintsDescription;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @noComplaintsForToday.
  ///
  /// In en, this message translates to:
  /// **'No complaints for today'**
  String get noComplaintsForToday;

  /// No description provided for @featuredSchemes.
  ///
  /// In en, this message translates to:
  /// **'Featured Schemes'**
  String get featuredSchemes;

  /// No description provided for @complaintDetails.
  ///
  /// In en, this message translates to:
  /// **'Complaint Details'**
  String get complaintDetails;

  /// No description provided for @resolution.
  ///
  /// In en, this message translates to:
  /// **'Resolution'**
  String get resolution;

  /// No description provided for @noResolutionDetailsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No resolution details available'**
  String get noResolutionDetailsAvailable;

  /// No description provided for @writeYourCommentHere.
  ///
  /// In en, this message translates to:
  /// **'Write your comment here...'**
  String get writeYourCommentHere;

  /// No description provided for @complaintResolvedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Complaint resolved successfully'**
  String get complaintResolvedSuccessfully;

  /// No description provided for @failedToResolveComplaint.
  ///
  /// In en, this message translates to:
  /// **'Failed to resolve complaint'**
  String get failedToResolveComplaint;

  /// No description provided for @getDirections.
  ///
  /// In en, this message translates to:
  /// **'Get directions'**
  String get getDirections;

  /// No description provided for @locationNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Location not available'**
  String get locationNotAvailable;

  /// No description provided for @attendanceMarked.
  ///
  /// In en, this message translates to:
  /// **'Attendance Marked'**
  String get attendanceMarked;

  /// No description provided for @attendanceMarkedDescription.
  ///
  /// In en, this message translates to:
  /// **'Your attendance has been successfully marked.'**
  String get attendanceMarkedDescription;

  /// No description provided for @attendanceEnded.
  ///
  /// In en, this message translates to:
  /// **'Attendance Ended'**
  String get attendanceEnded;

  /// No description provided for @attendanceEndedDescription.
  ///
  /// In en, this message translates to:
  /// **'Your attendance has been successfully ended.'**
  String get attendanceEndedDescription;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @present.
  ///
  /// In en, this message translates to:
  /// **'Present'**
  String get present;

  /// No description provided for @incomplete.
  ///
  /// In en, this message translates to:
  /// **'Incomplete'**
  String get incomplete;

  /// No description provided for @totalDays.
  ///
  /// In en, this message translates to:
  /// **'Total days'**
  String get totalDays;

  /// No description provided for @loginAsCitizen.
  ///
  /// In en, this message translates to:
  /// **'Login as Citizen'**
  String get loginAsCitizen;

  /// No description provided for @areYouSureLogout.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get areYouSureLogout;

  /// No description provided for @logoutDescription.
  ///
  /// In en, this message translates to:
  /// **'You\'ll need to sign in again to access your account.'**
  String get logoutDescription;

  /// No description provided for @scanQRCodeForAttendance.
  ///
  /// In en, this message translates to:
  /// **'Scan QR code for attendance'**
  String get scanQRCodeForAttendance;

  /// No description provided for @scanError.
  ///
  /// In en, this message translates to:
  /// **'Scan Error'**
  String get scanError;

  /// No description provided for @invalidQRCodeFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid QR code format. Expected: lat,long or JSON with lat and long keys.'**
  String get invalidQRCodeFormat;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @resolutionComment.
  ///
  /// In en, this message translates to:
  /// **'Resolution Comment'**
  String get resolutionComment;

  /// No description provided for @comment.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get comment;

  /// No description provided for @noAttendanceRecordsFound.
  ///
  /// In en, this message translates to:
  /// **'No attendance records found'**
  String get noAttendanceRecordsFound;

  /// No description provided for @selectMonth.
  ///
  /// In en, this message translates to:
  /// **'Select Month'**
  String get selectMonth;

  /// No description provided for @endAttendance.
  ///
  /// In en, this message translates to:
  /// **'End Attendance'**
  String get endAttendance;

  /// No description provided for @markAttendance.
  ///
  /// In en, this message translates to:
  /// **'Mark Attendance'**
  String get markAttendance;

  /// No description provided for @attendanceLog.
  ///
  /// In en, this message translates to:
  /// **'Attendance log'**
  String get attendanceLog;

  /// No description provided for @presentDaysOfTotal.
  ///
  /// In en, this message translates to:
  /// **'Present days of total'**
  String get presentDaysOfTotal;

  /// No description provided for @okButton.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get okButton;

  /// No description provided for @attendanceSummary.
  ///
  /// In en, this message translates to:
  /// **'Attendance log'**
  String get attendanceSummary;

  /// No description provided for @totalWorkingDays.
  ///
  /// In en, this message translates to:
  /// **'Total days'**
  String get totalWorkingDays;

  /// No description provided for @absent.
  ///
  /// In en, this message translates to:
  /// **'Absent'**
  String get absent;

  /// No description provided for @noActiveAttendanceSession.
  ///
  /// In en, this message translates to:
  /// **'No active attendance session found'**
  String get noActiveAttendanceSession;

  /// No description provided for @attendanceDescription.
  ///
  /// In en, this message translates to:
  /// **'Your attendance has been successfully marked.'**
  String get attendanceDescription;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @waitingVerificationFromVdo.
  ///
  /// In en, this message translates to:
  /// **'Waiting verification from VDO'**
  String get waitingVerificationFromVdo;

  /// No description provided for @commentSection.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get commentSection;

  /// No description provided for @schemeDetails.
  ///
  /// In en, this message translates to:
  /// **'Scheme Details'**
  String get schemeDetails;

  /// No description provided for @viewing.
  ///
  /// In en, this message translates to:
  /// **'Viewing'**
  String get viewing;

  /// No description provided for @couldNotOpenGoogleMaps.
  ///
  /// In en, this message translates to:
  /// **'Could not open Google Maps'**
  String get couldNotOpenGoogleMaps;

  /// No description provided for @pleaseEnterCompleteOtp.
  ///
  /// In en, this message translates to:
  /// **'Please enter complete OTP'**
  String get pleaseEnterCompleteOtp;

  /// No description provided for @passwordResetSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Password reset successfully'**
  String get passwordResetSuccessfully;

  /// No description provided for @scanQrCodeForAttendance.
  ///
  /// In en, this message translates to:
  /// **'Scan QR code for attendance'**
  String get scanQrCodeForAttendance;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @updateYourFeedback.
  ///
  /// In en, this message translates to:
  /// **'Update your feedback'**
  String get updateYourFeedback;

  /// No description provided for @yourFeedbackHasBeenUpdated.
  ///
  /// In en, this message translates to:
  /// **'Your feedback has been updated'**
  String get yourFeedbackHasBeenUpdated;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @areYouSureYouWantToLogOut.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get areYouSureYouWantToLogOut;

  /// No description provided for @youllNeedToSignInAgainToAccessTheApp.
  ///
  /// In en, this message translates to:
  /// **'You\'ll need to sign in again to access your account.'**
  String get youllNeedToSignInAgainToAccessTheApp;

  /// No description provided for @complaintVerified.
  ///
  /// In en, this message translates to:
  /// **'Complaint verified'**
  String get complaintVerified;

  /// No description provided for @vdo.
  ///
  /// In en, this message translates to:
  /// **'VDO'**
  String get vdo;

  /// No description provided for @inspection.
  ///
  /// In en, this message translates to:
  /// **'Inspection'**
  String get inspection;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get thisMonth;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @checkContractorSupervisorAttendance.
  ///
  /// In en, this message translates to:
  /// **'Check Contractor / Supervisor attendance'**
  String get checkContractorSupervisorAttendance;

  /// No description provided for @updateContractorDetails.
  ///
  /// In en, this message translates to:
  /// **'Update Contractor details'**
  String get updateContractorDetails;

  /// No description provided for @startVillageMasterData.
  ///
  /// In en, this message translates to:
  /// **'Start the GP Master Data'**
  String get startVillageMasterData;

  /// No description provided for @viewGpMasterData.
  ///
  /// In en, this message translates to:
  /// **'View GP Master Data'**
  String get viewGpMasterData;

  /// No description provided for @editGpMasterData.
  ///
  /// In en, this message translates to:
  /// **'Edit GP Master Data'**
  String get editGpMasterData;

  /// No description provided for @addGpMasterData.
  ///
  /// In en, this message translates to:
  /// **'Add GP Master Data'**
  String get addGpMasterData;

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// No description provided for @supportedBy.
  ///
  /// In en, this message translates to:
  /// **'Supported by'**
  String get supportedBy;

  /// No description provided for @noComplaintsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No complaints available'**
  String get noComplaintsAvailable;

  /// No description provided for @awaitingForCitizenToCloseComplaint.
  ///
  /// In en, this message translates to:
  /// **'Awaiting for citizen to close complaint'**
  String get awaitingForCitizenToCloseComplaint;

  /// No description provided for @awaitingForSupervisorToTakeAction.
  ///
  /// In en, this message translates to:
  /// **'Awaiting for supervisor to take action'**
  String get awaitingForSupervisorToTakeAction;

  /// No description provided for @awaitingForVdoToVerify.
  ///
  /// In en, this message translates to:
  /// **'Awaiting for VDO to verify'**
  String get awaitingForVdoToVerify;

  /// No description provided for @pleaseSelectDateRangeFirst.
  ///
  /// In en, this message translates to:
  /// **'Please select a date range first'**
  String get pleaseSelectDateRangeFirst;

  /// No description provided for @selectDateRangeToEnableExport.
  ///
  /// In en, this message translates to:
  /// **'Select a date range to enable export'**
  String get selectDateRangeToEnableExport;

  /// No description provided for @totalReportedComplaints.
  ///
  /// In en, this message translates to:
  /// **'Total Reported Complaints'**
  String get totalReportedComplaints;

  /// No description provided for @openComplaints.
  ///
  /// In en, this message translates to:
  /// **'Open Complaints'**
  String get openComplaints;

  /// No description provided for @resolvedComplaints.
  ///
  /// In en, this message translates to:
  /// **'Resolved complaints'**
  String get resolvedComplaints;

  /// No description provided for @csvExportedToDownloads.
  ///
  /// In en, this message translates to:
  /// **'CSV file exported successfully to Downloads folder: {fileName}'**
  String csvExportedToDownloads(String fileName);

  /// No description provided for @errorExportingCsv.
  ///
  /// In en, this message translates to:
  /// **'Error exporting CSV: {error}'**
  String errorExportingCsv(String error);

  /// No description provided for @couldNotOpenLink.
  ///
  /// In en, this message translates to:
  /// **'Could not open {platform} link.'**
  String couldNotOpenLink(String platform);

  /// No description provided for @connectWithSwachhRajasthan.
  ///
  /// In en, this message translates to:
  /// **'Connect with Swachh Rajasthan'**
  String get connectWithSwachhRajasthan;

  /// No description provided for @noContractorDetailsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No contractor details available'**
  String get noContractorDetailsAvailable;

  /// No description provided for @viewRankingsOfGp.
  ///
  /// In en, this message translates to:
  /// **'View Rankings of GP'**
  String get viewRankingsOfGp;

  /// No description provided for @exitApp.
  ///
  /// In en, this message translates to:
  /// **'Exit App'**
  String get exitApp;

  /// No description provided for @areYouSureExitApp.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to exit the app?'**
  String get areYouSureExitApp;

  /// No description provided for @exit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exit;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @noComplaintsFound.
  ///
  /// In en, this message translates to:
  /// **'No complaints found'**
  String get noComplaintsFound;

  /// No description provided for @complaintCount.
  ///
  /// In en, this message translates to:
  /// **'Complaint ({count})'**
  String complaintCount(int count);

  /// No description provided for @openCount.
  ///
  /// In en, this message translates to:
  /// **'Open ({count})'**
  String openCount(int count);

  /// No description provided for @resolvedCount.
  ///
  /// In en, this message translates to:
  /// **'Resolved ({count})'**
  String resolvedCount(int count);

  /// No description provided for @verifiedCount.
  ///
  /// In en, this message translates to:
  /// **'Verified ({count})'**
  String verifiedCount(int count);

  /// No description provided for @disposedComplaintsCount.
  ///
  /// In en, this message translates to:
  /// **'Disposed complaints ({count})'**
  String disposedComplaintsCount(int count);

  /// No description provided for @startNewInspection.
  ///
  /// In en, this message translates to:
  /// **'Start new inspection'**
  String get startNewInspection;

  /// No description provided for @noInspectionsFound.
  ///
  /// In en, this message translates to:
  /// **'No inspections found'**
  String get noInspectionsFound;

  /// No description provided for @inspectionLogCount.
  ///
  /// In en, this message translates to:
  /// **'Inspection log ({count})'**
  String inspectionLogCount(int count);

  /// No description provided for @viewGpsInspection.
  ///
  /// In en, this message translates to:
  /// **'View GPs inspection'**
  String get viewGpsInspection;

  /// No description provided for @selectLocation.
  ///
  /// In en, this message translates to:
  /// **'Select Location'**
  String get selectLocation;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @searchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search....'**
  String get searchPlaceholder;

  /// No description provided for @searchBlock.
  ///
  /// In en, this message translates to:
  /// **'Search block...'**
  String get searchBlock;

  /// No description provided for @searchGp.
  ///
  /// In en, this message translates to:
  /// **'Search GP...'**
  String get searchGp;

  /// No description provided for @pleaseSelectDistrictFirstForGp.
  ///
  /// In en, this message translates to:
  /// **'Please select a district first to view Gram Panchayats.'**
  String get pleaseSelectDistrictFirstForGp;

  /// No description provided for @failedToLoadGramPanchayats.
  ///
  /// In en, this message translates to:
  /// **'Failed to load Gram Panchayats'**
  String get failedToLoadGramPanchayats;

  /// No description provided for @noBlocksFound.
  ///
  /// In en, this message translates to:
  /// **'No blocks found'**
  String get noBlocksFound;

  /// No description provided for @noGramPanchayatsFoundForBlock.
  ///
  /// In en, this message translates to:
  /// **'No Gram Panchayats found for {block}'**
  String noGramPanchayatsFoundForBlock(String block);

  /// No description provided for @chooseAnotherBlock.
  ///
  /// In en, this message translates to:
  /// **'Choose another block'**
  String get chooseAnotherBlock;

  /// No description provided for @districtOrBlockNotFound.
  ///
  /// In en, this message translates to:
  /// **'District or Block information not found'**
  String get districtOrBlockNotFound;

  /// No description provided for @inspectionLog.
  ///
  /// In en, this message translates to:
  /// **'Inspection log'**
  String get inspectionLog;

  /// No description provided for @noGramPanchayatsFound.
  ///
  /// In en, this message translates to:
  /// **'No Gram Panchayats found'**
  String get noGramPanchayatsFound;

  /// No description provided for @pleaseSelectDistrictFirst.
  ///
  /// In en, this message translates to:
  /// **'Please select a district first.'**
  String get pleaseSelectDistrictFirst;

  /// No description provided for @noDataAvailableForBlock.
  ///
  /// In en, this message translates to:
  /// **'No data available for the selected block.'**
  String get noDataAvailableForBlock;

  /// No description provided for @districtInfoNotFound.
  ///
  /// In en, this message translates to:
  /// **'District information not found. Please select a district first.'**
  String get districtInfoNotFound;

  /// No description provided for @viewingInspectionDetailsFor.
  ///
  /// In en, this message translates to:
  /// **'Viewing inspection details for {gpName}'**
  String viewingInspectionDetailsFor(String gpName);

  /// No description provided for @failedToLoadAttendance.
  ///
  /// In en, this message translates to:
  /// **'Failed to load attendance'**
  String get failedToLoadAttendance;

  /// No description provided for @errorLoadingAttendance.
  ///
  /// In en, this message translates to:
  /// **'Error loading attendance: {error}'**
  String errorLoadingAttendance(String error);

  /// No description provided for @attendanceLogFor.
  ///
  /// In en, this message translates to:
  /// **'Attendance log - {gpName}'**
  String attendanceLogFor(String gpName);

  /// No description provided for @attendanceLogPresentTotal.
  ///
  /// In en, this message translates to:
  /// **'Attendance log ({present}/{total})'**
  String attendanceLogPresentTotal(int present, int total);

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @unknownDate.
  ///
  /// In en, this message translates to:
  /// **'Unknown date'**
  String get unknownDate;

  /// No description provided for @roadMaintenance.
  ///
  /// In en, this message translates to:
  /// **'Road Maintenance'**
  String get roadMaintenance;

  /// No description provided for @complaintHasBeenClosed.
  ///
  /// In en, this message translates to:
  /// **'Complaint has been closed'**
  String get complaintHasBeenClosed;

  /// No description provided for @closeComplaint.
  ///
  /// In en, this message translates to:
  /// **'Close complaint'**
  String get closeComplaint;

  /// No description provided for @closeComplaintConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to close this complaint?'**
  String get closeComplaintConfirmation;

  /// No description provided for @contractorSupervisor.
  ///
  /// In en, this message translates to:
  /// **'Contractor / Supervisor'**
  String get contractorSupervisor;

  /// No description provided for @maximumFivePhotosUploaded.
  ///
  /// In en, this message translates to:
  /// **'Maximum 5 photos can be uploaded'**
  String get maximumFivePhotosUploaded;

  /// No description provided for @onlyPhotosAddedMaximumFive.
  ///
  /// In en, this message translates to:
  /// **'Only {count} photo(s) added. Maximum 5 photos allowed.'**
  String onlyPhotosAddedMaximumFive(int count);

  /// No description provided for @failedToPickImagesError.
  ///
  /// In en, this message translates to:
  /// **'Failed to pick images: {error}'**
  String failedToPickImagesError(String error);

  /// No description provided for @inspectionSubmittedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Your Inspection has been submitted successfully'**
  String get inspectionSubmittedSuccessfully;

  /// No description provided for @pleaseEnterVillageName.
  ///
  /// In en, this message translates to:
  /// **'Please enter village name'**
  String get pleaseEnterVillageName;

  /// No description provided for @failedToSubmitInspection.
  ///
  /// In en, this message translates to:
  /// **'Failed to submit inspection: {error}'**
  String failedToSubmitInspection(String error);

  /// No description provided for @enterVillageName.
  ///
  /// In en, this message translates to:
  /// **'Enter village name'**
  String get enterVillageName;

  /// No description provided for @generalDetails.
  ///
  /// In en, this message translates to:
  /// **'General Details'**
  String get generalDetails;

  /// No description provided for @numberOfWards.
  ///
  /// In en, this message translates to:
  /// **'Number of Wards'**
  String get numberOfWards;

  /// No description provided for @numberPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Number'**
  String get numberPlaceholder;

  /// No description provided for @dailyRegisterMaintainedAtHeadquarters.
  ///
  /// In en, this message translates to:
  /// **'Daily Register maintained at Headquarters'**
  String get dailyRegisterMaintainedAtHeadquarters;

  /// No description provided for @householdWasteCollectionDisposal.
  ///
  /// In en, this message translates to:
  /// **'Household Waste Collection & Disposal Work'**
  String get householdWasteCollectionDisposal;

  /// No description provided for @atWhatIntervalWasteCollected.
  ///
  /// In en, this message translates to:
  /// **'At what interval is waste collected from houses?'**
  String get atWhatIntervalWasteCollected;

  /// No description provided for @arrangementSeparateWetDryWaste.
  ///
  /// In en, this message translates to:
  /// **'Arrangement for separate collection of wet & dry waste in cleaning vehicles'**
  String get arrangementSeparateWetDryWaste;

  /// No description provided for @wasteDisposedAtRrc.
  ///
  /// In en, this message translates to:
  /// **'Is the waste being disposed of at RRC'**
  String get wasteDisposedAtRrc;

  /// No description provided for @arrangementWasteAtRrc.
  ///
  /// In en, this message translates to:
  /// **'Arrangement of waste collection and disposal at RRC'**
  String get arrangementWasteAtRrc;

  /// No description provided for @wasteCollectionVehiclePrepared.
  ///
  /// In en, this message translates to:
  /// **'Is the waste collection vehicle properly prepared/functional'**
  String get wasteCollectionVehiclePrepared;

  /// No description provided for @roadCleaningWork.
  ///
  /// In en, this message translates to:
  /// **'Road Cleaning Work'**
  String get roadCleaningWork;

  /// No description provided for @atWhatIntervalRoadsSwept.
  ///
  /// In en, this message translates to:
  /// **'At what interval are roads/markets/main squares swept/cleaned?'**
  String get atWhatIntervalRoadsSwept;

  /// No description provided for @drainCleaningWork.
  ///
  /// In en, this message translates to:
  /// **'Drain Cleaning Work'**
  String get drainCleaningWork;

  /// No description provided for @atWhatIntervalDrainsCleaned.
  ///
  /// In en, this message translates to:
  /// **'At what interval are drains cleaned?'**
  String get atWhatIntervalDrainsCleaned;

  /// No description provided for @disposalSludgeFromDrains.
  ///
  /// In en, this message translates to:
  /// **'Arrangement for disposal of sludge from drains'**
  String get disposalSludgeFromDrains;

  /// No description provided for @drainWasteOnRoadside.
  ///
  /// In en, this message translates to:
  /// **'Is the drain waste collected on the roadside'**
  String get drainWasteOnRoadside;

  /// No description provided for @cscCleaningWork.
  ///
  /// In en, this message translates to:
  /// **'Community Sanitation Complex (CSC) Cleaning Work'**
  String get cscCleaningWork;

  /// No description provided for @intervalCscCleaning.
  ///
  /// In en, this message translates to:
  /// **'Interval of CSC cleaning'**
  String get intervalCscCleaning;

  /// No description provided for @availabilityElectricityWaterCsc.
  ///
  /// In en, this message translates to:
  /// **'Availability of electricity & water in CSC'**
  String get availabilityElectricityWaterCsc;

  /// No description provided for @cscUsedByCommunity.
  ///
  /// In en, this message translates to:
  /// **'Is the CSC being used by the community'**
  String get cscUsedByCommunity;

  /// No description provided for @pinkToiletInSchoolsUsed.
  ///
  /// In en, this message translates to:
  /// **'Is the pink toilet in schools being used'**
  String get pinkToiletInSchoolsUsed;

  /// No description provided for @otherPoints.
  ///
  /// In en, this message translates to:
  /// **'Other Points'**
  String get otherPoints;

  /// No description provided for @firmPaidRegularly.
  ///
  /// In en, this message translates to:
  /// **'Is the firm being paid regularly'**
  String get firmPaidRegularly;

  /// No description provided for @cleaningStaffPaidRegularly.
  ///
  /// In en, this message translates to:
  /// **'Are cleaning staff being paid regularly by the firm'**
  String get cleaningStaffPaidRegularly;

  /// No description provided for @safetyEquipmentProvided.
  ///
  /// In en, this message translates to:
  /// **'Has the firm provided safety equipment'**
  String get safetyEquipmentProvided;

  /// No description provided for @entryInFeedbackRegister.
  ///
  /// In en, this message translates to:
  /// **'Is entry being made regularly in the feedback register'**
  String get entryInFeedbackRegister;

  /// No description provided for @rateChartPrepared.
  ///
  /// In en, this message translates to:
  /// **'Is a rate chart prepared for cleaning work'**
  String get rateChartPrepared;

  /// No description provided for @rateChartDisplayed.
  ///
  /// In en, this message translates to:
  /// **'Is the rate chart displayed at major locations'**
  String get rateChartDisplayed;

  /// No description provided for @suggestionsByInspector.
  ///
  /// In en, this message translates to:
  /// **'Suggestions by Inspector'**
  String get suggestionsByInspector;

  /// No description provided for @daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @fortnight.
  ///
  /// In en, this message translates to:
  /// **'Fortnight'**
  String get fortnight;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @gp.
  ///
  /// In en, this message translates to:
  /// **'GP'**
  String get gp;

  /// No description provided for @bdo.
  ///
  /// In en, this message translates to:
  /// **'BDO'**
  String get bdo;

  /// No description provided for @selectGp.
  ///
  /// In en, this message translates to:
  /// **'Select GP'**
  String get selectGp;

  /// No description provided for @errorLoadingGps.
  ///
  /// In en, this message translates to:
  /// **'Error loading GPs: {error}'**
  String errorLoadingGps(String error);

  /// No description provided for @failedToLoadRankings.
  ///
  /// In en, this message translates to:
  /// **'Failed to load rankings: {error}'**
  String failedToLoadRankings(String error);

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @failedToLoadComplaintDetails.
  ///
  /// In en, this message translates to:
  /// **'Failed to load complaint details'**
  String get failedToLoadComplaintDetails;

  /// No description provided for @unknownLocation.
  ///
  /// In en, this message translates to:
  /// **'Unknown Location'**
  String get unknownLocation;

  /// No description provided for @invalidCoordinates.
  ///
  /// In en, this message translates to:
  /// **'Invalid Coordinates'**
  String get invalidCoordinates;

  /// No description provided for @testLocation.
  ///
  /// In en, this message translates to:
  /// **'Test Location'**
  String get testLocation;

  /// No description provided for @locationAtCoordinates.
  ///
  /// In en, this message translates to:
  /// **'Location at {lat}, {long}'**
  String locationAtCoordinates(String lat, String long);

  /// No description provided for @todaySuffix.
  ///
  /// In en, this message translates to:
  /// **'(today)'**
  String get todaySuffix;

  /// No description provided for @attendanceLogTitle.
  ///
  /// In en, this message translates to:
  /// **'Attendance log ({present}/{total}) - {filter}'**
  String attendanceLogTitle(int present, int total, String filter);

  /// No description provided for @failedToMarkAttendance.
  ///
  /// In en, this message translates to:
  /// **'Failed to mark attendance'**
  String get failedToMarkAttendance;

  /// No description provided for @gramPanchayatName.
  ///
  /// In en, this message translates to:
  /// **'Gram Panchayat Name'**
  String get gramPanchayatName;

  /// No description provided for @noComplaintsForStatus.
  ///
  /// In en, this message translates to:
  /// **'No {status} complaints'**
  String noComplaintsForStatus(String status);

  /// No description provided for @na.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get na;

  /// No description provided for @noDescription.
  ///
  /// In en, this message translates to:
  /// **'No description'**
  String get noDescription;

  /// No description provided for @filterMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get filterMonth;

  /// No description provided for @filterWeek.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get filterWeek;

  /// No description provided for @filterDay.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get filterDay;

  /// No description provided for @tapToScanQRCode.
  ///
  /// In en, this message translates to:
  /// **'Tap the button to scan a QR code'**
  String get tapToScanQRCode;

  /// No description provided for @scan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get scan;

  /// No description provided for @gpMasterData.
  ///
  /// In en, this message translates to:
  /// **'GP Master Data'**
  String get gpMasterData;

  /// No description provided for @gpVillageNotAssignedContactAdmin.
  ///
  /// In en, this message translates to:
  /// **'GP/Village is not assigned to your account. Please contact admin.'**
  String get gpVillageNotAssignedContactAdmin;

  /// No description provided for @exportingData.
  ///
  /// In en, this message translates to:
  /// **'Exporting data...'**
  String get exportingData;

  /// No description provided for @exportSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Export Successful'**
  String get exportSuccessful;

  /// No description provided for @exportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export Failed'**
  String get exportFailed;

  /// No description provided for @csvFileSavedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'CSV file saved successfully!\n\nLocation: {path}'**
  String csvFileSavedSuccessfully(String path);

  /// No description provided for @failedToExportDataPleaseTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Failed to export data. Please try again.'**
  String get failedToExportDataPleaseTryAgain;

  /// No description provided for @addNewAgency.
  ///
  /// In en, this message translates to:
  /// **'Add New Agency'**
  String get addNewAgency;

  /// No description provided for @agencyNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Agency Name*'**
  String get agencyNameRequired;

  /// No description provided for @enterAgencyName.
  ///
  /// In en, this message translates to:
  /// **'Enter agency name'**
  String get enterAgencyName;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @enter10Digits.
  ///
  /// In en, this message translates to:
  /// **'Enter 10 digits'**
  String get enter10Digits;

  /// No description provided for @enterEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter email address'**
  String get enterEmailAddress;

  /// No description provided for @enterAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter address'**
  String get enterAddress;

  /// No description provided for @failedToAddAgency.
  ///
  /// In en, this message translates to:
  /// **'Failed to add agency: {error}'**
  String failedToAddAgency(String error);

  /// No description provided for @agency.
  ///
  /// In en, this message translates to:
  /// **'Agency'**
  String get agency;

  /// No description provided for @selectAgency.
  ///
  /// In en, this message translates to:
  /// **'Select Agency'**
  String get selectAgency;

  /// No description provided for @pleaseSelectAgency.
  ///
  /// In en, this message translates to:
  /// **'Please select an agency'**
  String get pleaseSelectAgency;

  /// No description provided for @pleaseSelectWorkOrderDate.
  ///
  /// In en, this message translates to:
  /// **'Please select work order date'**
  String get pleaseSelectWorkOrderDate;

  /// No description provided for @pleaseSelectDuration.
  ///
  /// In en, this message translates to:
  /// **'Please select duration'**
  String get pleaseSelectDuration;

  /// No description provided for @pleaseSelectDurationToCalculateEndDate.
  ///
  /// In en, this message translates to:
  /// **'Please select duration to calculate end date'**
  String get pleaseSelectDurationToCalculateEndDate;

  /// No description provided for @phoneNumberRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get phoneNumberRequired;

  /// No description provided for @contractorAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Contractor added successfully!'**
  String get contractorAddedSuccessfully;

  /// No description provided for @contractorDetailsUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Contractor details updated successfully!'**
  String get contractorDetailsUpdatedSuccessfully;

  /// No description provided for @addNew.
  ///
  /// In en, this message translates to:
  /// **'Add New'**
  String get addNew;

  /// No description provided for @addContractor.
  ///
  /// In en, this message translates to:
  /// **'Add Contractor'**
  String get addContractor;

  /// No description provided for @enterContractorName.
  ///
  /// In en, this message translates to:
  /// **'Enter contractor name'**
  String get enterContractorName;

  /// No description provided for @phoneNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneNumberLabel;

  /// No description provided for @workOrderDatePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Work Order date'**
  String get workOrderDatePlaceholder;

  /// No description provided for @workOrderAmount.
  ///
  /// In en, this message translates to:
  /// **'Work order amount'**
  String get workOrderAmount;

  /// No description provided for @enterAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter amount'**
  String get enterAmount;

  /// No description provided for @selectDuration.
  ///
  /// In en, this message translates to:
  /// **'Select duration'**
  String get selectDuration;

  /// No description provided for @selectFrequency.
  ///
  /// In en, this message translates to:
  /// **'Select frequency'**
  String get selectFrequency;

  /// No description provided for @thisFieldIsRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get thisFieldIsRequired;

  /// No description provided for @pleaseSelectValue.
  ///
  /// In en, this message translates to:
  /// **'Please select a value'**
  String get pleaseSelectValue;

  /// No description provided for @alternateDays.
  ///
  /// In en, this message translates to:
  /// **'Alternate days'**
  String get alternateDays;

  /// No description provided for @twiceAWeek.
  ///
  /// In en, this message translates to:
  /// **'Twice a week'**
  String get twiceAWeek;

  /// No description provided for @gramPanchayatFallback.
  ///
  /// In en, this message translates to:
  /// **'Gram Panchayat'**
  String get gramPanchayatFallback;

  /// No description provided for @vdoName.
  ///
  /// In en, this message translates to:
  /// **'VDO Name'**
  String get vdoName;

  /// No description provided for @sarpanchDetails.
  ///
  /// In en, this message translates to:
  /// **'Sarpanch details'**
  String get sarpanchDetails;

  /// No description provided for @contactNumber.
  ///
  /// In en, this message translates to:
  /// **'Contact Number'**
  String get contactNumber;

  /// No description provided for @numberPlaceholder10Digits.
  ///
  /// In en, this message translates to:
  /// **'Number (10 digits)'**
  String get numberPlaceholder10Digits;

  /// No description provided for @numberOfWardPanchs.
  ///
  /// In en, this message translates to:
  /// **'Number of Ward Panchs'**
  String get numberOfWardPanchs;

  /// No description provided for @noShort.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get noShort;

  /// No description provided for @workOrderDetails.
  ///
  /// In en, this message translates to:
  /// **'Work order details'**
  String get workOrderDetails;

  /// No description provided for @workOrderNo.
  ///
  /// In en, this message translates to:
  /// **'Work order no'**
  String get workOrderNo;

  /// No description provided for @noDot.
  ///
  /// In en, this message translates to:
  /// **'No.'**
  String get noDot;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @fundSanctioned.
  ///
  /// In en, this message translates to:
  /// **'Fund Sanctioned'**
  String get fundSanctioned;

  /// No description provided for @doorToDoorCollectionDetails.
  ///
  /// In en, this message translates to:
  /// **'Door to door collection details'**
  String get doorToDoorCollectionDetails;

  /// No description provided for @noOfHouseholds.
  ///
  /// In en, this message translates to:
  /// **'No. of households'**
  String get noOfHouseholds;

  /// No description provided for @noOfShops.
  ///
  /// In en, this message translates to:
  /// **'No. of shops'**
  String get noOfShops;

  /// No description provided for @collectionFrequency.
  ///
  /// In en, this message translates to:
  /// **'Collection frequency'**
  String get collectionFrequency;

  /// No description provided for @roadSweepingDetails.
  ///
  /// In en, this message translates to:
  /// **'Road sweeping details'**
  String get roadSweepingDetails;

  /// No description provided for @widthM.
  ///
  /// In en, this message translates to:
  /// **'Width (m)'**
  String get widthM;

  /// No description provided for @widthInMetres.
  ///
  /// In en, this message translates to:
  /// **'Width in metres'**
  String get widthInMetres;

  /// No description provided for @lengthM.
  ///
  /// In en, this message translates to:
  /// **'Length (m)'**
  String get lengthM;

  /// No description provided for @lengthInMetres.
  ///
  /// In en, this message translates to:
  /// **'Length in metres'**
  String get lengthInMetres;

  /// No description provided for @cleaningFrequency.
  ///
  /// In en, this message translates to:
  /// **'Cleaning frequency'**
  String get cleaningFrequency;

  /// No description provided for @drainCleaningDetails.
  ///
  /// In en, this message translates to:
  /// **'Drain cleaning details'**
  String get drainCleaningDetails;

  /// No description provided for @length.
  ///
  /// In en, this message translates to:
  /// **'Length'**
  String get length;

  /// No description provided for @swmAssetsTitle.
  ///
  /// In en, this message translates to:
  /// **'SWM Assets (Solid Waste Management Assets)'**
  String get swmAssetsTitle;

  /// No description provided for @rrcResourceRecoveryCentre.
  ///
  /// In en, this message translates to:
  /// **'RRC (Resource Recovery Centre)'**
  String get rrcResourceRecoveryCentre;

  /// No description provided for @pwmuPlasticWaste.
  ///
  /// In en, this message translates to:
  /// **'PWMU (Plastic Waste Management Unit)'**
  String get pwmuPlasticWaste;

  /// No description provided for @compositPit.
  ///
  /// In en, this message translates to:
  /// **'Composit pit'**
  String get compositPit;

  /// No description provided for @collectionVehicle.
  ///
  /// In en, this message translates to:
  /// **'Collection vehicle'**
  String get collectionVehicle;

  /// No description provided for @sbmgYearTargetsTitle.
  ///
  /// In en, this message translates to:
  /// **'SBMG Year Targets (Swachh Bharat Mission - Gramin Year Targets)'**
  String get sbmgYearTargetsTitle;

  /// No description provided for @ihhlIndividualHousehold.
  ///
  /// In en, this message translates to:
  /// **'IHHL (Individual Household Latrine)'**
  String get ihhlIndividualHousehold;

  /// No description provided for @cscCommunitySanitation.
  ///
  /// In en, this message translates to:
  /// **'CSC (Community Sanitation Complex)'**
  String get cscCommunitySanitation;

  /// No description provided for @soakPit.
  ///
  /// In en, this message translates to:
  /// **'Soak pit'**
  String get soakPit;

  /// No description provided for @magicPit.
  ///
  /// In en, this message translates to:
  /// **'Magic pit'**
  String get magicPit;

  /// No description provided for @leachPit.
  ///
  /// In en, this message translates to:
  /// **'Leach pit'**
  String get leachPit;

  /// No description provided for @wspWasteStabilisation.
  ///
  /// In en, this message translates to:
  /// **'WSP (Waste Stabilisation Pond)'**
  String get wspWasteStabilisation;

  /// No description provided for @dewatsTitle.
  ///
  /// In en, this message translates to:
  /// **'DEWATS (Decentralised Wastewater Treatment System)'**
  String get dewatsTitle;

  /// No description provided for @headName.
  ///
  /// In en, this message translates to:
  /// **'Head name'**
  String get headName;

  /// No description provided for @enterHeadName.
  ///
  /// In en, this message translates to:
  /// **'Enter head name'**
  String get enterHeadName;

  /// No description provided for @addVillage.
  ///
  /// In en, this message translates to:
  /// **'Add Village'**
  String get addVillage;

  /// No description provided for @villagesCount.
  ///
  /// In en, this message translates to:
  /// **'Villages ({count})'**
  String villagesCount(int count);

  /// No description provided for @villageNumber.
  ///
  /// In en, this message translates to:
  /// **'Village {number}'**
  String villageNumber(int number);

  /// No description provided for @villageNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Village name'**
  String get villageNameLabel;

  /// No description provided for @population.
  ///
  /// In en, this message translates to:
  /// **'Population'**
  String get population;

  /// No description provided for @noOfHouseholdsLabel.
  ///
  /// In en, this message translates to:
  /// **'No. of households'**
  String get noOfHouseholdsLabel;

  /// No description provided for @sbmgAssets.
  ///
  /// In en, this message translates to:
  /// **'SBMG Assets'**
  String get sbmgAssets;

  /// No description provided for @gwmAssets.
  ///
  /// In en, this message translates to:
  /// **'GWM Assets'**
  String get gwmAssets;

  /// No description provided for @viewAllSearchAgency.
  ///
  /// In en, this message translates to:
  /// **'View all / Search…'**
  String get viewAllSearchAgency;

  /// No description provided for @ownIncome.
  ///
  /// In en, this message translates to:
  /// **'Own income'**
  String get ownIncome;

  /// No description provided for @ceo.
  ///
  /// In en, this message translates to:
  /// **'CEO'**
  String get ceo;

  /// No description provided for @districtInfoNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'District information not available.'**
  String get districtInfoNotAvailable;

  /// No description provided for @noBlocksAvailable.
  ///
  /// In en, this message translates to:
  /// **'No blocks available.'**
  String get noBlocksAvailable;

  /// No description provided for @citizen.
  ///
  /// In en, this message translates to:
  /// **'Citizen'**
  String get citizen;

  /// No description provided for @pleaseSelectBlockFirst.
  ///
  /// In en, this message translates to:
  /// **'Please select a block first.'**
  String get pleaseSelectBlockFirst;

  /// No description provided for @noGramPanchayatsFoundForThisBlock.
  ///
  /// In en, this message translates to:
  /// **'No Gram Panchayats found for this block.'**
  String get noGramPanchayatsFoundForThisBlock;

  /// No description provided for @failedToLoadBlocksError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load blocks: {error}'**
  String failedToLoadBlocksError(String error);

  /// No description provided for @failedToLoadGramPanchayatsError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load Gram Panchayats: {error}'**
  String failedToLoadGramPanchayatsError(String error);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
